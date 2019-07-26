library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwardingUnit is
  port(																				
  		ExMemWrite : in  std_logic;
  		MemWbWrite : in  std_logic;
		ExMemRd    : in  std_logic_vector(4 downto 0);
		MemWbRd    : in  std_logic_vector(4 downto 0);
		IdExRs     : in  std_logic_vector(4 downto 0);
		IdExRt     : in  std_logic_vector(4 downto 0);
		ForwardA   : out std_logic_vector(2 downto 0);
		ForwardB   : out std_logic_vector(2 downto 0)
  );
end forwardingUnit;

architecture forwardingUnit of forwardingUnit is


component comparador5Bits is
  port(																				
  	X    : in std_logic_vector(4 downto 0);
  	Y    : in std_logic_vector(4 downto 0);
	comp : out std_logic
  );
end component;

signal A : std_logic;
signal B : std_logic;
signal C : std_logic_vector(4 downto 0);
signal D : std_logic_vector(4 downto 0);
signal E : std_logic;
signal F : std_logic;
signal G : std_logic;
signal H : std_logic;
signal I : std_logic;
signal J : std_logic;
signal outComparador1 : std_logic;
signal outComparador2 : std_logic;
signal outComparador3 : std_logic;
signal outComparador4 : std_logic;
signal outComparador5 : std_logic;
signal outComparador6 : std_logic;

begin

process(A,B,C,D,E,F,G,H,I,J)
	begin
		if(A = '1' and B = '1' and E = '1') then
			ForwardA <= "010";
		elsif (G = '1' and H = '1' and I = '1' and (not (A = '1' and B = '1' and E = '1')) and I = '1') then
			ForwardA <= "001";
		else
			ForwardA <= "000";
	
		end if;
	
		if(A = '1' and B = '1' and F = '1') then
			ForwardB <= "010";
		elsif(G = '1' and H = '1' and J = '1' and (not (A = '1' and B = '1' and F = '1')) and J = '1') then
			ForwardB <= "001";
		else
			ForwardB <= "000";
		end if;				 
	
end process;  




comparador1 : comparador5Bits port map(ExMemRd,"00000",outComparador1);
comparador2 : comparador5Bits port map(MemWbRd,"00000",outComparador2);
comparador3 : comparador5Bits port map(ExMemRd,C,outComparador3);
comparador4 : comparador5Bits port map(ExMemRd,D,outComparador4);
comparador5 : comparador5Bits port map(MemWbRd,C,outComparador5);
comparador6 : comparador5Bits port map(MemWbRd,D,outComparador6);


A <= ExMemWrite;
C <= IdExRs;
D <= IdExRt;	
G <= MemWbWrite;

B <= not outComparador1;
H <= not outComparador2;
E <= outComparador3;
F <= outComparador4;
I <= outComparador5;
J <= outComparador6;


end forwardingUnit;
