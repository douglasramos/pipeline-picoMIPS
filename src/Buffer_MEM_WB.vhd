library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Buffer_MEM_WB is
  port(
  	   clk, BufferOff : in std_logic;
       ReadDataIn, resultadoIn : in std_logic_vector(31 downto 0);
	   MemtoregIn :	in std_logic;
	   ReadDataOut, resultadoOut : out std_logic_vector(31 downto 0);
	   MemtoregOut : out std_logic
	   
  );
end Buffer_MEM_WB;

architecture Buffer_MEM_WB of Buffer_MEM_WB is

signal resultado, ReadData: std_logic_vector(31 downto 0);
signal Memtoreg: std_logic;

begin

IF_ID :
process (clk)
begin
	if (clk'event and clk='1' and BufferOff = '0') then  -- Clock na borda de subida
		resultado <= resultadoIn;
		ReadData <= ReadDataIn;
		Memtoreg <= MemtoregIn;
	end if;
end process;

resultadoOut <= resultado;
ReadDataOut <= ReadData;
MemtoregOut <= Memtoreg;


end Buffer_MEM_WB;