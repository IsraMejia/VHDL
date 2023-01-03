library ieee;
use ieee.std_logic_1164.all;
--simil al vga controller
entity sync_generator is

	generic(
		--Marcos horizontales de pixeles visibles de una VGA de 640x480 visibles	
		Ha: integer := 96; --Ancho del pulso de sincronización horizontal en píxeles
		Hb: integer := 144;--Inicio del período de actividad horizontal en píxeles
		Hc: integer := 784;--Final del período de actividad horizontal en píxeles

		Hd: integer := 800;--Ancho total de la señal horizontal en píxeles o ciclos (visibles o no visibles)
		Va: integer := 2;  --Pulsos de sincronización vertical en líneas de píxeles

		--Marcos verticales de pixeles visibles de una VGA de 640x480 visibles	
		Vb: integer := 35; --Inicio del período de actividad vertical en líneas de píxeles
		--33+2 // 32= BPV aqui es donde se empiezan a dibujar pixeles de forma vertical
		Vc: integer := 515;--Final del período de actividad vertical en líneas de píxeles
		--35+480
		Vd: integer := 525 --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
		--515+10
	);
		
	port(
		pixel_clk	: in std_logic; --Señal de reloj para contar los píxeles
		encendido	: in std_logic; --esta encendido el juego o no 

		--BUFFER : permiten retroalimentacion interna en la entidad, pero no desde otras entidades
		--util usar buffers ya que se retrolimentan las señales de sincronizacion  con datos de esta propia entidad nada mas
		--buffers de entrada
		Hsync	: buffer std_logic; -- Horizontal sync pulse. señal de sincronizacion horizontal
		Vsync	: buffer std_logic; -- Vertical sync pulse. señal de sincronizacion vertical
		--buffers de salida
		Hactive : buffer std_logic; --indican cuando los píxeles deben ser mostrados en la pantalla.
		-- '1' durante el período de actividad horizontal y '0' el resto del tiempo
		Vactive : buffer std_logic; --indica cuando una línea de píxeles deben ser mostradas en la pantalla.
		-- '1' durante el período de actividad vertical y '0' el resto del tiempo.

		dena : out std_logic --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
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

