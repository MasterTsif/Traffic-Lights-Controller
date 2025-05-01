https://github.com/user-attachments/assets/ec7818ba-bf73-4ec7-bbb4-26b27b0c7c1e

This project presents the design and implementation of a comprehensive traffic light control system in VHDL, intended for deployment on an FPGA platform. The system supports normal traffic signaling, pedestrian interaction, emergency mode, and a priority mode for emergency vehicles (police mode). In its standard operation, traffic lights cycle through predefined durations, while a pedestrian can request priority via a switch, halving the duration of the vehicle green phase. In emergency mode, all lights blink simultaneously, overriding normal behavior. In police mode, a rotating light pattern is activated, bypassing the finite state machine logic entirely. The system features an auditory warning mechanism (buzzer) with frequency modulation during the red phase, and three 7-segment displays that show the countdown timers for each state. All functional subsystems are integrated to deliver a reliable, extensible, and realistically behaving traffic controller.
Simulation:
![1](https://github.com/user-attachments/assets/ed007762-74b3-4e94-b316-8e735369d160)

(Emergency mode, Siren Mode, Reset)
https://github.com/user-attachments/assets/7cbe79c1-1615-4056-bc68-f0d1d0a4223e
