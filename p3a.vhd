-- What this VHDL program does is, when it receives a hexadecimal value as input, 
-- it has its output equivalent in hexadecimal with respect to 
-- its related output binary for a seven-segment display.
-- In this way we show its value on a screen of our FPGA
library ieee;
use ieee.std_logic_1164.all;

entity practicatres is
    port(
        ent: in  std_logic_vector(3 downto 0);
        sal: out std_logic_vector(7 downto 0)
    );
end; 

architecture behavior of practicatres is 
begin
    with ent select
        sal <= x"03" when x"0",
            -- comando en Hexadec x"03" = 0 DecAnodo
                x"9f" when x"1",
                x"25" when x"2",
                x"0d" when x"3",
                x"99" when x"4",
                x"49" when x"5",
                x"41" when x"6",
                x"25" when x"7",
                x"01" when x"8",
                x"09" when x"9",
                x"11" when x"a",
                x"c1" when x"b",
                x"e5" when x"c",
                x"85" when x"d",
                x"21" when x"e",
                x"71" when others;
    --comando en Hexadec = output equivalent in hexadecimal with respect to 
    -- its related output binary for a seven-segment display.
end;    