library ieee;
use ieee.std_logic_1164.all;
--simil al vga controller
entity sync_generator is

	generic(	
		Ha: integer := 96; --horiztonal sync pulse width in pixels
		Hb: integer := 144;
		Hc: integer := 784;

		Hd: integer := 800;
		Va: integer := 2;

		Vb: integer := 35;  --33+2 // 32= BPV
		Vc: integer := 515; --35+480
		Vd: integer := 525  --515+10
	);
		
	port(
		pixel_clk	: in std_logic;
		encendido	: in std_logic;
		--BUFFER : Los datos fluyen fuera de la entidad, pero la entidad puede leer la señal 
			--(lo que permite la retroalimentación interna). 
			--Sin embargo, la señal no puede ser impulsada desde fuera de la entidad, 
			--por lo que no puede usarse para la entrada de datos.
		Hsync	: buffer std_logic; -- Horizontal sync pulse.
		Vsync	: buffer std_logic; -- Vertical sync pulse.
		Hactive : buffer std_logic;
		Vactive : buffer std_logic;
		dena : out std_logic
	);
		
end sync_generator;


architecture sync_generator_arch of sync_generator is


begin


	-- Horizontal signal generator	
	process(pixel_clk, encendido)
		variable Hcount: integer range 0 to Hd;
	begin	
		if(encendido = '0') then
			Hcount := 0;
			
		elsif(pixel_clk'event and pixel_clk = '1') then
			Hcount := Hcount + 1;
			
			if(Hcount = Ha) then
				Hsync <= '1';
				
			elsif(Hcount = Hb) then
				Hactive <= '1';
			
			elsif(Hcount = Hc) then
				Hactive <= '0';
				
			elsif(Hcount = Hd) then
				Hsync <= '0';
				Hcount := 0;
			end if;
		end if;
	end process;


	
	-- Vertical signal generator	
	process(Hsync, encendido)
		variable Vcount: integer range 0 to Vd;
	begin	
		if(encendido = '0') then
			Vcount := 0;
		
		elsif(Hsync'event and Hsync = '1') then
			Vcount := Vcount + 1;
			
			if(Vcount = Va) then
				Vsync <= '1';
			elsif(Vcount = Vb) then
				Vactive <= '1';
			elsif(Vcount = Vc) then
				Vactive <= '0';
			elsif(Vcount = Vd) then
				Vsync <= '0';
				Vcount := 0;
			end if;
		end if;
	end process;
	


	-- Dena generator (enables to diplay on the screen)	
	dena <= Hactive and Vactive;
	
end sync_generator_arch;

