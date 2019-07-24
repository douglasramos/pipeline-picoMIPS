library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUControl is
  port(																				
  		ALUOp      : in std_logic_vector(2 downto 0);
  		FunctField : in std_logic_vector(5 downto 0);
		ULASet     : out std_logic_vector(3 downto 0);
		CoproBit   : out std_logic
  );
end ALUControl;

architecture ALUControl of ALUControl is

begin			   
	
---- Processes ----
process (ALUOp,functField)

begin
	if ALUOp = "010" then	
		case functField is
			when "100000" => ULASet   <= "0001";
							 CoproBit <= '0';
			when "101010" => ULASet   <= "0111";
							 CoproBit <= '0';
			when "001000" => ULASet   <= "0000";
							 CoproBit <= '0';
			when "100001" => ULASet   <= "1001";
							 CoproBit <= '0';
			when "000000" => ULASet   <= "1000";
							 CoproBit <= '0';
			when "110001" => ULASet   <= "0000";
							 CoproBit <= '1';
			when "110011" => ULASet   <= "0000";
							 CoproBit <= '1';
			when others   => ULASet   <= "0000";
							 CoproBit <= '0';
		end case;
	else
		case ALUOp is
			when "000" => ULASet      <= "0000";
						  CoproBit    <= '0';
			when "001" => ULASet      <= "0110";
						  CoproBit    <= '0';
			when "011" => ULASet      <= "0111";
						  CoproBit    <= '0';
			when "100" => ULASet 	  <= "0001";
						  CoproBit    <= '0';
			when others   => ULASet   <= "0000";
							 CoproBit <= '0';
			
		end case;
	end if;
	 
end process;

---- User Signal Assignments ----


end ALUControl;
