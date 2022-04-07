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

typedef struct {
	rxid_t rxid;
	byte src;
	byte datalen;
	byte data[8];
} can_packet;

void setup() {
	Serial.begin(2000000);
	
	while (!Serial) {
	}
	
	Serial.print("sizeof(rxid_t) = ");
	Serial.print(sizeof(rxid_t));
	Serial.println("");

	if (CAN0.begin(CAN_500KBPS) == CAN_OK) {
		Serial.println("READY CAN0");
		//CAN0.setMode(MCP_NORMAL);
	} else {
		Serial.println("ERROR CAN0");
	}

	if (CAN1.begin(CAN_500KBPS) == CAN_OK) {
		Serial.println("READY CAN1");
		//CAN1.setMode(MCP_NORMAL);
	} else {
		Serial.println("ERROR CAN1");
	}
	
	SPI.setClockDivider(SPI_CLOCK_DIV2);
	pinMode(CAN0_INT, INPUT);
	pinMode(CAN1_INT, INPUT);
	
	//attachInterrupt(digitalPinToInterrupt(CAN0_INT), on_data_CAN0, LOW);
	//attachInterrupt(digitalPinToInterrupt(CAN1_INT), on_data_CAN1, LOW);
	
	
	/*delay(2000);
	
	byteLen = 3;
	byteBuf[0] = 0x45;	
	byteBuf[1] = 0xAB;	
	byteBuf[2] = 0x69;
	CAN1.sendMsgBuf(0xAABB, 1, byteLen, byteBuf);*/
	
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

void can_send(byte CANsrc, rxid_t rxID, byte CAN_len, byte* CAN_buf) {
	MCP_CAN* can = NULL;
	
	if (CANsrc == 0) {
		can = &CAN0;
	} else {
		can = &CAN1;
	}
	
	can->sendMsgBuf(rxID, 0, CAN_len, CAN_buf);
}

volatile byte can_packet_count;
volatile can_packet can_packets[16];

void on_data_CAN0() {
	rxid_t can0_rxid;
	byte can0_bytebuf[16];
	byte can0_bytelen;
	
	if (CAN0.checkReceive() == CAN_MSGAVAIL) {
	
	}
	
	if (CAN0.readMsgBuf(&can0_rxid, &can0_bytelen, can0_bytebuf) == CAN_OK) {
		byte free_idx = can_packet_count++;

		can_packets[free_idx].rxid = can0_rxid;
		can_packets[free_idx].src = 0;
		can_packets[free_idx].datalen = can0_bytelen;
		memcpy(can_packets[free_idx].datalen, can0_bytebuf, can0_bytelen);
	}
}

void on_data_CAN1() {
}

void loop() {
	/*if (!digitalRead(CAN0_INT)) {
		if (CAN0.readMsgBuf(&rxID, &byteLen, byteBuf) == CAN_OK) {
			serial_send(0, rxID, byteLen, byteBuf);
		}
	}*/
	
	if (can_packet_count > 0) {
		can_packet_count--;
		
		Serial.println("YEET YEET");
	}
	
	//can_send(1, 0x0FFFE094, 0, byteBuf);
	
	//can_send(1, 0x0FFFE094, 0, byteBuf);
	
	
	/*byteBuf[0] = 0x3C;
	byteBuf[1] = 0x00;
	byteBuf[2] = 0x00;
	byteBuf[3] = 0x00;
	byteBuf[4] = 0x3C;
	byteBuf[5] = 0x00;
	byteBuf[6] = 0x00;
	byteBuf[7] = 0x00;
	can_send(1, 0xC5, 8, byteBuf);*/
	
	
	// can_send(1, 0x0FFFE094, 0, byteBuf);
	
	/*if (!digitalRead(CAN1_INT)) {
		if (CAN1.readMsgBuf(&rxID, &byteLen, byteBuf) == CAN_OK) {
			serial_send(1, rxID, byteLen, byteBuf);
		}
	}*/
	
	/*delay(1000);
	byteBuf[0] = 0x69;
	can_send(1, 0x33, 1, byteBuf);*/
}
