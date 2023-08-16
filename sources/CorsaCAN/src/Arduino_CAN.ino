#include <SPI.h>              //Library for using SPI Communication 
#include <mcp2515.h>          //Library for using CAN Communication (https://github.com/autowp/arduino-mcp2515/)

struct can_frame canMsg;
MCP2515 mcp2515(10);                 // SPI CS Pin 10
 
void setup()
{
  Serial.begin(115200);                //Begins Serial Communication at 9600 baudrate
  Serial.println("Running!");
 
  mcp2515.reset();
  mcp2515.setBitrate(CAN_500KBPS, MCP_16MHZ); //Sets CAN at speed 500KBPS and Clock 8MHz
  mcp2515.setNormalMode();                  //Sets CAN at normal mode
}
 

char buffer[6];
 
void loop()
{
  if (mcp2515.readMessage(&canMsg) == MCP2515::ERROR_OK) // To receive data (Poll Read)
  {
    Serial.print("ID: 0x");
    Serial.print(canMsg.can_id, HEX);
    Serial.print("; DLC: 0x");
    Serial.print(canMsg.can_dlc, HEX);
    Serial.print("; DATA:");

    for (int i = 0; i < 8; i++) {
      Serial.print(" 0x");


      sprintf(buffer, "%02x", canMsg.data[i]);
      Serial.print(buffer);
    }

    Serial.println();
  }
}