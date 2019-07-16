library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library biblioteca_de_componentes;

entity ULAmodified is
  generic(
       NB 		: integer := 32;
       Tsom 	: time := 5 ns;
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
       C 		: out 	std_logic_vector(NB - 1 downto 0)	--resultado da operação
  );
end ULAmodified;

architecture ULAmodified of ULAmodified is

---- Architecture declarations -----

signal S_NB, Eq, Cmp 	: std_logic_vector (NB downto 0);
signal Zer, D, nd 		: std_logic_vector (NB - 1 downto 0) := (others => '0');
signal zeros 		    : std_logic_vector (NB - 2 downto 0) := (others => '0');
signal Upper 	        : std_logic_vector (NB downto 0)     := ('1', others => '0');
signal n                : integer := 2;
signal carryIn          : integer := 1; 

---------- deslocador -------------------------------
component deslocador_combinatorio
  generic(
       NB    : integer := 32;
       NBD   : integer := 2;
       Tprop : time    := 1 ns
  );
  port(
       DE : in std_logic;
       I  : in std_logic_vector(NB - 1 downto 0);
       O  : out std_logic_vector(NB - 1 downto 0)
  );
end component;
----------------------------------------------------

begin

n       <= to_integer(unsigned(B));
carryIn <= 1 when Veum = '1' else 0;
Eq      <= zeros & "01" when A = B else zeros & "00";
Cmp 	<= zeros & "01" when A < B else zeros & "00";	
	
---- User Signal Assignments ----
With cUla select	  
		S_NB <=	std_logic_vector(signed('0' &  A) + carryIn )	             when "0000",
				std_logic_vector(signed('0' &  A) + signed(B) + carryIn )	 when "0001",
				std_logic_vector(signed('0' &  B) + carryIn )	             when "0010",
				std_logic_vector(signed('0' &  A) - signed(B) + carryIn )	 when "0011",
				std_logic_vector('0' &  (A and B))	     		             when "0100",
				std_logic_vector('0' &  (A or B))		    	             when "0101",
				Eq			                     							 when "0110",
				Cmp				                    						 when "0111",
				std_logic_vector(signed('0' & D) + carryIn) 		         when "1000",
				std_logic_vector(unsigned('0' & A) + unsigned(B) + carryIn)  when "1001",
				(others => '0')				             					 when others;   

--------------------------------------------------------------------------------------------------------------------
-- Saída de Vai um

Vaum <=	S_NB(NB) after Tsom;  

--------------------------------------------------------------------------------------------------------------------
-- Resultado da Operação
C <= 		S_NB(NB - 1 downto 0) after Ttrans  when cUla = "0000" else
			S_NB(NB - 1 downto 0) after Tsom  	when cUla = "0001" else
			S_NB(NB - 1 downto 0) after Ttrans  when cUla = "0010" else
			S_NB(NB - 1 downto 0) after Tsub  	when cUla = "0011" else
			S_NB(NB - 1 downto 0) after Tgate 	when cUla = "0100" else
			S_NB(NB - 1 downto 0) after Tgate 	when cUla = "0101" else
			S_NB(NB - 1 downto 0) after Tsom    when cUla = "0110" else
			S_NB(NB - 1 downto 0) after Tsom 	when cUla = "0111" else
			S_NB(NB - 1 downto 0)			 	when cUla = "1000" else   -- shift não causa atraso
			S_NB(NB - 1 downto 0) after Tsom	when cUla = "1001";       -- add unsigned

--------------------------------------------------------------------------------------------------------------------
-- Atualização do sinal

Sinal <= S_NB(NB - 1) after Tsom;

--------------------------------------------------------------------------------------------------------------------
-- Atualização de Zero 

Zero <= '1'  after Tsom when S_NB(NB - 1 downto 0) = Zer else
					'0' after Tsom ;
 
--------------------------------------------------------------------------------------------------------------------
--Deslocador

deslocador: deslocador_combinatorio generic map (NB, n, 1 ns) port map ('1', A, D);

---------------------------------------------------

end ULAmodified;
