library ieee;
use ieee.std_logic_1164.all;

entity image_generator is

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
		
		PVsize: integer := 10; --Medidas verticales de las raquetas de los jugadores
		PHsize: integer := 5;  --Medidas horizontales de las raquetas de los jugadores
		BallSize: integer := 3 --tamaño de la pelota

		--mov_continuo : std_logic := 1
	);
	
	port(
		encendido	     : in std_logic;--Si esta encendido el juego o no 
		
		--Relojes de imagenes
		pixel_clk 		 : in std_logic;--Señal de reloj para contar los píxeles
		paddle_clk		 : in std_logic;--Señal de reloj para las raquetas
		ball_clk	     : in std_logic;--Señal de reloj para el balon
		
		--puertos de sincronizacion 
		Hactive : in std_logic; --indican cuando los píxeles deben ser mostrados en la pantalla.
		-- '1' durante el período de actividad horizontal y '0' el resto del tiempo
		Vactive : in std_logic;--indica cuando una línea de píxeles deben ser mostradas en la pantalla.
		-- '1' durante el período de actividad vertical y '0' el resto del tiempo.
		Hsync : in std_logic; -- Horizontal sync pulse. señal de sincronizacion horizontal
		Vsync : in std_logic; -- Vertical sync pulse. señal de sincronizacion vertical
		dena		 	 : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla

		direction_switch : in std_logic_vector(3 downto 0);
		start_game		 : in std_logic;
		score1			 : buffer integer;
		score2			 : buffer integer;
		
		--puertos de colores
		R,G,B			 : out std_logic_vector(3 downto 0));
		
end image_generator;


architecture image_generator_arch of image_generator is


	--Contadores de posicion de pixeles
	signal row_counter : integer range 0 to Vc; --contador de Renglones visibles en VGA 640x480
	signal col_counter : integer range 0 to Hc; --contador de Columnas visibles en VGA 640x480
	
	
	--Paddle positions
	--tienen rango hasta los pixeles visibles en VGA 640x480 ya sea vertical u horizontal
	signal paddle1_pos_x	 : integer range 0 to Hc;
	signal paddle2_pos_x	 : integer range 0 to Hc;
	signal paddle1_pos_y	 : integer range 0 to Vc;
	signal paddle2_pos_y	 : integer range 0 to Vc;

	
	--Position and direction of the ball	
	--tienen rango hasta los pixeles visibles en VGA 640x480 ya sea vertical u horizontal
	signal Ball_pos_x		 : integer range 0 to Hc;
	signal Ball_pos_y		 : integer range 0 to Vc;
	signal Ball_direction : integer range 0 to 5;
	
	--States of the game
	--Maquina de estados del videojuego de pingpong 
	type state_type is (S0, S1);
	signal state: state_type;
	signal move: std_logic; --movimiento de la pelota
	
	
begin 

	--Proceso de conteo de Pixeles visibles en el monitor VGA 640x480 
	process(pixel_clk, Hactive, Vactive, Hsync, Vsync) begin
		--Contador de Reglones de pixeles visibles de la pantalla VGA
		if(encendido = '0') then
			row_counter <= 0; --Por defecto, si esta apagado se reinicia el contador de renglones

			elsif(Vsync = '0') then
				row_counter <= 0;--Por defecto, si no hay pulso de sinc Vertical se reinicia el contador de renglones
				
			elsif(Hsync'event and Hsync = '1') then
				if(Vactive = '1') then
					row_counter <= row_counter + 1;
				--Cuanto tenemos una nueva señal de sincronizacion en 1 y estamos en un pixel vertical visible
				--aumentar el contador de renglones recorridos en 1
				end if;	
		end if;

		
		--Contador de Columnas de pixeles visibles de la pantalla VGA
		if(encendido = '0') then
			col_counter <= 0;--Por defecto, si esta apagado se reinicia el contador de columnas
			elsif(Hsync = '0') then
				col_counter <= 0;--Por defecto, si no hay pulso de sinc Horizontal se reinicia el contador de renglones
				
			elsif(pixel_clk'event and pixel_clk = '1') then
				--Cada que se avance en un pixel (un ciclo del reloj de los pixeles)
				if(Hactive = '1') then
					--Si estamos dentro del periodo visible horizontal del monitor VGA
					col_counter <= col_counter + 1;--aumentar el contador de columnas recorridos en 1
				end if;
		end if;
		
	end process;




	
	
	--Proceso de los movimientos de las raquetas del juego
	process(paddle_clk, encendido, direction_switch) begin	
		if(encendido = '0') then
			--Si esta apagado, movemos las raquetas a las posiciones iniciales del juego
			paddle1_pos_X <= 50;
			paddle1_pos_y <= 240;
			
			paddle2_pos_x <= 590;
			paddle2_pos_y <= 240;			

			elsif(paddle_clk'event and paddle_clk = '1') then
				--Si estamos en un nuevo flanco ascendente del reloj de las raquetas, 
				--colocalas en su posicion horizontal
				paddle1_pos_x <= 50;
				paddle2_pos_x <= 590;
				
				--MovimientoRaqueta Jugador1				
				if(direction_switch(0) = '0') then
					if(paddle1_pos_y = Vc - Vb) then --525-35=490
						paddle1_pos_y <= Vc - Vb; -- si llega el jugador 1 al fin vertical, ahi pare
					else paddle1_pos_y <= paddle1_pos_y - 1;
						--caso contrario siga bajando
					end if;
				end if;				
				if(direction_switch(0) = '1') then
					if(paddle1_pos_y = 0) then
						paddle1_pos_y <= 0; -- si llega el jugador 1 al incio vertical, ahi pare
					else paddle1_pos_y <= paddle1_pos_y + 1;
						--caso contrario siga subiendo bajando
					end if;
				end if;
				


				--MovimientoRaqueta Jugador2
				if(direction_switch(1) = '0') then
					if(paddle2_pos_y = Vc - Vb) then --525-35=490
						paddle2_pos_y <= Vc - Vb;-- si llega el jugador 2 al fin vertical, ahi pare
					else paddle2_pos_y <= paddle2_pos_y - 1;
						--caso contrario siga bajando
					end if;
				end if;				
				if(direction_switch(1) = '1') then
					if(paddle2_pos_y = 0) then
						paddle2_pos_y <= 0 ; -- si llega el jugador 2 al incio vertical, ahi pare
					else paddle2_pos_y <= paddle2_pos_y + 1;
						--caso contrario siga subiendo  bajando
					end if;
			end if;
			
		end if;		
	end process;




	
	--Fisicas de la pelota	
	process(ball_clk, encendido, Ball_direction, move) begin 
	
	
		if(encendido = '0' or move = '0') then
			--En caso de que no este encendido el juego o aun no se indique movimiento, centra la pelota
			Ball_pos_x <= 320;
			Ball_pos_y <= 240;
			
			Ball_direction <= Ball_direction + 1;
			--cambiamos a la siguiente direccion de inicio de la pelota para que continue el juego
					if(Ball_direction > 5) then
						Ball_direction <= 0; -- se reinicia el ciclo de direcciones cuando ya se usaron todas
					end if;
		
		elsif(ball_clk'event and ball_clk = '1') then
			--en cada flanco ascendente del reloj de velocidad de la pelota 
			case Ball_direction is
			
				-- Direcciones, 6 en total, 4 diagonales y 2 horizontales	
				--MODIFICAR
					--El orden que nos da es el de las manecillas del reloj de 0 a 5 
				--MODIFICAR			
				when 0 => Ball_pos_x <= Ball_pos_x + 1; 	--Diagonal hacia la derecha y abajo
							 Ball_pos_y <= Ball_pos_y - 1;

				when 1 => Ball_pos_x <= Ball_pos_x - 1;		--Diagonal hacia la izquierda y abajo
							 Ball_pos_y <= Ball_pos_y - 1;

				when 2 => Ball_pos_x <= Ball_pos_x - 1;		--Diagonal hacia la izquierda y arriba
							 Ball_pos_y <= Ball_pos_y + 1;

				when 3 => Ball_pos_x <= Ball_pos_x + 1;		--Diagonal hacia la derecha y arriba	
						    Ball_pos_y <= Ball_pos_y + 1;

				when 4 => Ball_pos_x <= Ball_pos_x + 1;		--Horizontal a la derecha

				when 5 => Ball_pos_x <= Ball_pos_x - 1;		--Horizontal a la izquierda

			end case;
			
			
			--Fisica de rebote en los bordes de las barras ---Verticales
			if(Ball_pos_y = 0) then	 --Si toca el borde superior la pelota			
				if(Ball_direction = 0) then -- y tiene una Diagonal hacia la derecha y abajo
					Ball_direction <= 3;	--rebota haciando una Diagonal hacia la derecha y arriba	
				elsif(Ball_direction = 1) then
					Ball_direction <= 2;
				end if;
			end if;
			
			if(Ball_pos_y = 480) then  --Si toca el borde inferior la pelota							
				if(Ball_direction = 2) then --si hace una Diagonal hacia la izquierda y arriba
					Ball_direction <= 1;	--rebota haciendo una Diagonal hacia la izquierda y abajo
				elsif(Ball_direction = 3) then
					Ball_direction <= 0;
				end if;
			end if;
			

			--Fisica de rebote en los bordes de las barras ---Horizontales
			if(Ball_pos_x = 0) then		--Si toca el borde izquierdo			
				if(Ball_direction = 1) then --Si venia en Diagonal hacia la izquierda y abajo
					Ball_direction <= 0;	--Rebota en Diagonal hacia la derecha y abajo
				elsif(Ball_direction = 2) then --Si venia en Diagonal hacia la izquierda y arriba
					Ball_direction <= 3;	   --Rebota en Diagonal hacia la derecha y arriba
				elsif(Ball_direction = 5) then --Si venia en Horizontal a la izquierda
					Ball_direction <= 4;	   --Horizontal a la derecha
				end if;
			end if;
			
			if(Ball_pos_x = 640) then		--Si toca el borde Derecho						
				if(Ball_direction = 0) then	--Si venia en Diagonal hacia la derecha y abajo
					Ball_direction <= 1;	--Rebota en Diagonal hacia la izquierda y abajo
				elsif(Ball_direction = 3) then  --Si venia en Diagonal hacia la derecha y arriba
					Ball_direction <= 2;		--Rebota en Diagonal hacia la izquierda y arriba
				elsif(Ball_direction = 4) then  --Si venia en Horizontal a la derecha
					Ball_direction <= 5;		--Rebota en Horizontal a la izquierda
				end if;
			end if;
			

			-- Fisicas de Rebote del balon con las raquetas de los jugadores
			--Rebote de balon en jugador 2
			if(Ball_pos_x + BallSize > paddle2_pos_x - PHsize) then 
			--si la pelota llega a la posicion horizontal de la raqueta del jugador 2
					if(Ball_pos_y - BallSize <= paddle2_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle2_pos_y - PVsize) then
						--Si la pelota esta en el rango vertical de la raqueta2
						if(Ball_pos_y >= paddle2_pos_y - 10 and
							Ball_pos_y <= paddle2_pos_y + 10) then
							--Si la pelota esta cerca del centro, va a rebotar horizontalmente 
								Ball_direction <= 5;
						else							
							if(Ball_direction = 0) then 
							--Si la pelota viene en Diagonal hacia la derecha y abajo
								Ball_direction <= 1; --Rebota en Diagonal hacia la izquierda y abajo
								
							elsif(Ball_direction = 3) then
							--Si la pelota viene en Diagonal hacia la derecha y arriba
								Ball_direction <= 2; --Rebota en Diagonal hacia la izquierda y arriba
							
							elsif(Ball_direction = 4) then
							--Si la pelota viene en Horizontal a la derecha
								if(Ball_pos_y > paddle2_pos_y) then
								--Si la pelota toca borde vertical del jugador 2 (borde superior)
									Ball_direction <= 2;--Rebota en Diagonal hacia la izquierda y arriba
								else--(borde inferior)
									Ball_direction <= 1;--Rebota en Diagonal hacia la izquierda y abajo
								end if;
							end if;
						end if;
					end if;
			end if;
			

			-- Fisicas de Rebote del balon con las raquetas de los jugadores
			--Rebote de balon en jugador 1
			if(Ball_pos_x - BallSize < paddle1_pos_x + PHsize) then
			--Si la pelota llega a la posicion horizontal de la raqueta del jugador 1
					if(Ball_pos_y - BallSize <= paddle1_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle1_pos_y - PVsize) then
						--Si la pelota esta en el rango vertical de la raqueta1
						if(Ball_pos_y >= paddle1_pos_y - 10 and
							Ball_pos_y <= paddle1_pos_y + 10) then
								--Si la pelota esta cerca del centro, va a rebotar horizontalmente
								Ball_direction <= 4;
						else							
							if(Ball_direction = 1) then
							--Si la pelota viene en Diagonal hacia la izquierda y abajo
								Ball_direction <= 0; --Rebota en Diagonal hacia la derecha y abajo
								
							elsif(Ball_direction = 2) then
							--Si la pelota viene en Diagonal hacia la izquierda y arriba
								Ball_direction <= 3;--Rebota en Diagonal hacia la derecha y arriba
							
							elsif(Ball_direction = 5) then
							--Si la pelota viene de forma horizontal hacia la izquierda
								if(Ball_pos_y > paddle1_pos_y) then
								--Si la pelota toca borde vertical del jugador 1 (borde superior)
									Ball_direction <= 3;--Rebota en Diagonal hacia la derecha y arriba
								else--(borde inferior)
									Ball_direction <= 0;--Rebota en Diagonal hacia la derecha y abajo
								end if;
							end if;
						end if;
					end if;
			end if;
			
		
		end if;
		
	end process;
	




	
	--Logica de la maquina de estados del videojuego
	process(pixel_clk, encendido) begin
		--Podemos ver que se ejecuta cuando pixel_clk, o encendido cambia
	
		if(encendido = '0') then 
		--Si se apaga el juego se reinician los estados del juego
			state <= S0;
			score1 <= 0;
			score2 <= 0;
		
		elsif(pixel_clk'event and pixel_clk = '1') then
		--Si estamos en un flanco ascendente del reloj de pixeles
			case state is
				when S0 => --Cuando estamos en el estado 0
					if(start_game = '0') then --Si no se inia el juego
						State <= S1; --Se espera que el jugador inicie el jeugo para continuar
					end if;

				when S1 =>--Cuando estamos en el estado 1
					
					--Si anota el jugador 2
					if(Ball_pos_x < 40) then--Si la pelota es anotada en la cancha izquierda
						State <= S0; --Se pausa el juego
						if(score2 = 9) then --Si el jugador 2 llego a 9 puntos
							--gano el juego y reiniciamos los marcadores
							score2 <= 0;
							score1 <= 0;
						else
							--Si no se ha ganado el juego, solo aumentamos el contador del jugador 2
							score2 <= score2 + 1;
						end if;
					end if;

					--Si anota el jugador 1
					if(Ball_pos_x > 600) then --Si la pelota es anotada en la cancha derecha 
						State <= S0; --Se pausa el juego
						if(score1 = 9) then --Si el jugador 1 llego a 9 puntos
							--gano el juego y reiniciamos los marcadores
							score1 <= 0;
							score2 <= 0;
						else
							--Si no se ha ganado el juego, solo aumentamos el contador del jugador 1
							score1 <= score1 + 1;
						end if;
					end if;
					
			end case;
		end if;
	end process;
	
	--Proceso que pausa o reanuda el juego
	process(State) begin
		--Cuando haya un cambio en el estado de la maquina de estados del juego
		
		case State is
			when S0 => --Si estamos en S0, asignamos 0 a mov, lo que pausa el juego
				move <= '0';

			when S1 => --Si estamos en S1, asignamos 1 a mov, lo que reanuda el juego
				move <= '1';
		end case;
	end process;




	
	--Proceso que se encarga de dibujar el juego en la pantalla
	process(paddle1_pos_x, paddle1_pos_y, 
			paddle2_pos_x, paddle2_pos_y, 
			dena, 
			row_counter, col_counter) begin
		
		--Si estamos en un area visible de la pantalla VGA para poder dibujar
		if(dena = '1') then
		
			--En caso de que estemos en un area perteneciente al jugador 1
			 if((paddle1_pos_x <= col_counter + PHsize) and
				(paddle1_pos_x + PHsize >= col_counter) and
				(paddle1_pos_y <= row_counter + PVsize) and
				(paddle1_pos_y + PVsize >= row_counter)) or
				
			--En caso de que estemos en un area perteneciente al jugador 2
				((paddle2_pos_x <= col_counter + PHsize) and
				(paddle2_pos_x + PHsize >= col_counter) and
				(paddle2_pos_y <= row_counter + PVsize) and
				(paddle2_pos_y + PVsize >= row_counter)) or
				
			--En caso de que estemos en un area perteneciente a la Pelota
				((Ball_pos_x <= col_counter + BallSize) and
				(Ball_pos_X + BallSize >= col_counter) and
				(Ball_pos_y <= row_counter + BallSize) and
				(Ball_pos_y + BallSize >= row_counter))	then
				
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
		
			-- If dena = 0, no color has to be displayed
		
			R <= (others => '0');
			G <= (others => '0');
			B <= (others => '0');
			
		end if;
		
	end process;

end image_generator_arch;
			
