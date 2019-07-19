library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bitwise is
  generic(
	   Tprop : time := 0.25 ns
  );
  port(
  	operand : in std_logic_vector(31 downto 0);
  	bitMult : in std_logic;
  	multi   : out std_logic_vector(31 downto 0)
  );
end Bitwise;

architecture Bitwise of Bitwise is
begin							  
	
	multi <= operand after Tprop when bitMult = '1' else "00000000000000000000000000000000" after Tprop;
	
end Bitwise;