library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplicator is
  port(
  	A  		 : in std_logic_vector(15 downto 0);
  	B  		 : in std_logic_vector(15 downto 0);
	C  	     : out std_logic_vector(31 downto 0);
	enable   : in std_logic;
	overflow : out std_logic
  );
end Multiplicator;

architecture Multiplicator of Multiplicator is
----------------------------------------------------------------------------------------------
--Somador
----------------------------------------------------------------------------------------------
component ULAmodified is
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
end component; 

----------------------------------------------------------------------------------------------
--Deslocador
----------------------------------------------------------------------------------------------
component deslocador_combinatorio is
  generic(
       NB : integer := 32;
       NBD : integer := 1;
       Tprop : time := 1 ns
  );
  port(
       DE : in std_logic;
       I : in std_logic_vector(NB - 1 downto 0);
       O : out std_logic_vector(NB - 1 downto 0)
  );
end component;
----------------------------------------------------------------------------------------------
--Sinal dos operandos
----------------------------------------------------------------------------------------------
component Sinal is
 generic(
	   Tprop : time := 0.25 ns
  );
  port(
  	operando           : in  std_logic_vector(15 downto 0);
  	operando_extendido : out std_logic_vector(31 downto 0)
  );
end component;


----------------------------------------------------------------------------------------------
--Multiplicação do primeiro operando por '1' ou '0'
----------------------------------------------------------------------------------------------
component Bitwise is
  generic(
	   Tprop : time := 0.25 ns
  );
  port(
  	operand : in std_logic_vector(31 downto 0);
  	bitMult : in std_logic;
  	multi   : out std_logic_vector(31 downto 0)
  );
end component;

----------------------------------------------------------------------------------------------
--Achar o complemento de 2
----------------------------------------------------------------------------------------------
component Inverter is
  generic(
	   Tprop : time := 0.25 ns
  );
  port(
    operando_in           : in  std_logic_vector(31 downto 0);
  	isComplement          : in  std_logic;
 	operando_out          : out std_logic_vector(31 downto 0);
	en                    : in  std_logic
  );
end component;

----------------------------------------------------------------------------------------------
--declaração de sinais
----------------------------------------------------------------------------------------------
signal A_mod                                                                           : std_logic_vector(31 downto 0);
signal A_bit_0, A_bit_1, A_bit_2, A_bit_3, A_bit_4, A_bit_5, A_bit_6, A_bit_7          : std_logic_vector(31 downto 0); 
signal A_bit_8, A_bit_9, A_bit_10, A_bit_11, A_bit_12, A_bit_13, A_bit_14, A_bit_15    : std_logic_vector(31 downto 0);
signal A_shift_0, A_shift_1, A_shift_2, A_shift_3, A_shift_4, A_shift_5, A_shift_6     : std_logic_vector(31 downto 0); 
signal A_shift_7, A_shift_8, A_shift_9, A_shift_10, A_shift_11, A_shift_12, A_shift_13 : std_logic_vector(31 downto 0); 
signal A_shift_14, A_shift_15, A_shift_15_isInverted					     		   : std_logic_vector(31 downto 0); 
signal over_1, over_2, over_3, over_4, over_5, over_6, over_7, over_8, over_9, over_10 : std_logic;
signal over_11, over_12, over_13, over_14, over_15                                     : std_logic;
signal soma_1, soma_2, soma_3, soma_4, soma_5, soma_6, soma_7, soma_8, soma_9, soma_10 : std_logic_vector(31 downto 0);
signal soma_11, soma_12, soma_13, soma_14                                              : std_logic_vector(31 downto 0); 
signal C_out 																		   : std_logic_vector(31 downto 0);

begin

----------------------------------------------------------------------------------------------
--Sinal do operando 1 (A)
----------------------------------------------------------------------------------------------
	Sinal_A : Sinal port map(A, A_mod);

----------------------------------------------------------------------------------------------
--Operações bitwise
----------------------------------------------------------------------------------------------
	Bitwise_0 : Bitwise port map(A_mod, B(0), A_bit_0);
	Bitwise_1 : Bitwise port map(A_mod, B(1), A_bit_1);
	Bitwise_2 : Bitwise port map(A_mod, B(2), A_bit_2);
	Bitwise_3 : Bitwise port map(A_mod, B(3), A_bit_3);
	Bitwise_4 : Bitwise port map(A_mod, B(4), A_bit_4);
	Bitwise_5 : Bitwise port map(A_mod, B(5), A_bit_5);
	Bitwise_6 : Bitwise port map(A_mod, B(6), A_bit_6);
	Bitwise_7 : Bitwise port map(A_mod, B(7), A_bit_7);
	Bitwise_8 : Bitwise port map(A_mod, B(8), A_bit_8);
	Bitwise_9 : Bitwise port map(A_mod, B(9), A_bit_9);
	Bitwise_10 : Bitwise port map(A_mod, B(10), A_bit_10);
	Bitwise_11 : Bitwise port map(A_mod, B(11), A_bit_11);
	Bitwise_12 : Bitwise port map(A_mod, B(12), A_bit_12);
	Bitwise_13 : Bitwise port map(A_mod, B(13), A_bit_13);
	Bitwise_14 : Bitwise port map(A_mod, B(14), A_bit_14);
	Bitwise_15 : Bitwise port map(A_mod, B(15), A_bit_15);

----------------------------------------------------------------------------------------------
--Operações de Shift
----------------------------------------------------------------------------------------------
	shift_0  : deslocador_combinatorio generic map(32,0,0 ns) port map('1', A_bit_0, A_shift_0); 
	shift_1  : deslocador_combinatorio generic map(32,1,0 ns) port map('1', A_bit_1, A_shift_1); 
	shift_2  : deslocador_combinatorio generic map(32,2,0 ns) port map('1', A_bit_2, A_shift_2); 
	shift_3  : deslocador_combinatorio generic map(32,3,0 ns) port map('1', A_bit_3, A_shift_3); 
	shift_4  : deslocador_combinatorio generic map(32,4,0 ns) port map('1', A_bit_4, A_shift_4); 
	shift_5  : deslocador_combinatorio generic map(32,5,0 ns) port map('1', A_bit_5, A_shift_5); 
	shift_6  : deslocador_combinatorio generic map(32,6,0 ns) port map('1', A_bit_6, A_shift_6); 
	shift_7  : deslocador_combinatorio generic map(32,7,0 ns) port map('1', A_bit_7, A_shift_7); 
	shift_8  : deslocador_combinatorio generic map(32,8,0 ns) port map('1', A_bit_8, A_shift_8); 
	shift_9  : deslocador_combinatorio generic map(32,9,0 ns) port map('1', A_bit_9, A_shift_9); 
	shift_10 : deslocador_combinatorio generic map(32,10,0 ns) port map('1', A_bit_10, A_shift_10); 
	shift_11 : deslocador_combinatorio generic map(32,11,0 ns) port map('1', A_bit_11, A_shift_11); 
	shift_12 : deslocador_combinatorio generic map(32,12,0 ns) port map('1', A_bit_12, A_shift_12); 
	shift_13 : deslocador_combinatorio generic map(32,13,0 ns) port map('1', A_bit_13, A_shift_13); 
	shift_14 : deslocador_combinatorio generic map(32,14,0 ns) port map('1', A_bit_14, A_shift_14); 
	shift_15 : deslocador_combinatorio generic map(32,15,0 ns) port map('1', A_bit_15, A_shift_15); 

----------------------------------------------------------------------------------------------
--Bit 15: última parcela inverte ou não?
----------------------------------------------------------------------------------------------

	lastBit : Inverter port map(A_shift_15, B(15), A_shift_15_isInverted,'1');

----------------------------------------------------------------------------------------------
--Operações de Soma
----------------------------------------------------------------------------------------------
	--Primeira camada de somas
	somador_1 : ULAmodified port map('0', A_shift_0, A_shift_1,   "0001", open, open, over_1, soma_1,'1');		
	somador_2 : ULAmodified port map('0', A_shift_2, A_shift_3,   "0001", open, open, over_2, soma_2,'1');		
	somador_3 : ULAmodified port map('0', A_shift_4, A_shift_5,   "0001", open, open, over_3, soma_3,'1');		
  	somador_4 : ULAmodified port map('0', A_shift_6, A_shift_7,   "0001", open, open, over_4, soma_4,'1');		
	somador_5 : ULAmodified port map('0', A_shift_8, A_shift_9,   "0001", open, open, over_5, soma_5,'1');		
	somador_6 : ULAmodified port map('0', A_shift_10, A_shift_11, "0001", open, open, over_6, soma_6,'1');		
	somador_7 : ULAmodified port map('0', A_shift_12, A_shift_13, "0001", open, open, over_7, soma_7,'1');		
	somador_8 : ULAmodified port map('0', A_shift_14, A_shift_15_isInverted, "0001", open, open, over_8, soma_8,'1');
	
	--Segunda camada de somas
	somador_9  : ULAmodified port map('0', soma_1, soma_2, "0001", open, open, over_9, soma_9,'1');
	somador_10 : ULAmodified port map('0', soma_3, soma_4, "0001", open, open, over_10, soma_10,'1');
	somador_11 : ULAmodified port map('0', soma_5, soma_6, "0001", open, open, over_11, soma_11,'1');
	somador_12 : ULAmodified port map('0', soma_7, soma_8, "0001", open, open, over_12, soma_12,'1');
	
	
	--Terceira camada de somas
	somador_13  : ULAmodified port map('0', soma_9, soma_10, "0001", open, open, over_13, soma_13,'1');
	somador_14  : ULAmodified port map('0', soma_11, soma_12, "0001", open, open, over_14, soma_14,'1');
	
	--Resultado final
	somador_15  : ULAmodified port map('0', soma_13, soma_14, "0001", open, open, over_15, C_out,'1');
	
	C <= C_out when enable = '1' else "00000000000000000000000000000000";
	
	overflow <= over_1 or over_2 or over_3 or over_4 or over_5 or over_6 or over_7 or over_8 or over_9 or over_10 or over_11 or over_12 or over_13 or over_14 or over_15;
	
	
	
																			
end Multiplicator;