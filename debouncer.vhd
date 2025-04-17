--==============================================================================
-- File: debouncer.vhd
-- Description: Implements a button debounce circuit by sampling a noisy input,
--              synchronizing it to the system clock, and requiring a stable
--              input for a defined time (debounce_limit) before updating output.
--==============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    port(
        clk       : in  STD_LOGIC;        -- System clock for synchronization.
        rst       : in  STD_LOGIC;        
        noisy     : in  STD_LOGIC;        -- Raw, bouncing input signal.
        clean     : buffer STD_LOGIC      -- Debounced, synchronized output.
    );
end debouncer;

architecture Behavioral of debouncer is
    signal sync_0, sync_1 : STD_LOGIC := '0';      -- Two-stage synchronizer to avoid metastability on asynchronous input.
    signal counter        : integer    := 0;       -- Counter to measure how long the input remains in the new state.
    constant debounce_limit : integer := 50000000; -- Number of clock cycles input must be stable before accepting change (1s).
begin
    process(clk, rst)
    begin
        if rst = '0' then
            sync_0  <= '0';
            sync_1  <= '0';
            counter <= 0;
            clean   <= '0';
        elsif rising_edge(clk) then
            -- Stage 1: sample the noisy input
            sync_0 <= noisy;
            -- Stage 2: further synchronize to clock domain
            sync_1 <= sync_0;

            -- If synchronized input matches current output, reset counter
            if clean = sync_1 then
                counter <= 0;
            else
                -- Otherwise, increment counter to track stability duration
                counter <= counter + 1;
                -- Once stable for debounce_limit cycles, update output
                if counter >= debounce_limit then
                    clean   <= sync_1;
                    counter <= 0;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
