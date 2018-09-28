
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder2input is
generic (N: integer);
port (
	I0 : in std_logic_vector(N-1 downto 0);
	I1 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0)
);
end adder2input;

architecture arc of adder2input is

begin
	Y<= std_logic_vector( unsigned(I0) + unsigned(I1) );

end arc;

