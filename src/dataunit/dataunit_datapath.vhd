library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dataunit_datapath is

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
end dataunit_datapath;

architecture arc of dataunit_datapath is

	component reg is
		generic( N : integer);
		port (
			CLK, rst_n : in std_logic;
			load : in std_logic;
			D : in std_logic_vector(N-1 downto 0);
			Q : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component mux4input is
		generic (N: integer);
		port (
			sel : in std_logic_vector(1 downto 0);
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			I2 : in std_logic_vector(N-1 downto 0);
			I3 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component adder2input is
		generic (N: integer);
		port (
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component sub2input is
		generic (N: integer);
		port (
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	component mux2input is
		generic (N: integer);
		port (
			sel : in std_logic;
			I0 : in std_logic_vector(N-1 downto 0);
			I1 : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	
	component mux6input is
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
	end component;
	
	component datacell is
		port (
				CLK, rst_n 							: in std_logic;
				enc 									: in std_logic;
				in_right, up_in, keybyte		: in std_logic_vector (7 downto 0);
				s0c, s1c, s2c, s3c				: in std_logic_vector (7 downto 0);
				key_lenght 							: in std_logic_vector (1 downto 0);
				cell_num 							: in std_logic_vector (3 downto 0);
				ROUND									: in std_logic_vector (3 downto 0);
				sel_state							: in std_logic_vector (2 downto 0);
				load_state							: in std_logic;
				debug_sttin							: out std_logic_vector (7 downto 0);
				data_out 							: out std_logic_vector (7 downto 0)
			);
	end component;
	
	
	component sbox is
		port (
			CLK, rst_n 		: in std_logic;
			data_in 			: in std_logic_vector(7 downto 0);
			data_out 		: out std_logic_vector(7 downto 0);
			enc				: in std_logic
		);
	end component;



	signal 	ROUND_in, ROUND_out, 
				add_out, sub_out 							: std_logic_vector(3 downto 0);
	signal 	out0, out1,out2, out3, out4, out5, 
				out6, out7, out8, out9, out10, 
				out11, out12, out13, out14, out15	: std_logic_vector(7 downto 0);
	signal 	sboxout0, sboxout1, 
				sboxout2, sboxout3 						: std_logic_vector(7 downto 0);
	signal 	brout0, brout1, brout2, brout3 		: std_logic_vector(7 downto 0);
	signal 	tosbox0, tosbox1, tosbox2, tosbox3 	: std_logic_vector(7 downto 0);
	
	signal 	debug_sttin							: std_logic_vector (7 downto 0);
begin

--ROUND 
	SUB1		: sub2input 	generic map(4) port map ( I0 => ROUND_out, I1 => "0001", Y => sub_out);
	ADD1		: adder2input 	generic map(4) port map ( I0 => ROUND_out, I1 => "0001", Y => add_out);
	MUX1		: mux6input 	generic map(4) port map(sel=> sel_round, I0 => "1010" , I1 => "1100", I2 => "1110" , I3 => sub_out, I4 => add_out , I5 => "0000",  Y=>ROUND_in);
	ROUND1	: reg 			generic map(4) port map (CLK => CLK, rst_n => reset_reg, load => load_ROUND, D => ROUND_in, Q => ROUND_out);



	--WORDS from key generator are descendent sorted: W3 W2 W1 W0 so keywords(127) is W3(31) and so on..
--FIRST ROW
	DC0		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out1, up_in => sboxout0, 		
											keybyte=> keywords(31 downto 24),
											s0c => out0 , s1c => out4, s2c =>out8, s3c=>out12,
											key_lenght => key_lenght,
											cell_num => "0000",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											debug_sttin => debug_sttin,
											enc => enc,
											data_out => out0
										);
	DC1		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out2, up_in => sboxout1, 		
											keybyte=> keywords(63 downto 56),
											s0c => out1 , s1c => out5, s2c =>out9, s3c=>out13,
											key_lenght => key_lenght,
											cell_num => "0001",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out1
										);
	DC2		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out3, up_in => sboxout2, 		
											keybyte=> keywords(95 downto 88),
											s0c => out2 , s1c => out6, s2c =>out10, s3c=>out14,
											key_lenght => key_lenght,
											cell_num => "0010",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out2
										);
	DC3		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => in0, up_in => sboxout3, 		
											keybyte=> keywords(127 downto 120),
											s0c => out3 , s1c => out7, s2c =>out11, s3c=>out15,
											key_lenght => key_lenght,
											cell_num => "0011",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out3
										);
-- BARREL ROLL
	BR0		: mux4input generic map(8) port map(sel => br0_sel, I0=> out0, I1 => out1, I2=> out2, I3 => out3, Y=> brout0);
	BR1		: mux4input generic map(8) port map(sel => br1_sel, I0=> out0, I1 => out1, I2=> out2, I3 => out3, Y=> brout1);
	BR2		: mux4input generic map(8) port map(sel => br2_sel, I0=> out0, I1 => out1, I2=> out2, I3 => out3, Y=> brout2);
	BR3		: mux4input generic map(8) port map(sel => br3_sel, I0=> out0, I1 => out1, I2=> out2, I3 => out3, Y=> brout3);
										
--SECOND ROW
	DC4		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out5, up_in => brout0, 		
											keybyte=> keywords(23 downto 16),
											s0c => out0 , s1c => out4, s2c =>out8, s3c=>out12,
											key_lenght => key_lenght,
											cell_num => "0100",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out4
										);
	DC5		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out6, up_in => brout1, 		
											keybyte=> keywords(55 downto 48),
											s0c => out1 , s1c => out5, s2c =>out9, s3c=>out13,
											key_lenght => key_lenght,
											cell_num => "0101",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out5
										);
	DC6		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out7, up_in => brout2, 		
											keybyte=> keywords(87 downto 80),
											s0c => out2 , s1c => out6, s2c =>out10, s3c=>out14,
											key_lenght => key_lenght,
											cell_num => "0110",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out6
										);
	DC7		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => in1, up_in => brout3, 		
											keybyte=> keywords(119 downto 112),
											s0c => out3 , s1c => out7, s2c =>out11, s3c=>out15,
											key_lenght => key_lenght,
											cell_num => "0111",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out7
										);
--THIRD ROW
	DC8		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out9, up_in => out4, 		
											keybyte=> keywords(15 downto 8),
											s0c => out0 , s1c => out4, s2c =>out8, s3c=>out12,
											key_lenght => key_lenght,
											cell_num => "1000",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out8
										);
	DC9		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out10, up_in => out5, 		
											keybyte=> keywords(47 downto 40),
											s0c => out1 , s1c => out5, s2c =>out9, s3c=>out13,
											key_lenght => key_lenght,
											cell_num => "1001",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out9
										);
	DC10		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out11, up_in => out6, 		
											keybyte=> keywords(79 downto 72),
											s0c => out2 , s1c => out6, s2c =>out10, s3c=>out14,
											key_lenght => key_lenght,
											cell_num => "1010",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out10
										);
	DC11		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => in2, up_in => out7, 		
											keybyte=> keywords(111 downto 104),
											s0c => out3 , s1c => out7, s2c =>out11, s3c=>out15,
											key_lenght => key_lenght,
											cell_num => "1011",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out11
										);				
--FOURTH ROW
	DC12		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out13, up_in => out8, 		
											keybyte=> keywords(7 downto 0),
											s0c => out0 , s1c => out4, s2c =>out8, s3c=>out12,
											key_lenght => key_lenght,
											cell_num => "1100",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out12
										);
	DC13		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out14, up_in => out9, 		
											keybyte=> keywords(39 downto 32),
											s0c => out1 , s1c => out5, s2c =>out9, s3c=>out13,
											key_lenght => key_lenght,
											cell_num => "1101",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out13
										);
	DC14		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => out15, up_in => out10, 		
											keybyte=> keywords(71 downto 64),
											s0c => out2 , s1c => out6, s2c =>out10, s3c=>out14,
											key_lenght => key_lenght,
											cell_num => "1110",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out14
										);
	DC15		: datacell port map(	CLK => CLK, rst_n => reset_reg, 
											in_right => in3, up_in => out11, 		
											keybyte=> keywords(103 downto 96),
											s0c => out3 , s1c => out7, s2c =>out11, s3c=>out15,
											key_lenght => key_lenght,
											cell_num => "1111",
											ROUND	=> ROUND_out,
											sel_state => sel_state,
											load_state => load_state,
											enc => enc,
											data_out => out15
										);			

	MUX2	: mux2input generic map(8) port map(sel=> sel_sbox, I0 => out12, I1 => wordtosbox(31 downto 24), Y=>tosbox0);
	MUX3	: mux2input generic map(8) port map(sel=> sel_sbox, I0 => out13, I1 => wordtosbox(23 downto 16), Y=>tosbox1);
	MUX4	: mux2input generic map(8) port map(sel=> sel_sbox, I0 => out14, I1 => wordtosbox(15 downto 8), Y=>tosbox2);
	MUX5	: mux2input generic map(8) port map(sel=> sel_sbox, I0 => out15, I1 => wordtosbox(7 downto 0), Y=>tosbox3);
		
	SBOX0	: sbox port map( CLK => CLK, rst_n => reset_reg, data_in => tosbox0, data_out => sboxout0, enc=> enc);
	SBOX1	: sbox port map( CLK => CLK, rst_n => reset_reg, data_in => tosbox1, data_out => sboxout1, enc=> enc);
	SBOX2	: sbox port map( CLK => CLK, rst_n => reset_reg, data_in => tosbox2, data_out => sboxout2, enc=> enc);
	SBOX3	: sbox port map( CLK => CLK, rst_n => reset_reg, data_in => tosbox3, data_out => sboxout3, enc=> enc);
	
	
--DATAOUT

	data_out0 <= out0;
	data_out1 <= out4;
	data_out2 <= out8;
	data_out3 <= out12;--debug_sttin;

	
	ROUND <= ROUND_out;
	
end arc;

