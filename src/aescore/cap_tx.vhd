library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cap_tx is
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
			--TO CIPHER
			ready_to_send								: out std_logic
	);

end cap_tx;

architecture arc of cap_tx is

	component cap_tx_ctrlunit is

		port(
			CLK, rst_n 									: in std_logic;
		--INPUTS
			--FROM DATAPATH
			COUNTER										: in std_logic_vector(5 downto 0);
			ENC											: in std_logic;
			--from CIPHER
			valid_from_cipher							: in std_logic;
			--from SERIAL
			TX_DONE  									: in std_logic;
		--OUTPUTS
			--TO DATAPATH
			reset_reg, load_COUNTER, load_ENC, 
			load_SESSION,  load_DATA, 
			reset_COUNTER								: out std_logic;
			sel_DATA										: out std_logic;
			sel_TOPC										: out std_logic_vector(1 downto 0);
			--TO SERIAL
			SEND 											: out std_logic;
			--TO CIPHER
			ready_to_send								: out std_logic
			
		);

	end component;

	component cap_tx_datapath is

		port(
			CLK, rst_n 									: in std_logic;
		--INPUTS
			--from CONTROL UNIT
			reset_reg, load_COUNTER, load_ENC, 
			load_SESSION,  load_DATA, 
			reset_COUNTER								: in std_logic;
			sel_DATA										: in std_logic;
			sel_TOPC										: in std_logic_vector(1 downto 0);
			--FROM CIPHER
			data_from_cipher							: in std_logic_vector(127 downto 0);
			enc_from_cipher							: in std_logic;
			session_from_cipher						: in std_logic_vector(7 downto 0);
		--OUTPUTS
			--to control unit
			COUNTER										: out std_logic_vector(5 downto 0);
			ENC											: out std_logic;
			--to serial
			data_to_pc									: out std_logic_vector(7 downto 0)
		);
	end component;
	
	--COMMUNICATION SIGNALS
	signal 	reset_reg, load_COUNTER, load_ENC, 
				load_SESSION, load_DATA, 
				reset_COUNTER, sel_DATA				: std_logic;
	signal 	sel_TOPC									: std_logic_vector(1 downto 0);
	signal	COUNTER									: std_logic_vector(5 downto 0);
	signal	SESSION									: std_logic_vector(7 downto 0);
	signal 	ENC										: std_logic;
	
	

begin


	CTRLUNIT: cap_tx_ctrlunit port map( 	CLK => CLK, rst_n => rst_n,
														COUNTER => COUNTER,
														ENC => enc_from_cipher,
														valid_from_cipher	=> valid_from_cipher,
														TX_DONE => TX_DONE,
														reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC, 
														load_SESSION => load_SESSION,  load_DATA => load_DATA, 
														reset_COUNTER => reset_COUNTER,
														sel_DATA	=> sel_DATA,
														sel_TOPC	=> sel_TOPC,
														ready_to_send => ready_to_send,
														SEND 	=> SEND
														);
														
	DATAPATH: cap_tx_datapath port map(		CLK => CLK, rst_n => rst_n,
														reset_reg => reset_reg, load_COUNTER => load_COUNTER, load_ENC => load_ENC, 
														load_SESSION => load_SESSION,  load_DATA => load_DATA, 
														reset_COUNTER => reset_COUNTER,
														sel_DATA	=> sel_DATA,
														sel_TOPC	=> sel_TOPC,
														data_from_cipher => data_from_cipher,
														enc_from_cipher => enc_from_cipher,
														session_from_cipher => session_from_cipher,
														COUNTER => COUNTER,
														ENC => ENC,
														data_to_pc => data_to_pc );

end arc;

