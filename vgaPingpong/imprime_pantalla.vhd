--Este arcivo se encarga de hacer toda la logica necesaria para dibujar en pantalla 
-- el videojuego del ping pong, desde su logica para recorrer pixel a pixel de la pantalla
-- dibujar cada jugador, la pelota, asi como las fisicas propias del juego.
-- Contiene una maquina de estados para poder almacenar le valor de los contadores 
-- y reanudar el juego con un nuevo saque cada que se anote un punto

library ieee;
use ieee.std_logic_1164.all;

entity imprime_pantalla is

	generic(
	
		--Marcos horizontales de pixeles visibles de una VGA de 640x480 visibles	
		Psh: integer := 96; --Ancho del pulso de sincronización horizontal en píxeles
		Ihv: integer := 144;--Inicio del período de actividad horizontal en píxeles
		Fhv: integer := 784;--Final del período de actividad horizontal en píxeles, fin de la parte visible
		TotalHorizontal: integer := 800;--Ancho total de la señal horizontal en píxeles o ciclos (visibles o no visibles)
		
		Psv: integer := 2;  --Pulsos de sincronización vertical en líneas de píxeles
		--Marcos verticales de pixeles visibles de una VGA de 640x480 visibles	
		Ivv: integer := 35; --Inicio del período de actividad vertical en líneas de píxeles
		--33+2 // 32= BPV aqui es donde se empiezan a dibujar pixeles de forma vertical
		Fvv: integer := 515;--Final del período de actividad vertical en líneas de píxeles, fin de la parte visible
		--35+480
		TotalVertical: integer := 525; --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
		--515+10
		
		MedidaVerticalRaqueta: integer := 10; --Medidas verticales de las raquetas de los jugadores
		MedidaHorizontalRaqueta: integer := 5;  --Medidas horizontales de las raquetas de los jugadores
		MedidaPelota: integer := 3 --tamaño de la pelota
 
	);
	
	port(
		encendido	     : in std_logic;--Si esta encendido el juego o no 
		
		--Relojes de imagenes
		reloj_pixeles 		 : in std_logic;--Señal de reloj para contar los píxeles
		reloj_raquetas		 : in std_logic;--Señal de reloj para las raquetas
		reloj_pelota	     : in std_logic;--Señal de reloj para el balon
		
		--puertos de sincronizacion 
		Hactive : in std_logic; --indican cuando los píxeles deben ser mostrados en la pantalla.
		-- '1' durante el período de actividad horizontal y '0' el resto del tiempo
		Vactive : in std_logic;--indica cuando una línea de píxeles deben ser mostradas en la pantalla.
		-- '1' durante el período de actividad vertical y '0' el resto del tiempo.
		Hsync : in std_logic; -- Horizontal sync pulse. señal de sincronizacion horizontal
		Vsync : in std_logic; -- Vertical sync pulse. señal de sincronizacion vertical
		habilitador  : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla

		palancasjugadores : in std_logic_vector(1 downto 0); --Switches/controles de cada jugador
		start_game		 : in std_logic;	--Bit de control para saber si el juego ha iniciado
		marcador_j1			 : buffer integer;
		marcador_j2			 : buffer integer;
		
		--puertos de colores
		R,G,B			 : out std_logic_vector(3 downto 0));
		
end entity imprime_pantalla;


architecture imprime_pantalla_bhv of imprime_pantalla is


	--Contadores de posicion de pixeles
	signal contador_renglones : integer range 0 to Fvv; --contador de Renglones visibles en VGA 640x480
	signal contador_columnas : integer range 0 to Fhv; --contador de Columnas visibles en VGA 640x480
	
	
	--Coordenadas de las raquetas 
	--tienen rango hasta los pixeles visibles en VGA 640x480 ya sea vertical u horizontal
	signal coord_x_raqueta1	 : integer range 0 to Fhv;
	signal coord_x_raqueta2	 : integer range 0 to Fhv;
	signal coord_y_raqueta1	 : integer range 0 to Fvv;
	signal coord_y_raqueta2	 : integer range 0 to Fvv;

	
	--Coordenadas y direccion de la pelota
	--tienen rango hasta los pixeles visibles en VGA 640x480 ya sea vertical u horizontal
	signal Coord_x_pelota		 : integer range 0 to Fhv;
	signal Coord_y_pelota		 : integer range 0 to Fvv;
	signal Direccion_pelota 	 : integer range 0 to 5;
	
	--Maquina de estados del videojuego de pingpong 
	type tipo_estados is (S0, S1);
	signal estado: tipo_estados;
	signal movimiento_juego: std_logic; --movimiento de la pelota y raquetas
	
	
begin 

	--Proceso de conteo de Pixeles visibles en el monitor VGA 640x480 
	process(reloj_pixeles, Hactive, Vactive, Hsync, Vsync) begin
		
		--Contador de Reglones de pixeles visibles de la pantalla VGA
		if(encendido = '0') then
			contador_renglones <= 0; --Por defecto, si esta apagado se reinicia el contador de renglones

			elsif(Vsync = '0') then
				contador_renglones <= 0;--Por defecto, si no hay pulso de sinc Vertical se reinicia el contador de renglones
				
			elsif(Hsync'event and Hsync = '1') then
				if(Vactive = '1') then
					contador_renglones <= contador_renglones + 1;
					--Cuanto tenemos una nueva señal de sincronizacion en 1 y estamos en un pixel vertical visible
					--aumentar el contador de renglones recorridos en 1
				end if;	
		end if;

		
		--Contador de Columnas de pixeles visibles de la pantalla VGA
		if(encendido = '0') then
			contador_columnas <= 0;--Por defecto, si esta apagado se reinicia el contador de columnas
			elsif(Hsync = '0') then
				contador_columnas <= 0;--Por defecto, si no hay pulso de sinc Horizontal se reinicia el contador de renglones
				
			elsif(reloj_pixeles'event and reloj_pixeles = '1') then
				--Cada que se avance en un pixel (un ciclo del reloj de los pixeles)
				if(Hactive = '1') then
					--Si estamos dentro del periodo visible horizontal del monitor VGA
					contador_columnas <= contador_columnas + 1;--aumentar el contador de columnas recorridos en 1
				end if;
		end if;
		
	end process;




	
	
	--Proceso de los movimientos de las raquetas del juego
	process(reloj_raquetas, encendido, palancasjugadores) begin	
		if(encendido = '0') then
			--Si esta apagado, movemos las raquetas a las posiciones iniciales del juego
			coord_x_RAQUETA1 <= 50;
			coord_y_raqueta1 <= 240;
			
			coord_x_raqueta2 <= 590;
			coord_y_raqueta2 <= 240;			

			elsif(reloj_raquetas'event and reloj_raquetas = '1') then
				--Si estamos en un nuevo flanco ascendente del reloj de las raquetas, 
				--colocalas en su posicion horizontal
				coord_x_raqueta1 <= 50;
				coord_x_raqueta2 <= 590;
				
				--MovimientoRaqueta Jugador1 	(pin c11)			
				if(palancasjugadores(0) = '0') then
					if( coord_y_raqueta1  = Fvv - Ivv - MedidaVerticalRaqueta +30) then --525-35=490  / -7=7cm
						coord_y_raqueta1 <= Fvv - Ivv - MedidaVerticalRaqueta +30; -- si llega el jugador 1 al fin vertical, ahi pare
					else coord_y_raqueta1 <= coord_y_raqueta1 + 1;
						--caso contrario siga bajando
					end if;
				end if;				
				if(palancasjugadores(0) = '1') then 
					if( coord_y_raqueta1  = MedidaVerticalRaqueta +15 ) then -- -25 = 1falta
						coord_y_raqueta1 <= MedidaVerticalRaqueta +15 ; -- si llega el jugador 1 al incio vertical, ahi pare
					else coord_y_raqueta1 <= coord_y_raqueta1 - 1;
						--caso contrario siga subiendo bajando
					end if;
				end if;
				

				
				--MovimientoRaqueta Jugador2 (pin c10)	
				if(palancasjugadores(1) = '0') then
					if( coord_y_raqueta2  = Fvv - Ivv - MedidaVerticalRaqueta + 30) then --525-35=490
						coord_y_raqueta2 <= Fvv - Ivv - MedidaVerticalRaqueta + 30;-- si llega el jugador 2 al fin vertical, ahi pare
					else coord_y_raqueta2 <= coord_y_raqueta2 + 1;
						--caso contrario siga bajando
					end if;
				end if;				
				if(palancasjugadores(1) = '1') then
					if( coord_y_raqueta2  =  MedidaVerticalRaqueta +15) then
						coord_y_raqueta2 <=  MedidaVerticalRaqueta +15 ; -- si llega el jugador 2 al incio vertical, ahi pare
					else coord_y_raqueta2 <= coord_y_raqueta2 - 1;
						--caso contrario siga subiendo  bajando
					end if;
			end if;
			
		end if;		
	end process;




	
	--Fisicas de la pelota	
	process(reloj_pelota, encendido, Direccion_pelota, movimiento_juego) begin 
	
	
		if(encendido = '0' or movimiento_juego = '0') then
			--En caso de que no este encendido el juego o aun no se indique movimiento, centra la pelota
			Coord_x_pelota <= 320;
			Coord_y_pelota <= 240;
			
			Direccion_pelota <= Direccion_pelota + 1;
			--cambiamos a la siguiente direccion de inicio de la pelota para que continue el juego
					if(Direccion_pelota > 5) then
						Direccion_pelota <= 0; -- se reinicia el ciclo de direcciones cuando ya se usaron todas
					end if;
		
		elsif(reloj_pelota'event and reloj_pelota = '1') then
			--en cada flanco ascendente del reloj de velocidad de la pelota 
			case Direccion_pelota is
			
				-- Direcciones, 6 en total, 4 diagonales y 2 horizontales	
				--MODIFICAR
					--El orden que nos da es el de las manecillas del reloj de 0 a 5 
				--MODIFICAR			
				when 0 => Coord_x_pelota <= Coord_x_pelota + 1; 	--Diagonal hacia la derecha y abajo
							 Coord_y_pelota <= Coord_y_pelota - 1;

				when 1 => Coord_x_pelota <= Coord_x_pelota - 1;		--Diagonal hacia la izquierda y abajo
							 Coord_y_pelota <= Coord_y_pelota - 1;

				when 2 => Coord_x_pelota <= Coord_x_pelota - 1;		--Diagonal hacia la izquierda y arriba
							 Coord_y_pelota <= Coord_y_pelota + 1;

				when 3 => Coord_x_pelota <= Coord_x_pelota + 1;		--Diagonal hacia la derecha y arriba	
						    Coord_y_pelota <= Coord_y_pelota + 1;

				when 4 => Coord_x_pelota <= Coord_x_pelota + 1;		--Horizontal a la derecha

				when 5 => Coord_x_pelota <= Coord_x_pelota - 1;		--Horizontal a la izquierda

			end case;
			
			
			--Fisica de rebote en los bordes de las barras ---Verticales
			if(Coord_y_pelota = 30) then	 --Si toca el borde superior la pelota			
				if(Direccion_pelota = 0) then -- y tiene una Diagonal hacia la derecha y abajo
					Direccion_pelota <= 3;	--rebota haciando una Diagonal hacia la derecha y arriba	
				elsif(Direccion_pelota = 1) then
					Direccion_pelota <= 2;
				end if;
			end if;
			
			if(Coord_y_pelota = 480) then  --Si toca el borde inferior la pelota							
				if(Direccion_pelota = 2) then --si hace una Diagonal hacia la izquierda y arriba
					Direccion_pelota <= 1;	--rebota haciendo una Diagonal hacia la izquierda y abajo
				elsif(Direccion_pelota = 3) then
					Direccion_pelota <= 0;
				end if;
			end if;
			

			--Fisica de rebote en los bordes de las barras ---Horizontales
			if(Coord_x_pelota = 0) then		--Si toca el borde izquierdo			
				if(Direccion_pelota = 1) then --Si venia en Diagonal hacia la izquierda y abajo
					Direccion_pelota <= 0;	--Rebota en Diagonal hacia la derecha y abajo
				elsif(Direccion_pelota = 2) then --Si venia en Diagonal hacia la izquierda y arriba
					Direccion_pelota <= 3;	   --Rebota en Diagonal hacia la derecha y arriba
				elsif(Direccion_pelota = 5) then --Si venia en Horizontal a la izquierda
					Direccion_pelota <= 4;	   --Horizontal a la derecha
				end if;
			end if;
			
			if(Coord_x_pelota = 640) then		--Si toca el borde Derecho						
				if(Direccion_pelota = 0) then	--Si venia en Diagonal hacia la derecha y abajo
					Direccion_pelota <= 1;	--Rebota en Diagonal hacia la izquierda y abajo
				elsif(Direccion_pelota = 3) then  --Si venia en Diagonal hacia la derecha y arriba
					Direccion_pelota <= 2;		--Rebota en Diagonal hacia la izquierda y arriba
				elsif(Direccion_pelota = 4) then  --Si venia en Horizontal a la derecha
					Direccion_pelota <= 5;		--Rebota en Horizontal a la izquierda
				end if;
			end if;
			

			-- Fisicas de Rebote del balon con las raquetas de los jugadores
			--Rebote de balon en jugador 2
			if(Coord_x_pelota + MedidaPelota > coord_x_raqueta2 - MedidaHorizontalRaqueta) then 
			--si la pelota llega a la posicion horizontal de la raqueta del jugador 2
					if(Coord_y_pelota - MedidaPelota <= coord_y_raqueta2 + MedidaVerticalRaqueta and
						Coord_y_pelota + MedidaPelota >= coord_y_raqueta2 - MedidaVerticalRaqueta) then
						--Si la pelota esta en el rango vertical de la raqueta2
						if(Coord_y_pelota >= coord_y_raqueta2 - 10 and
							Coord_y_pelota <= coord_y_raqueta2 + 10) then
							--Si la pelota esta cerca del centro, va a rebotar horizontalmente 
								Direccion_pelota <= 5;
						else							
							if(Direccion_pelota = 0) then 
							--Si la pelota viene en Diagonal hacia la derecha y abajo
								Direccion_pelota <= 1; --Rebota en Diagonal hacia la izquierda y abajo
								
							elsif(Direccion_pelota = 3) then
							--Si la pelota viene en Diagonal hacia la derecha y arriba
								Direccion_pelota <= 2; --Rebota en Diagonal hacia la izquierda y arriba
							
							elsif(Direccion_pelota = 4) then
							--Si la pelota viene en Horizontal a la derecha
								if(Coord_y_pelota > coord_y_raqueta2) then
								--Si la pelota toca borde vertical del jugador 2 (borde superior)
									Direccion_pelota <= 2;--Rebota en Diagonal hacia la izquierda y arriba
								else--(borde inferior)
									Direccion_pelota <= 1;--Rebota en Diagonal hacia la izquierda y abajo
								end if;
							end if;
						end if;
					end if;
			end if;
			

			-- Fisicas de Rebote del balon con las raquetas de los jugadores
			--Rebote de balon en jugador 1
			if(Coord_x_pelota - MedidaPelota < coord_x_raqueta1 + MedidaHorizontalRaqueta) then
			--Si la pelota llega a la posicion horizontal de la raqueta del jugador 1
					if(Coord_y_pelota - MedidaPelota <= coord_y_raqueta1 + MedidaVerticalRaqueta and
						Coord_y_pelota + MedidaPelota >= coord_y_raqueta1 - MedidaVerticalRaqueta) then
						--Si la pelota esta en el rango vertical de la raqueta1
						if(Coord_y_pelota >= coord_y_raqueta1 - 10 and
							Coord_y_pelota <= coord_y_raqueta1 + 10) then
								--Si la pelota esta cerca del centro, va a rebotar horizontalmente
								Direccion_pelota <= 4;
						else							
							if(Direccion_pelota = 1) then
							--Si la pelota viene en Diagonal hacia la izquierda y abajo
								Direccion_pelota <= 0; --Rebota en Diagonal hacia la derecha y abajo
								
							elsif(Direccion_pelota = 2) then
							--Si la pelota viene en Diagonal hacia la izquierda y arriba
								Direccion_pelota <= 3;--Rebota en Diagonal hacia la derecha y arriba
							
							elsif(Direccion_pelota = 5) then
							--Si la pelota viene de forma horizontal hacia la izquierda
								if(Coord_y_pelota > coord_y_raqueta1) then
								--Si la pelota toca borde vertical del jugador 1 (borde superior)
									Direccion_pelota <= 3;--Rebota en Diagonal hacia la derecha y arriba
								else--(borde inferior)
									Direccion_pelota <= 0;--Rebota en Diagonal hacia la derecha y abajo
								end if;
							end if;
						end if;
					end if;
			end if;
			
		
		end if;
		
	end process;
	




	
	--Logica de la maquina de estados del videojuego
	process(reloj_pixeles, encendido) begin
		--Podemos ver que se ejecuta cuando reloj_pixeles, o encendido cambia
	
		if(encendido = '0') then 
		--Si se apaga el juego se reinician los estados del juego
			estado <= S0;
			marcador_j1 <= 0;
			marcador_j2 <= 0;
		
		elsif(reloj_pixeles'event and reloj_pixeles = '1') then
		--Si estamos en un flanco ascendente del reloj de pixeles
			case estado is
				when S0 => --Cuando estamos en el estado 0
					if(start_game = '0') then --Si no se inia el juego
						Estado <= S1; --Se espera que el jugador inicie el jeugo para continuar
					end if;

				when S1 =>--Cuando estamos en el estado 1
					
					--Si anota el jugador 2
					if(Coord_x_pelota < 40) then--Si la pelota es anotada en la cancha izquierda
						Estado <= S0; --Se pausa el juego
						if(marcador_j2 = 9) then --Si el jugador 2 llego a 9 puntos
							--gano el juego y reiniciamos los marcadores
							marcador_j2 <= 0;
							marcador_j1 <= 0;
						else
							--Si no se ha ganado el juego, solo aumentamos el contador del jugador 2
							marcador_j2 <= marcador_j2 + 1;
						end if;
					end if;

					--Si anota el jugador 1
					if(Coord_x_pelota > 600) then --Si la pelota es anotada en la cancha derecha 
						Estado <= S0; --Se pausa el juego
						if(marcador_j1 = 9) then --Si el jugador 1 llego a 9 puntos
							--gano el juego y reiniciamos los marcadores
							marcador_j1 <= 0;
							marcador_j2 <= 0;
						else
							--Si no se ha ganado el juego, solo aumentamos el contador del jugador 1
							marcador_j1 <= marcador_j1 + 1;
						end if;
					end if;
					
			end case;
		end if;
	end process;
	
	--Proceso que pausa o reanuda el juego
	process(Estado) begin
		--Cuando haya un cambio en el estado de la maquina de estados del juego
		
		case Estado is
			when S0 => --Si estamos en S0, asignamos 0 a mov, lo que pausa el juego
				movimiento_juego <= '0';

			when S1 => --Si estamos en S1, asignamos 1 a mov, lo que reanuda el juego
				movimiento_juego <= '1';
		end case;
	end process;




	
	--Proceso que se encarga de dibujar el juego en la pantalla
	process(coord_x_raqueta1, coord_y_raqueta1, 
			coord_x_raqueta2, coord_y_raqueta2, 
			habilitador, 
			contador_renglones, contador_columnas) begin
		
		--Si estamos en un area visible de la pantalla VGA para poder dibujar
		if(habilitador = '1') then
		
			--En caso de que estemos en un area perteneciente al jugador 1
			 if((coord_x_raqueta1 <= contador_columnas + MedidaHorizontalRaqueta) and
				(coord_x_raqueta1 + MedidaHorizontalRaqueta >= contador_columnas) and
				(coord_y_raqueta1 <= contador_renglones + MedidaVerticalRaqueta) and
				(coord_y_raqueta1 + MedidaVerticalRaqueta >= contador_renglones)) or
				
			--En caso de que estemos en un area perteneciente al jugador 2
				((coord_x_raqueta2 <= contador_columnas + MedidaHorizontalRaqueta) and
				(coord_x_raqueta2 + MedidaHorizontalRaqueta >= contador_columnas) and
				(coord_y_raqueta2 <= contador_renglones + MedidaVerticalRaqueta) and
				(coord_y_raqueta2 + MedidaVerticalRaqueta >= contador_renglones)) or
				
			--En caso de que estemos en un area perteneciente a la Pelota
				((Coord_x_pelota <= contador_columnas + MedidaPelota) and
				(Coord_x_PELOTA + MedidaPelota >= contador_columnas) and
				(Coord_y_pelota <= contador_renglones + MedidaPelota) and
				(Coord_y_pelota + MedidaPelota >= contador_renglones))	then
				
				--Colores que se usaran 
					R <= "1110";
					G <= "1110";
					B <= "0000";
				
			else		
				--Para el resto (fondo de la pantalla)			
				R <= "1000";
				G <= "0000";
				B <= "1100";				
			end if;
			
		else
		
			-- If habilitador = 0, No mostrar nada
		
			R <= (others => '0');
			G <= (others => '0');
			B <= (others => '0');
			
		end if;
		
	end process;

end imprime_pantalla_bhv;
			
