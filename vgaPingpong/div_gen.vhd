--Esta entidad es capaz de recibir la un divisor a la que se desea generar 
--una nueva señal de salida, en otras palaras en un divisor de frecuencias

library ieee;
use ieee.std_logic_1164.all;

entity divisor_frec is

	generic( divisor : integer:= 2);-- variable local --415000 este es el actual
	--divisor de frecuencias, entre menor sea el numero mas rapido va la pelota
	port( 	
		reloj_entrada 	: in std_logic;
		encendido 		: in std_logic;
		reloj_salida: out std_logic
	);
			
end divisor_frec;

architecture divisor_frec_bhv of divisor_frec is

	signal ContadorAscendente : integer range 0 to ( (divisor/2)-1 ); --ContadorDeFlancosAscendentes
		--Va desde 0 hasta el franco ascendente donde se niega la señal a dividir
	signal temporal: std_logic;

begin

	process(reloj_entrada, encendido)
		 
	begin
		
		if(encendido = '0') then --encendido = apagado
			ContadorAscendente <= 0; --contadorascendente 
			temporal  <= '0'; --reloj de salida necesario 
			
		elsif(reloj_entrada'event and reloj_entrada = '1') then 
		--Si tenemos el juego encendido y a su vez el estado del reloj esta en 1 (flanco ascendente)
			if(ContadorAscendente = ((divisor/2)-1)) then 
		    --Cuando sea el momento de negar la señal de entrada para obtener la frecuencia deseada
			-- se resta "-1" en la relacion de frecuencias, para que antes de que se produzca el próximo flanco de subida en "reloj_entrada". se realice el codigo a continuacion
			  temporal<= not temporal;-- negamos el estado del reloj temporaloral que seria de nuestra nueva frecuencia
			  ContadorAscendente <= 0; --reiniciamos el contador de flancos ascendentes de la señal original
			else
			  ContadorAscendente <= ContadorAscendente+1; 
			  --seguimos contando si un no es el momento de hacer lo anterior
			end if;
		end if;

	end process;
	
	reloj_salida <= temporal;
	
end divisor_frec_bhv;