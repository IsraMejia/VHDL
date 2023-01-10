--Este archivo contiene los decodificadores que van a mostrar el marcador 
--en los displays de 7 segmentos

library ieee;
use ieee.std_logic_1164.all;

entity marcador_dss is

	port(
			marcador_j1 : in integer;	--score en decimal del jugador 1 
			marcador_j2 : in integer;	--score en decimal del jugador 2 

			seg_marcador_j1	 : out std_logic_vector(6 downto 0); -- 7 segmentos del marcador 1
			separador1_marcador	 : out std_logic; 	--barra que divide los marcadores de cada jugador
			separador2_marcador	 : out std_logic; 	--barra que divide los marcadores de cada jugador
			seg_marcador_j2	 : out std_logic_vector(6 downto 0) -- 7 segmentos del marcador 1
			
	);  
			
end marcador_dss;

architecture marcador_dss_bhv of marcador_dss is

begin
	--Asignamos barras que dividen los marcadores
	separador1_marcador <= '0';
	separador2_marcador <= '0';

	--decodificador del marcador 1
	with marcador_j1 select
		seg_marcador_j1 <= "1000000" when 0, --Cuando el marcador sea 0, mostrarlo en el display del jugador1
				"1111001" when 1, --Cuando el marcador sea 1, mostrarlo en el display del jugador1
				"0100100" when 2, --Cuando el marcador sea 2, mostrarlo en el display del jugador1 
				"0110000" when 3, --Cuando el marcador sea 3, mostrarlo en el display del jugador1
				"0011001" when 4, --Cuando el marcador sea 4, mostrarlo en el display del jugador1
				"0010010" when 5, --Cuando el marcador sea 5, mostrarlo en el display del jugador1
				"0000010" when 6, --Cuando el marcador sea 6, mostrarlo en el display del jugador1
				"1111000" when 7, --Cuando el marcador sea 7, mostrarlo en el display del jugador1
				"0000000" when 8, --Cuando el marcador sea 8, mostrarlo en el display del jugador1
				"0010000" when 9, --Cuando el marcador sea 9, mostrarlo en el display del jugador1 
				"0010010" when others;
	
	--decodificador del marcador 2
	with marcador_j2 select
		seg_marcador_j2 <= "1000000" when 0, --Cuando el marcador sea 0, mostrarlo en el display del jugador2
				"1111001" when 1, --Cuando el marcador sea 1, mostrarlo en el display del jugador2
				"0100100" when 2, --Cuando el marcador sea 2, mostrarlo en el display del jugador2 
				"0110000" when 3, --Cuando el marcador sea 3, mostrarlo en el display del jugador2
				"0011001" when 4, --Cuando el marcador sea 4, mostrarlo en el display del jugador2
				"0010010" when 5, --Cuando el marcador sea 5, mostrarlo en el display del jugador2
				"0000010" when 6, --Cuando el marcador sea 6, mostrarlo en el display del jugador2
				"1111000" when 7, --Cuando el marcador sea 7, mostrarlo en el display del jugador2
				"0000000" when 8, --Cuando el marcador sea 8, mostrarlo en el display del jugador2
				"0010000" when 9, --Cuando el marcador sea 9, mostrarlo en el display del jugador2 
				"0010010" when others;
		
end marcador_dss_bhv;