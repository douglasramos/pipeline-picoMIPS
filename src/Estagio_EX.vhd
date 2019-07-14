library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Estagio_EX is
  port(
       clk : in std_logic;
       regData1, regData2 : in std_logic_vector(31 downto 0);
       endDesvio, PCatualizado : in std_logic_vector(31 downto 0);
	   rt, rd : in std_logic_vector(4 downto 0);
       ULAc : in std_logic_vector(3 downto 0); 
	   muxc1, muxc2 : in std_logic;
       resultado : out std_logic_vector(31 downto 0);
       endWrite, PCdesvio : out std_logic_vector(31 downto 0);
	   regWrite:  out std_logic_vector(4 downto 0);
	   vaum, zero : out std_logic
  );
end Estagio_EX;

architecture Estagio_EX of Estagio_EX is 

signal sinal: std_logic;
signal endDesvioX4, outMux1: std_logic_vector(31 downto 0);
signal outMux2: std_logic_vector(4 downto 0);
-------------------- ULA -------------------------------
component ULAmodified is
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
end component;
--------------------------------------------------------
------------------ Somador -----------------------------
component Somador is
  generic(
       NumeroBits : integer := 8;
       Tsoma : time := 3 ns;
       Tinc : time := 2 ns
  );
  port(
       S : in std_logic;
       Vum : in std_logic;
       A : in std_logic_vector(NumeroBits - 1 downto 0);
       B : in std_logic_vector(NumeroBits - 1 downto 0);
       C : out std_logic_vector(NumeroBits - 1 downto 0)
  );
end component;
---------------------------------------------------------
------------------ Deslocador ---------------------------
component deslocador_combinatorio is
  generic(
       NB : integer := 8;
       NBD : integer := 1;
       Tprop : time := 1 ns
  );
  port(
       DE : in std_logic;
       I : in std_logic_vector(NB - 1 downto 0);
       O : out std_logic_vector(NB - 1 downto 0)
  );
end component;
--------------------------------------------------------
------------------ MUX ---------------------------------
component multiplexador is
  generic(
       NumeroBits : integer := 8;
       Tsel : time := 2 ns;
       Tdata : time := 1 ns
  );
  port(
       S : in std_logic;
       I0 : in std_logic_vector(NumeroBits - 1 downto 0);
       I1 : in std_logic_vector(NumeroBits - 1 downto 0);
       O : out std_logic_vector(NumeroBits - 1 downto 0)
  );
end component;
---------------------------------------------------------

begin

ula: ULAmodified generic map (32, 0 ns, 0 ns, 0 ns, 0ns) 
     port map ('0', regData1, outMux1, ULAc, sinal, vaum, zero, resultado);

mux1: multiplexador generic map (32, 0 ns, 0 ns)
      port map (muxc1, regData2, endDesvio, outMux1);

deslocador: deslocador_combinatorio generic map (32, 2, 0 ns)
	  port map ('1', endDesvio, endDesvioX4);

soma: Somador generic map (32, 0 ns, 0 ns)
		 port map ('1', '0', PCatualizado, endDesvioX4, PCdesvio);
	
mux2: multiplexador generic map (5, 0 ns, 0 ns)
	  port map (muxc2, rt, rd, outMux2);

regWrite <= outMux2;
endWrite <= regData2;
	 

end Estagio_EX;