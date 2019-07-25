library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity ID_EX_teste is
  port(
       clk, reset, hold : in std_logic;
       instruct, PCatualizado : in std_logic_vector(31 downto 0);
       resultado, PCdesvio : out std_logic_vector(31 downto 0);
	   regWrite:  out std_logic_vector(4 downto 0) 
  );
end ID_EX_teste;

architecture ID_EX_teste of ID_EX_teste is

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

signal regData1, regData2, writeData : std_logic_vector(31 downto 0);
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

begin
	
ID: Estagio_ID port map (clk, reset, instruct, writeData, we, endWrite, regData1, regData2, endDesvio, rd, rt, shamt, op, func);
ID_EX: Buffer_ID_EX port map (clk, hold, PCatualizado, regData1, regData2, endDesvio, rt, rd, PCout, regData1out, regData2out,
		endDesvioOut, rtOut, rdOut, ULAcIn, mux1cIn, mux2cIn, ULAcOut, mux1cOut, mux2cOut, muxMEMcIn, muxWBcIn, muxMEMcOut, muxWBcOut); 
EX: Estagio_EX port map (clk, regData1out, regData2out, endDesvioOut, PCout, rtOut, rdOut, ULAcOut, mux1cOut, mux2cOut, resultado,
		endMemWrite, PCdesvio, regWrite, vaum, zero);

UC: controlUnit port map (op, mux2cIn, we, mux1cIn, PCSrc, MemRead, MemWrite, Memtoreg, ALUOp);
ALU: ALUControl port map (ALUOp, func, ULAcIn, mulbit);



end ID_EX_teste;