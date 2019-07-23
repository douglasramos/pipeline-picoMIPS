-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Douglas Ramos 
-- Co-Authors: Pedro Brito, Rafael Higa 
--
-- Description:
--     Estagio Memory do Pipeline

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

library pipeline;
use pipeline.types.all;

entity Estagio_MEM is
  port(
  	   clk:       in std_logic; 
  	   clk_cache: in std_logic;
	   cpu_write: in std_logic;
       address:   in std_logic_vector(15 downto 0);
	   data_in :  in word_type;
	   
	   data_out:  out word_type;
	   stall:     out std_logic
	   
  );
end Estagio_MEM;

architecture Estagio_MEM of Estagio_MEM is 

------------------------------------------------------------
------------------------ Cache D ---------------------------
component CacheD is
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
        cpu_adrr: in  std_logic_vector(15 downto 0);
		data_in : in  word_type;	
		data_out: out word_type;
        
		-- I/O relacionados a Memoria princial
        mem_block_in:   in  word_vector_type(15 downto 0);
		mem_addr:       out std_logic_vector(15 downto 0) := (others => '0');
		mem_block_out:  out word_vector_type(15 downto 0) := (others => word_vector_init)
        
    );
end component CacheD;

component ControlCacheD is
    generic (
        access_time: in time := 5 ns
    );
    port (			  
	
		clk:          in std_logic;		

		-- I/O relacionados ao stage MREADY
		clk_pipeline:  in std_logic;
        cpu_write:     in std_logic;
		cpu_addr:      in std_logic_vector(15 downto 0);
		stall:         out std_logic := '0';
		
		-- I/O relacionados ao cache
		dirty_bit:     in  std_logic;
		hit_signal:    in  std_logic;
		write_options: out std_logic_vector(1 downto 0) := "00";
		update_info:   out std_logic := '0';
		
        -- I/O relacionados a Memoria princial
		mem_ready:     in  std_logic;
		mem_rw:        out std_logic := '0';  --- '1' write e '0' read
        mem_enable:    out std_logic := '0'
        
    );
end component ControlCacheD;

--- sinais de ligacao entre controle do cache e o fluxo de dados do mesmo
signal i_write_options: std_logic_vector(1 downto 0);
signal i_mem_write: std_logic;
signal i_hit: std_logic;
signal i_update_info: std_logic;
signal i_dirty_bit: std_logic;

--- sinais de memoria (deveriam vir de fora)
signal i_mem_ready: std_logic;
signal i_mem_rw: std_logic;
signal i_mem_enable: std_logic;

signal i_mem_block_in: word_vector_type(15 downto 0);
signal i_mem_addr: std_logic_vector(15 downto 0);
signal i_mem_block_out: word_vector_type(15 downto 0);
------------------------------------------------------------

begin			
	
cache: cacheD generic map (0 ns) 
			  port map (i_write_options, i_mem_write, i_update_info, i_hit, i_dirty_bit, address, 
			            data_in, data_out, i_mem_block_in, i_mem_addr, i_mem_block_out );
			  
cacheControl: ControlCacheD	generic map (0 ns) 
                            port map (clk_cache, clk, cpu_write, address, stall, i_dirty_bit, i_hit, 
                                      i_write_options, i_update_info, i_mem_ready, i_mem_rw, i_mem_enable);
end Estagio_MEM;