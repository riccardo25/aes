library ieee;
use ieee.std_logic_1164.all;

entity mux3input is
generic (N: integer);
port (
	sel : in std_logic_vector(1 downto 0);
	I0 : in std_logic_vector(N-1 downto 0);
	I1 : in std_logic_vector(N-1 downto 0);
	I2 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0)
);
end mux3input;

architecture arc of mux3input is
begin
	Y <= 	I0 when sel="00" else
			I1 when sel="01" else
			I2;
end arc;
