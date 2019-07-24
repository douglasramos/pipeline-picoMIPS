library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

library pipeline;
use pipeline.types.all;

entity pipeline is
  port(
       clk, reset: in std_logic;
       PC : in std_logic_vector(31 downto 0);
       resultado: out std_logic_vector(31 downto 0)
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
	   
	   write_options, update_info: in std_logic;
	   stall: out std_logic;
	   mem_bloco_data: in  word_vector_type(15 downto 0);
	   mem_addr: out std_logic_vector(15 downto 0) := (others => '0')
	   
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
  generic(
       NBend : integer := 4;
       NBdado : integer := 8;
       Tread : time := 5 ns;
       Twrite : time := 5 ns
  );
  port(																				
  		ExMemWrite : in std_logic;
  		MemWbWrite : in std_logic;
		ExMemRd    : in std_logic_vector(4 downto 0);
		MemWbRd    : in std_logic_vector(4 downto 0);
		IdExRs     : in std_logic_vector(4 downto 0);
		IdExRt     : in std_logic_vector(4 downto 0);
		ForwardA   : out std_logic_vector(1 downto 0);
		ForwardB   : out std_logic_vector(1 downto 0)
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
	   ULAcIn : in std_logic_vector(3 downto 0);
	   mux1cIn, mux2cIn : in std_logic;
	   
	   ULAcOut : out std_logic_vector(3 downto 0);
	   mux1cOut, mux2cOut : out std_logic;
	   
	   -- controle dos estagios seguintes --
	   MemReadIn, MemWriteIn, MemtoregIn, RegwriteIn : in std_logic;
	   MemReadOut, MemWriteOut, MemtoregOut, RegwriteOut : out std_logic
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Buffer EX/MEM ----------------------------------
component Buffer_EX_MEM is
  port(
  	   clk, BufferOff : in std_logic;
       resultadoIn, endWriteIn, PCdesvioIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemReadIn, MemWriteIn, MemtoregIn, RegwriteENin : in std_logic;
	   resultadoOut, endWriteOut, PCdesvioOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemReadOut, MemWriteOut, MemtoregOut, RegwriteENout : out std_logic
	   
  );
end component;
------------------------------------------------------------------------
----------------------- Buffer MEM/WB ----------------------------------
component Buffer_MEM_WB is
  port(
  	   clk, BufferOff : in std_logic;
       ReadDataIn, resultadoIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemtoregIn, RegwriteENin :	in std_logic;
	   ReadDataOut, resultadoOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemtoregOut, RegwriteENout : out std_logic
	   
  );
end component;
------------------------------------------------------------------------

-- entradas do estagio IF
	



begin
	
	
	
	
	
	
end pipeline;