library ieee;
use ieee.std_logic_1164.all;

entity segmentos is 
port(
		segmento:    out std_logic_vector( 6 downto 0);
        interruptor: in  std_logic_vector( 3 downto 0)
);
end segmentos;

architecture bhv_in of segmentos is
begin 
		with interruptor select 
		    segmento <= "0000001" when "0000",  
                    -- 0 = enciende segmento -cuando-> num binario
                    "1001111" when "0001",   
                    "0010010" when "0010",   
                    "0000110" when "0011",   
                    "1001100" when "0100",   
                    "0100100" when "0101",   
                    "0100000" when "0110",   
                    "0001111" when "0111",   
                    "0000000" when "1000",   
                    "0000100" when "1001",   
                    "1111111" when others;
end bhv_in;