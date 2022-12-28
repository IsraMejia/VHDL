library ieee;
use  ieee.std_logic_1164.all;

entity gen25mhz is 
    port (
        clk50mhz : in std_logic;
        clk25mhz : inout std_logic := '0' --entrada y salida
    );
end entity gen25mhz;

architecture behavior of gen25mhz is 
begin   
    process (clk50mhz)
    begin 
        if clk50mhz'event and clk50mhz = '1' then
            clk25mhz <= not clk25mhz; --convierte un reloj de 50 mhz a uno de 25
        end if;
    end process;
end architecture