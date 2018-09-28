
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rotword is
    Port ( input : in  STD_LOGIC_VECTOR(31 downto 0);
           output : out  STD_LOGIC_VECTOR(31 downto 0)
			  );
end rotword;

architecture arc of rotword is

begin
 output <= input(23 downto 0) & input(31 downto 24);
end arc;

