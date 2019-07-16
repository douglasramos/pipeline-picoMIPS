library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador5Bits is
  port(																				
  	X    : in std_logic_vector(4 downto 0);
  	Y    : in std_logic_vector(4 downto 0);
	comp : out std_logic
  );
end comparador5Bits;

architecture comparador5Bits of comparador5Bits is
	
	signal Z : std_logic_vector(4 downto 0);
	signal comp1 : std_logic;
	signal comp2 : std_logic;
	signal comp3 : std_logic;
begin

	Z(0) <= not (X(0) xor Y(0));
	Z(1) <= not (X(1) xor Y(1));
	Z(2) <= not (X(2) xor Y(2));
	Z(3) <= not (X(3) xor Y(3));
	Z(4) <= not (X(4) xor Y(4));
	
	
	comp <= Z(0) and Z(1) and Z(2) and Z(3) and Z(4);
	
end comparador5Bits;
