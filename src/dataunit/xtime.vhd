
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xtime is
port (
--INPUT
		a			: in std_logic_vector (7 downto 0);
--OUTPUT
		q			: out std_logic_vector (7 downto 0)
		);
end xtime;

architecture arc of xtime is

begin
	
	q <= a(6 downto 4) & (a(3) xor a(7)) & (a(2) xor a(7)) & a(1) & (a(0) xor a(7)) & a(7);

end arc;

