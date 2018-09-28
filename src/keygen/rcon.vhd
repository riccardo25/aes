library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rcon is

port (

	input: in std_logic_vector(3 downto 0);
	output: out std_logic_vector(31 downto 0)
);
end rcon;

architecture arc of rcon is

begin

	output <= 	("00000001" & "000000000000000000000000") when input= "0000" else
					("00000010" & "000000000000000000000000") when input= "0001" else
					("00000100" & "000000000000000000000000") when input= "0010" else
					("00001000" & "000000000000000000000000") when input= "0011" else
					("00010000" & "000000000000000000000000") when input= "0100" else
					("00100000" & "000000000000000000000000") when input= "0101" else
					("01000000" & "000000000000000000000000") when input= "0110" else
					("10000000" & "000000000000000000000000") when input= "0111" else
					("00011011" & "000000000000000000000000") when input= "1000" else
					("00110110" & "000000000000000000000000") when input= "1001" else
					("00000000000000000000000000000000");
end arc;

