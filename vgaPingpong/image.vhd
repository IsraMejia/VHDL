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
				--Si estamos en un nuevo flanco ascendente del reloj de las raquetas??????????
				paddle1_pos_x <= 50;
				paddle2_pos_x <= 590;
				
				--Movement paddle 1
				
				if(direction_switch(0) = '1') then
					if(paddle1_pos_y = Vc - Vb) then
						paddle1_pos_y <= 0;
					else paddle1_pos_y <= paddle1_pos_y + 1;
					end if;
				end if;
				
				if(direction_switch(1) = '1') then
					if(paddle1_pos_y = 0) then
						paddle1_pos_y <= Vc - Vb;
					else paddle1_pos_y <= paddle1_pos_y - 1;
					end if;
				end if;
				
				--Movement paddle 2
				
				if(direction_switch(2) = '1') then
					if(paddle2_pos_y = Vc - Vb) then
						paddle2_pos_y <= 0;
					else paddle2_pos_y <= paddle2_pos_y + 1;
					end if;
				end if;
				
				if(direction_switch(3) = '1') then
					if(paddle2_pos_y = 0) then
						paddle2_pos_y <= Vc - Vb;
					else paddle2_pos_y <= paddle2_pos_y - 1;
					end if;
			end if;
			
		end if;
		
	end process;




	
	---Position and direction of the ball-----------
	
	process(ball_clk, encendido, Ball_direction, move)
	
	begin
	
		if(encendido = '0' or move = '0') then
			Ball_pos_x <= 320;
			Ball_pos_y <= 240;
			
			Ball_direction <= Ball_direction + 1;
					if(Ball_direction > 5) then
						Ball_direction <= 0;
					end if;
		
		elsif(ball_clk'event and ball_clk = '1') then
			
			case Ball_direction is
			
				-- Direcciones, 6 en total, 4 diagonales y 2 horizontales
				
				when 0 => Ball_pos_x <= Ball_pos_x + 1;
							 Ball_pos_y <= Ball_pos_y - 1;

				when 1 => Ball_pos_x <= Ball_pos_x - 1;
							 Ball_pos_y <= Ball_pos_y - 1;

				when 2 => Ball_pos_x <= Ball_pos_x - 1;
							 Ball_pos_y <= Ball_pos_y + 1;

				when 3 => Ball_pos_x <= Ball_pos_x + 1;
						    Ball_pos_y <= Ball_pos_y + 1;

				when 4 => Ball_pos_x <= Ball_pos_x + 1;

				when 5 => Ball_pos_x <= Ball_pos_x - 1;

			end case;
			
			--Bounce with the board edges
			if(Ball_pos_y = 0) then
				
				if(Ball_direction = 0) then
					Ball_direction <= 3;
				elsif(Ball_direction = 1) then
					Ball_direction <= 2;
				end if;
			end if;
			
			if(Ball_pos_y = 480) then
				
				if(Ball_direction = 2) then
					Ball_direction <= 1;
				elsif(Ball_direction = 3) then
					Ball_direction <= 0;
				end if;
			end if;
			
			if(Ball_pos_x = 0) then
				
				if(Ball_direction = 1) then
					Ball_direction <= 0;
				elsif(Ball_direction = 2) then
					Ball_direction <= 3;
				elsif(Ball_direction = 5) then
					Ball_direction <= 4;
				end if;
			end if;
			
			if(Ball_pos_x = 640) then
				
				if(Ball_direction = 0) then
					Ball_direction <= 1;
				elsif(Ball_direction = 3) then
					Ball_direction <= 2;
				elsif(Ball_direction = 4) then
					Ball_direction <= 5;
				end if;
			end if;
			
			--Bounces with the paddles
			-- Rebote con los jugadores
			if(Ball_pos_x + BallSize > paddle2_pos_x - PHsize) then
					if(Ball_pos_y - BallSize <= paddle2_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle2_pos_y - PVsize) then
						
						if(Ball_pos_y >= paddle2_pos_y - 10 and
							Ball_pos_y <= paddle2_pos_y + 10) then
								Ball_direction <= 5;
						else
							
							if(Ball_direction = 0) then
								Ball_direction <= 1;
								
							elsif(Ball_direction = 3) then
								Ball_direction <= 2;
							
							elsif(Ball_direction = 4) then
								if(Ball_pos_y > paddle2_pos_y) then
									Ball_direction <= 2;
								else
									Ball_direction <= 1;
								end if;
							end if;
						end if;
					end if;
			end if;
			
			if(Ball_pos_x - BallSize < paddle1_pos_x + PHsize) then
					if(Ball_pos_y - BallSize <= paddle1_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle1_pos_y - PVsize) then
						
						if(Ball_pos_y >= paddle1_pos_y - 10 and
							Ball_pos_y <= paddle1_pos_y + 10) then
								Ball_direction <= 4;
						else
							
							if(Ball_direction = 1) then
								Ball_direction <= 0;
								
							elsif(Ball_direction = 2) then
								Ball_direction <= 3;
							
							elsif(Ball_direction = 5) then
								if(Ball_pos_y > paddle1_pos_y) then
									Ball_direction <= 3;
								else
									Ball_direction <= 0;
								end if;
							end if;
						end if;
					end if;
			end if;
			
		
		end if;
		
	end process;
	




	---State Machine of the game-----------------
	process(pixel_clk, encendido)
	begin
	
		if(encendido = '0') then
			state <= S0;
			score1 <= 0;
			score2 <= 0;
		
		elsif(pixel_clk'event and pixel_clk = '1') then
			case state is
				when S0 =>
					if(start_game = '0') then
						State <= S1;
					end if;

				when S1 =>
					if(Ball_pos_x < 40) then
						State <= S0;
						if(score2 = 4) then
							score2 <= 0;
							score1 <= 0;
						else
							score2 <= score2 + 1;
						end if;
					end if;
					if(Ball_pos_x > 600) then
						State <= S0;
						if(score1 = 4) then
							score1 <= 0;
							score2 <= 0;
						else
							score1 <= score1 + 1;
						end if;
					end if;
					
			end case;
		end if;
	end process;
	
	process(State)
	begin
	case State is
		when S0 => move <= '0';
		when S1 => move <= '1';
	end case;
	end process;
	
	---Image generator--------------------
	process(paddle1_pos_x, paddle1_pos_y, paddle2_pos_x, paddle2_pos_y, dena, row_counter, col_counter)
	
	begin
		
		--Signal that enables to display data on the screen
		if(dena = '1') then
		
				 -- Paddle 1 detection
			 if((paddle1_pos_x <= col_counter + PHsize) and
				(paddle1_pos_x + PHsize >= col_counter) and
				(paddle1_pos_y <= row_counter + PVsize) and
				(paddle1_pos_y + PVsize >= row_counter)) or
				
				 -- Paddle 2 detection
				((paddle2_pos_x <= col_counter + PHsize) and
				(paddle2_pos_x + PHsize >= col_counter) and
				(paddle2_pos_y <= row_counter + PVsize) and
				(paddle2_pos_y + PVsize >= row_counter)) or
				
				 -- Ball detection
				((Ball_pos_x <= col_counter + BallSize) and
				(Ball_pos_X + BallSize >= col_counter) and
				(Ball_pos_y <= row_counter + BallSize) and
				(Ball_pos_y + BallSize >= row_counter))	then
				
					-- Paddle and ball color
					
					R <= "1110";
					G <= "1110";
					B <= "0000";
				
			else
				
					-- Background color
			
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
			
