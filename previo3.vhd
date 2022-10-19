--this program creates the logic of a four traffic semaphores in a roundabout. 
--To obtain the simplified data flow of the variables, multiple Karnaugh maps were used.

library ieee;
use ieee.std_logic_1164.all;

entity previo is
    port( 
        a,b,c,d : in std_logic;
        sa,sb,sc,sd : out std_logic
    );
end;

architecture bhv of previo is
begin
    -- and * , or +
    sa<=(
        (not x  and y and  not x) or ( not x and y and w) 
        or ( x  and not y  and  not z) or (not x and not y and z and not w )
    );

    sb<=( 
        (not x  and y and not w and not z) or (x and not y and w and not z)
        or (not y and not z and w) or (not x and z and w)
    );

    sc<=( 
        (y or z or w) and (x or z or w) and (not y or not w)
        and (not y or not z) and (not z or not w)
    );

    sd<=( 
        (not x and y and not w and z) or (not x and not y and w and z)
        or (not x and y and w and not z)
    ); 
		
end;
