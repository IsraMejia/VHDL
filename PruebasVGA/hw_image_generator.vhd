library ieee;
use  ieee.std_logic_1164.all;

entity hw_image_generator is 
    generic(
        pixels_y : integer := 640; -- row that first color will persist until
        pixels_x : integer := 480 --column that first color will persist unitl
    );

    port(
        disp_ena : in std_logic; --display enable ( 1 = display time , 0 = blanking time borrando)
        row      : in integer;   -- row pixel coodinate
        column   : in integer;   -- column picel coordinate
        
        -- color magnitude output to DAC
        red      : out std_logic_vector(3 downto 0) := (others => '0'); 
        green   : out std_logic_vector(3 downto 0) := (others => '0');
        blue     : out std_logic_vector(3 downto 0) := (others => '0')
    );

end entity hw_image_generator;

architecture behavior of hw_image_generator is 
begin   
    process(disp_ena, row, column)
    begin 
        if (disp_ena = '1') then --display time

            if((row > 200 and row < 250) and  (column >1 and column<50)) then
                red <= (others => '1'); -- no dibujar nanda
                green <= (others => '0');
                blue <= (others => '0');

            elsif((row > 200 and row < 250) and  (column >100 and column<150)) then
                red <= (others => '0'); -- no dibujar nanda
                green <= (others => '1');
                blue <= (others => '0');
            
            elsif((row > 200 and row < 250) and  (column >200 and column<250)) then
                red <= (others => '0'); -- no dibujar nanda
                green <= (others => '0');
                blue <= (others => '1');
            
            elsif((row > 200 and row < 250) and  (column >300 and column<350)) then
                red <= (others => '1'); -- no dibujar nanda
                green <= (others => '1');
                blue <= (others => '1');
            
            elsif((row > 200 and row < 250) and  (column >400 and column<450)) then
                red <= (others => '1'); -- no dibujar nanda
                green <= (others => '0');
                blue <= (others => '0');
            
            else
                red <= (others => '0'); -- no dibujar nanda
                green <= (others => '0');
                blue <= (others => '0');
            
            end if ;
        end if;

    end process ;
end behavior ;
