library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library biblioteca_de_componentes;

entity controlUnit is
  port(																				
  	   clk               : in std_logic;
  	   instructionOpCode : in std_logic_vector(5 downto 0);   -- Entrada da UC. Analisa qual instrução executada e como proceder com os sinais de controle
       RegDst            : out std_logic;					  -- Decide campo do operando destino: Rd ou Rt?
	   Regwrite          : out std_logic;				      -- O enable de escrita no banco de registradores
	   ALUSrc            : out std_logic;                     -- Escolhe o segundo operando da ULA
	   PCSrc             : out std_logic;                     -- Escolhe o valor do Program Counter: PC+4 ou outra coisa?
	   MemRead           : out std_logic;				      -- Define leitura no cache de dados
	   MemWrite		     : out std_logic;                     -- Define escrita no cache de dados
	   MemtoReg          : out std_logic;				   	  -- Sinal para multiplexação no estágio write-back
	   ALUOp             : out std_logic_vector(2 downto 0);  -- Define qual operação será realizada na ULA. São sinais de controle do módulo de controle da ULA
	   EXExcInterrupt    : in std_logic_vector(1 downto 0);	  -- Entrada que define o comportamento do mecanismo de interrupções e exceções
	   IFFlush			 : out std_logic;					  -- Sinal IF.Flush
	   IDFlush			 : out std_logic;					  -- Sinal ID.Flush
	   EXFlush           : out std_logic;				      -- Sinal EX.Flush
	   BufferOff		 : out std_logic;					  -- Desativa enable dos buffers de todos os registradores entre os estágios do pipeline
	   causeValue        : out std_logic_vector(4 downto 0);  -- Write-enable para gravar causa da exceção/interrupção no vetor de causa
	   EPCWriteEnable    : out std_logic					  -- Write-enable para gravar endereço da instrução que deu problema no EPC
  );
end controlUnit;

architecture controlUnit of controlUnit is

--Multiplexador 8x1
component Mux8x1 is
	generic(
       NB : integer := 5;
       Tsel : time := 3 ns;
       Tdata : time := 2 ns
  	);
  	port(
       I0 : in std_logic_vector(NB - 1 downto 0);
       I1 : in std_logic_vector(NB - 1 downto 0);
       I2 : in std_logic_vector(NB - 1 downto 0);
       I3 : in std_logic_vector(NB - 1 downto 0);
       I4 : in std_logic_vector(NB - 1 downto 0);
       I5 : in std_logic_vector(NB - 1 downto 0);
       I6 : in std_logic_vector(NB - 1 downto 0);
       I7 : in std_logic_vector(NB - 1 downto 0);
       Sel : in std_logic_vector(2 downto 0);
       O : out std_logic_vector(NB - 1 downto 0)
  	);
end component;
	
type state_type is (s0, s1, s2);
signal PS, NS : state_type;

signal D1 : std_logic;
signal D0 : std_logic;
signal X1 : std_logic;
signal X0 : std_logic;
signal Q1 : std_logic;
signal Q0 : std_logic;	   
signal isCause : std_logic;
signal muxSel : std_logic_vector(2 downto 0); 
signal state : std_logic_vector(1 downto 0);

begin

---- Processes ----				
-------------------------------------------------------------------------------------------------
--Sinais de controle do pipeline
process (instructionOpCode)

begin
	case instructionOpCode is
		when "000000" => RegDst   <= '1';     --formato R
						 Regwrite <= '1';
						 ALUSrc   <= '0';
						 PCSrc    <= '1';
						 MemRead  <= '0';
						 MemWrite <= '0';
						 MemtoReg <= '0';
						 ALUOp    <= "010";
						 
		when "000010" => RegDst   <= '0';     --j
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '1';
						 MemRead  <= '0';
						 MemWrite <= '0';
						 MemtoReg <= '0';
						 ALUOp    <= "001";
						 
		when "000011" => RegDst   <= '0';     --jal
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '1';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "000";
		
		when "000100" => RegDst   <= '0';     --beq
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '1';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "001";
		
		when "000101" => RegDst   <= '0';     --bne
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '1';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "001";
		
		when "001000" => RegDst   <= '0';     --addi
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '0';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "100";
		
		when "001010" => RegDst   <= '0';     --slti
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '0';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "011";
		
		when "100011" => RegDst   <= '0';     --lw
						 Regwrite <= '1';
						 ALUSrc   <= '1';
						 PCSrc    <= '0';
						 MemRead  <= '1';
						 MemWrite <= '0'; 
						 MemtoReg <= '1';
						 ALUOp    <= "000";
		
		when "101011" => RegDst   <= '0';     --sw
						 Regwrite <= '0';
						 ALUSrc   <= '1';
						 PCSrc    <= '0';
						 MemRead  <= '0';
						 MemWrite <= '1'; 
						 MemtoReg <= '0';
						 ALUOp    <= "000";
						 
		when others   => RegDst   <= '0';
						 Regwrite <= '0';
						 ALUSrc   <= '0';
						 PCSrc    <= '0';
						 MemRead  <= '0';
						 MemWrite <= '0'; 
						 MemtoReg <= '0';
						 ALUOp    <= "000";
		
		end case;
	 
end process;

-------------------------------------------------------------------------------------------------
--Process para tratamento de interrupções e exceções	

sync_proc: process (clk, NS)
begin	
	
	if (state = "00" and rising_edge(clk)) then 
		PS <= s0;
	elsif (rising_edge(clk)) then
		PS <= NS;
	end if;	 
	
end process sync_proc;


comb_proc: process (PS,EXExcInterrupt)
begin
	
case PS is
	when s0=>
		Q0 <= '0';
		Q1 <= '0';
		if (EXExcInterrupt = "01") then
			NS <= s1;
			state <= "01";
		elsif (EXExcInterrupt = "10") then
			NS <= s2;	  
			state <= "10";
		else
			NS <= s0;
			state <= "00";
		end if;
				
	when s1=> 		
		state <= "01";				
		NS <= s1;      														  --necessidade de implementar dps algo com reset aqui???
		Q0 <= D0;
		Q1 <= D1;
						
	when s2=>		 
						
		if (EXExcInterrupt = "00") then										  --necessidade de implementar dps algo com reset aqui???
			NS <= s0;
		else
			NS <= s2;
		end if;	
		
		state <= "10";
		Q0 <= D0;
		Q1 <= D1;
	end case;	
				
end process comb_proc;



D1 <= ((not Q1) and (not Q0) and X1 and (not X0)) or (Q1 and (not Q0));
D0 <= ((not Q1) and (not Q0) and (not X1) and X0) or ((not Q1) and Q0);

IFFlush <= (not Q1) and Q0;
IDFlush <= (not Q1) and Q0;
EXFlush <= (not Q1) and Q0;

BufferOff <= Q1 and (not Q0);
isCause <= ((not Q1) and Q0) or (Q1 and (not Q0));
EPCWriteEnable <= isCause;

X1 <= EXExcInterrupt(1);
X0 <= EXExcInterrupt(0);

muxSel(2) <= X1;
muxSel(1) <= X0;
muxSel(0) <= isCause; 

Mux : Mux8x1 port map ("00000", "00000", "00000", "01100", "00000", "01010", "00000", "00000", muxSel, causeValue);


end controlUnit;
