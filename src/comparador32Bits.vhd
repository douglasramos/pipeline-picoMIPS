library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador32Bits is
  port(																				
  	X    : in std_logic_vector(31 downto 0);
  	Y    : in std_logic_vector(31 downto 0);
	comp : out std_logic
  );
end comparador32Bits;

architecture comparador32Bits of comparador32Bits is
	
	signal Z : std_logic_vector(31 downto 0);
	signal comp1 : std_logic;
	signal comp2 : std_logic;
	signal comp3 : std_logic;
begin

	Z(0) <= not (X(0) xor Y(0));
	Z(1) <= not (X(1) xor Y(1));
	Z(2) <= not (X(2) xor Y(2));
	Z(3) <= not (X(3) xor Y(3));
	Z(4) <= not (X(4) xor Y(4));
	Z(5) <= not (X(5) xor Y(5));
	Z(6) <= not (X(6) xor Y(6));
	Z(7) <= not (X(7) xor Y(7));
	Z(8) <= not (X(8) xor Y(8));
	Z(9) <= not (X(9) xor Y(9));
	Z(10) <= not (X(10) xor Y(10));
	Z(11) <= not (X(11) xor Y(11));
	Z(12) <= not (X(12) xor Y(12));
	Z(13) <= not (X(13) xor Y(13));
	Z(14) <= not (X(14) xor Y(14));
	Z(15) <= not (X(15) xor Y(15));
	Z(16) <= not (X(16) xor Y(16));
	Z(17) <= not (X(17) xor Y(17));
	Z(18) <= not (X(18) xor Y(18));
	Z(19) <= not (X(19) xor Y(19));
	Z(20) <= not (X(20) xor Y(20));
	Z(21) <= not (X(21) xor Y(21));
	Z(22) <= not (X(22) xor Y(22));
	Z(23) <= not (X(23) xor Y(23));
	Z(24) <= not (X(24) xor Y(24));
	Z(25) <= not (X(25) xor Y(25));
	Z(26) <= not (X(26) xor Y(26));
	Z(27) <= not (X(27) xor Y(27));
	Z(28) <= not (X(28) xor Y(28));
	Z(29) <= not (X(29) xor Y(29));
	Z(30) <= not (X(30) xor Y(30));
	Z(31) <= not (X(31) xor Y(31));
	
	comp1 <= Z(0) and Z(1) and Z(2) and Z(3) and Z(4) and Z(5) and Z(6) and Z(7) and Z(8) and Z(9);
	comp2 <= Z(10) and Z(11) and Z(12) and Z(13) and Z(14) and Z(15) and Z(16) and Z(17) and Z(18) and Z(19);
	comp3 <= Z(20) and Z(21) and Z(22) and Z(23) and Z(24) and Z(25) and Z(26) and Z(27) and Z(28) and Z(29) and Z(30) and Z(31);
	
	comp <= comp1 and comp2 and comp3;
	
end comparador32Bits;
