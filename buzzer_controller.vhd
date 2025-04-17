--==============================================================================
-- File: buzzer_controller.vhd
-- Description: Controls a buzzer output by toggling at different rates based on
--              countdown input when enabled, driven by a 1 Hz clock.
--==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer_controller is
    port (
        clk_1hz     : in  std_logic;                -- 1 Hz clock input
        rst         : in  std_logic;                -- active-low reset
        enable      : in  std_logic;                -- enable buzzer toggling
        countdown   : in  integer range 0 to 9;     -- remaining seconds
        buzzer_out  : out std_logic                 -- buzzer output signal
    );
end buzzer_controller;

architecture Behavioral of buzzer_controller is
    signal out_reg : std_logic := '0';
begin

    process(clk_1hz, rst)
       variable local_counter : integer range 0 to 3 := 0;
    begin
       if rst = '0' then
           out_reg <= '0';
           local_counter := 0;
       elsif rising_edge(clk_1hz) then
           if enable = '1' then
               case countdown is
                   when 3 => out_reg <= not out_reg;          -- toggle at 1 Hz
                   when 2 =>                                  -- toggle at 0.5 Hz
                       if local_counter = 1 then
                           out_reg <= not out_reg;
                           local_counter := 0;
                       else
                           local_counter := local_counter + 1;
                       end if;
                   when 1 =>                                  -- toggle at 0.25 Hz
                       if local_counter = 3 then
                           out_reg <= not out_reg;
                           local_counter := 0;
                       else
                           local_counter := local_counter + 1;
                       end if;
                   when others =>
                       out_reg <= '0';                       -- turn off buzzer
                       local_counter := 0;
               end case;
           else
               out_reg <= '0';                           -- disable buzzer
               local_counter := 0;
           end if;
       end if;
    end process;

    buzzer_out <= out_reg;                            -- drive buzzer output

end Behavioral;