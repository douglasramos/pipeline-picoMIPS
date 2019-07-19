library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inverter is
  generic(
	   Tprop : time := 0.25 ns
  );
  port(
    operando_in           : in  std_logic_vector(31 downto 0);
  	isComplement		  : in  std_logic;
 	operando_out          : out std_logic_vector(31 downto 0);
	en                    : in  std_logic 
  );
end Inverter;

architecture Inverter of Inverter is

signal operando_inter			 : std_logic_vector(31 downto 0);	
signal soma1          			 : std_logic_vector(31 downto 0);
signal operando_in_31 			 : std_logic_vector(31 downto 0);
signal operando_out_intermediate : std_logic_vector(31 downto 0);

component ULAmodified is
  generic(
       NB 		: integer := 32;
       Tsom 	: time := 1 ns;
       Tsub 	: time := 5 ns;
       Ttrans 	: time := 5 ns;
       Tgate 	: time := 1 ns
  );
  port(
       Veum 	: in 	std_logic;					  		--vem um
       A 		: in 	std_logic_vector(NB - 1 downto 0);	--operando
       B 		: in 	std_logic_vector(NB - 1 downto 0);	--operando
       cUla 	: in 	std_logic_vector(3 downto 0);		--controle: qual operação realizar
       Sinal 	: out 	std_logic;							--???
       Vaum 	: out 	std_logic;							--vai um
       Zero 	: out 	std_logic;							--???
       C 		: out 	std_logic_vector(NB - 1 downto 0);	--resultado da operação
	   enable   : in    std_logic
  );
end component;		

  
begin							  

operando_in_31 <="11111111111111111111111111111111" when isComplement = '1' else "00000000000000000000000000000000";

operando_inter <= operando_in_31 xor operando_in after Tprop;

soma1(0) <= isComplement;
soma1(31 downto 1) <= "0000000000000000000000000000000";

soma : ULAmodified port map('0', operando_inter, soma1, "0001", open, open, open, operando_out_intermediate,'1');

operando_out <= operando_out_intermediate when en = '1' else "00000000000000000000000000000000";

end Inverter;