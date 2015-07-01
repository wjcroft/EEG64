#include "Energia.h"
#include "MySPI.h"
#include "ADS1299.h"
#include "Definitions.h"

void ADS1299::initialize(byte _totNumDev){
    DRDY = _DRDY;
    CS[0] = _CS1, CS[1] = _CS2, CS[2] = _CS3, CS[3] = _CS4, CS[4] = _CS5, CS[5] = _CS6, CS[6] = _CS7, CS[7] = _CS8;
    DIVIDER = SPI_CLOCK_DIV4;
    dataRate = DR_250SPS;
    
//    bit24ChannelData = {0};
 //   longChannelData = {0};
    
    if(_totNumDev > 8) _totNumDev = 8; //check for valid values
    totNumDev = _totNumDev;
    
    // recommended power up sequence requiers Tpor (~32mS)
    delay(1000); //Wait 1s
    
    pinMode(DRDY, INPUT);
    for(int i = 0; i < totNumDev; ++i) { pinMode(CS[i], OUTPUT); digitalWrite(CS[i], HIGH); }
    MySPI.setBitOrder(MSBFIRST);
    MySPI.setClockDivider(DIVIDER);
    MySPI.setDataMode(SPI_MODE1); //CPOL = 0, CPHA = 1
    MySPI.begin();
    dataRate = DR_500SPS;
    
    
    //MASTER
    SDATAC(0x01);
    resetADS(0x01);
    delay(1);
    SDATAC(0x01);
    syncADStoMirror(0x01);
    //    enableOscOut(0x01);
    enableInternalRefBuf(0x01);
    delay(1);
    
    //TEST
    RDATAC(1);
    
    //SLAVES
    for(int i = 2; i <= totNumDev; ++i) {
        resetADS(i);
        delay(1);
        syncADStoMirror(0x01);
        SDATAC(i);
        enableInternalRefBuf(i);
        disableOscOut(i);
    }
    
    //    for(int i = 1; i <= totNumDev; ++i) syncADStoMirror(i);
//    setDataRate(DR_500SPS);
    //    RDATAC(1);
};




//  <<<<<<  GLOBAL  >>>>>>

//NOTE: You must manually toggle CS high or low
byte ADS1299::xfer(byte _data) { return MySPI.transfer(_data); }

void ADS1299::setDataRate(byte DR) {
    for(int i = 1; i <= totNumDev; ++i) {
        regMirror[i-1][CONFIG1] = (regMirror[i-1][CONFIG1] & 0b11111000) | DR;
        WREG(i, CONFIG1, regMirror[i-1][CONFIG1]);
    }
    dataRate = DR;
    
}

// Query to see if data is available from the ADS1299...return TRUE is data is available
bool ADS1299::isDataAvailable(void) { return (!(digitalRead(DRDY))); } //GLOBAL

//  <<<<<<  SYSTEM COMMANDS  >>>>>>
void ADS1299::WAKEUP(byte dev) {
    csLow(dev);
    xfer(_WAKEUP);
    csHigh(dev);
    delayMicroseconds(3);     //must wait 4 tCLK cycles before sending another command (Datasheet, pg. 35)
}

// ONLY allowed to send WAKEUP after sending STANDBY
void ADS1299::STANDBY(byte dev) {
    csLow(dev);
    xfer(_STANDBY);
    csHigh(dev);
}

// reset all the registers to default settings
void ADS1299::RESET(byte dev) {
    csLow(dev);
    xfer(_RESET);
    delayMicroseconds(12);    //must wait 18 tCLK cycles to execute this command (Datasheet, pg. 35)
    csHigh(dev);
}

//start data conversions on ADS
void ADS1299::START(byte dev) {
    csLow(dev);
    xfer(_START);
    csHigh(dev);
    delayMicroseconds(3);
}

//stop data conversion
void ADS1299::STOP(byte dev) {
    csLow(dev);
    xfer(_STOP);
    csHigh(dev);
}

//read data continuous mode
void ADS1299::RDATAC(byte dev) {
    csLow(dev);
    xfer(_RDATAC);
    csHigh(dev);
    delayMicroseconds(3);
}
//stop data continuous mode
void ADS1299::SDATAC(byte dev) {
    csLow(dev);
    xfer(_SDATAC);
    csHigh(dev);
    delayMicroseconds(3);   //must wait 4 tCLK cycles after executing this command (Datasheet, pg. 37)
}
//single read data
void ADS1299::RDATA(byte dev) {
    long statRegTemp = 0;
    
    csLow(dev);        //  open SPI
    
    //STATUS REGISTER
    for(int i=0; i<3; i++){
        statRegTemp = (statRegTemp<<8) | xfer(0x00);    //  save 24 status bits to statRegTemp
        if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
    }
    statReg[dev-1][PCHAN] = (byte)((statRegTemp >> 12) & 0xFF);
    statReg[dev-1][NCHAN] = (byte)((statRegTemp >> 4) & 0xFF);
    
    //CHANNEL DATA
    for(int i = 0; i<8; i++) {
        for(int j=0; j<3; j++) {   //  read 24 bits of channel data in 8 3 byte chunks
            bit24ChannelData[dev-1][(i*3) + j] = xfer(0x00);  // raw data completely raw, unedited
            if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
        }
        if(bit24ChannelData[dev-1][(i*3) + 2] & 0b10000000) longChannelData[dev-1][i] = 0xFF000000;
        longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 2] << 16;
        longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 1] << 8;
        longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 0] << 0;
    }
    csHigh(dev);
}




//  <<<<<<  REGISTER READ/WRITE COMMANDS  >>>>>>

//  reads ONE register at _address
byte ADS1299::RREG(byte dev, byte _address) {
    byte opcode1 = _address + 0x20;   //  RREG expects 001rrrrr where rrrrr = _address
    
    csLow(dev);        //  open SPI
    
    xfer(opcode1);          //  opcode1
    delayMicroseconds(4); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
    xfer(0x00);           //  opcode2
    delayMicroseconds(4);
    regMirror[dev-1][_address] = xfer(0x00);//  update mirror location with returned byte
    delayMicroseconds(4);
    csHigh(dev);       //  close SPI
    
    return regMirror[dev-1][_address];     // return requested register value
}

//  Write ONE register at _address
void ADS1299::WREG(byte dev, byte _address, byte _value) {
    SDATAC(dev);
    byte opcode1 = _address + 0x40;   //  WREG expects 010rrrrr where rrrrr = _address
    
    csLow(dev);        //  open SPI
    
    xfer(opcode1);          //  Send WREG command & address
    if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
    xfer(0x00);           //  Send number of registers to read -1
    if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
    xfer(_value);         //  Write the value to the register
    
    csHigh(dev);       //  close SPI
    return;
}




//  <<<<<<  COMPOUND DEVICE COMMANDS  >>>>>>

//reset all the ADS1299's settings.  Call however you'd like.  Stops all data acquisition
void ADS1299::resetADS(byte dev) {
    RESET(dev);             // send RESET command to default all registers
    SDATAC(dev);            // exit Read Data Continuous mode to communicate with ADS
};

// Start continuous data acquisition
void ADS1299::startADS(byte dev) {
    SDATAC(dev);
    START(dev);        // start the data acquisition
    RDATAC(dev); // enter Read Data Continuous mode
}

// Stop the continuous data acquisition
void ADS1299::stopADS(byte dev) {
    SDATAC(dev); // exit Read Data Continuous mode to communicate with ADS
    STOP(dev); // stop data conversions
}

void ADS1299::startAllADS(void) {
    for(int i = 1; i <= totNumDev; ++i) {
        SDATAC(i);
        STOP(i); }
    for(int i = 1; i <= totNumDev; ++i) csLow(i); //bring all CS low
    START(1); //will act on all chips because all CS are low
    for(int i = 1; i <= totNumDev; ++i) csHigh(i); //this will return all CS high
    for(int i = 1; i <= totNumDev; ++i) RDATAC(i); //set all devices to read data continuous w/ synchronized conversions
}

void ADS1299::stopAllADS(void) {
    for(int i = 1; i <= totNumDev; ++i) {
        SDATAC(i);
        STOP(i); }
}

// Get ADS channel data when DRDY goes low
void ADS1299::updateChannelData(){
    byte inByte = 0;
    long statRegTemp = 0;
    for(int dev = 1; dev <= totNumDev; ++dev) {
        csLow(dev);        //  open SPI
        
        //STATUS REGISTER
        statRegTemp = 0;
        for(int i=0; i<3; i++){
            statRegTemp = (statRegTemp<<8) | xfer(0x00);    //  save 24 status bits to statRegTemp
            if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
        }
        statReg[dev-1][PCHAN] = (byte)((statRegTemp >> 12) & 0xFF);
        statReg[dev-1][NCHAN] = (byte)((statRegTemp >> 4) & 0xFF);
        
        //CHANNEL DATA
        for(int i = 0; i<8; i++) {
            for(int j=0; j<3; j++) {   //  read 24 bits of channel data in 8 3 byte chunks
                bit24ChannelData[dev-1][(i*3) + j] = xfer(0x00);  // raw data completely raw, unedited
                if(DIVIDER == SPI_CLOCK_DIV2 || DIVIDER == SPI_CLOCK_DIV4) delayMicroseconds(2); //must wait 4tCLK; if SCLK_MHZ is higher than 4MHz then a delay must be introduced
            }
            if(bit24ChannelData[dev-1][(i*3) + 2] & 0b10000000) longChannelData[dev-1][i] = 0xFF000000;
            longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 2] << 16;
            longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 1] << 8;
            longChannelData[dev-1][i] &= bit24ChannelData[dev-1][(i*3) + 0] << 0;
        }
        csHigh(dev);       //  close SPI
    }
}

/* data xfer format:
 * DATA_HEADER  (1byte)                 hex 0x68    dec 104
 * INFO_BYTE    (1byte)
 * SAMPLE_NUM   (4bytes)
 * EPOCH_NUM    (1byte)
 * STAT_REG     (2bytes * totNumDev)    PCHAN followed by NCHAN
 * CHAN_DATA    (32bytes * totNumDev)   chan 1 first; MSB first; 2's complement; raw data from ADS
 * CHECKSUM     (1byte)                 data xor'd with DATA_HEADER in order of sending
 *
 * Maximum packet size 213 bytes or 1704 bits
 * Maximum data rate (from ADS) with 8 devices is 500SPS (at a serial baud rate of 921600baud)
 *
 * INFO_BYTE =
 * 7   RESV
 * 6:3 Number of active devices
 * 2:0 Current data rate
 *
 */

//!!!!! EPOCH NOT NEEDED, DEFAULT VALUE DECLARED IN HEADER
void ADS1299::transferChannelDataToPC(long sampleNum, byte epochNum) {
    byte checksum = DATA_HEADER;
    Serial.write(DATA_HEADER);
    
    Serial.write(((totNumDev-1)<<3) + dataRate); //send "INFO_BYTE"
    checksum ^= ((totNumDev-1)<<3) + dataRate;
    
    for(int i = 0; i < 4; ++i) {
        Serial.write((byte)(sampleNum>>(i*8) & 0xFF)); //transfer sampleNum in 4 bytes
        checksum ^= (byte)(sampleNum>>(i*8) & 0xFF);
    }
    
    Serial.write(epochNum);
    checksum ^= epochNum;
    
    
    for(int i = 0; i < totNumDev; ++i) { //print status register from all devices which are active
        Serial.write(statReg[i][PCHAN]);
        checksum ^= statReg[i][PCHAN];
        Serial.write(statReg[i][NCHAN]);
        checksum ^= statReg[i][NCHAN];
    }
    
    for(int d = 0; d < totNumDev; ++d) { //print channel data from all devices which are active
        for(int i = 0; i < 8; ++i) { //chan #
            for(int j = 0; j < 4; ++j) { //byte #, LSB first
                Serial.write((byte)(longChannelData[d][i]>>(j*8) & 0xFF)); //transfer sampleNum in 4 bytes
                checksum ^= (byte)(longChannelData[d][i]>>(j*8) & 0xFF);
            }
        }
    }
    Serial.write(checksum);
    
    return;
}









//  <<<<<<  PAGE 2, CHANNEL OPTIONS  >>>>>>

//turn channels on and off
//accessing the regMirror array with LOFF+chan allows us to keep chan non-zero (i.e. the first device is referenced as dev = 1, NOT dev = 0
void ADS1299::changeChannelState(byte dev, byte chan, bool state) {      regMirror[dev-1][LOFF+chan] = (regMirror[dev-1][LOFF+chan] & 0b01111111) | ((!state) << 7);     WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]); } //State, bit 7
void ADS1299::changeChannelGain(byte dev, byte chan, byte GAIN_CODE) {   regMirror[dev-1][LOFF+chan] = (regMirror[dev-1][LOFF+chan] & 0b10001111) | GAIN_CODE;           WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]); } //Gain, bits 6:4
void ADS1299::changeChannelSRB2(byte dev, byte chan, bool SRB2Conn) {    regMirror[dev-1][LOFF+chan] = (regMirror[dev-1][LOFF+chan] & 0b11110111) | (SRB2Conn << 3);     WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]); } //SRB2, bit 3
void ADS1299::changeChannelMUX(byte dev, byte chan, byte MUX_CODE) {     regMirror[dev-1][LOFF+chan] = (regMirror[dev-1][LOFF+chan] & 0b11111000) | MUX_CODE;            WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]); } //MUX, bits 2:0

//ACTIVE TEST SIGNALS
void ADS1299::activateTestSignal(byte dev, byte TEST_AMP_CODE, byte TEST_FREQ_CODE) {
    regMirror[dev-1][CONFIG2] = 0b11010000 | TEST_AMP_CODE | TEST_FREQ_CODE; //Set test signals to generate interally, and set amplitude and frequency
    WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]);
    for(int i = 0; i < 8; ++i) {
        regMirror[dev-1][CH1SET+i] = (regMirror[dev-1][CH1SET+i] & 0b01111000) | MUX_TESTSIG; // turn all channels on and set all channels to "TEST_SIGNAL" MUX
        WREG(dev, CH1SET+i, regMirror[dev-1][CH1SET+i]);
    }
}
void ADS1299::activateTestShorted(byte dev) {
    for(int i = 0; i < 8; ++i) {
        regMirror[dev-1][CH1SET+i] = (regMirror[dev-1][CH1SET+i] & 0b01111000) | MUX_SHORTED; // turn all channels on and set all channels to "TEST_SIGNAL" MUX
        WREG(dev, CH1SET+i, regMirror[dev-1][CH1SET+i]);
    }
}

void ADS1299::internalTestSigGen(byte dev) { regMirror[dev-1][CONFIG2] &= 0b11101111; WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]); }
void ADS1299::externalTestSigGen(byte dev) { regMirror[dev-1][CONFIG2] |= 0b00010000; WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]); }


//DEACTIVATE TEST SIGNALS
void ADS1299::deactivateTestSignal(byte dev) {
    regMirror[dev-1][CONFIG2] = 0b11000000; //set test signals to generate externally
    WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]);
    for(int i = 0; i < 8; ++i) {
        regMirror[dev-1][CH1SET+i] = (regMirror[dev-1][CH1SET+i] & 0b11111000) | MUX_NORMAL; // keep all channels at current powered up/down state and set all channels to "NORMAL" MUX, and set test sigs to generate externally
        WREG(dev, CH1SET+i, regMirror[dev-1][CH1SET+i]);
    }
}
void ADS1299::deactivateTestShorted(byte dev) {
    for(int i = 0; i < 8; ++i) {
        regMirror[dev-1][CH1SET+i] = (regMirror[dev-1][CH1SET+i] & 0b11111000) | MUX_NORMAL; // keep all channels at current powered up/down state and set all channels to "NORMAL" MUX
        WREG(dev, CH1SET+i, regMirror[dev-1][CH1SET+i]);
    }
}


void ADS1299::changeTestSigAmplitude(byte dev, byte TEST_AMP_CODE)  { regMirror[dev-1][CONFIG2] = (regMirror[dev-1][CONFIG2] & 0b11111011) | TEST_AMP_CODE;  WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]); }
void ADS1299::changeTestSigFrequency(byte dev, byte TEST_FREQ_CODE) { regMirror[dev-1][CONFIG2] = (regMirror[dev-1][CONFIG2] & 0b11111100) | TEST_FREQ_CODE; WREG(dev, CONFIG2, regMirror[dev-1][CONFIG2]); }




//  <<<<<<  PAGE 3, LOFF  >>>>>>

void ADS1299::disableLOFFComparator(byte dev) { regMirror[dev-1][CONFIG4] |= 0b11111101;  WREG(dev, CONFIG4, regMirror[dev-1][CONFIG4]); }
void ADS1299::enableLOFFComparator(byte dev) { regMirror[dev-1][CONFIG4] |= 0b00000010;  WREG(dev, CONFIG4, regMirror[dev-1][CONFIG4]); }

void ADS1299::setLOFFThreshold(byte dev, byte LOFF_THRESH_CODE) {       regMirror[dev-1][LOFF] = (regMirror[dev-1][LOFF] & 0b00011111) | LOFF_THRESH_CODE;  WREG(dev, LOFF, regMirror[dev][LOFF]); }
void ADS1299::setLOFFCurrentMagnitude(byte dev, byte LOFF_AMP_CODE) {    regMirror[dev-1][LOFF] = (regMirror[dev-1][LOFF] & 0b11110011) | LOFF_AMP_CODE;     WREG(dev, LOFF, regMirror[dev][LOFF]); }
void ADS1299::setLOFFFrequency(byte dev, byte LOFF_FREQ_CODE) {               regMirror[dev-1][LOFF] = (regMirror[dev-1][LOFF] & 0b11111100) | LOFF_FREQ_CODE;    WREG(dev, LOFF, regMirror[dev][LOFF]); }


void ADS1299::changeChannelLOFFDetectP(byte dev, byte chan, bool state) { //enabled or disable LOFF sense for channel
    regMirror[dev-1][LOFF_SENSP] &= (!(0x1 << (chan-1)));
    if(state == ENABLE || state == ON ) regMirror[dev-1][LOFF_SENSP] = regMirror[dev-1][LOFF_SENSP] | (0x1 << (chan-1));
    WREG(dev, LOFF_SENSP, regMirror[dev-1][LOFF_SENSP]);
}
void ADS1299::changeChannelLOFFDetectN(byte dev, byte chan, bool state) {
    regMirror[dev-1][LOFF_SENSN] &= (!(0x1 << (chan-1)));
    if(state == ENABLE || state == ON ) regMirror[dev-1][LOFF_SENSN] = regMirror[dev-1][LOFF_SENSN] | (0x1 << (chan-1));
    WREG(dev, LOFF_SENSN, regMirror[dev-1][LOFF_SENSN]);
}
void ADS1299::changeChannelLOFFCurDir(byte dev, byte chan, bool INV_OR_NONINV) {
    regMirror[dev-1][LOFF_FLIP] &= (!(0x1 << (chan-1)));
    if(INV_OR_NONINV == INV) regMirror[dev-1][LOFF_FLIP] = regMirror[dev-1][LOFF_FLIP] | (0x1 << (chan-1));
    WREG(dev, LOFF_FLIP, regMirror[dev-1][LOFF_FLIP]);
}

bool runBiasLOFFSense(byte dev) {return 1;}
//TODO






//  <<<<<<  PAGE 4, BIAS  >>>>>>

// ENABLE / DISABLE BIAS
void ADS1299::enableInternalBiasBuf(byte dev) {  regMirror[dev-1][CONFIG3] |= 0b00000100;    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }
void ADS1299::disableInternalBiasBuf(byte dev) { regMirror[dev-1][CONFIG3] &= 0b11111011;    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }

void ADS1299::rerouteBiasToChan(byte dev, byte chan, bool P_OR_N) {
    regMirror[dev-1][BIAS_SENSP] &= (!(0x1 << (chan-1)));
    regMirror[dev-1][BIAS_SENSN] &= (!(0x1 << (chan-1))); //remove select channel from bias derivation
    regMirror[dev-1][LOFF_SENSP] &= (!(0x1 << (chan-1)));
    regMirror[dev-1][LOFF_SENSN] &= (!(0x1 << (chan-1))); //remove select channel from LOFF
    regMirror[dev-1][LOFF+chan] &= 0b11111000;
    if(P_OR_N == PCHAN) regMirror[dev-1][LOFF+chan] |= MUX_BIAS_DRP; //set channel mux to either bias drive P or bias drive N
    else regMirror[dev-1][LOFF+chan] |= MUX_BIAS_DRN;
    
    WREG(dev, BIAS_SENSP, regMirror[dev-1][BIAS_SENSP]);
    WREG(dev, BIAS_SENSN, regMirror[dev-1][BIAS_SENSN]);
    WREG(dev, LOFF_SENSP, regMirror[dev-1][LOFF_SENSP]);
    WREG(dev, LOFF_SENSN, regMirror[dev-1][LOFF_SENSN]);
    WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]);
}

void ADS1299::disableRerouteBias(byte dev, byte chan) {
    regMirror[dev-1][LOFF+chan] &= 0b11111000; //set channel mux to normal (bits 2:0, mux code "000")
    WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]);
}

//Bias signal can be measured w/ usual ADC function of ADS chip
void ADS1299::measureBiasOnChan(byte dev, byte chan) {
    regMirror[dev-1][BIAS_SENSP] &= (!(0x1 << (chan-1)));
    regMirror[dev-1][BIAS_SENSN] &= (!(0x1 << (chan-1))); //remove select channel from bias derivation
    regMirror[dev-1][LOFF+chan] &= 0b11111000;
    regMirror[dev-1][LOFF+chan] |= MUX_BIAS_MEAS; //MUX channel to "bias measure"
    regMirror[dev-1][CONFIG3] |= 0b00010000; //set BIAS_MEAS; routes BIASIN to whatever channel has MUX_BIAS_MEAS signal attached
    
    WREG(dev, BIAS_SENSP, regMirror[dev-1][BIAS_SENSP]);
    WREG(dev, BIAS_SENSN, regMirror[dev-1][BIAS_SENSN]);
    WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]);
    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]);
}
void ADS1299::disableBiasMeasure(byte dev, byte chan) {
    regMirror[dev-1][LOFF+chan] &= 0b11111000;//set channel mux to normal (bits 2:0, mux code "000")
    regMirror[dev-1][CONFIG3] &= 0b11101111; //clear BIAS_MEAS
    
    WREG(dev, LOFF+chan, regMirror[dev-1][LOFF+chan]);
    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]);
}


void ADS1299::setBiasRefInt(byte dev) {          regMirror[dev-1][CONFIG3] &= 0b11110111;    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }
void ADS1299::setBiasRefExt(byte dev) {          regMirror[dev-1][CONFIG3] |= 0b00001000;    WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }

//enable or disable channel inclusion in bias generation
void ADS1299::changeChannelBiasDerivP(byte dev, byte chan, bool state) {
    if(state == ON) regMirror[dev-1][BIAS_SENSP] |= (0x1 << (chan-1));
    if(state == OFF) regMirror[dev-1][BIAS_SENSP] &= !(0x1 << (chan-1));
    WREG(dev, BIAS_SENSP, regMirror[dev-1][BIAS_SENSP]);
}
void ADS1299::changeChannelBiasDerivN(byte dev, byte chan, bool state) {
    if(state == ON) regMirror[dev-1][BIAS_SENSN] |= (0x1 << (chan-1));
    if(state == OFF) regMirror[dev-1][BIAS_SENSN] &= !(0x1 << (chan-1));
    WREG(dev, BIAS_SENSN, regMirror[dev-1][BIAS_SENSN]);
}





//  <<<<<<  PAGE 5, DEVICE CONFIGURATION  >>>>>>

void ADS1299::enableOscOut(byte dev) {          regMirror[dev-1][CONFIG1] |= 0b00100000;       WREG(dev, CONFIG1, regMirror[dev-1][CONFIG1]); }
void ADS1299::disableOscOut(byte dev) {         regMirror[dev-1][CONFIG1] &= 0b11011111;       WREG(dev, CONFIG1, regMirror[dev-1][CONFIG1]); }

void ADS1299::enableDaisyChain(byte dev) {      regMirror[dev-1][CONFIG1] &= 0b10111111;       WREG(dev, CONFIG1, regMirror[dev-1][CONFIG1]); }
void ADS1299::disableDaisyChain(byte dev) {     regMirror[dev-1][CONFIG1] |= 0b01000000;       WREG(dev, CONFIG1, regMirror[dev-1][CONFIG1]); }


void ADS1299::enableInternalRefBuf(byte dev) {  regMirror[dev-1][CONFIG3] |= 0b10000000;       WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }
void ADS1299::disableInternalRefBuf(byte dev) { regMirror[dev-1][CONFIG3] &= 0b01111111;       WREG(dev, CONFIG3, regMirror[dev-1][CONFIG3]); }

void ADS1299::connectSRB1(byte dev) {           regMirror[dev-1][MISC1] = 0b00100000;          WREG(dev, MISC1, regMirror[dev-1][MISC1]); }
void ADS1299::disconnectSRB1(byte dev) {        regMirror[dev-1][MISC1] = 0b00000000;          WREG(dev, MISC1, regMirror[dev-1][MISC1]); }

void ADS1299::conversationModeContinuous(byte dev) { regMirror[dev-1][CONFIG4] &= 0b11110111;  WREG(dev, CONFIG4, regMirror[dev-1][CONFIG4]); }
void ADS1299::conversationModeSingleShot(byte dev) { regMirror[dev-1][CONFIG4] |= 0b00001000;  WREG(dev, CONFIG4, regMirror[dev-1][CONFIG4]); }








//  <<<<<<  OTHER COMMANDS  >>>>>>

// simple hello world com check
byte ADS1299::getDeviceID(byte dev) {
    SDATAC(dev);
    csLow(dev);
    byte data = RREG(dev, 0x00);
    csHigh(dev);
    regMirror[dev-1][ID] = data;
    return data;
}

//SERIAL DATA REPORTING
void ADS1299::printDeviceID(byte dev) {
    SDATAC(dev);
    getDeviceID(dev);
    Serial.print("Device ID: ");
    printHex(regMirror[dev-1][ID]);
    Serial.print("\n");
}

//print out the state of all the control registers
void ADS1299::printAllRegisters(byte dev) {
    byte inbyte = 0;
    SDATAC(dev);
    for(int i = 0; i <= CONFIG4; ++i) {
        printHex(i);
        Serial.print(",\t");
        printRegisterName(i);
        inbyte = RREG(dev, i);
        printHex(inbyte);
        Serial.print(",\t");
        printBinary(inbyte);
        Serial.println("");
    }
}

// String-Byte converters for RREG and WREG
void ADS1299::printRegisterName(byte _address) { //GLOBAL
    if(_address == ID) Serial.print("ID,\t\t");
    else if(_address == CONFIG1) Serial.print("CONFIG1,\t");
    else if(_address == CONFIG2) Serial.print("CONFIG2,\t");
    else if(_address == CONFIG3) Serial.print("CONFIG3,\t");
    else if(_address == LOFF) Serial.print("LOFF,\t\t");
    else if(_address == CH1SET) Serial.print("CH1SET,\t\t");
    else if(_address == CH2SET) Serial.print("CH2SET,\t\t");
    else if(_address == CH3SET) Serial.print("CH3SET,\t\t");
    else if(_address == CH4SET) Serial.print("CH4SET,\t\t");
    else if(_address == CH5SET) Serial.print("CH5SET,\t\t");
    else if(_address == CH6SET) Serial.print("CH6SET,\t\t");
    else if(_address == CH7SET) Serial.print("CH7SET,\t\t");
    else if(_address == CH8SET) Serial.print("CH8SET,\t\t");
    else if(_address == BIAS_SENSP) Serial.print("BIAS_SENSP,\t");
    else if(_address == BIAS_SENSN) Serial.print("BIAS_SENSN,\t");
    else if(_address == LOFF_SENSP) Serial.print("LOFF_SENSP,\t");
    else if(_address == LOFF_SENSN) Serial.print("LOFF_SENSN,\t");
    else if(_address == LOFF_FLIP)  Serial.print("LOFF_FLIP,\t");
    else if(_address == LOFF_STATP) Serial.print("LOFF_STATP,\t");
    else if(_address == LOFF_STATN) Serial.print("LOFF_STATN,\t");
    else if(_address == GPIO) Serial.print("GPIO,\t\t");
    else if(_address == MISC1) Serial.print("MISC1,\t\t");
    else if(_address == MISC2) Serial.print("MISC2,\t\t");
    else if(_address == CONFIG4) Serial.print("CONFIG4,\t");
}

// Used for printing HEX in verbosity feedback mode
void ADS1299::printHex(byte _data){ //GLOBAL
    Serial.print("0x");
    if(_data < 0x10) Serial.print("0");
    Serial.print(_data, HEX);
}

void ADS1299::printBinary(byte _data) {
    Serial.print("0b");
    if      (_data < 0b00000010) Serial.print("0000000");
    else if (_data < 0b00000100) Serial.print("000000");
    else if (_data < 0b00001000) Serial.print("00000");
    else if (_data < 0b00010000) Serial.print("0000");
    else if (_data < 0b00100000) Serial.print("000");
    else if (_data < 0b01000000) Serial.print("00");
    else if (_data < 0b10000000) Serial.print("0");
    Serial.print(_data, BIN);
}

int ADS1299::charToInt(char charTo) {
    if(charTo == '0') return 0;
    else if(charTo == '1') return 1;
    else if(charTo == '2') return 2;
    else if(charTo == '3') return 3;
    else if(charTo == '4') return 4;
    else if(charTo == '5') return 5;
    else if(charTo == '6') return 6;
    else if(charTo == '7') return 7;
    else if(charTo == '8') return 8;
    else if(charTo == '9') return 9;
    else if(charTo == 'A') return 10;
    else if(charTo == 'B') return 11;
    else if(charTo == 'C') return 12;
    else if(charTo == 'D') return 13;
    else if(charTo == 'E') return 14;
    else if(charTo == 'F') return 15;
    else return 0;
}







//  <<<<<<  PRIVATE  >>>>>>
//Sync ADS / Register Mirror
void ADS1299::syncADStoMirror(byte dev) { for(int i = 0; i <= CONFIG4; ++i) regMirror[dev-1][i] = RREG(dev, i); }
void ADS1299::syncMirrorToADS(byte dev) { for(int i = 0; i <= CONFIG4; ++i) WREG(dev, i, regMirror[dev-1][i]) ; }

// ADS Slave Select
void ADS1299::csLow(byte dev) {  digitalWrite(CS[dev-1], LOW); }
void ADS1299::csHigh(byte dev) { digitalWrite(CS[dev-1], HIGH); }