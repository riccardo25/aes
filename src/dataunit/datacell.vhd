
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity datacell is
	port (
		CLK, rst_n 							: in std_logic;

		-- data inputs
		enc 									: in std_logic;
		in_right, up_in, keybyte		: in std_logic_vector (7 downto 0);
		s0c, s1c, s2c, s3c				: in std_logic_vector (7 downto 0);
		key_lenght 							: in std_logic_vector (1 downto 0);
		cell_num 							: in std_logic_vector (3 downto 0);
		ROUND									: in std_logic_vector (3 downto 0);
		
		--FROM CONTROLLER
		
		sel_state							: in std_logic_vector (2 downto 0);
		load_state							: in std_logic;

		-- data outputs
		debug_sttin							: out std_logic_vector (7 downto 0);
		data_out 							: out std_logic_vector (7 downto 0)
	);
end datacell;

architecture arc of datacell is

	component datacell_datapath is
		port (
			CLK, rst_n 							: in std_logic;
			enc 									: in std_logic;
			sel_state							: in std_logic_vector (2 downto 0);
			load_state							: in std_logic;
			in_right, up_in, keybyte		: in std_logic_vector (7 downto 0);
			s0c, s1c, s2c, s3c				: in std_logic_vector (7 downto 0);
			cell_num 							: in std_logic_vector (3 downto 0);
			ROUND									: in std_logic_vector (3 downto 0);
			debug_sttin							: out std_logic_vector (7 downto 0);
			STT									: out std_logic_vector (7 downto 0)
		);
	end component;

	signal STT_out									: std_logic_vector (7 downto 0);
	
begin


	DATAPATH: datacell_datapath port map(CLK => CLK, rst_n => rst_n, 
		sel_state => sel_state, load_state => load_state,
		in_right => in_right, up_in => up_in, keybyte => keybyte,
		s0c => s0c, s1c => s1c, s2c => s2c, s3c => s3c, enc => enc,
		cell_num => cell_num, STT => STT_out, ROUND => ROUND, debug_sttin	=> debug_sttin);
		
-- OUTPUT
	data_out <= STT_out;

end arc;

