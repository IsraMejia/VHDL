library ieee;
use ieee.std_logic_1164.all;

entity UA is 
port(S0,S1,b: in std_logic;
		Ni: out std_logic);
end;

architecture bhv of UA is
begin

Ni <= ((S1 and (not b)) or (S0 and b));

end;
