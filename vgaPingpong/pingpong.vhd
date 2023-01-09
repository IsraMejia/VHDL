--Este archivo, es el top en cuanto a jerarquia del proyecto, 
--se encarga de crear e instanciar los componentes de todas las entidades 
--involucradas en la creacion del juego, y la interaccion necesaria entre cada una de ellas 

library ieee;
use ieee.std_logic_1164.all;

entity PINGPONG is
	generic(
	
		div:integer := 2; --divisor de frecuencia por defecto
		div_paddle : integer := 200000; --velocidad  jugadores 	(divisor de frecuencia)	
		div_ball : integer 	 := 415000; --velocidad pelota (divisor de frecuencia)	

		--div_ball2 : integer := 370000;
		--div_ball3 : integer := 310000;
		--div_ball4 : integer := 250000;
	
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
	);

	port(
		clk : in std_logic; --Reloj de 50Mhz de la FPGA DE10-Lite
		encendido: in std_logic;--Si esta encendido el juego o no 
		
		Hsync	: buffer std_logic; -- Horizontal sync pulse. señal de sincronizacion horizontal
		Vsync	: buffer std_logic; -- Vertical sync pulse. señal de sincronizacion vertical

		direction_switch : in std_logic_vector(1 downto 0); --Switches/controles de cada jugador
		start_game		: in std_logic; --Bit de control para saber si el juego ha iniciado
		seg1 	: out std_logic_vector(6 downto 0);
		seg2	: out std_logic_vector(6 downto 0);
		bar		: out std_logic;
		
		ball_speed : in std_logic_vector(1 downto 0);
		--cambiar a std_logic
		
		--Vectores RGB para los colores al momento de dibujar la interfaz del juego en el monitor VGA
		R, G, B 		 : out std_logic_vector(3 downto 0)
	);

end entity PINGPONG;



architecture PINGPONG_arch of PINGPONG is

	--Relojes de imagenes
	pixel_clk 		 : in std_logic;--Señal de reloj para contar los píxeles
	paddle_clk		 : in std_logic;--Señal de reloj para las raquetas
	ball_clk	     : in std_logic;--Señal de reloj para el balon
	
	Hactive : in std_logic; --indican cuando los píxeles deben ser mostrados en la pantalla.
	-- '1' durante el período de actividad horizontal y '0' el resto del tiempo
	Vactive : in std_logic;--indica cuando una línea de píxeles deben ser mostradas en la pantalla.
	-- '1' durante el período de actividad vertical y '0' el resto del tiempo.
	dena : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
	
	signal score1  : integer;
	signal score2  : integer;


	--Componente que genera los relojes que se ocupan para el juego
	component div_gen is		
		generic( 
			div 	 : integer:= 2
		);		
		port( 	
			reloj_entrada 	: in std_logic;
			encendido 		: in std_logic;
			reloj_salida: out std_logic
		);	
	end component div_gen;
	

	--Componente para controlar el monitor VGA
	component sync_generator is
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
			-- '1' durante el período de actividad horizontal y '0' el resto del tiempo.
			Vactive : buffer std_logic; --indica cuando una línea de píxeles deben ser mostradas en la pantalla.
			-- '1' durante el período de actividad vertical y '0' el resto del tiempo.

			dena : out std_logic --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
		);
	end component sync_generator;



	
	component image_generator is	
		--Aqui se define el tamaño final de la pelota
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
		); --TAMAÑO DE LA PELOTA
		
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
			dena  : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla

			direction_switch : in std_logic_vector(1 downto 0); --Switches/controles de cada jugador
			start_game		 : in std_logic;	--Bit de control para saber si el juego ha iniciado
			score1			 : buffer integer;
			score2			 : buffer integer;
			
			--puertos de colores
			R,G,B			 : out std_logic_vector(3 downto 0))
			
		);
	end component image_generator;


	--Componente para mostrar el marcador en pantalla
	component score_display is
		port(
			score1   : in integer;--marcador jugador1
			score2   : in integer;--marcador jugador2
			seg1	 : out std_logic_vector(6 downto 0);--display 7S Jugador1
			seg2	 : out std_logic_vector(6 downto 0);--display 7S Jugador2
			bar	 	 : out std_logic --Barra del score	
		);
	end component;
	
	--Pin assignments
	--borrar y escribir en el trabajo escrito porque usamos cada pin 
		attribute chip_pin : string;
		
		attribute chip_pin of clk	       : signal is "N14";
		attribute chip_pin of encendido	   : signal is "F15";
		
		attribute chip_pin of direction_switch : signal is "C10,C11,C12,A12";
		attribute chip_pin of start_game       : signal is "B8";
		
		
		attribute chip_pin of Hsync	       : signal is "N3";
		attribute chip_pin of Vsync	       : signal is "n1";
		
		attribute chip_pin of R		       : signal is "AA1, V1, Y2, Y1";
		attribute chip_pin of G		       : signal is "W1, T2, R2, R1";
		attribute chip_pin of B		       : signal is "P1, T1, P4, N2";
		
		attribute chip_pin of seg1	       : signal is "B22,C22,B21,A21,B19,A20,B20";
		attribute chip_pin of seg2	       : signal is "C17,D17,E16,C16,C15,E15,C14";
		attribute chip_pin of bar	       : signal is "B17";
		
		attribute chip_pin of ball_speed   : signal is "B14,A14";
	----borrar y escribir en el trabajo escrito porque usamos cada pin 
			

begin

	----Mapeando puertos para el divisor de frecuencias que nos de el reloj de control de pixeles
	U0: div_gen	 
		generic map (div => div)
		port map(clk_in => clk,  encendido => encendido,   clk_out => pixel_clk)
	;
	
	--Mapeando puertos para Sincronizar la imagen del monitor VGA pixel a pixel
	u1: sync_generator	
		generic map(
			Ha => Ha,
			Hb => Hb,
			Hc => Hc,
			Hd => Hd,
			Va => Va,
			Vb => Vb,
			Vc => Vc,
			Vd => Vd
		)						
		port map(
			pixel_clk 	=> pixel_clk,
			encendido	=> encendido,
			Hsync		=> Hsync,
			Vsync		=> Vsync,
			Hactive		=> Hactive,
			Vactive		=> Vactive,
			dena 		=> dena
		)
	;
					

	--Mapeando puertos para poder Dibujar en pantalla el videojuego
	u2: image_generator	
		generic map(
			Ha => Ha,
			Hb => Hb,
			Hc => Hc,
			Hd => Hd,
			Va => Va,
			Vb => Vb,
			Vc => Vc,
			Vd => Vd,
			PVsize => paddlesizeV,
			PHsize => paddlesizeH
		)		
		port map(	
			pixel_clk	=> pixel_clk,
			paddle_clk	=> paddle_clk,
			ball_clk	=> ball_clk,
			encendido	=> encendido,
			Hactive		=> Hactive,
			Vactive 	=> Vactive,
			Hsync		=> Hsync,
			Vsync		=> Vsync,
			dena		=> dena,
			direction_switch=> direction_switch,
			start_game	=> start_game,
			score1		=> score1,
			score2		=> score2,
			R		    => R,
			G			=> G,
			B			=> B
		)
	;
				
	
	--Mapeando puertos para el reloj de los jugadores
	u3: div_gen 
		generic map (div => div_paddle)
		port map(clk_in => clk, encendido => encendido, clk_out => paddle_clk)
	;
	
	----Mapeando puertos para el reloj de la pelota
	u5: div_gen
		generic map (div => div_ball)
		port map(clk_in => clk, encendido => encendido, clk_out => ball_clk)
	;
	
	----Mapeando puertos para mostrar en pantalla los marcadores
	u4: score_display
		port map(score1 => score1, score2 => score2, seg1 => seg1, bar1 => bar1, bar2 => bar2, seg2 => seg2 )
	;
	
	--borrar
		--u6: div_gen
		--	generic map (div => div_ball2)
		--	port map(clk_in => clk, encendido => encendido, clk_out => ball_clk2);
			
		--u7: div_gen
		--	generic map (div => div_ball3)
		--	port map(clk_in => clk, encendido => encendido, clk_out => ball_clk3);
			
		--u8: div_gen
		--	generic map (div => div_ball4)
		--	port map(clk_in => clk, encendido => encendido, clk_out => ball_clk4);
	--xd
	
	
		
	
	--Multiplexor to choose the speed of the ball
		--process(ball_speed)
		--begin		
		--	case ball_speed is
		--		when "00" => ball_clk <= ball_clk1;
		--		when "01" => ball_clk <= ball_clk2;
		--		when "10" => ball_clk <= ball_clk3;
		--		when others => ball_clk <= ball_clk4;
		--	end case;
		--end process;

	--Escribir multplexor para seleccionar color de los jugadores
					
					
end PINGPONG_arch;