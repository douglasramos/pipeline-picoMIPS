library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Buffer_MEM_WB is
  port(
  	   clk, BufferOff : in std_logic;
       ReadDataIn, resultadoIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemtoregIn, RegwriteENin, MemWriteIn :	in std_logic;
	   ReadDataOut, resultadoOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemtoregOut, RegwriteENout, MemWriteOut : out std_logic
	   
  );
end Buffer_MEM_WB;

architecture Buffer_MEM_WB of Buffer_MEM_WB is

signal resultado, ReadData: std_logic_vector(31 downto 0);
signal Memtoreg, RegwriteEN, MemWrite: std_logic;
signal regWrite: std_logic_vector(4 downto 0);

begin

IF_ID :
process (clk)
begin
	if (clk'event and clk='1' and BufferOff = '0') then  -- Clock na borda de subida
		resultado <= resultadoIn;
		ReadData <= ReadDataIn;
		Memtoreg <= MemtoregIn;
		RegwriteEN <= RegwriteENin;
		regWrite <= regWriteIn;
		MemWrite <= MemWriteIn;
	end if;
end process;

resultadoOut <= resultado;
ReadDataOut <= ReadData;
MemtoregOut <= Memtoreg;
RegwriteENout <= RegwriteEN;
regWriteOut <= regWrite;
MemWriteOut <= MemWrite;


end Buffer_MEM_WB;