library ieee;
use ieee.std_logic_1164.all;

--Entity to get a fraction of the fundamental clock frequency

entity div_gen is

	generic( div 	      : integer:= 2);-- variable local --415000 este es el actual
	--divisor de frecuencias, entre menor sea el numero mas rapido va la pelota
	--creo que cambia con las entradas, aumenta la velocidad de la pelota 

	port( 	
		clk_in, encendido : in std_logic;
		clk_out: out std_logic
	);
			
end div_gen;

architecture div_gen_arch of div_gen is

	signal ContadorAscendente : integer range 0 to ((div/2)-1); --ContadorDeFlancosAscendentes
	signal temp: std_logic;

begin

	process(clk_in, encendido)
		 
	begin
		
		if(encendido = '0') then --encendido = apagado
			ContadorAscendente <= 0; --contadorascendente ayuda a que no sea un desastre todo , se pone super rapido el juego
			temp  <= '0'; --reloj de salida necesario 
			
		elsif(clk_in'event and clk_in = '1') then 
		--Si tenemos el juego encendido y a su vez el estado del reloj esta en 1 (flanco ascendente)
			if(ContadorAscendente = ((div/2)-1)) then 
				--Cuando sea el momento de negar la señal de entrada para obtener 
				--la frecuencia deseada
			  temp<= not temp;-- negamos el estado del reloj temporal que seria de nuestra nueva frecuencia
			  ContadorAscendente <= 0; --reiniciamos el contador de flancos ascendentes de la señal original
			else
			  ContadorAscendente <= ContadorAscendente+1; --seguimos contando si un no es el momento de hacer lo anterior
			end if;
		end if;

	end process;
	
	clk_out <= temp;
	
end div_gen_arch;