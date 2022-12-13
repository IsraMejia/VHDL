library ieee;
use ieee.std_logic_1164.all;

entity DIVI1SEG is
port (CLK50MHZ: in std_logic;
		CLK: out std_logic);
end DIVI1SEG;

architecture DIV of DIVI1SEG is
	constant MAX: integer := 50000000;
	constant HALF: integer:= MAX/2;
	signal COUNT: integer range 0 to MAX;
begin 
	process
		begin
			wait until CLK50MHZ'event AND CLK50MHZ = '1';
				if COUNT < MAX then
					COUNT <= COUNT + 1;
				else
					COUNT <= 0;
				end if;
				if COUNT < HALF then
					CLK <= '0';
				else
					CLK <= '1';
				end if;
	end process;
end DIV;