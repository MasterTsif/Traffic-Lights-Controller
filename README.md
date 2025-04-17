https://github.com/user-attachments/assets/af630557-7492-4b48-89d5-1d350d347e4d
# Traffic-Lights-Controller
This project presents the design and implementation of a comprehensive traffic light control system in VHDL, intended for deployment on an FPGA platform. The system supports normal traffic signaling, pedestrian interaction, emergency mode, and a priority mode for emergency vehicles (police mode). In its standard operation, traffic lights cycle through predefined durations, while a pedestrian can request priority via a switch, halving the duration of the vehicle green phase. In emergency mode, all lights blink simultaneously, overriding normal behavior. In police mode, a rotating light pattern is activated, bypassing the finite state machine logic entirely. The system features an auditory warning mechanism (buzzer) with frequency modulation during the red phase, and three 7-segment displays that show the countdown timers for each state. All functional subsystems are integrated to deliver a reliable, extensible, and realistically behaving traffic controller.

Traffic Lights - Emergency Mode:
https://github.com/user-attachments/assets/7774f25a-a66e-421c-8b7e-6e5a56cffa61

Simulation:
![1](https://github.com/user-attachments/assets/ed007762-74b3-4e94-b316-8e735369d160)
