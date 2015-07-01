All code associated with The EEG64 Project and The Shoulders of Giants summer program for biomedical engineering at the University of Texas at Dallas

Project Status:
The micro controller code is in an alpha stage; most features should be working but extensive testing and debugging is still necessary.
The MATLAB code is still in development. Most of the GUI components have been placed, and the GUI is visually in an “alpha” stage - developed, but needing extensive debugging.
The MATLAB <-> Microcontroller interface needs programming, and currently has the highest priority.


Microcontroller Interface DocumentationSerial commands are in the following format:
#	Segment			Size		Description								Value
—————————————————————————————————————————————————————————————————————————————————————————————————————1	Command Header	1 byte		Initial command header					Always	0x24 (decimal is 36)2	Device Number	1 byte		Which device to forward command to		8-bit unsigned int3	Parameter #1	1 byte		Typically a channel number				Either 8-bit unsigned int or 8-bit binary4	Parameter #2	1 byte		Typically a setting						8-bit binary5	Parameter #3	1 byte		Not typically used						Not typically used6	Checksum		1 byte		All bytes XOR’d in order sent			8-bit binaryTypical order of parameters: Channel, (Setting)Data samples sent in the following format
#	Segment			Size			Description											Value
—————————————————————————————————————————————————————————————————————————————————————————————————————1	Data Header		1 byte			Initial data header											Always	0x68 (decimal is 104)2	Info Byte		1 byte			See below; contains DR and number of devices				8-bit binary3	Sample Number	4 bytes			Current sample number collected from ADS					32-bit unsigned integer4	Epoch Number	1 byte			Epoch number; used to record epoch triggers				8-bit unsigned integer5	Stat Register	1 bytes			P-Channel LOFF status register								8-bit binary
6	Stat Register	1 bytes			N-Channel LOFF status register								8-bit binary7	Channel Data	32*N bytes		Channel Data from ADS; 32 bit signed int					Signed 24 bit int represented as signed 32 bit (0xFF800000h - 0x007FFFFF)8	Checksum		1 byte			All bytes XOR’d in order sent								8-bit binary Info Byte Format:
Bit #		Function
7			RESV - Not used, always 0
6:3			Number of active devices
2:0			Current data rate, represented as 3-bit register setting in ADS1299 (Datasheet, Pg. 40)Notes:
* Information byte can be used to calculate length of the entire packet in the following way:
	- Read 7 bytes (data header, info byte, sample number, epoch number)
	- Extract number of devices from info byte
	- Read 34 bytes * number of devices
	- Read checksum byte, compare with calculated value
* Typical length of a packet is 42 bytes, maximum packet size is 280 bytes
* Epoch number doesn’t have to be used, but can be if desired
* Status registers, MSB represents channel 8, LSB represents channel 1
* Channel data is sent channel 1 first, MSB first, two’s complement, and it is a 24-bit signed value converted to a 32-bit signed value