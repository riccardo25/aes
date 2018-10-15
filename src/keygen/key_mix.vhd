library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity key_mix is
	port(
	--INPUT
		data_in 			: in std_logic_vector(127 downto 0);
	--OUTPUT
		data_inverted	: out std_logic_vector(127 downto 0)
	);
end key_mix;

architecture arc of key_mix is

	component mix_columns is
		port (
			--INPUT
			enc 							: in std_logic;
			cell_num 					: in std_logic_vector (3 downto 0);
			s0c, s1c, s2c, s3c		: in std_logic_vector (7 downto 0);
			--OUTPUT
			Q								: out std_logic_vector (7 downto 0)
			);
	end component;

begin

	-- row 0
	MIX0	: mix_columns port map(cell_num => X"0", s0c => data_in(31 downto 24), s1c => data_in(23 downto 16), s2c => data_in(15 downto 8), s3c => data_in(7 downto 0), Q=> data_inverted(31 downto 24), enc => '0');
	MIX1	: mix_columns port map(cell_num => X"1", s0c => data_in(63 downto 56), s1c => data_in(55 downto 48), s2c => data_in(47 downto 40), s3c => data_in(39 downto 32), Q=> data_inverted(63 downto 56), enc => '0');	
	MIX2	: mix_columns port map(cell_num => X"2", s0c => data_in(95 downto 88), s1c => data_in(87 downto 80), s2c => data_in(79 downto 72), s3c => data_in(71 downto 64), Q=> data_inverted(95 downto 88), enc => '0');	
	MIX3	: mix_columns port map(cell_num => X"3", s0c => data_in(127 downto 120), s1c => data_in(119 downto 112), s2c => data_in(111 downto 104), s3c => data_in(103 downto 96), Q=> data_inverted(127 downto 120), enc => '0');	
	-- row 1
	MIX4	: mix_columns port map(cell_num => X"4", s0c => data_in(31 downto 24), s1c => data_in(23 downto 16), s2c => data_in(15 downto 8), s3c => data_in(7 downto 0), Q=> data_inverted(23 downto 16), enc => '0');
	MIX5	: mix_columns port map(cell_num => X"5", s0c => data_in(63 downto 56), s1c => data_in(55 downto 48), s2c => data_in(47 downto 40), s3c => data_in(39 downto 32), Q=> data_inverted(55 downto 48), enc => '0');	
	MIX6	: mix_columns port map(cell_num => X"6", s0c => data_in(95 downto 88), s1c => data_in(87 downto 80), s2c => data_in(79 downto 72), s3c => data_in(71 downto 64), Q=> data_inverted(87 downto 80), enc => '0');	
	MIX7	: mix_columns port map(cell_num => X"7", s0c => data_in(127 downto 120), s1c => data_in(119 downto 112), s2c => data_in(111 downto 104), s3c => data_in(103 downto 96), Q=> data_inverted(119 downto 112), enc => '0');	
	-- row 2
	MIX8	: mix_columns port map(cell_num => X"8", s0c => data_in(31 downto 24), s1c => data_in(23 downto 16), s2c => data_in(15 downto 8), s3c => data_in(7 downto 0), Q=> data_inverted(15 downto 8), enc => '0');
	MIX9	: mix_columns port map(cell_num => X"9", s0c => data_in(63 downto 56), s1c => data_in(55 downto 48), s2c => data_in(47 downto 40), s3c => data_in(39 downto 32), Q=> data_inverted(47 downto 40), enc => '0');	
	MIX10	: mix_columns port map(cell_num => X"A", s0c => data_in(95 downto 88), s1c => data_in(87 downto 80), s2c => data_in(79 downto 72), s3c => data_in(71 downto 64), Q=> data_inverted(79 downto 72), enc => '0');	
	MIX11	: mix_columns port map(cell_num => X"B", s0c => data_in(127 downto 120), s1c => data_in(119 downto 112), s2c => data_in(111 downto 104), s3c => data_in(103 downto 96), Q=> data_inverted(111 downto 104), enc => '0');	
	-- row 3
	MIX12	: mix_columns port map(cell_num => X"C", s0c => data_in(31 downto 24), s1c => data_in(23 downto 16), s2c => data_in(15 downto 8), s3c => data_in(7 downto 0), Q=> data_inverted(7 downto 0), enc => '0');
	MIX13	: mix_columns port map(cell_num => X"D", s0c => data_in(63 downto 56), s1c => data_in(55 downto 48), s2c => data_in(47 downto 40), s3c => data_in(39 downto 32), Q=> data_inverted(39 downto 32), enc => '0');	
	MIX14	: mix_columns port map(cell_num => X"E", s0c => data_in(95 downto 88), s1c => data_in(87 downto 80), s2c => data_in(79 downto 72), s3c => data_in(71 downto 64), Q=> data_inverted(71 downto 64), enc => '0');	
	MIX15	: mix_columns port map(cell_num => X"F", s0c => data_in(127 downto 120), s1c => data_in(119 downto 112), s2c => data_in(111 downto 104), s3c => data_in(103 downto 96), Q=> data_inverted(103 downto 96), enc => '0');	


end arc;

