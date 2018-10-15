----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:16:27 09/26/2018 
-- Design Name: 
-- Module Name:    aescore - arc 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aescore is
	port(
			CLK, rst_n 							: in std_logic;
			RXD                 				: in  std_logic;
			BTNU									: in  std_logic;
		--OUTPUT
			TXD                 				: out std_logic;
			test_out								: out std_logic_vector (7 downto 0)
	
	);
end aescore;

architecture arc of aescore is

	component cipher is
		port (
					--INPUT
						CLK, rst_n 							: in std_logic;
						data									: in std_logic_vector (127 downto 0);
						data_valid							: in  std_logic;
						session								: in std_logic_vector (7 downto 0);
						key_valid							: in  std_logic;
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
	end component;
	
	
	
	component cap is
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

	end component;
	
	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	signal 	CLK_new					  					: std_logic :='0';
	signal 	key_valid, data_valid,
				ready_for_data, ready_for_key, 
				valid_out 									: std_logic :='1';
	signal 	enc 											: std_logic :='1';
	signal 	key											: std_logic_vector(255 downto 0);
	signal	key_len 										: std_logic_vector(1 downto 0) := "00";
	signal 	data, crypted_data						: std_logic_vector(127 downto 0);
	signal 	enc_from_cipher							: std_logic;
	signal 	session_from_cipher						: std_logic_vector(7 downto 0);
	signal	session_to_cipher							: std_logic_vector (7 downto 0);
	signal 	ready_to_send								: std_logic;
	
	signal 	datauseless									: std_logic_vector(7 downto 0);
	

begin

--CLOCK SLOWER
	--REGCK 	: CLK_new <= (not CLK_new) when rising_edge(CLK);
	
	CLK_new <= CLK;
	
	AES1		: cipher port map (
						CLK=> CLK_new, rst_n => rst_n,
						data => data,
						data_valid => data_valid,
						key_valid => key_valid,
						session => session_to_cipher,
						key => key,
						key_lenght => key_len,
						enc => enc,
						ready_to_send	=> ready_to_send,
						ready_for_data	=> ready_for_data,
						ready_for_key	=> ready_for_key,
						enc_to_cap => enc_from_cipher,
						session_to_cap => session_from_cipher,
						valid_out => valid_out,
						crypted_data => crypted_data
					);
								
	TRANSM	: cap port map(
						CLK => CLK, rst_n => rst_n,
						ready_for_data	=> ready_for_data,
						ready_for_key => ready_for_key,
						valid_from_cipher	=> valid_out,
						data_from_cipher => crypted_data,
						enc_from_cipher => enc_from_cipher,
						session_from_cipher => session_from_cipher,
						RXD  => RXD,
						BTNU	=> BTNU,
						datasend	=> datauseless,--test_out,
						data_valid => data_valid, 
						key_valid => key_valid,
						ENC => enc,
						KEY => KEY,
						KEY_LEN => key_len,
						DATA => data,
						SESSION => session_to_cipher,
						ready_to_send => ready_to_send,
						TXD => TXD );


					
	test_out <= session_from_cipher;
	

end arc;

