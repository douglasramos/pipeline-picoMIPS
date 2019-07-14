-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Biblioteca_de_Componentes
-- Author      : Wilson Ruggiero
-- Company     : LARC-EPUSP
--
-------------------------------------------------------------------------------
--
-- File        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\compile\ULA.vhd
-- Generated   : Thu Feb  1 16:01:18 2018
-- From        : C:\My_Designs\Biblioteca_de_ComponentesV4.5\src\ULA.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

library biblioteca_de_componentes;

entity ULAmodified is
  generic(
       NB 		: integer := 8;
       Tsom 	: time := 5 ns;
       Tsub 	: time := 5 ns;
       Ttrans 	: time := 5 ns;
       Tgate 	: time := 1 ns
  );
  port(
       Veum 	: in 	std_logic;
       A 		: in 	std_logic_vector(NB - 1 downto 0);
       B 		: in 	std_logic_vector(NB - 1 downto 0);
       cUla 	: in 	std_logic_vector(3 downto 0);
       Sinal 	: out 	std_logic;
       Vaum 	: out 	std_logic;
       Zero 	: out 	std_logic;
       C 		: out 	std_logic_vector(NB - 1 downto 0)
  );
end ULAmodified;

architecture ULAmodified of ULAmodified is

---- Architecture declarations -----
signal S_NB, Eq, Cmp 	: std_logic_vector (NB downto 0);
signal Zer, D, nd 		: std_logic_vector (NB - 1 downto 0) := (others => '0');
signal zeros 		: std_logic_vector (NB - 2 downto 0) := (others => '0');
signal Upper 	: std_logic_vector (NB downto 0) := ( '1', others => '0');
signal n: integer := 2;


---------- deslocador -------------------------------
component deslocador_combinatorio
  generic(
       NB : integer := 8;
       NBD : integer := 2;
       Tprop : time := 1 ns
  );
  port(
       DE : in std_logic;
       I : in std_logic_vector(NB - 1 downto 0);
       O : out std_logic_vector(NB - 1 downto 0)
  );
end component;
----------------------------------------------------


begin

n <= to_integer(unsigned(B));
Eq <= zeros & "01" when A = B else zeros & "00";
Cmp <= zeros & "01" when A < B else zeros & "00";	
	
---- User Signal Assignments ----
With cUla select
		S_NB <=	(('0' &  A) + Veum )		when "0000",
				(('0' &  A) + B + Veum )	when "0001",
				(('0' &  B) + Veum )		when "0010",
				(('0' &  A) - B + Veum )	when "0011",
				('0' &  (A and B))			when "0100",
				('0' &  (A or B))			when "0101",
				 Eq					when "0110",
				 Cmp					when "0111",
				 (('0' & D) + Veum) 		when "1000",
				(others => '0')				when others;
-- Saída de Vai um
Vaum <=	S_NB(NB) after Tsom;
-- Resultado da Operação
C <= 		S_NB(NB - 1 downto 0) after Ttrans  when cUla = "0000" else
			S_NB(NB - 1 downto 0) after Tsom  	when cUla = "0001" else
			S_NB(NB - 1 downto 0) after Ttrans  when cUla = "0010" else
			S_NB(NB - 1 downto 0) after Tsub  	when cUla = "0011" else
			S_NB(NB - 1 downto 0) after Tgate 	when cUla = "0100" else
			S_NB(NB - 1 downto 0) after Tgate 	when cUla = "0101" else
			S_NB(NB - 1 downto 0) after Tsom    when cUla = "0110" else
			S_NB(NB - 1 downto 0) after Tsom 	when cUla = "0111" else
			S_NB(NB - 1 downto 0)			 	when cUla = "1000";
-- Atualização do sinal
Sinal <= S_NB(NB - 1) after Tsom;
-- Atualização de Zero
Zero <= '1'  after Tsom when S_NB(NB - 1 downto 0) = Zer else
					'0' after Tsom ;

 

deslocador: deslocador_combinatorio generic map (NB, n, 1 ns) port map ('1', A, D);
---------------------------------------------------

end ULAmodified;
