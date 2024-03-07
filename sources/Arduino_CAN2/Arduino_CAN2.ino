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
bool MIL = false;
byte CEL_Codes = 0;

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
int obd_Std = 6;

// Fuel Type Coding https://en.wikipedia.org/wiki/OBD-II_PIDs#Fuel_Type_Coding
int fuel_Type = 1;

// Default PID values
unsigned int engine_Coolant_Temperature = 95;
int engine_Rpm = 950;
int vehicle_Speed = 0;
int timing_Advance = 10;
unsigned int intake_Temp = 25;
int maf_Air_Flow_Rate = 20;

typedef void (*pid_handler)(int pid, int service_mode, int add_bytes, byte *buf);

typedef struct
{
    int PID;
    pid_handler Func;
} service_01_pid;

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
    if (CAN_OK == CAN0.begin(MCP_STDEXT, CAN_500KBPS, MCP_16MHZ))
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
    Serial.print(id, HEX);
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

void create_response_frame_mode06(byte *out, int service_mode, int tid, int limit_type, byte A, byte B, byte C, byte D)
{
    out[0] = 7;
    out[1] = service_mode + 0x40;
    out[2] = tid;
    out[3] = limit_type;
    out[4] = A;
    out[5] = B;
    out[6] = C;
    out[7] = D;
}

void create_response_frame(byte *out, int service_mode, int pid, size_t len, byte *bytes)
{
    for (size_t i = 0; i < 8; i++)
        out[i] = 0;

    int offset = 0;
    out[offset++] = len; // Length
    out[offset++] = service_mode + 0x40;

    if (pid >= 0)
        out[offset++] = pid;

    out[0] = out[0] + offset;

    for (size_t i = 0; i < len; i++)
        out[i + offset] = bytes[i];
}

void create_response_frame(byte *out, int service_mode, int pid)
{
    create_response_frame(out, service_mode, pid, 0, NULL);
}

void create_response_frame(byte *out, int service_mode, int pid, uint32_t u32)
{
    byte *bytes = (byte *)&u32;
    byte obd_bytes[] = {bytes[3], bytes[2], bytes[1], bytes[0]};
    create_response_frame(out, service_mode, pid, 4, obd_bytes);
}

void send_frame(uint32_t id, size_t len, byte *buf)
{
    print_frame(id, len, buf, true);
    CAN0.sendMsgBuf(id, len, buf);
}

// SERVICE 01 PID List

void service_01_pid_1F(int pid, int service_mode, int add_bytes, byte *buf) // Run time since engine start
{
    byte dat[2] = {0x00, 0x3C};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_0C(int pid, int service_mode, int add_bytes, byte *buf) // RPM
{
    byte dat[2] = {0x25, 0x25};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_0D(int pid, int service_mode, int add_bytes, byte *buf) // Vehicle speed
{
    byte dat[1] = {100};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_1C(int pid, int service_mode, int add_bytes, byte *buf) // OBD standards this vehicle conforms to
{
    byte dat[1] = {obd_Std};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_51(int pid, int service_mode, int add_bytes, byte *buf) // Fuel type
{
    byte dat[1] = {fuel_Type};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_05(int pid, int service_mode, int add_bytes, byte *buf) // ECT
{
    byte dat[1] = {(byte)(95 + 40)};
    create_response_frame(tmp8, service_mode, pid, sizeof(dat) / sizeof(*dat), dat);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_01_41(int pid, int service_mode, int add_bytes, byte *buf)
{
    // 0x01 - Monitor status since DTCs cleared
    // 0x41 - Monitor status this drive cycle

    // Note that for bits indicating test availability a bit set to 1 indicates available
    // whilst for bits indicating test completeness a bit set to 0 indicates complete.

    byte A = B7(MIL ? 1 : 0) | (CEL_Codes & 0b1111111);
    byte B = B6(0) | B5(0) | B4(0) | B3(0) | B2(1) | B1(1) | B0(1);
    byte C = B7(1) | B6(1) | B5(1) | B4(0) | B3(0) | B2(0) | B1(0) | B0(1); // Availability
    byte D = B7(0) | B6(0) | B5(0) | B4(0) | B3(0) | B2(0) | B1(0) | B0(0); // Completeness

    byte B2 = B6(0) | B5(0) | B4(0) | B3(0) | B2(1) | B1(0) | B0(1);
    byte C2 = B7(1) | B6(1) | B5(1) | B4(0) | B3(0) | B2(0) | B1(0) | B0(1); // Availability
    byte D2 = B7(0) | B6(0) | B5(1) | B4(0) | B3(0) | B2(0) | B1(0) | B0(1); // Completeness

    Serial.println("######### Emissions test " + String(pid));
    byte ABCD[4];

    if (pid == 0x1)
    {
        ABCD[0] = A;
        ABCD[1] = B;
        ABCD[2] = C;
        ABCD[3] = D;
    }
    else
    {
        ABCD[0] = 0;
        ABCD[1] = B2;
        ABCD[2] = C2;
        ABCD[3] = D2;
    }

    create_response_frame(tmp8, service_mode, pid, 4, ABCD);
    send_frame(REPLY_ID, 8, tmp8);
}

void service_01_pid_00_20_40_60_80_A0(int pid, int service_mode, int add_bytes, byte *buf)
{
    // Show PIDs supported
    uint32_t supported = 0;
    size_t incl_from = pid + 0x01;
    size_t incl_to = incl_from + 0x1F;

    for (size_t i = 0; i < get_service_01_count(); i++)
    {
        uint32_t f_pid = get_service_01_pid_pid(i);

        if (f_pid >= incl_from && f_pid <= incl_to)
            supported = supported | ((uint32_t)1 << (32 - (f_pid - pid)));
    }

    create_response_frame(tmp8, service_mode, pid, supported);
    send_frame(REPLY_ID, 8, tmp8);
}

service_01_pid service_01_PIDs[] = {{0x00, service_01_pid_00_20_40_60_80_A0},
                                    {0x20, service_01_pid_00_20_40_60_80_A0},
                                    {0x40, service_01_pid_00_20_40_60_80_A0},
                                    {0x60, service_01_pid_00_20_40_60_80_A0},
                                    {0x80, service_01_pid_00_20_40_60_80_A0},
                                    {0xA0, service_01_pid_00_20_40_60_80_A0},

                                    {0x05, service_01_pid_05},
                                    {0x1C, service_01_pid_1C},
                                    {0x1F, service_01_pid_1F},
                                    {0x0D, service_01_pid_0D},
                                    {0x51, service_01_pid_51},
                                    {0x0C, service_01_pid_0C},
                                    {0x01, service_01_pid_01_41},
                                    {0x41, service_01_pid_01_41}};

size_t get_service_01_count()
{
    return (sizeof(service_01_PIDs) / sizeof(*service_01_PIDs));
}

int get_service_01_pid_pid(int i)
{
    return service_01_PIDs[i].PID;
}

void handle_service_01(int add_bytes, int pid, byte *buf)
{
    const int service_mode = 0x1;

    for (size_t i = 0; i < get_service_01_count(); i++)
    {
        if (service_01_PIDs[i].PID == pid)
        {
            service_01_PIDs[i].Func(pid, service_mode, add_bytes, buf);
            return;
        }
    }
}

void handle_service_06(int add_bytes, int pid, byte *buf)
{
    Serial.println("############# SERVICE 0x06 #############");

    const int service_mode = 0x6;

    /*if (pid == 0x01)
    {
        create_response_frame_mode06(tmp8, service_mode, pid, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF);
        send_frame(REPLY_ID, 8, tmp8);
        delay(50);
    }
    else*/
    if (pid >= 0x1 && pid <= 0x20)
    {
        // byte arr[4] = {0xFF, 0xAB, 0xCD, 0xEF};
        // create_response_frame(tmp8, service_mode, pid, 4, arr);

        // create_response_frame_mode06(tmp8, service_mode, pid, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF);
        // send_frame(REPLY_ID, 8, tmp8);

        // create_response_frame_mode06(tmp8, service_mode, pid, 0xFF, 0xFF, 0x00, 0x00, 0x00);
        // send_frame(REPLY_ID, 8, tmp8);

        byte i = 0x0C;
        create_response_frame_mode06(tmp8, service_mode, pid, B7(1) | ((byte)i), 0x00, 0x10, 0x00, 0x00);
        send_frame(REPLY_ID, 8, tmp8);
        delay(50);

        create_response_frame_mode06(tmp8, service_mode, pid, B7(0) | ((byte)i), 0x00, 0x32, 0x00, 0x20);
        send_frame(REPLY_ID, 8, tmp8);
        delay(50);

        /*create_response_frame_mode06(tmp8, service_mode, pid, 0x16, 0x00, 0x32, 0x00, 0x20);
        send_frame(REPLY_ID, 8, tmp8);*/
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
    else if (add_bytes == 1 && (buf[0] == 0x03 || buf[0] == 0x07)) // DTCs
    {
        int service_mode = buf[0];
        int pid = buf[1];

        Serial.println("################ SERVICE " + String(service_mode));

        if (MIL)
        {
            byte dat[4] = {0};
            int code_count = 0;

            if (service_mode == 0x03)
            {
                dat[0] = 0x04;
                dat[1] = 0x20;
                dat[2] = 0x04;
                dat[3] = 0x30;
                code_count = 2;

                create_response_frame(tmp8, service_mode, code_count, sizeof(dat) / sizeof(*dat), dat);
                send_frame(REPLY_ID, 8, tmp8);
            }
            else
            {
                dat[0] = 0x03;
                dat[1] = 0x40;
                code_count = 1;

                create_response_frame(tmp8, service_mode, code_count, sizeof(dat) / sizeof(*dat), dat);
                send_frame(REPLY_ID, 8, tmp8);
            }

            // create_response_frame(tmp8, service_mode, code_count, sizeof(dat) / sizeof(*dat), dat);
            // send_frame(REPLY_ID, 8, tmp8);
        }
        else
        {
            create_response_frame(tmp8, service_mode, 0);
            send_frame(REPLY_ID, 8, tmp8);
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
}
