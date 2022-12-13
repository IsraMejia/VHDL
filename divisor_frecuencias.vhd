library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencias is
    port(
        reloj :     in std_logic;
        switches:   in std_logic_vector(3 downto 0);--Switchers
        clk:  out std_logic
    );
end divisor_frecuencias;

architecture div of divisor_frecuencias is
    signal periodo_en_alto : integer range 0 to 100000;
    constant periodo_MAXIMO: integer:= 100000;
    signal contador : integer range 0 to 100000;

begin
    --Definimos los periodos en alto acorde 
    --a las entradas dadas con los switches
    with switches select periodo_en_alto <=
        8000    when "0001",
        15000   when "0010",
        37000   when "0011",
        66000   when "0100",
        88000   when "0101",
        100 	 when others;

    process (reloj) --Cuando cambie el valor del reloj
        begin
            if rising_edge(reloj) then 
            --Si esta en flanco ascendente el reloj

                if contador < periodo_MAXIMO then 
                    contador <= contador +1;
                    --Aumenta el contador(la señal)
                else 
                    contador <= 0; --Reiniciaos el contador
                end if;

                if contador < periodo_en_alto then 
                    clk <= '1';
                else 
                    clk <= '0';
                end if;

            end if ;
        end process;
end architecture div;