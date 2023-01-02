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

	signal Qt : integer range 0 to ((div/2)-1);
	signal temp: std_logic;

begin

	process(clk_in, encendido)
		 
	begin
		
		if(encendido = '0') then --encendido = apagado
			Qt <= 0; --qt ayuda a que no sea un desastre todo , se pone super rapido el juego
			temp  <= '0'; --reloj de salida necesario 
			
		elsif(clk_in'event and clk_in = '1') then 
		--Si tenemos el juego encendido y a su vez el estado del reloj esta en 1
			
			if(Qt = ((div/2)-1)) then 
			  temp<= not temp;-- negamos el estado del reloj y lo guardamos en temporal
			  	-- Al saber que la entrada es de 50MHz -> nos dara una señal de 25MHz
			  Qt <= 0;
			else
			  Qt <= Qt+1;
			end if;
		end if;

	end process;
	
	clk_out <= temp;
	
end div_gen_arch;