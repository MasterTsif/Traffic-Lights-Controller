library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    port(
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        noisy     : in  STD_LOGIC;
        clean : buffer STD_LOGIC
    );
end debouncer;

architecture Behavioral of debouncer is
    signal sync_0, sync_1 : STD_LOGIC;
    signal counter : integer := 0;
    constant debounce_limit : integer := 50000000;
begin
    process(clk, rst)
    begin
        if rst = '0' then
            sync_0   <= '0';
            sync_1   <= '0';
            counter  <= 0;
            clean   <= '0';
        elsif rising_edge(clk) then
            sync_0 <= noisy   ;
            sync_1 <= sync_0;

            if clean = sync_1 then
                counter <= 0;
            else
                counter <= counter + 1;
                if counter >= debounce_limit then
                    clean <= sync_1;
                    counter <= 0;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
