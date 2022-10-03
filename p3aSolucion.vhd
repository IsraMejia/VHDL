--This code convert inputs from FPGA's Switches in binary,
--to outputs in hexadecimal to show them in the seven segments display

library ieee;
use ieee.std_logic_1164.all;

entity practicatres is 
port(
		segmento:    out std_logic_vector( 6 downto 0);
        interruptor: in  std_logic_vector( 3 downto 0)
);
end practicatres;

architecture bhv_in of practicatres is
begin 
		with interruptor select 
		    segmento <= "0000001" when "0000",   -- switchs 0000 = 0 --Segmentos--> 0000001 
                        "1001111" when "0001",   -- switchs 0001 = 1 --Segmentos--> 1001111 
                        "0010010" when "0010",   -- switchs 0010 = 2 --Segmentos--> 0010010 
                        "0000110" when "0011",   -- switchs 0011 = 3 --Segmentos--> 0000110 
                        "1001100" when "0100",   -- switchs 0100 = 4 --Segmentos--> 1001100 
                        "0100100" when "0101",   -- switchs 0101 = 5 --Segmentos--> 0100100 
                        "0100000" when "0110",   -- switchs 0110 = 6 --Segmentos--> 0100000 
                        "0001111" when "0111",   -- switchs 0000 = 7 --Segmentos--> 0001111 
                        "0000000" when "1000",   -- switchs 1000 = 8 --Segmentos--> 0000000 
                        "0000100" when "1001",   -- switchs 1001 = 9 --Segmentos--> 0000100 
                        "0001000" when "1010",   -- switchs 1010 = 10 = A --Segmentos--> 0000100
                        "0000000" when "1011",   -- switchs 1011 = 11 = B --Segmentos--> 0000100
                        "0110001" when "1100",   -- switchs 1100 = 12 = C --Segmentos--> 0000100
                        "0000001" when "1101",   -- switchs 1101 = 13 = D --Segmentos--> 0000100
                        "0110000" when "1110",   -- switchs 1110 = 14 = E --Segmentos--> 0000100
                        "0111000" when "1111",   -- switchs 1111 = 15 = F --Segmentos--> 0000100
                        "1111111" when others;
end bhv_in;

