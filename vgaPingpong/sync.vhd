library ieee;
use ieee.std_logic_1164.all;
--simil al vga controller
entity sync_generator is

	generic(
		--Marcos horizontales de pixeles visibles de una VGA de 640x480 visibles	
		Ha: integer := 96; --Ancho del pulso de sincronización horizontal en píxeles
		Hb: integer := 144;--Inicio del período de actividad horizontal en píxeles
		Hc: integer := 784;--Final del período de actividad horizontal en píxeles, fin de la parte visible

		Hd: integer := 800;--Ancho total de la señal horizontal en píxeles o ciclos (visibles o no visibles)
		Va: integer := 2;  --Pulsos de sincronización vertical en líneas de píxeles

		--Marcos verticales de pixeles visibles de una VGA de 640x480 visibles	
		Vb: integer := 35; --Inicio del período de actividad vertical en líneas de píxeles
		--33+2 // 32= BPV aqui es donde se empiezan a dibujar pixeles de forma vertical
		Vc: integer := 515;--Final del período de actividad vertical en líneas de píxeles, fin de la parte visible
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
-- esta arquitectura se encarga de controlar las señales de sincronizacion horizontal y vertical

begin

	--Proceso de sincornizacion Horizontal
	--El proceso de sincronización horizontal utiliza la señal de reloj pixel_clk 
	--para contar los píxeles y establece la señal Hsync y Hactive en los momentos adecuados. 
	--En otras palabras recorremos horizontalmente e indicamos cuando estamos en la parte visible del monitor
	process(pixel_clk, encendido)
		variable Hcount: integer range 0 to Hd;
		--recorreremos con Hcount cada pixel del monitor de izquierda a derecha
	begin	
		if(encendido = '0') then
			Hcount := 0; 
			
		elsif(pixel_clk'event and pixel_clk = '1') then
			Hcount := Hcount + 1; -- avanza el contador mientras avanza el reloj, un pixel por cada clk
			
			if(Hcount = Ha) then
				--Si estamos dentro del pulso de sincronizacion horizontal, 
				Hsync <= '1'; 
			
			--logica de la parte visible
			elsif(Hcount = Hb) then
				Hactive <= '1';--estamos dentro los pixeles horizontales visibles 			
			elsif(Hcount = Hc) then
				Hactive <= '0';--ya no estamos en la parte horizontal visible 
				
			elsif(Hcount = Hd) then --Llegamos al final de los pixeles horizontales
				--reinicia los contadores de sincronizacion y recorrido horizontal
				Hsync <= '0'; 
				Hcount := 0;
			end if;
		end if;
	end process;


	
	--Proceso de sincornizacion Vertical
	--El proceso de sincronización vertical utiliza la señal Hsync 
	--para contar las líneas de píxeles y establece la señal Vsync y Vactive en los momentos adecuados.
	--En otras palabras recorremos verticalmente e indicamos cuando estamos en la parte visible del monitor
	process(Hsync, encendido)
		variable Vcount: integer range 0 to Vd;
		--recorreremos con Vcount cada pixel del monitor de arriba a abajo
	begin	
		if(encendido = '0') then
			Vcount := 0;
		
		elsif(Hsync'event and Hsync = '1') then--Si estamos en el pulso de sincronizacion
			Vcount := Vcount + 1; -- avanza el contador mientras avanza el reloj, un pixel por cada clk
			
			if(Vcount = Va) then --estamos en los pulsos de sincronizacion verticales
				Vsync <= '1';

			--logica de la parte visible
			elsif(Vcount = Vb) then
				Vactive <= '1';--estamos dentro los pixeles horizontales visibles 
			elsif(Vcount = Vc) then
				Vactive <= '0';----ya no estamos en la parte horizontal visible 

			elsif(Vcount = Vd) then --Llegamos al final de los pixeles verticales
			--reinicia los contadores de sincronizacion y recorrido vertical
				Vsync <= '0';
				Vcount := 0;
			end if;
		end if;
	end process;
	


	-- Dena generator (enables to diplay on the screen)	
	dena <= Hactive and Vactive; --Dena indica con 1 estamos en la parte visible de nuestro VGA de 640x480 píxeles
	
end sync_generator_arch;

