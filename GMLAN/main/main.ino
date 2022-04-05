#include <mcp_can.h>
#include <SPI.h>

#define CAN0_INT 3    // INT pin
MCP_CAN CAN0(10);      // CS pin

#define CAN1_INT 2
MCP_CAN CAN1(9);

#define WAIT_FOR_REQUEST

typedef long unsigned int rxid_t;

byte byteBuf[32];
byte byteLen;
rxid_t rxID;

byte sendBuf[256];

void setup() {
	Serial.begin(2000000);
	
	bool ready0 = false;
	bool ready1 = false;
	bool wait = true;

	while (!Serial) {
	}
	
	Serial.print("sizeof(rxid_t) = ");
	Serial.print(sizeof(rxid_t));
	Serial.println("");

	if (CAN0.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ) == CAN_OK) {
		Serial.println("READY CAN0");
		CAN0.setMode(MCP_NORMAL);
		ready0 = true;
	} else {
		Serial.println("ERROR CAN0");
	}

	if (CAN1.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ) == CAN_OK) {
		Serial.println("READY CAN1");
		CAN1.setMode(MCP_NORMAL);
		ready1 = true;
	} else {
		Serial.println("ERROR CAN1");
	}

	if (ready0 && ready1) {
		Serial.println("READY");
	}

#ifdef WAIT_FOR_REQUEST
	while (wait) {
		if (Serial.readBytes(byteBuf, 1) > 0) {
			if (byteBuf[0] == 0x42) {
				wait = false;
			}
		}
	}
#endif
	
	SPI.setClockDivider(SPI_CLOCK_DIV2);
	pinMode(CAN0_INT, INPUT);
	pinMode(CAN1_INT, INPUT);
	
	Serial.println("SWITCHBIN");
	/*delay(2000);
	
	byteLen = 3;
	byteBuf[0] = 0x45;	
	byteBuf[1] = 0xAB;	
	byteBuf[2] = 0x69;
	CAN1.sendMsgBuf(0xAABB, 1, byteLen, byteBuf);*/
}

void can_send(byte CANsrc, rxid_t rxID, byte CAN_len, byte* CAN_buf) {
	MCP_CAN* can = NULL;
	
	if (CANsrc == 0) {
		can = &CAN0;
	} else {
		can = &CAN1;
	}
	
	can->sendMsgBuf(rxID, CAN_len, CAN_buf);
}

void serial_send(byte CANsrc, rxid_t rxID, byte CAN_len, byte* CAN_buf) {
	int idx = 0;
	sendBuf[idx++] = CANsrc;
	
	for (int i = 0; i < sizeof(rxid_t); i++) {
		sendBuf[idx++] = ((byte*)&rxID)[i];
	}
	
	sendBuf[idx++] = CAN_len;
	
	for (int i = 0; i < CAN_len; i++) {
		sendBuf[idx++] = CAN_buf[i];
	}
	
	Serial.write(sendBuf, idx);
	
	/*Serial.write(CANsrc);
	Serial.write((byte*)&rxID, sizeof(rxid_t));
	Serial.write(CAN_len);
	Serial.write(CAN_buf, CAN_len);*/
}


void loop() {
	if (!digitalRead(CAN0_INT)) {
		if (CAN0.readMsgBuf(&rxID, &byteLen, byteBuf) == CAN_OK) {
			serial_send(0, rxID, byteLen, byteBuf);
		}
	}
	
	if (!digitalRead(CAN1_INT)) {
		if (CAN1.readMsgBuf(&rxID, &byteLen, byteBuf) == CAN_OK) {
			serial_send(1, rxID, byteLen, byteBuf);
		}
	}
	
	delay(1000);
	can_send(1, 0x12ABCD, 1, byteBuf);
}
