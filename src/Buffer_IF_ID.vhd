library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Buffer_IF_ID is
  port(
  	   clk, BufferOff : in std_logic;
  	   FlushUC, FlushHU : in std_logic;
       PCin, instructIn : in std_logic_vector(31 downto 0);
	   PCout, instructOut : out std_logic_vector(31 downto 0)
	   
  );
end Buffer_IF_ID;

architecture Buffer_IF_ID of Buffer_IF_ID is

signal PC, instruct: std_logic_vector(31 downto 0);

begin

IF_ID :
process (clk)
begin
	if (FlushUC = '1' or FlushHU = '1') then
		PC <= "00000000000000000000000000000000";
		instruct <= "00000000000000000000000000000000";
	elsif (clk'event and clk='1' and BufferOff = '0') then  -- Clock na borda de subida
		PC <= PCin;
		instruct <= instructIn;
	end if;
end process;

PCout <= PC;
instructOut <= instruct;


end Buffer_IF_ID;