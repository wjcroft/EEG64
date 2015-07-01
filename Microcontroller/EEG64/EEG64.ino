/*
 
 Developed by Chip Audette (Fall 2013) for use with OpenBCI
 Builds upon work by Joel Murphy and Conor Russomanno (Summer 2013)
 
 Modified January 2014.
 
 This example uses the ADS1299 Arduino Library, a software bridge between the ADS1299 TI chip and
 Arduino. See http://www.ti.com/product/ads1299 for more information about the device and the README
 folder in the ADS1299 directory for more information about the library.
 
 */
 
#include "Energia.h"
#include "MySPI.h"
#include "ADS1299.h"
#include "Definitions.h"

long micros_cs = 0;

typedef long int int32;

ADS1299 ADSMAN;

//void serialEvent(void);

void setup() {
  
    Serial.begin(115200);
    Serial.flush();
    ADSMAN.initialize(1);
        
} // end of setup

long sampleNum = 1;
byte epochNum = 0;

//TEST
bool initDataTransfer = true;
//bool initDataTransfer = false;

void loop() {
  if(initDataTransfer && ADSMAN.isDataAvailable()) {
    ADSMAN.updateChannelData();
    ADSMAN.transferChannelDataToPC(sampleNum);
    sampleNum++;
  }
  //TEST
  if(sampleNum > 100) while(1);
} // end of loop

void serialEvent(){            // send an 'x' on the serial line to trigger ADStest()
    while(Serial.available()){
        
        byte headerPacket = Serial.read();
        
        byte cmdByte = Serial.read();
        byte device = Serial.read();
        byte param1 = Serial.read();
        byte param2 = Serial.read();
        byte param3 = Serial.read();
        
        byte chksum = Serial.read();
        
        //if check sum is bad
        if ( ( headerPacket ^ (cmdByte ^ (device ^ (param1 ^ (param2 ^ param3)))) ) != chksum ) {
            Serial.write(0x46); //ack header
            Serial.write(0xBA); //bad checksum / packet
            Serial.write( ( headerPacket ^ (cmdByte ^ (device ^ (param1 ^ (param2 ^ param3)))) ) );

            /*wait until serial data becomes available then recursively call serialEvent()
            while(!Serial.available());
            serialEvent();
            return; */
            return; //just return to collect more data; serial data can be sent again and serialEvent() called after data from ADS is read
        }
        
        //if checksum is good
        Serial.write(0x46); //ack header
        Serial.write(0xA1); //good checksum
        
        switch ((char)cmdByte) {
          case 'S':
                initDataTransfer = true;
                Serial.write('S');
                break;
          case 'H':
                initDataTransfer = false;
                Serial.write('H');
                break;
            default:
                Serial.write((char)cmdByte);
                break;
        }
    }
}


