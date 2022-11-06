--Sumador Serial
-- dos vectores, dos variables, con salida de 5 bits y posible acarreo de entrada

library ieee;
use ieee.std_logic_1164.all;

entity pmsum is
    port( 
        x,y : in std_logic_vector(3 downto 0);
        ci:   in std_logic;
        su:   out std_logic_vector(4 downto 0) --Salidas
			--5bit mas significativo es el carry final
    );
end;

architecture bhv of pmsum is
    component fa is --La entidad de sumador normal lo convertimos en un componente de la arquitectura
        port( 
            a,b, ci : in std_logic;
            co, s: out std_logic
        );
    end component;

    signal ac: std_logic_vector(2 downto 0); --Señal de puente entre cada suma del sumador serial

begin
    u1: fa Port Map ( a => x(0) , b => y(0), ci => ci , co =>ac(0) , s => su(0) ) ;
    --conectando con el archivo del sumador normal,  
    --Bit A del sumador al bit menos significativo de X, ...., El Acarreo de salida Co se coloca en el bit menos significativo de la señal AC

    u2: fa Port Map ( a => x(1) , b => y(1), ci => ac(0) , co =>ac(1) , s => su(1) ) ; 
    u3: fa Port Map ( a => x(2) , b => y(2), ci => ac(1) , co =>ac(2) , s => su(2) ) ; 
    u4: fa Port Map ( a => x(3) , b => y(3), ci => ac(2) , co =>su(4) , s => su(3) ) ; --co en su(4) ya que es parte del resultado
	 		
end;
