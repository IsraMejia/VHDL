library ieee;
use ieee.std_logic_1164.all;

entity Fa is 
port(a,b,ci: in std_logic;
		co,s: out std_logic);
end;

architecture bhv of Fa is
begin

s <= a xor b xor ci;
co <= ((ci and (a xor b)) or (a and b));

end;
