#ifndef _Definitions_EEG64_h	// add _8_
#define _Definitions_EEG64_h

#include "Energia.h"

#define MATLAB


//QUICKFIX
#define SPI_CLOCK_DIV2 -1
#define SPI_CLOCK_DIV4 -1

//SERIAL COMM PACKET HEADERS / DEFINES
#define CMD_HEADER  0x24
#define ACK_HEADER  0x46
#define DATA_HEADER 0x68
#define ACK_OK      0xA1
#define ACK_BAD     0xBA

//USER CONFIGURATION
#define _RST    9 //P6.5
#define _STRT  30 //P5.5
#define _DRDY  29 //P5.4
#define _CS1   27 //P4.5
#define _CS2   26 //P4.4
#define _CS3   25 //P4.2
#define _CS4   24 //P4.0
#define _CS5   40 //P2.7
#define _CS6   39 //P2.6
#define _CS7   19 //P2.5
#define _CS8   38 //P2.4

//MISO (14) P1.7
//MOSI (15) P1.6
//SCK  (7)  P1.5

//ADS1299 SPI Command Definition Byte Assignments
#define _WAKEUP 0x02 // Wake-up from standby mode
#define _STANDBY 0x04 // Enter Standby mode
#define _RESET 0x06 // Reset the device registers to default
#define _START 0x08 // Start and restart (synchronize) conversions
#define _STOP 0x0A // Stop conversion
#define _RDATAC 0x10 // Enable Read Data Continuous mode (default mode at power-up)
#define _SDATAC 0x11 // Stop Read Data Continuous mode
#define _RDATA 0x12 // Read data by command; supports multiple read back

//ASD1299 Register Addresses
//REG_ADDR
#define ID      0x00
#define CONFIG1 0x01
#define CONFIG2 0x02
#define CONFIG3 0x03
#define LOFF 0x04
#define CH1SET 0x05
#define CH2SET 0x06
#define CH3SET 0x07
#define CH4SET 0x08
#define CH5SET 0x09
#define CH6SET 0x0A
#define CH7SET 0x0B
#define CH8SET 0x0C
#define BIAS_SENSP 0x0D
#define BIAS_SENSN 0x0E
#define LOFF_SENSP 0x0F
#define LOFF_SENSN 0x10
#define LOFF_FLIP 0x11
#define LOFF_STATP 0x12
#define LOFF_STATN 0x13
#define GPIO 0x14
#define MISC1 0x15
#define MISC2 0x16
#define CONFIG4 0x17

//CHANNEL SETTINGS
#define CHAN_ON (0b00000000)
#define CHAN_OFF (0b10000000)
//SRB2ON/DISCON not used; simple bitshifting instead
//#define SRB2_CON
//#define SRB2_DISCON

// CHANNEL SETTINGS
#define POWER_DOWN      (0)
#define GAIN_SET        (1)
#define INPUT_TYPE_SET  (2)
#define BIAS_SET        (3)
#define SRB2_SET        (4)
#define YES      	(0x01)
#define NO      	(0x00)

//GAIN_CODE
#define GAIN01 (0b00000000)	// 0x00
#define GAIN02 (0b00010000)	// 0x10
#define GAIN04 (0b00100000)	// 0x20
#define GAIN06 (0b00110000)	// 0x30
#define GAIN08 (0b01000000)	// 0x40
#define GAIN12 (0b01010000)	// 0x50
#define GAIN24 (0b01100000)	// 0x60

//MUX_CODE
#define MUX_NORMAL (0b00000000)
#define MUX_SHORTED (0b00000001)
#define MUX_BIAS_MEAS (0b00000010)
#define MUX_MVDD (0b00000011)
#define MUX_TEMP (0b00000100)
#define MUX_TESTSIG (0b00000101)
#define MUX_BIAS_DRP (0b00000110)
#define MUX_BIAS_DRN (0b00000111)

//TEST_AMP_CODE (Pg. 41)
#define TESTSIG_AMP_1X (0b00000000) //1 × (VREFP – VREFN) / 2.4 mV (default)
#define TESTSIG_AMP_2X (0b00000100) //2 × (VREFP – VREFN) / 2.4 mV

//TEST_FREQ_CODE (Pg. 41)
#define TESTSIG_PULSE_SLOW (0b00000000) //Pulsed at fCLK / 2^21 (default)
#define TESTSIG_PULSE_FAST (0b00000001) //Pulsed at fCLK / 2^20
#define TESTSIG_DCSIG (0b00000011) //Pulsed at DC

//LOFF_THRESH_CODE (Datasheet Pg. 43)

//LOFF_THRESH_CODE_P
#define THRESH_95   (0b00000000) //default
#define THRESH_92p5 (0b00100000)
#define THRESH_90   (0b01000000)
#define THRESH_87p5 (0b01100000)
#define THRESH_85   (0b10000000)
#define THRESH_80   (0b10100000)
#define THRESH_75   (0b11000000)
#define THRESH_70   (0b11100000)

//LOFF_THRESH_CODE_N
#define THRESH_5    (0b00000000) //default
#define THRESH_7p5  (0b00100000)
#define THRESH_10   (0b01000000)
#define THRESH_12p5 (0b01100000)
#define THRESH_15   (0b10000000)
#define THRESH_20   (0b10100000)
#define THRESH_25   (0b11000000)
#define THRESH_30   (0b11100000)

//LOFF_AMP_CODE
#define LOFF_AMP_6NA (0b00000000)
#define LOFF_AMP_24NA (0b00000100)
#define LOFF_AMP_6UA (0b00001000)
#define LOFF_AMP_24UA (0b00001100)

//LOFF_FREQ_CODE
#define LOFF_FREQ_DC (0b00000000)
#define LOFF_FREQ_7p8HZ (0b00000001)
#define LOFF_FREQ_31p2HZ (0b00000010)
#define LOFF_FREQ_FS_4 (0b00000011)

//MISC DEFINITIONS
#define PCHAN (0)
#define NCHAN (1)
#define BOTHCHAN (2)

#define NONINV (0)
#define INV (1)

#define OFF (0)
#define ON (1)

#define DISABLE (0)
#define ENABLE (1)

//SERIAL COMMUNICATIONS
#define PCKT_START 0xA0	// prefix for data packet error checking
#define PCKT_END 0xC0	// postfix for data packet error checking

#define DR_16KSPS (0b00000000)
#define DR_8KSPS  (0b00000001)
#define DR_4KSPS  (0b00000010)
#define DR_2KSPS  (0b00000011)
#define DR_1KSPS  (0b00000100)
#define DR_500SPS (0b00000101)
#define DR_250SPS (0b00000110) //default
//111 not used



#endif
