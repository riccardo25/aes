library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cipher is

	port (
				--INPUT
					CLK, rst_n 							: in std_logic;
					data									: in std_logic_vector (127 downto 0);
					data_valid							: in std_logic;
					key_valid							: in std_logic;
					session								: in std_logic_vector (7 downto 0);
					key									: in std_logic_vector (255 downto 0);
					key_lenght							: in std_logic_vector (1 downto 0);
					enc									: in std_logic;
					ready_to_send						: in std_logic;
				--OUTPUT
					ready_for_data						: out std_logic;
					ready_for_key						: out std_logic;
					enc_to_cap							: out std_logic;
					session_to_cap						: out std_logic_vector(7 downto 0);
					valid_out							: out std_logic;
					crypted_data						: out std_logic_vector (127 downto 0)
				);
	end cipher;

architecture arc of cipher is

	
	--signal data	: std_logic_vector (127 downto 0) := X"3243f6a8885a308d313198a2e0370734";
	--signal data	: std_logic_vector (127 downto 0) := X"69c4e0d86a7b0430d8cdb78070b4c55a";
	
	--signal data	: std_logic_vector (127 downto 0) := X"3925841d02dc09fbdc118597196a0b32";
	--signal key 	: std_logic_vector (255 downto 0) := X"00000000000000000000000000000000" & X"09cf4f3c" & X"abf71588" & X"28aed2a6"& X"2b7e1516";
	
	--signal data	: std_logic_vector (127 downto 0) := X"00112233445566778899aabbccddeeff";--X"dda97ca4864cdfe06eaf70a0ec0d7191";--X"8ea2b7ca516745bfeafc49904b496089";--
	--signal key 	: std_logic_vector (255 downto 0) := X"00000000000000000000000000000000" &  X"0c0d0e0f08090a0b0405060700010203";
	--signal key 	: std_logic_vector (255 downto 0) := X"0000000000000000" &  X"14151617101112130c0d0e0f08090a0b0405060700010203";
	--signal key 	: std_logic_vector (255 downto 0) := X"1C1D1E1F18191A1B" &  X"14151617101112130c0d0e0f08090a0b0405060700010203";

	component dataunit is

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
	end component;
	
	
	component key_generator is

		port(
			CLK, rst_n 		: in std_logic;
			
			-- INPUT
			key 				: in std_logic_vector (255 downto 0);
			key_len 			: in std_logic_vector (1 downto 0); 
			ROUND0 			: in std_logic_vector (3 downto 0);
			ROUND1			: in std_logic_vector (3 downto 0);
			enc0				: in std_logic;
			enc1				: in std_logic;
			
			-- OUTPUT
			valid_out0 		: out std_logic;
			data_out0		: out std_logic_vector (127 downto 0);
			valid_out1 		: out std_logic;
			data_out1		: out std_logic_vector (127 downto 0)
		);
	end component;
	
	component cbc is

		port(
				CLK, rst_n 			: in std_logic;
				
			-- INPUT
				
				--from interface
				data_in				: in std_logic_vector (127 downto 0);
				enc_in				: in std_logic;
				session_in			: in std_logic_vector (7 downto 0);
				key_in				: in std_logic_vector (255 downto 0);
				key_len_in			: in std_logic_vector (1 downto 0);
				valid_input			: in std_logic;
				
				--from cipher
				cryptrounddata		: in std_logic_vector (31 downto 0);
				cryptround_valid	: in std_logic;
				loading				: in std_logic;
				
			-- OUTPUT
				--to DATA UNIT
				tocryptdata			: out std_logic_vector (31 downto 0);
				curr_enc				: out std_logic;
				reset_du				: out std_logic;
				
				--to CIPHER
				curr_key				: out std_logic_vector (255 downto 0);
				curr_key_len		: out std_logic_vector (1 downto 0);
				curr_session		: out std_logic_vector (7 downto 0);
				
				--to TOP LEVEL
				ready_for_input	: out std_logic;
				valid_out 			: out std_logic;
				data_out				: out std_logic_vector (127 downto 0)
			);
	end component;
	
	
	component SKMD_controller is
		port(
				CLK, rst_n  			: in std_logic;
		--INPUTS
				--FROM CAP
				valid_from_PC			: in std_logic;
				ready_to_send			: in std_logic;
				--FROM CBC
				done0, done1			: in std_logic;
				datacrypt0,
				datacrypt1				: in std_logic_vector(127 downto 0);
				session0, session1	: in std_logic_vector(7 downto 0);
				enc0, enc1				: in std_logic;
				ready_for_input0,
				ready_for_input1		: in std_logic;
				
		-- OUTPUT
							
				--TO CAP
				datacrypt_out			: out std_logic_vector(127 downto 0);
				session_out				: out std_logic_vector(7 downto 0);
				enc_out					: out std_logic;
				valid_to_serial		: out std_logic;
				ready_get_PC			: out std_logic;
				-- TO CBC
				resetCBC					: out std_logic;
				valid0, valid1			: out std_logic
				
		);
	end component;
	
	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	--SIGNALS
	
	signal keywords_valid0, keywords_valid1 			: std_logic;
	signal keywords0, keywords1							: std_logic_vector (127 downto 0);
	signal ROUND0, ROUND1									: std_logic_vector (3 downto 0);
	signal cryptrounddata0, cryptrounddata1			: std_logic_vector (31 downto 0);
	signal cryptround_valid0, cryptround_valid1 		: std_logic;
	signal tocryptdata0, tocryptdata1					: std_logic_vector (31 downto 0);
	signal loading0, loading1								: std_logic;
	signal session0, session1								: std_logic_vector (7 downto 0);
	signal key0, key1											: std_logic_vector (255 downto 0);
	signal key_len0, key_len1								: std_logic_vector (1 downto 0);
	signal enc0, enc1											: std_logic;
	signal valid_input										: std_logic;
	signal valid_out0, valid_out1 						: std_logic;
	signal crypted_data0, crypted_data1 				: std_logic_vector (127 downto 0);
	signal resetCBC											: std_logic;
	signal ready_get_PC										: std_logic;
	signal valid0, valid1									: std_logic;
	signal ready_for_input0, ready_for_input1			: std_logic;
	signal reset_du0, reset_du1							: std_logic;
	

begin

-- COMPONENTS

	--KEY GENERATOR

	KGEN 	: key_generator port map( 	CLK => CLK, rst_n => rst_n, 
												enc0 => enc0, enc1 => enc1,
												key => key0, 
												key_len => key_len0, 
												ROUND0 => ROUND0, ROUND1 => ROUND1,
												valid_out0 => keywords_valid0, valid_out1 => keywords_valid1, 
												data_out0 => keywords0, data_out1 => keywords1 );
									
	-- CIPHER 0
	
	DUNIT0: dataunit port map( 		CLK => CLK, rst_n => reset_du0, 
												keywords => keywords0, loading => loading0,
												in0=>tocryptdata0(31 downto 24), in1=>tocryptdata0(23 downto 16), 
												in2=>tocryptdata0(15 downto 8), in3=>tocryptdata0(7 downto 0),
												key_lenght => key_len0, enc => enc0, ROUND => ROUND0,
												key_valid => keywords_valid0,
												data_out0 => cryptrounddata0(31 downto 24) , data_out1 => cryptrounddata0(23 downto 16), 
												data_out2 => cryptrounddata0(15 downto 8), data_out3 => cryptrounddata0(7 downto 0),
												valid_out => cryptround_valid0);
									
	DL0	: cbc port map( 				CLK => CLK, rst_n => resetCBC, 
												--from interface
												data_in => data,
												enc_in => enc,
												session_in => session,
												key_in => key,
												key_len_in => key_lenght,
												--FROM SKMD
												valid_input => valid0,
												--from dataunit
												cryptrounddata	=> cryptrounddata0,
												cryptround_valid => cryptround_valid0,
												loading => loading0,
												--to DATA UNIT
												tocryptdata => tocryptdata0,
												curr_enc	=> enc0,
												reset_du => reset_du0,
												--to KEY GENERATOR
												curr_key => key0,
												curr_key_len => key_len0,
												curr_session => session0,
												ready_for_input => ready_for_input0,
												--TO SKMD
												valid_out => valid_out0,
												data_out	=> crypted_data0 );
												
												
	-- CIPHER 1
	
	DUNIT1: dataunit port map( 		CLK => CLK, rst_n => reset_du1, 
												keywords => keywords1, loading => loading1,
												in0=>tocryptdata1(31 downto 24), in1=>tocryptdata1(23 downto 16), 
												in2=>tocryptdata1(15 downto 8), in3=>tocryptdata1(7 downto 0),
												key_lenght => key_len1, enc => enc1, ROUND => ROUND1,
												key_valid => keywords_valid1,
												data_out0 => cryptrounddata1(31 downto 24) , data_out1 => cryptrounddata1(23 downto 16), 
												data_out2 => cryptrounddata1(15 downto 8), data_out3 => cryptrounddata1(7 downto 0),
												valid_out => cryptround_valid1);
									
	DL1	: cbc port map( 				CLK => CLK, rst_n => resetCBC, 
												--from interface
												data_in => data,
												enc_in => enc,
												session_in => session,
												key_in => key,
												key_len_in => key_lenght,
												--FROM SKMD
												valid_input => valid1,
												--from dataunit
												cryptrounddata	=> cryptrounddata1,
												cryptround_valid => cryptround_valid1,
												loading => loading1,
												--to DATA UNIT
												tocryptdata => tocryptdata1,
												curr_enc	=> enc1,
												reset_du => reset_du1,
												--to KEY GENERATOR
												curr_key => key1,
												curr_key_len => key_len1,
												curr_session => session1,
												ready_for_input => ready_for_input1,
												--TO SKMD
												valid_out => valid_out1,
												data_out	=> crypted_data1 );
												
												
	--SINGLE KEY MULTIPLE DATA CONTROLLER
	
	SKMD : SKMD_controller port map( CLK => CLK, rst_n => rst_n, 
												--FROM CAP
												valid_from_PC => valid_input,
												ready_to_send => ready_to_send,
												--FROM CBC
												done0	=> valid_out0,
												done1	=> valid_out1,
												datacrypt0 => crypted_data0,
												datacrypt1 => crypted_data1,
												session0 => session0,
												session1 => session1,
												enc0 => enc0,
												enc1 => enc1,
												ready_for_input0 => ready_for_input0,
												ready_for_input1 => ready_for_input1,
										-- OUTPUT	
												--TO CAP
												datacrypt_out => crypted_data,
												session_out	=> session_to_cap,
												enc_out => enc_to_cap,
												valid_to_serial => valid_out,
												ready_get_PC => ready_get_PC,
												-- TO CBC
												resetCBC	=> resetCBC,
												valid0 => valid0,
												valid1 => valid1 );
			
	--MERGE INPUT
	valid_input <= data_valid and key_valid;
	--SPLIT OUTPUT
	ready_for_data 	<= ready_get_PC;
	ready_for_key 		<=	ready_get_PC;
	

end arc;

