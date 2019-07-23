-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Douglas Ramos
-- Co-Authors: Pedro Brito, Rafael Higa
--
-- Description:
--     Cache de dados

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

-- importa os types do projeto
library pipeline;
use pipeline.types.all;


entity CacheD is
    generic (
        access_time: in time := 5 ns
    );
    port (
		
		-- I/O relacionados ao controle
		write_options:   in  std_logic_vector(1 downto 0);
		mem_write:       in  std_logic;
		update_info:     in  std_logic;
		hit:             out std_logic := '0';
		dirty_bit:       out std_logic := '0';
		
		-- I/O relacionados ao MEM stage
        cpu_adrr:        in  std_logic_vector(15 downto 0);
		data_in :        in  word_type;	
		data_out:        out word_type;
        
		-- I/O relacionados a Memoria princial
        mem_block_in:    in  word_vector_type(15 downto 0);
		mem_addr:        out std_logic_vector(15 downto 0) := (others => '0');
		mem_block_out:   out word_vector_type(15 downto 0) := (others => word_vector_init)
        
    );
end entity CacheD;

architecture CacheD_arch of CacheD is	 	  
							  
	constant cache_size: positive := 2**14; -- 16KBytes = 4096 * 4 bytes (4096 words de 32bits)
	constant words_per_block: positive := 16;
	constant bloco_size: positive := words_per_block * 4; --- 16 * 4 = 64Bytes
    constant number_of_blocks: positive := cache_size / bloco_size; -- 256 blocos
	constant blocks_per_set: positive := 2; -- Associativo por conjunto de 2 blocos
	constant number_of_sets: positive := number_of_blocks / blocks_per_set; --  128 conjuntos
		
	
	--- Cada "linha" em um conjunto possui valid + dirty + tag + data
	type set_row_type is record
         valid: std_logic;
		 dirty: std_logic;
         tag:   std_logic_vector(2 downto 0);
         data:  word_vector_type(words_per_block - 1 downto 0);
    end record set_row_type;
	
	type set_type is array (blocks_per_set - 1 downto 0) of set_row_type;
	
	constant set_row_init : set_row_type := (valid => '0',
										     dirty => '0',
										     tag =>   (others => '0'),   
											 data =>  (others => word_vector_init));	
											 
	constant set_with_instruction_1 : set_row_type := (valid => '1',
										               dirty =>  '0',
										               tag =>    "011",   
											           data =>  (2 => word_vector_instruction1 , 
													            others => word_vector_init));										
	
    --- Cache é formado por um array de conjuntos
	type set_vector_type is record
		 set: set_type;
    end record set_vector_type;
		
	type cache_type is array (number_of_sets - 1 downto 0) of set_vector_type;
	
	constant cache_set_init : set_vector_type := (set => (others => set_row_init));
	
	constant cache_set_instruction1 : set_vector_type := (set => (0 => set_with_instruction_1, 1 => set_row_init));  
	
	--- definicao do cache
    signal cache: cache_type := (1 => cache_set_instruction1, others => cache_set_init); 
	
	signal mem_block_addr: natural;
	signal index: natural;
	signal word_offset: natural;
	signal tag: std_logic_vector(2 downto 0);
	signal set_index: natural;
	signal hit_signal: std_logic; --- sinal interno utilizado para poder usar o hit na logica do set_index
	
	
begin 
	-- obtem campos do cache a partir do endereço de entrada
	mem_block_addr <= to_integer(unsigned(cpu_adrr(15 downto 6)));
	index <= mem_block_addr mod number_of_sets;
	tag <= cpu_adrr(15 downto 13);
	word_offset <= to_integer(unsigned(cpu_adrr(5 downto 2)));
		
	-- Logica que define o index dentro do conjunto em caso de hit ou nao.
	-- Note que caso o conjunto esteja cheio, troca-se sempre o primeiro bloco
	set_index <= 0 when (cache(index).set(0).valid = '1' and cache(index).set(0).tag = tag) or
	                    (hit_signal = '0' and cache(index).set(0).valid = '0') else
    			 1 when (cache(index).set(1).valid = '1' and cache(index).set(1).tag = tag) or
			            (hit_signal = '0' and cache(index).set(1).valid = '0') else 0;
	
	-- dois (2 blocos por conjunto) comparadores em paralelo para definir o hit
	hit_signal <= '1' when (cache(index).set(0).valid = '1' and cache(index).set(0).tag = tag) or
	                 (cache(index).set(1).valid = '1' and cache(index).set(1).tag = tag) else '0';
	
	--  saidas
	
	hit <= hit_signal;
	
	data_out <=	cache(index).set(set_index).data(word_offset) after access_time;
	
	mem_addr <= cpu_adrr;
	
	dirty_bit <= cache(index).set(set_index).dirty;
	
	mem_block_out <= cache(index).set(set_index).data;
	
	-- atualizacao do cache de acordo com os sinais de controle
	process(update_info, write_options, mem_write)
	begin
		if (update_info'event or write_options'event) then
			
			-- atualiza info (tag e valid bit)
			if (update_info'event and update_info = '1') then
				cache(index).set(set_index).tag <= tag;
				cache(index).set(set_index).valid <= '1';
			end if;
						
			-- write_options 00 -> mantem valor do cache inalterado
			-- write_options 01 -> usa o valor do mem (ocorreu miss)
			-- write_options 10 -> usa o valor do data_in (cpu write)
			if (write_options = "01") then
				cache(index).set(set_index).data <= mem_block_in;	
				
			elsif (write_options = "10") then
				cache(index).set(set_index).data(word_offset) <= data_in after access_time;
				cache(index).set(set_index).dirty <= '1'; 
			end if;
			
			-- Escreve na memoria
			--if (buffer_write'event and buffer_write = '1') then
				--mem_block_out <= cache(index).set(set_index).data after access_time;
			--end if;
			
		end if;
	end process;

end architecture CacheD_arch;