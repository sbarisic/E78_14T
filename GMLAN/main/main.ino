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

void setup() {
	Serial.begin(2000000);
	
	while (!Serial) {
	}
	
	Serial.print("sizeof(rxid_t) = ");
	Serial.print(sizeof(rxid_t));
	Serial.println("");

	if (CAN0.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ) == CAN_OK) {
		Serial.println("READY CAN0");
		CAN0.setMode(MCP_NORMAL);
	} else {
		Serial.println("ERROR CAN0");
	}

	if (CAN1.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ) == CAN_OK) {
		Serial.println("READY CAN1");
		CAN1.setMode(MCP_NORMAL);
	} else {
		Serial.println("ERROR CAN1");
	}
	
	SPI.setClockDivider(SPI_CLOCK_DIV2);
	pinMode(CAN0_INT, INPUT);
	pinMode(CAN1_INT, INPUT);
	
	
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

void sevenbit_encode(byte* RawData, byte RawDataLen, byte* FrameData, byte* OutLen) {
	byte FrameIdx = 0;
	byte ExtraBitCount = 0;
	byte ExtraBits = 0;

	// Placeholder for length
	FrameData[FrameIdx++] = 0b10000000;

	for (byte i = 0; i < RawDataLen; i++) {
		// Calculate shifted byte
		int B = (RawData[i] >> 1) & 0b01111111;

		// Add shifted byte
		FrameData[FrameIdx++] = (byte)B;

		// Put extra bit aside
		ExtraBits = (byte)((ExtraBits << 1) | (RawData[i] & 0x1));
		ExtraBitCount++;

		// If enough extra bits, add extra bits
		if (ExtraBitCount == 7) {
			FrameData[FrameIdx++] = ExtraBits;

			ExtraBits = 0;
			ExtraBitCount = 0;
		}
	}

	// If leftover extra bits, add extra bits
	if (ExtraBitCount > 0) {
		FrameData[FrameIdx++] = (byte)(ExtraBits << (7 - ExtraBitCount));
	}

	FrameData[0] |= (byte)(FrameIdx - 1);
	*OutLen = FrameIdx;
}

byte sendBuf[111];
byte encSendBuf[128];

void serial_send(byte CANsrc, rxid_t rxID, byte CAN_len, byte* CAN_buf) {
	byte idx = 0;
	sendBuf[idx++] = CANsrc;
	
	for (int i = 0; i < sizeof(rxid_t); i++) {
		sendBuf[idx++] = ((byte*)&rxID)[i];
	}
	
	sendBuf[idx++] = CAN_len;
	
	for (int i = 0; i < CAN_len; i++) {
		sendBuf[idx++] = CAN_buf[i];
	}
	
	/*Serial.print("Count: ");
	Serial.println(idx);
	for (int i = 0; i < idx; i++) {
		Serial.print(sendBuf[i], HEX);
		Serial.print(" ");
	}
	Serial.println("");*/
	
	sevenbit_encode(sendBuf, idx, encSendBuf, &idx);
	Serial.write(encSendBuf, idx);
	
	/*Serial.print("Count: ");
	Serial.println(idx);
	for (int i = 0; i < idx; i++) {
		Serial.print(encSendBuf[i], BIN);
		Serial.print(" ");
	}
	Serial.println("");*/
	
	
	// old
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
	
	/*delay(1000);
	byteBuf[0] = 0x69;
	can_send(1, 0x33, 1, byteBuf);*/
}
