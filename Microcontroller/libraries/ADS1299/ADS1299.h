

#ifndef _ADS1299_EEG64_h
#define _ADS1299_EEG64_h

#include "Energia.h"
#include "MySPI.h"
#include "Definitions.h"

class ADS1299 {
public:
    
    //  <<<<<< VARIABLES >>>>>>
    byte regMirror [8][24]; //used to mirror all registers; access using [devNum] [REG_ADDR]
    byte statReg[8][2]; //used to hold stat registers; access using [devNum] [PCHAN / NCHAN] [CHAN #]
    byte bit24ChannelData[8][24]; // array to hold raw channel data
    long longChannelData[8][8]; //array to hold raw channel data in long (32bit) format
    
    byte totNumDev; //the total number of devices
    
    int DRDY; //usually P2.6 or pin 13
    int CS[8]; 	//usually CS1-4 are P1.2-P1.5, CS5-8 are P6.0-P6.3 (pin # equivalents of 35-38 and 23-26)
    
    int DIVIDER; // select SPI SCK frequency; 2,4,8,16,32,64,128 are all valid; divides 16MHz clock by divider
    int dataRate; //check "Definitions.h" for valid values
    
    
    
    //  <<<<<<  GLOBAL  >>>>>>
    void initialize(byte _totNumDev);
    
    
    byte xfer(byte _data); //NOTE: You must manually toggle CS high or low
    bool isDataAvailable(void); // Query to see if data is available from the ADS1299...return TRUE is data is available
    
    void setDataRate(byte DR);
    
    
    //  <<<<<<  SYSTEM COMMANDS  >>>>>>
    
    void WAKEUP(byte dev);  // ONLY allowed to send WAKEUP after sending STANDBY
    void STANDBY(byte dev); // put ADS into low power mode
    void RESET(byte dev);   // reset all the registers to default settings
    void START(byte dev);   //start data conversions on ADS
    void STOP(byte dev);    //stop data conversion
    void RDATAC(byte dev);  //read data continuous mode
    void SDATAC(byte dev);  //stop data continuous mode
    void RDATA(byte dev);   //single read data
    
    
    
    
    //  <<<<<<  REGISTER READ/WRITE COMMANDS  >>>>>>
    
    byte RREG(byte dev, byte _address);                 // reads ONE register at _address
    void WREG(byte dev, byte _address, byte _value);    // writes ONE register at _address
    
    
    
    
    //  <<<<<<  COMPOUND DEVICE COMMANDS  >>>>>>
    
    void resetADS(byte dev);    //reset all the ADS1299's settings.  Call however you'd like.  Stops all data acquisition
    void startADS(byte dev);    // Start continuous data acquisition
    void stopADS(byte dev);     // Stop the continuous data acquisition
    
    void startAllADS(void);
    void stopAllADS(void);
    
    void updateChannelData(); // Get ADS channel data when DRDY goes low
    
    /* data xfer format:
     * DATA_HEADER  (1byte)                 hex 0x68    dec 104
     * INFO_BYTE    (1byte)
     * SAMPLE_NUM   (4bytes)
     * EPOCH_NUM    (1byte)
     * STAT_REG     (2bytes * totNumDev)
     * CHAN_DATA    (32bytes * totNumDev)   chan 1 first; MSB first; 2's complement; raw data from ADS
     * CHECKSUM     (1byte)                 data xor'd with DATA_HEADER in order of sending
     *
     * Maximum packet size 215 bytes or 1704 bits
     * Maximum data rate (from ADS) with 8 devices is 500SPS (at a serial baud rate of 921600baud)
     *
     * INFO_BYTE =
     * 7   RESV - Always 0
     * 6:3 Number of active devices
     * 2:0 Current data rate
     *
     */
    
    //transfer sampleNum in 3 bytes, allows for roughly 16.8 million samples before "overflowing" into most-signif byte (which isn't transferred)
    //option to transfer epochNum if it is available / mapped
    void transferChannelDataToPC(long sampleNum, byte epochNum = 0x00);
    
    
    
    //  <<<<<<  PAGE 2, CHANNEL OPTIONS  >>>>>>
    
    //turn channels on and off
    //accessing the regMirror array with LOFF+chan allows us to keep chan non-zero (i.e. the first device is referenced as dev = 1, NOT dev = 0
    void changeChannelState(byte dev, byte chan, bool state);      //State, bit 7
    void changeChannelGain(byte dev, byte chan, byte GAIN_CODE);   //Gain, bits 6:4
    void changeChannelSRB2(byte dev, byte chan, bool SRB2Conn);    //SRB2, bit 3
    void changeChannelMUX(byte dev, byte chan, byte MUX_CODE);     //MUX, bits 2:0
    
    //ACTIVE TEST SIGNALS
    void activateTestSignal(byte dev, byte TEST_AMP_CODE, byte TEST_FREQ_CODE); // turn all channels on and set all channels to "TEST_SIGNAL" MUX
    void activateTestShorted(byte dev); // turn all channels on and set all channels to "TEST_SIGNAL" MUX
    
    void internalTestSigGen(byte dev);
    void externalTestSigGen(byte dev);
    
    
    //DEACTIVATE TEST SIGNALS - Keep all channels at EN/DIS state and set to NORMAL MUX
    void deactivateTestSignal(byte dev);
    void deactivateTestShorted(byte dev);
    
    void changeTestSigAmplitude(byte dev, byte TEST_AMP_CODE);
    void changeTestSigFrequency(byte dev, byte TEST_FREQ_CODE);
    
    
    
    //  <<<<<<  PAGE 3, LOFF  >>>>>>
    
    void disableLOFFComparator(byte dev);
    void enableLOFFComparator(byte dev);
    
    void setLOFFThreshold(byte dev, byte LOFF_THRESH_CODE);
    void setLOFFCurrentMagnitude(byte dev, byte LOFF_AMP_CODE);
    void setLOFFFrequency(byte dev, byte LOFF_FREQ_CODE);
    
    
    void changeChannelLOFFDetectP(byte dev, byte chan, bool state);
    void changeChannelLOFFDetectN(byte dev, byte chan, bool state);
    void changeChannelLOFFCurDir(byte dev, byte chan, bool INV_OR_NONINV);
    
    bool runBiasLOFFSense(byte dev);
    //TODO
    
    
    
    //  <<<<<<  PAGE 4, BIAS  >>>>>>
    
    // ENABLE / DISABLE BIAS
    void enableInternalBiasBuf(byte dev);
    void disableInternalBiasBuf(byte dev);
    
    void rerouteBiasToChan(byte dev, byte chan, bool P_OR_N);
    
    void disableRerouteBias(byte dev, byte chan);
    
    //Bias signal can be measured w/ usual ADC function of ADS chip
    void measureBiasOnChan(byte dev, byte chan);
    void disableBiasMeasure(byte dev, byte chan);
    
    
    void setBiasRefInt(byte dev);
    void setBiasRefExt(byte dev);
    
    //enable or disable channel inclusion in bias generation
    void changeChannelBiasDerivP(byte dev, byte chan, bool state);
    void changeChannelBiasDerivN(byte dev, byte chan, bool state);
    
    
    
    //  <<<<<<  PAGE 5, DEVICE CONFIGURATION  >>>>>>
    
    void enableOscOut(byte dev);
    void disableOscOut(byte dev);
    
    void enableDaisyChain(byte dev);
    void disableDaisyChain(byte dev);
    
    
    void enableInternalRefBuf(byte dev);
    void disableInternalRefBuf(byte dev);
    
    void connectSRB1(byte dev);
    void disconnectSRB1(byte dev);
    
    void conversationModeContinuous(byte dev);
    void conversationModeSingleShot(byte dev);
    
    
    //  <<<<<<  OTHER COMMANDS  >>>>>>
    
    // simple hello world com check
    byte getDeviceID(byte dev);
    void printDeviceID(byte dev);
    
    void printAllRegisters(byte dev);       //print out the state of all the control registers
    void printRegisterName(byte _address);  // String-Byte converters for RREG and WREG
    void printHex(byte _data);              // Used for printing HEX in verbosity feedback mode
    void printBinary(byte _data);
    
    int charToInt(char charTo);
    
    //Sync ADS / Register Mirror
    void syncADStoMirror(byte dev);
    void syncMirrorToADS(byte dev);
    
    
    
    
    //  <<<<<<  PRIVATE  >>>>>>
    
    // ADS Slave Select
    void csLow(byte dev);
    void csHigh(byte dev);
    
};

#endif
