library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sinal is
  generic(
	   Tprop : time := 0.25 ns
  );
  port(
  	operando           : in  std_logic_vector(15 downto 0);
  	operando_extendido : out std_logic_vector(31 downto 0)
  );
end Sinal;

architecture Sinal of Sinal is


begin							  
	
	operando_extendido <= "1111111111111111" & operando after Tprop when operando(15) = '1' else "0000000000000000" & operando after Tprop;
	
end Sinal;