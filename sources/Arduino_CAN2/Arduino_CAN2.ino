#include <mcp_can.h>
#include <SPI.h>

#define B0(i) (((i) & 0x1) << 0)
#define B1(i) (((i) & 0x1) << 1)
#define B2(i) (((i) & 0x1) << 2)
#define B3(i) (((i) & 0x1) << 3)
#define B4(i) (((i) & 0x1) << 4)
#define B5(i) (((i) & 0x1) << 5)
#define B6(i) (((i) & 0x1) << 6)
#define B7(i) (((i) & 0x1) << 7)

// Set INT to pin 2
#define CAN0_INT 2
MCP_CAN CAN0(10);

// Default reply ECU ID
#define REPLY_ID 0x7E8

unsigned long canId = 0;
byte len = 0;
byte buf[8];

byte tmp8[8] = {0};

//=================================================================
// Setup Needed Vars
//=================================================================

// Current Firmware Version
char FW_Version[] = "0.10";

// char str[20];
String canMessageRead = "";

// MIL on and DTC Present
bool MIL = true;

// Stored Vechicle VIN
// unsigned char vehicle_Vin[18] = "1WK58FB1111111111";
unsigned char vehicle_Vin[18] = "12345678910111213";

// Stored Calibration ID
unsigned char calibration_ID[18] = "12345678910111213";

// Stored CVN
unsigned char cvn_ID[18] = "12345678910111213";

// Stored ECU Name
unsigned char ecu_Name[19] = "ECM-EngineControl";

// OBD standards https://en.wikipedia.org/wiki/OBD-II_PIDs#Service_01_PID_1C
int obd_Std = 7;

// Fuel Type Coding https://en.wikipedia.org/wiki/OBD-II_PIDs#Fuel_Type_Coding
int fuel_Type = 1;

// Default PID values
unsigned int engine_Coolant_Temperature = 95;
int engine_Rpm = 950;
int vehicle_Speed = 0;
int timing_Advance = 10;
unsigned int intake_Temp = 25;
int maf_Air_Flow_Rate = 20;

//=================================================================
// Init CAN-BUS and Serial
//=================================================================

void setup()
{

    Serial.begin(115200);
    delay(100);

    pinMode(CAN0_INT, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(CAN0_INT), can0_receive, FALLING);

START_CAN_INIT:

    // Try and init your CAN-BUS sheild.
    // You will have to check your crystal oscillator on your CAN-BUS sheild and change 'MCP_16MHZ' accordingly.
    if (CAN_OK == CAN0.begin(MCP_ANY, CAN_500KBPS, MCP_16MHZ))
    {
        Serial.println("CAN BUS Shield init ok!");
        CAN0.setMode(MCP_NORMAL);
    }
    else
    {
        Serial.println("ERROR!!!! CAN-BUS Shield init fail");
        Serial.println("ERROR!!!! Will try to init CAN-BUS shield again");
        delay(1000);
        goto START_CAN_INIT;
    }
}

bool lastIsOut = true;

void print_frame(uint32_t id, size_t len, byte *buf, bool isOut)
{
    // Temp buffer
    char buffer[6];

    if (lastIsOut != isOut)
    {
        if (isOut)
        {
            Serial.println("OUT:");
        }
        else
        {
            Serial.println("IN:");
        }
    }

    lastIsOut = isOut;

    Serial.print("    ID: 0x");
    Serial.print(canId, HEX);
    Serial.print("; DLC: 0x");
    Serial.print(len, HEX);
    Serial.print("; DATA:");

    for (int i = 0; i < 8; i++)
    {
        // Serial.print(" 0x");

        sprintf(buffer, " %02x", buf[i]);
        Serial.print(buffer);
    }

    Serial.println();
}

void create_response_frame(byte *out, int service_mode, int pid, size_t len, byte *bytes)
{
    for (size_t i = 0; i < 8; i++)
        out[i] = 0;

    out[0] = len + 2;
    out[1] = service_mode + 0x40;
    out[2] = pid;

    for (size_t i = 0; i < len; i++)
    {
        out[i + 3] = bytes[i];
    }
}

void send_frame(uint32_t id, size_t len, byte *buf)
{
    print_frame(id, len, buf, true);
    CAN0.sendMsgBuf(id, len, buf);
}

void handle_service_01(int add_bytes, int pid, byte *buf)
{
    const int service_mode = 0x1;

    byte mode1Supported0x00PID[8] = {0x06, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    byte mode1Supported0x20PID[8] = {0x06, 0x41, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00};
    byte mode1Supported0x40PID[8] = {0x06, 0x41, 0x40, 0x04, 0x00, 0x00, 0x00, 0x00};

    // byte ABCD[4] = {0b01111111, 0b01110111, 0b11101111, 0b11101111};

    byte A = B7(0) | B0(0);
    byte B = B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
    byte C = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
    byte D = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0); // B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);

    byte B2 = B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
    byte C2 = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
    byte D2 = B7(0) | B6(0) | B5(1) | B4(0) | B3(0) | B2(0) | B1(0) | B0(1); // B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);

    byte monitoring1[8] = {0x06, 0x01 + 0x40, 0x01, A, B, C, D, 0};
    // byte monitoring2[8] = {0x06, 0x01 + 0x40, 0x41, 0b00000000, 0b01110111, 0b11101111, 0b11101111, 0};

    if (add_bytes == 2 && (pid == 0x0 || pid == 0x20 || pid == 0x40))
    {
        // Show PIDs supported

        byte *out = mode1Supported0x00PID;

        if (pid == 0x20)
            out = mode1Supported0x20PID;
        else if (pid == 0x40)
            out = mode1Supported0x40PID;

        send_frame(REPLY_ID, 8, out);
    }
    else if (add_bytes == 2 && (pid == 0x1 || pid == 0x41))
    {
        // 0x01 - Monitor status since DTCs cleared
        // 0x41 - Monitor status this drive cycle

        Serial.println("Emissions test");
        print_frame(canId, len, buf - 1, false);

        byte ABCD[4];

        if (pid == 0x1)
        {
            ABCD[0] = A;
            ABCD[1] = B;
            ABCD[2] = C;
            ABCD[3] = D;
            create_response_frame(tmp8, service_mode, pid, 4, ABCD);
        }
        else
        {
            ABCD[0] = 0;
            ABCD[1] = B2;
            ABCD[2] = C2;
            ABCD[3] = D2;
            create_response_frame(tmp8, service_mode, pid, 4, ABCD);
        }

        send_frame(REPLY_ID, 8, tmp8);
    }
}

void handle_service_06(int add_bytes, int pid, byte *buf)
{
    const int service_mode = 0x6;

    if (pid >= 0x1 && pid <= 0x20)
    {
        byte arr[4] = {0xFF, 0xAB, 0xCD, 0xEF};
        create_response_frame(tmp8, service_mode, pid, 4, arr);
        send_frame(REPLY_ID, 8, tmp8);
    }
}

void handle_service_09(int add_bytes, int pid, byte *buf)
{
    const int service_mode = 0x9;

    if (pid == 0x0) // Service 9 supported PIDs
    {
        byte A = B7(0) | B6(1) | B5(0) | B4(1) | B3(0) | B2(1) | B1(0) | B0(0);
        byte B = B7(0) | B6(1) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
        byte C = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
        byte D = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0); // B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0);
        byte ABCD[4] = {A, B, C, D};

        create_response_frame(tmp8, service_mode, pid, 4, ABCD);
        send_frame(REPLY_ID, 8, tmp8);
    }
    else if (pid == 0x2) // VIN
    {
        unsigned char frame1[8] = {0x10, 2 + 18, 0x49, pid, 1, vehicle_Vin[0], vehicle_Vin[1], vehicle_Vin[2]};
        unsigned char frame2[8] = {0x21, vehicle_Vin[3], vehicle_Vin[4], vehicle_Vin[5], vehicle_Vin[6], vehicle_Vin[7], vehicle_Vin[8], vehicle_Vin[9]};
        unsigned char frame3[8] = {0x22, vehicle_Vin[10], vehicle_Vin[11], vehicle_Vin[12], vehicle_Vin[13], vehicle_Vin[14], vehicle_Vin[15], vehicle_Vin[16]};

        send_frame(REPLY_ID, 8, frame1);
        send_frame(REPLY_ID, 8, frame2);
        send_frame(REPLY_ID, 8, frame3);
    }
    else if (pid == 0x4) // Cal ID
    {
        unsigned char frame1[8] = {0x10, 2 + 18, 0x49, pid, 1, calibration_ID[0], calibration_ID[1], calibration_ID[2]};
        unsigned char frame2[8] = {0x21, calibration_ID[3], calibration_ID[4], calibration_ID[5], calibration_ID[6], calibration_ID[7], calibration_ID[8], calibration_ID[9]};
        unsigned char frame3[8] = {0x22, calibration_ID[10], calibration_ID[11], calibration_ID[12], calibration_ID[13], calibration_ID[14], calibration_ID[15], calibration_ID[16]};

        send_frame(REPLY_ID, 8, frame1);
        send_frame(REPLY_ID, 8, frame2);
        send_frame(REPLY_ID, 8, frame3);
    }
    else if (pid == 0x6) // Calibration verification numbers
    {
        unsigned char frame1[8] = {0x10, 2 + (4 + 7 + 7 + 7 + 7), 0x49, pid, 0x08, 0xAB, 0xCD, 0xEF};
        unsigned char frame2[8] = {0x21, 0x00, 0x00, 0x00, 0xDE, 0xAD, 0xBE, 0xEF};
        unsigned char frame3[8] = {0x22, 0x00, 0x00, 0x00, 0xDE, 0xAD, 0xBE, 0xEF};
        unsigned char frame4[8] = {0x23, 0x00, 0x00, 0x00, 0xDE, 0xAD, 0xBE, 0xEF};
        unsigned char frame5[8] = {0x24, 0x00, 0x00, 0x00, 0xDE, 0xAD, 0xBE, 0xEF};

        send_frame(REPLY_ID, 8, frame1);
        send_frame(REPLY_ID, 8, frame2);
        send_frame(REPLY_ID, 8, frame3);
        send_frame(REPLY_ID, 8, frame4);
        send_frame(REPLY_ID, 8, frame5);
    }
    else if (pid == 0xA) // ECU Name
    {
        unsigned char frame1[8] = {0x10, 2 + 20, 0x49, pid, 1, ecu_Name[0], ecu_Name[1], ecu_Name[2]};
        unsigned char frame2[8] = {0x21, ecu_Name[3], ecu_Name[4], ecu_Name[5], ecu_Name[6], ecu_Name[7], ecu_Name[8], ecu_Name[9]};
        unsigned char frame3[8] = {0x22, ecu_Name[10], ecu_Name[11], ecu_Name[12], ecu_Name[13], ecu_Name[14], ecu_Name[15], ecu_Name[16]};
        unsigned char frame4[8] = {0x23, ecu_Name[17], ecu_Name[18]};

        send_frame(REPLY_ID, 8, frame1);
        send_frame(REPLY_ID, 8, frame2);
        send_frame(REPLY_ID, 8, frame3);
        send_frame(REPLY_ID, 8, frame4);
    }
}

void handle_request_frame(int address, int add_bytes, byte *buf)
{
    if (buf[0] == 0x1)
    {
        handle_service_01(add_bytes, buf[1], buf + 1);
    }
    else if (buf[0] == 0x6)
    {
        handle_service_06(add_bytes, buf[1], buf + 1);
    }
    else if (buf[0] == 0x9)
    {
        handle_service_09(add_bytes, buf[1], buf + 1);
    }
    else if (add_bytes == 1 && buf[0] == 0x3) // DTCs
    {
        if (MIL)
        {
            unsigned char DTC[] = {0x6, 0x43, 0x2, 0x04, 0x20, 0x04, 0x30, 0}; // P0217
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, DTC);
        }
        else
        {
            unsigned char DTC[] = {0x6, 0x43, 0, 0, 0, 0, 0, 0}; // No Stored DTC
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, DTC);
        }
    }
    else if (add_bytes == 1 && buf[0] == 0x4) // Clear DTCs
    {
        MIL = false;
    }
}

void can0_receive()
{
    if (CAN0.readMsgBuf(&canId, &len, buf) == CAN_OK)
    {
        print_frame(canId, len, buf, false);

        if (canId == 0x7DF)
        {
            int add_bytes = buf[0];
            handle_request_frame(canId, add_bytes, buf + 1);
        }
    }
}

void loop()
{

    return;

    //=================================================================
    // Random PID Values - Used if want in stand alone mode... Testing
    //=================================================================
    engine_Coolant_Temperature = random(-40, 215);
    engine_Rpm = random(-0, 16000);
    vehicle_Speed = random(-0, 255);
    timing_Advance = random(-64, 63);
    intake_Temp = random(-40, 215);
    maf_Air_Flow_Rate = random(0, 655);

    //=================================================================
    // Define ECU Supported PID's
    //=================================================================

    // Define the set of PIDs for MODE01 you wish you ECU to support.  For more information, see:
    // https://en.wikipedia.org/wiki/OBD-II_PIDs#Mode_1_PID_00
    //
    // PID 0x01 (1) - Monitor status since DTCs cleared. (Includes malfunction indicator lamp (MIL) status and number of DTCs.)
    // |   PID 0x05 (05) - Engine Coolant Temperature
    // |   |      PID 0x0C (12) - Engine RPM
    // |   |      |PID 0x0D (13) - Vehicle speed
    // |   |      ||PID 0x0E (14) - Timing advance
    // |   |      |||PID 0x0F (15) - Intake air temperature
    // |   |      ||||PID 0x10 (16) - MAF Air Flow Rate
    // |   |      |||||            PID 0x1C (28) - OBD standards this vehicle conforms to
    // |   |      |||||            |                              PID 0x51 (58) - Fuel Type
    // |   |      |||||            |                              |
    // v   V      VVVVV            V                              v
    // 10001000000111110000:000000010000000000000:0000000000000000100
    // Converted to hex, that is the following four byte value binary to hex
    // 0x881F0000 0x00 PID 01 -20
    // 0x02000000 0x20 PID 21 - 40
    // 0x04000000 0x40 PID 41 - 60

    // Next, we'll create the bytearray that will be the Supported PID query response data payload using the four bye supported pi hex value
    // we determined above (0x081F0000):

    //                               0x06 - additional meaningful bytes after this one (1 byte Service Mode, 1 byte PID we are sending, and the four by Supported PID value)
    //                                |    0x41 - This is a response (0x40) to a service mode 1 (0x01) query.  0x40 + 0x01 = 0x41
    //                                |     |    0x00 - The response is for PID 0x00 (Supported PIDS 1-20)
    //                                |     |     |    0x88 - The first of four bytes of the Supported PIDS value
    //                                |     |     |     |    0x1F - The second of four bytes of the Supported PIDS value
    //                                |     |     |     |     |    0x00 - The third of four bytes of the Supported PIDS value
    //                                |     |     |     |     |      |   0x00 - The fourth of four bytes of the Supported PIDS value
    //                                |     |     |     |     |      |    |    0x00 - OPTIONAL - Just extra zeros to fill up the 8 byte CAN message data payload)
    //                                |     |     |     |     |      |    |     |
    //                                V     V     V     V     V      V    V     V
    byte mode1Supported0x00PID[8] = {0x06, 0x41, 0x00, 0x88, 0x1F, 0x00, 0x00, 0x00};
    byte mode1Supported0x20PID[8] = {0x06, 0x41, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00};
    byte mode1Supported0x40PID[8] = {0x06, 0x41, 0x40, 0x04, 0x00, 0x00, 0x00, 0x00};

    // Define the set of PIDs for MODE09 you wish you ECU to support.
    // As per the information on bitwise encoded PIDs (https://en.wikipedia.org/wiki/OBD-II_PIDs#Mode_1_PID_00)
    // Our supported PID value is:
    //
    //  PID 0x02 - Vehicle Identification Number (VIN)
    //  | PID 0x04 (04) - Calibration ID
    //  | |     PID 0x0C (12) - ECU NAME
    //  | |     |
    //  V V     V
    // 01010000010  // Converted to hex, that is the following four byte value binary to hex
    // 0x28200000 0x00 PID 01-11

    // Next, we'll create the bytearray that will be the Supported PID query response data payload using the four bye supported pi hex value
    // we determined above (0x28200000):

    //                               0x06 - additional meaningful bytes after this one (1 byte Service Mode, 1 byte PID we are sending, and the four by Supported PID value)
    //                                |    0x41 - This is a response (0x40) to a service mode 1 (0x01) query.  0x40 + 0x01 = 0x41
    //                                |     |    0x00 - The response is for PID 0x00 (Supported PIDS 1-20)
    //                                |     |     |    0x28 - The first of four bytes of the Supported PIDS value
    //                                |     |     |     |    0x20 - The second of four bytes of the Supported PIDS value
    //                                |     |     |     |     |    0x00 - The third of four bytes of the Supported PIDS value
    //                                |     |     |     |     |      |   0x00 - The fourth of four bytes of the Supported PIDS value
    //                                |     |     |     |     |      |    |    0x00 - OPTIONAL - Just extra zeros to fill up the 8 byte CAN message data payload)
    //                                |     |     |     |     |      |    |     |
    //                                V     V     V     V     V      V    V     V
    byte mode9Supported0x00PID[8] = {0x06, 0x49, 0x00, 0x28, 0x28, 0xFF, 0xFF, 0x00};

    //=================================================================
    // Vars to help build msg
    //=================================================================

    ////Build setting return msg
    byte obd_Std_Msg[8] = {4, 65, 0x1C, (byte)(obd_Std)};
    byte fuel_Type_Msg[8] = {4, 65, 0x51, (byte)(fuel_Type)};

    // Work out eng RPM
    float rpm_Val = engine_Rpm * 4;
    unsigned int rpm_A = (long)rpm_Val / 256;
    unsigned int rpm_B = (long)rpm_Val % 256;

    // Work out MAF values
    float maf_Val = maf_Air_Flow_Rate * 100;
    unsigned int maf_A = (long)maf_Air_Flow_Rate / 256;
    unsigned int maf_B = (long)maf_Air_Flow_Rate;

    // Build sensor return msg
    byte engine_Coolant_Temperature_Msg[8] = {3, 65, 0x05, (byte)(engine_Coolant_Temperature + 40)};
    byte engine_Rpm_Msg[8] = {4, 65, 0x0C, (byte)rpm_A, (byte)rpm_B};
    byte vehicle_Speed_Msg[8] = {3, 65, 0x0D, (byte)(vehicle_Speed)};
    byte timing_Advance_Msg[8] = {3, 65, 0x0E, (byte)((timing_Advance + 64) * 2)};
    byte intake_Temp_Msg[8] = {3, 65, 0x0F, (byte)(intake_Temp + 40)};
    byte maf_Air_Flow_Rate_Msg[8] = {4, 65, 0x10, (byte)maf_A, (byte)maf_B};

    // if(CAN_MSGAVAIL == CAN.checkReceive())
    if (!digitalRead(CAN0_INT))
    {
        CAN0.readMsgBuf(&canId, &len, buf);
        // https://en.wikipedia.org/wiki/OBD-II_PIDs#CAN_(11-bit)_bus_format

        // Serial.print("Received: ");
        // Serial.print(canId, HEX);
        // Serial.print(",");

        /*for (int i = 0; i < 3; i++)
        {
            canMessageRead = canMessageRead + buf[i] + ",";
        }*/
        // Serial.println(canMessageRead);

        int add_bytes = buf[0];
        handle_request_frame(canId, add_bytes, buf + 1);
        return;

        //=================================================================
        // Return CAN-BUS Messages - SUPPORTED PID's
        //=================================================================

        if (canMessageRead == "2,1,0,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, mode1Supported0x00PID);
            print_frame(REPLY_ID, 8, mode1Supported0x00PID, true);
        }

        if (canMessageRead == "2,1,32,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, mode1Supported0x20PID);
            print_frame(REPLY_ID, 8, mode1Supported0x20PID, true);
        }

        if (canMessageRead == "2,1,64,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, mode1Supported0x40PID);
            print_frame(REPLY_ID, 8, mode1Supported0x40PID, true);
        }

        if (canMessageRead == "2,9,0,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, mode9Supported0x00PID);
            print_frame(REPLY_ID, 8, mode9Supported0x00PID, true);
        }

        //=================================================================
        // Return CAN-BUS Messages - RETURN PID VALUES - SENSORS
        //=================================================================

        // Engine Coolant
        if (canMessageRead == "2,1,5,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, engine_Coolant_Temperature_Msg);
            print_frame(REPLY_ID, 8, engine_Coolant_Temperature_Msg, true);
        }

        // Rpm
        if (canMessageRead == "2,1,12,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, engine_Rpm_Msg);
            print_frame(REPLY_ID, 8, engine_Rpm_Msg, true);
        }

        // Speed
        if (canMessageRead == "2,1,13,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, vehicle_Speed_Msg);
            print_frame(REPLY_ID, 8, vehicle_Speed_Msg, true);
        }

        // Timing Adv
        if (canMessageRead == "2,1,14,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, timing_Advance_Msg);
            print_frame(REPLY_ID, 8, timing_Advance_Msg, true);
        }

        // Intake Tempture
        if (canMessageRead == "2,1,15,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, intake_Temp_Msg);
            print_frame(REPLY_ID, 8, intake_Temp_Msg, true);
        }

        // MAF
        if (canMessageRead == "2,1,16,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, maf_Air_Flow_Rate_Msg);
            print_frame(REPLY_ID, 8, maf_Air_Flow_Rate_Msg, true);
        }

        // OBD standard
        if (canMessageRead == "2,1,28,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, obd_Std_Msg);
            print_frame(REPLY_ID, 8, obd_Std_Msg, true);
        }

        // Fuel Type Coding
        if (canMessageRead == "2,1,58,")
        {
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, fuel_Type_Msg);
            print_frame(REPLY_ID, 8, fuel_Type_Msg, true);
        }

        //=================================================================
        // Return CAN-BUS Messages - RETURN PID VALUES - DATA
        //=================================================================

        // VIN
        if (canMessageRead == "2,9,2,")
        {

            unsigned char frame1[8] = {16, 20, 73, 2, 1, vehicle_Vin[0], vehicle_Vin[1], vehicle_Vin[2]};
            unsigned char frame2[8] = {33, vehicle_Vin[3], vehicle_Vin[4], vehicle_Vin[5], vehicle_Vin[6], vehicle_Vin[7], vehicle_Vin[8], vehicle_Vin[9]};
            unsigned char frame3[8] = {34, vehicle_Vin[10], vehicle_Vin[11], vehicle_Vin[12], vehicle_Vin[13], vehicle_Vin[14], vehicle_Vin[15], vehicle_Vin[16]};

            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame1);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame2);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame3);
        }

        // CAL ID
        if (canMessageRead == "2,9,4,")
        {
            unsigned char frame1[8] = {16, 20, 73, 4, 1, calibration_ID[0], calibration_ID[1], calibration_ID[2]};
            unsigned char frame2[8] = {33, calibration_ID[3], calibration_ID[4], calibration_ID[5], calibration_ID[6], calibration_ID[7], calibration_ID[8], calibration_ID[9]};
            unsigned char frame3[8] = {34, calibration_ID[10], calibration_ID[11], calibration_ID[12], calibration_ID[13], calibration_ID[14], calibration_ID[15], calibration_ID[16]};

            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame1);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame2);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame3);
        }

        // ECU NAME
        if (canMessageRead == "2,9,10,")
        {

            unsigned char frame1[8] = {10, 14, 49, 10, 01, ecu_Name[0], ecu_Name[1], ecu_Name[2]};
            unsigned char frame2[8] = {21, ecu_Name[3], ecu_Name[4], ecu_Name[5], ecu_Name[6], ecu_Name[7], ecu_Name[8], ecu_Name[9]};
            unsigned char frame3[8] = {22, ecu_Name[10], ecu_Name[11], ecu_Name[12], ecu_Name[13], ecu_Name[14], ecu_Name[15], ecu_Name[16]};
            unsigned char frame4[8] = {23, ecu_Name[17], ecu_Name[18]};

            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame1);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame2);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame3);
            CAN0.sendMsgBuf(REPLY_ID, 0, 8, frame4);
        }

        //=================================================================
        // Return CAN-BUS Messages - RETURN PID VALUES - DTC
        //=================================================================

        // DTC
        if (canMessageRead == "1,3,0,")
        {
            if (MIL)
            {
                unsigned char DTC[] = {6, 67, 1, 0x04, 0x20, 0, 0, 0}; // P0217
                CAN0.sendMsgBuf(REPLY_ID, 0, 8, DTC);
                print_frame(REPLY_ID, 8, DTC, true);
            }
            else
            {
                unsigned char DTC[] = {6, 67, 0, 0, 0, 0, 0, 0}; // No Stored DTC
                CAN0.sendMsgBuf(REPLY_ID, 0, 8, DTC);
                print_frame(REPLY_ID, 8, DTC, true);
            }
        }

        // DTC Clear
        if (canMessageRead == "1,4,0,")
        {
            MIL = false;
        }

        canMessageRead = "";
    }
}
