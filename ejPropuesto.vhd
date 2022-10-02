-- Este ejemplo imprime un HOLA de forma secuencial con los switch's
-- switchs 1000 = H --Segmentos--> 1001001                                   
-- switchs 1100 = 0 --Segmentos--> 0000001 
-- switchs 1110 = l --Segmentos--> 1001111 
-- switchs 1111 = A --Segmentos--> 0001000

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
		    segmento <= "1001000" when "1000",  -- switchs 1000 = H --Segmentos--> 1001000  
                        "0000001" when "1100",  -- switchs 1100 = O --Segmentos--> 0000001
                        "1110001" when "1110",  -- switchs 1110 = L --Segmentos--> 1110001
                        "0001000" when "1111",  -- switchs 1111 = A --Segmentos--> 0001000   
                        "1111111" when others;  --Cualquier otra combinacion no prendas ningun segmento (1111111)
end bhv_in;
