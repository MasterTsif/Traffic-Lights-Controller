library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Traffic_Lights_Controller is
    port (
		  -- INPUTS
        clk          : in  STD_LOGIC; -- System clock input (50 MHz from dev board).
        rst          : in  STD_LOGIC;  
        emergency    : in  STD_LOGIC; -- Emergency mode input (bound to switch); when HIGH, traffic lights enter blinking mode.
        ped_switch   : in  STD_LOGIC; -- Pedestrian request button (bound to switch); when HIGH, reduces vehicle green light duration by half.
		  next_button  : in STD_LOGIC;  -- Button to manually jump to next state.	
		  police_siren : in STD_LOGIC;  -- Police mode (bound to switch); when HIGH lights have a cycling on-off effect.	
		  
		  -- OUTPUTS
        veh_light    : out STD_LOGIC_VECTOR(2 downto 0); -- Vehicle traffic light output (connected to LEDs), "001" = Red, "010" = Yellow, "100" = Green.
        ped_light    : out STD_LOGIC_VECTOR(1 downto 0); -- Pedestrian light output (connected to LEDs):
																		   -- When veh_light = "001" (Red for cars), ped_light = "10" (Green for pedestrians).
																		   -- Otherwise, ped_light = "01" (Red for pedestrians).							  
        o_seg_CR     : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment display output for vehicle **Red** light countdown timer.
        o_seg_CY     : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment display output for vehicle **Yellow** light countdown timer.
        o_seg_CG     : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment display output for vehicle **Green** light countdown timer.
        buzzer       : out STD_LOGIC  						   -- Buzzer output (connected via GPIO); activates with variable frequency at the end of the 
																		   -- green light for vehicles to warn pedestrians or drivers.
    );
end Traffic_Lights_Controller;

architecture Behavioral of Traffic_Lights_Controller is
	 ------------------------------------------------------------------
    -- Component: Clock Divider
    -- Description:  Takes as input the 50 MHz system clock from the 
	 -- development board and produces a 1 Hz output clock signal. 
    ------------------------------------------------------------------
    component clock_divider is
        port (
            clk_in  : in  STD_LOGIC;   
            rst     : in  STD_LOGIC;   
            clk_out : out STD_LOGIC    
        );
    end component;
    
     -- Output signal from the clock divider (1 Hz clock signal).
    signal clk_divided : STD_LOGIC;
	 
	 ------------------------------------------------------------------
    -- Component: Debouncer
    -- Description: Removes glitches and bouncing from an input signal,
	 -- used for the switches of emergency, ped_switch and police_siren.
    ------------------------------------------------------------------
    component debouncer is
        port (
            clk   : in  STD_LOGIC;   
            rst : in  STD_LOGIC;   
            noisy : in  STD_LOGIC;   
            clean : out STD_LOGIC    
        );
    end component;
	 
	 -- Clean output signals from the debouncer.
    signal emergency_clean    : STD_LOGIC;
	 signal ped_switch_clean   : STD_LOGIC;
	 signal police_siren_clean : STD_LOGIC;
	 
	 ------------------------------------------------------------------
    -- Component: Βuzzer
    -- Description: Drives a buzzer output based on a countdown timer.
    -- Activates the buzzer with variable frequency during the last few 
    -- seconds of the green light phase.
    ------------------------------------------------------------------
	 component buzzer_controller is
    port (
        clk_1hz     : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;
        countdown   : in  integer range 0 to 9;
        buzzer_out  : out std_logic
    );
	 end component;

    ------------------------------------------------------------------
    -- Signal for Buzzer Output
    ------------------------------------------------------------------
    signal buzzer_sig : STD_LOGIC;
		
	  ------------------------------------------------------------------
    -- Internal Signals and States
    ------------------------------------------------------------------
    signal toggle  : STD_LOGIC := '0';              -- Toggle signal
    type state_type is (S_GREEN, S_YELLOW, S_RED);  -- Traffic light state definition
    signal state   : state_type := S_GREEN;         -- Initial state set to GREEN
    signal counter : integer    := 0;               -- Timing counter for current state duration
	 signal police_pattern : STD_LOGIC_VECTOR(2 downto 0) := "100"; -- For police siren lights pattern
	 ------------------------------------------------------------------
    -- Signals for 7-Segment Displays (timers per light state)
    ------------------------------------------------------------------
    signal CGCounter : integer := 0;  -- Green light countdown
    signal CYCounter : integer := 0;  -- Yellow light countdown
    signal CRCounter : integer := 0;  -- Red light countdown
    ------------------------------------------------------------------
    -- Constants: Light Durations (in seconds)
    ------------------------------------------------------------------
    constant T_GREEN  : integer := 11; -- Green light duration
    constant T_YELLOW : integer := 7;  -- Yellow light duration
    constant T_RED    : integer := 6;  -- Red light duration
begin
    ------------------------------------------------------------------
    -- Instance: Clock Divider
    ------------------------------------------------------------------
    CD: clock_divider
        port map (
            clk_in  => clk,         
            rst     => rst,         
            clk_out => clk_divided 
        );

    ------------------------------------------------------------------
    -- Instance: Debouncer for emergency
    ------------------------------------------------------------------
    DB: debouncer
        port map (
            clk   => clk,              
            rst => rst,            
            noisy => emergency,        
            clean => emergency_clean   
        );
		  
	 ------------------------------------------------------------------
    -- Instance: Debouncer for ped_switch
    ------------------------------------------------------------------
    DB2: debouncer
        port map (
            clk   => clk,              
            rst => rst,            
            noisy => ped_switch,        
            clean => ped_switch_clean   
        );  
	 ------------------------------------------------------------------
    -- Instance: Debouncer for police_siren
    ------------------------------------------------------------------
	 DB3: debouncer
    port map (
        clk   => clk,
        rst   => rst,
        noisy => police_siren,
        clean => police_siren_clean
    );
	 ------------------------------------------------------------------
    -- Instance: Buzzer
    ------------------------------------------------------------------  
	 BUZ : buzzer_controller
    port map (
        clk_1hz    => clk_divided,
        rst        => rst,
        enable     => '1',
        countdown  => CRCounter,
        buzzer_out => buzzer_sig
    );

		  
	process(clk_divided, rst)
	begin
		 if rst = '0' then
			  state     <= S_GREEN;
			  counter   <= 0;
			  toggle    <= '0';
		 elsif rising_edge(clk_divided) then
			  if police_siren_clean = '1' then
					-- Rotate left, cars only.
					police_pattern <= police_pattern(1 downto 0) & police_pattern(2);
					veh_light <= police_pattern;
					ped_light <= "00";
			  else
					if emergency_clean = '1' then -- Emergency mode active
						 toggle <= not toggle;
						 if toggle = '1' then
							  veh_light <= "111";
							  ped_light <= "11";
						 else
							  veh_light <= "000";
							  ped_light <= "00";
						 end if;
					else
						 if next_button = '1' then -- Manually jump to next state
							  case state is
									when S_GREEN =>
										 state   <= S_YELLOW;
									when S_YELLOW =>
										 state   <= S_RED;
									when S_RED =>
										 state   <= S_GREEN;
									when others =>
										 state   <= S_GREEN;
							  end case;
							  counter <= 0;
						 else
							  case state is  -- Normal traffic light operation
									when S_GREEN =>
										 veh_light <= "001";
										 ped_light <= "10";
										 if ped_switch_clean = '1' then  -- Pedestrian button pressed
											  if counter >= T_GREEN / 2 then
													state   <= S_YELLOW;
													counter <= 0;
											  else
													CGCounter <= 5 - counter;
													counter <= counter + 1;									 
											  end if;
										 else	
											  if counter >= T_GREEN then
													state   <= S_YELLOW;
													counter <= 0;
											  else
													CGCounter <= 11 - counter;
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
											  CYCounter <= 7 - counter;
											  counter <= counter + 1;
										 end if;
									when S_RED =>
										 veh_light <= "100";
										 ped_light <= "01";
										 if counter >= T_RED then
											  state   <= S_GREEN;
											  counter <= 0;
										 else
											  CRCounter <= 6 - counter;
											  counter <= counter + 1;
										 end if;
									when others =>
										 veh_light <= "000";
										 ped_light <= "00";
							  end case;
						 end if;
					end if;
			  end if;
		 end if;
	end process;

	 ------------------------------------------------------------------
    -- 7-Segment Display Outputs
    ------------------------------------------------------------------
	 seg_CG : entity work.bcd_to_7segment
        port map (
            bcd => CGCounter,
            seg => o_seg_CG
        );
    seg_CY : entity work.bcd_to_7segment
        port map (
            bcd => CYCounter,
            seg => o_seg_CY
        );
	 seg_CR : entity work.bcd_to_7segment
        port map (
            bcd => CRCounter,
            seg => o_seg_CR
        );
	 ------------------------------------------------------------------
    -- Buzzer Output
    ------------------------------------------------------------------	
	 buzzer <= buzzer_sig;

end Behavioral;