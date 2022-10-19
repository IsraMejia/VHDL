--this program creates the logic of a seven segment display. 
--To obtain the simplified data flow of the variables, multiple Karnaugh maps were used.

library ieee;
use ieee.std_logic_1164.all;

entity deco is
    port( 
        w,x,y,z : in std_logic;
        a,b,c,d,e,f,g: out std_logic
    );
end;

architecture bhv of deco is
begin

    a<=(
        (x or not z) and (x or not y or not w) and
        (y or z or w) and (not x or y or z)
    );

    b<=(
        (x and (y or z)) or (y and (z xor w))
    );

    c<=(
        (x and (y or z)) or (not y and z and not w)
    );

    d<=(
        (x and (y or z)) or (y and not( z xor w)) or
        (not x and not y and not z and w)
    );

    e<=(
        w or (y and not z) or (x and z)
    );

    f<=((x or z or w) and (x or not y or w) and (z or not(x xor y)));

    g<=((z or not(x xor y)) and (x or y or not z) and (x or not z or w));
		
end;
