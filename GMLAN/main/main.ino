#include <mcp_can.h>
#include <SPI.h>

#define CAN0_INT 3    // INT pin
MCP_CAN CAN0(10);      // CS pin

#define CAN1_INT 2
MCP_CAN CAN1(9);

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

	while (wait) {
		if (Serial.readBytes(byteBuf, 1) > 0) {
			if (byteBuf[0] == 0x42) {
				wait = false;
			}
		}
	}
	
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

void serial_send(byte CANsrc, rxid_t rxID, byte CAN_len, byte* CAN_buf) {
	int len = 0;
	int idx = 0;
	
	sendBuf[idx++] = CANsrc;
	
	for (int i = 0; i < sizeof(rxid_t); i++) {
		sendbuf[idx++] = ((byte*)&rxID)[i];
		len++;
	}
	
	sendbuf[idx++] = CAN_len;
	
	for (int i = 0; i < CAN_len; i++) {
		sendbuf[idx++] = CAN_buf[i];
		len++;
	}
	
	Serial.write(sendBuf, len);
	
	/*Serial.write(CANsrc);
	Serial.write((byte*)&rxID, sizeof(rxid_t));
	Serial.write(CAN_len);
	Serial.write(CAN_buf, CAN_len);*/
}


void loop() {
	if (!digitalRead(CAN0_INT)) {
		CAN0.readMsgBuf(&rxID, &byteLen, byteBuf);
		serial_send(0, rxID, byteLen, byteBuf);
	}
	
	if (!digitalRead(CAN1_INT)) {
		CAN1.readMsgBuf(&rxID, &byteLen, byteBuf);
		serial_send(1, rxID, byteLen, byteBuf);
	}
}