-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- File: types.vhd
-- Author: Douglas Ramos
--
-- Description:
--     Define tipos comuns utilizados no proejto

library IEEE;
use IEEE.std_logic_1164.all;

package types is		 
	
    subtype word_type     is std_logic_vector(31 downto 0);
	type word_vector_type is array(natural range <>) of word_type;
	
	constant word_vector_init: word_type := (others => '0');
	constant word_vector_test: word_type := (others => '1');
	
	constant word_vector_instruction1: word_type :=(1 | 3 | 5 | 7 => '0', others => '1');
	
end package types;
