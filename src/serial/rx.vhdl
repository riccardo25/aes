--==================================================================--
----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx is
    port (
        CLK                 : in  std_logic;
        rst_n               : in  std_logic;                        -- active low
    -- control inputs
        ABORT               : in  std_logic;
    -- data inputs
        RXD                 : in  std_logic;
    -- data outputs
        dataout             : out std_logic_vector(7 downto 0);
    -- status outputs
        FRAMEERR            : out std_logic;
        DATAVALID           : out std_logic
    );
end rx;
----------------------------------------


----------------------------------------
architecture s of rx is
    type statetype is (INIT,
                       WAIT_HALF_START, CHECK_START,
                       WAIT_BIT, STORE_BIT, CHECK_STOP);

    signal state, nextstate                 : statetype := INIT;

    constant START_BIT                      : std_logic := '0';
    constant STOP_BIT                       : std_logic := '1';

    constant LIM                            : integer := 866;
    constant HALF_LIM                       : integer := LIM / 2;
    signal actual_data_to_get               : integer;

    signal Rdata,
           data_in                          : std_logic_vector(9 downto 0);
    signal load_data                        : std_logic;

    subtype cnt_type is integer range 0 to LIM+1;
    signal Rcnt,
           cnt_in                           : cnt_type;
    signal load_cnt                         : std_logic;

    subtype nbits_type is integer range 0 to 11;
    signal Rbits,
           bits_in                          : nbits_type;
    signal load_bits                        : std_logic;

    signal CNT_eq_HALFLIM                   : std_logic;
    signal CNT_eq_LIM                       : std_logic;
    signal BITS_eq_8                    : std_logic;


    signal Rframeerr,
           frameerr_in                      : std_logic;
    signal load_frameerr                    : std_logic;


    signal Rdatavalid,
           datavalid_in                     : std_logic;
    signal load_datavalid                   : std_logic;

    signal Rdataout,
           dataout_in                       : std_logic_vector(dataout'range);
    signal load_dataout                     : std_logic;
begin
    state <= INIT when rst_n = '0' else
             nextstate when rising_edge(CLK);

    process (state, ABORT, RXD, CNT_eq_HALFLIM, CNT_eq_LIM, BITS_eq_8)
    begin
        if ABORT = '1' then
            nextstate <= INIT;
        else
          case state is
            when INIT =>
                if RXD /= START_BIT then
                    nextstate <= INIT;
                else
                    nextstate <= WAIT_HALF_START;
                end if;
            when WAIT_HALF_START =>
                if CNT_eq_HALFLIM = '1' then
                    nextstate <= CHECK_START;
                else
                    nextstate <= WAIT_HALF_START;
                end if;
            when CHECK_START =>
                if RXD /= START_BIT then
                    nextstate <= INIT;
                else
                    nextstate <= WAIT_BIT;
                end if;
            when WAIT_BIT =>
                if CNT_eq_LIM = '1' then
                    nextstate <= STORE_BIT;
                else
                    nextstate <= WAIT_BIT;
                end if;
            when STORE_BIT =>
                if BITS_eq_8 = '1' then
                    nextstate <= CHECK_STOP;
                else
                    nextstate <= WAIT_BIT;
                end if;
            when CHECK_STOP =>
                nextstate <= INIT;
            when others =>
                    nextstate <= INIT;
          end case;
        end if;
    end process;


    --------------------
    CNT_eq_HALFLIM <= '1' when Rcnt = HALF_LIM else '0';
    CNT_eq_LIM <= '1' when Rcnt = LIM else '0';

    BITS_eq_8 <= '1' when Rbits = actual_data_to_get-1 else '0';
        actual_data_to_get <= 9;        -- word + stop bit
    --------------------

    --------------------
    Rdata <= data_in when rising_edge(CLK) and load_data = '1';
    load_data <= '1' when state = STORE_BIT else '0';
    data_in <= RXD & Rdata(Rdata'left downto 1) when state = STORE_BIT else
               (others => '-');
    --------------------

    --------------------
    Rcnt  <= cnt_in  when rising_edge(CLK) and load_cnt = '1';
    load_cnt  <= '1' when state = INIT or state = WAIT_HALF_START or state = CHECK_START or state = WAIT_BIT or state = STORE_BIT else '0';
    cnt_in <= 0         when state = INIT or state = CHECK_START or state = STORE_BIT else
              Rcnt + 1; -- when state = WAIT_HALF_START or state = WAIT_BIT
    --------------------

    --------------------
    Rbits <= bits_in when rising_edge(CLK) and load_bits = '1';
    load_bits <= '1' when state = INIT or state = STORE_BIT else '0';
    bits_in <= 0        when state = INIT                           else
               Rbits + 1; -- when state = STORE_BIT
    --------------------

    --------------------
    Rframeerr  <= frameerr_in when rising_edge(CLK) and load_frameerr = '1';
    load_frameerr <= '1' when state = CHECK_STOP else '0';
    FRAMEERR_in <= '1' when state = CHECK_STOP and Rdata(Rdata'left) /= STOP_BIT else
                   '0' when state = CHECK_STOP and Rdata(Rdata'left) =  STOP_BIT else
                   '-';
    --------------------

    --------------------
    --------------------

    --------------------
    Rdatavalid <= datavalid_in when rising_edge(CLK) and load_datavalid = '1';
    load_datavalid <= '1' when state = CHECK_STOP or state = INIT else '0';
    datavalid_in <= '1' when state = CHECK_STOP else
                    '0' when state = INIT else
                    '-';
    --------------------

    --------------------
    Rdataout <= dataout_in when rising_edge(CLK) and load_dataout = '1';
    load_dataout <= '1' when state = CHECK_STOP else '0';
        dataout_in <= Rdata(Rdata'left - 1 downto 1) when state = CHECK_STOP else (others => '-');
    --------------------

    -- ctrl outputs

    -- data outputs
    FRAMEERR  <= Rframeerr;
    DATAVALID <= Rdatavalid;
    dataout   <= Rdataout;
end s;
----------------------------------------
--==================================================================--
