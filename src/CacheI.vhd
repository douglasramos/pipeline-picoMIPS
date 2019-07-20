-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Douglas Ramos
-- Co-Authors: Pedro Brito, Rafael Higa
--
-- Description:
--     Cache de Instrucoes

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

-- importa os types do projeto
library pipeline;
use pipeline.types.all;


entity CacheI is
    generic (
        access_time: in time := 5 ns
    );
    port (
		
		-- I/O relacionados ao controle
		write_options:   in std_logic;
		update_info:     in std_logic; 
		hit:             out std_logic := '0';
		
		-- I/O relacionados ao IF stage
        cpu_adrr: in  std_logic_vector(15 downto 0);
        data_out: out word_type;	

        -- I/O relacionados a Memoria princial
        mem_bloco_data: in  word_vector_type(15 downto 0);
		mem_addr:       out std_logic_vector(15 downto 0) := (others => '0')
		
		   
    );
end entity CacheI;

architecture CacheI_arch of CacheI is	 	  
							  
	constant cache_size: positive := 2**14; -- 16KBytes = 4096 * 4 bytes (4096 words de 32bits)
	constant palavras_por_bloco: positive := 16;
	constant bloco_size: positive := palavras_por_bloco * 4; --- 16 * 4 = 64Bytes
    constant number_of_blocks: positive := cache_size / bloco_size; -- 256 blocos
	
	--- Cada "linha" no cache possui valid + tag + data
	    type cache_row_type is record
        valid: std_logic;
        tag:   std_logic_vector(1 downto 0);
        data:  word_vector_type(palavras_por_bloco - 1 downto 0);
    end record cache_row_type;

    type cache_type is array (number_of_blocks - 1 downto 0) of cache_row_type;
	
	constant cache_row_init : cache_row_type := (valid => '0',
												 tag => (others => '0'),   
												 data => (others => word_vector_init));
	
	--- definicao do cache												 
    signal cache: cache_type := (others => cache_row_init);	-- aqui ir� em algum index, um valor diferente para row
	
	--- Demais sinais internos
	signal mem_block_addr: natural;
	signal index: natural;
	signal word_offset: natural;
	signal tag: std_logic_vector(1 downto 0);
	
		
begin 
	-- obtem campos do cache a partir do endereco de entrada
	mem_block_addr <= to_integer(unsigned(cpu_adrr(15 downto 6)));
	index <= mem_block_addr mod number_of_blocks;
	tag <= cpu_adrr(15 downto 14);
	word_offset <= to_integer(unsigned(cpu_adrr(5 downto 2)));
		
							
    --  saidas
	hit <= '1' when cache(index).valid = '1' and cache(index).tag = tag else '0';
	data_out <=	cache(index).data(word_offset);
	mem_addr <= cpu_adrr;
	
	-- atualizacao do cache de acordo com os sinais de controle
	process(update_info, write_options)
	begin
		if (update_info'event or write_options'event) then
			
			-- atualiza informacoes do cache
			if (update_info'event and update_info = '1') then
				cache(index).tag <= tag;
				cache(index).valid <= '1';
			end if;
			
			-- write_options 0 -> mantem valor do cache inalterado
			-- write_options 1 -> usa o valor do mem (ocorreu miss)
			if (write_options'event and write_options = '1') then
				cache(index).data <= mem_bloco_data;
			end if;
			
		end if;
	end process;

end architecture CacheI_arch;