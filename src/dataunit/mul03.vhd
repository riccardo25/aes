library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mul03 is
port (
--INPUT
		a			: in std_logic_vector (7 downto 0);
--OUTPUT
		q			: out std_logic_vector (7 downto 0)
		);
end mul03;

architecture arc of mul03 is


component xtime is
port (
		a			: in std_logic_vector (7 downto 0);
		q			: out std_logic_vector (7 downto 0)
		);
end component;

	signal xa : std_logic_vector (7 downto 0);

begin

	XT1: xtime port map( a => a, q => xa);
	
	q <= a xor xa;




end arc;

