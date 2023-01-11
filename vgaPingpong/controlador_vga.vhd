--Este archivo se encarga de hacer el controlador de sincorinzacion del reloj de la FPGA (procesado por el divisor de frecuencia)
--que es el reloj de pixeles, para decir en que momento estamos posicionados en pixeles visibles 
--de nuestra pantalla VGA de 640x480

library ieee;
use ieee.std_logic_1164.all;
--simil al vga controller
entity controlador_vga is

	generic(
		--Marcos horizontales de pixeles visibles de una VGA de 640x480 visibles	
		Psh: integer := 96; --Ancho del pulso de sincronización horizontal en píxeles
		Ihv: integer := 144;--Inicio del período de actividad horizontal en píxeles (Inicio Horizontal visible)
		Fhv: integer := 784;--Final del período de actividad horizontal en píxeles, fin de la parte visible
		TotalHorizontal: integer := 800;--Largo total de la señal horizontal en píxeles o ciclos (visibles o no visibles)
		
		Psv: integer := 2;  --Pulsos de sincronización vertical en líneas de píxeles
		--Marcos verticales de pixeles visibles de una VGA de 640x480 visibles	
		Ivv: integer := 35; --Inicio del período de actividad vertical en líneas de píxeles (Inicio vertical visible)
		--33+2 // 32= BPV aqui es donde se empiezan a dibujar pixeles de forma vertical
		Fvv: integer := 515;--Final del período de actividad vertical en líneas de píxeles, fin de la parte visible
		--35+480
		TotalVertical: integer := 525 --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
		--515+10
	);
		 
	port(
		reloj_pixeles	: in std_logic; --Señal de reloj para contar los píxeles
		encendido	: in std_logic; --esta encendido el juego o no 

		--BUFFER : permiten retroalimentacion interna en la entidad, pero no desde otras entidades
		--util usar buffers ya que se retrolimentan las señales de sincronizacion  con datos de esta propia entidad nada mas
		--buffers de entrada
		Hsync	: buffer std_logic; -- Horizontal sync pulse. señal de sincronizacion horizontal
		Vsync	: buffer std_logic; -- Vertical sync pulse. señal de sincronizacion vertical
		--buffers de salida 
		Hactive : buffer std_logic; --indican cuando los píxeles deben ser mostrados en la pantalla.
		-- '1' durante el período de actividad horizontal y '0' el resto del tiempo.
		Vactive : buffer std_logic; --indica cuando una línea de píxeles deben ser mostradas en la pantalla.
		-- '1' durante el período de actividad vertical y '0' el resto del tiempo.

		habilitador : out std_logic --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
	);
		
end controlador_vga;


architecture controlador_vga_bhv of controlador_vga is
-- esta arquitectura se encarga de controlar las señales de sincronizacion horizontal y vertical

begin

	--Proceso de sincornizacion Horizontal
	--El proceso de sincronización horizontal utiliza la señal de reloj reloj_pixeles 
	--para contar los píxeles y establece la señal Hsync y Hactive en los momentos adecuados. 
	--En otras palabras recorremos horizontalmente e indicamos cuando estamos en la parte visible del monitor
	process(reloj_pixeles, encendido)
		variable ContadorHorizontal: integer range 0 to TotalHorizontal;
		--recorreremos con ContadorHorizontal cada pixel del monitor de izquierda a derecha
	begin	
		if(encendido = '0') then
			ContadorHorizontal := 0; 
			
		elsif(reloj_pixeles'event and reloj_pixeles = '1') then
			ContadorHorizontal := ContadorHorizontal + 1; -- avanza el contador mientras avanza el reloj, un pixel por cada clk
			
			if(ContadorHorizontal = Psh) then
				--Si estamos dentro del pulso de sincronizacion horizontal, 
				Hsync <= '1'; 
			
			--logica de la parte visible
			elsif(ContadorHorizontal = Ihv) then
				Hactive <= '1';--estamos dentro los pixeles horizontales visibles 			
			elsif(ContadorHorizontal = Fhv) then
				Hactive <= '0';--ya no estamos en la parte horizontal visible 
				
			elsif(ContadorHorizontal = TotalHorizontal) then --Llegamos al final de los pixeles horizontales
				--reinicia los contadores de sincronizacion y recorrido horizontal
				Hsync <= '0'; 
				ContadorHorizontal := 0;
			end if;
		end if;
	end process;


	
	--Proceso de sincornizacion Vertical
	--El proceso de sincronización vertical utiliza la señal Hsync 
	--para contar las líneas de píxeles y establece la señal Vsync y Vactive en los momentos adecuados.
	--En otras palabras recorremos verticalmente e indicamos cuando estamos en la parte visible del monitor
	process(Hsync, encendido)
		variable ContadorVertical: integer range 0 to TotalVertical;
		--recorreremos con ContadorVertical cada pixel del monitor de arriba a abajo
	begin	
		if(encendido = '0') then
			ContadorVertical := 0;
		
		elsif(Hsync'event and Hsync = '1') then--Si estamos en el pulso de sincronizacion
			ContadorVertical := ContadorVertical + 1; -- avanza el contador mientras avanza el reloj, un pixel por cada clk
			
			if(ContadorVertical = Psv) then --estamos en los pulsos de sincronizacion verticales
				Vsync <= '1';

			--logica de la parte visible
			elsif(ContadorVertical = Ivv) then
				Vactive <= '1';--estamos dentro los pixeles horizontales visibles 
			elsif(ContadorVertical = Ivv) then
				Vactive <= '0';----ya no estamos en la parte horizontal visible 

			elsif(ContadorVertical = TotalVertical) then --Llegamos al final de los pixeles verticales
			--reinicia los contadores de sincronizacion y recorrido vertical
				Vsync <= '0';
				ContadorVertical := 0;
			end if;
		end if;
	end process;
	


	
	habilitador <= Hactive and Vactive; 
	--Habilitador indica con 1 estamos en la parte visible de nuestro VGA de 640x480 píxeles
	
end controlador_vga_bhv;

