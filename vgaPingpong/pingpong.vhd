--Este archivo, es el top en cuanto a jerarquia del proyecto, 
--se encarga de crear e instanciar los componentes de todas las entidades 
--involucradas en la creacion del juego, y la interaccion necesaria entre cada una de ellas 

library ieee;
use ieee.std_logic_1164.all;

entity PINGPONG is
	generic(
	
		divisor:integer := 2; --divisor de frecuencia por defecto
		div_paddle : integer := 200000; --velocidad  jugadores 	(divisor de frecuencia)	
		div_ball : integer 	 := 415000; --velocidad pelota (divisor de frecuencia)	
	
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
		TotalVertical: integer := 525 --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
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
		seg_marcador_j1 	: out std_logic_vector(6 downto 0);
		seg_marcador_j2	: out std_logic_vector(6 downto 0);
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
	habilitador : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
	
	signal marcador_j1  : integer;
	signal marcador_j2  : integer;


	--Componente que genera los relojes que se ocupan para el juego
	component divisor_frec is		
		generic( 
			divisor 	 : integer:= 2
		);		
		port( 	
			reloj_entrada 	: in std_logic;
			encendido 		: in std_logic;
			reloj_salida: out std_logic
		);	
	end component divisor_frec;
	

	--Componente para controlar el monitor VGA
	component controlador_vga is
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
			TotalVertical: integer := 525 --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
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

			habilitador : out std_logic --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla
		);
	end component controlador_vga;



	
	component image_generator is	
		--Aqui se define el tamaño final de la pelota
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
			TotalVertical: integer := 525 --Ancho total de la señal vertical en líneas de píxeles o ciclos (visibles o no visibles)
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
			habilitador  : in std_logic; --1 cuando Hactive y Vactive son 1 -> mostrar pixeles en pantalla

			direction_switch : in std_logic_vector(1 downto 0); --Switches/controles de cada jugador
			start_game		 : in std_logic;	--Bit de control para saber si el juego ha iniciado
			marcador_j1			 : buffer integer;
			marcador_j2			 : buffer integer;
			
			--puertos de colores
			R,G,B			 : out std_logic_vector(3 downto 0))
			
		);
	end component image_generator;


	--Componente para mostrar el marcador en pantalla
	component marcador_dss is
		port(
			marcador_j1 : in integer;	--score en decimal del jugador 1 
			marcador_j2 : in integer;	--score en decimal del jugador 2 

			seg_marcador_j1	 : out std_logic_vector(6 downto 0); -- 7 segmentos del marcador 1
			separador1_marcador	 : out std_logic; 	--barra que divide los marcadores de cada jugador
			separador2_marcador	 : out std_logic 	--barra que divide los marcadores de cada jugador
			seg_marcador_j2	 : out std_logic_vector(6 downto 0); -- 7 segmentos del marcador 1
			
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
		
		attribute chip_pin of seg_marcador_j1	       : signal is "B22,C22,B21,A21,B19,A20,B20";
		attribute chip_pin of seg_marcador_j2	       : signal is "C17,D17,E16,C16,C15,E15,C14";
		attribute chip_pin of bar	       : signal is "B17";
		
		attribute chip_pin of ball_speed   : signal is "B14,A14";
	----borrar y escribir en el trabajo escrito porque usamos cada pin 
			

begin

	----Mapeando puertos para el divisor de frecuencias que nos de el reloj de control de pixeles
	U0: divisor_frec	 
		generic map (divisor => divisor)
		port map(reloj_entrada => clk,  encendido => encendido,   reloj_salida => pixel_clk)
	;
	
	--Mapeando puertos para Sincronizar la imagen del monitor VGA pixel a pixel
	u1: controlador_vga	
		generic map(
			Psh => Psh,
			Ihv => Ihv,
			Fhv => Fhv,
			TotalHorizontal => TotalHorizontal,
			Psv => Psv,
			Ivv => Ivv,
			Fvv => Fvv,
			TotalVertical => TotalVertical
		)						
		port map(
			pixel_clk 	=> pixel_clk,
			encendido	=> encendido,
			Hsync		=> Hsync,
			Vsync		=> Vsync,
			Hactive		=> Hactive,
			Vactive		=> Vactive,
			habilitador 		=> habilitador
		)
	;
					

	--Mapeando puertos para poder Dibujar en pantalla el videojuego
	u2: image_generator	
		generic map(
			Ha => Ha,
			Ihv => Ihv,
			Fhv => Fhv,
			TotalHorizontal => TotalHorizontal,
			Psv => Psv,
			Ivv => Ivv,
			Fvv => Fvv,
			TotalVertical => TotalVertical,
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
			habilitador		=> habilitador,
			direction_switch=> direction_switch,
			start_game	=> start_game,
			marcador_j1		=> marcador_j1,
			marcador_j2		=> marcador_j2,
			R		    => R,
			G			=> G,
			B			=> B
		)
	;
				
	
	--Mapeando puertos para el reloj de los jugadores
	u3: divisor_frec 
		generic map (divisor => divisor_paddle)
		port map(reloj_entrada => clk, encendido => encendido, reloj_salida => paddle_clk)
	;
	
	----Mapeando puertos para el reloj de la pelota
	u5: divisor_frec
		generic map (divisor => divisor_ball)
		port map(reloj_entrada => clk, encendido => encendido, reloj_salida => ball_clk)
	;
	
	----Mapeando puertos para mostrar en pantalla los marcadores
	u4: marcador_dss
		port map(marcador_j1 => marcador_j1, marcador_j2 => marcador_j2, seg_marcador_j1 => seg_marcador_j1, separador1_marcador => separador1_marcador, separador2_marcador => separador2_marcador, seg_marcador_j2 => seg_marcador_j2 )
	;
	

		
	
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