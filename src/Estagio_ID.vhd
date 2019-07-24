-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Pedro Brito
-- Co-Authors: Douglas Ramos, Rafael Higa
--
-- Description:
--     Estagio Instruction Decode do Pipeline

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity Estagio_ID is
  port(
       clk, reset : in std_logic;
       instruct : in std_logic_vector(31 downto 0);
       writeData : in std_logic_vector(31 downto 0);
	   we, ALUSrc : in std_logic;
       endWrite : in std_logic_vector(4 downto 0);
       regData1, regData2 : out std_logic_vector(31 downto 0);
       endDesvio : out std_logic_vector(31 downto 0);
	   rs, rd, rt, shamt :  out std_logic_vector(4 downto 0);
	   op, func : out  std_logic_vector(5 downto 0)
  );
end Estagio_ID;

architecture Estagio_ID of Estagio_ID is  

signal enda, endb: std_logic_vector(4 downto 0);
signal register2 : std_logic_vector(31 downto 0);

----------------- Register File -------------------------
component RegisterFile is
  generic(
       NBend : integer := 4;
       NBdado : integer := 8;
       Tread : time := 5 ns;
       Twrite : time := 5 ns
  );
  port(
       clk, reset : in std_logic;
       we : in std_logic;
       dadoina : in std_logic_vector(NBdado - 1 downto 0);
	   endwrite : in std_logic_vector(NBend - 1 downto 0);
       enda : in std_logic_vector(NBend - 1 downto 0);
       endb : in std_logic_vector(NBend - 1 downto 0);
       dadoouta : out std_logic_vector(NBdado - 1 downto 0);
       dadooutb : out std_logic_vector(NBdado - 1 downto 0)
  );
end component; 
--------------------------------------------------------

begin

banco: RegisterFile generic map (5, 32, 0 ns, 0 ns)
	   port map (clk, reset, we, writeData, endWrite, enda, endb, regData1, register2);

enda <= instruct(25 downto 21);
endb <= instruct(20 downto 16);	   
	   
rs <= enda;				 			--registrador de origem
rt <= endb;							--registrador alvo
rd <= instruct(15 downto 11);		--registrador de destino

op <= instruct(31 downto 26);		--op code
endDesvio <= "0000000000000000" & instruct(15 downto 0);	--endereço de desvio

shamt <= instruct(10 downto 6);
func <= instruct(5 downto 0); 

regData2 <= register2 when ALUSrc = '0' else "0000000000000000" & instruct(15 downto 0);


end Estagio_ID;	