library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mix_columns is
port (

--INPUT
	enc 							: in std_logic;
	cell_num 					: in std_logic_vector (3 downto 0);
	s0c, s1c, s2c, s3c		: in std_logic_vector (7 downto 0);
	
--OUTPUT
	Q								: out std_logic_vector (7 downto 0)
	);
end mix_columns;

architecture arc of mix_columns is

component xtime is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;

component mul03 is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;

component mul09 is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;

component mul0d is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;

component mul0b is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;

component mul0e is
	port (
			a			: in std_logic_vector (7 downto 0);
			q			: out std_logic_vector (7 downto 0)
			);
end component;


signal xs0c, xs1c, xs2c, xs3c							: std_logic_vector (7 downto 0);
signal mul03s0c, mul03s1c, mul03s2c, mul03s3c	: std_logic_vector (7 downto 0);

signal mul0bs0c, mul0bs1c, mul0bs2c, mul0bs3c	: std_logic_vector (7 downto 0);
signal mul0es0c, mul0es1c, mul0es2c, mul0es3c	: std_logic_vector (7 downto 0);
signal mul0ds0c, mul0ds1c, mul0ds2c, mul0ds3c	: std_logic_vector (7 downto 0);
signal mul09s0c, mul09s1c, mul09s2c, mul09s3c	: std_logic_vector (7 downto 0);

begin

	MUL0: mul03 port map (a => s0c, q=> mul03s0c);
	MUL1: mul03 port map (a => s1c, q=> mul03s1c);
	MUL2: mul03 port map (a => s2c, q=> mul03s2c);
	MUL3: mul03 port map (a => s3c, q=> mul03s3c);
	
	MUL4: mul0b port map (a => s0c, q=> mul0bs0c);
	MUL5: mul0b port map (a => s1c, q=> mul0bs1c);
	MUL6: mul0b port map (a => s2c, q=> mul0bs2c);
	MUL7: mul0b port map (a => s3c, q=> mul0bs3c);
	
	MUL8: mul0d port map (a => s0c, q=> mul0ds0c);
	MUL9: mul0d port map (a => s1c, q=> mul0ds1c);
	MUL10: mul0d port map (a => s2c, q=> mul0ds2c);
	MUL11: mul0d port map (a => s3c, q=> mul0ds3c);
	
	MUL12: mul0e port map (a => s0c, q=> mul0es0c);
	MUL13: mul0e port map (a => s1c, q=> mul0es1c);
	MUL14: mul0e port map (a => s2c, q=> mul0es2c);
	MUL15: mul0e port map (a => s3c, q=> mul0es3c);
	
	MUL16: mul09 port map (a => s0c, q=> mul09s0c);
	MUL17: mul09 port map (a => s1c, q=> mul09s1c);
	MUL18: mul09 port map (a => s2c, q=> mul09s2c);
	MUL19: mul09 port map (a => s3c, q=> mul09s3c);
	
	X0: xtime port map (a => s0c, q=> xs0c);
	X1: xtime port map (a => s1c, q=> xs1c);
	X2: xtime port map (a => s2c, q=> xs2c);
	X3: xtime port map (a => s3c, q=> xs3c);
	
	q <= 	(xs0c xor mul03s1c xor s2c xor s3c) when enc = '1' and ( cell_num="0000" or cell_num="0001" or cell_num="0010" or cell_num="0011" ) else 
			(s0c xor xs1c xor mul03s2c xor s3c) when enc = '1' and ( cell_num="0100" or cell_num="0101" or cell_num="0110" or cell_num="0111" ) else 
			(s0c xor s1c xor xs2c xor mul03s3c) when enc = '1' and ( cell_num="1000" or cell_num="1001" or cell_num="1010" or cell_num="1011" ) else
			(mul03s0c xor s1c xor s2c xor xs3c) when enc = '1' and ( cell_num="1100" or cell_num="1101" or cell_num="1110" or cell_num="1111" ) else
            
         (mul0es0c xor mul0bs1c xor mul0ds2c xor mul09s3c) when cell_num="0000" or cell_num="0001" or cell_num="0010" or cell_num="0011" else 
			(mul09s0c xor mul0es1c xor mul0bs2c xor mul0ds3c) when cell_num="0100" or cell_num="0101" or cell_num="0110" or cell_num="0111" else 
			(mul0ds0c xor mul09s1c xor mul0es2c xor mul0bs3c) when cell_num="1000" or cell_num="1001" or cell_num="1010" or cell_num="1011" else
			(mul0bs0c xor mul0ds1c xor mul09s2c xor mul0es3c);

end arc;

