
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dataunit is
	port (
			--INPUT
			CLK, rst_n 							: in std_logic;
			keywords								: in std_logic_vector (127 downto 0);
			in0, in1, in2, in3				: in std_logic_vector (7 downto 0);
			key_lenght							: in std_logic_vector (1 downto 0);
			enc									: in std_logic;	
			key_valid							: in std_logic;
			
			--OUTPUT
			loading								: out std_logic;
			ROUND									: out std_logic_vector (3 downto 0);
			data_out0, data_out1,
			data_out2, data_out3				: out std_logic_vector (7 downto 0);
			valid_out							: out std_logic
			
		);
end dataunit;

architecture arc of dataunit is

	component dataunit_control is

		port (
				CLK, rst_n 							: in std_logic;
				ROUND									: in std_logic_vector (3 downto 0);
				key_lenght							: in std_logic_vector (1 downto 0);
				enc									: in std_logic;
				key_valid							: in std_logic;
				sel_state, sel_round				: out std_logic_vector (2 downto 0);
				reset_reg							: out std_logic;
				loading								: out std_logic;
				br0_sel, br1_sel, 
				br2_sel, br3_sel					: out std_logic_vector (1 downto 0);
				load_round, load_state			: out std_logic;
				valid_out							: out std_logic
			);

	end component;
	
	
	component dataunit_datapath is

		port (
			CLK, rst_n 							: in std_logic;

			-- data inputs
			key_lenght 							: in std_logic_vector (1 downto 0);
			enc									: in std_logic;
			keywords								: in std_logic_vector (127 downto 0);
			in0, in1, in2, in3				: in std_logic_vector (7 downto 0);
			wordtosbox							: in std_logic_vector (31 downto 0);
			--FROM CONTROLLER
			
			sel_state, sel_round				: in std_logic_vector (2 downto 0);
			reset_reg							: in std_logic;
			load_round, load_state			: in std_logic;
			sel_sbox								: in std_logic;
			br0_sel, br1_sel, 
			br2_sel, br3_sel					: in std_logic_vector (1 downto 0);

			-- data outputs
			ROUND									: out std_logic_vector (3 downto 0);
			data_out0, data_out1,
			data_out2, data_out3				: out std_logic_vector (7 downto 0)
		);
	end component;	
	

	signal 	sel_state, sel_round				: std_logic_vector (2 downto 0);
	signal 	reset_reg							: std_logic;
	signal 	load_round, load_state			: std_logic;
	signal 	sig_ROUND							: std_logic_vector (3 downto 0);
	signal 	br0_sel, br1_sel, 
				br2_sel, br3_sel					: std_logic_vector (1 downto 0);
	
				
				
	

begin


	CONTROLUNIT: dataunit_control port map(CLK => CLK, rst_n => rst_n, 
		ROUND => sig_ROUND,	key_lenght => key_lenght, sel_round => sel_round,
		reset_reg => reset_reg, sel_state => sel_state, key_valid => key_valid,
		load_round => load_round, load_state => load_state, enc => enc,
		loading => loading,
		br0_sel => br0_sel, br1_sel => br1_sel, br2_sel => br2_sel, br3_sel => br3_sel,
		valid_out => valid_out);
		
	DATAPATH: dataunit_datapath port map(CLK => CLK, rst_n => rst_n, 
		ROUND => sig_ROUND,	key_lenght => key_lenght, keywords => keywords,
		reset_reg => reset_reg, sel_state => sel_state, sel_round=> sel_round,
		load_round => load_round, load_state => load_state,
		wordtosbox => X"00000000", sel_sbox => '0', enc=> enc,
		in0 => in0, in1=> in1, in2=>in2, in3=> in3,
		data_out0 => data_out0, data_out1 => data_out1, data_out2=> data_out2, 
		data_out3=> data_out3,
		br0_sel => br0_sel, br1_sel => br1_sel, br2_sel => br2_sel, br3_sel => br3_sel);
		
		
		ROUND <= sig_ROUND;
		
end arc;

