All code associated with The EEG64 Project and The Shoulders of Giants summer program for biomedical engineering at the University of Texas at Dallas

Project Status:
The micro controller code is in an alpha stage; most features should be working but extensive testing and debugging is still necessary.
The MATLAB code is still in development. Most of the GUI components have been placed, and the GUI is visually in an “alpha” stage - developed, but needing extensive debugging.
The MATLAB <-> Microcontroller interface needs programming, and currently has the highest priority.


Microcontroller Interface Documentation

—————————————————————————————————————————————————————————————————————————————————————————————————————

—————————————————————————————————————————————————————————————————————————————————————————————————————
6	Stat Register	1 bytes			N-Channel LOFF status register								8-bit binary
Bit #		Function
7			RESV - Not used, always 0
6:3			Number of active devices
2:0			Current data rate, represented as 3-bit register setting in ADS1299 (Datasheet, Pg. 40)
* Information byte can be used to calculate length of the entire packet in the following way:
	- Read 7 bytes (data header, info byte, sample number, epoch number)
	- Extract number of devices from info byte
	- Read 34 bytes * number of devices
	- Read checksum byte, compare with calculated value
* Typical length of a packet is 42 bytes, maximum packet size is 280 bytes
* Epoch number doesn’t have to be used, but can be if desired
* Status registers, MSB represents channel 8, LSB represents channel 1
* Channel data is sent channel 1 first, MSB first, two’s complement, and it is a 24-bit signed value converted to a 32-bit signed value