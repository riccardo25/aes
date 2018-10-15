library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity generator is
port(
	CLK, rst_n 		: in std_logic;
	
	-- INPUT
	key 				: in std_logic_vector (255 downto 0);
	key_len 			: in std_logic_vector (1 downto 0);
	
	-- OUTPUT
	valid 			: out std_logic;
	curr_round 		: out std_logic_vector (3 downto 0);
	dataround		: out std_logic_vector (127 downto 0)
);

end generator;

architecture arc of generator is

--COMPONENTS

	component gen_datapath is
		port(
			CLK, rst_n 									: in std_logic;
			key 											: in std_logic_vector (255 downto 0);
			sel_curr, sel_s, sel_t5, 
			sel_t7, sel_w6, sel_w7, sel_rcon, 
			sel_rconout			 						: in std_logic;
			sel_rotWord, sel_t4, 
			sel_t6, sel_w0, sel_w1, sel_w2, 
			sel_w3, sel_w4, 
			sel_w5, sel_dataround 					: in std_logic_vector (1 downto 0);
			load_curr 									: in std_logic;
			load_w0, load_w1, load_w2, load_w3, 
			load_w4, load_w5, load_w6, load_w7, 
			load_rcon 									: in std_logic;
			w0, w1, w2, w3, w4, w5, w6, w7 		: out std_logic_vector (31 downto 0);
			curr_round									: out std_logic_vector (3 downto 0);
			dataround									: out std_logic_vector (127 downto 0)
		);
	end component;
	
	component gen_control is
		port(
			CLK, rst_n : in std_logic;
			key_len 									: in std_logic_vector (1 downto 0);
			curr_round 								: in std_logic_vector (3 downto 0);
			valid 									: out std_logic;
			load_curr,
			sel_curr, sel_s, sel_t5, 
			sel_t7, sel_w6, sel_w7, 
			sel_rcon, sel_rconout				: out std_logic;
			sel_rotWord, 
			sel_t4, sel_t6, sel_w0, sel_w1, 
			sel_w2, sel_w3, sel_w4, sel_w5, 
			sel_dataround							: out std_logic_vector (1 downto 0);
			load_w0, load_w1, load_w2, 
			load_w3, load_w4, load_w5, 
			load_w6, load_w7, load_rcon		: out std_logic
		);
	end component;
	
	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;


--SIGNALS
	--signal key 	: std_logic_vector (255 downto 0) := X"00000000000000000000000000000000" & X"09cf4f3c" & X"abf71588" & X"28aed2a6"& X"2b7e1516"; --chiave da 128
	--signal key 	: std_logic_vector (255 downto 0) := X"0000000000000000" & X"522c6b7b" & X"62f8ead2" & X"809079e5" & X"c810f32b" & X"da0e6452"& X"8e73b0f7"; --chiave da 192
	--signal key 	: std_logic_vector (255 downto 0) := X"0914dff4" & X"2d9810a3" & X"3b6108d7" & X"1f352c07" & X"857d7781" & X"2b73aef0" & X"15ca71be"& X"603deb10"; --chiave da 256

	signal 	sel_curr, sel_s, sel_t5, sel_t7, sel_w6, 
				sel_w7, sel_rcon, sel_rconout, valid_signal				: std_logic;
	signal 	sel_rotWord, sel_t4, sel_t6, sel_w0, 
				sel_w1, sel_w2, sel_w3, sel_w4, sel_w5, sel_dataround	: std_logic_vector (1 downto 0);
	signal 	load_curr, load_w0, load_w1, load_w2, load_w3, 
				load_w4, load_w5, load_w6, load_w7, load_rcon			: std_logic;
	signal 	w0, w1, w2, w3, w4, w5, w6, w7 								: std_logic_vector (31 downto 0);
	signal 	valround_out_signal, valround_in_signal					: std_logic_vector (4 downto 0);
	signal 	curr_round_signal													: std_logic_vector (3 downto 0);
	signal 	dataround_signal													: std_logic_vector (127 downto 0);
	
begin

	DATPATH1	: gen_datapath port map(CLK => CLK, rst_n => rst_n,
		key => key ,
		w0 => w0, w1 => w1, w2 => w2, w3 => w3, w4 => w4, w5 => w5, w6 => w6, w7 => w7,
		sel_curr => sel_curr, sel_rconout => sel_rconout, sel_s => sel_s,
		sel_t4 => sel_t4, sel_t5 => sel_t5, sel_t6 => sel_t6, sel_t7 => sel_t7, 
		sel_rotWord => sel_rotWord, sel_rcon => sel_rcon,
		sel_w0 => sel_w0, sel_w1 => sel_w1, sel_w2 => sel_w2, sel_w3 => sel_w3, 
		sel_w4 => sel_w4, sel_w5 => sel_w5, sel_w6 => sel_w6, sel_w7 => sel_w7,
		load_curr => load_curr, load_rcon => load_rcon,
		load_w0 => load_w0, load_w1 => load_w1, load_w2 => load_w2, load_w3 => load_w3, 
		load_w4 => load_w4, load_w5 => load_w5, load_w6 => load_w6, load_w7 => load_w7,
		dataround => dataround_signal, curr_round => curr_round_signal, sel_dataround => sel_dataround);
	
	CTRLUNIT1 : gen_control port map(CLK => CLK, rst_n => rst_n,
		key_len => key_len,
		curr_round => curr_round_signal, sel_curr => sel_curr, sel_s => sel_s,
		sel_t4 => sel_t4, sel_t5 => sel_t5, sel_t6 => sel_t6, sel_t7 => sel_t7, sel_rcon=> sel_rcon,
		sel_rotWord => sel_rotWord, sel_rconout => sel_rconout,
		sel_w0 => sel_w0, sel_w1 => sel_w1, sel_w2 => sel_w2, sel_w3 => sel_w3, 
		sel_w4 => sel_w4, sel_w5 => sel_w5, sel_w6 => sel_w6, sel_w7 => sel_w7,
		load_curr => load_curr, load_rcon => load_rcon,
		load_w0 => load_w0, load_w1 => load_w1, load_w2 => load_w2, load_w3 => load_w3, 
		load_w4 => load_w4, load_w5 => load_w5, load_w6 => load_w6, load_w7 => load_w7, 
		valid => valid_signal, sel_dataround => sel_dataround);


	
	
--REGISTERS FOR PIPELINE data, valid and current round
	valround_in_signal <= valid_signal & curr_round_signal;
	VALROUND_REG : reg 	generic map(5) 	port map(CLK => CLK, rst_n => rst_n, load => '1', D => valround_in_signal, Q => valround_out_signal);
	DOU1	: reg 			generic map(128)	port map(CLK => CLK, rst_n => rst_n, load => '1', D => dataround_signal, Q => dataround);

--OUTPUT
	valid <= valround_out_signal(4);
	curr_round <= valround_out_signal(3 downto 0);
end arc;

