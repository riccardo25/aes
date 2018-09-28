
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux6input is
	generic (N: integer);
	port (
		sel : in std_logic_vector(2 downto 0);
		I0 : in std_logic_vector(N-1 downto 0);
		I1 : in std_logic_vector(N-1 downto 0);
		I2 : in std_logic_vector(N-1 downto 0);
		I3 : in std_logic_vector(N-1 downto 0);
		I4 : in std_logic_vector(N-1 downto 0);
		I5 : in std_logic_vector(N-1 downto 0);
		Y : out std_logic_vector(N-1 downto 0)
	);
end mux6input;

architecture arc of mux6input is

begin

	Y <= 	I0 when sel="000" else
			I1 when sel="001" else
			I2 when sel="010" else
			I3 when sel="011" else
			I4 when sel="100" else
			I5;


end arc;

