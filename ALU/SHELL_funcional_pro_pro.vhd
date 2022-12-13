library ieee;
use ieee.std_logic_1164.all;

--sell en realidad ese esl nombre de la entidad
entity SHELL is 
--La entidad shell integra la unidad aritmetica y la logica 
--el elemento m es el multiplexor que decide si la operacion es aritmetica o logica
    port(
        x, y: in std_logic_vector(3 downto 0); -- entrada
        
        sels: in std_logic_vector(3 downto 0); 
        --(s1,   s0,  ci,  m) orden de los bits --m= logico o aritmetico
     --sels(3), (2), (1), (0)
        
        --r: out std_logic_vector(4 downto 0) 
        -- salida original de 5 bits 

        -- salida pasada por el decodificador para mostrar 
        --resultados en 2 displays de 7 segmentos
		salidasegmentos: out std_logic_vector(13 downto 0) 


    );
end;

architecture bhv of SHELL is
    --Declaracion de componentes
    component PMsum is 
        port(
                x,y:    in std_logic_vector(3 downto 0);
                S1,S0:  in std_logic;
                ci:     in std_logic;
                su:    out std_logic_vector(4 downto 0)
        );
    end component;

    component UA is 
        port(
            S0,S1,b: in std_logic;
            Ni:     out std_logic
        );
    end component;

    component UL is 
        port(
            x, y: in std_logic_vector(3 downto 0); -- entrada
            sel:  in std_logic_vector(2 downto 0); --utilisamos 2 lineas de seleccion 
            l:   out std_logic_vector(3 downto 0) -- salida proporcional a la entrada
        );
    end component;

    
    component segmentos is 
        port(
                segmento:    out std_logic_vector( 13 downto 0);
                interruptor: in  std_logic_vector( 4 downto 0)
        );
    end component;
    

    --Declaracion de señales
    --una señal es un cable intermedio en nuestro circuito, 
    --las salidas de los componentes que usamos como entradas
    signal f,g , result: std_logic_vector(4 downto 0); 
    --para asignar la nueva salida en 16 bits
    signal displays: std_logic_vector(13 downto 0);  

begin
    
    u1 : PMsum  port map (
        --x y y tienen relacion 1 a 1 con la entidad
        x => x, y=>y, 
        --s1 = sels[s1] , s0 = sels[s0] , ci = sels[ci]
        s1 => sels(3), s0 => sels(2), ci => sels(1),
        --su se conecta con el vector f
        su => f
    ) ;

    
    u2 : ul port map( 
            x => x, y=>y, 
            --sel2=s1,         sel1=s0,           sel0=ci
            sel(2) => sels(3), sel(1) => sels(2), sel(0) => sels(1), 
            --la salida de la unidad logica 'l' lo conectamos con g 
            --desde el vetor 3 al 4 (salida y entrada de la misma longitud)
            l => g(3 downto 0)   
    ) ;
    g(4) <= '0'; --definimos el bit mas significativo de G 
    --r <= f when sels(0) = '0' else g; -- m = '0' g<-f else r<-g 
    
    -- r no va a recibir esto, 
    --sino interruptor del componente segmentos y este dara la salida en 16bits
    result <= f when sels(0) = '0' else g; 
    u3: segmentos port map(displays , result ); --mapeo de puertos por posiciones
    salidasegmentos <= displays ; 

end; 

