-- PCS3412 - Organizacao e Arquitetura de Computadores I
-- PicoMIPS
-- Author: Pedro Brito
-- Co-Authors: Douglas Ramos, Rafael Higa
--
-- Description:
--     Estagio Instruction Fetch do Pipeline 

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

library pipeline;
use pipeline.types.all;

entity Estagio_IF is
  port(
       clk, clk_cache, reset : in std_logic;
       PCatualizado, PCdesvio : in std_logic_vector(31 downto 0);
	   muxc : in std_logic;
       instruct, PC4 : out std_logic_vector(31 downto 0);
	   
	   write_options, update_info: in std_logic;
	   stall: out std_logic;
	   mem_bloco_data: in  word_vector_type(15 downto 0);
	   mem_addr: out std_logic_vector(15 downto 0) := (others => '0')
	   
  );
end Estagio_IF;

architecture Estagio_IF of Estagio_IF is 

--------------------- MUX ----------------------------------
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
------------------------------------------------------------ 
-------------------- Somador -------------------------------
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
------------------------------------------------------------
------------------ Registrador -----------------------------
component registrador is
  generic(
       NumeroBits : INTEGER := 8;
       Tprop : time := 5 ns;
       Tsetup : time := 2 ns
  );
  port(
       C : in std_logic;
       R : in std_logic;
       S : in std_logic;
       D : in std_logic_vector(NumeroBits - 1 downto 0);
       Q : out std_logic_vector(NumeroBits - 1 downto 0)
  );
end component;
------------------------------------------------------------
------------------------ Cache I ---------------------------
component CacheI is
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
end component;

component ControlCacheI is
    generic (
        access_time: in time := 5 ns
    );
    port (
	
		clk:    in std_logic;		

		-- I/O relacionados ao stage IF
        stall:  out std_logic := '0';
		pc:     in word_type;
		
		-- I/O relacionados ao cache
		hit_signal:      in  std_logic;
		write_options:   out std_logic := '0';
		update_info:     out std_logic := '0';
		
        -- I/O relacionados a Memoria princial
		mem_ready:      in  std_logic;
		mem_rw:         out std_logic := '0';  --- '1' write e '0' read
        mem_enable:     out std_logic := '0'
        
    );
end component ControlCacheI; 

--- sinais de ligacao entre controle do cache e o fluxo de dados do mesmo
signal i_write_options: std_logic;
signal i_hit: std_logic;
signal i_update_info: std_logic; 

--- sinais de memoria (deveriam vir de fora)
signal i_mem_ready: std_logic;
signal i_mem_rw: std_logic;
signal i_mem_enable: std_logic;
------------------------------------------------------------

signal PC, address: std_logic_vector(31 downto 0);

begin			
	
mux: multiplexador generic map (32, 0 ns, 0 ns) port map (muxc, PCatualizado, PCdesvio, PC);
soma: somador generic map (32, 0 ns, 0 ns) port map ('1', '0', PC, "00000000000000000000000000000100", PC4);
reg: registrador generic map (32, 0 ns, 0 ns) port map (clk, reset, '0', PC, address);
cache: cacheI generic map (0 ns) port map (i_write_options, i_update_info, i_hit, address(15 downto 0), instruct, mem_bloco_data, mem_addr); 
cacheControl: ControlCacheI	generic map (0 ns) 
                            port map (clk_cache, stall, PC, i_hit, i_write_options, i_update_info, i_mem_ready, i_mem_rw, i_mem_enable);

	


end Estagio_IF;