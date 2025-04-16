library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer_controller is
    port (
        clk_1hz     : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;             -- Ενεργοποίηση buzzer
        countdown   : in  integer range 0 to 9;  -- Υπολειπόμενα δευτερόλεπτα
        buzzer_out  : out std_logic
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
                   when 3 =>										-- Τoggle rate 1Hz.
                       out_reg <= not out_reg;
                   when 2 => 										-- Τoggle rate 0.5Hz.       
                       if local_counter = 1 then
                           out_reg <= not out_reg;
                           local_counter := 0;
                       else
                           local_counter := local_counter + 1;
                       end if;
                   when 1 =>										-- Τoggle rate 0.25Hz.
                       if local_counter = 3 then
                           out_reg <= not out_reg;
                           local_counter := 0;
                       else
                           local_counter := local_counter + 1;
                       end if;
                   when others =>
                       out_reg <= '0';
                       local_counter := 0;
               end case;
           else
               out_reg <= '0';
               local_counter := 0;
           end if;
       end if;
    end process;

    buzzer_out <= out_reg;

end Behavioral;