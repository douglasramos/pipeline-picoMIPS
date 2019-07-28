library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

library biblioteca_de_componentes;

library pipeline;
use pipeline.types.all;

entity pipeline is
  port(
       clk, clk_cache, reset, muxc: in std_logic;
       PC : in std_logic_vector(31 downto 0);
       resultadoSaida: out std_logic_vector(31 downto 0)
  );
end pipeline;

architecture pipeline of pipeline is

-- Declaração dos componentes
----------------------- Estagio IF -------------------------------------
component Estagio_IF is
  port(
       clk, clk_cache, reset : in std_logic;
       PCatualizado, PCdesvio : in std_logic_vector(31 downto 0);
	   muxc : in std_logic;
       instruct, PC4 : out std_logic_vector(31 downto 0);
	   
	   stall: out std_logic;
	   mem_bloco_data: in  word_vector_type(15 downto 0);
	   mem_addr: out std_logic_vector(15 downto 0) := (others => '0');
	   enable: in std_logic;
       PCin: in std_logic_vector(31 downto 0)
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Estagio ID -------------------------------------
component Estagio_ID is
  port(
       clk, reset : in std_logic;
       instruct : in std_logic_vector(31 downto 0);
       writeData : in std_logic_vector(31 downto 0);
	   we, ALUSrc : in std_logic;
       endWrite : in std_logic_vector(4 downto 0);
       regData1, regData2 : out std_logic_vector(31 downto 0);
       endDesvio : out std_logic_vector(31 downto 0);
	   rs, rd, rt, shamt :  out std_logic_vector(4 downto 0);
	   op, func : out  std_logic_vector(5 downto 0)
  );
end component;
------------------------------------------------------------------------
----------------------- Estagio EX -------------------------------------
component Estagio_EX is
  port(
       clk : in std_logic;
       regData1, regData2, resultadoMEM, resultadoWB : in std_logic_vector(31 downto 0);
       endDesvio, PCatualizado : in std_logic_vector(31 downto 0);
	   rt, rd : in std_logic_vector(4 downto 0);
       ULAc : in std_logic_vector(3 downto 0); 
	   muxOp1, muxOp2: in std_logic_vector(2 downto 0); 
	   muxReg : in std_logic;
       resultado : out std_logic_vector(31 downto 0);
       endWrite, PCdesvio : out std_logic_vector(31 downto 0);
	   regWrite:  out std_logic_vector(4 downto 0);
	   vaum, zero : out std_logic
  );
end component;
-------------------------------------------------------------------------
----------------------- Estagio MEM -------------------------------------
component Estagio_MEM is
  port(
  	   clk:       in std_logic; 
  	   clk_cache: in std_logic;
	   cpu_write: in std_logic;
       address:   in std_logic_vector(15 downto 0);
	   data_in :  in word_type;
	   
	   data_out:  out word_type;
	   stall:     out std_logic
	   
  );
end component;
------------------------------------------------------------------------
----------------------- UC Pipeline ------------------------------------
component controlUnit is
  generic(
  	   TpropLogtime : time := 0.25 ns;  						  --Tempo de propagação de porta lógica
  	   Tprop    	: time := 1 ns;							  --Parametros de reg/flipflop
	   Tsetup       : time := 0.25 ns;						  --Parametros de reg/flipflop
	   Thold        : time := 0.25 ns						  --Parametros de reg/flipflop
  );
  port(																				
  	   clk               : in std_logic;
  	   instructionOpCode : in std_logic_vector(5 downto 0);   -- Entrada da UC. Analisa qual instrução executada e como proceder com os sinais de controle
       RegDst            : out std_logic;					  -- Decide campo do operando destino: Rd ou Rt?
	   Regwrite          : out std_logic;				      -- O enable de escrita no banco de registradores
	   ALUSrc            : out std_logic;                     -- Escolhe o segundo operando da ULA
	   PCSrc             : out std_logic;                     -- Escolhe o valor do Program Counter: PC+4 ou outra coisa?
	   MemRead           : out std_logic;				      -- Define leitura no cache de dados
	   MemWrite		     : out std_logic;                     -- Define escrita no cache de dados
	   MemtoReg          : out std_logic;				   	  -- Sinal para multiplexação no estágio write-back
	   ALUOp             : out std_logic_vector(2 downto 0);  -- Define qual operação será realizada na ULA. São sinais de controle do módulo de controle da ULA
	   EXExcInterrupt    : in  std_logic_vector(1 downto 0);  -- Entrada que define o comportamento do mecanismo de interrupções e exceções
	   IFFlush			 : out std_logic;					  -- Sinal IF.Flush
	   IDFlush			 : out std_logic;					  -- Sinal ID.Flush
	   EXFlush           : out std_logic;				      -- Sinal EX.Flush
	   BufferOff		 : out std_logic;					  -- Desativa enable dos buffers de todos os registradores entre os estágios do pipeline
	   causeValue        : out std_logic_vector(4 downto 0);  -- Write-enable para gravar causa da exceção/interrupção no vetor de causa
	   EPCWriteEnable    : out std_logic					  -- Write-enable para gravar endereço da instrução que deu problema no EPC
  );
end component;
------------------------------------------------------------------------
----------------------- UC ULA -----------------------------------------
component ALUControl is
  port(																				
  		ALUOp      : in std_logic_vector(2 downto 0);
  		FunctField : in std_logic_vector(5 downto 0);
		ULASet     : out std_logic_vector(3 downto 0);
		MulBit     : out std_logic
  );
end component;
------------------------------------------------------------------------
----------------------- Forwarding Unit --------------------------------
component forwardingUnit is
  port(																				
  		ExMemWrite : in  std_logic;
  		MemWbWrite : in  std_logic;
		ExMemRd    : in  std_logic_vector(4 downto 0);
		MemWbRd    : in  std_logic_vector(4 downto 0);
		IdExRs     : in  std_logic_vector(4 downto 0);
		IdExRt     : in  std_logic_vector(4 downto 0);
		ForwardA   : out std_logic_vector(2 downto 0);
		ForwardB   : out std_logic_vector(2 downto 0)
  );
end component;
------------------------------------------------------------------------
----------------------- Hazard Unit ------------------------------------
component hazardUnit is
generic(
  	   TpropLogtime : time := 0.25 ns;  						
  	   Tprop    	: time := 1 ns;							  
	   Tsetup       : time := 0.25 ns;						  
	   Thold        : time := 0.25 ns						  
);
port(
	clk            : in  std_logic;						  -- o mesmo clock do pipeline
	opcode         : in  std_logic_vector(5 downto 0);	  -- opcode lido no estágio ID
	equality       : in  std_logic;                       -- resultado da comparação de igualdade na ULA. Vem do estágio EX
	IDEXMemRead    : in  std_logic;
	IDEXRt	       : in  std_logic_vector(4 downto 0);
	IFIDRs	       : in  std_logic_vector(4 downto 0);
	IFIDRt	       : in  std_logic_vector(4 downto 0);
	isStallForward : out std_logic;
  	IFFlush        : out std_logic;
  	IDFlush        : out std_logic
   );																									
end component;
------------------------------------------------------------------------
----------------------- Buffer IF/ID -----------------------------------
component Buffer_IF_ID is
  port(
  	   clk, BufferOff : in std_logic;
  	   FlushUC, FlushHU : in std_logic;
       PCin, instructIn : in std_logic_vector(31 downto 0);
	   PCout, instructOut : out std_logic_vector(31 downto 0)
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Buffer ID/EX -----------------------------------
component Buffer_ID_EX is
  port(
  	   clk, BufferOff : in std_logic;
  	   FlushHU : in std_logic;
       PCin : in std_logic_vector(31 downto 0);
	   regData1in, regData2in, endDesvioIn : in std_logic_vector(31 downto 0);
	   rsIn, rtIn, rdIn : in std_logic_vector(4 downto 0);
	   
	   
	   PCout : out std_logic_vector(31 downto 0);
	   regData1out, regData2out, endDesvioOut : out std_logic_vector(31 downto 0);
	   rsOut, rtOut, rdOut : out std_logic_vector(4 downto 0);
	   
	   -- sinais de controle --
	   ULAcIn : in std_logic_vector(2 downto 0);
	   muxRegIn : in std_logic;
	   
	   ULAcOut : out std_logic_vector(2 downto 0);
	   muxRegOut : out std_logic;
	   
	   -- controle dos estagios seguintes --
	   MemReadIn, MemWriteIn, MemtoregIn, RegwriteIn, PCSrcIn : in std_logic;
	   MemReadOut, MemWriteOut, MemtoregOut, RegwriteOut, PCSrcOut : out std_logic;
	   
	   funcIn : in std_logic_vector(5 downto 0);
	   funcOut : out std_logic_vector(5 downto 0)
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Buffer EX/MEM ----------------------------------
component Buffer_EX_MEM is
  port(
  	   clk, BufferOff : in std_logic;
       resultadoIn, endWriteIn, PCdesvioIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemReadIn, MemWriteIn, MemtoregIn, RegwriteENin, PCSrcIn : in std_logic;
	   resultadoOut, endWriteOut, PCdesvioOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemReadOut, MemWriteOut, MemtoregOut, RegwriteENout, PCSrcOut : out std_logic
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Buffer MEM/WB ----------------------------------
component Buffer_MEM_WB is
  port(
  	   clk, BufferOff : in std_logic;
       ReadDataIn, resultadoIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemtoregIn, RegwriteENin, MemWriteIn :	in std_logic;
	   ReadDataOut, resultadoOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemtoregOut, RegwriteENout, MemWriteOut : out std_logic
	   
  );
end component;
------------------------------------------------------------------------

------ registrador
component registrador is
  generic(
       NumeroBits : INTEGER := 8;
       Tprop : time := 5 ns;
       Tsetup : time := 2 ns
  );
  port(
       C : in std_logic;
       R : in std_logic;
       S : in std_logic;
       D : in std_logic_vector(NumeroBits - 1 downto 0);
       Q : out std_logic_vector(NumeroBits - 1 downto 0)
  );
end component;
----------------------

-- entradas estagio IF
	signal PCatualizado, PCdesvioIF, PCtemp, PCin, PC4in : std_logic_vector(31 downto 0);
	--signal muxc : std_logic;
	
	--sinais relacionados ao Cache I
	signal stall_I: std_logic;		--saida
	signal mem_bloco_data:  word_vector_type(15 downto 0);
	signal mem_addr: std_logic_vector(15 downto 0) := (others => '0');		--saida
	
-- saidas do estagio IF/entradas buffer IF/ID
	signal instruct, PC4 : std_logic_vector(31 downto 0);
	
--saidas do buffer IF/ID / entradas do estagio ID
	
	
	--sinais que nao vem do buffer
	signal we, ALUSrc : std_logic;		--sinais de controle vindos da UC
    signal writeData : std_logic_vector(31 downto 0);	--sinal vindo do estagio WB
    signal endWriteReg : std_logic_vector(4 downto 0);		--sinal vindo do WB
    
-- saidas do estagio ID / entradas do buffer ID/EX	
	signal regData1, regData2 : std_logic_vector(31 downto 0);
    signal endDesvio : std_logic_vector(31 downto 0);
	signal rs, rd, rt, shamt :  std_logic_vector(4 downto 0);
	--sinais que vao para a UC
	signal op, func, funcOut :  std_logic_vector(5 downto 0);
	
--saidas do buffer ID/EX / entradas do estagio EX
	signal regData1out, regData2out, resultadoMEM, resultadoWB : std_logic_vector(31 downto 0);  --os dois ultimos vem de estagios seguintes, n do buffer
    signal endDesvioOut, PCatualizadoOut : std_logic_vector(31 downto 0);
	signal rsOut, rtOut, rdOut : std_logic_vector(4 downto 0);
    -- sinais vindos do buffer a partir da UC
	signal ULAc : std_logic_vector(3 downto 0); 
	signal muxOp1, muxOp2: std_logic_vector(2 downto 0);	--vem da forward unit, n passa pelo buffer 
	signal muxReg : std_logic;
	   
-- saidas do estagio EX / entradas do buffer EX/MEM	   
    signal resultado : std_logic_vector(31 downto 0);
    signal endWriteMem, PCdesvio : std_logic_vector(31 downto 0);
	signal regWrite:  std_logic_vector(4 downto 0);
	signal vaum, zero : std_logic;
	
-- saidas do buffer EX/MEM / entradas do estagio MEM
	signal cpu_write: std_logic;
    signal address:   std_logic_vector(31 downto 0);
	signal data_in :  word_type;

-- saidas do estagio MEM / entradas do buffer MEM/WB
	signal data_out:  word_type;
	signal stall_D:     std_logic;
	
-- sinais da UC
	signal instructionOpCode : std_logic_vector(5 downto 0);
	signal Regwrite_UC, ALUSrc_UC, PCSrc, MemRead, MemWrite, MemtoReg, RegDst: std_logic;	
	signal ALUOp             : std_logic_vector(2 downto 0);   
	signal EXExcInterrupt    : std_logic_vector(1 downto 0);  
	signal IFFlush_UC, IDFlush_UC, EXFlush_UC, BufferOff, EPCWriteEnable, MulBit: std_logic;					  
	signal causeValue        : std_logic_vector(4 downto 0);
	signal ForwardA, ForwardB        : std_logic_vector(2 downto 0);
	signal Regwrite_UC_F, ALUSrc_UC_f, PCSrc_F, MemRead_F, MemWrite_F, MemtoReg_F, RegDst_F: std_logic;	
	signal ALUOp_F             : std_logic_vector(2 downto 0); 
	
--sinais dos buffers
	signal IFFlush_HU, IDFlush_HU: std_logic;
	signal PC4out, PC4out_EX, instructOut, PCdesvio_EX, resultado_WB, readData: std_logic_vector(31 downto 0);
	signal Regwrite_EX, Regwrite_MEM, Regwrite_WB: std_logic;
	signal endWrite_WB, endWrite_MEM : std_logic_vector(4 downto 0);
	signal ALUOpOut: std_logic_vector(2 downto 0);
	
	signal MemRead_EX, MemWrite_EX, Memtoreg_EX, PCSrc_EX: std_logic;
	signal MemRead_MEM, MemWrite_MEM, MemWrite_WB: std_logic;
	signal Memtoreg_MEM, PCSrc_MEM, Memtoreg_WB, PCSrc_WB, isStallForward, flush, enable: std_logic;
	signal temp, temp2: integer;
	
begin
	
	Est_IF: Estagio_IF port map (clk, clk_cache, reset, PCatualizado, PC, muxc, instruct, PC4, stall_I, mem_bloco_data, mem_addr, enable, PCin);
	--PCSrc -> WB;	PCdesvio -> estagio MEM;	instruct e PC4 vao para o buffer
	
	PCtemp <= (PC4out_EX - x"00000004");
	PCin <= PCtemp when isStallForward = '1' else PCatualizado when PC4out /= x"00000000";
	enable <= '1' when isStallForward = '1' else '0' when PC4out /= x"00000000";
	PC4in <= PC4out_EX when isStallForward = '1' else PC4 when PC4out /= x"00000000";
	reg: registrador generic map (32, 0 ns, 0 ns) port map (clk, '0', '0', PC4in, PCatualizado);
	
	buffer1: Buffer_IF_ID port map (clk, BufferOff,	IFFlush_UC, flush, PC4, instruct, PC4out, instructOut);
	-- BufferOff, Flush_UC -> UC; Flush_HU -> HU; 	instructOut entra no estagio ID;	PC4out vai diretamente para o buffer ID/EX
	flush <= IFFlush_HU or isStallForward;
	
	Est_ID: Estagio_ID port map (clk, reset, instructOut, writeData, Regwrite_WB, ALUsrc, endWrite_WB, regData1, regData2, endDesvio,
								 rs, rd, rt, shamt, op, func);
	-- instructOut -> buffer IF/ID;		writeData -> estagio WB;	Regwrite_WB, endWrite_WB -> buffer MEM/WB
	-- ALUSrc -> UC;	op vai para a UC;	func vai para a ALUOp;	as demais saidas entram no buffer ID/EX
	
	UC: controlUnit generic map (0 ns, 0 ns, 0 ns, 0 ns)
					port map (clk, op, RegDst, Regwrite_UC, ALUSrc, PCSrc, MemRead, MemWrite, Memtoreg, ALUOp, EXExcInterrupt,
							  IFFlush_UC, IDFlush_UC, EXFlush_UC, BufferOff, causeValue, EPCWriteEnable);
	-- op -> estagio ID;	RegDst e ALUOp vao para o buffer para serem usados no estagio EX
	-- PCSrc, MemRead, MemWrite vao para o buffer ID/EX e entao para o buffer EX/MEM para serem usados no estagio MEM
	-- Regwrite_UC e Memtoreg seguem os buffers ID/EX, EX/MEM e MEM/WB para serem usados no estagio WB
	MemRead_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else MemRead;
	MemWrite_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else MemWrite;
	Memtoreg_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else Memtoreg;
	ALUOp_F <= "000" when IDFlush_UC = '1' or isStallForward = '1' else ALUOp;
	PCSrc_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else PCSrc;
	Regwrite_UC_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else Regwrite_UC;
	RegDst_F <= '0' when IDFlush_UC = '1' or isStallForward = '1' else RegDst;
		
		
	ULA_C: ALUControl port map (ALUOpOut, funcOut, ULAc, MulBit);
	-- ALUOpOut, func -> buffer ID/EX;	ULAc entra na ULA do estagio EX
	
	buffer2: Buffer_ID_EX port map (clk, BufferOff, IDFlush_HU, PC4out, regData1, regData2, endDesvio, rs, rt, rd,
							PC4out_EX, regData1out, regData2out, endDesvioOut, rsOut, rtOut, rdOut, ALUOp_F, RegDst_F,
							ALUOpOut, muxReg, MemRead_F, MemWrite_F, Memtoreg_F, RegWrite_UC_F, PCSrc_F,
							MemRead_EX, MemWrite_EX, Memtoreg_EX, RegWrite_EX, PCSrc_EX, func, funcOut);
	
	
	Est_EX: Estagio_EX port map (clk, regData1out, regData2out, address, writeData, endDesvioOut, PC4out_EX, rtOut, rdOut,
								 ULAc, ForwardA, ForwardB, muxReg, resultado, endWriteMem, PCdesvio_EX, regWrite, vaum, zero);
	--ForwardA, ForwardB -> forwardUnit;	resultado, endWriteMem, PCdesvio vao para o buffer EX/MEM
	--os demais sinais vem do buffer
	
	buffer3: Buffer_EX_MEM port map (clk, BufferOff, resultado, endWriteMem, PCdesvio_EX, regWrite, MemRead_EX, MemWrite_EX, Memtoreg_EX, Regwrite_EX, PCSrc_EX,
									 address, data_in, PCdesvio, endWrite_MEM, MemRead_MEM, MemWrite_MEM, Memtoreg_MEM, Regwrite_MEM, PCSrc_MEM);
	--PCdesvio_EX -> buffer ID/EX;	PCdesvio vai para o mux no estagio IF
	--data_in e address entram no cache de dados;	os sinais de controle MemRead e MemWrite sao usados no estagio MEM
	--os sinais de controle Memtoreg e PCSrc serao passados para o buffer MEM/WB
	
	Est_MEM: Estagio_MEM port map (clk, clk_cache, MemWrite_MEM, address(15 downto 0), data_in, data_out, stall_D);
	
	
	buffer4: Buffer_MEM_WB port map (clk, BufferOff, data_out, address, endWrite_MEM, Memtoreg_MEM, RegWrite_MEM, MemWrite_MEM, readData, resultado_WB,
									 endWrite_WB, Memtoreg_WB, RegWrite_WB, MemWrite_WB);
	
	

	fwd: forwardingUnit port map (RegWrite_EX, RegWrite_WB, endWrite_MEM, endWrite_WB, rsOut, rtOut, ForwardA, ForwardB);
	
	hzd: hazardUnit generic map (0 ns, 0 ns, 0 ns, 0 ns)
					port map (clk, op, resultado(0), MemRead_EX, rtOut, rs, rt, isStallForward, IFFlush_HU, IDFlush_HU);
	
	
	writeData <= readData when Memtoreg_WB = '1' else resultado_WB;					

	
end pipeline;