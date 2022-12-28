library ieee;
use  ieee.std_logic_1164.all;

entity hw_image_generator is 
    generic(
        pixels_y : integer := 478; -- row that first color will persist until
        pixels_x : integer := 600 --column that first color will persist unitl
    );

    port(
        disp_ena : in std_logic; --display enable ( 1 = display time , 0 = blanking time borrado)
        row      : in integer;   -- row pixel coodinate
        column   : in integer;   -- column picel coordinate
        red      : out std_logic_vector(3 downto 0) := (others => '0');
        greeen      : out std_logic_vector(3 downto 0) := (others => '0');
        blue      : out std_logic_vector(3 downto 0) := (others => '0')
    );

end entity hw_image_generator;

