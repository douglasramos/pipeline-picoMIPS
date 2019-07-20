-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Rafael Higa 
-- Co-Authors: Pedro Brito, Douglas Ramos 
--
-- Description:
--     ULA modificada 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library biblioteca_de_componentes;

entity ULAmodified is
  generic(
       NB 		: integer := 32;
       Tsom 	: time := 1 ns;   --tava 5, mudei pra 1!
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
end ULAmodified;

architecture ULAmodified of ULAmodified is

---- Architecture declarations -----

signal S_NB, Eq, Cmp 	: std_logic_vector (NB downto 0);
signal Zer, D, nd 		: std_logic_vector (NB - 1 downto 0) := (others => '0');
signal zeros 		    : std_logic_vector (NB - 2 downto 0) := (others => '0');
signal Upper 	        : std_logic_vector (NB downto 0)     := ('1', others => '0');
signal n                : integer := 2;
signal carryIn          : integer := 1; 
signal cUlaEn           : std_logic_vector(4 downto 0);

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

cUlaEn(0) <= cUla(0);
cUlaEn(1) <= cUla(1);
cUlaEn(2) <= cUla(2);
cUlaEn(3) <= cUla(3);
cUlaEn(4) <= enable;

---- User Signal Assignments ----
With cUlaEn select	  
		S_NB <=	std_logic_vector(signed('0' &  A) + carryIn )	             when "10000",
				std_logic_vector(signed('0' &  A) + signed(B) + carryIn )	 when "10001",
				std_logic_vector(signed('0' &  B) + carryIn )	             when "10010",
				std_logic_vector(signed('0' &  A) - signed(B) + carryIn )	 when "10011",
				std_logic_vector('0' &  (A and B))	     		             when "10100",
				std_logic_vector('0' &  (A or B))		    	             when "10101",
				Eq			                     							 when "10110",
				Cmp				                    						 when "10111",
				std_logic_vector(signed('0' & D) + carryIn) 		         when "11000",
				std_logic_vector(unsigned('0' & A) + unsigned(B) + carryIn)  when "11001",
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
