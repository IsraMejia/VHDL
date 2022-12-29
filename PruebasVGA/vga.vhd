library ieee;
use  ieee.std_logic_1164.all;

entity vga is  
    port(
        input_clk   :in std_logic; --50mhz
        pixel_clk   :out std_logic; --monitor del reloj a 25 mhz

        red         :out std_logic_vector(3 downto 0);
        green       :out std_logic_vector(3 downto 0);
        blue        :out std_logic_vector(3 downto 0);

        h_sync          :out std_logic;
        v_sync          :out std_logic
    );
end entity vga;

architecture behaviorall of vga is 
    signal pixel_clock  :std_logic;
    signal disp_ena     :std_logic; --1 enable, 0 dispborrada
    signal column       :integer;   --horizontal pixel coordinate
    signal row          :integer;   --vertical pixel coordinate
    signal reset, cs    :std_logic;

    begin
        pixel_clk <= pixel_clock;
        reset <= '1';
        cs <= '1';

        u1: entity work.gen25mhz(behavior) port map (input_clk, pixel_clock);

        u2: entity work.vga_controller(behavior) 
            port map (pixel_clock, '1', h_sync, v_sync, disp_ena, column, row);
        
        u3: entity work.hw_image_generator(behavior)
            port map (disp_ena, row, column, red, green, blue);
    end;
