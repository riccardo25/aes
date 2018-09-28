library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cap is

	port(
	--INPUTS
		CLK, rst_n						: in std_logic;
		
		--from CIPHER
		ready_for_data					: in std_logic;
		ready_for_key					: in std_logic;
		valid_from_cipher				: in std_logic;
		data_from_cipher				: in std_logic_vector(127 downto 0);
		
		-- serial INPUT
		RXD            				: in  std_logic;
		BTNU								: in  std_logic;
		
	--OUTPUTS
		datasend							: out std_logic_vector(7 downto 0);
		
		--TO CIPHER
		data_valid, key_valid		: out std_logic;
		ENC								: out std_logic;
		KEY								: out std_logic_vector(255 downto 0);
		KEY_LEN							: out std_logic_vector(1 downto 0);
		DATA								: out std_logic_vector(127 downto 0);
		
		-- serial OUTPUT
		TXD            				: out std_logic
	);

end cap;

architecture arc of cap is


	component serial is
		 port (
			  CLK                 : in  std_logic;
			  rst_n               : in  std_logic;                            -- active low
		 -- control inputs
			  SEND                : in  std_logic;
			  ABORT               : in  std_logic;
		 -- serial I/O
			  RXD                 : in  std_logic;
			  TXD                 : out std_logic;
		 -- parallel I/O
			  datain              : in  std_logic_vector(7 downto 0);   -- word to be sent to TXD
			  dataout             : out std_logic_vector(7 downto 0);   -- word received from RXD
		 -- status outputs
			  RX_FRAMEERR         : out std_logic;
			  RX_DATAVALID        : out std_logic;                            -- received a word from RXD
			  TX_DONE             : out std_logic                             -- transimtted a word to TXD
		 );
	end component;
	
	
	component cap_datapath is
		port(
			CLK, rst_n 									: in std_logic;
		--INPUTS
			--from CONTROL UNIT
			reset_reg, load_COUNTER, load_ENC, 
			load_SESSION, load_KEY_LEN, 
			load_KEY, load_DATA, reset_COUNTER 	: in std_logic;
			sel_KEY_LEN, sel_DATA					: in std_logic;
			sel_TOPC										: in std_logic_vector(1 downto 0);
			--FROM CIPHER
			data_from_cipher							: in std_logic_vector(127 downto 0);
			--from SERIAL
			data_from_pc								: in std_logic_vector(7 downto 0);
		--OUTPUTS
			--to control unit
			COUNTER										: out std_logic_vector(5 downto 0);
			--to toplevel
			KEY											: out std_logic_vector(255 downto 0);
			ENC											: out std_logic;
			KEY_LEN										: out std_logic_vector(1 downto 0);
			SESSION										: out std_logic_vector(7 downto 0);
			DATA											: out std_logic_vector(127 downto 0);
			--to serial
			data_to_pc									: out std_logic_vector(7 downto 0)
		);
	end component;
	
	
	component cap_controlunit is
		port(
			CLK, rst_n 									: in std_logic;
		--INPUTS
			--FROM DATAPATH
			COUNTER										: in std_logic_vector(5 downto 0);
			ENC											: in std_logic;
			--from CIPHER
			ready_for_data								: in std_logic;
			ready_for_key								: in std_logic;
			valid_from_cipher							: in std_logic;
			--from SERIAL
			RX_FRAMEERR, RX_DATAVALID, TX_DONE  : in std_logic;
			data_from_pc								: in std_logic_vector(7 downto 0);
		--OUTPUTS
			--TO DATAPATH
			reset_reg, load_COUNTER, load_ENC, 
			load_SESSION, load_KEY_LEN, 
			load_KEY, load_DATA, reset_COUNTER	: out std_logic;
			sel_KEY_LEN, sel_DATA					: out std_logic;
			sel_TOPC										: out std_logic_vector(1 downto 0);
			--TO CIPHER
			data_valid, key_valid					: out std_logic;
			--TO SERIAL
			SEND 											: out std_logic
		);
	end component;

--COMMUNICATION SIGNALS
	signal 	reset_reg, load_COUNTER, load_ENC, 
				load_SESSION, load_KEY_LEN, 
				load_KEY, load_DATA, reset_COUNTER	: std_logic;
	signal 	sel_KEY_LEN, sel_DATA					: std_logic;
	signal 	sel_TOPC										: std_logic_vector(1 downto 0);
	signal	COUNTER										: std_logic_vector(5 downto 0);
	signal	SESSION										: std_logic_vector(7 downto 0);
--	signal	ENC											: std_logic;
	
--TOPLEVEL SIGNALS
--	signal	KEY											: std_logic_vector(255 downto 0);
--	signal	KEY_LEN										: std_logic_vector(1 downto 0);
--	signal	DATA											: std_logic_vector(127 downto 0);
--	signal 	data_from_cipher							: std_logic_vector(127 downto 0):= X"707172737475767778797A7B7C7D7E7F";
	signal 	d_valid, k_valid, ENC_out				: std_logic;
	
--SERIAL SIGNLAS
	signal SEND, ABORT, RX_FRAMEERR, RX_DATAVALID, TX_DONE: std_logic := '0';
	signal data_from_PC, data_to_PC : std_logic_vector(7 downto 0);

	
begin


	SER 		: serial port map(
								CLK=> CLK, rst_n => rst_n,        
						 -- control inputs
							   SEND => SEND,
							   ABORT  => ABORT,
						 -- serial I/O
							   RXD => RXD,
							   TXD => TXD,
						 -- parallel I/O
							   datain =>  data_to_PC,
							   dataout =>  data_from_PC,
						 -- status outputs
							   RX_FRAMEERR => RX_FRAMEERR,
							   RX_DATAVALID => RX_DATAVALID,   -- received a word from RXD
							   TX_DONE => TX_DONE);
								
	
	CTRLUNIT	: cap_controlunit  port map(
								CLK=> CLK, rst_n => rst_n,
								COUNTER => COUNTER, ENC => ENC_out,
								ready_for_data	=> ready_for_data,
								ready_for_key => ready_for_key,
								sel_TOPC	=> sel_TOPC,
								data_valid => d_valid, key_valid => k_valid,
								valid_from_cipher	=> valid_from_cipher,
								RX_FRAMEERR => RX_FRAMEERR, RX_DATAVALID => RX_DATAVALID, TX_DONE => TX_DONE,
								data_from_pc => data_from_pc, reset_COUNTER => reset_COUNTER,
								reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC, 
								load_SESSION => load_SESSION, load_KEY_LEN => load_KEY_LEN, 
								load_KEY => load_KEY, load_DATA => load_DATA,
								sel_KEY_LEN	=> sel_KEY_LEN, sel_DATA => sel_DATA,
								SEND => SEND );

	DATAPATH	: cap_datapath	port map(
								CLK => CLK, rst_n => rst_n,
								reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC, 
								load_SESSION => load_SESSION, load_KEY_LEN => load_KEY_LEN, 
								load_KEY => load_KEY, load_DATA => load_DATA, reset_COUNTER => reset_COUNTER,
								sel_KEY_LEN	=> sel_KEY_LEN, sel_DATA => sel_DATA,
								data_from_cipher => data_from_cipher,
								data_from_pc => data_from_pc, sel_TOPC => sel_TOPC,
								COUNTER => COUNTER,
								KEY => KEY,
								ENC => ENC_out,
								KEY_LEN => KEY_LEN,
								SESSION => SESSION,
								DATA => DATA,	
								data_to_pc => data_to_PC );
--DATAOUT	
	data_valid <= d_valid;
	key_valid <= k_valid;
	ENC <= ENC_out;
	datasend	<= SESSION;
	ABORT <=BTNU;
	
	end arc;

