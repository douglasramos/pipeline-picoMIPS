library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Buffer_ID_EX is
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
end Buffer_ID_EX;

architecture Buffer_ID_EX of Buffer_ID_EX is

signal PC, regData1, regData2, endDesvio: std_logic_vector(31 downto 0);
signal rs, rt, rd : std_logic_vector(4 downto 0);
signal ULAc : std_logic_vector(2 downto 0);
signal muxReg, MemRead, MemWrite, Memtoreg, Regwrite, PCSrc : std_logic;
signal func : std_logic_vector(5 downto 0);

begin

IF_ID :
process (clk)
begin	  
	if FlushHU = '1' then
		PC <= "00000000000000000000000000000000";
		regData1 <= "00000000000000000000000000000000";
		regData2 <= "00000000000000000000000000000000";
		endDesvio <= "00000000000000000000000000000000";
		rs <= "00000";
		rt <= "00000";
		rd <= "00000";
		
		ULAc <= "000";
		muxReg <= '0';
		
		MemRead <= '0';
		MemWrite <= '0';
		Memtoreg <= '0';
		Regwrite <= '0';
		PCSrc <= '0';
		func <= "000000";
		
	elsif (clk'event and clk='1' and BufferOff = '0') then  -- Clock na borda de subida
		PC <= PCin;
		regData1 <= regData1in;
		regData2 <= regData2in;
		endDesvio <= endDesvioIn;
		rs <= rsIn;
		rt <= rtIn;
		rd <= rdIn;
		
		ULAc <= ULAcIn;
		muxReg <= muxRegIn;
		
		MemRead <= MemReadIn;
		MemWrite <= MemWriteIn;
		Memtoreg <= MemtoregIn;
		Regwrite <= RegwriteIn;
		PCSrc <= PCSrcIn;
		func <= funcIn;
	end if;
end process;

PCout <= PC;
regData1out <= regData1;
regData2out <= regData2;
endDesvioOut <= endDesvio;
rsOut <= rs; 
rtOut <= rt;
rdOut <= rd;

ULAcOut <= ULAc;
muxRegOut <= muxReg;

MemReadOut <= MemRead;
MemWriteOut <= MemWrite;
MemtoregOut <= Memtoreg;
RegwriteOut <= Regwrite;
PCSrcOut <= PCSrc;
funcOut <= func;

end Buffer_ID_EX;