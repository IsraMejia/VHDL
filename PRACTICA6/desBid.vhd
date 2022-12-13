library ieee;
use ieee.std_logic_1164.all;

Entity desBid is
port(ClkDes, SI, LR : in std_logic;
		PO1 : out std_logic_vector(6 downto 0),
		PO2 : out std_logic_vector(6 downto 0),
		PO3 : out std_logic_vector(6 downto 0),
		PO4 : out std_logic_vector(6 downto 0));
End desBid;

Architecture archi of desBid is
 signal tmp1: std_logic_vector(6 downto 0);--podemos tener las letras aqui
 signal tmp2: std_logic_vector(6 downto 0);
 signal tmp3: std_logic_vector(6 downto 0);
 signal tmp4: std_logic_vector(6 downto 0);
 
--DECLARAMOS COMPONENTE DE DISPLAY 7 SEGMENTOS
component display is 
port(    
    interruptor: in  std_logic_vector( 4 downto 0);
    segmento:    out std_logic_vector( 6 downto 0)
);
end display;
 
--DECLARMOS COMPONENTE PARA DIVISOR DE FRECUENCIA
component DIVI1SEG is
port (CLK50MHZ: in std_logic;
		CLK: out std_logic);
end component DIVI1SEG;

 begin
	process (ClkDes) --salida del divisor
	 begin
		if (ClkDes'event and ClkDes='1') then
			if (LR='0') then
				tmp1 <= tmp2(6 downto 0) & SI;--derecha a izquierda
				tmp2 <= tmp3(6 downto 0) & SI;
				tmp3 <= tmp4(6 downto 0) & SI;
				tmp4 <= tmp3	(6 downto 0) & SI;
			else
				tmp1 <= SI & tmp1(6 downto 1); --izquieda derecha
				tmp2 <= SI & tmp2(6 downto 1);
				tmp3 <= SI & tmp3(6 downto 1);
				tmp4 <= SI & tmp4(6 downto 1);
			end if;
		end if;
	end process;
	PO1 <= tmp1; --salida de decodificador podemos pintar lo display
	
End archi;