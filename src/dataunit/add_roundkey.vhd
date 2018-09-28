library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity add_roundkey is
port (
	I0 : in std_logic_vector(7 downto 0);
	I1 : in std_logic_vector(7 downto 0);
	Y : out std_logic_vector(7 downto 0)
);
end add_roundkey;

architecture arc of add_roundkey is

begin

Y <= I0 xor I1;

end arc;

