--This code convert inputs from FPGA"s Switches in binary (5 bit's),
--to outputs in decimal to show them in two seven segments displays

library ieee;
use ieee.std_logic_1164.all;

entity display is 
port(    
    interruptor: in  std_logic_vector( 4 downto 0);
    segmento:    out std_logic_vector( 6 downto 0)
);
end display;

architecture bhv_display of display is
begin 
	with interruptor select 
             segmento <= --0000001" when "00000",   -- switchs 0000 = S --Display--> 0000001 
                         "0100100" when "00000",   -- switchs 0000 = S --Display--> 0000001 
                         "0011000" when "00001",   -- switchs 0001 = P --Display--> 1001111 
                         "0001000" when "00010",   -- switchs 0010 = A --Display--> 0010010 
                         "1111010" when "00011",   -- switchs 0011 = r --Display--> 0000110 
                         "0111001" when "00100",   -- switchs 0100 = T --Display--> 1001100 
                         "1101010" when "00101",   -- switchs 0101 = n --Display--> 0100100  
                         "1111111" when others;
end bhv_display ;
