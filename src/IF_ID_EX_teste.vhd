library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

library pipeline;
use pipeline.types.all;

entity IF_ID_EX_teste is
  port(
       clk, reset, hold, muxc : in std_logic;
       PCatualizado, PCdesvioIn : in std_logic_vector(31 downto 0);
       resultado, PCdesvio : out std_logic_vector(31 downto 0);
	   regWrite:  out std_logic_vector(4 downto 0);
	   write_options, update_info: in std_logic;
	   hit: out std_logic
  );
end IF_ID_EX_teste;

architecture IF_ID_EX_teste of IF_ID_EX_teste is

-------------------- Estagio ID ---------------------------------
component Estagio_ID is
  port(
       clk, reset : in std_logic;
       instruct : in std_logic_vector(31 downto 0);
       writeData : in std_logic_vector(31 downto 0);
	   we : in std_logic;
       endWrite : in std_logic_vector(4 downto 0);
       regData1, regData2 : out std_logic_vector(31 downto 0);
       endDesvio : out std_logic_vector(31 downto 0);
	   rd, rt, shamt :  out std_logic_vector(4 downto 0);
	   op, func : out  std_logic_vector(5 downto 0)
  );
end component;
------------------------------------------------------------------
-------------------- Estagio EX ----------------------------------
component Estagio_EX is
  port(
       clk : in std_logic;
       regData1, regData2 : in std_logic_vector(31 downto 0);
       endDesvio, PCatualizado : in std_logic_vector(31 downto 0);
	   rt, rd : in std_logic_vector(4 downto 0);
       ULAc : in std_logic_vector(3 downto 0); 
	   muxc1, muxc2 : in std_logic;
       resultado : out std_logic_vector(31 downto 0);
       endWrite, PCdesvio : out std_logic_vector(31 downto 0);
	   regWrite:  out std_logic_vector(4 downto 0);
	   vaum, zero : out std_logic
  );
end component;
------------------------------------------------------------------
------------------- Buffer ID/EX ---------------------------------
component Buffer_ID_EX is
  port(
       clk, hold : in std_logic;
       PCin : in std_logic_vector(31 downto 0);
	   regData1in, regData2in, endDesvioIn : in std_logic_vector(31 downto 0);
	   rtIn, rdIn : in std_logic_vector(4 downto 0);
	   
	   
	   PCout : out std_logic_vector(31 downto 0);
	   regData1out, regData2out, endDesvioOut : out std_logic_vector(31 downto 0);
	   rtOut, rdOut : out std_logic_vector(4 downto 0);
	   
	   -- sinais de controle --
	   ULAcIn : in std_logic_vector(3 downto 0);
	   mux1cIn, mux2cIn : in std_logic;
	   
	   ULAcOut : out std_logic_vector(3 downto 0);
	   mux1cOut, mux2cOut : out std_logic;
	   
	   -- controle dos estagios seguintes --
	   muxMEMcIn, muxWBcIn : in std_logic;
	   muxMEMcOut, muxWBcOut : out std_logic
	   
  );
end component;
-------------------------------------------------------------------
--------------------- UC Pipeline ---------------------------------
component controlUnit is
  port(																				
  	   instructionOpCode : in std_logic_vector(5 downto 0);   -- Entrada da UC. Analisa qual instrução executada e como proceder com os sinais de controle
       RegDst            : out std_logic;					  -- Decide campo do operando destino: Rd ou Rt?
	   Regwrite          : out std_logic;				      -- O enable de escrita no banco de registradores
	   ALUSrc            : out std_logic;                     -- Escolhe o segundo operando da ULA
	   PCSrc             : out std_logic;                     -- Escolhe o valor do Program Counter: PC+4 ou outra coisa?
	   MemRead           : out std_logic;				      -- Define leitura no cache de dados
	   MemWrite		     : out std_logic;                     -- Define escrita no cache de dados
	   MemtoReg          : out std_logic;
	   ALUOp             : out std_logic_vector(2 downto 0)   -- Define qual operação será realizada na ULA. São sinais de controle do módulo de controle da ULA
  );
end component;
-------------------------------------------------------------------
---------------------- UC ULA -------------------------------------
component ALUControl is
  port(																				
  		ALUOp      : in std_logic_vector(2 downto 0);
  		FunctField : in std_logic_vector(5 downto 0);
		ULASet     : out std_logic_vector(3 downto 0);
		MulBit     : out std_logic
  );
end component;
-------------------------------------------------------------------
--------------------- Estagio IF ----------------------------------
component Estagio_IF is
  port(
       clk, reset : in std_logic;
       PCatualizado, PCdesvio : in std_logic_vector(31 downto 0);
	   muxc : in std_logic;
       instruct, PC4 : out std_logic_vector(31 downto 0);
	   
	   write_options, update_info: in std_logic;
	   hit: out std_logic;
	   mem_bloco_data: in  word_vector_type(15 downto 0);
	   mem_addr: out std_logic_vector(15 downto 0) := (others => '0')
	   
  );
end component;
-------------------------------------------------------------------
--------------------- Buffer IF/ID --------------------------------
component Buffer_IF_ID is
  port(
       clk, hold : in std_logic;
       PCin, instructIn : in std_logic_vector(31 downto 0);
	   PCout, instructOut : out std_logic_vector(31 downto 0)
	   
  );
end component;
-------------------------------------------------------------------

signal regData1, regData2, writeData, instruct, PC4, instructIn, PC4in : std_logic_vector(31 downto 0);
signal endDesvio :  std_logic_vector(31 downto 0);
signal rd, rt, shamt:  std_logic_vector(4 downto 0);
signal op, func:  std_logic_vector(5 downto 0);
signal PCout, endMemWrite : std_logic_vector(31 downto 0);
signal regData1out, regData2out, endDesvioOut : std_logic_vector(31 downto 0);
signal rtOut, rdOut, endWrite : std_logic_vector(4 downto 0);
signal ULAcIn, ULAcOut : std_logic_vector(3 downto 0);
signal mux1cIn, mux2cIn, mux1cOut, mux2cOut, muxMEMcIn, muxWBcIn, muxMEMcOut, muxWBcOut : std_logic;
signal we, vaum, zero, PCSrc, memread, memwrite, memtoreg, mulbit: std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal mem_bloco_data: word_vector_type(15 downto 0);
signal mem_addr: std_logic_vector(15 downto 0) := (others => '0');

begin
	
ID: Estagio_ID port map (clk, reset, instruct, writeData, we, endWrite, regData1, regData2, endDesvio, rd, rt, shamt, op, func);
ID_EX: Buffer_ID_EX port map (clk, hold, PC4, regData1, regData2, endDesvio, rt, rd, PCout, regData1out, regData2out,
		endDesvioOut, rtOut, rdOut, ULAcIn, mux1cIn, mux2cIn, ULAcOut, mux1cOut, mux2cOut, muxMEMcIn, muxWBcIn, muxMEMcOut, muxWBcOut); 
EX: Estagio_EX port map (clk, regData1out, regData2out, endDesvioOut, PCout, rtOut, rdOut, ULAcOut, mux1cOut, mux2cOut, resultado,
		endMemWrite, PCdesvio, regWrite, vaum, zero);

UC: controlUnit port map (op, mux2cIn, we, mux1cIn, PCSrc, MemRead, MemWrite, Memtoreg, ALUOp);
ALU: ALUControl port map (ALUOp, func, ULAcIn, mulbit);

EIF: Estagio_IF port map (clk, reset, PCatualizado, PCdesvioIn, muxc, instructIn, PC4in, write_options, update_info, hit, mem_bloco_data, mem_addr);
IF_ID: Buffer_IF_ID port map (clk, hold, PC4in, instructIn, PC4, instruct);

end IF_ID_EX_teste;