library ieee;
use ieee.std_logic_1164.all;

entity PMsum is 
port(x,y: in std_logic_vector(3 downto 0);
		S1,S0: in std_logic;
		ci:in std_logic;
		su: out std_logic_vector(4 downto 0));
end;

architecture bhv of PMsum is 

component Fa is 
port(a,b,ci: in std_logic;
		co,s: out std_logic);
end component;

component UA is 
port(S0,S1,b: in std_logic;
		Ni: out std_logic);
end component;

signal ac: std_logic_vector (6 downto 0);--puentes para los acarreos

begin

u1 : Fa port map(a=>x(0),b=>ac(3),ci=>ci,co=>ac(0),s=>su(0));--comparamos entradas de Fa con las variables que tenemos de este archivo 

u2 : Fa port map(a=>x(1),b=>ac(4),ci=>ac(0),co=>ac(1),s=>su(1));

u3 : Fa port map(a=>x(2),b=>ac(5),ci=>ac(1),co=>ac(2),s=>su(2));

u4 : Fa port map(a=>x(3),b=>ac(6),ci=>ac(2),co=>su(4),s=>su(3));



u5 : UA port map(b=>y(0),S1=>S1, S0=>S0, Ni=>ac(3));

u6 : UA port map(b=>y(1),S1=>S1, S0=>S0, Ni=>ac(4));

u7 : UA port map(b=>y(2),S1=>S1, S0=>S0, Ni=>ac(5));

u8 : UA port map(b=>y(3),S1=>S1, S0=>S0, Ni=>ac(6));
end;