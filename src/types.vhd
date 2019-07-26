-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Douglas Ramos
-- Co-Authors: Pedro Bitro, Rafael Higa
--
-- Description:
--     Define tipos comuns utilizados no proejto

library IEEE;
use IEEE.std_logic_1164.all;

package types is

    subtype word_type     is std_logic_vector(31 downto 0);
	type word_vector_type is array(natural range <>) of word_type;

	constant word_vector_init: word_type := (others => '0');

	constant word_vector_instruction1: word_type := x"8C410050";
	constant word_vector_instruction2: word_type := x"20230005";

	constant word_vector_test: word_type := (others => '1');

	constant word_vector_value: word_type := x"00000070";

end package types;
