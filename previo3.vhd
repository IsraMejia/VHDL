--this program creates the logic of a four traffic semaphores in a roundabout. 
--To obtain the simplified data flow of the variables, multiple Karnaugh maps were used.

library ieee;
use ieee.std_logic_1164.all;

entity previotres is
    port( 
        a,b,c,d : in std_logic;
        sa,sb,sc,sd : out std_logic
    );
end;

architecture bhv of previotres is
begin
    -- and * , or +
    sa<=(
        (not a  and b and  not a) or ( not a and b and d) 
        or ( a  and not b  and  not c) or (not a and not b and c and not d )
    );

    sb<=( 
        (not a  and b and not d and not c) or (a and not b and d and not c)
        or (not b and not c and d) or (not a and c and d)
    );

    sc<=( 
        (b or c or d) and (a or c or d) and (not b or not d)
        and (not b or not c) and (not c or not d)
    );

    sd<=( 
        (not a and b and not d and c) or (not a and not b and d and c)
        or (not a and b and d and not c)
    ); 
		
end;
 