library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_traffic_light is
    port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
		  emergency  : in  STD_LOGIC;
		  ped_switch : in  STD_LOGIC;
        veh_light  : out STD_LOGIC_VECTOR(2 downto 0);
        ped_light  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end simple_traffic_light;

architecture Behavioral of simple_traffic_light is
	 
	 ------------------------------------------------------------------
    -- Component: Clock Divider
    -- Περιγραφή: Διαίρεση της συχνότητας του ρολογιού.
    ------------------------------------------------------------------
    component clock_divider is
        port (
            clk_in  : in  STD_LOGIC;   
            rst     : in  STD_LOGIC;   
            clk_out : out STD_LOGIC    
        );
    end component;
    
    -- Σήμα εξόδου από το clock divider
    signal clk_divided : STD_LOGIC;
	 
	 ------------------------------------------------------------------
    -- Component: Debouncer
    -- Περιγραφή: Αφαίρεση θορύβου από το σήμα εισόδου.
    ------------------------------------------------------------------
    component debouncer is
        port (
            clk   : in  STD_LOGIC;   
            rst : in  STD_LOGIC;   
            noisy : in  STD_LOGIC;   
            clean : out STD_LOGIC    
        );
    end component;
    
    -- Σήμα καθαρισμένου σήματος από το debouncer
    signal emergency_clean : STD_LOGIC;
	 signal ped_switch_clean : STD_LOGIC;
		
	 ------------------------------------------------------------------
    -- Εσωτερικά Σήματα και Καταστάσεις
    ------------------------------------------------------------------
    signal toggle  : STD_LOGIC := '0';              -- Σήμα μεταγωγής
    type state_type is (S_GREEN, S_YELLOW, S_RED);  -- Ορισμός καταστάσεων σηματοδότησης
    signal state   : state_type := S_GREEN;         -- Αρχική κατάσταση = πράσινο
    signal counter : integer    := 0;               -- Μετρητής χρονισμού κατάστασης

    ------------------------------------------------------------------
    -- Σταθερές: Χρονικές Διάφορες Καταστάσεων
    ------------------------------------------------------------------
    constant T_GREEN  : integer := 11; -- Διάρκεια πράσινου φωτός
    constant T_YELLOW : integer := 7;  -- Διάρκεια κίτρινου φωτός
    constant T_RED    : integer := 6;  -- Διάρκεια κόκκινου φωτός
begin
    ------------------------------------------------------------------
    -- Instance: Clock Divider (CD)
    ------------------------------------------------------------------
    CD: clock_divider
        port map (
            clk_in  => clk,         
            rst     => rst,         
            clk_out => clk_divided 
        );

    ------------------------------------------------------------------
    -- Instance: Debouncer (DB) for emergency
    ------------------------------------------------------------------
    DB: debouncer
        port map (
            clk   => clk,              
            rst => rst,            
            noisy => emergency,        
            clean => emergency_clean   
        );
		  
	 ------------------------------------------------------------------
    -- Instance: Debouncer (DB) for ped_switch
    ------------------------------------------------------------------
    DB2: debouncer
        port map (
            clk   => clk,              
            rst => rst,            
            noisy => ped_switch,        
            clean => ped_switch_clean   
        );  
		  
    process(clk_divided, rst)
    begin
        if rst = '0' then
            state     <= S_GREEN;
            counter   <= 0;
            toggle    <= '0';
        elsif rising_edge(clk_divided) then
            if emergency_clean = '1' then -- Λειτουργία έκτακτης ανάγκης
                toggle <= not toggle;
                if toggle = '1' then
                    veh_light <= "111";
                    ped_light <= "11";
                else
                    veh_light <= "000";
                    ped_light <= "00";
                end if;
            else
                case state is  -- Κανονική λειτουργία
                    when S_GREEN =>
                        veh_light <= "001";
                        ped_light <= "10";
								if ped_switch_clean = '1' then -- Αν ο πεζος εχει πατησει το κουμπι
									if counter >= T_GREEN / 2 then
                            state   <= S_YELLOW;
                            counter <= 0;
									else
										 counter <= counter + 1;
									end if;
								else	
									if counter >= T_GREEN then
										 state   <= S_YELLOW;
										 counter <= 0;
									else
										 counter <= counter + 1;
									end if;
								end if;	
                    when S_YELLOW =>
                        veh_light <= "010";
                        ped_light <= "10";
                        if counter >= T_YELLOW then
                            state   <= S_RED;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when S_RED =>
                        veh_light <= "100";
                        ped_light <= "01";
                        if counter >= T_RED then
                            state   <= S_GREEN;
                            counter <= 0;
                        else
                            counter <= counter + 1;
                        end if;
                    when others =>
                        veh_light <= "000";
                        ped_light <= "00";
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;