#include <mcp_can.h>
#include <SPI.h>

#define CAN0_INT 2    // INT pin
MCP_CAN CAN0(10);      // CS pin

byte CAN0_byteBuf[256];
byte CAN0_len;
unsigned long CAN0_rxID;

void setup() {
	Serial.begin(2000000);

	while (!Serial) {
	}

	if (CAN0.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ) == CAN_OK) {
		Serial.println("READY");
	} else {
		Serial.println("ERROR");
	}

	bool wait = true;
	while (wait) {
		if (Serial.readBytes(CAN0_byteBuf, 1) > 0) {
			if (CAN0_byteBuf[0] == 0x42) {
				wait = false;
			}
		}
	}
	
	Serial.println("SWITCHBIN");
	pinMode(2, INPUT);
}


void loop() {
	delay(500);
	
	// CAN0.readMsgBuf(&CAN0_rxID, &CAN0_len, CAN0_byteBuf);
	
	CAN0_len = 10;
	CAN0_rxID = 0xAABBCCDD;
	
	Serial.write((byte*)&CAN0_rxID, sizeof(unsigned long));
	Serial.write(CAN0_len);
	Serial.write(CAN0_byteBuf, 10);
}
