library ieee;
use ieee.std_logic_1164.all;

entity UL is 
    port(
        x, y: in std_logic_vector(3 downto 0); -- entrada
        sel: in std_logic_vector(2 downto 0);  
        l: out std_logic_vector(3 downto 0) -- salida proporcional a la entrada
    );
end;

architecture bhv of UL is
begin

l <= ( x and y) when sel = "000" else 
     (x or y )  when sel = "001" else 
     (not x  )  when sel = "010" else 
     (x xor y)  when sel = "011" else 
     (x nor y ) when sel = "100" else 
     (x nand y) when sel = "101" else 
     (y)        when sel = "110" else
     (not x or y); 
end;
