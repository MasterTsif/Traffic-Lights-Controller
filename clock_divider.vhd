--==============================================================================
-- File: clock_divider.vhd
-- Description: Divides a 50 MHz input clock down to a 1 Hz output clock
--              by toggling an internal signal every 25 000 000 cycles.
--==============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        clk_in  : in  STD_LOGIC;  -- 50 MHz input clock.
        rst     : in  STD_LOGIC;  
        clk_out : out STD_LOGIC   -- 1 Hz output clock.
    );
end clock_divider;

architecture Behavioral of clock_divider is 
    signal counter : integer := 0;     -- Counter tracks input clock cycles up to the toggle threshold.
    signal clk_sig : STD_LOGIC := '0'; -- Internal clock signal that toggles to form clk_out.
begin
    process(clk_in, rst)
    begin
        if rst = '0' then
            counter <= 0;
            clk_sig <= '0';
        elsif rising_edge(clk_in) then
            if counter = 25000000 then  -- change to 25000 for faster simulation.
                clk_sig <= not clk_sig;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Drive the external clock output.
    clk_out <= clk_sig;
end Behavioral;