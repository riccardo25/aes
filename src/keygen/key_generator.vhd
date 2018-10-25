library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity key_generator is

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
end key_generator;

architecture arc of key_generator is

	--signal key 	: std_logic_vector (255 downto 0) := X"00000000000000000000000000000000" & X"0c0d0e0f08090a0b0405060700010203";
	--signal key 	: std_logic_vector (255 downto 0) := X"00000000000000000000000000000000" & X"09cf4f3c" & X"abf71588" & X"28aed2a6"& X"2b7e1516";
	--signal key 	: std_logic_vector (255 downto 0) := X"0000000000000000" & X"522c6b7b" & X"62f8ead2" & X"809079e5" & X"c810f32b" & X"da0e6452"& X"8e73b0f7";
	--signal key 	: std_logic_vector (255 downto 0) := X"0914dff4" & X"2d9810a3" & X"3b6108d7" & X"1f352c07" & X"857d7781" & X"2b73aef0" & X"15ca71be"& X"603deb10";
	
	
	component key_interface is
		port(
			CLK, rst_n									: in std_logic;
			--INPUT FROM TOPLEVEL
			key											: in std_logic_vector( 255 downto 0);
			key_len										: in std_logic_vector( 1 downto 0);
			ROUND0										: in std_logic_vector( 3 downto 0);	
			enc0											: in std_logic;
			ROUND1										: in std_logic_vector( 3 downto 0);	
			enc1											: in std_logic;
			--INPUT FROM STORE
			R0in, R1in, R2in, R3in, R4in, 
			R5in, R6in, R7in, R8in, R9in, 
			R10in, R11in, R12in, R13in, R14in	: in std_logic_vector(128 downto 0);
			--OUTPUT TO GEN AND STORE
			reset											: out std_logic;
			key_out										: out std_logic_vector( 255 downto 0);
			key_len_out									: out std_logic_vector( 1 downto 0);			
			--OUTPUT TO TOPLEVEL
			valid0										: out std_logic;
			data_out0 									: out std_logic_vector( 127 downto 0);
			valid1										: out std_logic;
			data_out1 									: out std_logic_vector( 127 downto 0)
		);
	end component;

	component generator is
	port(
		CLK, rst_n 		: in std_logic;
		key 				: in std_logic_vector (255 downto 0);
		key_len 			: in std_logic_vector (1 downto 0); 
		valid 			: out std_logic;
		curr_round 		: out std_logic_vector (3 downto 0);
		dataround		: out std_logic_vector (127 downto 0)
	);

	end component;
	
	
	component storage is
		port(
		CLK, rst_n : in std_logic;
		key 												: in std_logic_vector (255 downto 0);
		key_len 											: in std_logic_vector (1 downto 0);
		validin 											: in std_logic;
		datain											: in std_logic_vector (127 downto 0);
		curr_round										: in std_logic_vector (3 downto 0);
		R0out, R1out, R2out, R3out, R4out, 
		R5out, R6out, R7out, R8out, R9out, 
		R10out, R11out, R12out, R13out, R14out	: out std_logic_vector(128 downto 0)
		);
	end component;
	
	signal data_gentostore 					: std_logic_vector (127 downto 0);
	signal curr_round_gentostore			: std_logic_vector (3 downto 0);
	signal valid_gentostore, int_reset	: std_logic;
	
	signal 	R0, R1, R2,	R3, R4, R5, R6, 
				R7, R8, R9, R10, R11, 
				R12, R13, R14					: std_logic_vector(128 downto 0);
				
	signal int_key			 					: std_logic_vector (255 downto 0);
	signal int_key_len		 				: std_logic_vector (1 downto 0);

begin


	GEN 	: generator port map(	CLK => CLK, rst_n => int_reset, key => int_key , key_len => int_key_len,
											valid => valid_gentostore, dataround =>data_gentostore,
											curr_round => curr_round_gentostore);
										
										
	STORE_k: storage 	port map(	CLK => CLK, rst_n => int_reset, key => int_key , key_len => int_key_len,
											validin => valid_gentostore, datain =>data_gentostore,
											curr_round => curr_round_gentostore, R0out => R0 , R1out => R1 , 
											R2out => R2 , R3out => R3, R4out => R4 , R5out => R5 , R6out => R6, 
											R7out => R7 , R8out => R8 , R9out => R9 , R10out => R10, 
											R11out => R11, R12out => R12, R13out => R13, R14out => R14);
										
	
	INTE: key_interface port map(	CLK => CLK, rst_n => rst_n, 
											key => key , key_len => key_len, 
											ROUND0 => ROUND0,	ROUND1 => ROUND1,
											enc0 => enc0, enc1 => enc1,
											R0in => R0 , R1in => R1 , R2in => R2 , R3in => R3, 
											R4in => R4 , R5in => R5 , R6in => R6 , R7in => R7 , R8in => R8 , 
											R9in => R9 , R10in => R10, R11in => R11, R12in => R12, R13in => R13, 
											R14in => R14, reset =>int_reset, key_out=> int_key, key_len_out => int_key_len, 
											valid0	=> valid_out0, valid1 => valid_out1,
											data_out0 => data_out0, data_out1 => data_out1 );
											


end arc;

