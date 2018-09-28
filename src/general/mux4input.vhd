
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux4input is
generic (N: integer);
port (
	sel : in std_logic_vector(1 downto 0);
	I0 : in std_logic_vector(N-1 downto 0);
	I1 : in std_logic_vector(N-1 downto 0);
	I2 : in std_logic_vector(N-1 downto 0);
	I3 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0)
);
end mux4input;

architecture arc of mux4input is

begin

	Y <= 	I0 when sel="00" else
			I1 when sel="01" else
			I2 when sel="10" else
			I3;


end arc;

