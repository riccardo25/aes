--==================================================================--
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx is
    port (
        CLK                 : in  std_logic;
        rst_n               : in  std_logic;                        -- active low
    -- control inputs
        SEND                : in  std_logic;
        ABORT               : in  std_logic;
    -- data inputs
        datain              : in  std_logic_vector(7 downto 0);
    -- data outputs
        TXD                 : out std_logic;
    -- status outputs
        DONE                : out std_logic
    );
end tx;
----------------------------------------


----------------------------------------
architecture s of tx is
    type statetype is (INIT, READY,
                       START,
                       SEND_BIT);

    signal state, nextstate                 : statetype := INIT;

    constant START_BIT                      : std_logic := '0';
    constant STOP_BIT                       : std_logic := '1';

    constant LIM                            : integer := 866;
    signal actual_data_to_send              : integer;

    signal Rdata,
           data_in                          : std_logic_vector(10 downto 0);
    signal load_data                        : std_logic;

    subtype cnt_type is integer range 0 to LIM+1 +1;
    signal Rcnt,
           cnt_in                           : cnt_type;
    signal load_cnt                         : std_logic;

    subtype nbits_type is integer range 0 to 12;
    signal Rbits,
           bits_in                          : nbits_type;
    signal load_bits                        : std_logic;

    signal CNT_eq_LIM                       : std_logic;
    signal BITS_eq_8                    : std_logic;


begin
    state <= INIT when rst_n = '0' else
             nextstate when rising_edge(CLK);

    process (state, SEND, ABORT, CNT_eq_LIM, BITS_eq_8)
    begin
        if ABORT = '1' then
            nextstate <= INIT;
        else
          case state is
            when INIT =>
                nextstate <= READY;
            when READY =>
                if SEND = '1' then
                        nextstate <= START;
                else
                    nextstate <= READY;
                end if;
            when START =>
                    nextstate <= SEND_BIT;
            when SEND_BIT =>
                if CNT_eq_LIM = '1' then
                    if BITS_eq_8 = '1' then
                        nextstate <= READY;
                    else
                        nextstate <= START;
                    end if;
                else
                    nextstate <= SEND_BIT;
                end if;
            when others =>
                    nextstate <= READY;
          end case;
        end if;
    end process;


    --------------------
    CNT_eq_LIM <= '1' when Rcnt = LIM else '0';

    BITS_eq_8 <= '1' when Rbits = actual_data_to_send else '0';
        actual_data_to_send <= 10;       -- word + start bit + stop bit
    --------------------

    --------------------
    --------------------

    --------------------
    Rdata <= data_in when rising_edge(CLK) and load_data = '1';
    load_data <= '1' when state = INIT or (state = READY and SEND = '1') or (state = SEND_BIT and CNT_eq_LIM = '1') else '0';
    with state select
        data_in <= STOP_BIT & STOP_BIT & datain & START_BIT             when READY,
                   STOP_BIT & Rdata(Rdata'left downto 1)                when SEND_BIT,
                   (others => STOP_BIT)                                 when INIT,
                   (others => '-')                                      when others;
    --------------------

    --------------------
    Rcnt  <= cnt_in  when rising_edge(CLK) and load_cnt = '1';
    load_cnt  <= '1' when state = START or state = SEND_BIT else '0';
    cnt_in <= 0         when state = START  else
              Rcnt + 1; -- when state = SEND_BIT
    --------------------

    --------------------
    Rbits <= bits_in when rising_edge(CLK) and load_bits = '1';
    load_bits <= '1' when state = READY or state = START else '0';
    bits_in <= 0        when state = READY                           else
              Rbits + 1; -- when state = START
    --------------------

    -- ctrl outputs
    DONE <= '1' when state = READY else '0';

    -- data outputs
    TXD <= Rdata(0);
end s;
----------------------------------------
--==================================================================--
