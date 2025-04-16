library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        clk_in  : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : integer := 0;
    signal clk_sig : STD_LOGIC := '0';
begin
    process(clk_in, rst)
    begin
        if rst = '0' then
            counter <= 0;
            clk_sig <= '0';
        elsif rising_edge(clk_in) then
            if counter = 25000000 then --Change to 25000 for simulation
                clk_sig <= not clk_sig;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= clk_sig;
end Behavioral;
