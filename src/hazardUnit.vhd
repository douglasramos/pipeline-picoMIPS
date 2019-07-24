library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity hazardUnit is
generic(
  	   TpropLogtime : time := 0.25 ns;  						
  	   Tprop    	: time := 1 ns;							  
	   Tsetup       : time := 0.25 ns;						  
	   Thold        : time := 0.25 ns						  
);
port(
	clk            : in  std_logic;						  -- o mesmo clock do pipeline
	opcode         : in  std_logic_vector(5 downto 0);	  -- opcode lido no estágio ID
	equality       : in  std_logic;                       -- resultado da comparação de igualdade na ULA. Vem do estágio EX
	IDEXMemRead    : in  std_logic;
	IDEXRt	       : in  std_logic_vector(4 downto 0);
	IFIDRs	       : in  std_logic_vector(4 downto 0);
	IFIDRt	       : in  std_logic_vector(4 downto 0);
	isStallForward : out std_logic;
  	IFFlush        : out std_logic;
  	IDFlush        : out std_logic
   );																									
end hazardUnit;

architecture hazardUnit of hazardUnit is

component comparador5Bits port
	(X    : in std_logic_vector(4 downto 0);
  	 Y    : in std_logic_vector(4 downto 0);
	 comp : out std_logic
	);
end component;
	
type state_type is (s0, s1, s2, s3);
signal PS, NS : state_type;
signal state  : std_logic_vector(1 downto 0);   


signal A              : std_logic;
signal B              : std_logic;
signal D1, D0         : std_logic;
signal Q1, Q0         : std_logic;
signal isBranch       : std_logic_vector(1 downto 0);	 
signal opCodeShiftOne : std_logic_vector(4 downto 0);	
signal branchDetector : std_logic;


begin		   

sync_proc: process (clk,NS)
	begin	
	
		if (state = "00" and rising_edge(clk)) then 
			PS <= s0;
			Q1 <= '0' after Tprop + Thold;
			Q0 <= '0' after Tprop + Thold;
		elsif (rising_edge(clk)) then
			PS <= NS;
			Q1 <= D1 after Tprop + Thold;
			Q0 <= D0 after Tprop + Thold;
		end if;	 
	
end process sync_proc;


comb_proc: process (PS, isBranch,equality)
	begin
	
	case PS is
		when s0=>
			if (isBranch = "01") then
				NS <= s1;
				state <= "01";
			elsif (isbranch = "10") then
				NS <= s2;	  
				state <= "10";
			else
				NS <= s0;
				state <= "00";
			end if;
		
		when s1=> 		
			if (equality = '1') then										
				NS <= s3;
			else
				NS <= s0;
			end if;	
	
			state <= "01";				     														
						
		when s2=>		 						
			if (equality = '0') then										
				NS <= s3;
			else
				NS <= s0;
			end if;	
		
			state <= "10";

		when s3=>
			state <= "11";
			NS <= s0;
		
		end case;	
				
end process comb_proc;

--------------------------------------------------------------------------------------------------------------
--Forwarding
--------------------------------------------------------------------------------------------------------------
															   --caso em que é necessário ler registrador após o estágio MEM, que ocorre qdo usa instrução "load"
	comparador1 : comparador5Bits port map(IDEXRt, IFIDRs,A);
	comparador2 : comparador5Bits port map(IDEXRt, IFIDRt,B);
	
	isStallForward <= IDEXMemRead and (A or B);                --Zerar sinais de controle nos buffers IF/ID
												               --importante: com esse sinal, implementar lógica para o PC no estágio IF re-executar uma instrução (fazer sistema de desincrementar 4, ou de guardar o ´último valor de PC que passou pelo estágio IF)

	
--------------------------------------------------------------------------------------------------------------
--Control Hazards
--------------------------------------------------------------------------------------------------------------
	opCodeShiftOne(4) <= opcode(5);
	opCodeShiftOne(3) <= opcode(4);
	opCodeShiftOne(2) <= opcode(3);
	opCodeShiftOne(1) <= opcode(2);
	opCodeShiftOne(0) <= opcode(1);
	
	comparador3 : comparador5Bits port map(opCodeShiftOne, "00010", branchDetector);
	
	isBranch(1) <= branchDetector and opcode(0);
	isBranch(0) <= branchDetector and (not opcode(0));
	
	IFFlush <= Q1 and Q0 after TpropLogtime;
	IDFlush <= Q1 and Q0 after TpropLogtime;
	
	D1 <= ((not Q1) and (not Q0) and isBranch(1) and (not isBranch(0))) or ((not Q1) and Q0 and equality) or (Q1 and (not Q0) and (not equality)) after 2 * TpropLogtime;
	D0 <= ((not Q1) and (not Q0) and (not isBranch(1)) and isBranch(0)) or ((not Q1) and Q0 and equality) or (Q1 and (not Q0) and (not equality)) after 2 * TpropLogtime;
	
	
end hazardUnit;