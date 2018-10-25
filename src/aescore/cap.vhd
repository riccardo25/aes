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
		enc_from_cipher				: in std_logic;
		session_from_cipher			: in std_logic_vector(7 downto 0);
		
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
		SESSION							: out std_logic_vector (7 downto 0);
		ready_to_send					: out std_logic;
		-- serial OUTPUT
		TXD            				: out std_logic
	);

end cap;

architecture arc of cap is


	component cap_rx is
		 port(
		--INPUTS
			CLK, rst_n						: in std_logic;
			--from CIPHER
			ready_for_data					: in std_logic;
			ready_for_key					: in std_logic;
			--from SERIAL
			RX_FRAMEERR, RX_DATAVALID	: in std_logic;
			data_from_pc					: in std_logic_vector(7 downto 0);
		--OUTPUTS
			--to TOPLEVEL
			KEY								: out std_logic_vector(255 downto 0);
			ENC								: out std_logic;
			KEY_LEN							: out std_logic_vector(1 downto 0);
			SESSION							: out std_logic_vector(7 downto 0);
			DATA								: out std_logic_vector(127 downto 0);
			data_valid, key_valid		: out std_logic
		);
	end component;
	
	component cap_tx is
		port (
				CLK, rst_n 									: in std_logic;
			--INPUTS
				--from SERIAL
				TX_DONE  									: in std_logic;
				--from CIPHER
				valid_from_cipher							: in std_logic;
				data_from_cipher							: in std_logic_vector(127 downto 0);
				enc_from_cipher							: in std_logic;
				session_from_cipher						: in std_logic_vector(7 downto 0);
			--OUTPUTS
				--to SERIAL
				data_to_PC									: out std_logic_vector(7 downto 0);
				SEND 											: out std_logic;
				ready_to_send								: out std_logic
				
		);

	end component;
	

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
	
	
	

--COMMUNICATION SIGNALS

	signal	d_SESSION									: std_logic_vector(7 downto 0);
	
	
--SERIAL SIGNLAS
	signal SEND, ABORT, RX_FRAMEERR, RX_DATAVALID, TX_DONE: std_logic := '0';
	signal data_from_PC, data_to_PC : std_logic_vector(7 downto 0);

	
begin


	SER 		: serial port map( 	CLK=> CLK, rst_n => rst_n,        
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
								
	TX 		: cap_tx port map( 	CLK=> CLK, rst_n => rst_n,
											--from SERIAL
											TX_DONE => TX_DONE,
											--from CIPHER
											valid_from_cipher => valid_from_cipher, 
											data_from_cipher => data_from_cipher,
											enc_from_cipher => enc_from_cipher,
											session_from_cipher =>session_from_cipher,
											
											--to SERIAL
											data_to_PC => data_to_PC,
											SEND => SEND,
											--to cipher
											ready_to_send => ready_to_send);
											
	RX			: cap_rx port map( 	CLK=> CLK, rst_n => rst_n,
											--from CIPHER
											ready_for_data	=> ready_for_data,
											ready_for_key => ready_for_key,
											--from SERIAL
											RX_FRAMEERR => RX_FRAMEERR,
											RX_DATAVALID => RX_DATAVALID,
											data_from_pc => data_from_pc,
										--OUTPUTS
											KEY => KEY,
											ENC => ENC, 
											KEY_LEN => KEY_LEN,
											SESSION => d_SESSION,
											DATA => DATA,
											data_valid => data_valid, key_valid => key_valid );
-- BUTTON FOR DEBUG
	ABORT <=BTNU;
--DATAOUT	
	SESSION <= d_SESSION;
	datasend	<= session_from_cipher;
	
	
	end arc;

