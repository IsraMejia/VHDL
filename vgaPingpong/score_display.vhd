--Este archivo contiene los decodificadores que van a mostrar el marcador 
--en los displays de 7 segmentos

library ieee;
use ieee.std_logic_1164.all;

entity score_display is

	port(
			score1 : in integer;	--score en decimal del jugador 1 
			score2 : in integer;	--score en decimal del jugador 2 

			seg1	 : out std_logic_vector(6 downto 0); -- 7 segmentos del marcador 1
			bar1	 : out std_logic; 	--barra que divide los marcadores de cada jugador
			bar2	 : out std_logic 	--barra que divide los marcadores de cada jugador
			seg2	 : out std_logic_vector(6 downto 0); -- 7 segmentos del marcador 1
			
	);
			
end score_display;

architecture score_display_arch of score_display is

begin
	--Asignamos barras que dividen los marcadores
	bar1 <= '0';
	bar2 <= '0';

	--decodificador del marcador 1
	with score1 select
		seg1 <= "1000000" when 0, --Cuando el marcador sea 0, mostrarlo en el display del jugador1
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
	with score2 select
		seg2 <= "1000000" when 0, --Cuando el marcador sea 0, mostrarlo en el display del jugador2
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
		
end score_display_arch;