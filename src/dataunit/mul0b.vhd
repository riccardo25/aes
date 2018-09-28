library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mul0b is

port (
--INPUT
		a			: in std_logic_vector (7 downto 0);
--OUTPUT
		q			: out std_logic_vector (7 downto 0)
		);
end mul0b;

architecture arc of mul0b is

component xtime is
port (
		a			: in std_logic_vector (7 downto 0);
		q			: out std_logic_vector (7 downto 0)
		);
end component;

	signal xa, xb, xc : std_logic_vector (7 downto 0);

begin

	XT1: xtime port map( a => a, q => xa);
	XT2: xtime port map( a =>xa, q => xb);
	XT3: xtime port map( a =>xb, q => xc);
	
	q <= a xor xc xor xa;

end arc;