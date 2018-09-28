--==================================================================--
library ieee;
use ieee.std_logic_1164.all;

entity serial is
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
end serial;


architecture struct of serial is
    signal RXD_s1, RXD_s2                   : std_logic;
begin
    TXDEV : entity work.tx
            port map (
                CLK     =>  CLK,
                rst_n   =>  rst_n,
                SEND    =>  SEND,
                ABORT   =>  ABORT,
                datain  =>  datain,
                TXD     =>  TXD,
                DONE    =>  TX_DONE
            );

    -- synchronizer
    RXD_s1 <= RXD    when rising_edge(CLK);
    RXD_s2 <= RXD_s1 when rising_edge(CLK);

    RXDEV : entity work.rx
            port map (
                CLK         =>  CLK,
                rst_n       =>  rst_n,
                ABORT       =>  ABORT,
                RXD         =>  RXD_s2,
                dataout     =>  dataout,
                FRAMEERR    =>  RX_FRAMEERR,
                DATAVALID   =>  RX_DATAVALID
            );
end struct;
--==================================================================--
