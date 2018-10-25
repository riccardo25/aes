
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity gen_datapath is

port(
	CLK, rst_n 										: in std_logic;
	
	-- INPUT
	key 												: in std_logic_vector (255 downto 0);
	
	--from controller
	sel_curr, sel_s, sel_t5, sel_t7, 
	sel_w6, sel_w7, sel_rcon, sel_rconout	: in std_logic;
	sel_rotWord, sel_t4, 
	sel_t6, sel_w0, sel_w1, sel_w2, 
	sel_w3, sel_w4, sel_w5, sel_dataround	: in std_logic_vector (1 downto 0);
	
	load_curr, load_rcon 						: in std_logic;
	load_w0, load_w1, load_w2, load_w3, 
	load_w4, load_w5, load_w6, load_w7 		: in std_logic;
	
	--to controller
	w0, w1, w2, w3, w4, w5, w6, w7 			: out std_logic_vector (31 downto 0);
	
	-- OUTPUT
	curr_round										: out std_logic_vector (3 downto 0);
	dataround										: out std_logic_vector (127 downto 0)
);

end gen_datapath;

architecture arc of gen_datapath is


	component sbox is
		port (
			CLK, rst_n 		: in std_logic;
			data_in 			: in std_logic_vector(7 downto 0);
			data_out 		: out std_logic_vector(7 downto 0);
			enc				: in std_logic
		);
	end component;

	component mux3input is
		generic (N: integer);
		port (
			sel 	: in std_logic_vector(1 downto 0);
			I0 	: in std_logic_vector(N-1 downto 0);
			I1 	: in std_logic_vector(N-1 downto 0);
			I2 	: in std_logic_vector(N-1 downto 0);
			Y 		: out std_logic_vector(N-1 downto 0)
		);
	end component;


	component mux2input is
		generic (N: integer);
		port (
			sel 	: in std_logic;
			I0 	: in std_logic_vector(N-1 downto 0);
			I1 	: in std_logic_vector(N-1 downto 0);
			Y 		: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component mux4input is
		generic (N: integer);
		port (
			sel 	: in std_logic_vector(1 downto 0);
			I0 	: in std_logic_vector(N-1 downto 0);
			I1 	: in std_logic_vector(N-1 downto 0);
			I2 	: in std_logic_vector(N-1 downto 0);
			I3 	: in std_logic_vector(N-1 downto 0);
			Y 		: out std_logic_vector(N-1 downto 0)
		);
	end component;


	component rotword is
		 Port ( input : in  STD_LOGIC_VECTOR(31 downto 0); output : out  STD_LOGIC_VECTOR(31 downto 0) );
	end component;

	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;


	component rcon is
		port ( input : in std_logic_vector(3 downto 0); output: out std_logic_vector(31 downto 0));
	end component;
	
	component adder2input is
		generic (N: integer);
		port (
			I0 	: in std_logic_vector(N-1 downto 0);
			I1 	: in std_logic_vector(N-1 downto 0);
			Y 		: out std_logic_vector(N-1 downto 0)
		);
	end component;


	signal 	t4, t5, t6, t7, rconsel_outmux		: std_logic_vector (31 downto 0);
	signal 	w0_out, w1_out, w2_out, w3_out, 
				w4_out, w5_out, w6_out, w7_out 		: std_logic_vector (31 downto 0);
	signal 	w0sel, w1sel, w2sel, w3sel, w4sel, 
				w5sel, w6sel, w7sel 						: std_logic_vector (31 downto 0);
	signal 	p, q, s, r, x1, rcon_out 				: std_logic_vector (31 downto 0);
	signal 	currsel_out, curr_out, adder_sig,
				rcon_round, rconsel_out, rcon_add	: std_logic_vector (3 downto 0);
	signal 	w0w3out, w2w5out, w4w7out				: std_logic_vector (127 downto 0);
	signal 	t4w1, x1w0, w5w0, t5w2, x1w2, 
				t6w3, t6w1 									: std_logic_vector (31 downto 0); 

begin

-- CURR_ROUND
	ADD1 : adder2input 	generic map(4)	 port map( I0 => "0001", I1=>curr_out, Y => adder_sig);
	MUX1 : mux2input 		generic map(4)	 port map(sel=> sel_curr, I0 => (others => '0'), I1 => adder_sig, Y=>currsel_out);
	CURR1: reg 				generic map(4)	 port map(CLK => CLK, rst_n => rst_n, load => load_curr, D => currsel_out, Q => curr_out);

--RCON_ROUND
	ADD2  : adder2input 	generic map(4)	 port map( I0 => "0001", I1=>rcon_round, Y => rcon_add);
	MUXRC : mux2input 	generic map(4)	 port map(sel=> sel_rcon, I0 => (others => '0'), I1 =>rcon_add , Y=>rconsel_out);
	CUREC : reg 			generic map(4)	 port map(CLK => CLK, rst_n => rst_n, load => load_rcon, D => rconsel_out, Q => rcon_round);

-- X1 BLOCK
	MUX2 : mux4input 		generic map(32) port map(sel => sel_rotWord, I0 => w3_out, I1 => t5, I2 =>w7_out, I3 => w5_out, Y=>p);
	ROT1 : rotword 							 port map( input => p, output => r);
	MUX3 : mux2input 		generic map(32) port map(sel=> sel_s, I0 => w7_out, I1 => r, Y=> s );
	
	
	SBX1 : sbox 								 port map(CLK=> CLK, rst_n=>rst_n, data_in => s(31 downto 24), data_out=>q(31 downto 24), enc=>'1');
	SBX2 : sbox  								 port map(CLK=> CLK, rst_n=>rst_n, data_in => s(23 downto 16), data_out=>q(23 downto 16), enc=>'1');
	SBX3 : sbox 								 port map(CLK=> CLK, rst_n=>rst_n, data_in => s(15 downto 8), data_out=>q(15 downto 8), enc=>'1');
	SBX4 : sbox 								 port map(CLK=> CLK, rst_n=>rst_n, data_in => s(7 downto 0), data_out=>q(7 downto 0), enc=>'1');
	
	RCON1 : rcon 								 port map(input => rcon_round, output => rconsel_outmux);
	MUX9 : mux2input 		generic map(32) port map(sel=> sel_rconout, I0 => rconsel_outmux, I1 => "00000000000000000000000000000000", Y=> rcon_out );
	x1 		<= (q xor rcon_out);
	
-- DATAROUND 
	w0w3out 	<= (w3_out & w2_out & w1_out & w0_out);
	w2w5out 	<= (w5_out & w4_out & w3_out & w2_out);
	w4w7out 	<= (w7_out & w6_out & w5_out & w4_out);
	
	MUX4a : mux3input 	generic map(128) port map(sel=> sel_dataround, I0 => w0w3out, I1 =>w2w5out , I2 => w4w7out, Y=> dataround );

-- REGISTER FOR PIPELINE
	

-- t4
	x1w0 		<=(x1 xor w0_out);
	w5w0 		<=(w5_out xor w0_out);
	MUX5 : mux3input 		generic map(32) port map(sel => sel_t4, I0 => x1w0, I1 => key(159 downto 128), I2 =>w5w0, Y=>t4);
-- t5
	t4w1 		<= (t4 xor w1_out);
	MUX6 : mux2input 		generic map(32) port map(sel=> sel_t5, I0 => t4w1, I1 => key(191 downto 160), Y=> t5 );
	
-- t6
	t5w2 		<= (t5 xor w2_out);
	x1w2 		<= (x1 xor w2_out);
	MUX7 : mux3input 		generic map(32) port map(sel => sel_t6, I0 => t5w2, I1 => x1w0, I2 =>x1w2, Y=>t6);
	
-- t7
	t6w3 		<= (t6 xor w3_out);
	t6w1 		<= (t6 xor w1_out);
	MUX8 : mux2input 		generic map(32) port map(sel=> sel_t7, I0 =>t6w3 , I1 =>t6w1, Y=> t7 );
	
	
-- w0
	
	MUXW0 : mux4input 	generic map(32) port map(sel => sel_w0, I0 => key(31 downto 0), I1 => t4, I2 =>w4_out, I3 => w2_out, Y=>w0sel);
	REGW0: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w0, D => w0sel, Q => w0_out);
	
-- W1

	MUXW1 : mux4input 	generic map(32) port map(sel => sel_w1, I0 => key(63 downto 32), I1 => t5, I2 =>w5_out, I3 => w3_out, Y=>w1sel);
	REGw1: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w1, D => w1sel, Q => w1_out);
	
-- W2
	MUXW2 : mux4input 	generic map(32) port map(sel => sel_w2, I0 => key(95 downto 64), I1 => t6, I2 =>t4, I3=>w6_out, Y=>w2sel);
	REGw2: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w2, D => w2sel, Q => w2_out);
	
-- W3
	MUXw3 : mux4input 	generic map(32) port map(sel => sel_w3, I0 => key(127 downto 96), I1 => t7, I2 =>t5, I3=>w7_out, Y=>w3sel);
	REGw3: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w3, D => w3sel, Q => w3_out);
	
-- W4
	MUXw4 : mux3input 	generic map(32) port map(sel => sel_w4, I0 => key(159 downto 128), I1 => t6, I2 =>t4, Y=>w4sel);
	REGw4: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w4, D => w4sel, Q => w4_out);

-- W5
	MUXw5 : mux3input 	generic map(32) port map(sel => sel_w5, I0 => key(191 downto 160), I1 => t7, I2 =>t5, Y=>w5sel);
	REGw5: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w5, D => w5sel, Q => w5_out);
	
-- W6

	MUXw6 : mux2input 	generic map(32) port map(sel => sel_w6, I0 => key(223 downto 192), I1 => t6, Y=>w6sel);
	REGw6: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w6, D => w6sel, Q => w6_out);
	
-- W7

	MUXw7 : mux2input 	generic map(32) port map(sel => sel_w7, I0 => key(255 downto 224), I1 => t7, Y=>w7sel);
	REGw7: reg 				generic map(32) port map(CLK => CLK, rst_n => rst_n, load => load_w7, D => w7sel, Q => w7_out);

--OUTPUT DATA
	curr_round 	<= curr_out;
	w0 			<= w0_out;
	w1 			<= w1_out;
	w2 			<= w2_out;
	w3 			<= w3_out;
	w4 			<= w4_out;
	w5 			<= w5_out;
	w6 			<= w6_out;
	w7 			<= w7_out;

end arc;

