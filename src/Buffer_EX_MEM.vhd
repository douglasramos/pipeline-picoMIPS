library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Buffer_EX_MEM is
  port(
  	   clk, BufferOff : in std_logic;
       resultadoIn, endWriteIn, PCdesvioIn : in std_logic_vector(31 downto 0);
	   regWriteIn :	in std_logic_vector(4 downto 0);
	   MemReadIn, MemWriteIn, MemtoregIn, RegwriteENin, PCSrcIn : in std_logic;
	   resultadoOut, endWriteOut, PCdesvioOut : out std_logic_vector(31 downto 0);
	   regWriteOut : out std_logic_vector(4 downto 0);
	   MemReadOut, MemWriteOut, MemtoregOut, RegwriteENout, PCSrcOut : out std_logic
	   
  );
end Buffer_EX_MEM;

architecture Buffer_EX_MEM of Buffer_EX_MEM is

signal resultado, endWrite, PCdesvio: std_logic_vector(31 downto 0);
signal regWrite: std_logic_vector(4 downto 0);
signal MemRead, MemWrite, Memtoreg, RegwriteEN, PCSrc: std_logic;

begin

IF_ID :
process (clk)
begin
	if (clk'event and clk='1' and BufferOff = '0') then  -- Clock na borda de subida
		resultado <= resultadoIn;
		endWrite <= endWriteIn;
		PCdesvio <= PCdesvioIn;
		regWrite <= regWriteIn;
		MemRead <= MemReadIn;
		MemWrite <= MemWriteIn;
		Memtoreg <= MemtoregIn;
		RegwriteEN <= RegwriteENin;
		PCSrc <= PCSrcIn;
	end if;
end process;

resultadoOut <= resultado;
endWriteOut <= endWrite;
PCdesvioOut <= PCdesvio;
regWriteOut <= regWrite;

MemReadOut <= MemRead;
MemWriteOut <= MemWrite;
MemtoregOut <= Memtoreg;
RegwriteENout <= RegwriteEN;
PCSrcOut <= PCSrc;


end Buffer_EX_MEM;