--This code convert inputs from FPGA"s Switches in binary (5 bit's),
--to outputs in decimal to show them in two seven segments displays

library ieee;
use ieee.std_logic_1164.all;

entity dosdisplays is 
port(
        segmento:    out std_logic_vector( 13 downto 0);
        interruptor: in  std_logic_vector( 4 downto 0)
);
end dosdisplays;

architecture bhv_in of dosdisplays is
begin 
	with interruptor select 
             segmento <= "00000010000001" when "00000",   -- switchs 0000 = 0 --Display--> 0000001 
                         "00000011001111" when "00001",   -- switchs 0001 = 1 --Display--> 1001111 
                         "00000010010010" when "00010",   -- switchs 0010 = 2 --Display--> 0010010 
                         "00000010000110" when "00011",   -- switchs 0011 = 3 --Display--> 0000110 
                         "00000011001100" when "00100",   -- switchs 0100 = 4 --Display--> 1001100 
                         "00000010100100" when "00101",   -- switchs 0101 = 5 --Display--> 0100100 
                         "00000010100000" when "00110",   -- switchs 0110 = 6 --Display--> 0100000 
                         "00000010001111" when "00111",   -- switchs 0000 = 7 --Display--> 0001111 
                         "00000010000000" when "01000",   -- switchs 1000 = 8 --Display--> 0000000 
                         "00000010000100" when "01001",   -- switchs 1001 = 9 --Display--> 0000100 
                        --1001111=1,
                         "10011110000001" when "01010",   -- switchs 1010 = 10 = A --Display--> 0000100
                         "10011111001111" when "01011",   -- switchs 1011 = 11 = B --Display--> 0000100
                         "10011110010010" when "01100",   -- switchs 1100 = 12 = C --Display--> 0000100
                         "10011110000110" when "01101",   -- switchs 1101 = 13 = D --Display--> 0000100
                         "10011111001100" when "01110",   -- switchs 1110 = 14 = E --Display--> 0000100
                         "10011110100100" when "01111",   -- switchs 1111 = 15 = F --Display--> 0000100
                         "10011110100000" when "10000",   -- switchs 1111 = 16 = F --Display--> 0000100
                         "10011110001111" when "10001",   -- switchs 1111 = 17 = F --Display--> 0000100
                         "11111111111111" when others;
end bhv_in;

