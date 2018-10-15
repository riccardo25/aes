library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

	entity storage is

		port(
			CLK, rst_n : in std_logic;
			
			--INPUT FROM INTERFACE
			key 												: in std_logic_vector (255 downto 0);
			key_len 											: in std_logic_vector (1 downto 0);
			
			--INPUT FROM GENERATOR
			validin 											: in std_logic;
			datain											: in std_logic_vector (127 downto 0);
			curr_round										: in std_logic_vector (3 downto 0);
			
			--OUTPUT TO INTERFACE
			R0out, R1out, R2out, R3out, R4out, 
			R5out, R6out, R7out, R8out, R9out, 
			R10out, R11out, R12out, R13out, R14out	: out std_logic_vector(128 downto 0)
			
			
		);
	end storage;

architecture arc of storage is

	--signal key 	: std_logic_vector (255 downto 0) := X"0914dff4" & X"2d9810a3" & X"3b6108d7" & X"1f352c07" & X"857d7781" & X"2b73aef0" & X"15ca71be"& X"603deb10";
	--signal datain : std_logic_vector (127 downto 0):= X"01010101" & X"02020202" & X"03030303" & X"04040404" ;
	
	component reg is
		generic( N : integer);
		port (CLK, rst_n : in std_logic; load : in std_logic; D : in std_logic_vector(N-1 downto 0); Q : out std_logic_vector(N-1 downto 0));
	end component;
	
	signal 	load_R1,  load_R2,  load_R3,  load_R4,  
				load_R5,  load_R6,  load_R7,  load_R8,  load_R9,  
				load_R10, load_R11, load_R12, load_R13, load_R14			: std_logic;
				
	signal 	Rin																		: std_logic_vector (128 downto 0);
	signal 	sync_curr_round 														: std_logic_vector (3 downto 0);
	signal	sync_validin															: std_logic;
	signal 	sync_datain																: std_logic_vector (127 downto 0);
begin

--SYNC 128 + 4 + 1 + 4
	
--	SYNCURR	: reg generic map(4)	port map(CLK => CLK, rst_n => rst_n, load => '1', D => curr_round, Q => sync_curr_round);
--	sync_validin <= validin when rising_edge(CLK);
--	SYNDATA	: reg generic map(128)	port map(CLK => CLK, rst_n => rst_n, load => '1', D => datain, Q => sync_datain);
	
	sync_curr_round <=curr_round;
	sync_validin <= validin;
	sync_datain <= datain;
	


	load_R1     <= '1' when sync_curr_round = "0001" and sync_validin='1' else '0';  
	load_R2     <= '1' when sync_curr_round = "0010" and sync_validin='1' else '0';  
	load_R3     <= '1' when sync_curr_round = "0011" and sync_validin='1' else '0';  
	load_R4     <= '1' when sync_curr_round = "0100" and sync_validin='1' else '0';  
	load_R5     <= '1' when sync_curr_round = "0101" and sync_validin='1' else '0';  
	load_R6     <= '1' when sync_curr_round = "0110" and sync_validin='1' else '0';  
	load_R7     <= '1' when sync_curr_round = "0111" and sync_validin='1' else '0';  
	load_R8     <= '1' when sync_curr_round = "1000" and sync_validin='1' else '0';  
	load_R9     <= '1' when sync_curr_round = "1001" and sync_validin='1' else '0';  
	load_R10    <= '1' when sync_curr_round = "1010" and sync_validin='1' else '0'; 
	load_R11    <= '1' when sync_curr_round = "1011" and sync_validin='1' and (key_len="01" or key_len="10") else '0'; 
	load_R12    <= '1' when sync_curr_round = "1100" and sync_validin='1' and (key_len="01" or key_len="10") else '0'; 
	load_R13    <= '1' when sync_curr_round = "1101" and sync_validin='1' and  key_len="10" else '0'; 
	load_R14    <= '1' when sync_curr_round = "1110" and sync_validin='1' and  key_len="10" else '0';


-- REGISTERS

	Rin   <= sync_validin & sync_datain;
	
	--R0 don't need register -> it's always the key
	R0out <= '1' &  key(127 downto 0);
	R1		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R1, D => Rin, Q => R1out);
	R2		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R2, D => Rin, Q => R2out);
	R3		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R3, D => Rin, Q => R3out);
	R4		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R4, D => Rin, Q => R4out);
	R5		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R5, D => Rin, Q => R5out);
	R6		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R6, D => Rin, Q => R6out);
	R7		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R7, D => Rin, Q => R7out);
	R8		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R8, D => Rin, Q => R8out);
	R9		: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R9, D => Rin, Q => R9out);
	R10	: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R10, D => Rin, Q => R10out);
	R11	: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R11, D => Rin, Q => R11out);
	R12	: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R12, D => Rin, Q => R12out);
	R13	: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R13, D => Rin, Q => R13out);
	R14	: reg generic map(129)	port map(CLK => CLK, rst_n => rst_n, load => load_R14, D => Rin, Q => R14out);
	


end arc;

