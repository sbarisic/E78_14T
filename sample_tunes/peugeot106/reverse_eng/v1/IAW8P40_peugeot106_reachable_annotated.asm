; Marelli IAW 8P.40 Peugeot 106 1.3 Rallye
; Conservative recursive Motorola 68HC11 disassembly
; Git commit: 1270f0cc444eb16ce1987d60eba304a3e06b4af4
; Stock SHA-256: 09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681
; Decoded instructions: 13734
; Reachable/evidence-seeded instruction bytes: 33663
; Contiguous code-byte ranges: 192
;
; Method: start at all ROM vectors plus evidence-backed routine entry points;
; follow direct JSR/BSR/JMP and conditional/unconditional branches;
; stop at returns, interrupt returns, waits/stops, and excluded calibration/data ranges.
; Dense sequential I/O routines at 0x4F10-0x5510 are seeded at their RTS-delimited starts.
; This is conservative: indirect-dispatch-only, dead, or not-yet-seeded code may still be absent.
; It deliberately does not linear-disassemble calibration bytes as instructions.

        .org $4017

; [CONFIRMED] Read ADC result group and seed RAM input channels.
adc_sample_group_a:
4017:  CE 10 00          ldx      #4096 ; xrefs $B8BB:call

loc_401A:
401A:  1F 30 80 FC       brclr    48, x; #-128; $401a ; $401A=loc_401A | xrefs $401A:branch
401E:  B6 10 31          ldaa     $1031 ; $1031=ADR1
4021:  B7 20 08          staa     $2008 ; $2008=adc_raw_input_2008
4024:  B6 10 33          ldaa     $1033 ; $1033=ADR3
4027:  B7 20 0D          staa     $200d ; $200D=adc_raw_input_200d
402A:  BD 41 55          jsr      $4155 ; $4155=adc_filter_helper_4155
402D:  B6 10 34          ldaa     $1034 ; $1034=ADR4
4030:  B7 20 0A          staa     $200a ; $200A=adc_raw_input_200a
4033:  39                rts      

; [CONFIRMED] Read alternate ADC result group and seed RAM input channels.
adc_sample_group_b:
4034:  CE 10 00          ldx      #4096 ; xrefs $B8D3:call

loc_4037:
4037:  1F 30 80 FC       brclr    48, x; #-128; $4037 ; $4037=loc_4037 | xrefs $4037:branch
403B:  B6 10 32          ldaa     $1032 ; $1032=ADR2
403E:  B7 20 0C          staa     $200c ; $200C=adc_raw_input_200c
4041:  B6 10 33          ldaa     $1033 ; $1033=ADR3
4044:  B7 20 07          staa     $2007 ; $2007=adc_processed_input_2007
4047:  B7 21 97          staa     $2197
404A:  BD 5E 82          jsr      $5e82 ; $5E82=adc_conversion_helper_5e82
404D:  B7 20 13          staa     $2013 ; $2013=processed_sensor_2013
4050:  96 11             ldaa     $11
4052:  C6 7F             ldab     #127
4054:  FD 20 24          std      $2024
4057:  FD 20 26          std      $2026
405A:  B6 10 34          ldaa     $1034 ; $1034=ADR4
405D:  B7 20 0E          staa     $200e ; $200E=adc_raw_input_200e
4060:  5F                clrb     
4061:  FD 20 0F          std      $200f
4064:  BD 41 B2          jsr      $41b2 ; $41B2=sub_41B2
4067:  BD 5D 8D          jsr      $5d8d ; $5D8D=sub_5D8D
406A:  CC 03 F5          ldd      #1013
406D:  FD 20 14          std      $2014
4070:  FD 20 22          std      $2022
4073:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
4075:  FD 20 20          std      $2020
4078:  39                rts      

sub_4079:
4079:  CC 00 00          ldd      #0 ; xrefs $B8F8:call
407C:  FD 21 1C          std      $211c
407F:  FD 21 1E          std      $211e
4082:  97 A1             staa     $a1
4084:  97 A2             staa     $a2 ; $00A2=spark_mode_flags
4086:  FD 20 03          std      $2003
4089:  DD D4             std      $d4
408B:  FD 21 2D          std      $212d
408E:  FD 21 2F          std      $212f
4091:  97 D3             staa     $d3
4093:  B7 21 2C          staa     $212c
4096:  97 D1             staa     $d1
4098:  B7 21 2B          staa     $212b
409B:  39                rts      

sub_409C:
409C:  DC CE             ldd      $ce ; $00CE=load_aircharge_word | xrefs $B8E3:call
409E:  FD 21 11          std      $2111
40A1:  B7 20 11          staa     $2011
40A4:  B7 21 31          staa     $2131
40A7:  39                rts      

sub_40A8:
40A8:  CE 21 1A          ldx      #8474 ; xrefs $B8D6:call
40AB:  F6 26 05          ldab     $2605
40AE:  E7 00             stab     0, x
40B0:  B6 20 0A          ldaa     $200a ; $200A=adc_raw_input_200a
40B3:  F6 26 04          ldab     $2604
40B6:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F
40B9:  B7 20 0B          staa     $200b
40BC:  BD 5D 08          jsr      $5d08 ; $5D08=sub_5D08
40BF:  B6 21 21          ldaa     $2121
40C2:  5F                clrb     
40C3:  FD 21 24          std      $2124
40C6:  CE 21 1A          ldx      #8474
40C9:  F6 26 07          ldab     $2607
40CC:  E7 00             stab     0, x
40CE:  B6 20 08          ldaa     $2008 ; $2008=adc_raw_input_2008
40D1:  F6 26 06          ldab     $2606
40D4:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F
40D7:  B7 20 09          staa     $2009
40DA:  BD 5B EC          jsr      $5bec ; $5BEC=sub_5BEC
40DD:  B6 21 20          ldaa     $2120
40E0:  5F                clrb     
40E1:  FD 21 22          std      $2122
40E4:  39                rts      

sub_40E5:
40E5:  86 14             ldaa     #20 ; xrefs $9660:call
40E7:  0F                sei      
40E8:  B7 10 30          staa     $1030 ; $1030=ADCTL
40EB:  CE 10 00          ldx      #4096
40EE:  B6 20 2A          ldaa     $202a
40F1:  81 7D             cmpa     #125
40F3:  25 05             bcs      $40fa ; $40FA=loc_40FA
40F5:  CC 00 00          ldd      #0
40F8:  20 0C             bra      $4106 ; $4106=loc_4106

loc_40FA:
40FA:  FC 20 28          ldd      $2028 ; xrefs $40F3:branch
40FD:  1A B3 87 9C       cpd      $879c
4101:  25 0C             bcs      $410f ; $410F=loc_410F
4103:  B3 87 9C          subd     $879c

loc_4106:
4106:  FD 20 28          std      $2028 ; xrefs $40F8:branch
4109:  7F 20 2A          clr      $202a
410C:  1C 40 01          bset     64, x; #1

loc_410F:
410F:  1F 30 80 FC       brclr    48, x; #-128; $410f ; $410F=loc_410F | xrefs $4101:branch, $410F:branch
4113:  B6 10 31          ldaa     $1031 ; $1031=ADR1
4116:  B7 20 08          staa     $2008 ; $2008=adc_raw_input_2008
4119:  B6 10 33          ldaa     $1033 ; $1033=ADR3
411C:  B7 20 0D          staa     $200d ; $200D=adc_raw_input_200d
411F:  B6 10 34          ldaa     $1034 ; $1034=ADR4
4122:  0E                cli      
4123:  B7 20 0A          staa     $200a ; $200A=adc_raw_input_200a
4126:  96 C9             ldaa     $c9
4128:  B7 20 13          staa     $2013 ; $2013=processed_sensor_2013
412B:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
412D:  FD 20 20          std      $2020
4130:  86 10             ldaa     #16
4132:  0F                sei      
4133:  B7 10 30          staa     $1030 ; $1030=ADCTL
4136:  BD 41 55          jsr      $4155 ; $4155=adc_filter_helper_4155
4139:  CE 10 00          ldx      #4096

loc_413C:
413C:  1F 30 80 FC       brclr    48, x; #-128; $413c ; $413C=loc_413C | xrefs $413C:branch
4140:  B6 10 32          ldaa     $1032 ; $1032=ADR2
4143:  B7 20 0C          staa     $200c ; $200C=adc_raw_input_200c
4146:  B6 10 33          ldaa     $1033 ; $1033=ADR3
4149:  B7 20 07          staa     $2007 ; $2007=adc_processed_input_2007
414C:  B6 10 34          ldaa     $1034 ; $1034=ADR4
414F:  0E                cli      
4150:  B7 20 0E          staa     $200e ; $200E=adc_raw_input_200e
4153:  39                rts      

; ---- unreached/data gap $4154-$4154 ----

        .org $4155

; [STRONG] ADC preprocessing helper used by the 0x200D path.
adc_filter_helper_4155:
4155:  CE 21 13          ldx      #8467 ; xrefs $402A:call, $4136:call
4158:  F6 26 01          ldab     $2601
415B:  E7 00             stab     0, x
415D:  B6 20 0D          ldaa     $200d ; $200D=adc_raw_input_200d
4160:  F6 26 00          ldab     $2600
4163:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F
4166:  B7 20 B6          staa     $20b6
4169:  39                rts      

; ---- unreached/data gap $416A-$416A ----

        .org $416B

sub_416B:
416B:  CE 21 13          ldx      #8467 ; xrefs $966F:call
416E:  FC 20 0F          ldd      $200f
4171:  ED 00             std      0, x
4173:  B6 20 0E          ldaa     $200e ; $200E=adc_raw_input_200e
4176:  13 A3 10 05       brclr    $a3, #16, $417f ; $417F=loc_417F
417A:  F6 89 86          ldab     $8986
417D:  20 03             bra      $4182 ; $4182=loc_4182

loc_417F:
417F:  F6 89 85          ldab     $8985 ; xrefs $4176:branch

loc_4182:
4182:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6 | xrefs $417D:branch
4185:  FD 20 0F          std      $200f
4188:  BD 41 B2          jsr      $41b2 ; $41B2=sub_41B2
418B:  BD 5D 8D          jsr      $5d8d ; $5D8D=sub_5D8D
418E:  B6 20 0E          ldaa     $200e ; $200E=adc_raw_input_200e
4191:  B0 20 0F          suba     $200f
4194:  24 01             bcc      $4197 ; $4197=loc_4197
4196:  40                nega     

loc_4197:
4197:  BB 21 31          adda     $2131 ; xrefs $4194:branch
419A:  24 02             bcc      $419e ; $419E=loc_419E
419C:  86 FF             ldaa     #-1

loc_419E:
419E:  B7 21 31          staa     $2131 ; xrefs $419A:branch

; [CONFIRMED] Build normalized load/MAP-like axis in RAM 0x2034.
build_load_axis_2034:
41A1:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
41A3:  05                asld     
41A4:  1A 83 07 FF       cpd      #2047
41A8:  23 03             bls      $41ad ; $41AD=loc_41AD
41AA:  CC 07 FF          ldd      #2047

loc_41AD:
41AD:  FD 20 34          std      $2034 ; $2034=normalized_load_axis | xrefs $41A8:branch
41B0:  39                rts      

; ---- unreached/data gap $41B1-$41B1 ----

        .org $41B2

sub_41B2:
41B2:  04                lsrd      ; xrefs $4064:call, $4188:call
41B3:  04                lsrd     
41B4:  04                lsrd     
41B5:  04                lsrd     
41B6:  04                lsrd     
41B7:  04                lsrd     
41B8:  37                pshb     
41B9:  F6 92 9B          ldab     $929b
41BC:  3D                mul      
41BD:  F3 92 9C          addd     $929c
41C0:  8F                xgdx     
41C1:  32                pula     
41C2:  F6 92 9B          ldab     $929b
41C5:  3D                mul      
41C6:  89 00             adca     #0
41C8:  16                tab      
41C9:  3A                abx      
41CA:  3C                pshx     
41CB:  32                pula     
41CC:  33                pulb     
41CD:  04                lsrd     
41CE:  04                lsrd     
41CF:  4D                tsta     
41D0:  27 02             beq      $41d4 ; $41D4=loc_41D4
41D2:  C6 FF             ldab     #-1

loc_41D4:
41D4:  39                rts       ; xrefs $41D0:branch

; ---- unreached/data gap $41D5-$41D5 ----

        .org $41D6

; [CONFIRMED] Build normalized transient/helper axis in RAM 0x2042.
build_transient_axis_2042:
41D6:  D6 C9             ldab     $c9 ; xrefs $9669:call
41D8:  D0 11             subb     $11
41DA:  24 01             bcc      $41dd ; $41DD=loc_41DD
41DC:  5F                clrb     

loc_41DD:
41DD:  F7 20 17          stab     $2017 ; xrefs $41DA:branch
41E0:  CE 92 91          ldx      #-28015
41E3:  B6 20 17          ldaa     $2017
41E6:  F6 92 9A          ldab     $929a
41E9:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
41EC:  FD 20 42          std      $2042 ; $2042=transient_helper_axis
41EF:  CE 21 13          ldx      #8467
41F2:  FC 20 24          ldd      $2024
41F5:  ED 00             std      0, x
41F7:  96 D3             ldaa     $d3
41F9:  B1 89 92          cmpa     $8992
41FC:  25 14             bcs      $4212 ; $4212=loc_4212
41FE:  96 C9             ldaa     $c9
4200:  F6 89 84          ldab     $8984
4203:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
4206:  FD 20 24          std      $2024
4209:  C1 80             cmpb     #-128
420B:  25 02             bcs      $420f ; $420F=loc_420F
420D:  4C                inca     
420E:  5F                clrb     

loc_420F:
420F:  FD 20 26          std      $2026 ; xrefs $420B:branch

loc_4212:
4212:  39                rts       ; xrefs $41FC:branch

; ---- unreached/data gap $4213-$4213 ----

        .org $4214

sub_4214:
4214:  B6 21 2A          ldaa     $212a ; xrefs $D3E5:call
4217:  B1 91 02          cmpa     $9102
421A:  23 74             bls      $4290 ; $4290=loc_4290
421C:  13 1E 90 02       brclr    $1e, #-112, $4222 ; $4222=loc_4222
4220:  20 6E             bra      $4290 ; $4290=loc_4290

loc_4222:
4222:  B6 20 26          ldaa     $2026 ; xrefs $421C:branch
4225:  91 10             cmpa     $10
4227:  25 0A             bcs      $4233 ; $4233=loc_4233
4229:  97 10             staa     $10
422B:  CC 00 00          ldd      #0
422E:  FD 21 1C          std      $211c
4231:  20 26             bra      $4259 ; $4259=loc_4259

loc_4233:
4233:  96 C9             ldaa     $c9 ; xrefs $4227:branch
4235:  B1 89 90          cmpa     $8990
4238:  23 1F             bls      $4259 ; $4259=loc_4259
423A:  91 10             cmpa     $10
423C:  24 1B             bcc      $4259 ; $4259=loc_4259
423E:  FC 21 1C          ldd      $211c
4241:  1A B3 89 93       cpd      $8993
4245:  25 0B             bcs      $4252 ; $4252=loc_4252
4247:  7A 00 10          dec      >$0010
424A:  CC 00 00          ldd      #0
424D:  FD 21 1C          std      $211c
4250:  20 07             bra      $4259 ; $4259=loc_4259

loc_4252:
4252:  FE 21 1C          ldx      $211c ; xrefs $4245:branch
4255:  08                inx      
4256:  FF 21 1C          stx      $211c

loc_4259:
4259:  B6 20 26          ldaa     $2026 ; xrefs $4231:branch, $4238:branch, $423C:branch, $4250:branch
425C:  91 11             cmpa     $11
425E:  22 0A             bhi      $426a ; $426A=loc_426A
4260:  97 11             staa     $11
4262:  CC 00 00          ldd      #0
4265:  FD 21 1E          std      $211e
4268:  20 26             bra      $4290 ; $4290=loc_4290

loc_426A:
426A:  96 C9             ldaa     $c9 ; xrefs $425E:branch
426C:  B1 89 91          cmpa     $8991
426F:  24 1F             bcc      $4290 ; $4290=loc_4290
4271:  91 11             cmpa     $11
4273:  23 1B             bls      $4290 ; $4290=loc_4290
4275:  FC 21 1E          ldd      $211e
4278:  1A B3 89 93       cpd      $8993
427C:  25 0B             bcs      $4289 ; $4289=loc_4289
427E:  7C 00 11          inc      >$0011
4281:  CC 00 00          ldd      #0
4284:  FD 21 1E          std      $211e
4287:  20 07             bra      $4290 ; $4290=loc_4290

loc_4289:
4289:  FE 21 1E          ldx      $211e ; xrefs $427C:branch
428C:  08                inx      
428D:  FF 21 1E          stx      $211e

loc_4290:
4290:  39                rts       ; xrefs $421A:branch, $4220:branch, $4268:branch, $426F:branch, $4273:branch, $4287:branch

; ---- unreached/data gap $4291-$4291 ----

        .org $4292

sub_4292:
4292:  FC 21 2D          ldd      $212d ; xrefs $B447:call
4295:  FD 21 2F          std      $212f
4298:  DC D4             ldd      $d4
429A:  FD 21 2D          std      $212d
429D:  96 D1             ldaa     $d1
429F:  B7 21 2B          staa     $212b
42A2:  96 D3             ldaa     $d3
42A4:  B7 21 2C          staa     $212c
42A7:  CC E4 E2          ldd      #-6942
42AA:  DE BA             ldx      $ba ; $00BA=engine_period_delta
42AC:  02                idiv     
42AD:  3C                pshx     
42AE:  DE BA             ldx      $ba ; $00BA=engine_period_delta
42B0:  03                fdiv     
42B1:  8F                xgdx     
42B2:  16                tab      
42B3:  32                pula     
42B4:  32                pula     
42B5:  DD D4             std      $d4
42B7:  04                lsrd     
42B8:  04                lsrd     
42B9:  04                lsrd     
42BA:  37                pshb     
42BB:  36                psha     
42BC:  04                lsrd     
42BD:  04                lsrd     
42BE:  4D                tsta     
42BF:  27 02             beq      $42c3 ; $42C3=loc_42C3
42C1:  C6 FF             ldab     #-1

loc_42C3:
42C3:  D7 D3             stab     $d3 ; xrefs $42BF:branch
42C5:  32                pula     
42C6:  33                pulb     
42C7:  4D                tsta     
42C8:  27 02             beq      $42cc ; $42CC=loc_42CC
42CA:  C6 FF             ldab     #-1

loc_42CC:
42CC:  D7 D1             stab     $d1 ; xrefs $42C8:branch
42CE:  39                rts      

; ---- unreached/data gap $42CF-$42CF ----

        .org $42D0

sub_42D0:
42D0:  13 9C 02 29       brclr    $9c, #2, $42fd ; $009C=scheduler_status_flags, $42FD=loc_42FD | xrefs $D3D9:call
42D4:  FC 21 11          ldd      $2111
42D7:  12 A9 01 06       brset    $a9, #1, $42e1 ; $00A9=operating_mode_flags, $42E1=loc_42E1
42DB:  12 9C 04 15       brset    $9c, #4, $42f4 ; $009C=scheduler_status_flags, $42F4=loc_42F4
42DF:  20 1C             bra      $42fd ; $42FD=loc_42FD

loc_42E1:
42E1:  DC CE             ldd      $ce ; $00CE=load_aircharge_word | xrefs $42D7:branch
42E3:  1A B3 20 14       cpd      $2014
42E7:  22 0B             bhi      $42f4 ; $42F4=loc_42F4
42E9:  13 A9 80 10       brclr    $a9, #-128, $42fd ; $00A9=operating_mode_flags, $42FD=loc_42FD
42ED:  DE BA             ldx      $ba ; $00BA=engine_period_delta
42EF:  BC 89 95          cpx      $8995
42F2:  25 09             bcs      $42fd ; $42FD=loc_42FD

loc_42F4:
42F4:  FD 20 22          std      $2022 ; xrefs $42DB:branch, $42E7:branch
42F7:  B6 20 0E          ldaa     $200e ; $200E=adc_raw_input_200e
42FA:  B7 20 12          staa     $2012

loc_42FD:
42FD:  13 1E 90 02       brclr    $1e, #-112, $4303 ; $4303=loc_4303 | xrefs $42D0:branch, $42DF:branch, $42E9:branch, $42F2:branch
4301:  20 04             bra      $4307 ; $4307=loc_4307

loc_4303:
4303:  13 1B 90 0B       brclr    $1b, #-112, $4312 ; $4312=loc_4312 | xrefs $42FD:branch

loc_4307:
4307:  CC 03 F5          ldd      #1013 ; xrefs $4301:branch
430A:  FD 21 11          std      $2111
430D:  7F 20 12          clr      $2012
4310:  20 03             bra      $4315 ; $4315=loc_4315

loc_4312:
4312:  FC 20 22          ldd      $2022 ; xrefs $4303:branch

loc_4315:
4315:  FD 20 14          std      $2014 ; xrefs $4310:branch
4318:  39                rts      

; ---- unreached/data gap $4319-$4319 ----

        .org $431A

; [STRONG] Preprocess temperature channel used by the CTS-like axis path.
preprocess_cts_path:
431A:  CE 21 1A          ldx      #8474 ; xrefs $72B9:call, $D5BC:call, $D6D6:call
431D:  F6 26 07          ldab     $2607
4320:  E7 00             stab     0, x
4322:  B6 20 08          ldaa     $2008 ; $2008=adc_raw_input_2008
4325:  F6 26 06          ldab     $2606
4328:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F
432B:  B7 20 09          staa     $2009
432E:  BD 5B EC          jsr      $5bec ; $5BEC=sub_5BEC
4331:  CE 21 22          ldx      #8482
4334:  B6 21 20          ldaa     $2120
4337:  F6 89 88          ldab     $8988
433A:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
433D:  FD 21 22          std      $2122

; [CONFIRMED] Use calibration 0x92CF through the axis helper to produce 0x203C/0x203E.
convert_cts_axis:
4340:  CE 92 CF          ldx      #-27953
4343:  F6 92 D8          ldab     $92d8
4346:  B6 21 22          ldaa     $2122
4349:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
434C:  FD 21 26          std      $2126
434F:  18 CE 40 0E       ldy      #16398
4353:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
4356:  97 CA             staa     $ca
4358:  5F                clrb     
4359:  B6 92 D8          ldaa     $92d8
435C:  80 01             suba     #1
435E:  B3 21 26          subd     $2126
4361:  FD 20 3C          std      $203c ; $203C=cts_axis_index
4364:  05                asld     
4365:  FD 20 3E          std      $203e ; $203E=cts_axis_fraction_or_value
4368:  39                rts      

; ---- unreached/data gap $4369-$4369 ----

        .org $436A

; [STRONG] Preprocess temperature channel used by the IAT-like axis path.
preprocess_iat_path:
436A:  CE 21 1A          ldx      #8474 ; xrefs $D5B9:call, $D6D3:call
436D:  F6 26 05          ldab     $2605
4370:  E7 00             stab     0, x
4372:  B6 20 0A          ldaa     $200a ; $200A=adc_raw_input_200a
4375:  F6 26 04          ldab     $2604
4378:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F
437B:  B7 20 0B          staa     $200b
437E:  BD 5D 08          jsr      $5d08 ; $5D08=sub_5D08
4381:  CE 21 24          ldx      #8484
4384:  B6 21 21          ldaa     $2121
4387:  F6 89 87          ldab     $8987
438A:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
438D:  FD 21 24          std      $2124

; [CONFIRMED] Use calibration 0x92D9 through the axis helper to produce 0x2038/0x203A.
convert_iat_axis:
4390:  CE 92 D9          ldx      #-27943
4393:  F6 92 E2          ldab     $92e2
4396:  B6 21 24          ldaa     $2124
4399:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
439C:  FD 21 28          std      $2128
439F:  18 CE 40 0E       ldy      #16398
43A3:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
43A6:  97 CB             staa     $cb
43A8:  5F                clrb     
43A9:  B6 92 E2          ldaa     $92e2
43AC:  80 01             suba     #1
43AE:  B3 21 28          subd     $2128
43B1:  FD 20 38          std      $2038 ; $2038=iat_axis_index
43B4:  05                asld     
43B5:  FD 20 3A          std      $203a
43B8:  39                rts      

; ---- unreached/data gap $43B9-$43B9 ----

        .org $43BA

sub_43BA:
43BA:  BD 43 DC          jsr      $43dc ; $43DC=sub_43DC | xrefs $D5BF:call
43BD:  81 00             cmpa     #0
43BF:  27 16             beq      $43d7 ; $43D7=loc_43D7
43C1:  B7 21 2A          staa     $212a
43C4:  CE 21 1A          ldx      #8474
43C7:  DC CC             ldd      $cc
43C9:  FD 21 1A          std      $211a
43CC:  F6 89 89          ldab     $8989
43CF:  B6 21 2A          ldaa     $212a
43D2:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
43D5:  DD CC             std      $cc

loc_43D7:
43D7:  BD 43 F3          jsr      $43f3 ; $43F3=sub_43F3 | xrefs $43BF:branch
43DA:  39                rts      

; ---- unreached/data gap $43DB-$43DB ----

        .org $43DC

sub_43DC:
43DC:  BD 5B 1B          jsr      $5b1b ; $5B1B=sub_5B1B | xrefs $43BA:call, $D6DF:call
43DF:  81 00             cmpa     #0
43E1:  27 0E             beq      $43f1 ; $43F1=loc_43F1
43E3:  CE 21 1A          ldx      #8474
43E6:  F6 26 03          ldab     $2603
43E9:  E7 00             stab     0, x
43EB:  F6 26 02          ldab     $2602
43EE:  BD B4 2F          jsr      $b42f ; $B42F=sub_B42F

loc_43F1:
43F1:  39                rts       ; xrefs $43E1:branch

; ---- unreached/data gap $43F2-$43F2 ----

        .org $43F3

sub_43F3:
43F3:  DC CC             ldd      $cc ; xrefs $43D7:call, $D6E5:call
43F5:  83 80 00          subd     #-32768
43F8:  24 02             bcc      $43fc ; $43FC=loc_43FC
43FA:  4F                clra     
43FB:  5F                clrb     

loc_43FC:
43FC:  04                lsrd      ; xrefs $43F8:branch
43FD:  04                lsrd     
43FE:  04                lsrd     
43FF:  04                lsrd     
4400:  FD 20 40          std      $2040 ; $2040=scheduler_axis_index
4403:  39                rts      

; ---- unreached/data gap $4404-$4404 ----

        .org $4405

sub_4405:
4405:  CE 10 00          ldx      #4096 ; xrefs $967B:call, $E6D5:call
4408:  1D 40 01          bclr     64, x; #1
440B:  39                rts      

; ---- unreached/data gap $440C-$440C ----

        .org $440D

sub_440D:
440D:  04                lsrd      ; xrefs $6F4B:call, $71C0:call
440E:  04                lsrd     
440F:  04                lsrd     
4410:  F3 20 28          addd     $2028
4413:  1A 83 7A 12       cpd      #31250
4417:  25 03             bcs      $441c ; $441C=loc_441C
4419:  CC 7A 12          ldd      #31250

loc_441C:
441C:  FD 20 28          std      $2028 ; xrefs $4417:branch
441F:  39                rts      

; ---- unreached/data gap $4420-$4420 ----

        .org $4421

sub_4421:
4421:  B6 8C 79          ldaa     $8c79 ; xrefs $B907:call
4424:  97 B6             staa     $b6
4426:  5F                clrb     
4427:  FD 21 32          std      $2132
442A:  4F                clra     
442B:  FD 21 34          std      $2134
442E:  97 B5             staa     $b5
4430:  B7 21 36          staa     $2136
4433:  B7 21 37          staa     $2137
4436:  B7 21 45          staa     $2145
4439:  B7 21 42          staa     $2142
443C:  FD 21 50          std      $2150
443F:  FD 21 52          std      $2152
4442:  B7 21 54          staa     $2154
4445:  FD 21 56          std      $2156
4448:  FD 21 58          std      $2158
444B:  B7 21 5A          staa     $215a
444E:  B7 21 4F          staa     $214f ; $214F=alternate_limiter_mode
4451:  4A                deca     
4452:  B7 21 5B          staa     $215b
4455:  B7 21 38          staa     $2138
4458:  86 02             ldaa     #2
445A:  B7 21 55          staa     $2155
445D:  7F 21 43          clr      $2143
4460:  39                rts      

sub_4461:
4461:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $D596:call
4464:  81 0C             cmpa     #12
4466:  26 06             bne      $446e ; $446E=loc_446E
4468:  BD 96 D3          jsr      $96d3 ; $96D3=sub_96D3
446B:  7E 45 36          jmp      $4536 ; $4536=loc_4536

loc_446E:
446E:  15 A0 20          bclr     $a0, #32 ; xrefs $4466:branch
4471:  12 A0 40 25       brset    $a0, #64, $449a ; $449A=loc_449A
4475:  DC BA             ldd      $ba ; $00BA=engine_period_delta
4477:  1A B3 8C 7A       cpd      $8c7a
447B:  25 11             bcs      $448e ; $448E=loc_448E
447D:  4F                clra     
447E:  F6 8C 79          ldab     $8c79
4481:  FD 21 47          std      $2147 ; $2147=spark_accumulator
4484:  86 40             ldaa     #64
4486:  97 B5             staa     $b5
4488:  15 A0 0C          bclr     $a0, #12
448B:  7E 45 06          jmp      $4506 ; $4506=loc_4506

loc_448E:
448E:  14 A0 40          bset     $a0, #64 ; xrefs $447B:branch
4491:  B6 8E 03          ldaa     $8e03
4494:  B7 21 42          staa     $2142
4497:  7E 44 DF          jmp      $44df ; $44DF=loc_44DF

loc_449A:
449A:  96 A3             ldaa     $a3 ; xrefs $4471:branch
449C:  81 40             cmpa     #64
449E:  27 3F             beq      $44df ; $44DF=loc_44DF
44A0:  91 B5             cmpa     $b5
44A2:  27 1B             beq      $44bf ; $44BF=loc_44BF
44A4:  97 B5             staa     $b5
44A6:  81 10             cmpa     #16
44A8:  26 12             bne      $44bc ; $44BC=loc_44BC
44AA:  15 A0 08          bclr     $a0, #8
44AD:  18 CE 8D D9       ldy      #-29223
44B1:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
44B4:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
44B7:  B7 20 00          staa     $2000
44BA:  20 2C             bra      $44e8 ; $44E8=loc_44E8

loc_44BC:
44BC:  15 A0 04          bclr     $a0, #4 ; xrefs $44A8:branch

loc_44BF:
44BF:  81 80             cmpa     #-128 ; xrefs $44A2:branch
44C1:  26 0F             bne      $44d2 ; $44D2=loc_44D2
44C3:  B6 21 42          ldaa     $2142
44C6:  27 05             beq      $44cd ; $44CD=loc_44CD
44C8:  7A 21 42          dec      $2142
44CB:  20 12             bra      $44df ; $44DF=loc_44DF

loc_44CD:
44CD:  14 A0 08          bset     $a0, #8 ; xrefs $44C6:branch
44D0:  20 0D             bra      $44df ; $44DF=loc_44DF

loc_44D2:
44D2:  13 B5 01 05       brclr    $b5, #1, $44db ; $44DB=loc_44DB | xrefs $44C1:branch
44D6:  BD 45 64          jsr      $4564 ; $4564=sub_4564
44D9:  20 34             bra      $450f ; $450F=loc_450F

loc_44DB:
44DB:  13 B5 80 05       brclr    $b5, #-128, $44e4 ; $44E4=loc_44E4 | xrefs $44D2:branch

loc_44DF:
44DF:  BD 45 38          jsr      $4538 ; $4538=sub_4538 | xrefs $4497:jump, $449E:branch, $44CB:branch, $44D0:branch
44E2:  20 22             bra      $4506 ; $4506=loc_4506

loc_44E4:
44E4:  13 B5 10 05       brclr    $b5, #16, $44ed ; $44ED=loc_44ED | xrefs $44DB:branch

loc_44E8:
44E8:  BD 45 56          jsr      $4556 ; $4556=sub_4556 | xrefs $44BA:branch
44EB:  20 19             bra      $4506 ; $4506=loc_4506

loc_44ED:
44ED:  13 B5 08 05       brclr    $b5, #8, $44f6 ; $44F6=loc_44F6 | xrefs $44E4:branch
44F1:  BD 45 B0          jsr      $45b0 ; $45B0=sub_45B0
44F4:  20 10             bra      $4506 ; $4506=loc_4506

loc_44F6:
44F6:  13 B5 04 05       brclr    $b5, #4, $44ff ; $44FF=loc_44FF | xrefs $44ED:branch
44FA:  BD 45 B8          jsr      $45b8 ; $45B8=sub_45B8
44FD:  20 07             bra      $4506 ; $4506=loc_4506

loc_44FF:
44FF:  13 B5 20 03       brclr    $b5, #32, $4506 ; $4506=loc_4506 | xrefs $44F6:branch
4503:  BD 45 CC          jsr      $45cc ; $45CC=sub_45CC

loc_4506:
4506:  CC 00 00          ldd      #0 ; xrefs $448B:jump, $44E2:branch, $44EB:branch, $44F4:branch, $44FD:branch, $44FF:branch
4509:  FD 21 4A          std      $214a
450C:  15 9E 01          bclr     $9e, #1

loc_450F:
450F:  12 9E 01 0E       brset    $9e, #1, $4521 ; $4521=loc_4521 | xrefs $44D9:branch
4513:  B6 21 46          ldaa     $2146
4516:  27 09             beq      $4521 ; $4521=loc_4521
4518:  B0 8E 27          suba     $8e27
451B:  24 01             bcc      $451e ; $451E=loc_451E
451D:  4F                clra     

loc_451E:
451E:  B7 21 46          staa     $2146 ; xrefs $451B:branch

loc_4521:
4521:  BD 45 D4          jsr      $45d4 ; $45D4=sub_45D4 | xrefs $450F:branch, $4516:branch
4524:  BD 45 F3          jsr      $45f3 ; $45F3=sub_45F3
4527:  BD 46 0A          jsr      $460a ; $460A=sub_460A
452A:  BD 46 42          jsr      $4642 ; $4642=sub_4642
452D:  BD 46 98          jsr      $4698 ; $4698=sub_4698
4530:  BD 46 BE          jsr      $46be ; $46BE=sub_46BE
4533:  BD 47 7B          jsr      $477b ; $477B=sub_477B

loc_4536:
4536:  39                rts       ; xrefs $446B:jump

; ---- unreached/data gap $4537-$4537 ----

        .org $4538

sub_4538:
4538:  13 A9 40 08       brclr    $a9, #64, $4544 ; $00A9=operating_mode_flags, $4544=loc_4544 | xrefs $44DF:call
453C:  14 A0 20          bset     $a0, #32
453F:  BD 49 80          jsr      $4980 ; $4980=sub_4980
4542:  20 10             bra      $4554 ; $4554=loc_4554

loc_4544:
4544:  BD 48 D8          jsr      $48d8 ; $48D8=sub_48D8 | xrefs $4538:branch
4547:  4F                clra     
4548:  F6 8D C0          ldab     $8dc0
454B:  2A 01             bpl      $454e ; $454E=loc_454E
454D:  43                coma     

loc_454E:
454E:  F3 21 47          addd     $2147 ; $2147=spark_accumulator | xrefs $454B:branch
4551:  FD 21 47          std      $2147 ; $2147=spark_accumulator

loc_4554:
4554:  39                rts       ; xrefs $4542:branch

; ---- unreached/data gap $4555-$4555 ----

        .org $4556

sub_4556:
4556:  14 A0 20          bset     $a0, #32 ; xrefs $44E8:call
4559:  BD 49 A9          jsr      $49a9 ; $49A9=sub_49A9
455C:  BD 49 BA          jsr      $49ba ; $49BA=sub_49BA
455F:  BD 49 CA          jsr      $49ca ; $49CA=sub_49CA
4562:  39                rts      

; ---- unreached/data gap $4563-$4563 ----

        .org $4564

sub_4564:
4564:  14 A0 08          bset     $a0, #8 ; xrefs $44D6:call
4567:  FC 20 65          ldd      $2065
456A:  1A B3 21 4A       cpd      $214a
456E:  22 05             bhi      $4575 ; $4575=loc_4575
4570:  15 9E 01          bclr     $9e, #1
4573:  20 36             bra      $45ab ; $45AB=loc_45AB

loc_4575:
4575:  FD 21 4A          std      $214a ; xrefs $456E:branch
4578:  14 9E 01          bset     $9e, #1
457B:  18 CE 8E 04       ldy      #-29180
457F:  13 A9 10 04       brclr    $a9, #16, $4587 ; $00A9=operating_mode_flags, $4587=loc_4587
4583:  18 CE 8E 0D       ldy      #-29171

loc_4587:
4587:  7D 00 90          tst      >$0090 ; xrefs $457F:branch
458A:  27 04             beq      $4590 ; $4590=loc_4590
458C:  18 CE 8E 18       ldy      #-29160

loc_4590:
4590:  1A 83 08 00       cpd      #2048 ; xrefs $458A:branch
4594:  23 03             bls      $4599 ; $4599=loc_4599
4596:  CC 08 00          ldd      #2048

loc_4599:
4599:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $4594:branch
459C:  CE 8E 21          ldx      #-29151
459F:  F6 20 AB          ldab     $20ab
45A2:  3A                abx      
45A3:  E6 00             ldab     0, x
45A5:  3D                mul      
45A6:  89 00             adca     #0
45A8:  B7 21 46          staa     $2146

loc_45AB:
45AB:  BD 48 D8          jsr      $48d8 ; $48D8=sub_48D8 | xrefs $4573:branch
45AE:  39                rts      

; ---- unreached/data gap $45AF-$45AF ----

        .org $45B0

sub_45B0:
45B0:  14 A0 08          bset     $a0, #8 ; xrefs $44F1:call
45B3:  BD 48 D8          jsr      $48d8 ; $48D8=sub_48D8
45B6:  39                rts      

; ---- unreached/data gap $45B7-$45B7 ----

        .org $45B8

sub_45B8:
45B8:  18 CE 8C 61       ldy      #-29599 ; xrefs $44FA:call
45BC:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
45BF:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
45C2:  16                tab      
45C3:  4F                clra     
45C4:  FD 21 47          std      $2147 ; $2147=spark_accumulator
45C7:  15 A0 08          bclr     $a0, #8
45CA:  39                rts      

; ---- unreached/data gap $45CB-$45CB ----

        .org $45CC

sub_45CC:
45CC:  14 A0 08          bset     $a0, #8 ; xrefs $4503:call
45CF:  BD 49 80          jsr      $4980 ; $4980=sub_4980
45D2:  39                rts      

; ---- unreached/data gap $45D3-$45D3 ----

        .org $45D4

sub_45D4:
45D4:  CE 21 34          ldx      #8500 ; xrefs $4521:call
45D7:  E6 00             ldab     0, x
45D9:  27 16             beq      $45f1 ; $45F1=loc_45F1
45DB:  18 FE 21 47       ldy      $2147 ; $2147=spark_accumulator
45DF:  18 3A             aby      
45E1:  18 FF 21 47       sty      $2147 ; $2147=spark_accumulator
45E5:  A6 01             ldaa     1, x
45E7:  B0 8D BF          suba     $8dbf
45EA:  24 01             bcc      $45ed ; $45ED=loc_45ED
45EC:  5A                decb     

loc_45ED:
45ED:  A7 01             staa     1, x ; xrefs $45EA:branch
45EF:  E7 00             stab     0, x

loc_45F1:
45F1:  39                rts       ; xrefs $45D9:branch

; ---- unreached/data gap $45F2-$45F2 ----

        .org $45F3

sub_45F3:
45F3:  DE CE             ldx      $ce ; $00CE=load_aircharge_word | xrefs $4524:call
45F5:  BC 8D C1          cpx      $8dc1
45F8:  23 0E             bls      $4608 ; $4608=loc_4608
45FA:  F6 26 11          ldab     $2611
45FD:  4F                clra     
45FE:  40                nega     
45FF:  50                negb     
4600:  82 00             sbca     #0
4602:  F3 21 47          addd     $2147 ; $2147=spark_accumulator
4605:  FD 21 47          std      $2147 ; $2147=spark_accumulator

loc_4608:
4608:  39                rts       ; xrefs $45F8:branch

; ---- unreached/data gap $4609-$4609 ----

        .org $460A

sub_460A:
460A:  B6 20 B1          ldaa     $20b1 ; $20B1=spark_fuel_bank_selector | xrefs $4527:call
460D:  26 31             bne      $4640 ; $4640=loc_4640
460F:  FC 8D C3          ldd      $8dc3
4612:  93 BA             subd     $ba ; $00BA=engine_period_delta
4614:  23 2A             bls      $4640 ; $4640=loc_4640
4616:  4D                tsta     
4617:  27 02             beq      $461b ; $461B=loc_461B
4619:  C6 FF             ldab     #-1

loc_461B:
461B:  B6 8D C5          ldaa     $8dc5 ; xrefs $4617:branch
461E:  3D                mul      
461F:  1A 83 00 7F       cpd      #127
4623:  23 03             bls      $4628 ; $4628=loc_4628
4625:  CC 00 7F          ldd      #127

loc_4628:
4628:  40                nega      ; xrefs $4623:branch
4629:  50                negb     
462A:  82 00             sbca     #0
462C:  F3 21 47          addd     $2147 ; $2147=spark_accumulator
462F:  2B 08             bmi      $4639 ; $4639=loc_4639
4631:  4D                tsta     
4632:  26 09             bne      $463d ; $463D=loc_463D
4634:  F1 8D C6          cmpb     $8dc6
4637:  24 04             bcc      $463d ; $463D=loc_463D

loc_4639:
4639:  F6 8D C6          ldab     $8dc6 ; xrefs $462F:branch
463C:  4F                clra     

loc_463D:
463D:  FD 21 47          std      $2147 ; $2147=spark_accumulator | xrefs $4632:branch, $4637:branch

loc_4640:
4640:  39                rts       ; xrefs $460D:branch, $4614:branch

; ---- unreached/data gap $4641-$4641 ----

        .org $4642

sub_4642:
4642:  FC 21 47          ldd      $2147 ; $2147=spark_accumulator | xrefs $452A:call
4645:  2B 2E             bmi      $4675 ; $4675=loc_4675
4647:  1A 83 00 7F       cpd      #127
464B:  22 11             bhi      $465e ; $465E=loc_465E
464D:  12 B5 04 3B       brset    $b5, #4, $468c ; $468C=loc_468C
4651:  17                tba      
4652:  5F                clrb     
4653:  B3 21 32          subd     $2132
4656:  2D 17             blt      $466f ; $466F=loc_466F
4658:  1A B3 8D C7       cpd      $8dc7
465C:  23 2E             bls      $468c ; $468C=loc_468C

loc_465E:
465E:  FC 21 32          ldd      $2132 ; xrefs $464B:branch
4661:  F3 8D C7          addd     $8dc7
4664:  1A 83 7F 00       cpd      #32512
4668:  23 15             bls      $467f ; $467F=loc_467F
466A:  CC 7F 00          ldd      #32512
466D:  20 10             bra      $467f ; $467F=loc_467F

loc_466F:
466F:  1A B3 8D C9       cpd      $8dc9 ; xrefs $4656:branch
4673:  2C 17             bge      $468c ; $468C=loc_468C

loc_4675:
4675:  FC 21 32          ldd      $2132 ; xrefs $4645:branch
4678:  F3 8D C9          addd     $8dc9
467B:  2C 02             bge      $467f ; $467F=loc_467F
467D:  4F                clra     
467E:  5F                clrb     

loc_467F:
467F:  FD 21 32          std      $2132 ; xrefs $4668:branch, $466D:branch, $467B:branch
4682:  16                tab      
4683:  4F                clra     
4684:  FD 21 47          std      $2147 ; $2147=spark_accumulator
4687:  F7 20 01          stab     $2001
468A:  20 0A             bra      $4696 ; $4696=loc_4696

loc_468C:
468C:  B6 21 48          ldaa     $2148 ; xrefs $464D:branch, $465C:branch, $4673:branch
468F:  5F                clrb     
4690:  FD 21 32          std      $2132
4693:  B7 20 01          staa     $2001

loc_4696:
4696:  39                rts       ; xrefs $468A:branch

; ---- unreached/data gap $4697-$4697 ----

        .org $4698

sub_4698:
4698:  B6 10 40          ldaa     $1040 ; xrefs $452D:call
469B:  84 02             anda     #2
469D:  B1 21 55          cmpa     $2155
46A0:  27 10             beq      $46b2 ; $46B2=loc_46B2
46A2:  B7 21 55          staa     $2155
46A5:  B6 8D CB          ldaa     $8dcb
46A8:  B7 21 54          staa     $2154
46AB:  B6 8D CC          ldaa     $8dcc
46AE:  5F                clrb     
46AF:  FD 21 52          std      $2152

loc_46B2:
46B2:  CE 21 50          ldx      #8528 ; xrefs $46A0:branch
46B5:  18 CE 8D CD       ldy      #-29235
46B9:  BD 47 26          jsr      $4726 ; $4726=sub_4726
46BC:  39                rts      

; ---- unreached/data gap $46BD-$46BD ----

        .org $46BE

sub_46BE:
46BE:  B6 00 90          ldaa     >$0090 ; xrefs $4530:call
46C1:  26 07             bne      $46ca ; $46CA=loc_46CA
46C3:  86 00             ldaa     #0
46C5:  B7 21 4F          staa     $214f ; $214F=alternate_limiter_mode
46C8:  20 5A             bra      $4724 ; $4724=loc_4724

loc_46CA:
46CA:  18 CE 87 AB       ldy      #-30805 ; xrefs $46C1:branch
46CE:  F6 8D D7          ldab     $8dd7
46D1:  B6 20 2D          ldaa     $202d
46D4:  27 07             beq      $46dd ; $46DD=loc_46DD
46D6:  18 CE 87 A6       ldy      #-30810
46DA:  F6 8D D8          ldab     $8dd8

loc_46DD:
46DD:  B1 21 5B          cmpa     $215b ; xrefs $46D4:branch
46E0:  27 1C             beq      $46fe ; $46FE=loc_46FE
46E2:  B7 21 5B          staa     $215b
46E5:  F7 21 49          stab     $2149
46E8:  FC 20 46          ldd      $2046 ; $2046=spark_transition_axis
46EB:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
46EE:  B7 21 4F          staa     $214f ; $214F=alternate_limiter_mode
46F1:  4F                clra     
46F2:  B7 21 58          staa     $2158
46F5:  B7 21 5A          staa     $215a
46F8:  B7 21 56          staa     $2156
46FB:  14 A0 10          bset     $a0, #16

loc_46FE:
46FE:  13 A0 10 18       brclr    $a0, #16, $471a ; $471A=loc_471A | xrefs $46E0:branch
4702:  7D 21 49          tst      $2149
4705:  26 13             bne      $471a ; $471A=loc_471A
4707:  B6 8D D1          ldaa     $8dd1
470A:  B7 21 5A          staa     $215a
470D:  B6 8D D2          ldaa     $8dd2
4710:  5F                clrb     
4711:  B3 21 56          subd     $2156
4714:  FD 21 58          std      $2158
4717:  15 A0 10          bclr     $a0, #16

loc_471A:
471A:  CE 21 56          ldx      #8534 ; xrefs $46FE:branch, $4705:branch
471D:  18 CE 8D D3       ldy      #-29229
4721:  BD 47 26          jsr      $4726 ; $4726=sub_4726

loc_4724:
4724:  39                rts       ; xrefs $46C8:branch

; ---- unreached/data gap $4725-$4725 ----

        .org $4726

sub_4726:
4726:  EC 02             ldd      2, x ; xrefs $46B9:call, $4721:call
4728:  6D 04             tst      4, x
472A:  27 04             beq      $4730 ; $4730=loc_4730
472C:  6A 04             dec      4, x
472E:  20 10             bra      $4740 ; $4740=loc_4740

loc_4730:
4730:  1A 83 00 00       cpd      #0 ; xrefs $472A:branch
4734:  27 0A             beq      $4740 ; $4740=loc_4740
4736:  18 A3 00          subd     0, y
4739:  24 03             bcc      $473e ; $473E=loc_473E
473B:  CC 00 00          ldd      #0

loc_473E:
473E:  ED 02             std      2, x ; xrefs $4739:branch

loc_4740:
4740:  12 A0 20 0E       brset    $a0, #32, $4752 ; $4752=loc_4752 | xrefs $472E:branch, $4734:branch
4744:  EC 00             ldd      0, x
4746:  27 28             beq      $4770 ; $4770=loc_4770
4748:  18 A3 02          subd     2, y
474B:  24 03             bcc      $4750 ; $4750=loc_4750
474D:  CC 00 00          ldd      #0

loc_4750:
4750:  ED 02             std      2, x ; xrefs $474B:branch

loc_4752:
4752:  ED 00             std      0, x ; xrefs $4740:branch
4754:  27 1A             beq      $4770 ; $4770=loc_4770
4756:  B6 21 48          ldaa     $2148
4759:  E6 05             ldab     5, x
475B:  26 08             bne      $4765 ; $4765=loc_4765
475D:  AB 00             adda     0, x
475F:  28 09             bvc      $476a ; $476A=loc_476A
4761:  86 7F             ldaa     #127
4763:  20 05             bra      $476a ; $476A=loc_476A

loc_4765:
4765:  A0 00             suba     0, x ; xrefs $475B:branch
4767:  24 01             bcc      $476a ; $476A=loc_476A
4769:  4F                clra     

loc_476A:
476A:  B7 21 48          staa     $2148 ; xrefs $475F:branch, $4763:branch, $4767:branch
476D:  B7 20 01          staa     $2001

loc_4770:
4770:  39                rts       ; xrefs $4746:branch, $4754:branch

; ---- unreached/data gap $4771-$4771 ----

        .org $4772

sub_4772:
4772:  B6 21 49          ldaa     $2149 ; xrefs $96B9:call
4775:  27 03             beq      $477a ; $477A=loc_477A
4777:  7A 21 49          dec      $2149

loc_477A:
477A:  39                rts       ; xrefs $4775:branch

sub_477B:
477B:  4F                clra      ; xrefs $4533:call
477C:  13 A0 04 13       brclr    $a0, #4, $4793 ; $4793=loc_4793
4780:  13 A9 40 09       brclr    $a9, #64, $478d ; $00A9=operating_mode_flags, $478D=loc_478D
4784:  13 D8 10 05       brclr    $d8, #16, $478d ; $478D=loc_478D
4788:  B6 20 AA          ldaa     $20aa
478B:  26 16             bne      $47a3 ; $47A3=loc_47A3

loc_478D:
478D:  B6 21 39          ldaa     $2139 ; xrefs $4780:branch, $4784:branch
4790:  7E 48 8C          jmp      $488c ; $488C=loc_488C

loc_4793:
4793:  12 A0 08 03       brset    $a0, #8, $479a ; $479A=loc_479A | xrefs $477C:branch
4797:  7E 48 8C          jmp      $488c ; $488C=loc_488C

loc_479A:
479A:  13 D8 10 26       brclr    $d8, #16, $47c4 ; $47C4=loc_47C4 | xrefs $4793:branch
479E:  B6 20 AA          ldaa     $20aa
47A1:  27 36             beq      $47d9 ; $47D9=loc_47D9

loc_47A3:
47A3:  B6 00 90          ldaa     >$0090 ; xrefs $478B:branch
47A6:  26 10             bne      $47b8 ; $47B8=loc_47B8
47A8:  CE 8D F2          ldx      #-29198
47AB:  13 B5 01 03       brclr    $b5, #1, $47b2 ; $47B2=loc_47B2
47AF:  CE 8D EC          ldx      #-29204

loc_47B2:
47B2:  F6 20 AB          ldab     $20ab ; xrefs $47AB:branch
47B5:  3A                abx      
47B6:  20 47             bra      $47ff ; $47FF=loc_47FF

loc_47B8:
47B8:  CE 8D F9          ldx      #-29191 ; xrefs $47A6:branch
47BB:  13 B5 01 03       brclr    $b5, #1, $47c2 ; $47C2=loc_47C2
47BF:  CE 8D F8          ldx      #-29192

loc_47C2:
47C2:  20 3B             bra      $47ff ; $47FF=loc_47FF | xrefs $47BB:branch

loc_47C4:
47C4:  13 B5 01 2C       brclr    $b5, #1, $47f4 ; $47F4=loc_47F4 | xrefs $479A:branch
47C8:  D6 CA             ldab     $ca
47CA:  F1 8E 00          cmpb     $8e00
47CD:  22 18             bhi      $47e7 ; $47E7=loc_47E7
47CF:  4F                clra     
47D0:  B7 21 46          staa     $2146
47D3:  B7 21 43          staa     $2143
47D6:  7E 48 8C          jmp      $488c ; $488C=loc_488C

loc_47D9:
47D9:  4F                clra      ; xrefs $47A1:branch
47DA:  B7 21 46          staa     $2146
47DD:  12 B5 80 06       brset    $b5, #-128, $47e7 ; $47E7=loc_47E7
47E1:  B7 21 43          staa     $2143
47E4:  7E 48 8C          jmp      $488c ; $488C=loc_488C

loc_47E7:
47E7:  CE 8D FA          ldx      #-29190 ; xrefs $47CD:branch, $47DD:branch
47EA:  7D 00 90          tst      >$0090
47ED:  27 03             beq      $47f2 ; $47F2=loc_47F2
47EF:  CE 8D FC          ldx      #-29188

loc_47F2:
47F2:  20 0B             bra      $47ff ; $47FF=loc_47FF | xrefs $47ED:branch

loc_47F4:
47F4:  CE 8D FB          ldx      #-29189 ; xrefs $47C4:branch
47F7:  7D 00 90          tst      >$0090
47FA:  27 03             beq      $47ff ; $47FF=loc_47FF
47FC:  CE 8D FD          ldx      #-29187

loc_47FF:
47FF:  A6 00             ldaa     0, x ; xrefs $47B6:branch, $47C2:branch, $47F2:branch, $47FA:branch
4801:  16                tab      
4802:  F0 21 43          subb     $2143
4805:  25 11             bcs      $4818 ; $4818=loc_4818
4807:  F1 8D FE          cmpb     $8dfe
480A:  23 1B             bls      $4827 ; $4827=loc_4827
480C:  B6 21 43          ldaa     $2143
480F:  BB 8D FE          adda     $8dfe
4812:  24 13             bcc      $4827 ; $4827=loc_4827
4814:  86 FF             ldaa     #-1
4816:  20 0F             bra      $4827 ; $4827=loc_4827

loc_4818:
4818:  50                negb      ; xrefs $4805:branch
4819:  F1 8D FF          cmpb     $8dff
481C:  23 09             bls      $4827 ; $4827=loc_4827
481E:  B6 21 43          ldaa     $2143
4821:  B0 8D FF          suba     $8dff
4824:  24 01             bcc      $4827 ; $4827=loc_4827
4826:  4F                clra     

loc_4827:
4827:  B7 21 43          staa     $2143 ; xrefs $480A:branch, $4812:branch, $4816:branch, $481C:branch, $4824:branch
482A:  F6 24 E9          ldab     $24e9
482D:  2B 0B             bmi      $483a ; $483A=loc_483A
482F:  3D                mul      
4830:  89 00             adca     #0
4832:  F6 8E 01          ldab     $8e01
4835:  11                cba      
4836:  2F 0E             ble      $4846 ; $4846=loc_4846
4838:  20 0B             bra      $4845 ; $4845=loc_4845

loc_483A:
483A:  50                negb      ; xrefs $482D:branch
483B:  3D                mul      
483C:  89 00             adca     #0
483E:  40                nega     
483F:  F6 8E 02          ldab     $8e02
4842:  11                cba      
4843:  2C 01             bge      $4846 ; $4846=loc_4846

loc_4845:
4845:  17                tba       ; xrefs $4838:branch

loc_4846:
4846:  4D                tsta      ; xrefs $4836:branch, $4843:branch
4847:  2B 16             bmi      $485f ; $485F=loc_485F
4849:  F6 20 DF          ldab     $20df
484C:  26 0F             bne      $485d ; $485D=loc_485D
484E:  F6 20 E0          ldab     $20e0
4851:  26 0A             bne      $485d ; $485D=loc_485D
4853:  F6 20 E1          ldab     $20e1
4856:  26 05             bne      $485d ; $485D=loc_485D
4858:  F6 20 DE          ldab     $20de
485B:  27 02             beq      $485f ; $485F=loc_485F

loc_485D:
485D:  86 00             ldaa     #0 ; xrefs $484C:branch, $4851:branch, $4856:branch

loc_485F:
485F:  B7 21 41          staa     $2141 ; xrefs $4847:branch, $485B:branch
4862:  B6 21 48          ldaa     $2148
4865:  F6 21 46          ldab     $2146
4868:  27 0D             beq      $4877 ; $4877=loc_4877
486A:  3D                mul      
486B:  89 00             adca     #0
486D:  B7 21 45          staa     $2145
4870:  40                nega     
4871:  BB 21 48          adda     $2148
4874:  B7 21 48          staa     $2148

loc_4877:
4877:  F6 21 41          ldab     $2141 ; xrefs $4868:branch
487A:  2A 0A             bpl      $4886 ; $4886=loc_4886
487C:  50                negb     
487D:  3D                mul      
487E:  05                asld     
487F:  2A 02             bpl      $4883 ; $4883=loc_4883
4881:  86 7F             ldaa     #127

loc_4883:
4883:  40                nega      ; xrefs $487F:branch
4884:  20 06             bra      $488c ; $488C=loc_488C

loc_4886:
4886:  3D                mul       ; xrefs $487A:branch
4887:  05                asld     
4888:  2A 02             bpl      $488c ; $488C=loc_488C
488A:  86 7F             ldaa     #127

loc_488C:
488C:  B7 21 44          staa     $2144 ; xrefs $4790:jump, $4797:jump, $47D6:jump, $47E4:jump, $4884:branch, $4888:branch
488F:  16                tab      
4890:  8B 80             adda     #-128
4892:  B7 20 02          staa     $2002
4895:  4F                clra     
4896:  5D                tstb     
4897:  2A 01             bpl      $489a ; $489A=loc_489A
4899:  43                coma     

loc_489A:
489A:  F3 21 47          addd     $2147 ; $2147=spark_accumulator | xrefs $4897:branch
489D:  2A 03             bpl      $48a2 ; $48A2=loc_48A2
489F:  5F                clrb     
48A0:  20 08             bra      $48aa ; $48AA=loc_48AA

loc_48A2:
48A2:  1A 83 00 7F       cpd      #127 ; xrefs $489D:branch
48A6:  23 02             bls      $48aa ; $48AA=loc_48AA
48A8:  C6 7F             ldab     #127

loc_48AA:
48AA:  D7 B6             stab     $b6 ; xrefs $48A0:branch, $48A6:branch
48AC:  0F                sei      
48AD:  17                tba      
48AE:  F0 20 DF          subb     $20df
48B1:  24 01             bcc      $48b4 ; $48B4=loc_48B4
48B3:  5F                clrb     

loc_48B4:
48B4:  F7 20 E3          stab     $20e3 ; xrefs $48B1:branch
48B7:  16                tab      
48B8:  F0 20 E0          subb     $20e0
48BB:  24 01             bcc      $48be ; $48BE=loc_48BE
48BD:  5F                clrb     

loc_48BE:
48BE:  F7 20 E4          stab     $20e4 ; xrefs $48BB:branch
48C1:  16                tab      
48C2:  F0 20 E1          subb     $20e1
48C5:  24 01             bcc      $48c8 ; $48C8=loc_48C8
48C7:  5F                clrb     

loc_48C8:
48C8:  F7 20 E5          stab     $20e5 ; xrefs $48C5:branch
48CB:  16                tab      
48CC:  F0 20 DE          subb     $20de
48CF:  24 01             bcc      $48d2 ; $48D2=loc_48D2
48D1:  5F                clrb     

loc_48D2:
48D2:  F7 20 E2          stab     $20e2 ; xrefs $48CF:branch
48D5:  0E                cli      
48D6:  39                rts      

; ---- unreached/data gap $48D7-$48D7 ----

        .org $48D8

sub_48D8:
48D8:  8D 14             bsr      $48ee ; $48EE=lookup_base_spark | xrefs $4544:call, $45AB:call, $45B3:call
48DA:  BD 49 43          jsr      $4943 ; $4943=apply_spark_temperature_correction
48DD:  B6 21 4C          ldaa     $214c
48E0:  B7 21 4E          staa     $214e
48E3:  BD 49 4F          jsr      $494f ; $494F=sub_494F
48E6:  B6 21 4C          ldaa     $214c
48E9:  B7 21 4D          staa     $214d
48EC:  39                rts      

; ---- unreached/data gap $48ED-$48ED ----

        .org $48EE

; [CONFIRMED] Select RPM-only or 24x9 spark bank, interpolate, add optional signed offset, accumulate in 0x2147.
lookup_base_spark:
48EE:  CC 00 00          ldd      #0 ; begin base spark selection/interpolation | xrefs $48D8:call
48F1:  FD 21 47          std      $2147 ; $2147=spark_accumulator
48F4:  13 A9 20 0C       brclr    $a9, #32, $4904 ; $00A9=operating_mode_flags, $4904=loc_4904
48F8:  18 CE 8C 19       ldy      #-29671
48FC:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
48FF:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
4902:  20 35             bra      $4939 ; $4939=loc_4939

loc_4904:
4904:  CE 8A 69          ldx      #-30103 ; xrefs $48F4:branch
4907:  7D 20 B1          tst      $20b1 ; $20B1=spark_fuel_bank_selector
490A:  26 03             bne      $490f ; $490F=loc_490F
490C:  CE 8B 41          ldx      #-29887

loc_490F:
490F:  18 CE 21 3A       ldy      #8506 ; xrefs $490A:branch
4913:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
4916:  18 ED 00          std      0, y
4919:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
491C:  18 ED 02          std      2, y
491F:  CD EF 04          stx      4, y
4922:  86 09             ldaa     #9
4924:  18 A7 06          staa     6, y
4927:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
492A:  13 A2 02 0B       brclr    $a2, #2, $4939 ; $00A2=spark_mode_flags, $4939=loc_4939
492E:  F6 8A 68          ldab     $8a68
4931:  2A 03             bpl      $4936 ; $4936=loc_4936
4933:  73 21 47          com      $2147 ; $2147=spark_accumulator

loc_4936:
4936:  F7 21 48          stab     $2148 ; xrefs $4931:branch

loc_4939:
4939:  16                tab       ; xrefs $4902:branch, $492A:branch
493A:  4F                clra     
493B:  F3 21 47          addd     $2147 ; $2147=spark_accumulator
493E:  FD 21 47          std      $2147 ; $2147=spark_accumulator
4941:  39                rts      

; ---- unreached/data gap $4942-$4942 ----

        .org $4943

; [STRONG] Apply signed temperature/load spark correction to the base spark result.
apply_spark_temperature_correction:
4943:  18 CE 21 3A       ldy      #8506 ; xrefs $48DA:call
4947:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
494A:  CE 8D 15          ldx      #-29419
494D:  20 0A             bra      $4959 ; $4959=loc_4959

sub_494F:
494F:  18 CE 21 3A       ldy      #8506 ; xrefs $48E3:call
4953:  FC 20 3A          ldd      $203a
4956:  CE 8C 7C          ldx      #-29572

loc_4959:
4959:  18 ED 02          std      2, y ; xrefs $494D:branch
495C:  CD EF 04          stx      4, y
495F:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
4962:  18 ED 00          std      0, y
4965:  86 09             ldaa     #9
4967:  18 A7 06          staa     6, y
496A:  BD B3 2B          jsr      $b32b ; $B32B=interp_2d_s8
496D:  B7 21 4C          staa     $214c
4970:  16                tab      
4971:  2B 03             bmi      $4976 ; $4976=loc_4976
4973:  4F                clra     
4974:  20 02             bra      $4978 ; $4978=loc_4978

loc_4976:
4976:  86 FF             ldaa     #-1 ; xrefs $4971:branch

loc_4978:
4978:  F3 21 47          addd     $2147 ; $2147=spark_accumulator | xrefs $4974:branch
497B:  FD 21 47          std      $2147 ; $2147=spark_accumulator
497E:  39                rts      

; ---- unreached/data gap $497F-$497F ----

        .org $4980

sub_4980:
4980:  13 D8 10 18       brclr    $d8, #16, $499c ; $499C=loc_499C | xrefs $453F:call, $45CF:call
4984:  B6 20 AB          ldaa     $20ab
4987:  27 13             beq      $499c ; $499C=loc_499C
4989:  B6 00 90          ldaa     >$0090
498C:  27 0A             beq      $4998 ; $4998=loc_4998
498E:  B6 20 2D          ldaa     $202d
4991:  26 09             bne      $499c ; $499C=loc_499C
4993:  B6 20 AA          ldaa     $20aa
4996:  27 04             beq      $499c ; $499C=loc_499C

loc_4998:
4998:  8D 09             bsr      $49a3 ; $49A3=sub_49A3 | xrefs $498C:branch
499A:  20 02             bra      $499e ; $499E=loc_499E

loc_499C:
499C:  8D 0B             bsr      $49a9 ; $49A9=sub_49A9 | xrefs $4980:branch, $4987:branch, $4991:branch, $4996:branch

loc_499E:
499E:  BD 49 BA          jsr      $49ba ; $49BA=sub_49BA | xrefs $499A:branch
49A1:  39                rts      

; ---- unreached/data gap $49A2-$49A2 ----

        .org $49A3

sub_49A3:
49A3:  18 CE 8C 31       ldy      #-29647 ; xrefs $4998:call
49A7:  20 04             bra      $49ad ; $49AD=loc_49AD

sub_49A9:
49A9:  18 CE 8C 49       ldy      #-29623 ; xrefs $4559:call, $499C:call

loc_49AD:
49AD:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis | xrefs $49A7:branch
49B0:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
49B3:  16                tab      
49B4:  4F                clra     
49B5:  FD 21 47          std      $2147 ; $2147=spark_accumulator
49B8:  39                rts      

; ---- unreached/data gap $49B9-$49B9 ----

        .org $49BA

sub_49BA:
49BA:  18 CE 8D AE       ldy      #-29266 ; xrefs $455C:call, $499E:call
49BE:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
49C1:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
49C4:  5F                clrb     
49C5:  FD 21 34          std      $2134
49C8:  39                rts      

; ---- unreached/data gap $49C9-$49C9 ----

        .org $49CA

sub_49CA:
49CA:  B6 20 00          ldaa     $2000 ; xrefs $455F:call
49CD:  27 06             beq      $49d5 ; $49D5=loc_49D5
49CF:  7A 20 00          dec      $2000
49D2:  7E 4A A0          jmp      $4aa0 ; $4AA0=loc_4AA0

loc_49D5:
49D5:  12 A0 04 08       brset    $a0, #4, $49e1 ; $49E1=loc_49E1 | xrefs $49CD:branch
49D9:  14 A0 04          bset     $a0, #4
49DC:  DC BA             ldd      $ba ; $00BA=engine_period_delta
49DE:  FD 20 2E          std      $202e

loc_49E1:
49E1:  18 CE 8D E8       ldy      #-29208 ; xrefs $49D5:branch
49E5:  CE 8D E2          ldx      #-29214
49E8:  7D 00 90          tst      >$0090
49EB:  27 0B             beq      $49f8 ; $49F8=loc_49F8
49ED:  CE 8D E4          ldx      #-29212
49F0:  7D 20 2D          tst      $202d
49F3:  27 03             beq      $49f8 ; $49F8=loc_49F8
49F5:  CE 8D E6          ldx      #-29210

loc_49F8:
49F8:  DC BA             ldd      $ba ; $00BA=engine_period_delta | xrefs $49EB:branch, $49F3:branch
49FA:  B3 20 2E          subd     $202e
49FD:  36                psha     
49FE:  24 07             bcc      $4a07 ; $4A07=loc_4A07
4A00:  18 08             iny      
4A02:  08                inx      
4A03:  40                nega     
4A04:  50                negb     
4A05:  82 00             sbca     #0

loc_4A07:
4A07:  37                pshb      ; xrefs $49FE:branch
4A08:  18 E6 00          ldab     0, y
4A0B:  F7 21 39          stab     $2139
4A0E:  E6 00             ldab     0, x
4A10:  3D                mul      
4A11:  18 8F             xgdy     
4A13:  32                pula     
4A14:  E6 00             ldab     0, x
4A16:  3D                mul      
4A17:  89 00             adca     #0
4A19:  16                tab      
4A1A:  18 3A             aby      
4A1C:  18 8F             xgdy     
4A1E:  04                lsrd     
4A1F:  04                lsrd     
4A20:  04                lsrd     
4A21:  04                lsrd     
4A22:  C9 00             adcb     #0
4A24:  89 00             adca     #0
4A26:  27 02             beq      $4a2a ; $4A2A=loc_4A2A
4A28:  C6 FF             ldab     #-1

loc_4A2A:
4A2A:  F1 21 39          cmpb     $2139 ; xrefs $4A26:branch
4A2D:  23 03             bls      $4a32 ; $4A32=loc_4A32
4A2F:  F6 21 39          ldab     $2139

loc_4A32:
4A32:  32                pula      ; xrefs $4A2D:branch
4A33:  4D                tsta     
4A34:  2A 01             bpl      $4a37 ; $4A37=loc_4A37
4A36:  50                negb     

loc_4A37:
4A37:  F7 21 39          stab     $2139 ; xrefs $4A34:branch
4A3A:  B6 20 A8          ldaa     $20a8
4A3D:  B0 8D EA          suba     $8dea
4A40:  24 01             bcc      $4a43 ; $4A43=loc_4A43
4A42:  4F                clra     

loc_4A43:
4A43:  91 D2             cmpa     $d2 ; xrefs $4A40:branch
4A45:  23 0A             bls      $4a51 ; $4A51=loc_4A51
4A47:  86 01             ldaa     #1
4A49:  B7 21 36          staa     $2136
4A4C:  86 FF             ldaa     #-1
4A4E:  5F                clrb     
4A4F:  20 31             bra      $4a82 ; $4A82=loc_4A82

loc_4A51:
4A51:  B6 20 A8          ldaa     $20a8 ; xrefs $4A45:branch
4A54:  BB 8D EA          adda     $8dea
4A57:  24 02             bcc      $4a5b ; $4A5B=loc_4A5B
4A59:  86 FF             ldaa     #-1

loc_4A5B:
4A5B:  91 D2             cmpa     $d2 ; xrefs $4A57:branch
4A5D:  24 0A             bcc      $4a69 ; $4A69=loc_4A69
4A5F:  86 03             ldaa     #3
4A61:  B7 21 36          staa     $2136
4A64:  4F                clra     
4A65:  C6 FF             ldab     #-1
4A67:  20 19             bra      $4a82 ; $4A82=loc_4A82

loc_4A69:
4A69:  86 02             ldaa     #2 ; xrefs $4A5D:branch
4A6B:  B7 21 36          staa     $2136
4A6E:  B6 21 38          ldaa     $2138
4A71:  BB 8D EB          adda     $8deb
4A74:  24 02             bcc      $4a78 ; $4A78=loc_4A78
4A76:  86 FF             ldaa     #-1

loc_4A78:
4A78:  F6 21 37          ldab     $2137 ; xrefs $4A74:branch
4A7B:  FB 8D EB          addb     $8deb
4A7E:  24 02             bcc      $4a82 ; $4A82=loc_4A82
4A80:  C6 FF             ldab     #-1

loc_4A82:
4A82:  B7 21 38          staa     $2138 ; xrefs $4A4F:branch, $4A67:branch, $4A7E:branch
4A85:  F7 21 37          stab     $2137
4A88:  B6 21 39          ldaa     $2139
4A8B:  2B 08             bmi      $4a95 ; $4A95=loc_4A95
4A8D:  F6 21 38          ldab     $2138
4A90:  3D                mul      
4A91:  89 00             adca     #0
4A93:  20 08             bra      $4a9d ; $4A9D=loc_4A9D

loc_4A95:
4A95:  40                nega      ; xrefs $4A8B:branch
4A96:  F6 21 37          ldab     $2137
4A99:  3D                mul      
4A9A:  89 00             adca     #0
4A9C:  40                nega     

loc_4A9D:
4A9D:  B7 21 39          staa     $2139 ; xrefs $4A93:branch

loc_4AA0:
4AA0:  39                rts       ; xrefs $49D2:jump

; ---- unreached/data gap $4AA1-$4AA6 ----

        .org $4AA7

sub_4AA7:
4AA7:  14 8C 48          bset     $8c, #72 ; xrefs $B88D:call
4AAA:  15 8C 23          bclr     $8c, #35
4AAD:  15 8D AE          bclr     $8d, #-82
4AB0:  15 8D 40          bclr     $8d, #64
4AB3:  14 8D 10          bset     $8d, #16
4AB6:  15 FC FC          bclr     $fc, #-4
4AB9:  4F                clra     
4ABA:  B7 21 5C          staa     $215c
4ABD:  B7 21 63          staa     $2163
4AC0:  B7 21 64          staa     $2164
4AC3:  B7 21 65          staa     $2165
4AC6:  B7 21 66          staa     $2166
4AC9:  B7 21 68          staa     $2168
4ACC:  86 1E             ldaa     #30
4ACE:  B7 21 6A          staa     $216a
4AD1:  7F 00 F1          clr      >$00f1
4AD4:  18 CE 26 20       ldy      #9760
4AD8:  BD 4B 13          jsr      $4b13 ; $4B13=sub_4B13
4ADB:  1A B3 26 24       cpd      $2624
4ADF:  27 12             beq      $4af3 ; $4AF3=loc_4AF3
4AE1:  CE 55 B8          ldx      #21944
4AE4:  C6 20             ldab     #32
4AE6:  3A                abx      
4AE7:  18 CE 26 20       ldy      #9760
4AEB:  86 10             ldaa     #16
4AED:  B7 21 6B          staa     $216b
4AF0:  BD 4B 52          jsr      $4b52 ; $4B52=sub_4B52

loc_4AF3:
4AF3:  18 CE 26 30       ldy      #9776 ; xrefs $4ADF:branch
4AF7:  BD 4B 13          jsr      $4b13 ; $4B13=sub_4B13
4AFA:  1A B3 26 34       cpd      $2634
4AFE:  27 12             beq      $4b12 ; $4B12=loc_4B12
4B00:  CE 55 B8          ldx      #21944
4B03:  C6 30             ldab     #48
4B05:  3A                abx      
4B06:  18 CE 26 30       ldy      #9776
4B0A:  86 10             ldaa     #16
4B0C:  B7 21 6B          staa     $216b
4B0F:  BD 4B 52          jsr      $4b52 ; $4B52=sub_4B52

loc_4B12:
4B12:  39                rts       ; xrefs $4AFE:branch

sub_4B13:
4B13:  4F                clra      ; xrefs $4AD8:call, $4AF7:call
4B14:  B7 21 6C          staa     $216c
4B17:  B7 21 6D          staa     $216d
4B1A:  CE 4A A2          ldx      #19106
4B1D:  A6 00             ldaa     0, x
4B1F:  18 E6 00          ldab     0, y
4B22:  3D                mul      
4B23:  17                tba      
4B24:  5F                clrb     
4B25:  F3 21 6C          addd     $216c
4B28:  FD 21 6C          std      $216c
4B2B:  08                inx      

loc_4B2C:
4B2C:  A6 00             ldaa     0, x ; xrefs $4B45:branch
4B2E:  18 E6 00          ldab     0, y
4B31:  3D                mul      
4B32:  F3 21 6C          addd     $216c
4B35:  FD 21 6C          std      $216c
4B38:  08                inx      
4B39:  18 08             iny      
4B3B:  3C                pshx     
4B3C:  8F                xgdx     
4B3D:  38                pulx     
4B3E:  83 4A A2          subd     #19106
4B41:  1A 83 00 04       cpd      #4
4B45:  26 E5             bne      $4b2c ; $4B2C=loc_4B2C
4B47:  18 E6 00          ldab     0, y
4B4A:  4F                clra     
4B4B:  F3 21 6C          addd     $216c
4B4E:  FD 21 6C          std      $216c
4B51:  39                rts      

sub_4B52:
4B52:  A6 00             ldaa     0, x ; xrefs $4AF0:call, $4B0F:call, $4B60:branch, $4BE7:call, $4C0C:call
4B54:  18 A7 00          staa     0, y
4B57:  08                inx      
4B58:  18 08             iny      
4B5A:  7A 21 6B          dec      $216b
4B5D:  7D 21 6B          tst      $216b
4B60:  26 F0             bne      $4b52 ; $4B52=sub_4B52
4B62:  39                rts      

sub_4B63:
4B63:  BD 4E A3          jsr      $4ea3 ; $4EA3=sub_4EA3 | xrefs $B890:call
4B66:  CE 26 30          ldx      #9776
4B69:  EC 04             ldd      4, x
4B6B:  1A 83 4D 20       cpd      #19744
4B6F:  26 0A             bne      $4b7b ; $4B7B=loc_4B7B
4B71:  15 8C 30          bclr     $8c, #48
4B74:  14 8C 08          bset     $8c, #8
4B77:  86 0F             ldaa     #15
4B79:  20 09             bra      $4b84 ; $4B84=loc_4B84

loc_4B7B:
4B7B:  14 8C 20          bset     $8c, #32 ; xrefs $4B6F:branch
4B7E:  15 8C 08          bclr     $8c, #8
4B81:  BD 4B 87          jsr      $4b87 ; $4B87=sub_4B87

loc_4B84:
4B84:  97 8B             staa     $8b ; xrefs $4B79:branch
4B86:  39                rts      

sub_4B87:
4B87:  7F 21 70          clr      $2170 ; xrefs $4B81:call, $4E36:call, $4E4C:call
4B8A:  7F 21 71          clr      $2171
4B8D:  7F 21 72          clr      $2172
4B90:  CE B6 70          ldx      #-18832
4B93:  F6 21 6F          ldab     $216f
4B96:  3A                abx      
4B97:  C6 80             ldab     #-128
4B99:  BD 4B B5          jsr      $4bb5 ; $4BB5=sub_4BB5
4B9C:  3A                abx      
4B9D:  BD 4B B5          jsr      $4bb5 ; $4BB5=sub_4BB5
4BA0:  3A                abx      
4BA1:  BD 4B B5          jsr      $4bb5 ; $4BB5=sub_4BB5
4BA4:  B6 21 70          ldaa     $2170
4BA7:  81 02             cmpa     #2
4BA9:  25 04             bcs      $4baf ; $4BAF=loc_4BAF
4BAB:  86 F0             ldaa     #-16
4BAD:  20 05             bra      $4bb4 ; $4BB4=loc_4BB4

loc_4BAF:
4BAF:  86 0F             ldaa     #15 ; xrefs $4BA9:branch
4BB1:  15 8C 10          bclr     $8c, #16

loc_4BB4:
4BB4:  39                rts       ; xrefs $4BAD:branch

sub_4BB5:
4BB5:  A6 00             ldaa     0, x ; xrefs $4B99:call, $4B9D:call, $4BA1:call
4BB7:  81 F0             cmpa     #-16
4BB9:  26 05             bne      $4bc0 ; $4BC0=loc_4BC0
4BBB:  7C 21 70          inc      $2170
4BBE:  20 0C             bra      $4bcc ; $4BCC=loc_4BCC

loc_4BC0:
4BC0:  81 0F             cmpa     #15 ; xrefs $4BB9:branch
4BC2:  26 05             bne      $4bc9 ; $4BC9=loc_4BC9
4BC4:  7C 21 71          inc      $2171
4BC7:  20 03             bra      $4bcc ; $4BCC=loc_4BCC

loc_4BC9:
4BC9:  7C 21 72          inc      $2172 ; xrefs $4BC2:branch

loc_4BCC:
4BCC:  39                rts       ; xrefs $4BBE:branch, $4BC7:branch

sub_4BCD:
4BCD:  13 F1 40 03       brclr    $f1, #64, $4bd4 ; $4BD4=loc_4BD4 | xrefs $D6A1:call
4BD1:  7E 4C 26          jmp      $4c26 ; $4C26=loc_4C26

loc_4BD4:
4BD4:  14 F1 40          bset     $f1, #64 ; xrefs $4BCD:branch
4BD7:  13 F1 10 25       brclr    $f1, #16, $4c00 ; $4C00=loc_4C00
4BDB:  CE 21 5D          ldx      #8541
4BDE:  18 CE 26 30       ldy      #9776
4BE2:  C6 06             ldab     #6
4BE4:  F7 21 6B          stab     $216b
4BE7:  BD 4B 52          jsr      $4b52 ; $4B52=sub_4B52
4BEA:  C6 30             ldab     #48
4BEC:  BD 69 DE          jsr      $69de ; $69DE=sub_69DE
4BEF:  86 04             ldaa     #4
4BF1:  B7 21 A3          staa     $21a3
4BF4:  B7 25 77          staa     $2577
4BF7:  48                asla     
4BF8:  B7 25 78          staa     $2578
4BFB:  15 FC 01          bclr     $fc, #1
4BFE:  20 35             bra      $4c35 ; $4C35=loc_4C35

loc_4C00:
4C00:  CE 21 5D          ldx      #8541 ; xrefs $4BD7:branch
4C03:  18 CE 26 20       ldy      #9760
4C07:  C6 06             ldab     #6
4C09:  F7 21 6B          stab     $216b
4C0C:  BD 4B 52          jsr      $4b52 ; $4B52=sub_4B52
4C0F:  C6 20             ldab     #32
4C11:  BD 69 DE          jsr      $69de ; $69DE=sub_69DE
4C14:  86 03             ldaa     #3
4C16:  B7 21 A3          staa     $21a3
4C19:  B7 25 77          staa     $2577
4C1C:  8B 01             adda     #1
4C1E:  B7 25 78          staa     $2578
4C21:  15 FC 01          bclr     $fc, #1
4C24:  20 0F             bra      $4c35 ; $4C35=loc_4C35

loc_4C26:
4C26:  13 F1 10 05       brclr    $f1, #16, $4c2f ; $4C2F=loc_4C2F | xrefs $4BD1:jump
4C2A:  15 F1 10          bclr     $f1, #16
4C2D:  20 03             bra      $4c32 ; $4C32=loc_4C32

loc_4C2F:
4C2F:  15 F1 20          bclr     $f1, #32 ; xrefs $4C26:branch

loc_4C32:
4C32:  15 F1 40          bclr     $f1, #64 ; xrefs $4C2D:branch

loc_4C35:
4C35:  39                rts       ; xrefs $4BFE:branch, $4C24:branch

sub_4C36:
4C36:  12 AF 80 20       brset    $af, #-128, $4c5a ; $4C5A=loc_4C5A | xrefs $4C97:call, $4CD5:call, $4E3F:call, $4EEC:call
4C3A:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
4C3D:  81 FF             cmpa     #-1
4C3F:  26 19             bne      $4c5a ; $4C5A=loc_4C5A
4C41:  86 04             ldaa     #4
4C43:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
4C46:  15 AF 01          bclr     $af, #1
4C49:  C6 03             ldab     #3
4C4B:  F7 21 68          stab     $2168
4C4E:  7F 21 69          clr      $2169
4C51:  CE 10 00          ldx      #4096
4C54:  1C 2D 08          bset     45, x; #8
4C57:  14 8D 02          bset     $8d, #2

loc_4C5A:
4C5A:  39                rts       ; xrefs $4C36:branch, $4C3F:branch

sub_4C5B:
4C5B:  12 8C 40 3E       brset    $8c, #64, $4c9d ; $4C9D=loc_4C9D | xrefs $D3DC:call
4C5F:  12 8D 04 3A       brset    $8d, #4, $4c9d ; $4C9D=loc_4C9D
4C63:  12 8D 20 12       brset    $8d, #32, $4c79 ; $4C79=loc_4C79
4C67:  13 8D 40 14       brclr    $8d, #64, $4c7f ; $4C7F=loc_4C7F
4C6B:  96 8B             ldaa     $8b
4C6D:  81 0F             cmpa     #15
4C6F:  26 0E             bne      $4c7f ; $4C7F=loc_4C7F
4C71:  14 8D 20          bset     $8d, #32
4C74:  15 8D 40          bclr     $8d, #64
4C77:  20 06             bra      $4c7f ; $4C7F=loc_4C7F

loc_4C79:
4C79:  7F 21 6A          clr      $216a ; xrefs $4C63:branch
4C7C:  15 8D 20          bclr     $8d, #32

loc_4C7F:
4C7F:  B6 21 6A          ldaa     $216a ; xrefs $4C67:branch, $4C6F:branch, $4C77:branch
4C82:  81 1E             cmpa     #30
4C84:  24 05             bcc      $4c8b ; $4C8B=loc_4C8B
4C86:  7C 21 6A          inc      $216a
4C89:  20 12             bra      $4c9d ; $4C9D=loc_4C9D

loc_4C8B:
4C8B:  13 A9 02 0E       brclr    $a9, #2, $4c9d ; $00A9=operating_mode_flags, $4C9D=loc_4C9D | xrefs $4C84:branch
4C8F:  86 AA             ldaa     #-86
4C91:  B7 21 67          staa     $2167
4C94:  14 8D 04          bset     $8d, #4
4C97:  BD 4C 36          jsr      $4c36 ; $4C36=sub_4C36
4C9A:  15 8D 20          bclr     $8d, #32

loc_4C9D:
4C9D:  13 8C 02 18       brclr    $8c, #2, $4cb9 ; $4CB9=loc_4CB9 | xrefs $4C5B:branch, $4C5F:branch, $4C89:branch, $4C8B:branch
4CA1:  B6 21 64          ldaa     $2164
4CA4:  81 02             cmpa     #2
4CA6:  24 05             bcc      $4cad ; $4CAD=loc_4CAD
4CA8:  7C 21 64          inc      $2164
4CAB:  20 0C             bra      $4cb9 ; $4CB9=loc_4CB9

loc_4CAD:
4CAD:  7F 24 14          clr      $2414 ; xrefs $4CA6:branch
4CB0:  7F 23 EF          clr      $23ef
4CB3:  7F 21 64          clr      $2164
4CB6:  15 8C 02          bclr     $8c, #2

loc_4CB9:
4CB9:  13 8C 10 03       brclr    $8c, #16, $4cc0 ; $4CC0=loc_4CC0 | xrefs $4C9D:branch, $4CAB:branch
4CBD:  7E 4C E1          jmp      $4ce1 ; $4CE1=loc_4CE1

loc_4CC0:
4CC0:  13 8C 40 1A       brclr    $8c, #64, $4cde ; $4CDE=loc_4CDE | xrefs $4CB9:branch
4CC4:  B6 21 63          ldaa     $2163
4CC7:  81 02             cmpa     #2
4CC9:  24 05             bcc      $4cd0 ; $4CD0=loc_4CD0
4CCB:  7C 21 63          inc      $2163
4CCE:  20 0E             bra      $4cde ; $4CDE=loc_4CDE

loc_4CD0:
4CD0:  96 8B             ldaa     $8b ; xrefs $4CC9:branch
4CD2:  B7 21 67          staa     $2167
4CD5:  BD 4C 36          jsr      $4c36 ; $4C36=sub_4C36
4CD8:  15 8C 40          bclr     $8c, #64
4CDB:  7F 21 63          clr      $2163

loc_4CDE:
4CDE:  7E 4D 0D          jmp      $4d0d ; $4D0D=loc_4D0D | xrefs $4CC0:branch, $4CCE:branch

loc_4CE1:
4CE1:  FC 21 65          ldd      $2165 ; xrefs $4CBD:jump
4CE4:  1A 83 01 B9       cpd      #441
4CE8:  24 11             bcc      $4cfb ; $4CFB=loc_4CFB
4CEA:  CE 10 00          ldx      #4096
4CED:  1D 2D 04          bclr     45, x; #4
4CF0:  FC 21 65          ldd      $2165
4CF3:  C3 00 01          addd     #1
4CF6:  FD 21 65          std      $2165
4CF9:  20 12             bra      $4d0d ; $4D0D=loc_4D0D

loc_4CFB:
4CFB:  15 8C 10          bclr     $8c, #16 ; xrefs $4CE8:branch
4CFE:  CE 10 00          ldx      #4096
4D01:  1C 2D 04          bset     45, x; #4
4D04:  CC 00 00          ldd      #0
4D07:  FD 21 65          std      $2165
4D0A:  14 8D 40          bset     $8d, #64

loc_4D0D:
4D0D:  12 9C 01 0F       brset    $9c, #1, $4d20 ; $009C=scheduler_status_flags, $4D20=loc_4D20 | xrefs $4CDE:jump, $4CF9:branch
4D11:  96 8B             ldaa     $8b
4D13:  81 F0             cmpa     #-16
4D15:  27 09             beq      $4d20 ; $4D20=loc_4D20
4D17:  14 8D 80          bset     $8d, #-128
4D1A:  CE 10 00          ldx      #4096
4D1D:  1C 24 20          bset     36, x; #32

loc_4D20:
4D20:  39                rts       ; xrefs $4D0D:branch, $4D15:branch

sub_4D21:
4D21:  B6 21 68          ldaa     $2168 ; xrefs $96C3:call
4D24:  81 07             cmpa     #7
4D26:  25 0F             bcs      $4d37 ; $4D37=loc_4D37
4D28:  B6 21 67          ldaa     $2167
4D2B:  F6 10 2E          ldab     $102e ; $102E=SCSR
4D2E:  B7 10 2F          staa     $102f ; $102F=SCDR
4D31:  7C 21 69          inc      $2169
4D34:  7F 21 68          clr      $2168

loc_4D37:
4D37:  F6 21 69          ldab     $2169 ; xrefs $4D26:branch
4D3A:  C1 03             cmpb     #3
4D3C:  24 05             bcc      $4d43 ; $4D43=loc_4D43
4D3E:  7C 21 68          inc      $2168
4D41:  20 40             bra      $4d83 ; $4D83=loc_4D83

loc_4D43:
4D43:  CE 10 00          ldx      #4096 ; xrefs $4D3C:branch
4D46:  1F 2D 08 13       brclr    45, x; #8; $4d5d ; $4D5D=loc_4D5D
4D4A:  1F 2E 80 35       brclr    46, x; #-128; $4d83 ; $4D83=loc_4D83
4D4E:  F6 21 68          ldab     $2168
4D51:  C1 03             cmpb     #3
4D53:  24 05             bcc      $4d5a ; $4D5A=loc_4D5A
4D55:  7C 21 68          inc      $2168
4D58:  20 29             bra      $4d83 ; $4D83=loc_4D83

loc_4D5A:
4D5A:  1D 2D 08          bclr     45, x; #8 ; xrefs $4D53:branch

loc_4D5D:
4D5D:  1F 2E 40 22       brclr    46, x; #64; $4d83 ; $4D83=loc_4D83 | xrefs $4D46:branch
4D61:  15 8D 02          bclr     $8d, #2
4D64:  7F 21 69          clr      $2169
4D67:  7F 21 68          clr      $2168
4D6A:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
4D6D:  81 04             cmpa     #4
4D6F:  26 12             bne      $4d83 ; $4D83=loc_4D83
4D71:  86 FF             ldaa     #-1
4D73:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
4D76:  14 AF 01          bset     $af, #1
4D79:  13 8C 80 06       brclr    $8c, #-128, $4d83 ; $4D83=loc_4D83
4D7D:  15 8C 80          bclr     $8c, #-128
4D80:  1D 08 02          bclr     8, x; #2

loc_4D83:
4D83:  39                rts       ; xrefs $4D41:branch, $4D4A:branch, $4D58:branch, $4D5D:branch, $4D6F:branch, $4D79:branch

; ---- unreached/data gap $4D84-$4E0A ----

        .org $4E0B

sub_4E0B:
4E0B:  12 FC 01 03       brset    $fc, #1, $4e12 ; $4E12=loc_4E12 | xrefs $D698:call
4E0F:  7E 4E A2          jmp      $4ea2 ; $4EA2=loc_4EA2

loc_4E12:
4E12:  12 FC 10 16       brset    $fc, #16, $4e2c ; $4E2C=loc_4E2C | xrefs $4E0B:branch
4E16:  14 FC 10          bset     $fc, #16
4E19:  86 08             ldaa     #8
4E1B:  B7 25 77          staa     $2577
4E1E:  B7 21 A3          staa     $21a3
4E21:  86 80             ldaa     #-128
4E23:  B7 25 78          staa     $2578
4E26:  15 FC 01          bclr     $fc, #1
4E29:  7E 4E A2          jmp      $4ea2 ; $4EA2=loc_4EA2

loc_4E2C:
4E2C:  13 FC 08 12       brclr    $fc, #8, $4e42 ; $4E42=loc_4E42 | xrefs $4E12:branch
4E30:  96 8B             ldaa     $8b
4E32:  81 F0             cmpa     #-16
4E34:  26 06             bne      $4e3c ; $4E3C=loc_4E3C
4E36:  BD 4B 87          jsr      $4b87 ; $4B87=sub_4B87
4E39:  14 8C 80          bset     $8c, #-128

loc_4E3C:
4E3C:  B7 21 67          staa     $2167 ; xrefs $4E34:branch
4E3F:  BD 4C 36          jsr      $4c36 ; $4C36=sub_4C36

loc_4E42:
4E42:  15 FC 1C          bclr     $fc, #28 ; xrefs $4E2C:branch
4E45:  BD 4E A3          jsr      $4ea3 ; $4EA3=sub_4EA3
4E48:  12 FC 20 38       brset    $fc, #32, $4e84 ; $4E84=loc_4E84
4E4C:  BD 4B 87          jsr      $4b87 ; $4B87=sub_4B87
4E4F:  13 8D 80 09       brclr    $8d, #-128, $4e5c ; $4E5C=loc_4E5C
4E53:  B6 21 71          ldaa     $2171
4E56:  81 03             cmpa     #3
4E58:  26 0B             bne      $4e65 ; $4E65=loc_4E65
4E5A:  20 46             bra      $4ea2 ; $4EA2=loc_4EA2

loc_4E5C:
4E5C:  B6 21 70          ldaa     $2170 ; xrefs $4E4F:branch
4E5F:  81 03             cmpa     #3
4E61:  26 02             bne      $4e65 ; $4E65=loc_4E65
4E63:  20 3D             bra      $4ea2 ; $4EA2=loc_4EA2

loc_4E65:
4E65:  F6 21 6F          ldab     $216f ; xrefs $4E58:branch, $4E61:branch
4E68:  C1 0E             cmpb     #14
4E6A:  25 08             bcs      $4e74 ; $4E74=loc_4E74
4E6C:  7F 21 6F          clr      $216f
4E6F:  7F 21 6E          clr      $216e
4E72:  20 06             bra      $4e7a ; $4E7A=loc_4E7A

loc_4E74:
4E74:  F7 21 6E          stab     $216e ; xrefs $4E6A:branch
4E77:  7C 21 6E          inc      $216e

loc_4E7A:
4E7A:  86 0F             ldaa     #15 ; xrefs $4E72:branch
4E7C:  B7 21 73          staa     $2173
4E7F:  14 FC 24          bset     $fc, #36
4E82:  20 1E             bra      $4ea2 ; $4EA2=loc_4EA2

loc_4E84:
4E84:  12 FC 40 17       brset    $fc, #64, $4e9f ; $4E9F=loc_4E9F | xrefs $4E48:branch
4E88:  F6 21 6F          ldab     $216f
4E8B:  C1 0E             cmpb     #14
4E8D:  25 02             bcs      $4e91 ; $4E91=loc_4E91
4E8F:  C6 FF             ldab     #-1

loc_4E91:
4E91:  5C                incb      ; xrefs $4E8D:branch
4E92:  F7 21 73          stab     $2173
4E95:  C6 0F             ldab     #15
4E97:  F7 21 6E          stab     $216e
4E9A:  14 FC 44          bset     $fc, #68
4E9D:  20 03             bra      $4ea2 ; $4EA2=loc_4EA2

loc_4E9F:
4E9F:  15 FC 60          bclr     $fc, #96 ; xrefs $4E84:branch

loc_4EA2:
4EA2:  39                rts       ; xrefs $4E0F:jump, $4E29:jump, $4E5A:branch, $4E63:branch, $4E82:branch, $4E9D:branch

sub_4EA3:
4EA3:  C6 80             ldab     #-128 ; xrefs $4B63:call, $4E45:call
4EA5:  CE B6 7F          ldx      #-18817
4EA8:  A6 00             ldaa     0, x
4EAA:  3A                abx      
4EAB:  A1 00             cmpa     0, x
4EAD:  27 11             beq      $4ec0 ; $4EC0=loc_4EC0
4EAF:  3A                abx      
4EB0:  A1 00             cmpa     0, x
4EB2:  27 0C             beq      $4ec0 ; $4EC0=loc_4EC0
4EB4:  CE B6 FF          ldx      #-18689
4EB7:  A6 00             ldaa     0, x
4EB9:  3A                abx      
4EBA:  A1 00             cmpa     0, x
4EBC:  27 02             beq      $4ec0 ; $4EC0=loc_4EC0
4EBE:  20 04             bra      $4ec4 ; $4EC4=loc_4EC4

loc_4EC0:
4EC0:  81 0E             cmpa     #14 ; xrefs $4EAD:branch, $4EB2:branch, $4EBC:branch
4EC2:  23 05             bls      $4ec9 ; $4EC9=loc_4EC9

loc_4EC4:
4EC4:  7F 21 6F          clr      $216f ; xrefs $4EBE:branch
4EC7:  20 03             bra      $4ecc ; $4ECC=loc_4ECC

loc_4EC9:
4EC9:  B7 21 6F          staa     $216f ; xrefs $4EC2:branch

loc_4ECC:
4ECC:  39                rts       ; xrefs $4EC7:branch

sub_4ECD:
4ECD:  13 A9 02 1E       brclr    $a9, #2, $4eef ; $00A9=operating_mode_flags, $4EEF=loc_4EEF | xrefs $D3DF:call
4ED1:  CE 10 00          ldx      #4096
4ED4:  1E 2D 08 17       brset    45, x; #8; $4eef ; $4EEF=loc_4EEF
4ED8:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
4EDB:  81 FF             cmpa     #-1
4EDD:  26 10             bne      $4eef ; $4EEF=loc_4EEF
4EDF:  13 8D 04 0C       brclr    $8d, #4, $4eef ; $4EEF=loc_4EEF
4EE3:  12 8D 02 08       brset    $8d, #2, $4eef ; $4EEF=loc_4EEF
4EE7:  86 AA             ldaa     #-86
4EE9:  B7 21 67          staa     $2167
4EEC:  BD 4C 36          jsr      $4c36 ; $4C36=sub_4C36

loc_4EEF:
4EEF:  39                rts       ; xrefs $4ECD:branch, $4ED4:branch, $4EDD:branch, $4EDF:branch, $4EE3:branch

; ---- unreached/data gap $4EF0-$4F0F ----

        .org $4F10

; [STRONG] Initialize extended I/O/service hardware state and related RAM flags.
hardware_io_service_init:
4F10:  0F                sei       ; xrefs $AAD0:jump
4F11:  18 CE 10 00       ldy      #4096
4F15:  7F 00 83          clr      >$0083
4F18:  C6 40             ldab     #64
4F1A:  F7 10 26          stab     $1026
4F1D:  7F 10 22          clr      $1022
4F20:  7F 10 24          clr      $1024 ; $1024=TMSK2_or_status
4F23:  86 FB             ldaa     #-5
4F25:  B7 10 27          staa     $1027
4F28:  18 1C 21 26       bset     33, y; #38
4F2C:  18 6F 0C          clr      12, y
4F2F:  18 6F 20          clr      32, y
4F32:  B6 10 00          ldaa     $1000 ; $1000=PORTA
4F35:  84 97             anda     #-105
4F37:  8A 10             oraa     #16
4F39:  B7 10 00          staa     $1000 ; $1000=PORTA
4F3C:  86 80             ldaa     #-128
4F3E:  B7 10 50          staa     $1050
4F41:  B7 10 40          staa     $1040
4F44:  CC 00 00          ldd      #0
4F47:  DD 01             std      $01
4F49:  97 03             staa     $03
4F4B:  86 1F             ldaa     #31
4F4D:  CE 00 E0          ldx      #224

loc_4F50:
4F50:  A7 00             staa     0, x ; xrefs $4F56:branch
4F52:  08                inx      
4F53:  8C 00 F8          cpx      #248
4F56:  26 F8             bne      $4f50 ; $4F50=loc_4F50
4F58:  18 1D 2D 40       bclr     45, y; #64
4F5C:  C6 03             ldab     #3
4F5E:  F7 24 14          stab     $2414
4F61:  CC 00 00          ldd      #0
4F64:  B7 24 11          staa     $2411
4F67:  FD 21 00          std      $2100
4F6A:  18 1C 2D 20       bset     45, y; #32
4F6E:  BD BD EC          jsr      $bdec ; $BDEC=sub_BDEC
4F71:  86 89             ldaa     #-119
4F73:  97 00             staa     $00
4F75:  CE B7 80          ldx      #-18560
4F78:  A6 02             ldaa     2, x
4F7A:  81 AA             cmpa     #-86
4F7C:  27 44             beq      $4fc2 ; $4FC2=loc_4FC2
4F7E:  86 07             ldaa     #7
4F80:  B7 24 6D          staa     $246d
4F83:  CC 00 00          ldd      #0
4F86:  FD 24 72          std      $2472
4F89:  FD 24 76          std      $2476
4F8C:  B7 24 78          staa     $2478
4F8F:  CC AA 89          ldd      #-21879
4F92:  FD 24 74          std      $2474
4F95:  CE B7 80          ldx      #-18560
4F98:  FF 24 6E          stx      $246e
4F9B:  86 1A             ldaa     #26
4F9D:  B7 24 6B          staa     $246b

loc_4FA0:
4FA0:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E | xrefs $4FC0:branch
4FA3:  18 CE 10 00       ldy      #4096
4FA7:  FC 10 0E          ldd      $100e ; $100E=TCNT
4FAA:  C3 07 D0          addd     #2000
4FAD:  FD 10 1C          std      $101c ; $101C=TOC4
4FB0:  C6 10             ldab     #16
4FB2:  F7 10 23          stab     $1023 ; $1023=TFLG1

loc_4FB5:
4FB5:  18 1F 23 10 FB    brclr    35, y; #16; $4fb5 ; $4FB5=loc_4FB5 | xrefs $4FB5:branch
4FBA:  BD 54 B6          jsr      $54b6 ; $54B6=hardware_io_countdown_helper_54b6
4FBD:  7D 24 6B          tst      $246b
4FC0:  26 DE             bne      $4fa0 ; $4FA0=loc_4FA0

loc_4FC2:
4FC2:  CE B7 80          ldx      #-18560 ; xrefs $4F7C:branch
4FC5:  A6 01             ldaa     1, x
4FC7:  97 84             staa     $84
4FC9:  C6 A0             ldab     #-96
4FCB:  F7 10 25          stab     $1025 ; $1025=TFLG2
4FCE:  18 1C 24 80       bset     36, y; #-128
4FD2:  0E                cli      
4FD3:  FC 10 0E          ldd      $100e ; $100E=TCNT
4FD6:  C3 00 1E          addd     #30
4FD9:  FD 10 1C          std      $101c ; $101C=TOC4
4FDC:  C6 10             ldab     #16
4FDE:  F7 10 23          stab     $1023 ; $1023=TFLG1

; [STRONG] Timed I/O/service state machine using countdown/state at 0x246B and pointer/state data.
hardware_io_service_state_machine:
4FE1:  7D 24 6B          tst      $246b ; xrefs $503C:jump, $5067:jump
4FE4:  26 51             bne      $5037 ; $5037=loc_5037
4FE6:  FC 21 00          ldd      $2100
4FE9:  1A 83 08 F2       cpd      #2290
4FED:  26 37             bne      $5026 ; $5026=loc_5026
4FEF:  CE B7 80          ldx      #-18560
4FF2:  96 84             ldaa     $84
4FF4:  8B 05             adda     #5
4FF6:  97 84             staa     $84
4FF8:  81 3C             cmpa     #60
4FFA:  26 11             bne      $500d ; $500D=loc_500D
4FFC:  A6 00             ldaa     0, x
4FFE:  4C                inca     
4FFF:  C6 00             ldab     #0
5001:  D7 84             stab     $84
5003:  FD 24 72          std      $2472
5006:  FF 24 6E          stx      $246e
5009:  86 02             ldaa     #2
500B:  20 09             bra      $5016 ; $5016=loc_5016

loc_500D:
500D:  B7 24 72          staa     $2472 ; xrefs $4FFA:branch
5010:  08                inx      
5011:  FF 24 6E          stx      $246e
5014:  86 01             ldaa     #1

loc_5016:
5016:  B7 24 6D          staa     $246d ; xrefs $500B:branch
5019:  86 1A             ldaa     #26
501B:  B7 24 6B          staa     $246b
501E:  CC 00 00          ldd      #0
5021:  FD 21 00          std      $2100
5024:  20 11             bra      $5037 ; $5037=loc_5037

loc_5026:
5026:  96 89             ldaa     $89 ; xrefs $4FED:branch
5028:  85 02             bita     #2
502A:  27 0B             beq      $5037 ; $5037=loc_5037
502C:  7D 24 6B          tst      $246b
502F:  26 06             bne      $5037 ; $5037=loc_5037
5031:  BD 54 C8          jsr      $54c8 ; $54C8=hardware_io_bit_clear_helper
5034:  15 89 02          bclr     $89, #2

loc_5037:
5037:  18 1E 23 10 03    brset    35, y; #16; $503f ; $503F=loc_503F | xrefs $4FE4:branch, $5024:branch, $502A:branch, $502F:branch
503C:  7E 4F E1          jmp      $4fe1 ; $4FE1=hardware_io_service_state_machine

loc_503F:
503F:  FC 10 1C          ldd      $101c ; $101C=TOC4 | xrefs $5037:branch
5042:  C3 01 F4          addd     #500
5045:  FD 10 1C          std      $101c ; $101C=TOC4
5048:  C6 10             ldab     #16
504A:  F7 10 23          stab     $1023 ; $1023=TFLG1
504D:  BD 54 B6          jsr      $54b6 ; $54B6=hardware_io_countdown_helper_54b6
5050:  CE 4E F0          ldx      #20208
5053:  D6 83             ldab     $83
5055:  58                aslb     
5056:  3A                abx      
5057:  EE 00             ldx      0, x
5059:  AD 00             jsr      0, x
505B:  7C 00 83          inc      >$0083
505E:  D6 83             ldab     $83
5060:  C1 10             cmpb     #16
5062:  26 03             bne      $5067 ; $5067=loc_5067
5064:  7F 00 83          clr      >$0083

loc_5067:
5067:  7E 4F E1          jmp      $4fe1 ; $4FE1=hardware_io_service_state_machine | xrefs $5062:branch

; [STRONG] Scan extended I/O status registers and mirror individual bits into RAM flags.
hardware_io_scan_group_506a:
506A:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E
506D:  18 CE 10 00       ldy      #4096
5071:  B6 10 60          ldaa     $1060
5074:  CE 00 E7          ldx      #231
5077:  85 01             bita     #1
5079:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
507C:  CE 00 E9          ldx      #233
507F:  85 04             bita     #4
5081:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5084:  08                inx      
5085:  85 02             bita     #2
5087:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
508A:  08                inx      
508B:  85 08             bita     #8
508D:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5090:  08                inx      
5091:  85 10             bita     #16
5093:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5096:  B6 10 80          ldaa     $1080
5099:  CE 00 E0          ldx      #224
509C:  85 01             bita     #1
509E:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50A1:  08                inx      
50A2:  85 02             bita     #2
50A4:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50A7:  08                inx      
50A8:  85 04             bita     #4
50AA:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50AD:  08                inx      
50AE:  85 08             bita     #8
50B0:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50B3:  08                inx      
50B4:  85 10             bita     #16
50B6:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50B9:  08                inx      
50BA:  85 20             bita     #32
50BC:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50BF:  08                inx      
50C0:  85 40             bita     #64
50C2:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
50C5:  B6 10 00          ldaa     $1000 ; $1000=PORTA
50C8:  CE 00 ED          ldx      #237
50CB:  85 04             bita     #4
50CD:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
50D0:  86 1F             ldaa     #31
50D2:  97 F0             staa     $f0
50D4:  86 01             ldaa     #1
50D6:  B7 10 23          staa     $1023 ; $1023=TFLG1
50D9:  B6 10 40          ldaa     $1040
50DC:  84 87             anda     #-121
50DE:  8A 28             oraa     #40
50E0:  B7 10 40          staa     $1040
50E3:  B6 10 50          ldaa     $1050
50E6:  8A 10             oraa     #16
50E8:  B7 10 50          staa     $1050
50EB:  B6 10 50          ldaa     $1050
50EE:  8A 01             oraa     #1
50F0:  B7 10 50          staa     $1050
50F3:  39                rts      

; [STRONG] Extended I/O bit scan/update routine; contains byte 0x5100 as an instruction operand, not a table.
hardware_io_scan_group_50f4:
50F4:  B6 10 00          ldaa     $1000 ; $1000=PORTA | begin dense hardware-I/O scan cluster; 0x5100 is within this routine
50F7:  8A 20             oraa     #32
50F9:  B7 10 00          staa     $1000 ; $1000=PORTA
50FC:  B6 10 80          ldaa     $1080
50FF:  CE 00 E5          ldx      #229
5102:  85 20             bita     #32
5104:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5107:  96 89             ldaa     $89
5109:  CE 00 E6          ldx      #230
510C:  85 80             bita     #-128
510E:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5111:  15 89 80          bclr     $89, #-128
5114:  B6 10 60          ldaa     $1060
5117:  CE 00 E9          ldx      #233
511A:  85 04             bita     #4
511C:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
511F:  08                inx      
5120:  85 02             bita     #2
5122:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5125:  08                inx      
5126:  08                inx      
5127:  85 10             bita     #16
5129:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
512C:  B6 10 23          ldaa     $1023 ; $1023=TFLG1
512F:  CE 00 ED          ldx      #237
5132:  88 04             eora     #4
5134:  85 04             bita     #4
5136:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5139:  B6 10 21          ldaa     $1021
513C:  84 DF             anda     #-33
513E:  8A 10             oraa     #16
5140:  B7 10 21          staa     $1021
5143:  86 04             ldaa     #4
5145:  B7 10 23          staa     $1023 ; $1023=TFLG1
5148:  B6 10 50          ldaa     $1050
514B:  84 FE             anda     #-2
514D:  B7 10 50          staa     $1050
5150:  B6 10 60          ldaa     $1060
5153:  CE 00 E7          ldx      #231
5156:  85 01             bita     #1
5158:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
515B:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_515c:
515C:  18 CE 10 00       ldy      #4096
5160:  B6 10 80          ldaa     $1080
5163:  CE 00 E5          ldx      #229
5166:  85 20             bita     #32
5168:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
516B:  B6 10 60          ldaa     $1060
516E:  CE 00 E9          ldx      #233
5171:  85 04             bita     #4
5173:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5176:  08                inx      
5177:  85 02             bita     #2
5179:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
517C:  08                inx      
517D:  08                inx      
517E:  85 10             bita     #16
5180:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5183:  B6 10 23          ldaa     $1023 ; $1023=TFLG1
5186:  CE 00 ED          ldx      #237
5189:  85 04             bita     #4
518B:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
518E:  B6 10 21          ldaa     $1021
5191:  8A 20             oraa     #32
5193:  84 EF             anda     #-17
5195:  B7 10 21          staa     $1021
5198:  86 04             ldaa     #4
519A:  B7 10 23          staa     $1023 ; $1023=TFLG1
519D:  B6 10 00          ldaa     $1000 ; $1000=PORTA
51A0:  84 DF             anda     #-33
51A2:  B7 10 00          staa     $1000 ; $1000=PORTA
51A5:  86 02             ldaa     #2
51A7:  B7 10 23          staa     $1023 ; $1023=TFLG1
51AA:  18 1C 22 02       bset     34, y; #2
51AE:  B6 10 50          ldaa     $1050
51B1:  84 DF             anda     #-33
51B3:  B7 10 50          staa     $1050
51B6:  B6 10 00          ldaa     $1000 ; $1000=PORTA
51B9:  8A 40             oraa     #64
51BB:  B7 10 00          staa     $1000 ; $1000=PORTA
51BE:  FC 10 0E          ldd      $100e ; $100E=TCNT
51C1:  DD 85             std      $85
51C3:  B6 10 50          ldaa     $1050
51C6:  8A 04             oraa     #4
51C8:  B7 10 50          staa     $1050
51CB:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_51cc:
51CC:  B6 10 80          ldaa     $1080
51CF:  CE 00 E4          ldx      #228
51D2:  85 10             bita     #16
51D4:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
51D7:  B6 10 60          ldaa     $1060
51DA:  CE 00 E7          ldx      #231
51DD:  85 01             bita     #1
51DF:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
51E2:  B6 10 60          ldaa     $1060
51E5:  CE 00 EB          ldx      #235
51E8:  85 08             bita     #8
51EA:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
51ED:  86 10             ldaa     #16
51EF:  B7 10 30          staa     $1030 ; $1030=ADCTL
51F2:  B6 10 50          ldaa     $1050
51F5:  84 FB             anda     #-5
51F7:  B7 10 50          staa     $1050
51FA:  39                rts      

; [STRONG] Extended I/O bit scan/update routine; spans 0x5200 as executable instruction bytes.
hardware_io_scan_group_51fb:
51FB:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E | routine spans 0x5200 as instruction bytes
51FE:  18 CE 10 00       ldy      #4096
5202:  B6 10 80          ldaa     $1080
5205:  CE 00 E4          ldx      #228
5208:  85 10             bita     #16
520A:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
520D:  B6 10 60          ldaa     $1060
5210:  CE 00 EB          ldx      #235
5213:  85 08             bita     #8
5215:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5218:  BD 54 A3          jsr      $54a3 ; $54A3=hardware_io_flag_helper_54a3
521B:  B6 10 00          ldaa     $1000 ; $1000=PORTA
521E:  8A 08             oraa     #8
5220:  B7 10 00          staa     $1000 ; $1000=PORTA
5223:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5224:
5224:  B6 10 80          ldaa     $1080
5227:  CE 00 E3          ldx      #227
522A:  85 08             bita     #8
522C:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
522F:  B6 10 60          ldaa     $1060
5232:  CE 00 EB          ldx      #235
5235:  85 08             bita     #8
5237:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
523A:  B6 10 00          ldaa     $1000 ; $1000=PORTA
523D:  84 F7             anda     #-9
523F:  B7 10 00          staa     $1000 ; $1000=PORTA
5242:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5243:
5243:  B6 10 80          ldaa     $1080
5246:  CE 00 E3          ldx      #227
5249:  85 08             bita     #8
524B:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
524E:  B6 10 60          ldaa     $1060
5251:  CE 00 EB          ldx      #235
5254:  85 08             bita     #8
5256:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5259:  B6 10 23          ldaa     $1023 ; $1023=TFLG1
525C:  CE 00 E8          ldx      #232
525F:  85 02             bita     #2
5261:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5264:  CE 00 E8          ldx      #232
5267:  DC 87             ldd      $87
5269:  1A 83 00 32       cpd      #50
526D:  24 04             bcc      $5273 ; $5273=loc_5273
526F:  86 FF             ldaa     #-1
5271:  20 01             bra      $5274 ; $5274=loc_5274

loc_5273:
5273:  4F                clra      ; xrefs $526D:branch

loc_5274:
5274:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper | xrefs $5271:branch
5277:  CC 00 00          ldd      #0
527A:  DD 87             std      $87
527C:  BD 54 A3          jsr      $54a3 ; $54A3=hardware_io_flag_helper_54a3
527F:  B6 10 00          ldaa     $1000 ; $1000=PORTA
5282:  84 BF             anda     #-65
5284:  B7 10 00          staa     $1000 ; $1000=PORTA
5287:  B6 10 40          ldaa     $1040
528A:  8A 02             oraa     #2
528C:  B7 10 40          staa     $1040
528F:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5290:
5290:  B6 10 80          ldaa     $1080
5293:  CE 00 E1          ldx      #225
5296:  85 02             bita     #2
5298:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
529B:  B6 10 60          ldaa     $1060
529E:  CE 00 EB          ldx      #235
52A1:  85 08             bita     #8
52A3:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
52A6:  C6 1F             ldab     #31
52A8:  B6 10 32          ldaa     $1032 ; $1032=ADR2
52AB:  81 EA             cmpa     #-22
52AD:  24 06             bcc      $52b5 ; $52B5=loc_52B5
52AF:  81 80             cmpa     #-128
52B1:  25 02             bcs      $52b5 ; $52B5=loc_52B5
52B3:  D7 F1             stab     $f1

loc_52B5:
52B5:  B6 10 33          ldaa     $1033 ; $1033=ADR3 | xrefs $52AD:branch, $52B1:branch
52B8:  81 8C             cmpa     #-116
52BA:  24 06             bcc      $52c2 ; $52C2=loc_52C2
52BC:  81 72             cmpa     #114
52BE:  25 02             bcs      $52c2 ; $52C2=loc_52C2
52C0:  D7 F2             stab     $f2

loc_52C2:
52C2:  B6 10 34          ldaa     $1034 ; $1034=ADR4 | xrefs $52BA:branch, $52BE:branch
52C5:  81 8C             cmpa     #-116
52C7:  24 06             bcc      $52cf ; $52CF=loc_52CF
52C9:  81 72             cmpa     #114
52CB:  25 02             bcs      $52cf ; $52CF=loc_52CF
52CD:  D7 F3             stab     $f3

loc_52CF:
52CF:  86 14             ldaa     #20 ; xrefs $52C7:branch, $52CB:branch
52D1:  B7 10 30          staa     $1030 ; $1030=ADCTL
52D4:  B6 10 40          ldaa     $1040
52D7:  84 FD             anda     #-3
52D9:  B7 10 40          staa     $1040
52DC:  39                rts      

; [STRONG] Extended I/O configuration routine; spans 0x5300 as executable instruction bytes.
hardware_io_scan_group_52dd:
52DD:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E | routine spans 0x5300 as instruction bytes
52E0:  18 CE 10 00       ldy      #4096
52E4:  B6 10 80          ldaa     $1080
52E7:  CE 00 E1          ldx      #225
52EA:  85 02             bita     #2
52EC:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
52EF:  B6 10 60          ldaa     $1060
52F2:  CE 00 EB          ldx      #235
52F5:  85 08             bita     #8
52F7:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
52FA:  BD 54 A3          jsr      $54a3 ; $54A3=hardware_io_flag_helper_54a3
52FD:  B6 10 40          ldaa     $1040
5300:  8A 01             oraa     #1
5302:  B7 10 40          staa     $1040
5305:  B6 10 50          ldaa     $1050
5308:  84 EF             anda     #-17
530A:  B7 10 50          staa     $1050
530D:  B6 10 40          ldaa     $1040
5310:  84 87             anda     #-121
5312:  8A 50             oraa     #80
5314:  B7 10 40          staa     $1040
5317:  B6 10 50          ldaa     $1050
531A:  8A 10             oraa     #16
531C:  B7 10 50          staa     $1050
531F:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5320:
5320:  B6 10 00          ldaa     $1000 ; $1000=PORTA
5323:  8A 20             oraa     #32
5325:  B7 10 00          staa     $1000 ; $1000=PORTA
5328:  B6 10 80          ldaa     $1080
532B:  CE 00 E0          ldx      #224
532E:  85 01             bita     #1
5330:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5333:  96 89             ldaa     $89
5335:  CE 00 E6          ldx      #230
5338:  88 80             eora     #-128
533A:  85 80             bita     #-128
533C:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
533F:  15 89 80          bclr     $89, #-128
5342:  B6 10 60          ldaa     $1060
5345:  CE 00 EB          ldx      #235
5348:  85 08             bita     #8
534A:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
534D:  B6 10 40          ldaa     $1040
5350:  84 FE             anda     #-2
5352:  B7 10 40          staa     $1040
5355:  B6 10 60          ldaa     $1060
5358:  CE 00 E7          ldx      #231
535B:  85 01             bita     #1
535D:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5360:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5361:
5361:  B6 10 80          ldaa     $1080
5364:  CE 00 E0          ldx      #224
5367:  85 01             bita     #1
5369:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
536C:  B6 10 60          ldaa     $1060
536F:  CE 00 EB          ldx      #235
5372:  85 08             bita     #8
5374:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
5377:  BD 54 A3          jsr      $54a3 ; $54A3=hardware_io_flag_helper_54a3
537A:  B6 10 00          ldaa     $1000 ; $1000=PORTA
537D:  84 DF             anda     #-33
537F:  B7 10 00          staa     $1000 ; $1000=PORTA
5382:  B6 10 40          ldaa     $1040
5385:  8A 04             oraa     #4
5387:  B7 10 40          staa     $1040
538A:  86 02             ldaa     #2
538C:  B7 10 23          staa     $1023 ; $1023=TFLG1
538F:  18 1C 22 02       bset     34, y; #2
5393:  B6 10 50          ldaa     $1050
5396:  8A 20             oraa     #32
5398:  B7 10 50          staa     $1050
539B:  B6 10 00          ldaa     $1000 ; $1000=PORTA
539E:  8A 40             oraa     #64
53A0:  B7 10 00          staa     $1000 ; $1000=PORTA
53A3:  FC 10 0E          ldd      $100e ; $100E=TCNT
53A6:  DD 85             std      $85
53A8:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_53a9:
53A9:  B6 10 60          ldaa     $1060
53AC:  CE 00 E7          ldx      #231
53AF:  85 01             bita     #1
53B1:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
53B4:  B6 10 80          ldaa     $1080
53B7:  CE 00 E2          ldx      #226
53BA:  85 04             bita     #4
53BC:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
53BF:  B6 10 60          ldaa     $1060
53C2:  CE 00 EB          ldx      #235
53C5:  85 08             bita     #8
53C7:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
53CA:  C6 1F             ldab     #31
53CC:  B6 10 31          ldaa     $1031 ; $1031=ADR1
53CF:  81 8C             cmpa     #-116
53D1:  24 06             bcc      $53d9 ; $53D9=loc_53D9
53D3:  81 72             cmpa     #114
53D5:  25 02             bcs      $53d9 ; $53D9=loc_53D9
53D7:  D7 F4             stab     $f4

loc_53D9:
53D9:  B6 10 32          ldaa     $1032 ; $1032=ADR2 | xrefs $53D1:branch, $53D5:branch
53DC:  81 8C             cmpa     #-116
53DE:  24 06             bcc      $53e6 ; $53E6=loc_53E6
53E0:  81 72             cmpa     #114
53E2:  25 02             bcs      $53e6 ; $53E6=loc_53E6
53E4:  D7 F5             stab     $f5

loc_53E6:
53E6:  B6 10 33          ldaa     $1033 ; $1033=ADR3 | xrefs $53DE:branch, $53E2:branch
53E9:  81 FF             cmpa     #-1
53EB:  24 06             bcc      $53f3 ; $53F3=loc_53F3
53ED:  81 00             cmpa     #0
53EF:  25 02             bcs      $53f3 ; $53F3=loc_53F3
53F1:  D7 F6             stab     $f6

loc_53F3:
53F3:  B6 10 34          ldaa     $1034 ; $1034=ADR4 | xrefs $53EB:branch, $53EF:branch
53F6:  81 8C             cmpa     #-116
53F8:  24 06             bcc      $5400 ; $5400=loc_5400
53FA:  81 72             cmpa     #114
53FC:  25 02             bcs      $5400 ; $5400=loc_5400
53FE:  D7 F7             stab     $f7

loc_5400:
5400:  B6 10 40          ldaa     $1040 ; xrefs $53F8:branch, $53FC:branch
5403:  84 FB             anda     #-5
5405:  B7 10 40          staa     $1040
5408:  B6 10 50          ldaa     $1050
540B:  8A 01             oraa     #1
540D:  B7 10 50          staa     $1050
5410:  B6 10 50          ldaa     $1050
5413:  8A 02             oraa     #2
5415:  B7 10 50          staa     $1050
5418:  39                rts      

; [STRONG] Extended I/O bit scan/update routine.
hardware_io_scan_group_5419:
5419:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E
541C:  18 CE 10 00       ldy      #4096
5420:  B6 10 80          ldaa     $1080
5423:  CE 00 E2          ldx      #226
5426:  85 04             bita     #4
5428:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
542B:  B6 10 80          ldaa     $1080
542E:  CE 00 E5          ldx      #229
5431:  85 20             bita     #32
5433:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5436:  B6 10 60          ldaa     $1060
5439:  CE 00 E9          ldx      #233
543C:  85 04             bita     #4
543E:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5441:  08                inx      
5442:  85 02             bita     #2
5444:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5447:  08                inx      
5448:  08                inx      
5449:  85 10             bita     #16
544B:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
544E:  B6 10 50          ldaa     $1050
5451:  84 FD             anda     #-3
5453:  B7 10 50          staa     $1050
5456:  B6 10 50          ldaa     $1050
5459:  84 FE             anda     #-2
545B:  B7 10 50          staa     $1050
545E:  39                rts      

; [STRONG] Small extended I/O flag mirror routine.
hardware_io_scan_group_545f:
545F:  B6 10 80          ldaa     $1080
5462:  CE 00 E5          ldx      #229
5465:  85 20             bita     #32
5467:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
546A:  39                rts      

; [STRONG] Extended I/O service routine with port/control writes.
hardware_io_service_546b:
546B:  B6 10 23          ldaa     $1023 ; $1023=TFLG1
546E:  CE 00 EF          ldx      #239
5471:  85 02             bita     #2
5473:  BD 54 FE          jsr      $54fe ; $54FE=hardware_io_bit_update_helper
5476:  CE 00 EF          ldx      #239
5479:  DC 87             ldd      $87
547B:  1A 83 00 32       cpd      #50
547F:  24 04             bcc      $5485 ; $5485=loc_5485
5481:  86 FF             ldaa     #-1
5483:  20 01             bra      $5486 ; $5486=loc_5486

loc_5485:
5485:  4F                clra      ; xrefs $547F:branch

loc_5486:
5486:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper | xrefs $5483:branch
5489:  CC 00 00          ldd      #0
548C:  DD 87             std      $87
548E:  B6 10 00          ldaa     $1000 ; $1000=PORTA
5491:  84 BF             anda     #-65
5493:  B7 10 00          staa     $1000 ; $1000=PORTA
5496:  39                rts      

; [STRONG] Small extended I/O flag mirror routine.
hardware_io_scan_group_5497:
5497:  86 FB             ldaa     #-5
5499:  B7 10 27          staa     $1027
549C:  BD 55 11          jsr      $5511 ; $5511=sub_5511
549F:  BD 55 50          jsr      $5550 ; $5550=sub_5550
54A2:  39                rts      

; [STRONG] Update a RAM flag from a selected hardware/service bit.
hardware_io_flag_helper_54a3:
54A3:  B6 10 23          ldaa     $1023 ; $1023=TFLG1 | xrefs $5218:call, $527C:call, $52FA:call, $5377:call
54A6:  CE 00 EE          ldx      #238
54A9:  88 01             eora     #1
54AB:  85 01             bita     #1
54AD:  BD 54 EB          jsr      $54eb ; $54EB=hardware_io_bit_set_helper
54B0:  86 01             ldaa     #1
54B2:  B7 10 23          staa     $1023 ; $1023=TFLG1
54B5:  39                rts      

; [STRONG] Update service countdown/state.
hardware_io_countdown_helper_54b6:
54B6:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $4FBA:call, $504D:call
54B9:  81 05             cmpa     #5
54BB:  26 0A             bne      $54c7 ; $54C7=loc_54C7
54BD:  C6 55             ldab     #85
54BF:  F7 10 3A          stab     $103a ; $103A=COPRST
54C2:  C6 AA             ldab     #-86
54C4:  F7 10 3A          stab     $103a ; $103A=COPRST

loc_54C7:
54C7:  39                rts       ; xrefs $54BB:branch

; [CONFIRMED] Clear a selected RAM bit when the tested condition is false.
hardware_io_bit_clear_helper:
54C8:  86 03             ldaa     #3 ; xrefs $5031:call
54CA:  B7 24 6D          staa     $246d
54CD:  FC B7 84          ldd      $b784
54D0:  9A 01             oraa     $01
54D2:  DA 02             orab     $02
54D4:  FD 24 72          std      $2472
54D7:  B6 B7 86          ldaa     $b786
54DA:  9A 03             oraa     $03
54DC:  B7 24 74          staa     $2474
54DF:  CE B7 84          ldx      #-18556
54E2:  FF 24 6E          stx      $246e
54E5:  86 1A             ldaa     #26
54E7:  B7 24 6B          staa     $246b
54EA:  39                rts      

; [CONFIRMED] Set/clear selected RAM bit according to tested condition.
hardware_io_bit_set_helper:
54EB:  27 08             beq      $54f5 ; $54F5=loc_54F5 | xrefs $5079:call, $508D:call, $509E:call, $50A4:call, $50AA:call, $50B0:call, $50B6:call, $50BC:call, +24 more
54ED:  E6 00             ldab     0, x
54EF:  C4 7F             andb     #127
54F1:  E7 00             stab     0, x
54F3:  20 08             bra      $54fd ; $54FD=loc_54FD

loc_54F5:
54F5:  6D 00             tst      0, x ; xrefs $54EB:branch
54F7:  2B 04             bmi      $54fd ; $54FD=loc_54FD
54F9:  C6 1F             ldab     #31
54FB:  E7 00             stab     0, x

loc_54FD:
54FD:  39                rts       ; xrefs $54F3:branch, $54F7:branch

; [CONFIRMED] Update selected RAM bit according to tested condition.
hardware_io_bit_update_helper:
54FE:  26 08             bne      $5508 ; $5508=loc_5508 | xrefs $5081:call, $5087:call, $5093:call, $50C2:call, $5104:call, $5173:call, $5179:call, $5180:call, +18 more
5500:  E6 00             ldab     0, x
5502:  CA 80             orab     #-128
5504:  E7 00             stab     0, x
5506:  20 08             bra      $5510 ; $5510=loc_5510

loc_5508:
5508:  6D 00             tst      0, x ; xrefs $54FE:branch
550A:  2A 04             bpl      $5510 ; $5510=loc_5510
550C:  C6 1F             ldab     #31
550E:  E7 00             stab     0, x

loc_5510:
5510:  39                rts       ; xrefs $5506:branch, $550A:branch

sub_5511:
5511:  CE 00 00          ldx      #0 ; xrefs $549C:call

loc_5514:
5514:  A6 E0             ldaa     224, x ; xrefs $554D:branch
5516:  84 7F             anda     #127
5518:  27 04             beq      $551e ; $551E=loc_551E
551A:  6A E0             dec      224, x
551C:  20 2B             bra      $5549 ; $5549=loc_5549

loc_551E:
551E:  3C                pshx      ; xrefs $5518:branch
551F:  8F                xgdx     
5520:  C5 08             bitb     #8
5522:  26 09             bne      $552d ; $552D=loc_552D
5524:  C5 10             bitb     #16
5526:  26 0A             bne      $5532 ; $5532=loc_5532
5528:  CE 00 01          ldx      #1
552B:  20 08             bra      $5535 ; $5535=loc_5535

loc_552D:
552D:  CE 00 02          ldx      #2 ; xrefs $5522:branch
5530:  20 03             bra      $5535 ; $5535=loc_5535

loc_5532:
5532:  CE 00 03          ldx      #3 ; xrefs $5526:branch

loc_5535:
5535:  C4 07             andb     #7 ; xrefs $552B:branch, $5530:branch
5537:  4F                clra     
5538:  0D                sec      

loc_5539:
5539:  49                rola      ; xrefs $553B:branch
553A:  5A                decb     
553B:  2A FC             bpl      $5539 ; $5539=loc_5539
553D:  A5 00             bita     0, x
553F:  26 07             bne      $5548 ; $5548=loc_5548
5541:  AA 00             oraa     0, x
5543:  A7 00             staa     0, x
5545:  14 89 02          bset     $89, #2

loc_5548:
5548:  38                pulx      ; xrefs $553F:branch

loc_5549:
5549:  08                inx       ; xrefs $551C:branch
554A:  8C 00 18          cpx      #24
554D:  26 C5             bne      $5514 ; $5514=loc_5514
554F:  39                rts      

sub_5550:
5550:  13 89 01 0A       brclr    $89, #1, $555e ; $555E=loc_555E | xrefs $549F:call
5554:  CC 00 00          ldd      #0
5557:  DD 01             std      $01
5559:  97 03             staa     $03
555B:  15 89 01          bclr     $89, #1

loc_555E:
555E:  39                rts       ; xrefs $5550:branch

loc_555F:
555F:  86 08             ldaa     #8 ; xrefs $5841:jump
5561:  B7 10 23          staa     $1023 ; $1023=TFLG1
5564:  3B                rti      
5565:  18 CE 10 00       ldy      #4096
5569:  C6 20             ldab     #32
556B:  F7 10 23          stab     $1023 ; $1023=TFLG1
556E:  18 1D 22 20       bclr     34, y; #32
5572:  B6 10 2E          ldaa     $102e ; $102E=SCSR
5575:  F6 24 12          ldab     $2412
5578:  F7 10 2F          stab     $102f ; $102F=SCDR
557B:  18 1C 2D 40       bset     45, y; #64
557F:  B6 24 11          ldaa     $2411
5582:  26 0B             bne      $558f ; $558F=loc_558F
5584:  B6 24 12          ldaa     $2412
5587:  81 C3             cmpa     #-61
5589:  27 0C             beq      $5597 ; $5597=loc_5597
558B:  86 05             ldaa     #5
558D:  20 0D             bra      $559c ; $559C=loc_559C

loc_558F:
558F:  81 04             cmpa     #4 ; xrefs $5582:branch
5591:  27 07             beq      $559a ; $559A=loc_559A
5593:  86 06             ldaa     #6
5595:  20 05             bra      $559c ; $559C=loc_559C

loc_5597:
5597:  14 89 01          bset     $89, #1 ; xrefs $5589:branch

loc_559A:
559A:  86 07             ldaa     #7 ; xrefs $5591:branch

loc_559C:
559C:  B7 24 15          staa     $2415 ; xrefs $558D:branch, $5595:branch
559F:  3B                rti      

; ---- unreached/data gap $55A0-$55F7 ----

        .org $55F8

sub_55F8:
55F8:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index | xrefs $D593:call
55FB:  18 CE 86 36       ldy      #-31178
55FF:  7D 00 90          tst      >$0090
5602:  27 10             beq      $5614 ; $5614=loc_5614
5604:  7D 20 2D          tst      $202d
5607:  27 06             beq      $560f ; $560F=loc_560F
5609:  18 CE 86 3F       ldy      #-31169
560D:  20 09             bra      $5618 ; $5618=loc_5618

loc_560F:
560F:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $5607:branch
5612:  20 12             bra      $5626 ; $5626=loc_5626

loc_5614:
5614:  18 CE 86 48       ldy      #-31160 ; xrefs $5602:branch

loc_5618:
5618:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $560D:branch
561B:  13 B2 04 07       brclr    $b2, #4, $5626 ; $5626=loc_5626
561F:  BB 86 51          adda     $8651
5622:  24 02             bcc      $5626 ; $5626=loc_5626
5624:  86 FF             ldaa     #-1

loc_5626:
5626:  B7 20 A8          staa     $20a8 ; xrefs $5612:branch, $561B:branch, $5622:branch
5629:  39                rts      

sub_562A:
562A:  CE 21 77          ldx      #8567 ; xrefs $96B6:call
562D:  C6 06             ldab     #6

loc_562F:
562F:  6D 00             tst      0, x ; xrefs $5645:branch
5631:  27 0A             beq      $563d ; $563D=loc_563D
5633:  6A 01             dec      1, x
5635:  26 06             bne      $563d ; $563D=loc_563D
5637:  86 0A             ldaa     #10
5639:  A7 01             staa     1, x
563B:  6A 00             dec      0, x

loc_563D:
563D:  08                inx       ; xrefs $5631:branch, $5635:branch
563E:  08                inx      
563F:  8C 21 81          cpx      #8577
5642:  27 05             beq      $5649 ; $5649=loc_5649

loc_5644:
5644:  5A                decb      ; xrefs $564F:branch
5645:  26 E8             bne      $562f ; $562F=loc_562F

loc_5647:
5647:  20 08             bra      $5651 ; $5651=loc_5651 | xrefs $564D:branch

loc_5649:
5649:  B6 24 EC          ldaa     $24ec ; xrefs $5642:branch
564C:  4D                tsta     
564D:  26 F8             bne      $5647 ; $5647=loc_5647
564F:  20 F3             bra      $5644 ; $5644=loc_5644

loc_5651:
5651:  39                rts       ; xrefs $5647:branch

; [OPEN] Reset-time mode/control initialization; exact physical role remains open.
mode_control_init_5652:
5652:  86 FF             ldaa     #-1 ; xrefs $B919:call
5654:  B7 24 EC          staa     $24ec
5657:  B7 21 81          staa     $2181
565A:  CC 00 04          ldd      #4
565D:  FD 21 83          std      $2183

loc_5660:
5660:  BD 57 92          jsr      $5792 ; $5792=sub_5792 | xrefs $568F:branch, $569F:branch
5663:  CC 00 0A          ldd      #10
5666:  FD 21 7F          std      $217f
5669:  FD 21 77          std      $2177
566C:  B7 20 97          staa     $2097
566F:  15 B2 37          bclr     $b2, #55
5672:  CE 10 00          ldx      #4096
5675:  1C 40 02          bset     64, x; #2
5678:  39                rts      

sub_5679:
5679:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $D590:call
567C:  81 0C             cmpa     #12
567E:  26 05             bne      $5685 ; $5685=loc_5685
5680:  BD 97 47          jsr      $9747 ; $9747=sub_9747
5683:  20 75             bra      $56fa ; $56FA=loc_56FA

loc_5685:
5685:  B6 20 90          ldaa     $2090 ; xrefs $567E:branch
5688:  81 03             cmpa     #3
568A:  27 15             beq      $56a1 ; $56A1=loc_56A1
568C:  B6 21 81          ldaa     $2181
568F:  26 CF             bne      $5660 ; $5660=loc_5660
5691:  B6 00 CA          ldaa     >$00ca
5694:  B1 86 63          cmpa     $8663
5697:  25 08             bcs      $56a1 ; $56A1=loc_56A1
5699:  B6 00 CB          ldaa     >$00cb
569C:  B1 86 64          cmpa     $8664
569F:  24 BF             bcc      $5660 ; $5660=loc_5660

loc_56A1:
56A1:  8D 58             bsr      $56fb ; $56FB=sub_56FB | xrefs $568A:branch, $5697:branch
56A3:  13 B2 04 3A       brclr    $b2, #4, $56e1 ; $56E1=loc_56E1
56A7:  B6 86 60          ldaa     $8660
56AA:  7D 00 90          tst      >$0090
56AD:  27 08             beq      $56b7 ; $56B7=loc_56B7
56AF:  7D 20 2D          tst      $202d
56B2:  26 03             bne      $56b7 ; $56B7=loc_56B7
56B4:  B6 86 5D          ldaa     $865d

loc_56B7:
56B7:  B7 21 74          staa     $2174 ; xrefs $56AD:branch, $56B2:branch
56BA:  B6 20 A4          ldaa     $20a4
56BD:  91 5D             cmpa     $5d
56BF:  26 0C             bne      $56cd ; $56CD=loc_56CD
56C1:  B6 21 76          ldaa     $2176
56C4:  B0 86 5C          suba     $865c
56C7:  24 01             bcc      $56ca ; $56CA=loc_56CA
56C9:  4F                clra     

loc_56CA:
56CA:  B7 21 76          staa     $2176 ; xrefs $56C7:branch

loc_56CD:
56CD:  13 B2 20 13       brclr    $b2, #32, $56e4 ; $56E4=loc_56E4 | xrefs $56BF:branch
56D1:  CE 10 00          ldx      #4096
56D4:  1E 40 02 04       brset    64, x; #2; $56dc ; $56DC=loc_56DC
56D8:  8D 67             bsr      $5741 ; $5741=sub_5741
56DA:  20 0B             bra      $56e7 ; $56E7=loc_56E7

loc_56DC:
56DC:  BD 57 C0          jsr      $57c0 ; $57C0=sub_57C0 | xrefs $56D4:branch
56DF:  20 06             bra      $56e7 ; $56E7=loc_56E7

loc_56E1:
56E1:  7F 21 74          clr      $2174 ; xrefs $56A3:branch

loc_56E4:
56E4:  BD 57 92          jsr      $5792 ; $5792=sub_5792 | xrefs $56CD:branch

loc_56E7:
56E7:  B6 21 74          ldaa     $2174 ; xrefs $56DA:branch, $56DF:branch
56EA:  F6 21 75          ldab     $2175
56ED:  1B                aba      
56EE:  25 05             bcs      $56f5 ; $56F5=loc_56F5
56F0:  BB 21 76          adda     $2176
56F3:  24 02             bcc      $56f7 ; $56F7=loc_56F7

loc_56F5:
56F5:  96 FF             ldaa     $ff ; xrefs $56EE:branch

loc_56F7:
56F7:  B7 20 97          staa     $2097 ; xrefs $56F3:branch

loc_56FA:
56FA:  39                rts       ; xrefs $5683:branch

sub_56FB:
56FB:  8D 22             bsr      $571f ; $571F=sub_571F | xrefs $56A1:call
56FD:  CE 10 00          ldx      #4096
5700:  1E 60 08 0E       brset    96, x; #8; $5712 ; $5712=loc_5712
5704:  13 B2 02 05       brclr    $b2, #2, $570d ; $570D=loc_570D
5708:  14 B2 04          bset     $b2, #4
570B:  20 11             bra      $571e ; $571E=loc_571E

loc_570D:
570D:  14 B2 02          bset     $b2, #2 ; xrefs $5704:branch
5710:  20 0C             bra      $571e ; $571E=loc_571E

loc_5712:
5712:  12 B2 02 05       brset    $b2, #2, $571b ; $571B=loc_571B | xrefs $5700:branch
5716:  15 B2 04          bclr     $b2, #4
5719:  20 03             bra      $571e ; $571E=loc_571E

loc_571B:
571B:  15 B2 02          bclr     $b2, #2 ; xrefs $5712:branch

loc_571E:
571E:  39                rts       ; xrefs $570B:branch, $5710:branch, $5719:branch

sub_571F:
571F:  CE 10 00          ldx      #4096 ; xrefs $56FB:call
5722:  1E 60 10 0E       brset    96, x; #16; $5734 ; $5734=loc_5734
5726:  13 B2 10 05       brclr    $b2, #16, $572f ; $572F=loc_572F
572A:  14 B2 20          bset     $b2, #32
572D:  20 11             bra      $5740 ; $5740=loc_5740

loc_572F:
572F:  14 B2 10          bset     $b2, #16 ; xrefs $5726:branch
5732:  20 0C             bra      $5740 ; $5740=loc_5740

loc_5734:
5734:  12 B2 10 05       brset    $b2, #16, $573d ; $573D=loc_573D | xrefs $5722:branch
5738:  15 B2 20          bclr     $b2, #32
573B:  20 03             bra      $5740 ; $5740=loc_5740

loc_573D:
573D:  15 B2 10          bclr     $b2, #16 ; xrefs $5734:branch

loc_5740:
5740:  39                rts       ; xrefs $572D:branch, $5732:branch, $573B:branch

sub_5741:
5741:  B6 86 5B          ldaa     $865b ; xrefs $56D8:call
5744:  27 04             beq      $574a ; $574A=loc_574A
5746:  12 A9 80 22       brset    $a9, #-128, $576c ; $00A9=operating_mode_flags, $576C=loc_576C

loc_574A:
574A:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte | xrefs $5744:branch
574C:  B1 86 65          cmpa     $8665
574F:  22 1B             bhi      $576c ; $576C=loc_576C
5751:  8D 61             bsr      $57b4 ; $57B4=sub_57B4
5753:  23 3C             bls      $5791 ; $5791=loc_5791
5755:  15 B2 01          bclr     $b2, #1
5758:  FC 20 42          ldd      $2042 ; $2042=transient_helper_axis
575B:  18 CE 86 52       ldy      #-31150
575F:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
5762:  B7 21 0E          staa     $210e
5765:  B1 00 D3          cmpa     >$00d3
5768:  22 02             bhi      $576c ; $576C=loc_576C
576A:  20 25             bra      $5791 ; $5791=loc_5791

loc_576C:
576C:  12 B2 01 21       brset    $b2, #1, $5791 ; $5791=loc_5791 | xrefs $5746:branch, $574F:branch, $5768:branch
5770:  7D 21 83          tst      $2183
5773:  26 1C             bne      $5791 ; $5791=loc_5791
5775:  7D 21 77          tst      $2177
5778:  26 17             bne      $5791 ; $5791=loc_5791
577A:  8D 16             bsr      $5792 ; $5792=sub_5792
577C:  14 B2 01          bset     $b2, #1
577F:  B6 86 68          ldaa     $8668
5782:  F6 86 69          ldab     $8669
5785:  B7 21 79          staa     $2179
5788:  F7 21 7B          stab     $217b
578B:  B6 86 6D          ldaa     $866d
578E:  B7 21 83          staa     $2183

loc_5791:
5791:  39                rts       ; xrefs $5753:branch, $576A:branch, $576C:branch, $5773:branch, $5778:branch

sub_5792:
5792:  CC 00 00          ldd      #0 ; xrefs $5660:call, $56E4:call, $577A:call
5795:  FD 21 75          std      $2175
5798:  15 B2 C0          bclr     $b2, #-64
579B:  CC 00 0A          ldd      #10
579E:  FD 21 79          std      $2179
57A1:  FD 21 7B          std      $217b
57A4:  FD 21 7D          std      $217d
57A7:  CC 00 05          ldd      #5
57AA:  FD 21 83          std      $2183
57AD:  CE 10 00          ldx      #4096
57B0:  1C 40 02          bset     64, x; #2
57B3:  39                rts      

sub_57B4:
57B4:  B6 86 65          ldaa     $8665 ; xrefs $5751:call, $57D2:call
57B7:  B0 86 66          suba     $8666
57BA:  24 01             bcc      $57bd ; $57BD=loc_57BD
57BC:  4F                clra     

loc_57BD:
57BD:  91 D0             cmpa     $d0 ; $00D0=load_aircharge_byte | xrefs $57BA:branch
57BF:  39                rts      

sub_57C0:
57C0:  12 B2 40 28       brset    $b2, #64, $57ec ; $57EC=loc_57EC | xrefs $56DC:call
57C4:  7D 21 7B          tst      $217b
57C7:  27 2F             beq      $57f8 ; $57F8=loc_57F8
57C9:  B6 86 5B          ldaa     $865b
57CC:  27 04             beq      $57d2 ; $57D2=loc_57D2
57CE:  12 A9 80 18       brset    $a9, #-128, $57ea ; $00A9=operating_mode_flags, $57EA=loc_57EA

loc_57D2:
57D2:  8D E0             bsr      $57b4 ; $57B4=sub_57B4 | xrefs $57CC:branch
57D4:  23 14             bls      $57ea ; $57EA=loc_57EA
57D6:  B6 21 0E          ldaa     $210e
57D9:  B1 00 D3          cmpa     >$00d3
57DC:  22 0C             bhi      $57ea ; $57EA=loc_57EA
57DE:  14 B2 40          bset     $b2, #64
57E1:  15 B2 01          bclr     $b2, #1
57E4:  B6 86 6A          ldaa     $866a
57E7:  B7 21 7D          staa     $217d

loc_57EA:
57EA:  20 3B             bra      $5827 ; $5827=loc_5827 | xrefs $57CE:branch, $57D4:branch, $57DC:branch, $57F6:branch

loc_57EC:
57EC:  12 B2 80 26       brset    $b2, #-128, $5816 ; $5816=loc_5816 | xrefs $57C0:branch
57F0:  B6 21 7D          ldaa     $217d
57F3:  BA 21 79          oraa     $2179
57F6:  26 F2             bne      $57ea ; $57EA=loc_57EA

loc_57F8:
57F8:  14 B2 C0          bset     $b2, #-64 ; xrefs $57C7:branch
57FB:  B6 86 6B          ldaa     $866b
57FE:  B7 21 7F          staa     $217f
5801:  FC 86 61          ldd      $8661
5804:  7D 00 90          tst      >$0090
5807:  27 08             beq      $5811 ; $5811=loc_5811
5809:  7D 20 2D          tst      $202d
580C:  26 03             bne      $5811 ; $5811=loc_5811
580E:  FC 86 5E          ldd      $865e

loc_5811:
5811:  FD 21 75          std      $2175 ; xrefs $5807:branch, $580C:branch
5814:  20 11             bra      $5827 ; $5827=loc_5827

loc_5816:
5816:  7D 21 7F          tst      $217f ; xrefs $57EC:branch
5819:  26 0C             bne      $5827 ; $5827=loc_5827
581B:  B6 86 67          ldaa     $8667
581E:  B7 21 77          staa     $2177
5821:  CE 10 00          ldx      #4096
5824:  1D 40 02          bclr     64, x; #2

loc_5827:
5827:  39                rts       ; xrefs $57EA:branch, $5814:branch, $5819:branch

; [OPEN] Periodic input/state processing call.
runtime_input_processing_5828:
5828:  CE 21 83          ldx      #8579 ; xrefs $D379:call
582B:  6D 00             tst      0, x
582D:  27 0A             beq      $5839 ; $5839=loc_5839
582F:  6A 01             dec      1, x
5831:  26 06             bne      $5839 ; $5839=loc_5839
5833:  86 04             ldaa     #4
5835:  A7 01             staa     1, x
5837:  6A 00             dec      0, x

loc_5839:
5839:  39                rts       ; xrefs $582D:branch, $5831:branch
583A:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
583D:  81 05             cmpa     #5
583F:  26 03             bne      $5844 ; $5844=loc_5844
5841:  7E 55 5F          jmp      $555f ; $555F=loc_555F

loc_5844:
5844:  CE 10 00          ldx      #4096 ; xrefs $583F:branch
5847:  1D 22 08          bclr     34, x; #8
584A:  1F 80 20 05       brclr    128, x; #32; $5853 ; $5853=loc_5853
584E:  15 9C 02          bclr     $9c, #2 ; $009C=scheduler_status_flags
5851:  20 03             bra      $5856 ; $5856=loc_5856

loc_5853:
5853:  14 9C 02          bset     $9c, #2 ; $009C=scheduler_status_flags | xrefs $584A:branch

loc_5856:
5856:  1C 00 08          bset     0, x; #8 ; xrefs $5851:branch
5859:  1C 50 01          bset     80, x; #1
585C:  01                nop      
585D:  01                nop      
585E:  01                nop      
585F:  01                nop      
5860:  01                nop      
5861:  01                nop      
5862:  01                nop      
5863:  1E 80 20 08       brset    128, x; #32; $586f ; $586F=loc_586F
5867:  14 45 01          bset     $45, #1
586A:  15 45 02          bclr     $45, #2
586D:  20 06             bra      $5875 ; $5875=loc_5875

loc_586F:
586F:  14 45 02          bset     $45, #2 ; xrefs $5863:branch
5872:  15 45 01          bclr     $45, #1

loc_5875:
5875:  3B                rti       ; xrefs $586D:branch

; ---- unreached/data gap $5876-$5876 ----

        .org $5877

sub_5877:
5877:  0F                sei       ; xrefs $773D:call
5878:  CC 01 F4          ldd      #500
587B:  D3 B8             addd     $b8 ; $00B8=previous_capture_or_schedule_base
587D:  FD 10 1E          std      $101e
5880:  FC 10 0E          ldd      $100e ; $100E=TCNT
5883:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
5885:  C3 00 19          addd     #25
5888:  1A 83 01 F4       cpd      #500
588C:  24 05             bcc      $5893 ; $5893=loc_5893
588E:  86 08             ldaa     #8
5890:  B7 10 23          staa     $1023 ; $1023=TFLG1

loc_5893:
5893:  CE 10 00          ldx      #4096 ; xrefs $588C:branch
5896:  1C 22 08          bset     34, x; #8
5899:  0E                cli      
589A:  39                rts      

; ---- unreached/data gap $589B-$589B ----

        .org $589C

sub_589C:
589C:  8F                xgdx      ; xrefs $703E:call, $71BA:call
589D:  B6 87 9B          ldaa     $879b
58A0:  81 01             cmpa     #1
58A2:  26 11             bne      $58b5 ; $58B5=loc_58B5
58A4:  8F                xgdx     
58A5:  F3 21 04          addd     $2104
58A8:  FD 21 04          std      $2104
58AB:  FC 21 02          ldd      $2102
58AE:  C9 00             adcb     #0
58B0:  89 00             adca     #0
58B2:  FD 21 02          std      $2102

loc_58B5:
58B5:  39                rts       ; xrefs $58A2:branch

; ---- unreached/data gap $58B6-$58B6 ----

        .org $58B7

sub_58B7:
58B7:  FC 20 65          ldd      $2065 ; xrefs $96C6:call
58BA:  85 F0             bita     #-16
58BC:  27 04             beq      $58c2 ; $58C2=loc_58C2
58BE:  86 FF             ldaa     #-1
58C0:  20 04             bra      $58c6 ; $58C6=loc_58C6

loc_58C2:
58C2:  05                asld      ; xrefs $58BC:branch
58C3:  05                asld     
58C4:  05                asld     
58C5:  05                asld     

loc_58C6:
58C6:  B7 20 FD          staa     $20fd ; xrefs $58C0:branch
58C9:  DC C7             ldd      $c7
58CB:  85 F0             bita     #-16
58CD:  27 04             beq      $58d3 ; $58D3=loc_58D3
58CF:  86 FF             ldaa     #-1
58D1:  20 04             bra      $58d7 ; $58D7=loc_58D7

loc_58D3:
58D3:  05                asld      ; xrefs $58CD:branch
58D4:  05                asld     
58D5:  05                asld     
58D6:  05                asld     

loc_58D7:
58D7:  B7 20 FE          staa     $20fe ; xrefs $58D1:branch
58DA:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator
58DC:  85 E0             bita     #-32
58DE:  27 04             beq      $58e4 ; $58E4=loc_58E4
58E0:  86 FF             ldaa     #-1
58E2:  20 03             bra      $58e7 ; $58E7=loc_58E7

loc_58E4:
58E4:  05                asld      ; xrefs $58DE:branch
58E5:  05                asld     
58E6:  05                asld     

loc_58E7:
58E7:  B7 20 FF          staa     $20ff ; xrefs $58E2:branch
58EA:  BD 63 44          jsr      $6344 ; $6344=load_aircharge_model
58ED:  F7 21 0F          stab     $210f
58F0:  39                rts      

; ---- unreached/data gap $58F1-$58F1 ----

        .org $58F2

sub_58F2:
58F2:  A6 00             ldaa     0, x ; xrefs $5A6C:call, $5B68:call, $5C67:call, $5D4C:call, $5E45:call, $5EDB:call, $5F64:call, $5FCC:call, +10 more
58F4:  85 FC             bita     #-4
58F6:  27 10             beq      $5908 ; $5908=loc_5908
58F8:  E6 01             ldab     1, x
58FA:  85 40             bita     #64
58FC:  26 6E             bne      $596c ; $596C=loc_596C
58FE:  85 10             bita     #16
5900:  26 57             bne      $5959 ; $5959=loc_5959
5902:  85 80             bita     #-128
5904:  26 5D             bne      $5963 ; $5963=loc_5963
5906:  20 0B             bra      $5913 ; $5913=loc_5913

loc_5908:
5908:  85 01             bita     #1 ; xrefs $58F6:branch
590A:  27 74             beq      $5980 ; $5980=loc_5980
590C:  8A 04             oraa     #4
590E:  18 E6 00          ldab     0, y
5911:  20 69             bra      $597c ; $597C=loc_597C

loc_5913:
5913:  7D 00 95          tst      >$0095 ; xrefs $5906:branch
5916:  26 2F             bne      $5947 ; $5947=loc_5947
5918:  85 01             bita     #1
591A:  27 21             beq      $593d ; $593D=loc_593D
591C:  18 E1 01          cmpb     1, y
591F:  24 05             bcc      $5926 ; $5926=loc_5926
5921:  18 EB 00          addb     0, y
5924:  20 58             bra      $597e ; $597E=loc_597E

loc_5926:
5926:  85 08             bita     #8 ; xrefs $591F:branch
5928:  26 0A             bne      $5934 ; $5934=loc_5934
592A:  84 FB             anda     #-5
592C:  8A 10             oraa     #16
592E:  C6 04             ldab     #4
5930:  E7 02             stab     2, x
5932:  20 04             bra      $5938 ; $5938=loc_5938

loc_5934:
5934:  84 F7             anda     #-9 ; xrefs $5928:branch
5936:  8A 80             oraa     #-128

loc_5938:
5938:  18 E6 02          ldab     2, y ; xrefs $5932:branch
593B:  20 3F             bra      $597c ; $597C=loc_597C

loc_593D:
593D:  5D                tstb      ; xrefs $591A:branch, $5965:branch
593E:  27 07             beq      $5947 ; $5947=loc_5947
5940:  C1 FF             cmpb     #-1
5942:  27 3C             beq      $5980 ; $5980=loc_5980
5944:  5A                decb     
5945:  20 37             bra      $597e ; $597E=loc_597E

loc_5947:
5947:  85 88             bita     #-120 ; xrefs $5916:branch, $593E:branch
5949:  26 05             bne      $5950 ; $5950=loc_5950

loc_594B:
594B:  84 AB             anda     #-85 ; xrefs $5971:branch
594D:  5F                clrb     
594E:  20 2C             bra      $597c ; $597C=loc_597C

loc_5950:
5950:  84 77             anda     #119 ; xrefs $5949:branch
5952:  8A 40             oraa     #64
5954:  F6 91 30          ldab     $9130
5957:  20 23             bra      $597c ; $597C=loc_597C

loc_5959:
5959:  6D 02             tst      2, x ; xrefs $5900:branch
595B:  26 06             bne      $5963 ; $5963=loc_5963
595D:  84 EF             anda     #-17
595F:  8A 80             oraa     #-128
5961:  20 19             bra      $597c ; $597C=loc_597C

loc_5963:
5963:  85 02             bita     #2 ; xrefs $5904:branch, $595B:branch
5965:  26 D6             bne      $593d ; $593D=loc_593D
5967:  18 E6 02          ldab     2, y
596A:  20 12             bra      $597e ; $597E=loc_597E

loc_596C:
596C:  85 01             bita     #1 ; xrefs $58FC:branch
596E:  26 05             bne      $5975 ; $5975=loc_5975
5970:  5D                tstb     
5971:  27 D8             beq      $594b ; $594B=loc_594B
5973:  20 0B             bra      $5980 ; $5980=loc_5980

loc_5975:
5975:  84 BF             anda     #-65 ; xrefs $596E:branch
5977:  8A 08             oraa     #8
5979:  18 E6 00          ldab     0, y

loc_597C:
597C:  A7 00             staa     0, x ; xrefs $5911:branch, $593B:branch, $594E:branch, $5957:branch, $5961:branch

loc_597E:
597E:  E7 01             stab     1, x ; xrefs $5924:branch, $5945:branch, $596A:branch

loc_5980:
5980:  39                rts       ; xrefs $590A:branch, $5942:branch, $5973:branch

; ---- unreached/data gap $5981-$5981 ----

        .org $5982

sub_5982:
5982:  CE 55 A0          ldx      #21920 ; xrefs $5A74:call, $5B70:call, $5C6F:call, $5D54:call, $5E4F:call, $5EE3:call, $5F6C:call, $5FD7:call, +10 more
5985:  3A                abx      
5986:  49                rola     
5987:  24 04             bcc      $598d ; $598D=loc_598D
5989:  86 80             ldaa     #-128
598B:  20 0A             bra      $5997 ; $5997=loc_5997

loc_598D:
598D:  49                rola      ; xrefs $5987:branch
598E:  25 06             bcs      $5996 ; $5996=loc_5996
5990:  49                rola     
5991:  49                rola     
5992:  25 02             bcs      $5996 ; $5996=loc_5996
5994:  2A 08             bpl      $599e ; $599E=loc_599E

loc_5996:
5996:  4F                clra      ; xrefs $598E:branch, $5992:branch

loc_5997:
5997:  AA 00             oraa     0, x ; xrefs $598B:branch
5999:  BD 59 A8          jsr      $59a8 ; $59A8=sub_59A8
599C:  20 05             bra      $59a3 ; $59A3=loc_59A3

loc_599E:
599E:  A6 00             ldaa     0, x ; xrefs $5994:branch
59A0:  BD 59 CA          jsr      $59ca ; $59CA=sub_59CA

loc_59A3:
59A3:  BD 59 F4          jsr      $59f4 ; $59F4=sub_59F4 | xrefs $599C:branch
59A6:  39                rts      

; ---- unreached/data gap $59A7-$59A7 ----

        .org $59A8

sub_59A8:
59A8:  CE 00 4B          ldx      #75 ; xrefs $5999:call
59AB:  36                psha     
59AC:  E6 00             ldab     0, x
59AE:  27 15             beq      $59c5 ; $59C5=loc_59C5
59B0:  84 7F             anda     #127

loc_59B2:
59B2:  E6 00             ldab     0, x ; xrefs $59BC:branch
59B4:  C4 7F             andb     #127
59B6:  11                cba      
59B7:  27 0C             beq      $59c5 ; $59C5=loc_59C5
59B9:  08                inx      
59BA:  9C 5B             cpx      $5b
59BC:  23 F4             bls      $59b2 ; $59B2=loc_59B2
59BE:  8C 00 5A          cpx      #90
59C1:  22 05             bhi      $59c8 ; $59C8=loc_59C8
59C3:  DF 5B             stx      $5b

loc_59C5:
59C5:  32                pula      ; xrefs $59AE:branch, $59B7:branch
59C6:  A7 00             staa     0, x

loc_59C8:
59C8:  39                rts       ; xrefs $59C1:branch

; ---- unreached/data gap $59C9-$59C9 ----

        .org $59CA

sub_59CA:
59CA:  DE 5B             ldx      $5b ; xrefs $59A0:call
59CC:  E6 00             ldab     0, x
59CE:  27 22             beq      $59f2 ; $59F2=loc_59F2

loc_59D0:
59D0:  E6 00             ldab     0, x ; xrefs $59F0:branch
59D2:  C4 7F             andb     #127
59D4:  11                cba      
59D5:  26 15             bne      $59ec ; $59EC=loc_59EC

loc_59D7:
59D7:  A6 01             ldaa     1, x ; xrefs $59DE:branch
59D9:  A7 00             staa     0, x
59DB:  08                inx      
59DC:  9C 5B             cpx      $5b
59DE:  23 F7             bls      $59d7 ; $59D7=loc_59D7
59E0:  DE 5B             ldx      $5b
59E2:  8C 00 4B          cpx      #75
59E5:  27 0B             beq      $59f2 ; $59F2=loc_59F2
59E7:  09                dex      
59E8:  DF 5B             stx      $5b
59EA:  20 06             bra      $59f2 ; $59F2=loc_59F2

loc_59EC:
59EC:  09                dex       ; xrefs $59D5:branch
59ED:  8C 00 4B          cpx      #75
59F0:  24 DE             bcc      $59d0 ; $59D0=loc_59D0

loc_59F2:
59F2:  39                rts       ; xrefs $59CE:branch, $59E5:branch, $59EA:branch

; ---- unreached/data gap $59F3-$59F3 ----

        .org $59F4

sub_59F4:
59F4:  CE 00 4B          ldx      #75 ; xrefs $59A3:call
59F7:  15 A4 80          bclr     $a4, #-128 ; $00A4=limiter_mode_flags
59FA:  15 A4 40          bclr     $a4, #64 ; $00A4=limiter_mode_flags

loc_59FD:
59FD:  E6 00             ldab     0, x ; xrefs $5A0A:branch
59FF:  C1 C0             cmpb     #-64
5A01:  24 0B             bcc      $5a0e ; $5A0E=loc_5A0E
5A03:  C1 80             cmpb     #-128
5A05:  24 0F             bcc      $5a16 ; $5A16=loc_5A16

loc_5A07:
5A07:  08                inx       ; xrefs $5A25:branch
5A08:  9C 5B             cpx      $5b
5A0A:  23 F1             bls      $59fd ; $59FD=loc_59FD
5A0C:  20 19             bra      $5a27 ; $5A27=loc_5A27

loc_5A0E:
5A0E:  14 A4 80          bset     $a4, #-128 ; $00A4=limiter_mode_flags | xrefs $5A01:branch
5A11:  14 A4 40          bset     $a4, #64 ; $00A4=limiter_mode_flags
5A14:  20 11             bra      $5a27 ; $5A27=loc_5A27

loc_5A16:
5A16:  18 CE 55 A0       ldy      #21920 ; xrefs $5A05:branch
5A1A:  18 E4 0C          andb     12, y
5A1D:  18 E1 0C          cmpb     12, y
5A20:  27 05             beq      $5a27 ; $5A27=loc_5A27
5A22:  14 A4 40          bset     $a4, #64 ; $00A4=limiter_mode_flags
5A25:  20 E0             bra      $5a07 ; $5A07=loc_5A07

loc_5A27:
5A27:  39                rts       ; xrefs $5A0C:branch, $5A14:branch, $5A20:branch

; ---- unreached/data gap $5A28-$5A28 ----

        .org $5A29

sub_5A29:
5A29:  13 9C 02 4A       brclr    $9c, #2, $5a77 ; $009C=scheduler_status_flags, $5A77=loc_5A77 | xrefs $D5C2:call
5A2D:  96 99             ldaa     $99 ; $0099=runtime_fault_flags
5A2F:  13 12 90 17       brclr    $12, #-112, $5a4a ; $5A4A=loc_5A4A
5A33:  85 04             bita     #4
5A35:  26 0E             bne      $5a45 ; $5A45=loc_5A45
5A37:  12 42 90 0A       brset    $42, #-112, $5a45 ; $5A45=loc_5A45
5A3B:  4F                clra     
5A3C:  97 94             staa     $94 ; $0094=reset_fault_cause
5A3E:  97 99             staa     $99 ; $0099=runtime_fault_flags
5A40:  14 12 02          bset     $12, #2
5A43:  20 15             bra      $5a5a ; $5A5A=loc_5A5A

loc_5A45:
5A45:  15 12 02          bclr     $12, #2 ; xrefs $5A35:branch, $5A37:branch
5A48:  20 10             bra      $5a5a ; $5A5A=loc_5A5A

loc_5A4A:
5A4A:  4D                tsta      ; xrefs $5A2F:branch
5A4B:  26 05             bne      $5a52 ; $5A52=loc_5A52
5A4D:  7D 00 94          tst      >$0094 ; $0094=reset_fault_cause
5A50:  27 05             beq      $5a57 ; $5A57=loc_5A57

loc_5A52:
5A52:  14 12 01          bset     $12, #1 ; xrefs $5A4B:branch
5A55:  20 03             bra      $5a5a ; $5A5A=loc_5A5A

loc_5A57:
5A57:  15 12 01          bclr     $12, #1 ; xrefs $5A50:branch

loc_5A5A:
5A5A:  12 96 02 07       brset    $96, #2, $5a65 ; $5A65=loc_5A65 | xrefs $5A43:branch, $5A48:branch, $5A55:branch
5A5E:  86 FF             ldaa     #-1
5A60:  97 95             staa     $95
5A62:  14 96 02          bset     $96, #2

loc_5A65:
5A65:  CE 00 12          ldx      #18 ; xrefs $5A5A:branch
5A68:  18 CE 91 31       ldy      #-28367
5A6C:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5A6F:  7F 00 95          clr      >$0095
5A72:  C6 00             ldab     #0
5A74:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5A77:
5A77:  39                rts       ; xrefs $5A29:branch

; ---- unreached/data gap $5A78-$5A78 ----

        .org $5A79

sub_5A79:
5A79:  C6 06             ldab     #6 ; xrefs $B863:call
5A7B:  18 CE 80 00       ldy      #-32768
5A7F:  CE 00 00          ldx      #0

loc_5A82:
5A82:  A6 00             ldaa     0, x ; xrefs $5A8D:branch
5A84:  18 A1 00          cmpa     0, y
5A87:  26 08             bne      $5a91 ; $5A91=loc_5A91
5A89:  08                inx      
5A8A:  18 08             iny      
5A8C:  5A                decb     
5A8D:  26 F3             bne      $5a82 ; $5A82=loc_5A82
5A8F:  20 03             bra      $5a94 ; $5A94=loc_5A94

loc_5A91:
5A91:  BD 63 6C          jsr      $636c ; $636C=sub_636C | xrefs $5A87:branch

loc_5A94:
5A94:  86 55             ldaa     #85 ; xrefs $5A8F:branch
5A96:  B7 10 3A          staa     $103a ; $103A=COPRST
5A99:  43                coma     
5A9A:  B7 10 3A          staa     $103a ; $103A=COPRST
5A9D:  FE 91 6C          ldx      $916c
5AA0:  FC 91 6A          ldd      $916a ; $916A=expected_stack_top
5AA3:  83 00 06          subd     #6
5AA6:  18 8F             xgdy     
5AA8:  18 EF 00          sty      0, y

loc_5AAB:
5AAB:  86 55             ldaa     #85 ; xrefs $5AC2:branch
5AAD:  16                tab      
5AAE:  E7 00             stab     0, x
5AB0:  E6 00             ldab     0, x
5AB2:  11                cba      
5AB3:  26 12             bne      $5ac7 ; $5AC7=loc_5AC7
5AB5:  43                coma     
5AB6:  53                comb     
5AB7:  E7 00             stab     0, x
5AB9:  E6 00             ldab     0, x
5ABB:  11                cba      
5ABC:  26 09             bne      $5ac7 ; $5AC7=loc_5AC7
5ABE:  08                inx      
5ABF:  CD AC 00          cpx      0, y
5AC2:  26 E7             bne      $5aab ; $5AAB=loc_5AAB
5AC4:  4F                clra     
5AC5:  20 02             bra      $5ac9 ; $5AC9=loc_5AC9

loc_5AC7:
5AC7:  86 08             ldaa     #8 ; xrefs $5AB3:branch, $5ABC:branch

loc_5AC9:
5AC9:  97 99             staa     $99 ; $0099=runtime_fault_flags | xrefs $5AC5:branch
5ACB:  86 55             ldaa     #85
5ACD:  B7 10 3A          staa     $103a ; $103A=COPRST
5AD0:  43                coma     
5AD1:  B7 10 3A          staa     $103a ; $103A=COPRST
5AD4:  39                rts      

; ---- unreached/data gap $5AD5-$5AD5 ----

        .org $5AD6

; [CONFIRMED] Incremental runtime additive checksum over 0x4000-0xFFFF while skipping 0xB600-0xB7FF.
incremental_rom_checksum:
5AD6:  0F                sei       ; mask interrupts around one incremental checksum step | xrefs $D40F:call
5AD7:  B6 91 6E          ldaa     $916e
5ADA:  27 28             beq      $5b04 ; $5B04=loc_5B04
5ADC:  FE 21 88          ldx      $2188
5ADF:  18 FE 21 8A       ldy      $218a
5AE3:  8C B6 00          cpx      #-18944
5AE6:  25 05             bcs      $5aed ; $5AED=loc_5AED
5AE8:  8C B7 FF          cpx      #-18433
5AEB:  23 08             bls      $5af5 ; $5AF5=loc_5AF5

loc_5AED:
5AED:  E6 00             ldab     0, x ; xrefs $5AE6:branch
5AEF:  18 3A             aby      
5AF1:  18 FF 21 8A       sty      $218a

loc_5AF5:
5AF5:  09                dex       ; xrefs $5AEB:branch
5AF6:  FF 21 88          stx      $2188
5AF9:  8C 40 00          cpx      #16384
5AFC:  24 1A             bcc      $5b18 ; $5B18=loc_5B18
5AFE:  18 BC 80 0E       cpy      $800e ; $800E=checksum_complement_target
5B02:  26 05             bne      $5b09 ; $5B09=loc_5B09

loc_5B04:
5B04:  15 99 04          bclr     $99, #4 ; $0099=runtime_fault_flags | xrefs $5ADA:branch
5B07:  20 03             bra      $5b0c ; $5B0C=loc_5B0C

loc_5B09:
5B09:  14 99 04          bset     $99, #4 ; $0099=runtime_fault_flags | xrefs $5B02:branch

loc_5B0C:
5B0C:  CC FF FF          ldd      #-1 ; xrefs $5B07:branch
5B0F:  FD 21 88          std      $2188
5B12:  CC 00 00          ldd      #0
5B15:  FD 21 8A          std      $218a

loc_5B18:
5B18:  0E                cli       ; xrefs $5AFC:branch
5B19:  39                rts      

; ---- unreached/data gap $5B1A-$5B1A ----

        .org $5B1B

sub_5B1B:
5B1B:  B6 20 0C          ldaa     $200c ; $200C=adc_raw_input_200c | xrefs $43DC:call
5B1E:  F6 92 67          ldab     $9267
5B21:  27 22             beq      $5b45 ; $5B45=loc_5B45
5B23:  F6 92 68          ldab     $9268
5B26:  C1 FF             cmpb     #-1
5B28:  27 1B             beq      $5b45 ; $5B45=loc_5B45
5B2A:  13 9C 02 45       brclr    $9c, #2, $5b73 ; $009C=scheduler_status_flags, $5B73=loc_5B73
5B2E:  12 98 01 09       brset    $98, #1, $5b3b ; $5B3B=loc_5B3B
5B32:  14 98 01          bset     $98, #1
5B35:  86 FF             ldaa     #-1
5B37:  97 95             staa     $95
5B39:  20 0A             bra      $5b45 ; $5B45=loc_5B45

loc_5B3B:
5B3B:  B1 92 67          cmpa     $9267 ; xrefs $5B2E:branch
5B3E:  25 10             bcs      $5b50 ; $5B50=loc_5B50
5B40:  B1 92 68          cmpa     $9268
5B43:  22 0B             bhi      $5b50 ; $5B50=loc_5B50

loc_5B45:
5B45:  15 42 01          bclr     $42, #1 ; xrefs $5B21:branch, $5B28:branch, $5B39:branch
5B48:  14 42 02          bset     $42, #2
5B4B:  15 99 10          bclr     $99, #16 ; $0099=runtime_fault_flags
5B4E:  20 06             bra      $5b56 ; $5B56=loc_5B56

loc_5B50:
5B50:  14 42 01          bset     $42, #1 ; xrefs $5B3E:branch, $5B43:branch
5B53:  15 42 02          bclr     $42, #2

loc_5B56:
5B56:  12 98 01 07       brset    $98, #1, $5b61 ; $5B61=loc_5B61 | xrefs $5B4E:branch
5B5A:  86 FF             ldaa     #-1
5B5C:  97 95             staa     $95
5B5E:  14 98 01          bset     $98, #1

loc_5B61:
5B61:  CE 00 42          ldx      #66 ; xrefs $5B56:branch
5B64:  18 CE 91 61       ldy      #-28319
5B68:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5B6B:  7F 00 95          clr      >$0095
5B6E:  C6 0F             ldab     #15
5B70:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5B73:
5B73:  96 30             ldaa     $30 ; xrefs $5B2A:branch
5B75:  12 42 04 1A       brset    $42, #4, $5b93 ; $5B93=loc_5B93
5B79:  13 42 90 11       brclr    $42, #-112, $5b8e ; $5B8E=loc_5B8E
5B7D:  B6 20 59          ldaa     $2059
5B80:  81 02             cmpa     #2
5B82:  22 05             bhi      $5b89 ; $5B89=loc_5B89
5B84:  B6 92 69          ldaa     $9269
5B87:  20 0B             bra      $5b94 ; $5B94=loc_5B94

loc_5B89:
5B89:  B6 92 6A          ldaa     $926a ; xrefs $5B82:branch
5B8C:  20 06             bra      $5b94 ; $5B94=loc_5B94

loc_5B8E:
5B8E:  B6 20 0C          ldaa     $200c ; $200C=adc_raw_input_200c | xrefs $5B79:branch
5B91:  20 01             bra      $5b94 ; $5B94=loc_5B94

loc_5B93:
5B93:  4F                clra      ; xrefs $5B75:branch

loc_5B94:
5B94:  39                rts       ; xrefs $5B87:branch, $5B8C:branch, $5B91:branch

sub_5B95:
5B95:  B6 20 59          ldaa     $2059 ; xrefs $D505:call
5B98:  81 04             cmpa     #4
5B9A:  25 1B             bcs      $5bb7 ; $5BB7=loc_5BB7
5B9C:  13 A9 02 17       brclr    $a9, #2, $5bb7 ; $00A9=operating_mode_flags, $5BB7=loc_5BB7
5BA0:  B6 20 09          ldaa     $2009
5BA3:  B1 91 76          cmpa     $9176
5BA6:  22 12             bhi      $5bba ; $5BBA=loc_5BBA
5BA8:  7D 21 87          tst      $2187
5BAB:  27 05             beq      $5bb2 ; $5BB2=loc_5BB2
5BAD:  7A 21 87          dec      $2187
5BB0:  20 0E             bra      $5bc0 ; $5BC0=loc_5BC0

loc_5BB2:
5BB2:  14 B3 10          bset     $b3, #16 ; xrefs $5BAB:branch
5BB5:  20 09             bra      $5bc0 ; $5BC0=loc_5BC0

loc_5BB7:
5BB7:  15 B3 10          bclr     $b3, #16 ; xrefs $5B9A:branch, $5B9C:branch

loc_5BBA:
5BBA:  B6 91 75          ldaa     $9175 ; xrefs $5BA6:branch
5BBD:  B7 21 87          staa     $2187

loc_5BC0:
5BC0:  13 B3 10 26       brclr    $b3, #16, $5bea ; $5BEA=loc_5BEA | xrefs $5BB0:branch, $5BB5:branch
5BC4:  B6 20 09          ldaa     $2009
5BC7:  B1 91 74          cmpa     $9174
5BCA:  25 10             bcs      $5bdc ; $5BDC=loc_5BDC
5BCC:  B6 91 75          ldaa     $9175
5BCF:  B7 21 86          staa     $2186
5BD2:  7D 21 85          tst      $2185
5BD5:  27 13             beq      $5bea ; $5BEA=loc_5BEA
5BD7:  7A 21 85          dec      $2185
5BDA:  20 0E             bra      $5bea ; $5BEA=loc_5BEA

loc_5BDC:
5BDC:  B6 91 75          ldaa     $9175 ; xrefs $5BCA:branch
5BDF:  B7 21 85          staa     $2185
5BE2:  7D 21 86          tst      $2186
5BE5:  27 03             beq      $5bea ; $5BEA=loc_5BEA
5BE7:  7A 21 86          dec      $2186

loc_5BEA:
5BEA:  39                rts       ; xrefs $5BC0:branch, $5BD5:branch, $5BDA:branch, $5BE5:branch

; ---- unreached/data gap $5BEB-$5BEB ----

        .org $5BEC

sub_5BEC:
5BEC:  14 B3 0C          bset     $b3, #12 ; xrefs $40DA:call, $432E:call
5BEF:  F6 91 71          ldab     $9171
5BF2:  27 07             beq      $5bfb ; $5BFB=loc_5BFB
5BF4:  F6 91 72          ldab     $9172
5BF7:  C1 FF             cmpb     #-1
5BF9:  26 03             bne      $5bfe ; $5BFE=loc_5BFE

loc_5BFB:
5BFB:  15 B3 04          bclr     $b3, #4 ; xrefs $5BF2:branch

loc_5BFE:
5BFE:  F6 91 74          ldab     $9174 ; xrefs $5BF9:branch
5C01:  26 12             bne      $5c15 ; $5C15=loc_5C15
5C03:  15 B3 08          bclr     $b3, #8
5C06:  13 B3 0C 06       brclr    $b3, #12, $5c10 ; $5C10=loc_5C10
5C0A:  13 9C 02 64       brclr    $9c, #2, $5c72 ; $009C=scheduler_status_flags, $5C72=loc_5C72
5C0E:  20 05             bra      $5c15 ; $5C15=loc_5C15

loc_5C10:
5C10:  4F                clra      ; xrefs $5C06:branch
5C11:  97 15             staa     $15
5C13:  20 58             bra      $5c6d ; $5C6D=loc_5C6D

loc_5C15:
5C15:  13 B3 04 0D       brclr    $b3, #4, $5c26 ; $5C26=loc_5C26 | xrefs $5C01:branch, $5C0E:branch
5C19:  B6 20 08          ldaa     $2008 ; $2008=adc_raw_input_2008
5C1C:  B1 91 71          cmpa     $9171
5C1F:  25 1F             bcs      $5c40 ; $5C40=loc_5C40
5C21:  B1 91 72          cmpa     $9172
5C24:  22 1A             bhi      $5c40 ; $5C40=loc_5C40

loc_5C26:
5C26:  13 B3 08 0E       brclr    $b3, #8, $5c38 ; $5C38=loc_5C38 | xrefs $5C15:branch
5C2A:  13 B3 10 0A       brclr    $b3, #16, $5c38 ; $5C38=loc_5C38
5C2E:  7D 21 85          tst      $2185
5C31:  27 0D             beq      $5c40 ; $5C40=loc_5C40
5C33:  7D 21 86          tst      $2186
5C36:  26 03             bne      $5c3b ; $5C3B=loc_5C3B

loc_5C38:
5C38:  14 15 02          bset     $15, #2 ; xrefs $5C26:branch, $5C2A:branch

loc_5C3B:
5C3B:  15 15 01          bclr     $15, #1 ; xrefs $5C36:branch
5C3E:  20 06             bra      $5c46 ; $5C46=loc_5C46

loc_5C40:
5C40:  14 15 01          bset     $15, #1 ; xrefs $5C1F:branch, $5C24:branch, $5C31:branch
5C43:  15 15 02          bclr     $15, #2

loc_5C46:
5C46:  12 96 04 16       brset    $96, #4, $5c60 ; $5C60=loc_5C60 | xrefs $5C3E:branch
5C4A:  13 15 01 04       brclr    $15, #1, $5c52 ; $5C52=loc_5C52
5C4E:  C6 FF             ldab     #-1
5C50:  20 01             bra      $5c53 ; $5C53=loc_5C53

loc_5C52:
5C52:  5F                clrb      ; xrefs $5C4A:branch

loc_5C53:
5C53:  F7 21 96          stab     $2196 ; xrefs $5C50:branch
5C56:  C6 FF             ldab     #-1
5C58:  D7 95             stab     $95
5C5A:  7F 21 A2          clr      $21a2
5C5D:  14 96 04          bset     $96, #4

loc_5C60:
5C60:  CE 00 15          ldx      #21 ; xrefs $5C46:branch
5C63:  18 CE 91 34       ldy      #-28364
5C67:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5C6A:  7F 00 95          clr      >$0095

loc_5C6D:
5C6D:  C6 01             ldab     #1 ; xrefs $5C13:branch
5C6F:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5C72:
5C72:  CE FF FF          ldx      #-1 ; xrefs $5C0A:branch
5C75:  13 15 0C 02       brclr    $15, #12, $5c7b ; $5C7B=loc_5C7B
5C79:  20 76             bra      $5cf1 ; $5CF1=loc_5CF1

loc_5C7B:
5C7B:  13 15 90 67       brclr    $15, #-112, $5ce6 ; $5CE6=loc_5CE6 | xrefs $5C75:branch
5C7F:  F6 21 96          ldab     $2196
5C82:  27 1E             beq      $5ca2 ; $5CA2=loc_5CA2
5C84:  7F 21 96          clr      $2196
5C87:  13 18 80 0A       brclr    $18, #-128, $5c95 ; $5C95=loc_5C95
5C8B:  86 FF             ldaa     #-1
5C8D:  B7 21 A2          staa     $21a2
5C90:  B6 91 74          ldaa     $9174
5C93:  20 45             bra      $5cda ; $5CDA=loc_5CDA

loc_5C95:
5C95:  86 FF             ldaa     #-1 ; xrefs $5C87:branch
5C97:  B7 21 A2          staa     $21a2
5C9A:  B6 21 21          ldaa     $2121
5C9D:  BD 5C F6          jsr      $5cf6 ; $5CF6=sub_5CF6
5CA0:  20 38             bra      $5cda ; $5CDA=loc_5CDA

loc_5CA2:
5CA2:  B6 21 A2          ldaa     $21a2 ; xrefs $5C82:branch
5CA5:  26 1A             bne      $5cc1 ; $5CC1=loc_5CC1
5CA7:  B6 21 20          ldaa     $2120
5CAA:  B1 91 76          cmpa     $9176
5CAD:  23 0A             bls      $5cb9 ; $5CB9=loc_5CB9
5CAF:  86 FF             ldaa     #-1
5CB1:  B7 21 A2          staa     $21a2
5CB4:  B6 91 74          ldaa     $9174
5CB7:  20 21             bra      $5cda ; $5CDA=loc_5CDA

loc_5CB9:
5CB9:  B6 91 76          ldaa     $9176 ; xrefs $5CAD:branch
5CBC:  CE FF FF          ldx      #-1
5CBF:  20 2D             bra      $5cee ; $5CEE=loc_5CEE

loc_5CC1:
5CC1:  B6 21 20          ldaa     $2120 ; xrefs $5CA5:branch
5CC4:  B1 91 76          cmpa     $9176
5CC7:  24 03             bcc      $5ccc ; $5CCC=loc_5CCC
5CC9:  7F 21 A2          clr      $21a2

loc_5CCC:
5CCC:  FE 21 94          ldx      $2194 ; xrefs $5CC7:branch
5CCF:  8C FF FF          cpx      #-1
5CD2:  27 06             beq      $5cda ; $5CDA=loc_5CDA
5CD4:  FE 21 94          ldx      $2194
5CD7:  26 1B             bne      $5cf4 ; $5CF4=loc_5CF4
5CD9:  4A                deca     

loc_5CDA:
5CDA:  36                psha      ; xrefs $5C93:branch, $5CA0:branch, $5CB7:branch, $5CD2:branch
5CDB:  4F                clra     
5CDC:  F6 91 73          ldab     $9173
5CDF:  05                asld     
5CE0:  05                asld     
5CE1:  05                asld     
5CE2:  8F                xgdx     
5CE3:  32                pula     
5CE4:  20 08             bra      $5cee ; $5CEE=loc_5CEE

loc_5CE6:
5CE6:  7F 21 A2          clr      $21a2 ; xrefs $5C7B:branch
5CE9:  B6 20 09          ldaa     $2009
5CEC:  20 00             bra      $5cee ; $5CEE=loc_5CEE

loc_5CEE:
5CEE:  B7 21 20          staa     $2120 ; xrefs $5CBF:branch, $5CE4:branch, $5CEC:branch

loc_5CF1:
5CF1:  FF 21 94          stx      $2194 ; xrefs $5C79:branch

loc_5CF4:
5CF4:  39                rts       ; xrefs $5CD7:branch

; ---- unreached/data gap $5CF5-$5CF5 ----

        .org $5CF6

sub_5CF6:
5CF6:  CE 92 D9          ldx      #-27943 ; xrefs $5C9D:call
5CF9:  F6 92 E2          ldab     $92e2
5CFC:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
5CFF:  18 CE 92 CF       ldy      #-27953
5D03:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
5D06:  39                rts      

; ---- unreached/data gap $5D07-$5D07 ----

        .org $5D08

sub_5D08:
5D08:  F6 91 77          ldab     $9177 ; xrefs $40BC:call, $437E:call
5D0B:  27 0D             beq      $5d1a ; $5D1A=loc_5D1A
5D0D:  F6 91 78          ldab     $9178
5D10:  C1 FF             cmpb     #-1
5D12:  27 06             beq      $5d1a ; $5D1A=loc_5D1A
5D14:  12 9C 02 07       brset    $9c, #2, $5d1f ; $009C=scheduler_status_flags, $5D1F=loc_5D1F
5D18:  20 3D             bra      $5d57 ; $5D57=loc_5D57

loc_5D1A:
5D1A:  4F                clra      ; xrefs $5D0B:branch, $5D12:branch
5D1B:  97 18             staa     $18
5D1D:  20 33             bra      $5d52 ; $5D52=loc_5D52

loc_5D1F:
5D1F:  B6 20 0A          ldaa     $200a ; $200A=adc_raw_input_200a | xrefs $5D14:branch
5D22:  B1 91 77          cmpa     $9177
5D25:  25 0D             bcs      $5d34 ; $5D34=loc_5D34
5D27:  B1 91 78          cmpa     $9178
5D2A:  22 08             bhi      $5d34 ; $5D34=loc_5D34
5D2C:  15 18 01          bclr     $18, #1
5D2F:  14 18 02          bset     $18, #2
5D32:  20 06             bra      $5d3a ; $5D3A=loc_5D3A

loc_5D34:
5D34:  14 18 01          bset     $18, #1 ; xrefs $5D25:branch, $5D2A:branch
5D37:  15 18 02          bclr     $18, #2

loc_5D3A:
5D3A:  12 96 08 07       brset    $96, #8, $5d45 ; $5D45=loc_5D45 | xrefs $5D32:branch
5D3E:  86 FF             ldaa     #-1
5D40:  97 95             staa     $95
5D42:  14 96 08          bset     $96, #8

loc_5D45:
5D45:  CE 00 18          ldx      #24 ; xrefs $5D3A:branch
5D48:  18 CE 91 37       ldy      #-28361
5D4C:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5D4F:  7F 00 95          clr      >$0095

loc_5D52:
5D52:  C6 02             ldab     #2 ; xrefs $5D1D:branch
5D54:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5D57:
5D57:  13 18 0C 02       brclr    $18, #12, $5d5d ; $5D5D=loc_5D5D | xrefs $5D18:branch
5D5B:  20 1C             bra      $5d79 ; $5D79=loc_5D79

loc_5D5D:
5D5D:  B6 20 0B          ldaa     $200b ; xrefs $5D57:branch
5D60:  13 18 90 12       brclr    $18, #-112, $5d76 ; $5D76=loc_5D76
5D64:  12 15 80 0B       brset    $15, #-128, $5d73 ; $5D73=loc_5D73
5D68:  B6 21 20          ldaa     $2120
5D6B:  BD 5D 7B          jsr      $5d7b ; $5D7B=sub_5D7B
5D6E:  B1 91 79          cmpa     $9179
5D71:  22 03             bhi      $5d76 ; $5D76=loc_5D76

loc_5D73:
5D73:  B6 91 79          ldaa     $9179 ; xrefs $5D64:branch

loc_5D76:
5D76:  B7 21 21          staa     $2121 ; xrefs $5D60:branch, $5D71:branch

loc_5D79:
5D79:  39                rts       ; xrefs $5D5B:branch

; ---- unreached/data gap $5D7A-$5D7A ----

        .org $5D7B

sub_5D7B:
5D7B:  CE 92 CF          ldx      #-27953 ; xrefs $5D6B:call
5D7E:  F6 92 D8          ldab     $92d8
5D81:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
5D84:  18 CE 92 D9       ldy      #-27943
5D88:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
5D8B:  39                rts      

; ---- unreached/data gap $5D8C-$5D8C ----

        .org $5D8D

sub_5D8D:
5D8D:  37                pshb      ; xrefs $4067:call, $418B:call
5D8E:  3C                pshx     
5D8F:  B6 91 7B          ldaa     $917b
5D92:  81 FF             cmpa     #-1
5D94:  27 0C             beq      $5da2 ; $5DA2=loc_5DA2
5D96:  B6 91 7A          ldaa     $917a
5D99:  27 07             beq      $5da2 ; $5DA2=loc_5DA2
5D9B:  12 9C 02 09       brset    $9c, #2, $5da8 ; $009C=scheduler_status_flags, $5DA8=loc_5DA8
5D9F:  7E 5E 52          jmp      $5e52 ; $5E52=loc_5E52

loc_5DA2:
5DA2:  4F                clra      ; xrefs $5D94:branch, $5D99:branch
5DA3:  97 1B             staa     $1b
5DA5:  7E 5E 4D          jmp      $5e4d ; $5E4D=loc_5E4D

loc_5DA8:
5DA8:  B6 20 0E          ldaa     $200e ; $200E=adc_raw_input_200e | xrefs $5D9B:branch
5DAB:  13 1B 90 1C       brclr    $1b, #-112, $5dcb ; $5DCB=loc_5DCB
5DAF:  B1 91 85          cmpa     $9185
5DB2:  25 12             bcs      $5dc6 ; $5DC6=loc_5DC6
5DB4:  B1 91 7B          cmpa     $917b
5DB7:  22 0D             bhi      $5dc6 ; $5DC6=loc_5DC6
5DB9:  B6 20 11          ldaa     $2011
5DBC:  B1 91 86          cmpa     $9186
5DBF:  25 05             bcs      $5dc6 ; $5DC6=loc_5DC6
5DC1:  14 1B 02          bset     $1b, #2
5DC4:  20 6D             bra      $5e33 ; $5E33=loc_5E33

loc_5DC6:
5DC6:  15 1B 02          bclr     $1b, #2 ; xrefs $5DB2:branch, $5DB7:branch, $5DBF:branch
5DC9:  20 68             bra      $5e33 ; $5E33=loc_5E33

loc_5DCB:
5DCB:  B1 91 7A          cmpa     $917a ; xrefs $5DAB:branch
5DCE:  24 14             bcc      $5de4 ; $5DE4=loc_5DE4
5DD0:  12 1E 80 08       brset    $1e, #-128, $5ddc ; $5DDC=loc_5DDC
5DD4:  12 1E 10 04       brset    $1e, #16, $5ddc ; $5DDC=loc_5DDC
5DD8:  13 A9 40 4F       brclr    $a9, #64, $5e2b ; $00A9=operating_mode_flags, $5E2B=loc_5E2B

loc_5DDC:
5DDC:  F6 00 D3          ldab     >$00d3 ; xrefs $5DD0:branch, $5DD4:branch
5DDF:  F1 91 84          cmpb     $9184
5DE2:  25 47             bcs      $5e2b ; $5E2B=loc_5E2B

loc_5DE4:
5DE4:  B1 91 7B          cmpa     $917b ; xrefs $5DCE:branch
5DE7:  22 42             bhi      $5e2b ; $5E2B=loc_5E2B
5DE9:  12 A9 01 08       brset    $a9, #1, $5df5 ; $00A9=operating_mode_flags, $5DF5=loc_5DF5
5DED:  FE 20 22          ldx      $2022
5DF0:  BC 91 7D          cpx      $917d
5DF3:  25 36             bcs      $5e2b ; $5E2B=loc_5E2B

loc_5DF5:
5DF5:  13 1E 90 02       brclr    $1e, #-112, $5dfb ; $5DFB=loc_5DFB | xrefs $5DE9:branch
5DF9:  20 35             bra      $5e30 ; $5E30=loc_5E30

loc_5DFB:
5DFB:  12 A9 40 08       brset    $a9, #64, $5e07 ; $00A9=operating_mode_flags, $5E07=loc_5E07 | xrefs $5DF5:branch
5DFF:  B6 91 7F          ldaa     $917f
5E02:  B7 20 16          staa     $2016
5E05:  20 29             bra      $5e30 ; $5E30=loc_5E30

loc_5E07:
5E07:  B6 20 16          ldaa     $2016 ; xrefs $5DFB:branch
5E0A:  27 06             beq      $5e12 ; $5E12=loc_5E12
5E0C:  4A                deca     
5E0D:  B7 20 16          staa     $2016
5E10:  20 1E             bra      $5e30 ; $5E30=loc_5E30

loc_5E12:
5E12:  12 A3 10 1A       brset    $a3, #16, $5e30 ; $5E30=loc_5E30 | xrefs $5E0A:branch
5E16:  DE BA             ldx      $ba ; $00BA=engine_period_delta
5E18:  BC 91 80          cpx      $9180
5E1B:  22 13             bhi      $5e30 ; $5E30=loc_5E30
5E1D:  30                tsx      
5E1E:  FC 20 22          ldd      $2022
5E21:  A3 00             subd     0, x
5E23:  25 06             bcs      $5e2b ; $5E2B=loc_5E2B
5E25:  1A B3 91 82       cpd      $9182
5E29:  24 05             bcc      $5e30 ; $5E30=loc_5E30

loc_5E2B:
5E2B:  14 1B 01          bset     $1b, #1 ; xrefs $5DD8:branch, $5DE2:branch, $5DE7:branch, $5DF3:branch, $5E23:branch
5E2E:  20 03             bra      $5e33 ; $5E33=loc_5E33

loc_5E30:
5E30:  15 1B 01          bclr     $1b, #1 ; xrefs $5DF9:branch, $5E05:branch, $5E10:branch, $5E12:branch, $5E1B:branch, $5E29:branch

loc_5E33:
5E33:  12 96 10 07       brset    $96, #16, $5e3e ; $5E3E=loc_5E3E | xrefs $5DC4:branch, $5DC9:branch, $5E2E:branch
5E37:  14 96 10          bset     $96, #16
5E3A:  86 FF             ldaa     #-1
5E3C:  97 95             staa     $95

loc_5E3E:
5E3E:  CE 00 1B          ldx      #27 ; xrefs $5E33:branch
5E41:  18 CE 91 3A       ldy      #-28358
5E45:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5E48:  F6 21 A1          ldab     $21a1
5E4B:  D7 95             stab     $95

loc_5E4D:
5E4D:  C6 03             ldab     #3 ; xrefs $5DA5:jump
5E4F:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5E52:
5E52:  13 1B 0C 0C       brclr    $1b, #12, $5e62 ; $5E62=loc_5E62 | xrefs $5D9F:jump
5E56:  38                pulx     
5E57:  33                pulb     
5E58:  20 26             bra      $5e80 ; $5E80=loc_5E80

loc_5E5A:
5E5A:  38                pulx      ; xrefs $5E62:branch
5E5B:  33                pulb     
5E5C:  D7 D0             stab     $d0 ; $00D0=load_aircharge_byte
5E5E:  DF CE             stx      $ce ; $00CE=load_aircharge_word
5E60:  20 1E             bra      $5e80 ; $5E80=loc_5E80

loc_5E62:
5E62:  13 1B 90 F4       brclr    $1b, #-112, $5e5a ; $5E5A=loc_5E5A | xrefs $5E52:branch
5E66:  12 1E 80 05       brset    $1e, #-128, $5e6f ; $5E6F=loc_5E6F
5E6A:  B6 92 5F          ldaa     $925f
5E6D:  27 05             beq      $5e74 ; $5E74=loc_5E74

loc_5E6F:
5E6F:  F6 91 7C          ldab     $917c ; xrefs $5E66:branch
5E72:  20 03             bra      $5e77 ; $5E77=loc_5E77

loc_5E74:
5E74:  BD 63 44          jsr      $6344 ; $6344=load_aircharge_model | xrefs $5E6D:branch

loc_5E77:
5E77:  D7 D0             stab     $d0 ; $00D0=load_aircharge_byte | xrefs $5E72:branch
5E79:  4F                clra     
5E7A:  05                asld     
5E7B:  05                asld     
5E7C:  DD CE             std      $ce ; $00CE=load_aircharge_word
5E7E:  38                pulx     
5E7F:  33                pulb     

loc_5E80:
5E80:  39                rts       ; xrefs $5E58:branch, $5E60:branch

; ---- unreached/data gap $5E81-$5E81 ----

        .org $5E82

; [STRONG] Convert/filter ADC source used to produce RAM 0x2013.
adc_conversion_helper_5e82:
5E82:  B6 92 60          ldaa     $9260 ; xrefs $404A:call, $9666:call
5E85:  27 07             beq      $5e8e ; $5E8E=loc_5E8E
5E87:  B6 92 61          ldaa     $9261
5E8A:  81 FF             cmpa     #-1
5E8C:  26 05             bne      $5e93 ; $5E93=loc_5E93

loc_5E8E:
5E8E:  4F                clra      ; xrefs $5E85:branch
5E8F:  97 1E             staa     $1e
5E91:  20 4E             bra      $5ee1 ; $5EE1=loc_5EE1

loc_5E93:
5E93:  13 9C 02 4F       brclr    $9c, #2, $5ee6 ; $009C=scheduler_status_flags, $5EE6=loc_5EE6 | xrefs $5E8C:branch
5E97:  B6 20 07          ldaa     $2007 ; $2007=adc_processed_input_2007
5E9A:  B1 92 60          cmpa     $9260
5E9D:  25 19             bcs      $5eb8 ; $5EB8=loc_5EB8
5E9F:  B1 92 61          cmpa     $9261
5EA2:  22 14             bhi      $5eb8 ; $5EB8=loc_5EB8
5EA4:  15 1E 01          bclr     $1e, #1
5EA7:  16                tab      
5EA8:  F0 21 97          subb     $2197
5EAB:  24 01             bcc      $5eae ; $5EAE=loc_5EAE
5EAD:  50                negb     

loc_5EAE:
5EAE:  F1 92 66          cmpb     $9266 ; xrefs $5EAB:branch
5EB1:  25 08             bcs      $5ebb ; $5EBB=loc_5EBB
5EB3:  14 1E 02          bset     $1e, #2
5EB6:  20 06             bra      $5ebe ; $5EBE=loc_5EBE

loc_5EB8:
5EB8:  14 1E 01          bset     $1e, #1 ; xrefs $5E9D:branch, $5EA2:branch

loc_5EBB:
5EBB:  15 1E 02          bclr     $1e, #2 ; xrefs $5EB1:branch

loc_5EBE:
5EBE:  B7 21 97          staa     $2197 ; xrefs $5EB6:branch
5EC1:  96 95             ldaa     $95
5EC3:  B7 21 A1          staa     $21a1
5EC6:  12 96 20 07       brset    $96, #32, $5ed1 ; $5ED1=loc_5ED1
5ECA:  14 96 20          bset     $96, #32
5ECD:  86 FF             ldaa     #-1
5ECF:  20 01             bra      $5ed2 ; $5ED2=loc_5ED2

loc_5ED1:
5ED1:  4F                clra      ; xrefs $5EC6:branch

loc_5ED2:
5ED2:  97 95             staa     $95 ; xrefs $5ECF:branch
5ED4:  CE 00 1E          ldx      #30
5ED7:  18 CE 91 3D       ldy      #-28355
5EDB:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5EDE:  7F 00 95          clr      >$0095

loc_5EE1:
5EE1:  C6 04             ldab     #4 ; xrefs $5E91:branch
5EE3:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5EE6:
5EE6:  13 1E 0C 02       brclr    $1e, #12, $5eec ; $5EEC=loc_5EEC | xrefs $5E93:branch
5EEA:  20 39             bra      $5f25 ; $5F25=loc_5F25

loc_5EEC:
5EEC:  B6 20 07          ldaa     $2007 ; $2007=adc_processed_input_2007 | xrefs $5EE6:branch
5EEF:  13 1E 90 30       brclr    $1e, #-112, $5f23 ; $5F23=loc_5F23
5EF3:  15 A9 80          bclr     $a9, #-128 ; $00A9=operating_mode_flags
5EF6:  B6 89 90          ldaa     $8990
5EF9:  97 10             staa     $10
5EFB:  B6 89 91          ldaa     $8991
5EFE:  97 11             staa     $11
5F00:  96 D1             ldaa     $d1
5F02:  B1 92 65          cmpa     $9265
5F05:  25 17             bcs      $5f1e ; $5F1E=loc_5F1E
5F07:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
5F09:  B1 92 63          cmpa     $9263
5F0C:  25 10             bcs      $5f1e ; $5F1E=loc_5F1E
5F0E:  F6 92 63          ldab     $9263
5F11:  FB 92 64          addb     $9264
5F14:  25 0F             bcs      $5f25 ; $5F25=loc_5F25
5F16:  11                cba      
5F17:  25 0C             bcs      $5f25 ; $5F25=loc_5F25
5F19:  B6 92 62          ldaa     $9262
5F1C:  20 02             bra      $5f20 ; $5F20=loc_5F20

loc_5F1E:
5F1E:  96 11             ldaa     $11 ; xrefs $5F05:branch, $5F0C:branch

loc_5F20:
5F20:  B7 20 13          staa     $2013 ; $2013=processed_sensor_2013 | xrefs $5F1C:branch

loc_5F23:
5F23:  97 C9             staa     $c9 ; xrefs $5EEF:branch

loc_5F25:
5F25:  39                rts       ; xrefs $5EEA:branch, $5F14:branch, $5F17:branch

; ---- unreached/data gap $5F26-$5F26 ----

        .org $5F27

sub_5F27:
5F27:  F6 20 88          ldab     $2088 ; xrefs $D46A:call
5F2A:  B6 92 6B          ldaa     $926b
5F2D:  26 07             bne      $5f36 ; $5F36=loc_5F36
5F2F:  97 24             staa     $24
5F31:  F7 21 8C          stab     $218c
5F34:  20 34             bra      $5f6a ; $5F6A=loc_5F6A

loc_5F36:
5F36:  13 9C 02 35       brclr    $9c, #2, $5f6f ; $009C=scheduler_status_flags, $5F6F=loc_5F6F | xrefs $5F2D:branch
5F3A:  12 96 80 09       brset    $96, #-128, $5f47 ; $5F47=loc_5F47
5F3E:  14 96 80          bset     $96, #-128
5F41:  86 FF             ldaa     #-1
5F43:  97 95             staa     $95
5F45:  20 05             bra      $5f4c ; $5F4C=loc_5F4C

loc_5F47:
5F47:  F1 21 8C          cmpb     $218c ; xrefs $5F3A:branch
5F4A:  26 08             bne      $5f54 ; $5F54=loc_5F54

loc_5F4C:
5F4C:  15 24 01          bclr     $24, #1 ; xrefs $5F45:branch
5F4F:  14 24 02          bset     $24, #2
5F52:  20 06             bra      $5f5a ; $5F5A=loc_5F5A

loc_5F54:
5F54:  14 24 01          bset     $24, #1 ; xrefs $5F4A:branch
5F57:  15 24 02          bclr     $24, #2

loc_5F5A:
5F5A:  F7 21 8C          stab     $218c ; xrefs $5F52:branch
5F5D:  CE 00 24          ldx      #36
5F60:  18 CE 91 43       ldy      #-28349
5F64:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5F67:  7F 00 95          clr      >$0095

loc_5F6A:
5F6A:  C6 05             ldab     #5 ; xrefs $5F34:branch
5F6C:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5F6F:
5F6F:  39                rts       ; xrefs $5F36:branch

; ---- unreached/data gap $5F70-$5F70 ----

        .org $5F71

sub_5F71:
5F71:  96 91             ldaa     $91 ; xrefs $D508:call
5F73:  81 06             cmpa     #6
5F75:  26 63             bne      $5fda ; $5FDA=loc_5FDA
5F77:  FC 92 6C          ldd      $926c
5F7A:  26 04             bne      $5f80 ; $5F80=loc_5F80
5F7C:  97 27             staa     $27
5F7E:  20 55             bra      $5fd5 ; $5FD5=loc_5FD5

loc_5F80:
5F80:  13 9C 02 56       brclr    $9c, #2, $5fda ; $009C=scheduler_status_flags, $5FDA=loc_5FDA | xrefs $5F7A:branch
5F84:  12 97 01 0A       brset    $97, #1, $5f92 ; $5F92=loc_5F92
5F88:  FD 21 9F          std      $219f
5F8B:  86 FF             ldaa     #-1
5F8D:  97 95             staa     $95
5F8F:  14 97 01          bset     $97, #1

loc_5F92:
5F92:  B6 20 AA          ldaa     $20aa ; xrefs $5F84:branch
5F95:  26 25             bne      $5fbc ; $5FBC=loc_5FBC
5F97:  DE BA             ldx      $ba ; $00BA=engine_period_delta
5F99:  BC 92 6E          cpx      $926e
5F9C:  24 1E             bcc      $5fbc ; $5FBC=loc_5FBC
5F9E:  BC 92 70          cpx      $9270
5FA1:  23 19             bls      $5fbc ; $5FBC=loc_5FBC
5FA3:  96 CA             ldaa     $ca
5FA5:  B1 92 72          cmpa     $9272
5FA8:  23 12             bls      $5fbc ; $5FBC=loc_5FBC
5FAA:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
5FAC:  B1 92 73          cmpa     $9273
5FAF:  23 0B             bls      $5fbc ; $5FBC=loc_5FBC
5FB1:  FE 21 9F          ldx      $219f
5FB4:  09                dex      
5FB5:  26 0B             bne      $5fc2 ; $5FC2=loc_5FC2
5FB7:  14 27 01          bset     $27, #1
5FBA:  20 03             bra      $5fbf ; $5FBF=loc_5FBF

loc_5FBC:
5FBC:  15 27 01          bclr     $27, #1 ; xrefs $5F95:branch, $5F9C:branch, $5FA1:branch, $5FA8:branch, $5FAF:branch

loc_5FBF:
5FBF:  FE 92 6C          ldx      $926c ; xrefs $5FBA:branch

loc_5FC2:
5FC2:  FF 21 9F          stx      $219f ; xrefs $5FB5:branch
5FC5:  CE 00 27          ldx      #39
5FC8:  18 CE 91 46       ldy      #-28346
5FCC:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
5FCF:  7F 00 95          clr      >$0095
5FD2:  15 27 02          bclr     $27, #2

loc_5FD5:
5FD5:  C6 06             ldab     #6 ; xrefs $5F7E:branch
5FD7:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_5FDA:
5FDA:  39                rts       ; xrefs $5F75:branch, $5F80:branch

; ---- unreached/data gap $5FDB-$5FDB ----

        .org $5FDC

sub_5FDC:
5FDC:  B6 8A 66          ldaa     $8a66 ; xrefs $D610:call
5FDF:  26 04             bne      $5fe5 ; $5FE5=loc_5FE5
5FE1:  97 3F             staa     $3f
5FE3:  20 43             bra      $6028 ; $6028=loc_6028

loc_5FE5:
5FE5:  13 9C 02 44       brclr    $9c, #2, $602d ; $009C=scheduler_status_flags, $602D=loc_602D | xrefs $5FDF:branch
5FE9:  12 96 40 09       brset    $96, #64, $5ff6 ; $5FF6=loc_5FF6
5FED:  14 96 40          bset     $96, #64
5FF0:  86 FF             ldaa     #-1
5FF2:  97 95             staa     $95
5FF4:  20 1F             bra      $6015 ; $6015=loc_6015

loc_5FF6:
5FF6:  B6 20 EF          ldaa     $20ef ; xrefs $5FE9:branch
5FF9:  27 1A             beq      $6015 ; $6015=loc_6015
5FFB:  13 2D 90 02       brclr    $2d, #-112, $6001 ; $6001=loc_6001
5FFF:  20 14             bra      $6015 ; $6015=loc_6015

loc_6001:
6001:  13 30 90 02       brclr    $30, #-112, $6007 ; $6007=loc_6007 | xrefs $5FFB:branch
6005:  20 0E             bra      $6015 ; $6015=loc_6015

loc_6007:
6007:  13 2A 90 02       brclr    $2a, #-112, $600d ; $600D=loc_600D | xrefs $6001:branch
600B:  20 08             bra      $6015 ; $6015=loc_6015

loc_600D:
600D:  14 3F 01          bset     $3f, #1 ; xrefs $6007:branch
6010:  15 3F 02          bclr     $3f, #2
6013:  20 06             bra      $601b ; $601B=loc_601B

loc_6015:
6015:  14 3F 02          bset     $3f, #2 ; xrefs $5FF4:branch, $5FF9:branch, $5FFF:branch, $6005:branch, $600B:branch
6018:  15 3F 01          bclr     $3f, #1

loc_601B:
601B:  CE 00 3F          ldx      #63 ; xrefs $6013:branch
601E:  18 CE 91 5E       ldy      #-28322
6022:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6025:  7F 00 95          clr      >$0095

loc_6028:
6028:  C6 0E             ldab     #14 ; xrefs $5FE3:branch
602A:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_602D:
602D:  39                rts       ; xrefs $5FE5:branch

; ---- unreached/data gap $602E-$602E ----

        .org $602F

; [OPEN] Periodic runtime stage.
runtime_stage_602f:
602F:  B6 92 74          ldaa     $9274 ; xrefs $D412:call
6032:  26 04             bne      $6038 ; $6038=loc_6038
6034:  97 2A             staa     $2a
6036:  20 1C             bra      $6054 ; $6054=loc_6054

loc_6038:
6038:  13 9C 02 1D       brclr    $9c, #2, $6059 ; $009C=scheduler_status_flags, $6059=loc_6059 | xrefs $6032:branch
603C:  12 97 02 07       brset    $97, #2, $6047 ; $6047=loc_6047
6040:  86 FF             ldaa     #-1
6042:  97 95             staa     $95
6044:  14 97 02          bset     $97, #2

loc_6047:
6047:  CE 00 2A          ldx      #42 ; xrefs $603C:branch
604A:  18 CE 91 49       ldy      #-28343
604E:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6051:  7F 00 95          clr      >$0095

loc_6054:
6054:  C6 07             ldab     #7 ; xrefs $6036:branch
6056:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6059:
6059:  39                rts       ; xrefs $6038:branch

; ---- unreached/data gap $605A-$605A ----

        .org $605B

sub_605B:
605B:  B6 92 75          ldaa     $9275 ; xrefs $D5A3:call
605E:  26 04             bne      $6064 ; $6064=loc_6064
6060:  97 2D             staa     $2d
6062:  20 46             bra      $60aa ; $60AA=loc_60AA

loc_6064:
6064:  13 9C 02 47       brclr    $9c, #2, $60af ; $009C=scheduler_status_flags, $60AF=loc_60AF | xrefs $605E:branch
6068:  12 45 10 43       brset    $45, #16, $60af ; $60AF=loc_60AF
606C:  12 45 80 3F       brset    $45, #-128, $60af ; $60AF=loc_60AF
6070:  12 97 04 0C       brset    $97, #4, $6080 ; $6080=loc_6080
6074:  86 FF             ldaa     #-1
6076:  97 95             staa     $95
6078:  14 97 04          bset     $97, #4
607B:  15 2D 01          bclr     $2d, #1
607E:  20 10             bra      $6090 ; $6090=loc_6090

loc_6080:
6080:  12 2D 01 11       brset    $2d, #1, $6095 ; $6095=loc_6095 | xrefs $6070:branch
6084:  96 CC             ldaa     $cc
6086:  B1 92 7C          cmpa     $927c
6089:  25 0A             bcs      $6095 ; $6095=loc_6095
608B:  B1 92 79          cmpa     $9279
608E:  22 05             bhi      $6095 ; $6095=loc_6095

loc_6090:
6090:  14 2D 02          bset     $2d, #2 ; xrefs $607E:branch
6093:  20 03             bra      $6098 ; $6098=loc_6098

loc_6095:
6095:  15 2D 02          bclr     $2d, #2 ; xrefs $6080:branch, $6089:branch, $608E:branch

loc_6098:
6098:  CE 00 2D          ldx      #45 ; xrefs $6093:branch
609B:  18 CE 91 4C       ldy      #-28340
609F:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
60A2:  7F 00 95          clr      >$0095
60A5:  15 2D 01          bclr     $2d, #1
60A8:  96 2D             ldaa     $2d

loc_60AA:
60AA:  C6 08             ldab     #8 ; xrefs $6062:branch
60AC:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_60AF:
60AF:  39                rts       ; xrefs $6064:branch, $6068:branch, $606C:branch

; ---- unreached/data gap $60B0-$60B0 ----

        .org $60B1

sub_60B1:
60B1:  B6 92 76          ldaa     $9276 ; xrefs $D5AD:call
60B4:  26 04             bne      $60ba ; $60BA=loc_60BA
60B6:  97 30             staa     $30
60B8:  20 46             bra      $6100 ; $6100=loc_6100

loc_60BA:
60BA:  13 9C 02 47       brclr    $9c, #2, $6105 ; $009C=scheduler_status_flags, $6105=loc_6105 | xrefs $60B4:branch
60BE:  12 45 10 43       brset    $45, #16, $6105 ; $6105=loc_6105
60C2:  12 45 80 3F       brset    $45, #-128, $6105 ; $6105=loc_6105
60C6:  12 97 08 0C       brset    $97, #8, $60d6 ; $60D6=loc_60D6
60CA:  86 FF             ldaa     #-1
60CC:  97 95             staa     $95
60CE:  14 97 08          bset     $97, #8
60D1:  15 30 01          bclr     $30, #1
60D4:  20 10             bra      $60e6 ; $60E6=loc_60E6

loc_60D6:
60D6:  12 30 01 11       brset    $30, #1, $60eb ; $60EB=loc_60EB | xrefs $60C6:branch
60DA:  96 CC             ldaa     $cc
60DC:  B1 92 7C          cmpa     $927c
60DF:  25 0A             bcs      $60eb ; $60EB=loc_60EB
60E1:  B1 92 79          cmpa     $9279
60E4:  22 05             bhi      $60eb ; $60EB=loc_60EB

loc_60E6:
60E6:  14 30 02          bset     $30, #2 ; xrefs $60D4:branch
60E9:  20 03             bra      $60ee ; $60EE=loc_60EE

loc_60EB:
60EB:  15 30 02          bclr     $30, #2 ; xrefs $60D6:branch, $60DF:branch, $60E4:branch

loc_60EE:
60EE:  CE 00 30          ldx      #48 ; xrefs $60E9:branch
60F1:  18 CE 91 4F       ldy      #-28337
60F5:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
60F8:  7F 00 95          clr      >$0095
60FB:  15 30 01          bclr     $30, #1
60FE:  96 30             ldaa     $30

loc_6100:
6100:  C6 09             ldab     #9 ; xrefs $60B8:branch
6102:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6105:
6105:  39                rts       ; xrefs $60BA:branch, $60BE:branch, $60C2:branch

; ---- unreached/data gap $6106-$6106 ----

        .org $6107

; [OPEN] Periodic runtime stage.
runtime_stage_6107:
6107:  B6 92 7F          ldaa     $927f ; xrefs $D415:call
610A:  26 06             bne      $6112 ; $6112=loc_6112
610C:  86 02             ldaa     #2
610E:  97 33             staa     $33
6110:  20 1A             bra      $612c ; $612C=loc_612C

loc_6112:
6112:  12 97 10 07       brset    $97, #16, $611d ; $611D=loc_611D | xrefs $610A:branch
6116:  86 FF             ldaa     #-1
6118:  97 95             staa     $95
611A:  14 97 10          bset     $97, #16

loc_611D:
611D:  CE 00 33          ldx      #51 ; xrefs $6112:branch
6120:  18 CE 91 52       ldy      #-28334
6124:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6127:  7F 00 95          clr      >$0095
612A:  96 33             ldaa     $33

loc_612C:
612C:  C6 0A             ldab     #10 ; xrefs $6110:branch
612E:  BD 59 82          jsr      $5982 ; $5982=sub_5982
6131:  39                rts      

; ---- unreached/data gap $6132-$6132 ----

        .org $6133

; [OPEN] Periodic runtime stage.
runtime_stage_6133:
6133:  B6 89 82          ldaa     $8982 ; xrefs $D418:call
6136:  26 04             bne      $613c ; $613C=loc_613C
6138:  97 48             staa     $48
613A:  20 18             bra      $6154 ; $6154=loc_6154

loc_613C:
613C:  12 98 04 07       brset    $98, #4, $6147 ; $6147=loc_6147 | xrefs $6136:branch
6140:  86 FF             ldaa     #-1
6142:  97 95             staa     $95
6144:  14 98 04          bset     $98, #4

loc_6147:
6147:  CE 00 48          ldx      #72 ; xrefs $613C:branch
614A:  18 CE 91 67       ldy      #-28313
614E:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6151:  7F 00 95          clr      >$0095

loc_6154:
6154:  C6 11             ldab     #17 ; xrefs $613A:branch
6156:  BD 59 82          jsr      $5982 ; $5982=sub_5982
6159:  39                rts      

; ---- unreached/data gap $615A-$615A ----

        .org $615B

; [OPEN] Periodic runtime stage.
runtime_stage_615b:
615B:  B6 89 83          ldaa     $8983 ; xrefs $D41B:call
615E:  26 04             bne      $6164 ; $6164=loc_6164
6160:  97 45             staa     $45
6162:  20 1C             bra      $6180 ; $6180=loc_6180

loc_6164:
6164:  13 9C 02 1D       brclr    $9c, #2, $6185 ; $009C=scheduler_status_flags, $6185=loc_6185 | xrefs $615E:branch
6168:  12 98 02 07       brset    $98, #2, $6173 ; $6173=loc_6173
616C:  86 FF             ldaa     #-1
616E:  97 95             staa     $95
6170:  14 98 02          bset     $98, #2

loc_6173:
6173:  CE 00 45          ldx      #69 ; xrefs $6168:branch
6176:  18 CE 91 64       ldy      #-28316
617A:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
617D:  7F 00 95          clr      >$0095

loc_6180:
6180:  C6 10             ldab     #16 ; xrefs $6162:branch
6182:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6185:
6185:  39                rts       ; xrefs $6164:branch

; ---- unreached/data gap $6186-$6186 ----

        .org $6187

; [OPEN] Periodic runtime stage.
runtime_stage_6187:
6187:  B6 92 80          ldaa     $9280 ; xrefs $D41E:call
618A:  26 0D             bne      $6199 ; $6199=loc_6199
618C:  97 36             staa     $36
618E:  CE FF FF          ldx      #-1
6191:  FF 21 99          stx      $2199
6194:  FF 21 9B          stx      $219b
6197:  20 76             bra      $620f ; $620F=loc_620F

loc_6199:
6199:  13 9C 02 7A       brclr    $9c, #2, $6217 ; $009C=scheduler_status_flags, $6217=loc_6217 | xrefs $618A:branch
619D:  CE 21 99          ldx      #8601
61A0:  C6 FF             ldab     #-1
61A2:  13 A1 20 35       brclr    $a1, #32, $61db ; $61DB=loc_61DB
61A6:  12 A4 40 31       brset    $a4, #64, $61db ; $00A4=limiter_mode_flags, $61DB=loc_61DB
61AA:  12 9F 02 15       brset    $9f, #2, $61c3 ; $61C3=loc_61C3
61AE:  B6 20 B7          ldaa     $20b7
61B1:  81 02             cmpa     #2
61B3:  26 16             bne      $61cb ; $61CB=loc_61CB
61B5:  18 FE 21 9D       ldy      $219d
61B9:  26 10             bne      $61cb ; $61CB=loc_61CB
61BB:  18 FE 92 83       ldy      $9283
61BF:  18 FF 21 9D       sty      $219d

loc_61C3:
61C3:  14 36 01          bset     $36, #1 ; xrefs $61AA:branch
61C6:  15 36 02          bclr     $36, #2
61C9:  20 10             bra      $61db ; $61DB=loc_61DB

loc_61CB:
61CB:  B6 8E 69          ldaa     $8e69 ; xrefs $61B3:branch, $61B9:branch
61CE:  B1 20 B9          cmpa     $20b9 ; $20B9=adaptive_fuel_trim_word
61D1:  24 18             bcc      $61eb ; $61EB=loc_61EB
61D3:  B6 8E 68          ldaa     $8e68
61D6:  B1 20 B9          cmpa     $20b9 ; $20B9=adaptive_fuel_trim_word
61D9:  23 07             bls      $61e2 ; $61E2=loc_61E2

loc_61DB:
61DB:  17                tba       ; xrefs $61A2:branch, $61A6:branch, $61C9:branch
61DC:  ED 00             std      0, x
61DE:  ED 02             std      2, x
61E0:  20 11             bra      $61f3 ; $61F3=loc_61F3

loc_61E2:
61E2:  17                tba       ; xrefs $61D9:branch
61E3:  ED 00             std      0, x
61E5:  08                inx      
61E6:  08                inx      
61E7:  C6 02             ldab     #2
61E9:  20 05             bra      $61f0 ; $61F0=loc_61F0

loc_61EB:
61EB:  17                tba       ; xrefs $61D1:branch
61EC:  ED 02             std      2, x
61EE:  C6 01             ldab     #1

loc_61F0:
61F0:  BD 62 19          jsr      $6219 ; $6219=sub_6219 | xrefs $61E9:branch

loc_61F3:
61F3:  12 97 20 07       brset    $97, #32, $61fe ; $61FE=loc_61FE | xrefs $61E0:branch
61F7:  86 FF             ldaa     #-1
61F9:  97 95             staa     $95
61FB:  14 97 20          bset     $97, #32

loc_61FE:
61FE:  CE 00 36          ldx      #54 ; xrefs $61F3:branch
6201:  18 CE 91 55       ldy      #-28331
6205:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6208:  7F 00 95          clr      >$0095
620B:  85 FD             bita     #-3
620D:  26 03             bne      $6212 ; $6212=loc_6212

loc_620F:
620F:  15 9A 03          bclr     $9a, #3 ; xrefs $6197:branch

loc_6212:
6212:  C6 0B             ldab     #11 ; xrefs $620D:branch
6214:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6217:
6217:  39                rts       ; xrefs $6199:branch

; ---- unreached/data gap $6218-$6218 ----

        .org $6219

sub_6219:
6219:  1A EE 00          ldy      0, x ; xrefs $61F0:call
621C:  18 8C FF FF       cpy      #-1
6220:  26 05             bne      $6227 ; $6227=loc_6227
6222:  FC 92 81          ldd      $9281
6225:  20 27             bra      $624e ; $624E=loc_624E

loc_6227:
6227:  1A EE 00          ldy      0, x ; xrefs $6220:branch
622A:  26 24             bne      $6250 ; $6250=loc_6250
622C:  DA 9A             orab     $9a
622E:  D7 9A             stab     $9a
6230:  14 36 01          bset     $36, #1
6233:  15 36 02          bclr     $36, #2
6236:  0F                sei      
6237:  86 09             ldaa     #9
6239:  B7 20 B7          staa     $20b7
623C:  FC 8E 2E          ldd      $8e2e
623F:  FD 20 B3          std      $20b3
6242:  0E                cli      
6243:  96 9F             ldaa     $9f
6245:  84 FA             anda     #-6
6247:  8A 02             oraa     #2
6249:  97 9F             staa     $9f
624B:  CC FF FF          ldd      #-1

loc_624E:
624E:  ED 00             std      0, x ; xrefs $6225:branch

loc_6250:
6250:  39                rts       ; xrefs $622A:branch

; ---- unreached/data gap $6251-$6251 ----

        .org $6252

sub_6252:
6252:  B6 92 85          ldaa     $9285 ; xrefs $D009:call, $D0BD:call
6255:  26 03             bne      $625a ; $625A=loc_625A
6257:  7E 62 DA          jmp      $62da ; $62DA=loc_62DA

loc_625A:
625A:  86 FF             ldaa     #-1 ; xrefs $6255:branch
625C:  B7 21 8D          staa     $218d
625F:  DE 08             ldx      $08
6261:  BC 8F F5          cpx      $8ff5
6264:  2D 0D             blt      $6273 ; $6273=loc_6273
6266:  14 9A 20          bset     $9a, #32
6269:  7F 21 8D          clr      $218d
626C:  FE 8F F5          ldx      $8ff5
626F:  DF 08             stx      $08
6271:  20 10             bra      $6283 ; $6283=loc_6283

loc_6273:
6273:  BC 8F F7          cpx      $8ff7 ; xrefs $6264:branch
6276:  2E 0B             bgt      $6283 ; $6283=loc_6283
6278:  14 9A 10          bset     $9a, #16
627B:  7F 21 8D          clr      $218d
627E:  FE 8F F7          ldx      $8ff7
6281:  DF 08             stx      $08

loc_6283:
6283:  DE 0C             ldx      $0c ; xrefs $6271:branch, $6276:branch
6285:  BC 8F F9          cpx      $8ff9
6288:  2D 0D             blt      $6297 ; $6297=loc_6297
628A:  14 9A 08          bset     $9a, #8
628D:  7F 21 8D          clr      $218d
6290:  FE 8F F9          ldx      $8ff9
6293:  DF 0C             stx      $0c
6295:  20 10             bra      $62a7 ; $62A7=loc_62A7

loc_6297:
6297:  BC 8F FB          cpx      $8ffb ; xrefs $6288:branch
629A:  2E 0B             bgt      $62a7 ; $62A7=loc_62A7
629C:  14 9A 04          bset     $9a, #4
629F:  7F 21 8D          clr      $218d
62A2:  FE 8F FB          ldx      $8ffb
62A5:  DF 0C             stx      $0c

loc_62A7:
62A7:  DE 06             ldx      $06 ; xrefs $6295:branch, $629A:branch
62A9:  BC 8F F1          cpx      $8ff1
62AC:  2D 0A             blt      $62b8 ; $62B8=loc_62B8
62AE:  14 9A 80          bset     $9a, #-128
62B1:  FE 8F F1          ldx      $8ff1
62B4:  DF 06             stx      $06
62B6:  20 14             bra      $62cc ; $62CC=loc_62CC

loc_62B8:
62B8:  BC 8F F3          cpx      $8ff3 ; xrefs $62AC:branch
62BB:  2E 0A             bgt      $62c7 ; $62C7=loc_62C7
62BD:  14 9A 40          bset     $9a, #64
62C0:  FE 8F F3          ldx      $8ff3
62C3:  DF 06             stx      $06
62C5:  20 05             bra      $62cc ; $62CC=loc_62CC

loc_62C7:
62C7:  B6 21 8D          ldaa     $218d ; xrefs $62BB:branch
62CA:  26 08             bne      $62d4 ; $62D4=loc_62D4

loc_62CC:
62CC:  14 39 01          bset     $39, #1 ; xrefs $62B6:branch, $62C5:branch
62CF:  15 39 02          bclr     $39, #2
62D2:  20 06             bra      $62da ; $62DA=loc_62DA

loc_62D4:
62D4:  15 39 01          bclr     $39, #1 ; xrefs $62CA:branch
62D7:  14 39 02          bset     $39, #2

loc_62DA:
62DA:  39                rts       ; xrefs $6257:jump, $62D2:branch

; ---- unreached/data gap $62DB-$62DB ----

        .org $62DC

; [OPEN] Periodic runtime stage.
runtime_stage_62dc:
62DC:  B6 92 85          ldaa     $9285 ; xrefs $D421:call
62DF:  26 04             bne      $62e5 ; $62E5=loc_62E5
62E1:  97 39             staa     $39
62E3:  20 20             bra      $6305 ; $6305=loc_6305

loc_62E5:
62E5:  13 9C 02 27       brclr    $9c, #2, $6310 ; $009C=scheduler_status_flags, $6310=loc_6310 | xrefs $62DF:branch
62E9:  12 97 40 07       brset    $97, #64, $62f4 ; $62F4=loc_62F4
62ED:  86 FF             ldaa     #-1
62EF:  97 95             staa     $95
62F1:  14 97 40          bset     $97, #64

loc_62F4:
62F4:  CE 00 39          ldx      #57 ; xrefs $62E9:branch
62F7:  18 CE 91 58       ldy      #-28328
62FB:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
62FE:  7F 00 95          clr      >$0095
6301:  85 FD             bita     #-3
6303:  26 06             bne      $630b ; $630B=loc_630B

loc_6305:
6305:  C6 03             ldab     #3 ; xrefs $62E3:branch
6307:  D4 9A             andb     $9a
6309:  D7 9A             stab     $9a

loc_630B:
630B:  C6 0C             ldab     #12 ; xrefs $6303:branch
630D:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6310:
6310:  39                rts       ; xrefs $62E5:branch

; ---- unreached/data gap $6311-$6311 ----

        .org $6312

sub_6312:
6312:  B6 92 86          ldaa     $9286 ; xrefs $C810:call
6315:  26 04             bne      $631b ; $631B=loc_631B
6317:  97 3C             staa     $3c
6319:  20 22             bra      $633d ; $633D=loc_633D

loc_631B:
631B:  13 9C 02 23       brclr    $9c, #2, $6342 ; $009C=scheduler_status_flags, $6342=loc_6342 | xrefs $6315:branch
631F:  12 97 80 07       brset    $97, #-128, $632a ; $632A=loc_632A
6323:  86 FF             ldaa     #-1
6325:  97 95             staa     $95
6327:  14 97 80          bset     $97, #-128

loc_632A:
632A:  CE 00 3C          ldx      #60 ; xrefs $631F:branch
632D:  18 CE 91 5B       ldy      #-28325
6331:  BD 58 F2          jsr      $58f2 ; $58F2=sub_58F2
6334:  7F 00 95          clr      >$0095
6337:  15 3C 01          bclr     $3c, #1
633A:  14 3C 02          bset     $3c, #2

loc_633D:
633D:  C6 0D             ldab     #13 ; xrefs $6319:branch
633F:  BD 59 82          jsr      $5982 ; $5982=sub_5982

loc_6342:
6342:  39                rts       ; xrefs $631B:branch

; ---- unreached/data gap $6343-$6343 ----

        .org $6344

; [STRONG] Interpolate the 0x9187 24x9 factor table and update load/air-charge state.
load_aircharge_model:
6344:  B6 20 17          ldaa     $2017 ; xrefs $58EA:call, $5E74:call
6347:  18 CE 21 8D       ldy      #8589
634B:  F6 92 9A          ldab     $929a
634E:  18 E7 06          stab     6, y
6351:  CE 92 91          ldx      #-28015
6354:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
6357:  18 ED 00          std      0, y
635A:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
635D:  18 ED 02          std      2, y
6360:  CC 91 87          ldd      #-28281
6363:  18 ED 04          std      4, y
6366:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
6369:  16                tab      
636A:  39                rts      

; ---- unreached/data gap $636B-$636B ----

        .org $636C

sub_636C:
636C:  FC 91 6A          ldd      $916a ; $916A=expected_stack_top | xrefs $5A91:call, $657B:call, $BA30:call
636F:  83 00 FF          subd     #255
6372:  18 8F             xgdy     
6374:  CE 00 00          ldx      #0

loc_6377:
6377:  EC 00             ldd      0, x ; xrefs $6385:branch
6379:  18 ED 00          std      0, y
637C:  08                inx      
637D:  08                inx      
637E:  18 08             iny      
6380:  18 08             iny      
6382:  8C 00 94          cpx      #148
6385:  23 F0             bls      $6377 ; $6377=loc_6377
6387:  CC 00 00          ldd      #0
638A:  DD 06             std      $06
638C:  DD 08             std      $08
638E:  DD 0C             std      $0c
6390:  DD 0A             std      $0a
6392:  DD 0E             std      $0e
6394:  FD 20 9E          std      $209e
6397:  97 A7             staa     $a7
6399:  97 90             staa     $90
639B:  97 5E             staa     $5e
639D:  C6 01             ldab     #1
639F:  D7 91             stab     $91
63A1:  F6 91 2E          ldab     $912e
63A4:  D7 92             stab     $92
63A6:  C6 FF             ldab     #-1
63A8:  D7 5F             stab     $5f
63AA:  D7 5D             stab     $5d
63AC:  15 8C 10          bclr     $8c, #16
63AF:  CE 00 12          ldx      #18

loc_63B2:
63B2:  A7 00             staa     0, x ; xrefs $63B8:branch
63B4:  08                inx      
63B5:  8C 00 5B          cpx      #91
63B8:  26 F8             bne      $63b2 ; $63B2=loc_63B2
63BA:  CE 00 72          ldx      #114

loc_63BD:
63BD:  A7 00             staa     0, x ; xrefs $63C3:branch
63BF:  08                inx      
63C0:  8C 00 8B          cpx      #139
63C3:  26 F8             bne      $63bd ; $63BD=loc_63BD
63C5:  97 8A             staa     $8a
63C7:  CC 00 4B          ldd      #75
63CA:  DD 5B             std      $5b
63CC:  B6 89 90          ldaa     $8990
63CF:  97 10             staa     $10
63D1:  B6 89 91          ldaa     $8991
63D4:  97 11             staa     $11
63D6:  C6 09             ldab     #9
63D8:  86 80             ldaa     #-128
63DA:  CE 00 60          ldx      #96
63DD:  18 CE 00 69       ldy      #105

loc_63E1:
63E1:  A7 00             staa     0, x ; xrefs $63EA:branch
63E3:  18 A7 00          staa     0, y
63E6:  08                inx      
63E7:  18 08             iny      
63E9:  5A                decb     
63EA:  26 F5             bne      $63e1 ; $63E1=loc_63E1
63EC:  7F 00 93          clr      >$0093
63EF:  C6 06             ldab     #6
63F1:  CE 80 00          ldx      #-32768
63F4:  18 CE 00 00       ldy      #0

loc_63F8:
63F8:  A6 00             ldaa     0, x ; xrefs $6401:branch
63FA:  18 A7 00          staa     0, y
63FD:  08                inx      
63FE:  18 08             iny      
6400:  5A                decb     
6401:  26 F5             bne      $63f8 ; $63F8=loc_63F8
6403:  39                rts      

; ---- unreached/data gap $6404-$6404 ----

        .org $6405

; [CONFIRMED] Vector target; exact hardware interrupt source depends on MCU mask.
interrupt_handler_6405:
6405:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
6408:  81 06             cmpa     #6
640A:  26 05             bne      $6411 ; $6411=loc_6411
640C:  BD E1 32          jsr      $e132 ; $E132=sub_E132
640F:  20 3E             bra      $644f ; $644F=loc_644F

loc_6411:
6411:  CE 10 00          ldx      #4096 ; xrefs $640A:branch
6414:  1D 50 10          bclr     80, x; #16
6417:  13 33 02 34       brclr    $33, #2, $644f ; $644F=loc_644F
641B:  14 33 01          bset     $33, #1
641E:  15 33 02          bclr     $33, #2
6421:  86 FF             ldaa     #-1
6423:  97 5F             staa     $5f
6425:  15 A6 10          bclr     $a6, #16
6428:  13 A6 04 13       brclr    $a6, #4, $643f ; $643F=loc_643F
642C:  7C 00 5D          inc      >$005d
642F:  96 5E             ldaa     $5e
6431:  81 03             cmpa     #3
6433:  27 05             beq      $643a ; $643A=loc_643A
6435:  7C 00 5E          inc      >$005e
6438:  20 15             bra      $644f ; $644F=loc_644F

loc_643A:
643A:  4F                clra      ; xrefs $6433:branch
643B:  97 5E             staa     $5e
643D:  20 10             bra      $644f ; $644F=loc_644F

loc_643F:
643F:  7A 00 5D          dec      >$005d ; xrefs $6428:branch
6442:  96 5E             ldaa     $5e
6444:  27 05             beq      $644b ; $644B=loc_644B
6446:  7A 00 5E          dec      >$005e
6449:  20 04             bra      $644f ; $644F=loc_644F

loc_644B:
644B:  86 03             ldaa     #3 ; xrefs $6444:branch
644D:  97 5E             staa     $5e

loc_644F:
644F:  3B                rti       ; xrefs $640F:branch, $6417:branch, $6438:branch, $643D:branch, $6449:branch

; ---- unreached/data gap $6450-$6450 ----

        .org $6451

sub_6451:
6451:  7D 24 6B          tst      $246b ; xrefs $D68F:call
6454:  27 03             beq      $6459 ; $6459=loc_6459
6456:  7E 65 0C          jmp      $650c ; $650C=loc_650C

loc_6459:
6459:  FE 25 73          ldx      $2573 ; xrefs $6454:branch
645C:  BD E3 26          jsr      $e326 ; $E326=sub_E326
645F:  3A                abx      
6460:  18 FE 25 75       ldy      $2575
6464:  18 A6 00          ldaa     0, y
6467:  18 3C             pshy     
6469:  13 FC 02 08       brclr    $fc, #2, $6475 ; $6475=loc_6475
646D:  BA 25 78          oraa     $2578
6470:  15 FC 02          bclr     $fc, #2
6473:  20 16             bra      $648b ; $648B=loc_648B

loc_6475:
6475:  C1 70             cmpb     #112 ; xrefs $6469:branch
6477:  27 4E             beq      $64c7 ; $64C7=loc_64C7
6479:  18 CE 26 00       ldy      #9728
647D:  18 3A             aby      
647F:  B4 25 78          anda     $2578
6482:  27 1A             beq      $649e ; $649E=loc_649E
6484:  18 EC 0E          ldd      14, y
6487:  A3 0E             subd     14, x
6489:  26 13             bne      $649e ; $649E=loc_649E

loc_648B:
648B:  18 38             puly      ; xrefs $6473:branch
648D:  18 08             iny      
648F:  18 FF 25 75       sty      $2575
6493:  FC 25 73          ldd      $2573
6496:  C3 00 80          addd     #128
6499:  FD 25 73          std      $2573
649C:  20 47             bra      $64e5 ; $64E5=loc_64E5

loc_649E:
649E:  14 FC 02          bset     $fc, #2 ; xrefs $6482:branch, $6489:branch
64A1:  86 10             ldaa     #16
64A3:  B7 24 6D          staa     $246d
64A6:  FF 24 6E          stx      $246e
64A9:  3C                pshx     
64AA:  CE 24 72          ldx      #9330

loc_64AD:
64AD:  18 EC 00          ldd      0, y ; xrefs $64BB:branch
64B0:  ED 00             std      0, x
64B2:  08                inx      
64B3:  08                inx      
64B4:  18 08             iny      
64B6:  18 08             iny      
64B8:  8C 24 82          cpx      #9346
64BB:  2B F0             bmi      $64ad ; $64AD=loc_64AD
64BD:  86 1A             ldaa     #26
64BF:  B7 24 6B          staa     $246b
64C2:  38                pulx     
64C3:  18 38             puly     
64C5:  20 45             bra      $650c ; $650C=loc_650C

loc_64C7:
64C7:  14 FC 02          bset     $fc, #2 ; xrefs $6477:branch
64CA:  86 01             ldaa     #1
64CC:  B7 24 6D          staa     $246d
64CF:  F6 21 6E          ldab     $216e
64D2:  3A                abx      
64D3:  FF 24 6E          stx      $246e
64D6:  B6 21 73          ldaa     $2173
64D9:  B7 24 72          staa     $2472
64DC:  86 1A             ldaa     #26
64DE:  B7 24 6B          staa     $246b
64E1:  18 38             puly     
64E3:  20 27             bra      $650c ; $650C=loc_650C

loc_64E5:
64E5:  1A 83 B7 00       cpd      #-18688 ; xrefs $649C:branch
64E9:  22 02             bhi      $64ed ; $64ED=loc_64ED
64EB:  20 1F             bra      $650c ; $650C=loc_650C

loc_64ED:
64ED:  CC B6 00          ldd      #-18944 ; xrefs $64E9:branch
64F0:  FD 25 73          std      $2573
64F3:  CC 25 7A          ldd      #9594
64F6:  FD 25 75          std      $2575
64F9:  B6 25 77          ldaa     $2577
64FC:  B1 21 A3          cmpa     $21a3
64FF:  25 05             bcs      $6506 ; $6506=loc_6506
6501:  14 FC 01          bset     $fc, #1
6504:  20 06             bra      $650c ; $650C=loc_650C

loc_6506:
6506:  7C 25 77          inc      $2577 ; xrefs $64FF:branch
6509:  BD E3 2F          jsr      $e32f ; $E32F=sub_E32F

loc_650C:
650C:  39                rts       ; xrefs $6456:jump, $64C5:branch, $64E3:branch, $64EB:branch, $6504:branch

; [OPEN] Periodic state update.
runtime_state_650d:
650D:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $6C6A:call, $D37F:call
6510:  81 FF             cmpa     #-1
6512:  27 11             beq      $6525 ; $6525=loc_6525
6514:  81 07             cmpa     #7
6516:  25 25             bcs      $653d ; $653D=loc_653D
6518:  18 CE 21 A9       ldy      #8617
651C:  18 A6 05          ldaa     5, y
651F:  27 04             beq      $6525 ; $6525=loc_6525
6521:  4A                deca     
6522:  18 A7 05          staa     5, y

loc_6525:
6525:  13 AF 20 14       brclr    $af, #32, $653d ; $653D=loc_653D | xrefs $6512:branch, $651F:branch
6529:  12 B0 01 09       brset    $b0, #1, $6536 ; $6536=loc_6536
652D:  12 B0 04 0C       brset    $b0, #4, $653d ; $653D=loc_653D
6531:  7C 21 A7          inc      $21a7
6534:  20 07             bra      $653d ; $653D=loc_653D

loc_6536:
6536:  13 B0 04 03       brclr    $b0, #4, $653d ; $653D=loc_653D | xrefs $6529:branch
653A:  7C 21 A7          inc      $21a7

loc_653D:
653D:  13 B0 80 09       brclr    $b0, #-128, $654a ; $654A=loc_654A | xrefs $6516:branch, $6525:branch, $652D:branch, $6534:branch, $6536:branch
6541:  B6 21 A8          ldaa     $21a8
6544:  27 04             beq      $654a ; $654A=loc_654A
6546:  4A                deca     
6547:  B7 21 A8          staa     $21a8

loc_654A:
654A:  39                rts       ; xrefs $653D:branch, $6544:branch

; ---- unreached/data gap $654B-$654B ----

        .org $654C

sub_654C:
654C:  12 AF 01 03       brset    $af, #1, $6553 ; $6553=loc_6553 | xrefs $96B3:call
6550:  7E 65 D6          jmp      $65d6 ; $65D6=loc_65D6

loc_6553:
6553:  BD 66 7C          jsr      $667c ; $667C=sub_667C | xrefs $654C:branch
6556:  12 AF 08 03       brset    $af, #8, $655d ; $655D=loc_655D
655A:  7E 65 A3          jmp      $65a3 ; $65A3=loc_65A3

loc_655D:
655D:  7D 21 A4          tst      $21a4 ; xrefs $6556:branch
6560:  2A 23             bpl      $6585 ; $6585=loc_6585
6562:  12 A8 08 02       brset    $a8, #8, $6568 ; $6568=sub_6568
6566:  20 1D             bra      $6585 ; $6585=loc_6585

sub_6568:
6568:  0F                sei       ; xrefs $6562:branch, $6E55:call
6569:  7F 21 A4          clr      $21a4
656C:  4F                clra     
656D:  CE 00 12          ldx      #18
6570:  DF 5B             stx      $5b

loc_6572:
6572:  A7 00             staa     0, x ; xrefs $6578:branch
6574:  08                inx      
6575:  8C 00 5A          cpx      #90
6578:  2F F8             ble      $6572 ; $6572=loc_6572
657A:  0E                cli      
657B:  BD 63 6C          jsr      $636c ; $636C=sub_636C
657E:  86 11             ldaa     #17
6580:  B7 21 BC          staa     $21bc
6583:  20 51             bra      $65d6 ; $65D6=loc_65D6

loc_6585:
6585:  12 A8 04 03       brset    $a8, #4, $658c ; $658C=loc_658C | xrefs $6560:branch, $6566:branch
6589:  7E 65 D6          jmp      $65d6 ; $65D6=loc_65D6

loc_658C:
658C:  15 AF 08          bclr     $af, #8 ; xrefs $6585:branch
658F:  7F 21 AF          clr      $21af
6592:  18 CE 21 A9       ldy      #8617
6596:  BD 69 CF          jsr      $69cf ; $69CF=sub_69CF
6599:  86 12             ldaa     #18
659B:  18 A7 02          staa     2, y
659E:  86 07             ldaa     #7
65A0:  7E 65 CD          jmp      $65cd ; $65CD=loc_65CD

loc_65A3:
65A3:  12 A8 01 11       brset    $a8, #1, $65b8 ; $65B8=loc_65B8 | xrefs $655A:jump
65A7:  7D 00 A8          tst      >$00a8
65AA:  26 03             bne      $65af ; $65AF=loc_65AF
65AC:  7E 65 D6          jmp      $65d6 ; $65D6=loc_65D6

loc_65AF:
65AF:  15 AF 06          bclr     $af, #6 ; xrefs $65AA:branch
65B2:  14 AF 08          bset     $af, #8
65B5:  7E 65 D6          jmp      $65d6 ; $65D6=loc_65D6

loc_65B8:
65B8:  15 AF 06          bclr     $af, #6 ; xrefs $65A3:branch
65BB:  7F 21 B2          clr      $21b2
65BE:  18 CE 21 A9       ldy      #8617
65C2:  7F 21 A7          clr      $21a7
65C5:  14 AF 20          bset     $af, #32
65C8:  14 B0 01          bset     $b0, #1
65CB:  86 FE             ldaa     #-2

loc_65CD:
65CD:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector | xrefs $65A0:jump
65D0:  15 AF 01          bclr     $af, #1
65D3:  18 6F 03          clr      3, y

loc_65D6:
65D6:  39                rts       ; xrefs $6550:jump, $6583:branch, $6589:jump, $65AC:jump, $65B5:jump

; ---- unreached/data gap $65D7-$65D7 ----

        .org $65D8

sub_65D8:
65D8:  BD 66 3D          jsr      $663d ; $663D=sub_663D | xrefs $6CFE:call, $D6A6:call
65DB:  12 AF 08 07       brset    $af, #8, $65e6 ; $65E6=loc_65E6
65DF:  12 A8 20 03       brset    $a8, #32, $65e6 ; $65E6=loc_65E6
65E3:  7E 66 22          jmp      $6622 ; $6622=loc_6622

loc_65E6:
65E6:  12 A9 02 11       brset    $a9, #2, $65fb ; $00A9=operating_mode_flags, $65FB=loc_65FB | xrefs $65DB:branch, $65DF:branch
65EA:  12 B0 80 31       brset    $b0, #-128, $661f ; $661F=loc_661F
65EE:  14 B0 80          bset     $b0, #-128
65F1:  86 17             ldaa     #23
65F3:  B7 21 A8          staa     $21a8
65F6:  BD 66 54          jsr      $6654 ; $6654=sub_6654
65F9:  20 24             bra      $661f ; $661F=loc_661F

loc_65FB:
65FB:  12 A4 80 11       brset    $a4, #-128, $6610 ; $00A4=limiter_mode_flags, $6610=loc_6610 | xrefs $65E6:branch
65FF:  7D 21 A8          tst      $21a8
6602:  26 1B             bne      $661f ; $661F=loc_661F
6604:  13 B0 80 17       brclr    $b0, #-128, $661f ; $661F=loc_661F
6608:  15 B0 80          bclr     $b0, #-128
660B:  BD 66 5E          jsr      $665e ; $665E=sub_665E
660E:  20 0F             bra      $661f ; $661F=loc_661F

loc_6610:
6610:  86 26             ldaa     #38 ; xrefs $65FB:branch
6612:  B7 21 A8          staa     $21a8
6615:  12 B0 80 06       brset    $b0, #-128, $661f ; $661F=loc_661F
6619:  14 B0 80          bset     $b0, #-128
661C:  BD 66 54          jsr      $6654 ; $6654=sub_6654

loc_661F:
661F:  7E 66 3B          jmp      $663b ; $663B=loc_663B | xrefs $65EA:branch, $65F9:branch, $6602:branch, $6604:branch, $660E:branch, $6615:branch

loc_6622:
6622:  CE 10 00          ldx      #4096 ; xrefs $65E3:jump
6625:  13 AF 10 08       brclr    $af, #16, $6631 ; $6631=loc_6631
6629:  1D 08 02          bclr     8, x; #2

loc_662C:
662C:  BD 66 54          jsr      $6654 ; $6654=sub_6654 | xrefs $6634:branch
662F:  20 0A             bra      $663b ; $663B=loc_663B

loc_6631:
6631:  1C 08 02          bset     8, x; #2 ; xrefs $6625:branch
6634:  13 B0 04 F4       brclr    $b0, #4, $662c ; $662C=loc_662C
6638:  BD 66 5E          jsr      $665e ; $665E=sub_665E

loc_663B:
663B:  39                rts       ; xrefs $661F:jump, $662F:branch

; ---- unreached/data gap $663C-$663C ----

        .org $663D

sub_663D:
663D:  3C                pshx      ; xrefs $65D8:call
663E:  13 AF 20 0C       brclr    $af, #32, $664e ; $664E=loc_664E
6642:  CE 10 00          ldx      #4096
6645:  1E 60 20 05       brset    96, x; #32; $664e ; $664E=loc_664E
6649:  15 B0 04          bclr     $b0, #4
664C:  20 03             bra      $6651 ; $6651=loc_6651

loc_664E:
664E:  14 B0 04          bset     $b0, #4 ; xrefs $663E:branch, $6645:branch

loc_6651:
6651:  38                pulx      ; xrefs $664C:branch
6652:  39                rts      

; ---- unreached/data gap $6653-$6653 ----

        .org $6654

sub_6654:
6654:  3C                pshx      ; xrefs $65F6:call, $661C:call, $662C:call
6655:  CE 10 00          ldx      #4096
6658:  1C 40 04          bset     64, x; #4
665B:  38                pulx     
665C:  39                rts      

; ---- unreached/data gap $665D-$665D ----

        .org $665E

sub_665E:
665E:  3C                pshx      ; xrefs $660B:call, $6638:call
665F:  CE 10 00          ldx      #4096
6662:  1D 40 04          bclr     64, x; #4
6665:  38                pulx     
6666:  39                rts      

; ---- unreached/data gap $6667-$667B ----

        .org $667C

sub_667C:
667C:  B6 21 A7          ldaa     $21a7 ; xrefs $6553:call, $690D:call, $6A12:call, $6C06:call
667F:  15 A8 FF          bclr     $a8, #-1
6682:  13 B0 01 03       brclr    $b0, #1, $6689 ; $6689=loc_6689
6686:  7E 66 CA          jmp      $66ca ; $66CA=loc_66CA

loc_6689:
6689:  12 B0 04 03       brset    $b0, #4, $6690 ; $6690=loc_6690 | xrefs $6682:branch
668D:  7E 66 B9          jmp      $66b9 ; $66B9=loc_66B9

loc_6690:
6690:  CE 66 68          ldx      #26216 ; xrefs $6689:branch

loc_6693:
6693:  A1 00             cmpa     0, x ; xrefs $6698:branch
6695:  23 03             bls      $669a ; $669A=loc_669A
6697:  08                inx      
6698:  20 F9             bra      $6693 ; $6693=loc_6693

loc_669A:
669A:  8F                xgdx      ; xrefs $6695:branch
669B:  83 66 68          subd     #26216
669E:  CE 66 72          ldx      #26226
66A1:  3A                abx      
66A2:  E6 00             ldab     0, x
66A4:  D7 A8             stab     $a8
66A6:  13 A8 02 0A       brclr    $a8, #2, $66b4 ; $66B4=loc_66B4
66AA:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
66AD:  81 FF             cmpa     #-1
66AF:  26 03             bne      $66b4 ; $66B4=loc_66B4
66B1:  BD 66 FA          jsr      $66fa ; $66FA=sub_66FA

loc_66B4:
66B4:  7F 21 A7          clr      $21a7 ; xrefs $66A6:branch, $66AF:branch
66B7:  20 3F             bra      $66f8 ; $66F8=loc_66F8

loc_66B9:
66B9:  81 C0             cmpa     #-64 ; xrefs $668D:jump
66BB:  23 3B             bls      $66f8 ; $66F8=loc_66F8
66BD:  86 FF             ldaa     #-1
66BF:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
66C2:  15 AF 01          bclr     $af, #1
66C5:  14 A8 20          bset     $a8, #32
66C8:  20 2E             bra      $66f8 ; $66F8=loc_66F8

loc_66CA:
66CA:  12 B0 04 02       brset    $b0, #4, $66d0 ; $66D0=loc_66D0 | xrefs $6686:jump
66CE:  20 13             bra      $66e3 ; $66E3=loc_66E3

loc_66D0:
66D0:  81 1B             cmpa     #27 ; xrefs $66CA:branch
66D2:  25 24             bcs      $66f8 ; $66F8=loc_66F8
66D4:  14 A8 80          bset     $a8, #-128
66D7:  81 26             cmpa     #38
66D9:  25 1D             bcs      $66f8 ; $66F8=loc_66F8
66DB:  14 A8 01          bset     $a8, #1
66DE:  7F 21 A7          clr      $21a7
66E1:  20 15             bra      $66f8 ; $66F8=loc_66F8

loc_66E3:
66E3:  81 4C             cmpa     #76 ; xrefs $66CE:branch
66E5:  24 0E             bcc      $66f5 ; $66F5=loc_66F5
66E7:  81 04             cmpa     #4
66E9:  25 0A             bcs      $66f5 ; $66F5=loc_66F5
66EB:  81 26             cmpa     #38
66ED:  25 03             bcs      $66f2 ; $66F2=loc_66F2
66EF:  14 A8 20          bset     $a8, #32

loc_66F2:
66F2:  14 A8 40          bset     $a8, #64 ; xrefs $66ED:branch

loc_66F5:
66F5:  7F 21 A7          clr      $21a7 ; xrefs $66E5:branch, $66E9:branch

loc_66F8:
66F8:  39                rts       ; xrefs $66B7:branch, $66BB:branch, $66C8:branch, $66D2:branch, $66D9:branch, $66E1:branch

; ---- unreached/data gap $66F9-$66F9 ----

        .org $66FA

sub_66FA:
66FA:  86 0D             ldaa     #13 ; xrefs $66B1:call
66FC:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
66FF:  15 AF 01          bclr     $af, #1
6702:  CC 67 B6          ldd      #26550
6705:  FD 24 1E          std      $241e
6708:  C6 08             ldab     #8
670A:  F7 24 15          stab     $2415
670D:  C6 09             ldab     #9
670F:  F7 24 14          stab     $2414
6712:  13 A8 02 09       brclr    $a8, #2, $671f ; $671F=loc_671F
6716:  F6 91 70          ldab     $9170
6719:  27 04             beq      $671f ; $671F=loc_671F
671B:  C6 31             ldab     #49
671D:  20 02             bra      $6721 ; $6721=loc_6721

loc_671F:
671F:  C6 30             ldab     #48 ; xrefs $6712:branch, $6719:branch

loc_6721:
6721:  F7 10 2B          stab     $102b ; $102B=BAUD | xrefs $671D:branch
6724:  3C                pshx     
6725:  CE 10 00          ldx      #4096
6728:  1C 2D 48          bset     45, x; #72
672B:  38                pulx     
672C:  39                rts      

; ---- unreached/data gap $672D-$672D ----

        .org $672E

sub_672E:
672E:  18 CE 21 A9       ldy      #8617 ; xrefs $6836:call, $690A:call, $6A15:call, $6CFB:call
6732:  18 6D 00          tst      0, y
6735:  26 5C             bne      $6793 ; $6793=loc_6793
6737:  18 A6 01          ldaa     1, y
673A:  26 0B             bne      $6747 ; $6747=loc_6747
673C:  18 6D 05          tst      5, y
673F:  26 01             bne      $6742 ; $6742=loc_6742
6741:  43                coma     

loc_6742:
6742:  18 A7 00          staa     0, y ; xrefs $673F:branch
6745:  20 4C             bra      $6793 ; $6793=loc_6793

loc_6747:
6747:  18 6D 05          tst      5, y ; xrefs $673A:branch
674A:  26 47             bne      $6793 ; $6793=loc_6793
674C:  12 AF 10 24       brset    $af, #16, $6774 ; $6774=loc_6774
6750:  14 AF 10          bset     $af, #16
6753:  18 6D 04          tst      4, y
6756:  26 15             bne      $676d ; $676D=loc_676D
6758:  14 AF 40          bset     $af, #64
675B:  18 E6 02          ldab     2, y
675E:  C4 0F             andb     #15
6760:  18 E7 04          stab     4, y
6763:  18 6D 04          tst      4, y
6766:  26 05             bne      $676d ; $676D=loc_676D
6768:  15 AF 10          bclr     $af, #16
676B:  20 21             bra      $678e ; $678E=loc_678E

loc_676D:
676D:  86 02             ldaa     #2 ; xrefs $6756:branch, $6766:branch
676F:  18 A7 05          staa     5, y
6772:  20 1F             bra      $6793 ; $6793=loc_6793

loc_6774:
6774:  15 AF 10          bclr     $af, #16 ; xrefs $674C:branch
6777:  18 6A 04          dec      4, y
677A:  27 07             beq      $6783 ; $6783=loc_6783
677C:  86 04             ldaa     #4
677E:  18 A7 05          staa     5, y
6781:  20 10             bra      $6793 ; $6793=loc_6793

loc_6783:
6783:  12 AF 40 07       brset    $af, #64, $678e ; $678E=loc_678E | xrefs $677A:branch
6787:  86 0A             ldaa     #10
6789:  18 A7 05          staa     5, y
678C:  20 05             bra      $6793 ; $6793=loc_6793

loc_678E:
678E:  86 FF             ldaa     #-1 ; xrefs $676B:branch, $6783:branch
6790:  18 A7 00          staa     0, y

loc_6793:
6793:  39                rts       ; xrefs $6735:branch, $6745:branch, $674A:branch, $6772:branch, $6781:branch, $678C:branch

; ---- unreached/data gap $6794-$6794 ----

        .org $6795

sub_6795:
6795:  18 E6 02          ldab     2, y ; xrefs $69CB:call
6798:  54                lsrb     
6799:  54                lsrb     
679A:  54                lsrb     
679B:  54                lsrb     
679C:  C4 0F             andb     #15
679E:  18 E7 04          stab     4, y
67A1:  39                rts      

; ---- unreached/data gap $67A2-$67A2 ----

        .org $67A3

; [OPEN] Reset-time state-machine/communications initialization.
state_or_comms_init_67a3:
67A3:  14 B0 80          bset     $b0, #-128 ; xrefs $B91C:call
67A6:  86 17             ldaa     #23
67A8:  B7 21 A8          staa     $21a8
67AB:  CE 10 00          ldx      #4096
67AE:  1C 40 04          bset     64, x; #4
67B1:  39                rts      

; ---- unreached/data gap $67B2-$6835 ----

        .org $6836

; [OPEN] Mode handler selected by RAM 0x21A6.
mode_handler_6836:
6836:  BD 67 2E          jsr      $672e ; $672E=sub_672E | xrefs $D42B:call
6839:  CE 68 30          ldx      #26672
683C:  F6 21 AF          ldab     $21af
683F:  58                aslb     
6840:  3A                abx      
6841:  EE 00             ldx      0, x
6843:  18 CE 21 A9       ldy      #8617
6847:  6E 00             jmp      0, x

; ---- unreached/data gap $6849-$68F2 ----

        .org $68F3

; [OPEN] Mode handler selected by RAM 0x21A6.
mode_handler_68f3:
68F3:  13 A9 02 13       brclr    $a9, #2, $690a ; $00A9=operating_mode_flags, $690A=loc_690A | xrefs $D434:call
68F7:  86 FF             ldaa     #-1
68F9:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
68FC:  14 AF 09          bset     $af, #9
68FF:  15 B0 81          bclr     $b0, #-127
6902:  7F 21 A7          clr      $21a7
6905:  7F 21 AF          clr      $21af
6908:  20 39             bra      $6943 ; $6943=loc_6943

loc_690A:
690A:  BD 67 2E          jsr      $672e ; $672E=sub_672E | xrefs $68F3:branch
690D:  BD 66 7C          jsr      $667c ; $667C=sub_667C
6910:  CE 68 E9          ldx      #26857
6913:  F6 21 B2          ldab     $21b2
6916:  58                aslb     
6917:  3A                abx      
6918:  EE 00             ldx      0, x
691A:  18 CE 21 A9       ldy      #8617
691E:  6E 00             jmp      0, x

; ---- unreached/data gap $6920-$6942 ----

        .org $6943

loc_6943:
6943:  39                rts       ; xrefs $6908:branch

; ---- unreached/data gap $6944-$69B7 ----

        .org $69B8

sub_69B8:
69B8:  14 AF 10          bset     $af, #16 ; xrefs $6C56:call
69BB:  86 02             ldaa     #2
69BD:  18 A7 05          staa     5, y
69C0:  86 FF             ldaa     #-1
69C2:  18 A7 01          staa     1, y
69C5:  18 6F 00          clr      0, y
69C8:  15 AF 40          bclr     $af, #64
69CB:  BD 67 95          jsr      $6795 ; $6795=sub_6795
69CE:  39                rts      

sub_69CF:
69CF:  15 AF 30          bclr     $af, #48 ; xrefs $6596:call, $6C13:call
69D2:  18 6F 01          clr      1, y
69D5:  86 1B             ldaa     #27
69D7:  18 A7 05          staa     5, y
69DA:  18 6F 00          clr      0, y
69DD:  39                rts      

sub_69DE:
69DE:  CE 26 00          ldx      #9728 ; xrefs $4BEC:call, $4C11:call, $6A3E:call
69E1:  3A                abx      
69E2:  FF 21 BA          stx      $21ba
69E5:  FC 21 BA          ldd      $21ba
69E8:  C3 00 0E          addd     #14
69EB:  FD 21 BA          std      $21ba
69EE:  CC 55 AA          ldd      #21930

loc_69F1:
69F1:  A3 00             subd     0, x ; xrefs $69F8:branch
69F3:  08                inx      
69F4:  08                inx      
69F5:  BC 21 BA          cpx      $21ba
69F8:  25 F7             bcs      $69f1 ; $69F1=loc_69F1
69FA:  FE 21 BA          ldx      $21ba
69FD:  ED 00             std      0, x
69FF:  39                rts      

; ---- unreached/data gap $6A00-$6A11 ----

        .org $6A12

; [OPEN] Mode handler selected by RAM 0x21A6.
mode_handler_6a12:
6A12:  BD 66 7C          jsr      $667c ; $667C=sub_667C | xrefs $D444:call, $D44D:call
6A15:  BD 67 2E          jsr      $672e ; $672E=sub_672E
6A18:  CE 6A 00          ldx      #27136
6A1B:  F6 21 B0          ldab     $21b0
6A1E:  58                aslb     
6A1F:  3A                abx      
6A20:  EE 00             ldx      0, x
6A22:  18 CE 21 A9       ldy      #8617
6A26:  6E 00             jmp      0, x

; ---- unreached/data gap $6A28-$6A2B ----

        .org $6A2C

sub_6A2C:
6A2C:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $6E2A:call, $6E3E:call
6A2F:  81 0A             cmpa     #10
6A31:  26 09             bne      $6a3c ; $6A3C=loc_6A3C
6A33:  12 A9 02 05       brset    $a9, #2, $6a3c ; $00A9=operating_mode_flags, $6A3C=loc_6A3C
6A37:  7F 26 10          clr      $2610
6A3A:  20 2B             bra      $6a67 ; $6A67=loc_6A67

loc_6A3C:
6A3C:  C6 10             ldab     #16 ; xrefs $6A31:branch, $6A33:branch
6A3E:  BD 69 DE          jsr      $69de ; $69DE=sub_69DE
6A41:  13 FC 01 22       brclr    $fc, #1, $6a67 ; $6A67=loc_6A67
6A45:  15 FC 01          bclr     $fc, #1
6A48:  86 02             ldaa     #2
6A4A:  B7 25 77          staa     $2577
6A4D:  B7 21 A3          staa     $21a3
6A50:  B7 25 78          staa     $2578
6A53:  7C 21 B0          inc      $21b0
6A56:  20 0F             bra      $6a67 ; $6A67=loc_6A67

; ---- unreached/data gap $6A58-$6A66 ----

        .org $6A67

loc_6A67:
6A67:  39                rts       ; xrefs $6A3A:branch, $6A41:branch, $6A56:branch

; ---- unreached/data gap $6A68-$6AEA ----

        .org $6AEB

sub_6AEB:
6AEB:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $6DFD:call, $6E1B:call
6AEE:  81 09             cmpa     #9
6AF0:  27 03             beq      $6af5 ; $6AF5=loc_6AF5
6AF2:  7E 6B 27          jmp      $6b27 ; $6B27=loc_6B27

loc_6AF5:
6AF5:  86 32             ldaa     #50 ; xrefs $6AF0:branch
6AF7:  B7 21 BC          staa     $21bc
6AFA:  F6 26 11          ldab     $2611
6AFD:  F0 92 8C          subb     $928c
6B00:  2B 19             bmi      $6b1b ; $6B1B=loc_6B1B
6B02:  F7 26 11          stab     $2611
6B05:  CE 00 00          ldx      #0
6B08:  F6 92 8C          ldab     $928c
6B0B:  3A                abx      
6B0C:  F6 26 11          ldab     $2611
6B0F:  4F                clra     
6B10:  02                idiv     
6B11:  8F                xgdx     
6B12:  5D                tstb     
6B13:  26 02             bne      $6b17 ; $6B17=loc_6B17
6B15:  C6 09             ldab     #9

loc_6B17:
6B17:  CA 10             orab     #16 ; xrefs $6B13:branch
6B19:  20 30             bra      $6b4b ; $6B4B=loc_6B4B

loc_6B1B:
6B1B:  86 39             ldaa     #57 ; xrefs $6B00:branch
6B1D:  B7 21 BC          staa     $21bc
6B20:  7F 26 11          clr      $2611
6B23:  C6 99             ldab     #-103
6B25:  20 24             bra      $6b4b ; $6B4B=loc_6B4B

loc_6B27:
6B27:  86 22             ldaa     #34 ; xrefs $6AF2:jump
6B29:  B7 21 BC          staa     $21bc
6B2C:  F6 26 10          ldab     $2610
6B2F:  F0 21 B3          subb     $21b3
6B32:  F1 92 88          cmpb     $9288
6B35:  2B 07             bmi      $6b3e ; $6B3E=loc_6B3E
6B37:  F7 26 10          stab     $2610
6B3A:  C6 22             ldab     #34
6B3C:  20 0D             bra      $6b4b ; $6B4B=loc_6B4B

loc_6B3E:
6B3E:  86 29             ldaa     #41 ; xrefs $6B35:branch
6B40:  B7 21 BC          staa     $21bc
6B43:  F6 92 88          ldab     $9288
6B46:  F7 26 10          stab     $2610
6B49:  C6 99             ldab     #-103

loc_6B4B:
6B4B:  18 E7 02          stab     2, y ; xrefs $6B19:branch, $6B25:branch, $6B3C:branch
6B4E:  86 03             ldaa     #3
6B50:  B7 21 B0          staa     $21b0
6B53:  39                rts      

sub_6B54:
6B54:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $6DEB:call, $6E0C:call
6B57:  81 09             cmpa     #9
6B59:  27 03             beq      $6b5e ; $6B5E=loc_6B5E
6B5B:  7E 6B 91          jmp      $6b91 ; $6B91=loc_6B91

loc_6B5E:
6B5E:  86 31             ldaa     #49 ; xrefs $6B59:branch
6B60:  B7 21 BC          staa     $21bc
6B63:  F6 26 11          ldab     $2611
6B66:  FB 92 8C          addb     $928c
6B69:  F1 92 8B          cmpb     $928b
6B6C:  22 14             bhi      $6b82 ; $6B82=loc_6B82
6B6E:  F7 26 11          stab     $2611
6B71:  CE 00 00          ldx      #0
6B74:  F6 92 8C          ldab     $928c
6B77:  3A                abx      
6B78:  F6 26 11          ldab     $2611
6B7B:  4F                clra     
6B7C:  02                idiv     
6B7D:  8F                xgdx     
6B7E:  CA 10             orab     #16
6B80:  20 33             bra      $6bb5 ; $6BB5=loc_6BB5

loc_6B82:
6B82:  86 39             ldaa     #57 ; xrefs $6B6C:branch
6B84:  B7 21 BC          staa     $21bc
6B87:  F6 92 8B          ldab     $928b
6B8A:  F7 26 11          stab     $2611
6B8D:  C6 99             ldab     #-103
6B8F:  20 24             bra      $6bb5 ; $6BB5=loc_6BB5

loc_6B91:
6B91:  86 21             ldaa     #33 ; xrefs $6B5B:jump
6B93:  B7 21 BC          staa     $21bc
6B96:  F6 26 10          ldab     $2610
6B99:  FB 21 B3          addb     $21b3
6B9C:  F1 92 87          cmpb     $9287
6B9F:  2C 07             bge      $6ba8 ; $6BA8=loc_6BA8
6BA1:  F7 26 10          stab     $2610
6BA4:  C6 11             ldab     #17
6BA6:  20 0D             bra      $6bb5 ; $6BB5=loc_6BB5

loc_6BA8:
6BA8:  86 29             ldaa     #41 ; xrefs $6B9F:branch
6BAA:  B7 21 BC          staa     $21bc
6BAD:  F6 92 87          ldab     $9287
6BB0:  F7 26 10          stab     $2610
6BB3:  C6 99             ldab     #-103

loc_6BB5:
6BB5:  18 E7 02          stab     2, y ; xrefs $6B80:branch, $6B8F:branch, $6BA6:branch
6BB8:  86 03             ldaa     #3
6BBA:  B7 21 B0          staa     $21b0
6BBD:  39                rts      

; [OPEN] Mode handler selected by RAM 0x21A6.
mode_handler_6bbe:
6BBE:  8D 0B             bsr      $6bcb ; $6BCB=sub_6BCB | xrefs $D43D:jump
6BC0:  8D 59             bsr      $6c1b ; $6C1B=sub_6C1B

loc_6BC2:
6BC2:  8D 6D             bsr      $6c31 ; $6C31=sub_6C31 | xrefs $6BC9:branch
6BC4:  BD 6C 56          jsr      $6c56 ; $6C56=sub_6C56
6BC7:  8D 3D             bsr      $6c06 ; $6C06=sub_6C06
6BC9:  20 F7             bra      $6bc2 ; $6BC2=loc_6BC2

sub_6BCB:
6BCB:  0F                sei       ; xrefs $6BBE:call, $6E82:call
6BCC:  CE 10 00          ldx      #4096
6BCF:  B6 10 22          ldaa     $1022
6BD2:  B7 21 C4          staa     $21c4
6BD5:  B6 10 20          ldaa     $1020
6BD8:  B7 21 C5          staa     $21c5
6BDB:  B6 10 40          ldaa     $1040
6BDE:  B7 21 C2          staa     $21c2
6BE1:  B6 10 50          ldaa     $1050
6BE4:  B7 21 C3          staa     $21c3
6BE7:  B6 10 00          ldaa     $1000 ; $1000=PORTA
6BEA:  B7 21 C1          staa     $21c1
6BED:  1D 24 20          bclr     36, x; #32
6BF0:  7F 10 22          clr      $1022
6BF3:  86 FF             ldaa     #-1
6BF5:  B7 10 23          staa     $1023 ; $1023=TFLG1
6BF8:  86 20             ldaa     #32
6BFA:  B7 10 25          staa     $1025 ; $1025=TFLG2
6BFD:  BD 6D 33          jsr      $6d33 ; $6D33=sub_6D33
6C00:  0E                cli      
6C01:  18 CE 21 A9       ldy      #8617
6C05:  39                rts      

sub_6C06:
6C06:  BD 66 7C          jsr      $667c ; $667C=sub_667C | xrefs $6BC7:call, $6C09:branch
6C09:  13 A8 04 F9       brclr    $a8, #4, $6c06 ; $6C06=sub_6C06
6C0D:  BD 6D 33          jsr      $6d33 ; $6D33=sub_6D33
6C10:  7F 21 B6          clr      $21b6
6C13:  BD 69 CF          jsr      $69cf ; $69CF=sub_69CF

loc_6C16:
6C16:  18 A6 00          ldaa     0, y ; xrefs $6C19:branch
6C19:  27 FB             beq      $6c16 ; $6C16=loc_6C16

sub_6C1B:
6C1B:  CE 55 B2          ldx      #21938 ; xrefs $6BC0:call
6C1E:  F6 21 B1          ldab     $21b1
6C21:  5C                incb     
6C22:  C1 04             cmpb     #4
6C24:  23 01             bls      $6c27 ; $6C27=loc_6C27
6C26:  5F                clrb     

loc_6C27:
6C27:  F7 21 B1          stab     $21b1 ; xrefs $6C24:branch
6C2A:  3A                abx      
6C2B:  A6 00             ldaa     0, x
6C2D:  18 A7 02          staa     2, y
6C30:  39                rts      

sub_6C31:
6C31:  86 03             ldaa     #3 ; xrefs $6BC2:call, $6D99:call
6C33:  B7 10 50          staa     $1050
6C36:  86 05             ldaa     #5
6C38:  B7 21 B7          staa     $21b7
6C3B:  86 80             ldaa     #-128
6C3D:  B7 21 B8          staa     $21b8

loc_6C40:
6C40:  B6 21 B7          ldaa     $21b7 ; xrefs $6C43:branch
6C43:  26 FB             bne      $6c40 ; $6C40=loc_6C40
6C45:  86 01             ldaa     #1
6C47:  B7 21 B7          staa     $21b7
6C4A:  86 FF             ldaa     #-1
6C4C:  B7 21 B8          staa     $21b8
6C4F:  B6 92 8D          ldaa     $928d
6C52:  B7 21 B6          staa     $21b6
6C55:  39                rts      

sub_6C56:
6C56:  BD 69 B8          jsr      $69b8 ; $69B8=sub_69B8 | xrefs $6BC4:call

loc_6C59:
6C59:  18 A6 00          ldaa     0, y ; xrefs $6C5C:branch
6C5C:  27 FB             beq      $6c59 ; $6C59=loc_6C59
6C5E:  7F 21 A7          clr      $21a7
6C61:  14 AF 20          bset     $af, #32
6C64:  39                rts      

; ---- unreached/data gap $6C65-$6C69 ----

        .org $6C6A

loc_6C6A:
6C6A:  BD 65 0D          jsr      $650d ; $650D=runtime_state_650d | xrefs $7303:jump

loc_6C6D:
6C6D:  B6 21 B6          ldaa     $21b6 ; xrefs $72FA:jump
6C70:  27 0B             beq      $6c7d ; $6C7D=loc_6C7D
6C72:  4A                deca     
6C73:  B7 21 B6          staa     $21b6
6C76:  26 12             bne      $6c8a ; $6C8A=loc_6C8A
6C78:  BD 6D 33          jsr      $6d33 ; $6D33=sub_6D33
6C7B:  20 7D             bra      $6cfa ; $6CFA=loc_6CFA

loc_6C7D:
6C7D:  CE 10 00          ldx      #4096 ; xrefs $6C70:branch
6C80:  1F 80 20 76       brclr    128, x; #32; $6cfa ; $6CFA=loc_6CFA

loc_6C84:
6C84:  4F                clra      ; xrefs $6C88:branch
6C85:  B7 10 50          staa     $1050
6C88:  20 FA             bra      $6c84 ; $6C84=loc_6C84

loc_6C8A:
6C8A:  B6 21 B7          ldaa     $21b7 ; xrefs $6C76:branch
6C8D:  4A                deca     
6C8E:  26 67             bne      $6cf7 ; $6CF7=loc_6CF7
6C90:  F6 21 B1          ldab     $21b1
6C93:  C1 02             cmpb     #2
6C95:  27 29             beq      $6cc0 ; $6CC0=loc_6CC0
6C97:  C1 01             cmpb     #1
6C99:  27 45             beq      $6ce0 ; $6CE0=loc_6CE0
6C9B:  CE 6C 65          ldx      #27749
6C9E:  3A                abx      
6C9F:  A6 00             ldaa     0, x
6CA1:  B4 21 B8          anda     $21b8
6CA4:  C1 04             cmpb     #4
6CA6:  26 07             bne      $6caf ; $6CAF=loc_6CAF
6CA8:  B7 10 40          staa     $1040
6CAB:  86 01             ldaa     #1
6CAD:  20 05             bra      $6cb4 ; $6CB4=loc_6CB4

loc_6CAF:
6CAF:  5D                tstb      ; xrefs $6CA6:branch
6CB0:  27 02             beq      $6cb4 ; $6CB4=loc_6CB4
6CB2:  8A 01             oraa     #1

loc_6CB4:
6CB4:  8A 02             oraa     #2 ; xrefs $6CAD:branch, $6CB0:branch
6CB6:  B7 10 50          staa     $1050
6CB9:  86 04             ldaa     #4
6CBB:  73 21 B8          com      $21b8
6CBE:  20 37             bra      $6cf7 ; $6CF7=loc_6CF7

loc_6CC0:
6CC0:  86 12             ldaa     #18 ; xrefs $6C95:branch
6CC2:  B7 10 50          staa     $1050
6CC5:  C6 FF             ldab     #-1
6CC7:  D7 5F             stab     $5f
6CC9:  13 A5 08 2D       brclr    $a5, #8, $6cfa ; $6CFA=loc_6CFA
6CCD:  B6 21 B8          ldaa     $21b8
6CD0:  26 06             bne      $6cd8 ; $6CD8=loc_6CD8
6CD2:  C6 F0             ldab     #-16
6CD4:  D7 5D             stab     $5d
6CD6:  C6 80             ldab     #-128

loc_6CD8:
6CD8:  F7 20 A4          stab     $20a4 ; xrefs $6CD0:branch
6CDB:  73 21 B8          com      $21b8
6CDE:  20 1A             bra      $6cfa ; $6CFA=loc_6CFA

loc_6CE0:
6CE0:  CE 10 00          ldx      #4096 ; xrefs $6C99:branch
6CE3:  1C 20 30          bset     32, x; #48
6CE6:  1C 0B 20          bset     11, x; #32
6CE9:  FC 92 8E          ldd      $928e
6CEC:  F3 10 0E          addd     $100e ; $100E=TCNT
6CEF:  FD 10 1A          std      $101a
6CF2:  1D 20 10          bclr     32, x; #16
6CF5:  86 08             ldaa     #8

loc_6CF7:
6CF7:  B7 21 B7          staa     $21b7 ; xrefs $6C8E:branch, $6CBE:branch

loc_6CFA:
6CFA:  3B                rti       ; xrefs $6C7B:branch, $6C80:branch, $6CC9:branch, $6CDE:branch

loc_6CFB:
6CFB:  BD 67 2E          jsr      $672e ; $672E=sub_672E | xrefs $9607:jump
6CFE:  BD 65 D8          jsr      $65d8 ; $65D8=sub_65D8

loc_6D01:
6D01:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $9615:jump
6D04:  81 08             cmpa     #8
6D06:  27 0B             beq      $6d13 ; $6D13=loc_6D13
6D08:  81 0D             cmpa     #13
6D0A:  26 10             bne      $6d1c ; $6D1C=loc_6D1C
6D0C:  B6 21 C0          ldaa     $21c0
6D0F:  81 BB             cmpa     #-69
6D11:  26 09             bne      $6d1c ; $6D1C=loc_6D1C

loc_6D13:
6D13:  86 55             ldaa     #85 ; xrefs $6D06:branch
6D15:  B7 10 3A          staa     $103a ; $103A=COPRST
6D18:  43                coma     
6D19:  B7 10 3A          staa     $103a ; $103A=COPRST

loc_6D1C:
6D1C:  B6 21 B8          ldaa     $21b8 ; xrefs $6D0A:branch, $6D11:branch
6D1F:  81 80             cmpa     #-128
6D21:  26 05             bne      $6d28 ; $6D28=loc_6D28
6D23:  7A 21 B7          dec      $21b7
6D26:  20 0A             bra      $6d32 ; $6D32=loc_6D32

loc_6D28:
6D28:  B6 21 B1          ldaa     $21b1 ; xrefs $6D21:branch
6D2B:  81 02             cmpa     #2
6D2D:  26 03             bne      $6d32 ; $6D32=loc_6D32
6D2F:  BD C9 C8          jsr      $c9c8 ; $C9C8=sub_C9C8

loc_6D32:
6D32:  3B                rti       ; xrefs $6D26:branch, $6D2D:branch

sub_6D33:
6D33:  86 02             ldaa     #2 ; xrefs $6BFD:call, $6C0D:call, $6C78:call
6D35:  B7 10 50          staa     $1050
6D38:  4F                clra     
6D39:  B7 10 40          staa     $1040
6D3C:  B7 10 20          staa     $1020
6D3F:  B7 10 00          staa     $1000 ; $1000=PORTA
6D42:  39                rts      

; [OPEN] Mode handler selected by RAM 0x21A6.
mode_handler_6d43:
6D43:  B7 21 BD          staa     $21bd ; xrefs $D456:call
6D46:  B6 24 20          ldaa     $2420
6D49:  F6 24 21          ldab     $2421
6D4C:  F1 21 BE          cmpb     $21be
6D4F:  27 05             beq      $6d56 ; $6D56=loc_6D56
6D51:  F7 21 BE          stab     $21be
6D54:  20 2A             bra      $6d80 ; $6D80=loc_6D80

loc_6D56:
6D56:  F6 21 BF          ldab     $21bf ; xrefs $6D4F:branch
6D59:  C1 BB             cmpb     #-69
6D5B:  27 03             beq      $6d60 ; $6D60=loc_6D60
6D5D:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6D60:
6D60:  13 FC 01 19       brclr    $fc, #1, $6d7d ; $6D7D=loc_6D7D | xrefs $6D5B:branch
6D64:  14 B0 02          bset     $b0, #2
6D67:  C6 20             ldab     #32
6D69:  81 54             cmpa     #84
6D6B:  26 08             bne      $6d75 ; $6D75=loc_6D75
6D6D:  12 A9 02 06       brset    $a9, #2, $6d77 ; $00A9=operating_mode_flags, $6D77=loc_6D77
6D71:  C6 00             ldab     #0
6D73:  20 02             bra      $6d77 ; $6D77=loc_6D77

loc_6D75:
6D75:  C6 30             ldab     #48 ; xrefs $6D6B:branch

loc_6D77:
6D77:  F7 21 BC          stab     $21bc ; xrefs $6D6D:branch, $6D73:branch
6D7A:  7F 21 BF          clr      $21bf

loc_6D7D:
6D7D:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69 | xrefs $6D60:branch

loc_6D80:
6D80:  81 31             cmpa     #49 ; xrefs $6D54:branch
6D82:  25 5B             bcs      $6ddf ; $6DDF=loc_6DDF
6D84:  81 35             cmpa     #53
6D86:  22 57             bhi      $6ddf ; $6DDF=loc_6DDF
6D88:  13 A9 01 03       brclr    $a9, #1, $6d8f ; $00A9=operating_mode_flags, $6D8F=loc_6D8F
6D8C:  7E 6E 66          jmp      $6e66 ; $6E66=loc_6E66

loc_6D8F:
6D8F:  13 A9 02 03       brclr    $a9, #2, $6d96 ; $00A9=operating_mode_flags, $6D96=loc_6D96 | xrefs $6D88:branch
6D93:  7E 6E 66          jmp      $6e66 ; $6E66=loc_6E66

loc_6D96:
6D96:  BD 6E 70          jsr      $6e70 ; $6E70=sub_6E70 | xrefs $6D8F:branch
6D99:  BD 6C 31          jsr      $6c31 ; $6C31=sub_6C31
6D9C:  CE 10 00          ldx      #4096

loc_6D9F:
6D9F:  1E 25 20 05       brset    37, x; #32; $6da8 ; $6DA8=loc_6DA8 | xrefs $6DA6:branch
6DA3:  7D 21 B6          tst      $21b6
6DA6:  26 F7             bne      $6d9f ; $6D9F=loc_6D9F

loc_6DA8:
6DA8:  0F                sei       ; xrefs $6D9F:branch
6DA9:  B6 21 C4          ldaa     $21c4
6DAC:  B7 10 22          staa     $1022
6DAF:  B6 21 C5          ldaa     $21c5
6DB2:  B7 10 20          staa     $1020
6DB5:  96 5D             ldaa     $5d
6DB7:  B7 20 A4          staa     $20a4
6DBA:  B6 21 C2          ldaa     $21c2
6DBD:  B7 10 40          staa     $1040
6DC0:  B6 21 C3          ldaa     $21c3
6DC3:  B7 10 50          staa     $1050
6DC6:  B6 21 C1          ldaa     $21c1
6DC9:  B7 10 00          staa     $1000 ; $1000=PORTA
6DCC:  96 8B             ldaa     $8b
6DCE:  81 F0             cmpa     #-16
6DD0:  27 06             beq      $6dd8 ; $6DD8=loc_6DD8
6DD2:  14 8D 80          bset     $8d, #-128
6DD5:  1C 24 20          bset     36, x; #32

loc_6DD8:
6DD8:  7F 21 C0          clr      $21c0 ; xrefs $6DD0:branch
6DDB:  0E                cli      
6DDC:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6DDF:
6DDF:  81 51             cmpa     #81 ; xrefs $6D82:branch, $6D86:branch
6DE1:  26 0E             bne      $6df1 ; $6DF1=loc_6DF1
6DE3:  C6 0A             ldab     #10
6DE5:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6DE8:  BD 6E 86          jsr      $6e86 ; $6E86=sub_6E86
6DEB:  BD 6B 54          jsr      $6b54 ; $6B54=sub_6B54
6DEE:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6DF1:
6DF1:  81 52             cmpa     #82 ; xrefs $6DE1:branch
6DF3:  26 0E             bne      $6e03 ; $6E03=loc_6E03
6DF5:  C6 0A             ldab     #10
6DF7:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6DFA:  BD 6E 86          jsr      $6e86 ; $6E86=sub_6E86
6DFD:  BD 6A EB          jsr      $6aeb ; $6AEB=sub_6AEB
6E00:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6E03:
6E03:  81 61             cmpa     #97 ; xrefs $6DF3:branch
6E05:  26 0B             bne      $6e12 ; $6E12=loc_6E12
6E07:  C6 09             ldab     #9
6E09:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6E0C:  BD 6B 54          jsr      $6b54 ; $6B54=sub_6B54
6E0F:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6E12:
6E12:  81 62             cmpa     #98 ; xrefs $6E05:branch
6E14:  26 0B             bne      $6e21 ; $6E21=loc_6E21
6E16:  C6 09             ldab     #9
6E18:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6E1B:  BD 6A EB          jsr      $6aeb ; $6AEB=sub_6AEB
6E1E:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6E21:
6E21:  81 54             cmpa     #84 ; xrefs $6E14:branch
6E23:  26 10             bne      $6e35 ; $6E35=loc_6E35
6E25:  C6 0A             ldab     #10
6E27:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6E2A:  BD 6A 2C          jsr      $6a2c ; $6A2C=sub_6A2C
6E2D:  C6 BB             ldab     #-69
6E2F:  F7 21 BF          stab     $21bf
6E32:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6E35:
6E35:  81 64             cmpa     #100 ; xrefs $6E23:branch
6E37:  26 10             bne      $6e49 ; $6E49=loc_6E49
6E39:  C6 09             ldab     #9
6E3B:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6E3E:  BD 6A 2C          jsr      $6a2c ; $6A2C=sub_6A2C
6E41:  C6 BB             ldab     #-69
6E43:  F7 21 BF          stab     $21bf
6E46:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69

loc_6E49:
6E49:  81 01             cmpa     #1 ; xrefs $6E37:branch
6E4B:  26 0E             bne      $6e5b ; $6E5B=loc_6E5B
6E4D:  12 A9 01 07       brset    $a9, #1, $6e58 ; $00A9=operating_mode_flags, $6E58=loc_6E58
6E51:  12 A9 02 03       brset    $a9, #2, $6e58 ; $00A9=operating_mode_flags, $6E58=loc_6E58
6E55:  BD 65 68          jsr      $6568 ; $6568=sub_6568

loc_6E58:
6E58:  7E 6E 69          jmp      $6e69 ; $6E69=loc_6E69 | xrefs $6E4D:branch, $6E51:branch

loc_6E5B:
6E5B:  81 0E             cmpa     #14 ; xrefs $6E4B:branch
6E5D:  26 07             bne      $6e66 ; $6E66=loc_6E66
6E5F:  D6 8B             ldab     $8b
6E61:  F7 21 BC          stab     $21bc
6E64:  20 03             bra      $6e69 ; $6E69=loc_6E69

loc_6E66:
6E66:  7F 21 BC          clr      $21bc ; xrefs $6D8C:jump, $6D93:jump, $6E5D:branch

loc_6E69:
6E69:  F6 21 BD          ldab     $21bd ; xrefs $6D5D:jump, $6D7D:jump, $6DDC:jump, $6DEE:jump, $6E00:jump, $6E0F:jump, $6E1E:jump, $6E32:jump, +3 more
6E6C:  F7 21 A6          stab     $21a6 ; $21A6=operating_state_selector
6E6F:  39                rts      

sub_6E70:
6E70:  80 31             suba     #49 ; xrefs $6D96:call
6E72:  B7 21 B1          staa     $21b1
6E75:  8B 81             adda     #-127
6E77:  B7 21 BC          staa     $21bc
6E7A:  7F 21 B6          clr      $21b6
6E7D:  86 BB             ldaa     #-69
6E7F:  B7 21 C0          staa     $21c0
6E82:  BD 6B CB          jsr      $6bcb ; $6BCB=sub_6BCB
6E85:  39                rts      

sub_6E86:
6E86:  13 A9 02 05       brclr    $a9, #2, $6e8f ; $00A9=operating_mode_flags, $6E8F=loc_6E8F | xrefs $6DE8:call, $6DFA:call
6E8A:  B6 92 89          ldaa     $9289
6E8D:  20 03             bra      $6e92 ; $6E92=loc_6E92

loc_6E8F:
6E8F:  B6 92 8A          ldaa     $928a ; xrefs $6E86:branch

loc_6E92:
6E92:  B7 21 B3          staa     $21b3 ; xrefs $6E8D:branch
6E95:  39                rts      

; [STRONG] High-load/final fuel-duration support path.
high_load_final_fuel_stage:
6E96:  13 A3 80 40       brclr    $a3, #-128, $6eda ; $6EDA=loc_6EDA | xrefs $B45D:call, $B468:call
6E9A:  DC BF             ldd      $bf ; $00BF=fuel_event_width_limit
6E9C:  04                lsrd     
6E9D:  1A 93 C1          cpd      $c1 ; $00C1=base_fuel_pulse_accumulator
6EA0:  23 30             bls      $6ed2 ; $6ED2=loc_6ED2
6EA2:  14 A1 40          bset     $a1, #64
6EA5:  18 CE 21 D8       ldy      #8664
6EA9:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
6EAC:  80 01             suba     #1
6EAE:  05                asld     
6EAF:  81 04             cmpa     #4
6EB1:  25 03             bcs      $6eb6 ; $6EB6=loc_6EB6
6EB3:  CC 04 00          ldd      #1024

loc_6EB6:
6EB6:  18 ED 00          std      0, y ; xrefs $6EB1:branch
6EB9:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
6EBC:  18 ED 02          std      2, y
6EBF:  CE 85 BA          ldx      #-31302
6EC2:  CD EF 04          stx      4, y
6EC5:  86 05             ldaa     #5
6EC7:  18 A7 06          staa     6, y
6ECA:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
6ECD:  B7 20 63          staa     $2063
6ED0:  20 0B             bra      $6edd ; $6EDD=loc_6EDD

loc_6ED2:
6ED2:  F3 85 B8          addd     $85b8 ; xrefs $6EA0:branch
6ED5:  1A 93 C1          cpd      $c1 ; $00C1=base_fuel_pulse_accumulator
6ED8:  24 03             bcc      $6edd ; $6EDD=loc_6EDD

loc_6EDA:
6EDA:  15 A1 40          bclr     $a1, #64 ; xrefs $6E96:branch

loc_6EDD:
6EDD:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $6ED0:branch, $6ED8:branch
6EDF:  13 A1 40 07       brclr    $a1, #64, $6eea ; $6EEA=loc_6EEA
6EE3:  4F                clra     
6EE4:  F6 20 63          ldab     $2063
6EE7:  05                asld     
6EE8:  D3 C1             addd     $c1 ; $00C1=base_fuel_pulse_accumulator

loc_6EEA:
6EEA:  DD C3             std      $c3 ; $00C3=final_fuel_duration | xrefs $6EDF:branch
6EEC:  39                rts      

; ---- unreached/data gap $6EED-$6EED ----

        .org $6EEE

; [CONFIRMED] Fuel output scheduler/timing path using period and event-width support calibrations.
fuel_output_scheduler:
6EEE:  CE 10 00          ldx      #4096 ; xrefs $B454:call, $B46B:call
6EF1:  1F 22 80 0C       brclr    34, x; #-128; $6f01 ; $6F01=rpm_limiter_hysteresis
6EF5:  FC 10 0E          ldd      $100e ; $100E=TCNT
6EF8:  C3 00 04          addd     #4
6EFB:  FD 10 16          std      $1016
6EFE:  01                nop      
6EFF:  01                nop      
6F00:  01                nop      

; [CONFIRMED] Set/clear RAM 0x00A4 bit 0x10 from engine period and primary/alternate threshold pairs.
rpm_limiter_hysteresis:
6F01:  DC BA             ldd      $ba ; $00BA=engine_period_delta | begin RPM limiter set/clear hysteresis | xrefs $6EF1:branch
6F03:  13 A4 10 16       brclr    $a4, #16, $6f1d ; $00A4=limiter_mode_flags, $6F1D=loc_6F1D
6F07:  7D 21 4F          tst      $214f ; $214F=alternate_limiter_mode
6F0A:  27 06             beq      $6f12 ; $6F12=loc_6F12
6F0C:  1A B3 87 A4       cpd      $87a4 ; $87A4=rpm_limit_alternate_clear_period
6F10:  20 04             bra      $6f16 ; $6F16=loc_6F16

loc_6F12:
6F12:  1A B3 87 A0       cpd      $87a0 ; $87A0=rpm_limit_primary_clear_period | xrefs $6F0A:branch

loc_6F16:
6F16:  23 2A             bls      $6f42 ; $6F42=loc_6F42 | xrefs $6F10:branch
6F18:  15 A4 10          bclr     $a4, #16 ; $00A4=limiter_mode_flags
6F1B:  20 16             bra      $6f33 ; $6F33=loc_6F33

loc_6F1D:
6F1D:  7D 21 4F          tst      $214f ; $214F=alternate_limiter_mode | xrefs $6F03:branch
6F20:  27 06             beq      $6f28 ; $6F28=loc_6F28
6F22:  1A B3 87 A2       cpd      $87a2 ; $87A2=rpm_limit_alternate_set_period
6F26:  20 04             bra      $6f2c ; $6F2C=loc_6F2C

loc_6F28:
6F28:  1A B3 87 9E       cpd      $879e ; $879E=rpm_limit_primary_set_period | xrefs $6F20:branch

loc_6F2C:
6F2C:  24 05             bcc      $6f33 ; $6F33=loc_6F33 | xrefs $6F26:branch
6F2E:  14 A4 10          bset     $a4, #16 ; $00A4=limiter_mode_flags
6F31:  20 0F             bra      $6f42 ; $6F42=loc_6F42

loc_6F33:
6F33:  13 A3 44 11       brclr    $a3, #68, $6f48 ; $6F48=loc_6F48 | xrefs $6F1B:branch, $6F2C:branch
6F37:  12 A3 04 07       brset    $a3, #4, $6f42 ; $6F42=loc_6F42
6F3B:  12 AA 20 64       brset    $aa, #32, $6fa3 ; $6FA3=loc_6FA3
6F3F:  7E 6F E2          jmp      $6fe2 ; $6FE2=loc_6FE2

loc_6F42:
6F42:  14 AA 02          bset     $aa, #2 ; xrefs $6F16:branch, $6F31:branch, $6F37:branch
6F45:  7E 6F E2          jmp      $6fe2 ; $6FE2=loc_6FE2

loc_6F48:
6F48:  FC 20 51          ldd      $2051 ; xrefs $6F33:branch
6F4B:  BD 44 0D          jsr      $440d ; $440D=sub_440D
6F4E:  12 AA 04 56       brset    $aa, #4, $6fa8 ; $6FA8=loc_6FA8
6F52:  B6 21 CA          ldaa     $21ca
6F55:  26 08             bne      $6f5f ; $6F5F=loc_6F5F
6F57:  14 AA 04          bset     $aa, #4
6F5A:  14 AA 02          bset     $aa, #2
6F5D:  20 49             bra      $6fa8 ; $6FA8=loc_6FA8

loc_6F5F:
6F5F:  4A                deca      ; xrefs $6F55:branch
6F60:  B7 21 CA          staa     $21ca
6F63:  DC BA             ldd      $ba ; $00BA=engine_period_delta
6F65:  FD 21 C8          std      $21c8
6F68:  13 AA 02 07       brclr    $aa, #2, $6f73 ; $6F73=loc_6F73
6F6C:  DC C3             ldd      $c3 ; $00C3=final_fuel_duration
6F6E:  05                asld     
6F6F:  DD BC             std      $bc ; $00BC=fuel_output_duration
6F71:  20 49             bra      $6fbc ; $6FBC=loc_6FBC

loc_6F73:
6F73:  DC C3             ldd      $c3 ; $00C3=final_fuel_duration | xrefs $6F68:branch
6F75:  13 AA 08 0B       brclr    $aa, #8, $6f84 ; $6F84=loc_6F84
6F79:  15 AA 08          bclr     $aa, #8
6F7C:  05                asld     
6F7D:  93 BF             subd     $bf ; $00BF=fuel_event_width_limit
6F7F:  24 03             bcc      $6f84 ; $6F84=loc_6F84
6F81:  CC 00 00          ldd      #0

loc_6F84:
6F84:  DD BC             std      $bc ; $00BC=fuel_output_duration | xrefs $6F75:branch, $6F7F:branch
6F86:  DC BF             ldd      $bf ; $00BF=fuel_event_width_limit
6F88:  1A 93 BC          cpd      $bc ; $00BC=fuel_output_duration
6F8B:  22 02             bhi      $6f8f ; $6F8F=loc_6F8F
6F8D:  20 2D             bra      $6fbc ; $6FBC=loc_6FBC

loc_6F8F:
6F8F:  04                lsrd      ; xrefs $6F8B:branch
6F90:  1A 93 BC          cpd      $bc ; $00BC=fuel_output_duration
6F93:  25 05             bcs      $6f9a ; $6F9A=loc_6F9A
6F95:  14 AA 02          bset     $aa, #2
6F98:  20 48             bra      $6fe2 ; $6FE2=loc_6FE2

loc_6F9A:
6F9A:  14 AA 08          bset     $aa, #8 ; xrefs $6F93:branch
6F9D:  DC BF             ldd      $bf ; $00BF=fuel_event_width_limit
6F9F:  DD BC             std      $bc ; $00BC=fuel_output_duration
6FA1:  20 19             bra      $6fbc ; $6FBC=loc_6FBC

loc_6FA3:
6FA3:  DC C3             ldd      $c3 ; $00C3=final_fuel_duration | xrefs $6F3B:branch
6FA5:  05                asld     
6FA6:  DD BC             std      $bc ; $00BC=fuel_output_duration

loc_6FA8:
6FA8:  DC BA             ldd      $ba ; $00BA=engine_period_delta | xrefs $6F4E:branch, $6F5D:branch
6FAA:  05                asld     
6FAB:  24 03             bcc      $6fb0 ; $6FB0=loc_6FB0
6FAD:  CC FF FF          ldd      #-1

loc_6FB0:
6FB0:  FD 21 C8          std      $21c8 ; xrefs $6FAB:branch
6FB3:  12 AA 02 05       brset    $aa, #2, $6fbc ; $6FBC=loc_6FBC
6FB7:  14 AA 02          bset     $aa, #2
6FBA:  20 26             bra      $6fe2 ; $6FE2=loc_6FE2

loc_6FBC:
6FBC:  15 AA 02          bclr     $aa, #2 ; xrefs $6F71:branch, $6F8D:branch, $6FA1:branch, $6FB3:branch
6FBF:  0F                sei      
6FC0:  FC 21 C6          ldd      $21c6 ; $21C6=fuel_event_phase_runtime
6FC3:  D3 B8             addd     $b8 ; $00B8=previous_capture_or_schedule_base
6FC5:  FD 10 16          std      $1016
6FC8:  FC 10 0E          ldd      $100e ; $100E=TCNT
6FCB:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
6FCD:  C3 00 19          addd     #25
6FD0:  1A B3 21 C6       cpd      $21c6 ; $21C6=fuel_event_phase_runtime
6FD4:  24 05             bcc      $6fdb ; $6FDB=loc_6FDB
6FD6:  86 80             ldaa     #-128
6FD8:  B7 10 23          staa     $1023 ; $1023=TFLG1

loc_6FDB:
6FDB:  CE 10 00          ldx      #4096 ; xrefs $6FD4:branch
6FDE:  1C 22 80          bset     34, x; #-128
6FE1:  0E                cli      

loc_6FE2:
6FE2:  39                rts       ; xrefs $6F3F:jump, $6F45:jump, $6F98:branch, $6FBA:branch

; ---- unreached/data gap $6FE3-$6FE3 ----

        .org $6FE4
6FE4:  CE 10 00          ldx      #4096
6FE7:  1D 22 80          bclr     34, x; #-128
6FEA:  13 AA 40 0A       brclr    $aa, #64, $6ff8 ; $6FF8=loc_6FF8
6FEE:  15 AA 40          bclr     $aa, #64
6FF1:  FC 21 CF          ldd      $21cf
6FF4:  DD BC             std      $bc ; $00BC=fuel_output_duration
6FF6:  20 44             bra      $703c ; $703C=loc_703C

loc_6FF8:
6FF8:  13 AA 04 32       brclr    $aa, #4, $702e ; $702E=loc_702E | xrefs $6FEA:branch
6FFC:  B6 87 B0          ldaa     $87b0
6FFF:  81 04             cmpa     #4
7001:  26 26             bne      $7029 ; $7029=loc_7029
7003:  13 AA 01 06       brclr    $aa, #1, $700d ; $700D=loc_700D
7007:  15 AA 01          bclr     $aa, #1
700A:  7E 70 FF          jmp      $70ff ; $70FF=loc_70FF

loc_700D:
700D:  14 AA 01          bset     $aa, #1 ; xrefs $7003:branch
7010:  DC C3             ldd      $c3 ; $00C3=final_fuel_duration
7012:  05                asld     
7013:  05                asld     
7014:  DD BC             std      $bc ; $00BC=fuel_output_duration
7016:  DC BA             ldd      $ba ; $00BA=engine_period_delta
7018:  05                asld     
7019:  24 03             bcc      $701e ; $701E=loc_701E
701B:  CC FF FF          ldd      #-1

loc_701E:
701E:  05                asld      ; xrefs $7019:branch
701F:  24 03             bcc      $7024 ; $7024=loc_7024
7021:  CC FF FF          ldd      #-1

loc_7024:
7024:  FD 21 C8          std      $21c8 ; xrefs $701F:branch
7027:  20 05             bra      $702e ; $702E=loc_702E

loc_7029:
7029:  DC C3             ldd      $c3 ; $00C3=final_fuel_duration | xrefs $7001:branch
702B:  05                asld     
702C:  DD BC             std      $bc ; $00BC=fuel_output_duration

loc_702E:
702E:  13 AA 80 0A       brclr    $aa, #-128, $703c ; $703C=loc_703C | xrefs $6FF8:branch, $7027:branch
7032:  DC BC             ldd      $bc ; $00BC=fuel_output_duration
7034:  F3 21 CF          addd     $21cf
7037:  DD BC             std      $bc ; $00BC=fuel_output_duration
7039:  15 AA 80          bclr     $aa, #-128

loc_703C:
703C:  DC BC             ldd      $bc ; $00BC=fuel_output_duration | xrefs $6FF6:branch, $702E:branch
703E:  BD 58 9C          jsr      $589c ; $589C=sub_589C
7041:  13 AA 10 14       brclr    $aa, #16, $7059 ; $7059=loc_7059
7045:  15 AA 10          bclr     $aa, #16
7048:  DC BC             ldd      $bc ; $00BC=fuel_output_duration
704A:  B3 21 CD          subd     $21cd
704D:  2C 08             bge      $7057 ; $7057=loc_7057
704F:  CC 00 00          ldd      #0
7052:  DD BC             std      $bc ; $00BC=fuel_output_duration
7054:  7E 70 FF          jmp      $70ff ; $70FF=loc_70FF

loc_7057:
7057:  DD BC             std      $bc ; $00BC=fuel_output_duration | xrefs $704D:branch

loc_7059:
7059:  CE 10 00          ldx      #4096 ; xrefs $7041:branch
705C:  1C 20 30          bset     32, x; #48
705F:  FC 10 0E          ldd      $100e ; $100E=TCNT
7062:  FD 21 CB          std      $21cb
7065:  1E 00 20 58       brset    0, x; #32; $70c1 ; $70C1=loc_70C1
7069:  1C 0B 20          bset     11, x; #32
706C:  FC 20 86          ldd      $2086 ; $2086=fuel_edge_deadline_term
706F:  F3 87 87          addd     $8787 ; $8787=oc3_period_fit_guard
7072:  D3 BC             addd     $bc ; $00BC=fuel_output_duration
7074:  1A B3 21 C8       cpd      $21c8
7078:  24 10             bcc      $708a ; $708A=loc_708A
707A:  DC BC             ldd      $bc ; $00BC=fuel_output_duration
707C:  F3 21 CB          addd     $21cb
707F:  F3 20 86          addd     $2086 ; $2086=fuel_edge_deadline_term
7082:  C3 00 05          addd     #5
7085:  FD 10 1A          std      $101a
7088:  20 20             bra      $70aa ; $70AA=loc_70AA

loc_708A:
708A:  FC 21 C8          ldd      $21c8 ; xrefs $7078:branch
708D:  C3 03 E8          addd     #1000
7090:  F3 21 CB          addd     $21cb
7093:  C3 00 05          addd     #5
7096:  FD 10 1A          std      $101a
7099:  14 AA 10          bset     $aa, #16
709C:  FC 21 C8          ldd      $21c8
709F:  C3 03 E8          addd     #1000
70A2:  93 BC             subd     $bc ; $00BC=fuel_output_duration
70A4:  B3 20 86          subd     $2086 ; $2086=fuel_edge_deadline_term
70A7:  FD 21 CD          std      $21cd

loc_70AA:
70AA:  1D 20 10          bclr     32, x; #16 ; xrefs $7088:branch
70AD:  15 2A 03          bclr     $2a, #3
70B0:  1E 60 01 05       brset    96, x; #1; $70b9 ; $70B9=loc_70B9
70B4:  14 2A 02          bset     $2a, #2
70B7:  20 46             bra      $70ff ; $70FF=loc_70FF

loc_70B9:
70B9:  14 2A 01          bset     $2a, #1 ; xrefs $70B0:branch
70BC:  1C 0B 20          bset     11, x; #32
70BF:  20 3E             bra      $70ff ; $70FF=loc_70FF

loc_70C1:
70C1:  FC 10 1A          ldd      $101a ; xrefs $7065:branch
70C4:  B3 21 CB          subd     $21cb
70C7:  F3 87 87          addd     $8787 ; $8787=oc3_period_fit_guard
70CA:  D3 BC             addd     $bc ; $00BC=fuel_output_duration
70CC:  1A B3 21 C8       cpd      $21c8
70D0:  24 0A             bcc      $70dc ; $70DC=loc_70DC
70D2:  DC BC             ldd      $bc ; $00BC=fuel_output_duration
70D4:  F3 10 1A          addd     $101a
70D7:  FD 10 1A          std      $101a
70DA:  20 20             bra      $70fc ; $70FC=loc_70FC

loc_70DC:
70DC:  14 AA 10          bset     $aa, #16 ; xrefs $70D0:branch
70DF:  FC 21 C8          ldd      $21c8
70E2:  C3 03 E8          addd     #1000
70E5:  F3 21 CB          addd     $21cb
70E8:  B3 10 1A          subd     $101a
70EB:  93 BC             subd     $bc ; $00BC=fuel_output_duration
70ED:  FD 21 CD          std      $21cd
70F0:  FC 21 C8          ldd      $21c8
70F3:  C3 03 E8          addd     #1000
70F6:  F3 21 CB          addd     $21cb
70F9:  FD 10 1A          std      $101a

loc_70FC:
70FC:  1D 20 10          bclr     32, x; #16 ; xrefs $70DA:branch

loc_70FF:
70FF:  3B                rti       ; xrefs $700A:jump, $7054:jump, $70B7:branch, $70BF:branch

; ---- unreached/data gap $7100-$7100 ----

        .org $7101

sub_7101:
7101:  B6 20 59          ldaa     $2059 ; xrefs $9678:call
7104:  81 01             cmpa     #1
7106:  26 4E             bne      $7156 ; $7156=loc_7156
7108:  13 A9 01 4A       brclr    $a9, #1, $7156 ; $00A9=operating_mode_flags, $7156=loc_7156
710C:  96 C9             ldaa     $c9
710E:  B1 89 90          cmpa     $8990
7111:  23 03             bls      $7116 ; $7116=loc_7116
7113:  14 AA 20          bset     $aa, #32

loc_7116:
7116:  BB 84 19          adda     $8419 ; xrefs $7111:branch
7119:  B1 89 90          cmpa     $8990
711C:  22 03             bhi      $7121 ; $7121=loc_7121
711E:  15 AA 20          bclr     $aa, #32

loc_7121:
7121:  12 AA 20 31       brset    $aa, #32, $7156 ; $7156=loc_7156 | xrefs $711C:branch
7125:  18 CE 84 1B       ldy      #-31717
7129:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
712C:  FD 21 CF          std      $21cf
712F:  CE 21 CF          ldx      #8655
7132:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
7135:  1A B3 20 5D       cpd      $205d
7139:  24 1E             bcc      $7159 ; $7159=loc_7159
713B:  86 02             ldaa     #2
713D:  B7 20 59          staa     $2059
7140:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
7143:  18 CE 84 7D       ldy      #-31619
7147:  7D 00 90          tst      >$0090
714A:  26 04             bne      $7150 ; $7150=loc_7150
714C:  18 CE 84 8E       ldy      #-31602

loc_7150:
7150:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $714A:branch
7153:  B7 20 60          staa     $2060

loc_7156:
7156:  7E 71 EF          jmp      $71ef ; $71EF=loc_71EF | xrefs $7106:branch, $7108:branch, $7121:branch

loc_7159:
7159:  B6 20 61          ldaa     $2061 ; xrefs $7139:branch
715C:  27 03             beq      $7161 ; $7161=loc_7161
715E:  7E 71 EC          jmp      $71ec ; $71EC=loc_71EC

loc_7161:
7161:  B6 84 4E          ldaa     $844e ; xrefs $715C:branch
7164:  B7 20 61          staa     $2061
7167:  18 CE 84 3D       ldy      #-31683
716B:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
716E:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
7171:  5F                clrb     
7172:  04                lsrd     
7173:  04                lsrd     
7174:  FD 20 5B          std      $205b
7177:  FC 84 4F          ldd      $844f
717A:  B3 20 14          subd     $2014
717D:  24 03             bcc      $7182 ; $7182=loc_7182
717F:  4F                clra     
7180:  20 05             bra      $7187 ; $7187=loc_7187

loc_7182:
7182:  04                lsrd      ; xrefs $717D:branch
7183:  B6 84 51          ldaa     $8451
7186:  3D                mul      

loc_7187:
7187:  B7 20 5A          staa     $205a ; xrefs $7180:branch
718A:  B6 20 5B          ldaa     $205b
718D:  F6 20 5A          ldab     $205a
7190:  3D                mul      
7191:  8F                xgdx     
7192:  B6 20 5C          ldaa     $205c
7195:  F6 20 5A          ldab     $205a
7198:  3D                mul      
7199:  89 00             adca     #0
719B:  16                tab      
719C:  3A                abx      
719D:  FC 20 5B          ldd      $205b
71A0:  FF 20 5B          stx      $205b
71A3:  B3 20 5B          subd     $205b
71A6:  FD 20 5B          std      $205b
71A9:  F3 20 5E          addd     $205e
71AC:  FD 20 5E          std      $205e
71AF:  B6 20 5D          ldaa     $205d
71B2:  89 00             adca     #0
71B4:  B7 20 5D          staa     $205d
71B7:  FC 20 5B          ldd      $205b
71BA:  BD 58 9C          jsr      $589c ; $589C=sub_589C
71BD:  FC 20 5B          ldd      $205b
71C0:  BD 44 0D          jsr      $440d ; $440D=sub_440D
71C3:  0F                sei      
71C4:  CE 10 00          ldx      #4096
71C7:  1C 20 30          bset     32, x; #48
71CA:  1C 0B 20          bset     11, x; #32
71CD:  FC 20 5B          ldd      $205b
71D0:  F3 10 0E          addd     $100e ; $100E=TCNT
71D3:  FD 10 1A          std      $101a
71D6:  1D 20 10          bclr     32, x; #16
71D9:  15 2A 03          bclr     $2a, #3
71DC:  0E                cli      
71DD:  1E 60 01 05       brset    96, x; #1; $71e6 ; $71E6=loc_71E6
71E1:  14 2A 02          bset     $2a, #2
71E4:  20 06             bra      $71ec ; $71EC=loc_71EC

loc_71E6:
71E6:  14 2A 01          bset     $2a, #1 ; xrefs $71DD:branch
71E9:  1C 0B 20          bset     11, x; #32

loc_71EC:
71EC:  7A 20 61          dec      $2061 ; xrefs $715E:jump, $71E4:branch

loc_71EF:
71EF:  13 A3 01 49       brclr    $a3, #1, $723c ; $723C=loc_723C | xrefs $7156:jump
71F3:  12 9E 10 45       brset    $9e, #16, $723c ; $723C=loc_723C
71F7:  B6 86 70          ldaa     $8670
71FA:  8B 02             adda     #2
71FC:  B1 20 F3          cmpa     $20f3
71FF:  24 3B             bcc      $723c ; $723C=loc_723C
7201:  96 D3             ldaa     $d3
7203:  B1 84 EC          cmpa     $84ec
7206:  24 34             bcc      $723c ; $723C=loc_723C
7208:  14 9E 10          bset     $9e, #16
720B:  18 CE 84 ED       ldy      #-31507
720F:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
7212:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
7215:  5F                clrb     
7216:  04                lsrd     
7217:  04                lsrd     
7218:  04                lsrd     
7219:  FD 21 CF          std      $21cf
721C:  1A 93 BF          cpd      $bf ; $00BF=fuel_event_width_limit
721F:  25 1B             bcs      $723c ; $723C=loc_723C
7221:  0F                sei      
7222:  CE 10 00          ldx      #4096
7225:  1E 22 80 0F       brset    34, x; #-128; $7238 ; $7238=loc_7238
7229:  12 AA 02 0B       brset    $aa, #2, $7238 ; $7238=loc_7238
722D:  14 AA 40          bset     $aa, #64
7230:  CE 10 00          ldx      #4096
7233:  1C 22 80          bset     34, x; #-128
7236:  20 03             bra      $723b ; $723B=loc_723B

loc_7238:
7238:  14 AA 80          bset     $aa, #-128 ; xrefs $7225:branch, $7229:branch

loc_723B:
723B:  0E                cli       ; xrefs $7236:branch

loc_723C:
723C:  39                rts       ; xrefs $71EF:branch, $71F3:branch, $71FF:branch, $7206:branch, $721F:branch

; ---- unreached/data gap $723D-$723D ----

        .org $723E

sub_723E:
723E:  13 A9 02 07       brclr    $a9, #2, $7249 ; $00A9=operating_mode_flags, $7249=loc_7249 | xrefs $D517:call
7242:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
7245:  81 0C             cmpa     #12
7247:  26 0B             bne      $7254 ; $7254=loc_7254

loc_7249:
7249:  CC 00 00          ldd      #0 ; xrefs $723E:branch
724C:  FD 21 C6          std      $21c6 ; $21C6=fuel_event_phase_runtime
724F:  97 BE             staa     $be ; $00BE=fuel_event_phase
7251:  7E 72 9B          jmp      $729b ; $729B=loc_729B

loc_7254:
7254:  18 CE 21 D1       ldy      #8657 ; xrefs $7247:branch
7258:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
725B:  18 ED 00          std      0, y
725E:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
7261:  18 ED 02          std      2, y
7264:  CC 87 B1          ldd      #-30799
7267:  18 ED 04          std      4, y
726A:  B6 92 90          ldaa     $9290
726D:  18 A7 06          staa     6, y
7270:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
7273:  D6 BE             ldab     $be ; $00BE=fuel_event_phase
7275:  37                pshb     
7276:  97 BE             staa     $be ; $00BE=fuel_event_phase
7278:  10                sba      
7279:  F6 88 89          ldab     $8889
727C:  24 02             bcc      $7280 ; $7280=loc_7280
727E:  40                nega     
727F:  50                negb     

loc_7280:
7280:  B1 88 89          cmpa     $8889 ; xrefs $727C:branch
7283:  32                pula     
7284:  23 03             bls      $7289 ; $7289=loc_7289
7286:  1B                aba      
7287:  97 BE             staa     $be ; $00BE=fuel_event_phase

loc_7289:
7289:  DC BA             ldd      $ba ; $00BA=engine_period_delta | xrefs $7284:branch
728B:  37                pshb     
728C:  D6 BE             ldab     $be ; $00BE=fuel_event_phase
728E:  3D                mul      
728F:  8F                xgdx     
7290:  32                pula     
7291:  D6 BE             ldab     $be ; $00BE=fuel_event_phase
7293:  3D                mul      
7294:  89 00             adca     #0
7296:  16                tab      
7297:  3A                abx      
7298:  FF 21 C6          stx      $21c6 ; $21C6=fuel_event_phase_runtime

loc_729B:
729B:  39                rts       ; xrefs $7251:jump

; ---- unreached/data gap $729C-$729C ----

        .org $729D

sub_729D:
729D:  86 01             ldaa     #1 ; xrefs $B8E9:call
729F:  B7 20 59          staa     $2059
72A2:  86 40             ldaa     #64
72A4:  97 A3             staa     $a3
72A6:  CC 00 00          ldd      #0
72A9:  FD 21 C6          std      $21c6 ; $21C6=fuel_event_phase_runtime
72AC:  DD BC             std      $bc ; $00BC=fuel_output_duration
72AE:  FD 20 5D          std      $205d
72B1:  B7 20 5F          staa     $205f
72B4:  B7 20 61          staa     $2061
72B7:  97 AA             staa     $aa
72B9:  BD 43 1A          jsr      $431a ; $431A=preprocess_cts_path
72BC:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
72BF:  18 CE 84 52       ldy      #-31662
72C3:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
72C6:  B7 21 CA          staa     $21ca
72C9:  39                rts      

; ---- unreached/data gap $72CA-$72CA ----

        .org $72CB
72CB:  CE 10 00          ldx      #4096
72CE:  86 80             ldaa     #-128
72D0:  B7 10 25          staa     $1025 ; $1025=TFLG2
72D3:  FC 21 00          ldd      $2100
72D6:  C3 00 01          addd     #1
72D9:  FD 21 00          std      $2100
72DC:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
72DF:  81 FF             cmpa     #-1
72E1:  27 23             beq      $7306 ; $7306=loc_7306
72E3:  81 05             cmpa     #5
72E5:  27 16             beq      $72fd ; $72FD=loc_72FD
72E7:  81 06             cmpa     #6
72E9:  27 15             beq      $7300 ; $7300=loc_7300
72EB:  81 08             cmpa     #8
72ED:  27 14             beq      $7303 ; $7303=loc_7303
72EF:  81 0D             cmpa     #13
72F1:  26 13             bne      $7306 ; $7306=loc_7306
72F3:  F6 21 C0          ldab     $21c0
72F6:  C1 BB             cmpb     #-69
72F8:  26 0C             bne      $7306 ; $7306=loc_7306
72FA:  7E 6C 6D          jmp      $6c6d ; $6C6D=loc_6C6D

loc_72FD:
72FD:  7E 73 69          jmp      $7369 ; $7369=loc_7369 | xrefs $72E5:branch

loc_7300:
7300:  7E E1 2E          jmp      $e12e ; $E12E=loc_E12E | xrefs $72E9:branch

loc_7303:
7303:  7E 6C 6A          jmp      $6c6a ; $6C6A=loc_6C6A | xrefs $72ED:branch

loc_7306:
7306:  B6 21 4F          ldaa     $214f ; $214F=alternate_limiter_mode | xrefs $72E1:branch, $72F1:branch, $72F8:branch
7309:  27 04             beq      $730f ; $730F=loc_730F
730B:  4A                deca     
730C:  B7 21 4F          staa     $214f ; $214F=alternate_limiter_mode

loc_730F:
730F:  BD EF 2A          jsr      $ef2a ; $EF2A=sub_EF2A | xrefs $7309:branch
7312:  14 B4 01          bset     $b4, #1
7315:  13 9C 01 03       brclr    $9c, #1, $731c ; $009C=scheduler_status_flags, $731C=loc_731C
7319:  7E 73 90          jmp      $7390 ; $7390=loc_7390

loc_731C:
731C:  96 B7             ldaa     $b7 ; xrefs $7315:branch
731E:  13 9E 40 05       brclr    $9e, #64, $7327 ; $7327=loc_7327
7322:  15 9E 40          bclr     $9e, #64
7325:  20 04             bra      $732b ; $732B=loc_732B

loc_7327:
7327:  8B 01             adda     #1 ; xrefs $731E:branch
7329:  97 B7             staa     $b7

loc_732B:
732B:  B1 92 E4          cmpa     $92e4 ; xrefs $7325:branch
732E:  25 05             bcs      $7335 ; $7335=loc_7335
7330:  14 B4 02          bset     $b4, #2
7333:  20 34             bra      $7369 ; $7369=loc_7369

loc_7335:
7335:  12 A9 01 17       brset    $a9, #1, $7350 ; $00A9=operating_mode_flags, $7350=loc_7350 | xrefs $732E:branch
7339:  14 9C 04          bset     $9c, #4 ; $009C=scheduler_status_flags
733C:  1F 50 01 29       brclr    80, x; #1; $7369 ; $7369=loc_7369
7340:  B6 20 F0          ldaa     $20f0
7343:  27 06             beq      $734b ; $734B=loc_734B
7345:  4A                deca     
7346:  B7 20 F0          staa     $20f0
7349:  26 1E             bne      $7369 ; $7369=loc_7369

loc_734B:
734B:  1D 50 01          bclr     80, x; #1 ; xrefs $7343:branch
734E:  20 19             bra      $7369 ; $7369=loc_7369

loc_7350:
7350:  B1 92 E3          cmpa     $92e3 ; xrefs $7335:branch
7353:  24 08             bcc      $735d ; $735D=loc_735D
7355:  13 AD 01 10       brclr    $ad, #1, $7369 ; $7369=loc_7369
7359:  13 9C 08 0C       brclr    $9c, #8, $7369 ; $009C=scheduler_status_flags, $7369=loc_7369

loc_735D:
735D:  12 A9 02 05       brset    $a9, #2, $7366 ; $00A9=operating_mode_flags, $7366=loc_7366 | xrefs $7353:branch
7361:  14 B4 08          bset     $b4, #8
7364:  20 03             bra      $7369 ; $7369=loc_7369

loc_7366:
7366:  14 B4 04          bset     $b4, #4 ; xrefs $735D:branch

loc_7369:
7369:  14 9C 08          bset     $9c, #8 ; $009C=scheduler_status_flags | xrefs $72FD:jump, $7333:branch, $733C:branch, $7349:branch, $734E:branch, $7355:branch, $7359:branch, $7364:branch
736C:  B6 87 9B          ldaa     $879b
736F:  81 01             cmpa     #1
7371:  26 1D             bne      $7390 ; $7390=loc_7390
7373:  FC 21 0A          ldd      $210a
7376:  C3 00 01          addd     #1
7379:  FD 21 0A          std      $210a
737C:  FC 21 0C          ldd      $210c
737F:  C3 00 01          addd     #1
7382:  FD 21 0C          std      $210c
7385:  1A 83 36 EE       cpd      #14062
7389:  25 05             bcs      $7390 ; $7390=loc_7390
738B:  86 02             ldaa     #2
738D:  B7 87 9B          staa     $879b

loc_7390:
7390:  3B                rti       ; xrefs $7319:jump, $7371:branch, $7389:branch

; ---- unreached/data gap $7391-$7391 ----

        .org $7392

; [CONFIRMED] Capture 68HC11 TIC3 value at 0x1014 into RAM 0x00D9.
timer_capture_handler:
7392:  FC 10 14          ldd      $1014 ; $1014=TIC3
7395:  DD D9             std      $d9 ; $00D9=captured_timer_value
7397:  86 20             ldaa     #32
7399:  B7 10 25          staa     $1025 ; $1025=TFLG2
739C:  30                tsx      
739D:  EE 07             ldx      7, x
739F:  8C 96 5A          cpx      #-27046
73A2:  27 0A             beq      $73ae ; $73AE=loc_73AE
73A4:  8C C9 C8          cpx      #-13880
73A7:  25 08             bcs      $73b1 ; $73B1=loc_73B1
73A9:  8C CA AD          cpx      #-13651
73AC:  24 03             bcc      $73b1 ; $73B1=loc_73B1

loc_73AE:
73AE:  7C 24 66          inc      $2466 ; xrefs $73A2:branch

loc_73B1:
73B1:  96 DC             ldaa     $dc ; xrefs $73A7:branch, $73AC:branch
73B3:  97 DB             staa     $db
73B5:  81 01             cmpa     #1
73B7:  26 2A             bne      $73e3 ; $73E3=loc_73E3
73B9:  86 14             ldaa     #20
73BB:  97 DC             staa     $dc
73BD:  13 AE 01 09       brclr    $ae, #1, $73ca ; $73CA=loc_73CA
73C1:  D6 AD             ldab     $ad
73C3:  C8 03             eorb     #3
73C5:  D7 AD             stab     $ad
73C7:  15 AE 01          bclr     $ae, #1

loc_73CA:
73CA:  12 AD 01 2C       brset    $ad, #1, $73fa ; $73FA=loc_73FA | xrefs $73BD:branch
73CE:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
73D0:  B3 23 0E          subd     $230e
73D3:  FD 23 0A          std      $230a
73D6:  93 ED             subd     $ed
73D8:  25 06             bcs      $73e0 ; $73E0=loc_73E0
73DA:  14 AC 10          bset     $ac, #16
73DD:  7E 74 69          jmp      $7469 ; $7469=loc_7469

loc_73E0:
73E0:  BD 7C B3          jsr      $7cb3 ; $7CB3=sub_7CB3 | xrefs $73D8:branch

loc_73E3:
73E3:  81 14             cmpa     #20 ; xrefs $73B7:branch
73E5:  26 16             bne      $73fd ; $73FD=loc_73FD
73E7:  CE 10 00          ldx      #4096
73EA:  1D 00 08          bclr     0, x; #8
73ED:  1D 50 01          bclr     80, x; #1
73F0:  14 9C 20          bset     $9c, #32 ; $009C=scheduler_status_flags
73F3:  14 AE 20          bset     $ae, #32
73F6:  86 32             ldaa     #50
73F8:  97 DC             staa     $dc

loc_73FA:
73FA:  7E 74 69          jmp      $7469 ; $7469=loc_7469 | xrefs $73CA:branch

loc_73FD:
73FD:  81 32             cmpa     #50 ; xrefs $73E5:branch
73FF:  26 15             bne      $7416 ; $7416=loc_7416
7401:  CE 10 00          ldx      #4096
7404:  1D 00 08          bclr     0, x; #8
7407:  1D 50 01          bclr     80, x; #1
740A:  15 9C 20          bclr     $9c, #32 ; $009C=scheduler_status_flags
740D:  14 AE 40          bset     $ae, #64
7410:  86 38             ldaa     #56
7412:  97 DC             staa     $dc
7414:  20 53             bra      $7469 ; $7469=loc_7469

loc_7416:
7416:  81 38             cmpa     #56 ; xrefs $73FF:branch
7418:  26 0B             bne      $7425 ; $7425=loc_7425
741A:  86 3A             ldaa     #58
741C:  97 DC             staa     $dc
741E:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7420:  FD 23 0C          std      $230c
7423:  20 44             bra      $7469 ; $7469=loc_7469

loc_7425:
7425:  81 3A             cmpa     #58 ; xrefs $7418:branch
7427:  26 30             bne      $7459 ; $7459=loc_7459
7429:  86 3B             ldaa     #59
742B:  97 DC             staa     $dc
742D:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
742F:  FD 23 0E          std      $230e
7432:  13 AD 01 03       brclr    $ad, #1, $7439 ; $7439=loc_7439
7436:  7E 74 E3          jmp      $74e3 ; $74E3=loc_74E3

loc_7439:
7439:  B3 23 0C          subd     $230c ; xrefs $7432:branch
743C:  DD ED             std      $ed
743E:  1A B3 20 8C       cpd      $208c
7442:  25 13             bcs      $7457 ; $7457=loc_7457
7444:  7C 20 8B          inc      $208b
7447:  C6 01             ldab     #1
7449:  96 DD             ldaa     $dd
744B:  81 3A             cmpa     #58
744D:  26 02             bne      $7451 ; $7451=loc_7451
744F:  D7 DD             stab     $dd

loc_7451:
7451:  D7 DB             stab     $db ; xrefs $744D:branch
7453:  C6 14             ldab     #20
7455:  D7 DC             stab     $dc

loc_7457:
7457:  20 10             bra      $7469 ; $7469=loc_7469 | xrefs $7442:branch

loc_7459:
7459:  96 DB             ldaa     $db ; xrefs $7427:branch
745B:  C6 14             ldab     #20
745D:  11                cba      
745E:  25 07             bcs      $7467 ; $7467=loc_7467
7460:  C6 32             ldab     #50
7462:  11                cba      
7463:  25 02             bcs      $7467 ; $7467=loc_7467
7465:  C6 38             ldab     #56

loc_7467:
7467:  D7 DC             stab     $dc ; xrefs $745E:branch, $7463:branch

loc_7469:
7469:  13 AD 02 5F       brclr    $ad, #2, $74cc ; $74CC=loc_74CC | xrefs $73DD:jump, $73FA:jump, $7414:branch, $7423:branch, $7457:branch
746D:  96 DB             ldaa     $db
746F:  81 1F             cmpa     #31
7471:  26 10             bne      $7483 ; $7483=loc_7483
7473:  13 AE 01 0C       brclr    $ae, #1, $7483 ; $7483=loc_7483
7477:  96 AD             ldaa     $ad
7479:  88 03             eora     #3
747B:  97 AD             staa     $ad
747D:  15 AE 01          bclr     $ae, #1
7480:  7E 74 E3          jmp      $74e3 ; $74E3=loc_74E3

loc_7483:
7483:  91 DD             cmpa     $dd ; xrefs $7471:branch, $7473:branch
7485:  26 08             bne      $748f ; $748F=loc_748F
7487:  14 A0 80          bset     $a0, #-128
748A:  BD 7C 57          jsr      $7c57 ; $7C57=sub_7C57
748D:  20 10             bra      $749f ; $749F=loc_749F

loc_748F:
748F:  91 DE             cmpa     $de ; xrefs $7485:branch
7491:  26 08             bne      $749b ; $749B=loc_749B
7493:  15 A0 80          bclr     $a0, #-128
7496:  BD 7C 8A          jsr      $7c8a ; $7C8A=sub_7C8A
7499:  20 1E             bra      $74b9 ; $74B9=loc_74B9

loc_749B:
749B:  13 A0 80 1A       brclr    $a0, #-128, $74b9 ; $74B9=loc_74B9 | xrefs $7491:branch

loc_749F:
749F:  96 DE             ldaa     $de ; xrefs $748D:branch
74A1:  8D 1C             bsr      $74bf ; $74BF=sub_74BF
74A3:  96 DB             ldaa     $db
74A5:  81 1F             cmpa     #31
74A7:  27 21             beq      $74ca ; $74CA=loc_74CA
74A9:  96 DE             ldaa     $de
74AB:  91 DC             cmpa     $dc
74AD:  26 1B             bne      $74ca ; $74CA=loc_74CA
74AF:  81 1F             cmpa     #31
74B1:  23 17             bls      $74ca ; $74CA=loc_74CA
74B3:  86 1F             ldaa     #31
74B5:  97 DC             staa     $dc
74B7:  20 11             bra      $74ca ; $74CA=loc_74CA

loc_74B9:
74B9:  96 DD             ldaa     $dd ; xrefs $7499:branch, $749B:branch
74BB:  8D 02             bsr      $74bf ; $74BF=sub_74BF
74BD:  20 0B             bra      $74ca ; $74CA=loc_74CA

sub_74BF:
74BF:  91 DB             cmpa     $db ; xrefs $74A1:call, $74BB:call
74C1:  23 06             bls      $74c9 ; $74C9=loc_74C9
74C3:  91 DC             cmpa     $dc
74C5:  24 02             bcc      $74c9 ; $74C9=loc_74C9
74C7:  97 DC             staa     $dc

loc_74C9:
74C9:  39                rts       ; xrefs $74C1:branch, $74C5:branch

loc_74CA:
74CA:  20 17             bra      $74e3 ; $74E3=loc_74E3 | xrefs $74A7:branch, $74AD:branch, $74B1:branch, $74B7:branch, $74BD:branch

loc_74CC:
74CC:  13 AD 04 13       brclr    $ad, #4, $74e3 ; $74E3=loc_74E3 | xrefs $7469:branch
74D0:  12 AE 20 0A       brset    $ae, #32, $74de ; $74DE=loc_74DE
74D4:  96 DB             ldaa     $db
74D6:  81 01             cmpa     #1
74D8:  26 09             bne      $74e3 ; $74E3=loc_74E3
74DA:  12 AE 08 05       brset    $ae, #8, $74e3 ; $74E3=loc_74E3

loc_74DE:
74DE:  B6 23 55          ldaa     $2355 ; xrefs $74D0:branch
74E1:  97 DC             staa     $dc

loc_74E3:
74E3:  96 DB             ldaa     $db ; xrefs $7436:jump, $7480:jump, $74CA:branch, $74CC:branch, $74D8:branch, $74DA:branch
74E5:  90 DC             suba     $dc
74E7:  B7 10 27          staa     $1027
74EA:  18 DE D9          ldy      $d9 ; $00D9=captured_timer_value
74ED:  18 BC 10 14       cpy      $1014 ; $1014=TIC3
74F1:  27 12             beq      $7505 ; $7505=loc_7505
74F3:  4C                inca     
74F4:  B7 10 27          staa     $1027
74F7:  FC 10 14          ldd      $1014 ; $1014=TIC3
74FA:  93 D9             subd     $d9 ; $00D9=captured_timer_value
74FC:  C3 00 32          addd     #50
74FF:  1A 93 ED          cpd      $ed
7502:  25 01             bcs      $7505 ; $7505=loc_7505
7504:  01                nop      

loc_7505:
7505:  13 AD 01 0B       brclr    $ad, #1, $7514 ; $7514=loc_7514 | xrefs $74F1:branch, $7502:branch
7509:  86 FF             ldaa     #-1
750B:  B7 10 27          staa     $1027
750E:  BD 77 A2          jsr      $77a2 ; $77A2=sub_77A2
7511:  7E 76 30          jmp      $7630 ; $7630=loc_7630

loc_7514:
7514:  96 DC             ldaa     $dc ; xrefs $7505:branch
7516:  81 3B             cmpa     #59
7518:  26 04             bne      $751e ; $751E=loc_751E
751A:  86 01             ldaa     #1
751C:  97 DC             staa     $dc

loc_751E:
751E:  12 AD 02 03       brset    $ad, #2, $7525 ; $7525=loc_7525 | xrefs $7518:branch
7522:  7E 75 A4          jmp      $75a4 ; $75A4=loc_75A4

loc_7525:
7525:  CE 10 00          ldx      #4096 ; xrefs $751E:branch
7528:  96 DB             ldaa     $db
752A:  91 DD             cmpa     $dd
752C:  26 18             bne      $7546 ; $7546=loc_7546
752E:  81 14             cmpa     #20
7530:  22 04             bhi      $7536 ; $7536=loc_7536
7532:  8B 0A             adda     #10
7534:  20 02             bra      $7538 ; $7538=loc_7538

loc_7536:
7536:  80 32             suba     #50 ; xrefs $7530:branch

loc_7538:
7538:  B7 23 71          staa     $2371 ; xrefs $7534:branch
753B:  1D 50 20          bclr     80, x; #32
753E:  BD 7B D9          jsr      $7bd9 ; $7BD9=sub_7BD9
7541:  BD 7C 6E          jsr      $7c6e ; $7C6E=sub_7C6E
7544:  20 15             bra      $755b ; $755B=loc_755B

loc_7546:
7546:  91 DE             cmpa     $de ; xrefs $752C:branch
7548:  27 03             beq      $754d ; $754D=loc_754D
754A:  7E 75 A1          jmp      $75a1 ; $75A1=loc_75A1

loc_754D:
754D:  80 14             suba     #20 ; xrefs $7548:branch
754F:  B7 23 71          staa     $2371
7552:  1C 50 20          bset     80, x; #32
7555:  BD 7B D9          jsr      $7bd9 ; $7BD9=sub_7BD9
7558:  BD 7C A1          jsr      $7ca1 ; $7CA1=sub_7CA1

loc_755B:
755B:  13 AE 02 42       brclr    $ae, #2, $75a1 ; $75A1=loc_75A1 | xrefs $7544:branch
755F:  13 A0 80 13       brclr    $a0, #-128, $7576 ; $7576=loc_7576
7563:  B6 20 E9          ldaa     $20e9
7566:  81 02             cmpa     #2
7568:  26 06             bne      $7570 ; $7570=loc_7570
756A:  18 CE 23 36       ldy      #9014
756E:  20 19             bra      $7589 ; $7589=loc_7589

loc_7570:
7570:  18 CE 23 1E       ldy      #8990 ; xrefs $7568:branch
7574:  20 13             bra      $7589 ; $7589=loc_7589

loc_7576:
7576:  B6 20 E9          ldaa     $20e9 ; xrefs $755F:branch
7579:  81 01             cmpa     #1
757B:  26 06             bne      $7583 ; $7583=loc_7583
757D:  18 CE 23 2A       ldy      #9002
7581:  20 06             bra      $7589 ; $7589=loc_7589

loc_7583:
7583:  18 CE 23 12       ldy      #8978 ; xrefs $757B:branch
7587:  20 00             bra      $7589 ; $7589=loc_7589

loc_7589:
7589:  18 A6 03          ldaa     3, y ; xrefs $756E:branch, $7574:branch, $7581:branch, $7587:branch
758C:  B7 23 55          staa     $2355
758F:  18 EC 04          ldd      4, y
7592:  FD 23 56          std      $2356
7595:  18 EC 08          ldd      8, y
7598:  FD 23 58          std      $2358
759B:  18 EC 06          ldd      6, y
759E:  FD 23 5A          std      $235a

loc_75A1:
75A1:  7E 76 30          jmp      $7630 ; $7630=loc_7630 | xrefs $754A:jump, $755B:branch

loc_75A4:
75A4:  96 DB             ldaa     $db ; xrefs $7522:jump
75A6:  B1 23 55          cmpa     $2355
75A9:  27 03             beq      $75ae ; $75AE=loc_75AE
75AB:  7E 76 30          jmp      $7630 ; $7630=loc_7630

loc_75AE:
75AE:  CE 10 00          ldx      #4096 ; xrefs $75A9:branch
75B1:  1F 20 40 0A       brclr    32, x; #64; $75bf ; $75BF=loc_75BF
75B5:  86 40             ldaa     #64
75B7:  B7 10 0B          staa     $100b ; $100B=CFORC
75BA:  FC 10 0E          ldd      $100e ; $100E=TCNT
75BD:  DD DF             std      $df

loc_75BF:
75BF:  1D 20 40          bclr     32, x; #64 ; xrefs $75B1:branch
75C2:  1C 22 40          bset     34, x; #64
75C5:  86 40             ldaa     #64
75C7:  B7 10 23          staa     $1023 ; $1023=TFLG1
75CA:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
75CC:  F3 23 56          addd     $2356
75CF:  FD 10 18          std      $1018
75D2:  FC 10 0E          ldd      $100e ; $100E=TCNT
75D5:  93 D9             subd     $d9 ; $00D9=captured_timer_value
75D7:  1A B3 23 56       cpd      $2356
75DB:  25 09             bcs      $75e6 ; $75E6=loc_75E6
75DD:  FC 10 0E          ldd      $100e ; $100E=TCNT
75E0:  C3 00 10          addd     #16
75E3:  FD 10 18          std      $1018

loc_75E6:
75E6:  13 A0 80 13       brclr    $a0, #-128, $75fd ; $75FD=loc_75FD | xrefs $75DB:branch
75EA:  B6 20 E9          ldaa     $20e9
75ED:  81 02             cmpa     #2
75EF:  26 06             bne      $75f7 ; $75F7=loc_75F7
75F1:  CE 23 36          ldx      #9014
75F4:  7E 76 0C          jmp      $760c ; $760C=loc_760C

loc_75F7:
75F7:  CE 23 1E          ldx      #8990 ; xrefs $75EF:branch
75FA:  7E 76 0C          jmp      $760c ; $760C=loc_760C

loc_75FD:
75FD:  B6 20 E9          ldaa     $20e9 ; xrefs $75E6:branch
7600:  81 01             cmpa     #1
7602:  26 05             bne      $7609 ; $7609=loc_7609
7604:  CE 23 2A          ldx      #9002
7607:  20 03             bra      $760c ; $760C=loc_760C

loc_7609:
7609:  CE 23 12          ldx      #8978 ; xrefs $7602:branch

loc_760C:
760C:  A6 03             ldaa     3, x ; xrefs $75F4:jump, $75FA:jump, $7607:branch
760E:  B7 23 55          staa     $2355
7611:  EC 04             ldd      4, x
7613:  FD 23 56          std      $2356
7616:  EC 08             ldd      8, x
7618:  FD 23 58          std      $2358
761B:  EC 06             ldd      6, x
761D:  FD 23 5A          std      $235a
7620:  CE 10 00          ldx      #4096
7623:  13 AE 04 09       brclr    $ae, #4, $7630 ; $7630=loc_7630
7627:  96 AD             ldaa     $ad
7629:  88 06             eora     #6
762B:  97 AD             staa     $ad
762D:  15 AE 04          bclr     $ae, #4

loc_7630:
7630:  96 DB             ldaa     $db ; xrefs $7511:jump, $75A1:jump, $75AB:jump, $7623:branch
7632:  81 32             cmpa     #50
7634:  27 07             beq      $763d ; $763D=loc_763D
7636:  81 14             cmpa     #20
7638:  27 03             beq      $763d ; $763D=loc_763D
763A:  7E 77 A0          jmp      $77a0 ; $77A0=loc_77A0

loc_763D:
763D:  12 AC 04 09       brset    $ac, #4, $764a ; $764A=loc_764A | xrefs $7634:branch, $7638:branch
7641:  14 AC 04          bset     $ac, #4
7644:  7F 23 04          clr      $2304
7647:  7E 76 FB          jmp      $76fb ; $76FB=loc_76FB

loc_764A:
764A:  96 B7             ldaa     $b7 ; xrefs $763D:branch
764C:  B7 23 00          staa     $2300
764F:  CE 10 00          ldx      #4096
7652:  1F 25 80 0A       brclr    37, x; #-128; $7660 ; $7660=engine_period_update
7656:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7658:  2B 06             bmi      $7660 ; $7660=engine_period_update
765A:  7C 23 00          inc      $2300
765D:  14 9E 40          bset     $9e, #64

; [CONFIRMED] Update prior capture and calculate RAM 0x00BA engine-period delta.
engine_period_update:
7660:  DC BA             ldd      $ba ; $00BA=engine_period_delta | xrefs $7652:branch, $7658:branch
7662:  FD 24 DB          std      $24db
7665:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7667:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7669:  DD BA             std      $ba ; $00BA=engine_period_delta
766B:  B6 23 00          ldaa     $2300
766E:  24 01             bcc      $7671 ; $7671=loc_7671
7670:  4A                deca     

loc_7671:
7671:  27 05             beq      $7678 ; $7678=loc_7678 | xrefs $766E:branch
7673:  CC FF FF          ldd      #-1
7676:  DD BA             std      $ba ; $00BA=engine_period_delta

loc_7678:
7678:  CE 10 00          ldx      #4096 ; xrefs $7671:branch
767B:  DC BA             ldd      $ba ; $00BA=engine_period_delta
767D:  1A B3 92 F8       cpd      $92f8
7681:  24 05             bcc      $7688 ; $7688=loc_7688
7683:  1D 50 08          bclr     80, x; #8
7686:  20 03             bra      $768b ; $768B=loc_768B

loc_7688:
7688:  1C 50 08          bset     80, x; #8 ; xrefs $7681:branch

loc_768B:
768B:  FC 24 DD          ldd      $24dd ; xrefs $7686:branch
768E:  FD 24 DF          std      $24df
7691:  DC BA             ldd      $ba ; $00BA=engine_period_delta
7693:  F3 24 DB          addd     $24db
7696:  24 03             bcc      $769b ; $769B=loc_769B
7698:  CC FF FF          ldd      #-1

loc_769B:
769B:  FD 24 DD          std      $24dd ; xrefs $7696:branch
769E:  12 A9 02 0B       brset    $a9, #2, $76ad ; $00A9=operating_mode_flags, $76AD=loc_76AD
76A2:  DC BA             ldd      $ba ; $00BA=engine_period_delta
76A4:  1A B3 92 EC       cpd      $92ec
76A8:  22 03             bhi      $76ad ; $76AD=loc_76AD
76AA:  14 A9 02          bset     $a9, #2 ; $00A9=operating_mode_flags

loc_76AD:
76AD:  13 AD 01 15       brclr    $ad, #1, $76c6 ; $76C6=loc_76C6 | xrefs $769E:branch, $76A8:branch
76B1:  DC BA             ldd      $ba ; $00BA=engine_period_delta
76B3:  1A B3 92 F0       cpd      $92f0
76B7:  25 05             bcs      $76be ; $76BE=loc_76BE
76B9:  7F 23 04          clr      $2304
76BC:  20 3D             bra      $76fb ; $76FB=loc_76FB

loc_76BE:
76BE:  96 AD             ldaa     $ad ; xrefs $76B7:branch
76C0:  88 03             eora     #3
76C2:  97 AD             staa     $ad
76C4:  20 35             bra      $76fb ; $76FB=loc_76FB

loc_76C6:
76C6:  13 AD 02 26       brclr    $ad, #2, $76f0 ; $76F0=loc_76F0 | xrefs $76AD:branch
76CA:  DC BA             ldd      $ba ; $00BA=engine_period_delta
76CC:  1A B3 92 F2       cpd      $92f2
76D0:  23 13             bls      $76e5 ; $76E5=loc_76E5
76D2:  14 AE 01          bset     $ae, #1
76D5:  13 AE 20 15       brclr    $ae, #32, $76ee ; $76EE=loc_76EE
76D9:  C6 1F             ldab     #31
76DB:  D7 DC             stab     $dc
76DD:  96 DB             ldaa     $db
76DF:  10                sba      
76E0:  B7 10 27          staa     $1027
76E3:  20 09             bra      $76ee ; $76EE=loc_76EE

loc_76E5:
76E5:  1A B3 92 F4       cpd      $92f4 ; xrefs $76D0:branch
76E9:  24 03             bcc      $76ee ; $76EE=loc_76EE
76EB:  14 AE 02          bset     $ae, #2

loc_76EE:
76EE:  20 0B             bra      $76fb ; $76FB=loc_76FB | xrefs $76D5:branch, $76E3:branch, $76E9:branch

loc_76F0:
76F0:  DC BA             ldd      $ba ; $00BA=engine_period_delta | xrefs $76C6:branch
76F2:  1A B3 92 F6       cpd      $92f6
76F6:  23 03             bls      $76fb ; $76FB=loc_76FB
76F8:  14 AE 04          bset     $ae, #4

loc_76FB:
76FB:  86 00             ldaa     #0 ; xrefs $7647:jump, $76BC:branch, $76C4:branch, $76EE:branch, $76F6:branch
76FD:  97 B7             staa     $b7
76FF:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7701:  DD B8             std      $b8 ; $00B8=previous_capture_or_schedule_base
7703:  13 AE 40 09       brclr    $ae, #64, $7710 ; $7710=loc_7710
7707:  DC BA             ldd      $ba ; $00BA=engine_period_delta
7709:  CE 00 0A          ldx      #10
770C:  02                idiv     
770D:  FF 20 8C          stx      $208c

loc_7710:
7710:  15 AE 60          bclr     $ae, #96 ; xrefs $7703:branch
7713:  15 AE 08          bclr     $ae, #8
7716:  15 AD 20          bclr     $ad, #32
7719:  B6 20 E9          ldaa     $20e9
771C:  4C                inca     
771D:  81 04             cmpa     #4
771F:  23 02             bls      $7723 ; $7723=loc_7723
7721:  86 01             ldaa     #1

loc_7723:
7723:  B7 20 E9          staa     $20e9 ; xrefs $771F:branch
7726:  13 9C 20 09       brclr    $9c, #32, $7733 ; $009C=scheduler_status_flags, $7733=loc_7733
772A:  85 01             bita     #1
772C:  26 05             bne      $7733 ; $7733=loc_7733
772E:  86 01             ldaa     #1
7730:  B7 20 E9          staa     $20e9

loc_7733:
7733:  CE 10 00          ldx      #4096 ; xrefs $7726:branch, $772C:branch
7736:  1D 24 40          bclr     36, x; #64
7739:  0E                cli      
773A:  14 AC 08          bset     $ac, #8
773D:  BD 58 77          jsr      $5877 ; $5877=sub_5877
7740:  BD BD 13          jsr      $bd13 ; $BD13=sub_BD13
7743:  BD B4 47          jsr      $b447 ; $B447=fuel_runtime_sequence
7746:  FC 93 0C          ldd      $930c
7749:  05                asld     
774A:  DE ED             ldx      $ed
774C:  03                fdiv     
774D:  8F                xgdx     
774E:  16                tab      
774F:  4F                clra     
7750:  DD EF             std      $ef
7752:  13 AD 01 09       brclr    $ad, #1, $775f ; $775F=loc_775F
7756:  FC 23 72          ldd      $2372
7759:  05                asld     
775A:  CE FF FF          ldx      #-1
775D:  20 04             bra      $7763 ; $7763=loc_7763

loc_775F:
775F:  DC ED             ldd      $ed ; xrefs $7752:branch
7761:  DE BA             ldx      $ba ; $00BA=engine_period_delta

loc_7763:
7763:  FD 23 80          std      $2380 ; xrefs $775D:branch
7766:  FF 23 82          stx      $2382
7769:  13 9C 20 17       brclr    $9c, #32, $7784 ; $009C=scheduler_status_flags, $7784=loc_7784
776D:  BD 93 BE          jsr      $93be ; $93BE=sub_93BE
7770:  14 AD 08          bset     $ad, #8
7773:  B6 20 E9          ldaa     $20e9
7776:  81 01             cmpa     #1
7778:  27 05             beq      $777f ; $777F=loc_777F
777A:  BD 7C F4          jsr      $7cf4 ; $7CF4=sub_7CF4
777D:  20 1A             bra      $7799 ; $7799=loc_7799

loc_777F:
777F:  BD 7D 14          jsr      $7d14 ; $7D14=sub_7D14 | xrefs $7778:branch
7782:  20 15             bra      $7799 ; $7799=loc_7799

loc_7784:
7784:  BD 94 35          jsr      $9435 ; $9435=sub_9435 | xrefs $7769:branch
7787:  14 AD 10          bset     $ad, #16
778A:  B6 20 E9          ldaa     $20e9
778D:  81 02             cmpa     #2
778F:  27 05             beq      $7796 ; $7796=loc_7796
7791:  BD 7D 34          jsr      $7d34 ; $7D34=sub_7D34
7794:  20 03             bra      $7799 ; $7799=loc_7799

loc_7796:
7796:  BD 7D 54          jsr      $7d54 ; $7D54=sub_7D54 | xrefs $778F:branch

loc_7799:
7799:  0F                sei       ; xrefs $777D:branch, $7782:branch, $7794:branch
779A:  CE 10 00          ldx      #4096
779D:  1C 24 40          bset     36, x; #64

loc_77A0:
77A0:  3B                rti       ; xrefs $763A:jump

; ---- unreached/data gap $77A1-$77A1 ----

        .org $77A2

sub_77A2:
77A2:  15 9C 08          bclr     $9c, #8 ; $009C=scheduler_status_flags | xrefs $750E:call
77A5:  96 B7             ldaa     $b7
77A7:  B7 23 00          staa     $2300
77AA:  CE 10 00          ldx      #4096
77AD:  1F 25 80 07       brclr    37, x; #-128; $77b8 ; $77B8=loc_77B8
77B1:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
77B3:  2B 03             bmi      $77b8 ; $77B8=loc_77B8
77B5:  7C 23 00          inc      $2300

loc_77B8:
77B8:  12 AC 01 36       brset    $ac, #1, $77f2 ; $77F2=loc_77F2 | xrefs $77AD:branch, $77B3:branch
77BC:  B6 23 86          ldaa     $2386
77BF:  27 28             beq      $77e9 ; $77E9=loc_77E9
77C1:  81 03             cmpa     #3
77C3:  26 17             bne      $77dc ; $77DC=loc_77DC
77C5:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
77C7:  B3 23 05          subd     $2305
77CA:  1A 83 4E 20       cpd      #20000
77CE:  22 0A             bhi      $77da ; $77DA=loc_77DA
77D0:  B6 23 00          ldaa     $2300
77D3:  81 01             cmpa     #1
77D5:  22 03             bhi      $77da ; $77DA=loc_77DA
77D7:  7E 7B C3          jmp      $7bc3 ; $7BC3=loc_7BC3

loc_77DA:
77DA:  86 03             ldaa     #3 ; xrefs $77CE:branch, $77D5:branch

loc_77DC:
77DC:  4A                deca      ; xrefs $77C3:branch
77DD:  B7 23 86          staa     $2386
77E0:  4F                clra     
77E1:  97 B7             staa     $b7
77E3:  B7 23 00          staa     $2300
77E6:  7E 7B B8          jmp      $7bb8 ; $7BB8=loc_7BB8

loc_77E9:
77E9:  14 AC 01          bset     $ac, #1 ; xrefs $77BF:branch
77EC:  7F 23 00          clr      $2300
77EF:  7E 7B B8          jmp      $7bb8 ; $7BB8=loc_7BB8

loc_77F2:
77F2:  12 AC 02 24       brset    $ac, #2, $781a ; $781A=loc_781A | xrefs $77B8:branch
77F6:  14 AC 02          bset     $ac, #2
77F9:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
77FB:  B3 23 05          subd     $2305
77FE:  FD 23 08          std      $2308
7801:  B6 23 00          ldaa     $2300
7804:  B2 23 04          sbca     $2304
7807:  B7 23 07          staa     $2307
780A:  FC 23 08          ldd      $2308
780D:  05                asld     
780E:  DD ED             std      $ed
7810:  B6 23 07          ldaa     $2307
7813:  49                rola     
7814:  B7 23 01          staa     $2301
7817:  7E 7B B8          jmp      $7bb8 ; $7BB8=loc_7BB8

loc_781A:
781A:  DC D9             ldd      $d9 ; $00D9=captured_timer_value | xrefs $77F2:branch
781C:  B3 23 05          subd     $2305
781F:  FD 23 08          std      $2308
7822:  B6 23 00          ldaa     $2300
7825:  B2 23 04          sbca     $2304
7828:  B7 23 07          staa     $2307
782B:  12 AC 10 03       brset    $ac, #16, $7832 ; $7832=loc_7832
782F:  7E 7A 3B          jmp      $7a3b ; $7A3B=loc_7A3B

loc_7832:
7832:  96 DB             ldaa     $db ; xrefs $782B:branch
7834:  81 1F             cmpa     #31
7836:  27 08             beq      $7840 ; $7840=loc_7840
7838:  22 79             bhi      $78b3 ; $78B3=loc_78B3
783A:  81 01             cmpa     #1
783C:  27 26             beq      $7864 ; $7864=loc_7864
783E:  20 5B             bra      $789b ; $789B=loc_789B

loc_7840:
7840:  DC D9             ldd      $d9 ; $00D9=captured_timer_value | xrefs $7836:branch
7842:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7844:  CE 00 0B          ldx      #11
7847:  02                idiv     
7848:  FF 23 72          stx      $2372
784B:  BD 7C 8A          jsr      $7c8a ; $7C8A=sub_7C8A
784E:  BD 7C A1          jsr      $7ca1 ; $7CA1=sub_7CA1
7851:  B6 20 E9          ldaa     $20e9
7854:  81 01             cmpa     #1
7856:  26 05             bne      $785d ; $785D=loc_785D
7858:  CE 20 E4          ldx      #8420
785B:  20 03             bra      $7860 ; $7860=loc_7860

loc_785D:
785D:  CE 20 E2          ldx      #8418 ; xrefs $7856:branch

loc_7860:
7860:  86 32             ldaa     #50 ; xrefs $785B:branch
7862:  20 22             bra      $7886 ; $7886=loc_7886

loc_7864:
7864:  DC D9             ldd      $d9 ; $00D9=captured_timer_value | xrefs $783C:branch
7866:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7868:  CE 00 0B          ldx      #11
786B:  02                idiv     
786C:  FF 23 72          stx      $2372
786F:  BD 7C 57          jsr      $7c57 ; $7C57=sub_7C57
7872:  BD 7C 6E          jsr      $7c6e ; $7C6E=sub_7C6E
7875:  B6 20 E9          ldaa     $20e9
7878:  81 02             cmpa     #2
787A:  26 05             bne      $7881 ; $7881=loc_7881
787C:  CE 20 E5          ldx      #8421
787F:  20 03             bra      $7884 ; $7884=loc_7884

loc_7881:
7881:  CE 20 E3          ldx      #8419 ; xrefs $787A:branch

loc_7884:
7884:  86 14             ldaa     #20 ; xrefs $787F:branch

loc_7886:
7886:  E6 00             ldab     0, x ; xrefs $7862:branch
7888:  FF 23 10          stx      $2310
788B:  BD 7F 1C          jsr      $7f1c ; $7F1C=sub_7F1C
788E:  4A                deca     
788F:  B7 23 53          staa     $2353
7892:  15 AD 20          bclr     $ad, #32
7895:  15 AE 08          bclr     $ae, #8
7898:  7E 7A 3B          jmp      $7a3b ; $7A3B=loc_7A3B

loc_789B:
789B:  81 14             cmpa     #20 ; xrefs $783E:branch
789D:  23 03             bls      $78a2 ; $78A2=loc_78A2
789F:  7E 7A 3B          jmp      $7a3b ; $7A3B=loc_7A3B

loc_78A2:
78A2:  14 AE 80          bset     $ae, #-128 ; xrefs $789D:branch
78A5:  14 A0 80          bset     $a0, #-128
78A8:  CE 10 00          ldx      #4096
78AB:  1D 50 20          bclr     80, x; #32
78AE:  FC 23 88          ldd      $2388 ; $2388=scheduler_scaled_output
78B1:  20 16             bra      $78c9 ; $78C9=loc_78C9

loc_78B3:
78B3:  81 32             cmpa     #50 ; xrefs $7838:branch
78B5:  23 03             bls      $78ba ; $78BA=loc_78BA
78B7:  7E 7A 3B          jmp      $7a3b ; $7A3B=loc_7A3B

loc_78BA:
78BA:  15 AE 80          bclr     $ae, #-128 ; xrefs $78B5:branch
78BD:  15 A0 80          bclr     $a0, #-128
78C0:  CE 10 00          ldx      #4096
78C3:  1C 50 20          bset     80, x; #32
78C6:  FC 23 88          ldd      $2388 ; $2388=scheduler_scaled_output

loc_78C9:
78C9:  FD 23 5C          std      $235c ; xrefs $78B1:branch
78CC:  13 AE 08 03       brclr    $ae, #8, $78d3 ; $78D3=loc_78D3
78D0:  7E 79 C1          jmp      $79c1 ; $79C1=loc_79C1

loc_78D3:
78D3:  12 AD 20 0F       brset    $ad, #32, $78e6 ; $78E6=loc_78E6 | xrefs $78CC:branch
78D7:  1A B3 23 08       cpd      $2308
78DB:  22 24             bhi      $7901 ; $7901=loc_7901
78DD:  96 DB             ldaa     $db
78DF:  81 01             cmpa     #1
78E1:  27 1E             beq      $7901 ; $7901=loc_7901
78E3:  14 AD 20          bset     $ad, #32

loc_78E6:
78E6:  96 DB             ldaa     $db ; xrefs $78D3:branch
78E8:  81 13             cmpa     #19
78EA:  26 0E             bne      $78fa ; $78FA=loc_78FA

loc_78EC:
78EC:  FC 23 08          ldd      $2308 ; xrefs $78FC:branch
78EF:  B3 23 5C          subd     $235c
78F2:  2B 03             bmi      $78f7 ; $78F7=loc_78F7
78F4:  7E 79 7D          jmp      $797d ; $797D=loc_797D

loc_78F7:
78F7:  7E 79 45          jmp      $7945 ; $7945=loc_7945 | xrefs $78F2:branch

loc_78FA:
78FA:  81 31             cmpa     #49 ; xrefs $78EA:branch
78FC:  27 EE             beq      $78ec ; $78EC=loc_78EC
78FE:  7E 7A 3B          jmp      $7a3b ; $7A3B=loc_7A3B

loc_7901:
7901:  15 AD 20          bclr     $ad, #32 ; xrefs $78DB:branch, $78E1:branch
7904:  FC 23 08          ldd      $2308
7907:  CE 00 0C          ldx      #12
790A:  02                idiv     
790B:  4D                tsta     
790C:  2A 01             bpl      $790f ; $790F=loc_790F
790E:  08                inx      

loc_790F:
790F:  FF 23 5E          stx      $235e ; xrefs $790C:branch
7912:  FC 23 5C          ldd      $235c
7915:  02                idiv     
7916:  4D                tsta     
7917:  2A 01             bpl      $791a ; $791A=loc_791A
7919:  08                inx      

loc_791A:
791A:  8F                xgdx      ; xrefs $7917:branch
791B:  C1 0C             cmpb     #12
791D:  24 08             bcc      $7927 ; $7927=loc_7927
791F:  C6 0C             ldab     #12
7921:  FE 23 08          ldx      $2308
7924:  FF 23 5C          stx      $235c

loc_7927:
7927:  FE 23 10          ldx      $2310 ; xrefs $791D:branch
792A:  EB 00             addb     0, x
792C:  37                pshb     
792D:  13 AE 80 04       brclr    $ae, #-128, $7935 ; $7935=loc_7935
7931:  86 14             ldaa     #20
7933:  20 02             bra      $7937 ; $7937=loc_7937

loc_7935:
7935:  86 32             ldaa     #50 ; xrefs $792D:branch

loc_7937:
7937:  90 DB             suba     $db ; xrefs $7933:branch
7939:  24 02             bcc      $793d ; $793D=loc_793D
793B:  8B 3C             adda     #60

loc_793D:
793D:  C6 0C             ldab     #12 ; xrefs $7939:branch
793F:  3D                mul      
7940:  17                tba      
7941:  33                pulb     
7942:  10                sba      
7943:  24 1B             bcc      $7960 ; $7960=loc_7960

loc_7945:
7945:  FE 23 5C          ldx      $235c ; xrefs $78F7:jump
7948:  BD 95 36          jsr      $9536 ; $9536=sub_9536
794B:  DF E1             stx      $e1
794D:  CE 10 00          ldx      #4096
7950:  86 42             ldaa     #66
7952:  B7 10 23          staa     $1023 ; $1023=TFLG1
7955:  1C 20 C0          bset     32, x; #-64
7958:  1C 22 42          bset     34, x; #66
795B:  14 AE 08          bset     $ae, #8
795E:  20 4B             bra      $79ab ; $79AB=loc_79AB

loc_7960:
7960:  81 0C             cmpa     #12 ; xrefs $7943:branch
7962:  22 74             bhi      $79d8 ; $79D8=loc_79D8
7964:  26 05             bne      $796b ; $796B=loc_796B
7966:  FC 23 08          ldd      $2308
7969:  20 12             bra      $797d ; $797D=loc_797D

loc_796B:
796B:  36                psha      ; xrefs $7964:branch
796C:  F6 23 5E          ldab     $235e
796F:  3D                mul      
7970:  17                tba      
7971:  5F                clrb     
7972:  FD 23 60          std      $2360
7975:  32                pula     
7976:  F6 23 5F          ldab     $235f
7979:  3D                mul      
797A:  F3 23 60          addd     $2360

loc_797D:
797D:  FD 23 67          std      $2367 ; xrefs $78F4:jump, $7969:branch
7980:  D3 D9             addd     $d9 ; $00D9=captured_timer_value
7982:  DD DF             std      $df
7984:  FD 10 18          std      $1018
7987:  86 42             ldaa     #66
7989:  B7 10 23          staa     $1023 ; $1023=TFLG1
798C:  CE 10 00          ldx      #4096
798F:  1C 20 C0          bset     32, x; #-64
7992:  1C 22 42          bset     34, x; #66
7995:  14 AE 08          bset     $ae, #8
7998:  FE 23 5C          ldx      $235c
799B:  BD 95 36          jsr      $9536 ; $9536=sub_9536
799E:  DF E1             stx      $e1
79A0:  FC 10 0E          ldd      $100e ; $100E=TCNT
79A3:  93 D9             subd     $d9 ; $00D9=captured_timer_value
79A5:  1A B3 23 67       cpd      $2367
79A9:  25 16             bcs      $79c1 ; $79C1=loc_79C1

loc_79AB:
79AB:  CE 10 00          ldx      #4096 ; xrefs $795E:branch
79AE:  1C 0B 40          bset     11, x; #64
79B1:  FC 10 0E          ldd      $100e ; $100E=TCNT
79B4:  DD DF             std      $df
79B6:  C3 00 0A          addd     #10
79B9:  FD 10 18          std      $1018
79BC:  86 40             ldaa     #64
79BE:  B7 10 23          staa     $1023 ; $1023=TFLG1

loc_79C1:
79C1:  12 AE 10 15       brset    $ae, #16, $79da ; $79DA=loc_79DA | xrefs $78D0:jump, $79A9:branch
79C5:  96 DB             ldaa     $db
79C7:  B1 23 53          cmpa     $2353
79CA:  26 6C             bne      $7a38 ; $7A38=loc_7A38
79CC:  FC 23 08          ldd      $2308
79CF:  1A B3 92 EE       cpd      $92ee
79D3:  25 05             bcs      $79da ; $79DA=loc_79DA
79D5:  14 AE 10          bset     $ae, #16

loc_79D8:
79D8:  20 61             bra      $7a3b ; $7A3B=loc_7A3B | xrefs $7962:branch, $79DA:branch

loc_79DA:
79DA:  12 AD 20 FA       brset    $ad, #32, $79d8 ; $79D8=loc_79D8 | xrefs $79C1:branch, $79D3:branch
79DE:  CE 10 00          ldx      #4096
79E1:  1F 20 40 1F       brclr    32, x; #64; $7a04 ; $7A04=loc_7A04
79E5:  12 AE 10 05       brset    $ae, #16, $79ee ; $79EE=loc_79EE
79E9:  14 AE 10          bset     $ae, #16
79EC:  20 4D             bra      $7a3b ; $7A3B=loc_7A3B

loc_79EE:
79EE:  1C 20 C0          bset     32, x; #-64 ; xrefs $79E5:branch
79F1:  1C 0B 40          bset     11, x; #64
79F4:  1D 22 40          bclr     34, x; #64
79F7:  FC 10 0E          ldd      $100e ; $100E=TCNT
79FA:  DD DF             std      $df
79FC:  D3 E1             addd     $e1
79FE:  FD 10 18          std      $1018
7A01:  1D 20 40          bclr     32, x; #64

loc_7A04:
7A04:  B6 23 08          ldaa     $2308 ; xrefs $79E1:branch
7A07:  F6 23 54          ldab     $2354
7A0A:  3D                mul      
7A0B:  8F                xgdx     
7A0C:  B6 23 09          ldaa     $2309
7A0F:  F6 23 54          ldab     $2354
7A12:  3D                mul      
7A13:  89 00             adca     #0
7A15:  16                tab      
7A16:  3A                abx      
7A17:  8F                xgdx     
7A18:  12 AE 10 03       brset    $ae, #16, $7a1f ; $7A1F=loc_7A1F
7A1C:  F3 23 08          addd     $2308

loc_7A1F:
7A1F:  FD 23 56          std      $2356 ; xrefs $7A18:branch
7A22:  D3 D9             addd     $d9 ; $00D9=captured_timer_value
7A24:  FD 10 18          std      $1018
7A27:  FC 10 0E          ldd      $100e ; $100E=TCNT
7A2A:  93 D9             subd     $d9 ; $00D9=captured_timer_value
7A2C:  1A B3 23 56       cpd      $2356
7A30:  25 06             bcs      $7a38 ; $7A38=loc_7A38
7A32:  CE 10 00          ldx      #4096
7A35:  1C 0B 40          bset     11, x; #64

loc_7A38:
7A38:  15 AE 10          bclr     $ae, #16 ; xrefs $79CA:branch, $7A30:branch

loc_7A3B:
7A3B:  13 AC 10 61       brclr    $ac, #16, $7aa0 ; $7AA0=loc_7AA0 | xrefs $782F:jump, $7898:jump, $789F:jump, $78B7:jump, $78FE:jump, $79D8:branch, $79EC:branch
7A3F:  15 9C 40          bclr     $9c, #64 ; $009C=scheduler_status_flags
7A42:  96 DB             ldaa     $db
7A44:  81 01             cmpa     #1
7A46:  27 07             beq      $7a4f ; $7A4F=loc_7A4F
7A48:  81 3A             cmpa     #58
7A4A:  26 20             bne      $7a6c ; $7A6C=loc_7A6C
7A4C:  14 9C 40          bset     $9c, #64 ; $009C=scheduler_status_flags

loc_7A4F:
7A4F:  DC ED             ldd      $ed ; xrefs $7A46:branch
7A51:  B3 23 08          subd     $2308
7A54:  B6 23 01          ldaa     $2301
7A57:  B2 23 07          sbca     $2307
7A5A:  12 9C 40 11       brset    $9c, #64, $7a6f ; $009C=scheduler_status_flags, $7A6F=loc_7A6F
7A5E:  24 03             bcc      $7a63 ; $7A63=loc_7A63
7A60:  7E 7B 2B          jmp      $7b2b ; $7B2B=loc_7B2B

loc_7A63:
7A63:  15 AC 10          bclr     $ac, #16 ; xrefs $7A5E:branch
7A66:  15 9D 10          bclr     $9d, #16
7A69:  7C 20 89          inc      $2089

loc_7A6C:
7A6C:  7E 7B 32          jmp      $7b32 ; $7B32=loc_7B32 | xrefs $7A4A:branch, $7A6F:branch

loc_7A6F:
7A6F:  24 FB             bcc      $7a6c ; $7A6C=loc_7A6C | xrefs $7A5A:branch
7A71:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7A73:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7A75:  CE 00 0B          ldx      #11
7A78:  02                idiv     
7A79:  FF 23 72          stx      $2372
7A7C:  BD 7C 57          jsr      $7c57 ; $7C57=sub_7C57
7A7F:  BD 7C 6E          jsr      $7c6e ; $7C6E=sub_7C6E
7A82:  B6 20 E9          ldaa     $20e9
7A85:  81 02             cmpa     #2
7A87:  26 05             bne      $7a8e ; $7A8E=loc_7A8E
7A89:  F6 20 E5          ldab     $20e5
7A8C:  20 03             bra      $7a91 ; $7A91=loc_7A91

loc_7A8E:
7A8E:  F6 20 E3          ldab     $20e3 ; xrefs $7A87:branch

loc_7A91:
7A91:  86 14             ldaa     #20 ; xrefs $7A8C:branch
7A93:  BD 7F 1C          jsr      $7f1c ; $7F1C=sub_7F1C
7A96:  4A                deca     
7A97:  B7 23 53          staa     $2353
7A9A:  7C 20 8A          inc      $208a
7A9D:  7E 7B 2B          jmp      $7b2b ; $7B2B=loc_7B2B

loc_7AA0:
7AA0:  12 A9 01 03       brset    $a9, #1, $7aa7 ; $00A9=operating_mode_flags, $7AA7=loc_7AA7 | xrefs $7A3B:branch
7AA4:  7E 7B 32          jmp      $7b32 ; $7B32=loc_7B32

loc_7AA7:
7AA7:  12 9D 10 4A       brset    $9d, #16, $7af5 ; $7AF5=loc_7AF5 | xrefs $7AA0:branch
7AAB:  DC ED             ldd      $ed
7AAD:  B3 23 08          subd     $2308
7AB0:  B6 23 01          ldaa     $2301
7AB3:  B2 23 07          sbca     $2307
7AB6:  24 7A             bcc      $7b32 ; $7B32=loc_7B32
7AB8:  DC ED             ldd      $ed
7ABA:  05                asld     
7ABB:  FD 23 65          std      $2365
7ABE:  B6 23 01          ldaa     $2301
7AC1:  49                rola     
7AC2:  B7 23 64          staa     $2364
7AC5:  FC 23 08          ldd      $2308
7AC8:  B3 23 65          subd     $2365
7ACB:  B6 23 07          ldaa     $2307
7ACE:  B2 23 64          sbca     $2364
7AD1:  24 5F             bcc      $7b32 ; $7B32=loc_7B32
7AD3:  FC 23 07          ldd      $2307
7AD6:  04                lsrd     
7AD7:  FD 23 6B          std      $236b
7ADA:  B6 23 09          ldaa     $2309
7ADD:  46                rora     
7ADE:  B7 23 6D          staa     $236d
7AE1:  FC 23 6B          ldd      $236b
7AE4:  04                lsrd     
7AE5:  FD 23 6E          std      $236e
7AE8:  B6 23 6D          ldaa     $236d
7AEB:  46                rora     
7AEC:  B7 23 70          staa     $2370
7AEF:  14 9D 10          bset     $9d, #16
7AF2:  7E 7B B8          jmp      $7bb8 ; $7BB8=loc_7BB8

loc_7AF5:
7AF5:  FC 23 08          ldd      $2308 ; xrefs $7AA7:branch
7AF8:  B3 23 6C          subd     $236c
7AFB:  B6 23 07          ldaa     $2307
7AFE:  B2 23 6B          sbca     $236b
7B01:  24 23             bcc      $7b26 ; $7B26=loc_7B26
7B03:  FC 23 6F          ldd      $236f
7B06:  B3 23 08          subd     $2308
7B09:  B6 23 6E          ldaa     $236e
7B0C:  B2 23 07          sbca     $2307
7B0F:  24 15             bcc      $7b26 ; $7B26=loc_7B26
7B11:  14 AC 10          bset     $ac, #16
7B14:  86 14             ldaa     #20
7B16:  F6 20 E3          ldab     $20e3
7B19:  BD 7F 1C          jsr      $7f1c ; $7F1C=sub_7F1C
7B1C:  4A                deca     
7B1D:  B7 23 53          staa     $2353
7B20:  86 02             ldaa     #2
7B22:  97 DB             staa     $db
7B24:  20 0C             bra      $7b32 ; $7B32=loc_7B32

loc_7B26:
7B26:  15 9D 10          bclr     $9d, #16 ; xrefs $7B01:branch, $7B0F:branch
7B29:  20 07             bra      $7b32 ; $7B32=loc_7B32

loc_7B2B:
7B2B:  86 01             ldaa     #1 ; xrefs $7A60:jump, $7A9D:jump
7B2D:  97 DB             staa     $db
7B2F:  7E 7B B8          jmp      $7bb8 ; $7BB8=loc_7BB8

loc_7B32:
7B32:  DC ED             ldd      $ed ; xrefs $7A6C:jump, $7AA4:jump, $7AB6:branch, $7AD1:branch, $7B24:branch, $7B29:branch
7B34:  FD 23 02          std      $2302
7B37:  FC 23 08          ldd      $2308
7B3A:  05                asld     
7B3B:  DD ED             std      $ed
7B3D:  B6 23 07          ldaa     $2307
7B40:  49                rola     
7B41:  B7 23 01          staa     $2301
7B44:  26 72             bne      $7bb8 ; $7BB8=loc_7BB8
7B46:  DC ED             ldd      $ed
7B48:  1A B3 92 EA       cpd      $92ea
7B4C:  22 4E             bhi      $7b9c ; $7B9C=loc_7B9C
7B4E:  FC 23 02          ldd      $2302
7B51:  1A B3 92 EA       cpd      $92ea
7B55:  22 45             bhi      $7b9c ; $7B9C=loc_7B9C
7B57:  14 A9 03          bset     $a9, #3 ; $00A9=operating_mode_flags
7B5A:  14 AD 02          bset     $ad, #2
7B5D:  15 AD 05          bclr     $ad, #5
7B60:  CE 10 00          ldx      #4096
7B63:  1C 00 08          bset     0, x; #8
7B66:  1C 50 03          bset     80, x; #3
7B69:  BD 7C B3          jsr      $7cb3 ; $7CB3=sub_7CB3
7B6C:  BD 93 BE          jsr      $93be ; $93BE=sub_93BE
7B6F:  CE FF FF          ldx      #-1
7B72:  DC ED             ldd      $ed
7B74:  FD 23 80          std      $2380
7B77:  FF 23 82          stx      $2382
7B7A:  BD 7C F4          jsr      $7cf4 ; $7CF4=sub_7CF4
7B7D:  BD 7C 8A          jsr      $7c8a ; $7C8A=sub_7C8A
7B80:  BD 7C A1          jsr      $7ca1 ; $7CA1=sub_7CA1
7B83:  BD 94 35          jsr      $9435 ; $9435=sub_9435
7B86:  CE FF FF          ldx      #-1
7B89:  DC ED             ldd      $ed
7B8B:  FD 23 80          std      $2380
7B8E:  FF 23 82          stx      $2382
7B91:  BD 7D 34          jsr      $7d34 ; $7D34=sub_7D34
7B94:  BD 7C 57          jsr      $7c57 ; $7C57=sub_7C57
7B97:  BD 7C 6E          jsr      $7c6e ; $7C6E=sub_7C6E
7B9A:  20 30             bra      $7bcc ; $7BCC=loc_7BCC

loc_7B9C:
7B9C:  12 A9 01 18       brset    $a9, #1, $7bb8 ; $00A9=operating_mode_flags, $7BB8=loc_7BB8 | xrefs $7B4C:branch, $7B55:branch
7BA0:  1A B3 92 E8       cpd      $92e8
7BA4:  22 12             bhi      $7bb8 ; $7BB8=loc_7BB8
7BA6:  CE 10 00          ldx      #4096
7BA9:  1C 00 08          bset     0, x; #8
7BAC:  1C 50 03          bset     80, x; #3
7BAF:  14 A9 01          bset     $a9, #1 ; $00A9=operating_mode_flags
7BB2:  7F 00 B7          clr      >$00b7
7BB5:  7F 23 00          clr      $2300

loc_7BB8:
7BB8:  DC D9             ldd      $d9 ; $00D9=captured_timer_value | xrefs $77E6:jump, $77EF:jump, $7817:jump, $7AF2:jump, $7B2F:jump, $7B44:branch, $7B9C:branch, $7BA4:branch
7BBA:  FD 23 05          std      $2305
7BBD:  B6 23 00          ldaa     $2300
7BC0:  B7 23 04          staa     $2304

loc_7BC3:
7BC3:  12 AC 10 05       brset    $ac, #16, $7bcc ; $7BCC=loc_7BCC | xrefs $77D7:jump
7BC7:  7F 00 DC          clr      >$00dc
7BCA:  20 0B             bra      $7bd7 ; $7BD7=loc_7BD7

loc_7BCC:
7BCC:  96 DB             ldaa     $db ; xrefs $7B9A:branch, $7BC3:branch
7BCE:  4C                inca     
7BCF:  81 3B             cmpa     #59
7BD1:  26 02             bne      $7bd5 ; $7BD5=loc_7BD5
7BD3:  86 01             ldaa     #1

loc_7BD5:
7BD5:  97 DC             staa     $dc ; xrefs $7BD1:branch

loc_7BD7:
7BD7:  39                rts       ; xrefs $7BCA:branch

; ---- unreached/data gap $7BD8-$7BD8 ----

        .org $7BD9

sub_7BD9:
7BD9:  F6 23 71          ldab     $2371 ; xrefs $753E:call, $7555:call
7BDC:  4F                clra     
7BDD:  8F                xgdx     
7BDE:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7BE0:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7BE2:  02                idiv     
7BE3:  FF 23 72          stx      $2372
7BE6:  F6 23 75          ldab     $2375
7BE9:  B6 23 72          ldaa     $2372
7BEC:  3D                mul      
7BED:  8F                xgdx     
7BEE:  F6 23 75          ldab     $2375
7BF1:  B6 23 73          ldaa     $2373
7BF4:  3D                mul      
7BF5:  16                tab      
7BF6:  3A                abx      
7BF7:  FF 23 78          stx      $2378
7BFA:  B6 23 73          ldaa     $2373
7BFD:  F6 23 74          ldab     $2374
7C00:  3D                mul      
7C01:  F3 23 78          addd     $2378
7C04:  FD 23 78          std      $2378
7C07:  B6 23 72          ldaa     $2372
7C0A:  F6 23 74          ldab     $2374
7C0D:  3D                mul      
7C0E:  17                tba      
7C0F:  5F                clrb     
7C10:  F3 23 78          addd     $2378
7C13:  FD 23 7A          std      $237a
7C16:  D3 B8             addd     $b8 ; $00B8=previous_capture_or_schedule_base
7C18:  FD 23 7C          std      $237c
7C1B:  8F                xgdx     
7C1C:  DC EB             ldd      $eb
7C1E:  DD E1             std      $e1
7C20:  8F                xgdx     
7C21:  93 E1             subd     $e1
7C23:  CE 10 00          ldx      #4096
7C26:  FD 23 7E          std      $237e
7C29:  FD 10 18          std      $1018
7C2C:  DD DF             std      $df
7C2E:  86 42             ldaa     #66
7C30:  B7 10 23          staa     $1023 ; $1023=TFLG1
7C33:  1C 20 C0          bset     32, x; #-64
7C36:  1C 22 42          bset     34, x; #66
7C39:  FC 10 0E          ldd      $100e ; $100E=TCNT
7C3C:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7C3E:  FD 23 78          std      $2378
7C41:  FC 23 7E          ldd      $237e
7C44:  93 B8             subd     $b8 ; $00B8=previous_capture_or_schedule_base
7C46:  1A B3 23 78       cpd      $2378
7C4A:  22 09             bhi      $7c55 ; $7C55=loc_7C55
7C4C:  FC 10 0E          ldd      $100e ; $100E=TCNT
7C4F:  C3 00 0A          addd     #10
7C52:  FD 10 18          std      $1018

loc_7C55:
7C55:  39                rts       ; xrefs $7C4A:branch

; ---- unreached/data gap $7C56-$7C56 ----

        .org $7C57

sub_7C57:
7C57:  3C                pshx      ; xrefs $748A:call, $786F:call, $7A7C:call, $7B94:call, $7FEE:call
7C58:  B6 20 E9          ldaa     $20e9
7C5B:  81 02             cmpa     #2
7C5D:  27 05             beq      $7c64 ; $7C64=loc_7C64
7C5F:  CE 23 1E          ldx      #8990
7C62:  20 03             bra      $7c67 ; $7C67=loc_7C67

loc_7C64:
7C64:  CE 23 36          ldx      #9014 ; xrefs $7C5D:branch

loc_7C67:
7C67:  A6 00             ldaa     0, x ; xrefs $7C62:branch
7C69:  97 DE             staa     $de
7C6B:  38                pulx     
7C6C:  39                rts      

; ---- unreached/data gap $7C6D-$7C6D ----

        .org $7C6E

sub_7C6E:
7C6E:  3C                pshx      ; xrefs $7541:call, $7872:call, $7A7F:call, $7B97:call, $7FF1:call
7C6F:  B6 20 E9          ldaa     $20e9
7C72:  81 02             cmpa     #2
7C74:  27 05             beq      $7c7b ; $7C7B=loc_7C7B
7C76:  CE 23 1E          ldx      #8990
7C79:  20 03             bra      $7c7e ; $7C7E=loc_7C7E

loc_7C7B:
7C7B:  CE 23 36          ldx      #9014 ; xrefs $7C74:branch

loc_7C7E:
7C7E:  EC 01             ldd      1, x ; xrefs $7C79:branch, $7CAC:branch, $7CB1:branch
7C80:  DD EB             std      $eb
7C82:  EC 0A             ldd      10, x
7C84:  FD 23 74          std      $2374
7C87:  38                pulx     
7C88:  39                rts      

; ---- unreached/data gap $7C89-$7C89 ----

        .org $7C8A

sub_7C8A:
7C8A:  3C                pshx      ; xrefs $7496:call, $784B:call, $7B7D:call, $7FF6:call
7C8B:  B6 20 E9          ldaa     $20e9
7C8E:  81 01             cmpa     #1
7C90:  27 05             beq      $7c97 ; $7C97=loc_7C97
7C92:  CE 23 12          ldx      #8978
7C95:  20 03             bra      $7c9a ; $7C9A=loc_7C9A

loc_7C97:
7C97:  CE 23 2A          ldx      #9002 ; xrefs $7C90:branch

loc_7C9A:
7C9A:  A6 00             ldaa     0, x ; xrefs $7C95:branch
7C9C:  97 DD             staa     $dd
7C9E:  38                pulx     
7C9F:  39                rts      

; ---- unreached/data gap $7CA0-$7CA0 ----

        .org $7CA1

sub_7CA1:
7CA1:  3C                pshx      ; xrefs $7558:call, $784E:call, $7B80:call, $7FF9:call
7CA2:  B6 20 E9          ldaa     $20e9
7CA5:  81 01             cmpa     #1
7CA7:  27 05             beq      $7cae ; $7CAE=loc_7CAE
7CA9:  CE 23 12          ldx      #8978
7CAC:  20 D0             bra      $7c7e ; $7C7E=loc_7C7E

loc_7CAE:
7CAE:  CE 23 2A          ldx      #9002 ; xrefs $7CA7:branch
7CB1:  20 CB             bra      $7c7e ; $7C7E=loc_7C7E

sub_7CB3:
7CB3:  7C 20 88          inc      $2088 ; xrefs $73E0:call, $7B69:call
7CB6:  96 DD             ldaa     $dd
7CB8:  81 3A             cmpa     #58
7CBA:  26 07             bne      $7cc3 ; $7CC3=loc_7CC3
7CBC:  86 38             ldaa     #56
7CBE:  97 DD             staa     $dd
7CC0:  15 A0 80          bclr     $a0, #-128

loc_7CC3:
7CC3:  15 9C 08          bclr     $9c, #8 ; $009C=scheduler_status_flags | xrefs $7CBA:branch
7CC6:  15 AC 14          bclr     $ac, #20
7CC9:  DC D9             ldd      $d9 ; $00D9=captured_timer_value
7CCB:  B3 23 0A          subd     $230a
7CCE:  B3 23 0A          subd     $230a
7CD1:  FD 23 0C          std      $230c
7CD4:  86 3A             ldaa     #58
7CD6:  97 DB             staa     $db
7CD8:  39                rts      

; ---- unreached/data gap $7CD9-$7CF3 ----

        .org $7CF4

sub_7CF4:
7CF4:  DC E3             ldd      $e3 ; xrefs $777A:call, $7B7A:call
7CF6:  FD 23 48          std      $2348
7CF9:  18 CE 23 12       ldy      #8978
7CFD:  B6 20 E3          ldaa     $20e3
7D00:  CE 20 E2          ldx      #8418
7D03:  BD 7E 78          jsr      $7e78 ; $7E78=sub_7E78
7D06:  B6 20 E3          ldaa     $20e3
7D09:  BD 7D CF          jsr      $7dcf ; $7DCF=sub_7DCF
7D0C:  CE 7C DA          ldx      #31962
7D0F:  BD 7D 74          jsr      $7d74 ; $7D74=sub_7D74
7D12:  39                rts      

; ---- unreached/data gap $7D13-$7D13 ----

        .org $7D14

sub_7D14:
7D14:  DC E3             ldd      $e3 ; xrefs $777F:call
7D16:  FD 23 48          std      $2348
7D19:  18 CE 23 2A       ldy      #9002
7D1D:  B6 20 E5          ldaa     $20e5
7D20:  CE 20 E4          ldx      #8420
7D23:  BD 7E 78          jsr      $7e78 ; $7E78=sub_7E78
7D26:  B6 20 E5          ldaa     $20e5
7D29:  BD 7D CF          jsr      $7dcf ; $7DCF=sub_7DCF
7D2C:  CE 7C DA          ldx      #31962
7D2F:  BD 7D 74          jsr      $7d74 ; $7D74=sub_7D74
7D32:  39                rts      

; ---- unreached/data gap $7D33-$7D33 ----

        .org $7D34

sub_7D34:
7D34:  DC E5             ldd      $e5 ; xrefs $7791:call, $7B91:call
7D36:  FD 23 48          std      $2348
7D39:  18 CE 23 1E       ldy      #8990
7D3D:  B6 20 E4          ldaa     $20e4
7D40:  CE 20 E3          ldx      #8419
7D43:  BD 7E 9B          jsr      $7e9b ; $7E9B=sub_7E9B
7D46:  B6 20 E4          ldaa     $20e4
7D49:  BD 7D CF          jsr      $7dcf ; $7DCF=sub_7DCF
7D4C:  CE 7C EA          ldx      #31978
7D4F:  BD 7D 74          jsr      $7d74 ; $7D74=sub_7D74
7D52:  39                rts      

; ---- unreached/data gap $7D53-$7D53 ----

        .org $7D54

sub_7D54:
7D54:  DC E5             ldd      $e5 ; xrefs $7796:call
7D56:  FD 23 48          std      $2348
7D59:  18 CE 23 36       ldy      #9014
7D5D:  B6 20 E2          ldaa     $20e2
7D60:  CE 20 E5          ldx      #8421
7D63:  BD 7E 9B          jsr      $7e9b ; $7E9B=sub_7E9B
7D66:  B6 20 E2          ldaa     $20e2
7D69:  BD 7D CF          jsr      $7dcf ; $7DCF=sub_7DCF
7D6C:  CE 7C EA          ldx      #31978
7D6F:  BD 7D 74          jsr      $7d74 ; $7D74=sub_7D74
7D72:  39                rts      

; ---- unreached/data gap $7D73-$7D73 ----

        .org $7D74

sub_7D74:
7D74:  FC 23 48          ldd      $2348 ; xrefs $7D0F:call, $7D2F:call, $7D4F:call, $7D6F:call
7D77:  18 ED 01          std      1, y
7D7A:  FC 23 80          ldd      $2380
7D7D:  04                lsrd     
7D7E:  FD 23 48          std      $2348
7D81:  A6 00             ldaa     0, x
7D83:  08                inx      
7D84:  B7 23 4A          staa     $234a
7D87:  B1 7C DA          cmpa     $7cda
7D8A:  26 25             bne      $7db1 ; $7DB1=loc_7DB1
7D8C:  B6 23 42          ldaa     $2342
7D8F:  8B 32             adda     #50
7D91:  A1 00             cmpa     0, x
7D93:  23 0F             bls      $7da4 ; $7DA4=loc_7DA4
7D95:  C6 03             ldab     #3
7D97:  3A                abx      
7D98:  80 3C             suba     #60
7D9A:  A1 00             cmpa     0, x
7D9C:  26 2A             bne      $7dc8 ; $7DC8=loc_7DC8

loc_7D9E:
7D9E:  A6 01             ldaa     1, x ; xrefs $7DA4:branch
7DA0:  E6 02             ldab     2, x
7DA2:  20 26             bra      $7dca ; $7DCA=loc_7DCA

loc_7DA4:
7DA4:  27 F8             beq      $7d9e ; $7D9E=loc_7D9E | xrefs $7D93:branch
7DA6:  C6 06             ldab     #6
7DA8:  3A                abx      
7DA9:  7A 23 4A          dec      $234a
7DAC:  7A 23 4A          dec      $234a
7DAF:  20 05             bra      $7db6 ; $7DB6=loc_7DB6

loc_7DB1:
7DB1:  B6 23 42          ldaa     $2342 ; xrefs $7D8A:branch
7DB4:  8B 14             adda     #20

loc_7DB6:
7DB6:  A1 00             cmpa     0, x ; xrefs $7DAF:branch, $7DC6:branch
7DB8:  26 06             bne      $7dc0 ; $7DC0=loc_7DC0
7DBA:  A6 01             ldaa     1, x
7DBC:  E6 02             ldab     2, x
7DBE:  20 0A             bra      $7dca ; $7DCA=loc_7DCA

loc_7DC0:
7DC0:  C6 03             ldab     #3 ; xrefs $7DB8:branch
7DC2:  3A                abx      
7DC3:  7A 23 4A          dec      $234a
7DC6:  26 EE             bne      $7db6 ; $7DB6=loc_7DB6

loc_7DC8:
7DC8:  C6 02             ldab     #2 ; xrefs $7D9C:branch

loc_7DCA:
7DCA:  18 A7 00          staa     0, y ; xrefs $7DA2:branch, $7DBE:branch
7DCD:  39                rts      

; ---- unreached/data gap $7DCE-$7DCE ----

        .org $7DCF

sub_7DCF:
7DCF:  18 3C             pshy      ; xrefs $7D09:call, $7D29:call, $7D49:call, $7D69:call
7DD1:  CE 00 0C          ldx      #12
7DD4:  5F                clrb     
7DD5:  02                idiv     
7DD6:  FF 23 44          stx      $2344
7DD9:  CC 1E 00          ldd      #7680
7DDC:  B3 23 44          subd     $2344
7DDF:  93 EF             subd     $ef
7DE1:  FD 23 76          std      $2376
7DE4:  FC 23 82          ldd      $2382
7DE7:  1A 83 FF FF       cpd      #-1
7DEB:  26 0D             bne      $7dfa ; $7DFA=loc_7DFA
7DED:  FC 23 80          ldd      $2380
7DF0:  FD 23 4D          std      $234d
7DF3:  8F                xgdx     
7DF4:  FC 23 48          ldd      $2348
7DF7:  05                asld     
7DF8:  20 29             bra      $7e23 ; $7E23=loc_7E23

loc_7DFA:
7DFA:  04                lsrd      ; xrefs $7DEB:branch
7DFB:  04                lsrd     
7DFC:  04                lsrd     
7DFD:  FD 23 4D          std      $234d
7E00:  8F                xgdx     
7E01:  7F 23 4A          clr      $234a
7E04:  FC 23 48          ldd      $2348
7E07:  36                psha     
7E08:  86 0F             ldaa     #15
7E0A:  3D                mul      
7E0B:  FD 23 4B          std      $234b
7E0E:  33                pulb     
7E0F:  86 0F             ldaa     #15
7E11:  3D                mul      
7E12:  F3 23 4A          addd     $234a
7E15:  04                lsrd     
7E16:  76 23 4C          ror      $234c
7E19:  04                lsrd     
7E1A:  76 23 4C          ror      $234c
7E1D:  FD 23 4A          std      $234a
7E20:  FC 23 4B          ldd      $234b

loc_7E23:
7E23:  02                idiv      ; xrefs $7DF8:branch
7E24:  8F                xgdx     
7E25:  F7 23 46          stab     $2346
7E28:  8F                xgdx     
7E29:  FE 23 4D          ldx      $234d
7E2C:  03                fdiv     
7E2D:  8F                xgdx     
7E2E:  B7 23 47          staa     $2347
7E31:  CC 1C 00          ldd      #7168
7E34:  B3 23 44          subd     $2344
7E37:  B3 23 46          subd     $2346
7E3A:  FD 23 4D          std      $234d
7E3D:  4A                deca     
7E3E:  4A                deca     
7E3F:  2E 27             bgt      $7e68 ; $7E68=loc_7E68
7E41:  26 04             bne      $7e47 ; $7E47=loc_7E47
7E43:  86 FF             ldaa     #-1
7E45:  20 02             bra      $7e49 ; $7E49=loc_7E49

loc_7E47:
7E47:  4C                inca      ; xrefs $7E41:branch
7E48:  40                nega     

loc_7E49:
7E49:  8B 02             adda     #2 ; xrefs $7E45:branch
7E4B:  B7 23 4C          staa     $234c
7E4E:  FC 23 80          ldd      $2380
7E51:  04                lsrd     
7E52:  FD 23 4A          std      $234a
7E55:  FC 23 48          ldd      $2348

loc_7E58:
7E58:  B3 23 4A          subd     $234a ; xrefs $7E5E:branch
7E5B:  7A 23 4C          dec      $234c
7E5E:  26 F8             bne      $7e58 ; $7E58=loc_7E58
7E60:  FD 23 48          std      $2348
7E63:  5F                clrb     
7E64:  86 03             ldaa     #3
7E66:  20 03             bra      $7e6b ; $7E6B=loc_7E6B

loc_7E68:
7E68:  FC 23 4D          ldd      $234d ; xrefs $7E3F:branch

loc_7E6B:
7E6B:  FD 23 42          std      $2342 ; xrefs $7E66:branch
7E6E:  FE 23 76          ldx      $2376
7E71:  18 38             puly     
7E73:  CD EF 0A          stx      10, y
7E76:  39                rts      

; ---- unreached/data gap $7E77-$7E77 ----

        .org $7E78

sub_7E78:
7E78:  3C                pshx      ; xrefs $7D03:call, $7D23:call
7E79:  36                psha     
7E7A:  16                tab      
7E7B:  86 14             ldaa     #20
7E7D:  BD 7F 1C          jsr      $7f1c ; $7F1C=sub_7F1C
7E80:  80 02             suba     #2
7E82:  18 A7 03          staa     3, y
7E85:  FC 23 48          ldd      $2348
7E88:  FD 23 69          std      $2369
7E8B:  04                lsrd     
7E8C:  F3 23 48          addd     $2348
7E8F:  18 ED 08          std      8, y
7E92:  33                pulb     
7E93:  38                pulx     
7E94:  A6 00             ldaa     0, x
7E96:  10                sba      
7E97:  16                tab      
7E98:  4F                clra     
7E99:  20 21             bra      $7ebc ; $7EBC=loc_7EBC

sub_7E9B:
7E9B:  3C                pshx      ; xrefs $7D43:call, $7D63:call
7E9C:  36                psha     
7E9D:  16                tab      
7E9E:  86 32             ldaa     #50
7EA0:  BD 7F 1C          jsr      $7f1c ; $7F1C=sub_7F1C
7EA3:  80 02             suba     #2
7EA5:  18 A7 03          staa     3, y
7EA8:  FC 23 48          ldd      $2348
7EAB:  FD 23 69          std      $2369
7EAE:  04                lsrd     
7EAF:  F3 23 48          addd     $2348
7EB2:  18 ED 08          std      8, y
7EB5:  33                pulb     
7EB6:  38                pulx     
7EB7:  A6 00             ldaa     0, x
7EB9:  10                sba      
7EBA:  16                tab      
7EBB:  4F                clra     

loc_7EBC:
7EBC:  CE 01 68          ldx      #360 ; xrefs $7E99:branch
7EBF:  7F 23 5C          clr      $235c
7EC2:  5D                tstb     
7EC3:  27 08             beq      $7ecd ; $7ECD=loc_7ECD
7EC5:  2A 0B             bpl      $7ed2 ; $7ED2=loc_7ED2
7EC7:  43                coma     
7EC8:  C3 01 68          addd     #360
7ECB:  20 08             bra      $7ed5 ; $7ED5=loc_7ED5

loc_7ECD:
7ECD:  FC 23 82          ldd      $2382 ; xrefs $7EC3:branch
7ED0:  20 30             bra      $7f02 ; $7F02=loc_7F02

loc_7ED2:
7ED2:  7C 23 5C          inc      $235c ; xrefs $7EC5:branch

loc_7ED5:
7ED5:  03                fdiv      ; xrefs $7ECB:branch
7ED6:  8F                xgdx     
7ED7:  5D                tstb     
7ED8:  2A 09             bpl      $7ee3 ; $7EE3=loc_7EE3
7EDA:  4C                inca     
7EDB:  26 06             bne      $7ee3 ; $7EE3=loc_7EE3
7EDD:  7C 23 5C          inc      $235c
7EE0:  5F                clrb     
7EE1:  20 12             bra      $7ef5 ; $7EF5=loc_7EF5

loc_7EE3:
7EE3:  36                psha      ; xrefs $7ED8:branch, $7EDB:branch
7EE4:  F6 23 82          ldab     $2382
7EE7:  3D                mul      
7EE8:  FD 23 5E          std      $235e
7EEB:  F6 23 83          ldab     $2383
7EEE:  32                pula     
7EEF:  3D                mul      
7EF0:  16                tab      
7EF1:  4F                clra     
7EF2:  F3 23 5E          addd     $235e

loc_7EF5:
7EF5:  7D 23 5C          tst      $235c ; xrefs $7EE1:branch
7EF8:  27 08             beq      $7f02 ; $7F02=loc_7F02

loc_7EFA:
7EFA:  F3 23 82          addd     $2382 ; xrefs $7F00:branch
7EFD:  7A 23 5C          dec      $235c
7F00:  26 F8             bne      $7efa ; $7EFA=loc_7EFA

loc_7F02:
7F02:  B3 23 69          subd     $2369 ; xrefs $7ED0:branch, $7EF8:branch
7F05:  18 ED 06          std      6, y
7F08:  FC 23 80          ldd      $2380
7F0B:  04                lsrd     
7F0C:  B6 23 54          ldaa     $2354
7F0F:  3D                mul      
7F10:  89 00             adca     #0
7F12:  16                tab      
7F13:  4F                clra     
7F14:  F3 23 80          addd     $2380
7F17:  18 ED 04          std      4, y
7F1A:  39                rts      

; ---- unreached/data gap $7F1B-$7F1B ----

        .org $7F1C

sub_7F1C:
7F1C:  36                psha      ; xrefs $788B:call, $7A93:call, $7B19:call, $7E7D:call, $7EA0:call
7F1D:  17                tba      
7F1E:  5F                clrb     
7F1F:  CE 00 0C          ldx      #12
7F22:  02                idiv     
7F23:  8F                xgdx     
7F24:  D3 EF             addd     $ef
7F26:  FD 23 5C          std      $235c
7F29:  5F                clrb     
7F2A:  32                pula     
7F2B:  B3 23 5C          subd     $235c
7F2E:  F7 23 54          stab     $2354
7F31:  39                rts      

; ---- unreached/data gap $7F32-$7F32 ----

        .org $7F33
7F33:  CE 10 00          ldx      #4096
7F36:  86 40             ldaa     #64
7F38:  B7 10 23          staa     $1023 ; $1023=TFLG1
7F3B:  12 AD 04 50       brset    $ad, #4, $7f8f ; $7F8F=loc_7F8F
7F3F:  1E 20 40 09       brset    32, x; #64; $7f4c ; $7F4C=loc_7F4C
7F43:  1D 22 40          bclr     34, x; #64
7F46:  BD BC 1A          jsr      $bc1a ; $BC1A=sub_BC1A
7F49:  7E 7F FC          jmp      $7ffc ; $7FFC=loc_7FFC

loc_7F4C:
7F4C:  1D 20 40          bclr     32, x; #64 ; xrefs $7F3F:branch
7F4F:  14 AE 08          bset     $ae, #8
7F52:  FC 10 18          ldd      $1018
7F55:  D3 E1             addd     $e1
7F57:  FD 10 18          std      $1018
7F5A:  13 AE 02 0C       brclr    $ae, #2, $7f6a ; $7F6A=loc_7F6A
7F5E:  1C 22 40          bset     34, x; #64
7F61:  96 AD             ldaa     $ad
7F63:  88 06             eora     #6
7F65:  97 AD             staa     $ad
7F67:  15 AE 02          bclr     $ae, #2

loc_7F6A:
7F6A:  FC 10 0E          ldd      $100e ; $100E=TCNT | xrefs $7F5A:branch
7F6D:  93 DF             subd     $df
7F6F:  1A 93 E1          cpd      $e1
7F72:  25 18             bcs      $7f8c ; $7F8C=loc_7F8C
7F74:  1C 0B 40          bset     11, x; #64
7F77:  13 AD 04 11       brclr    $ad, #4, $7f8c ; $7F8C=loc_7F8C
7F7B:  93 E1             subd     $e1
7F7D:  FD 23 62          std      $2362
7F80:  FC 23 5A          ldd      $235a
7F83:  B3 23 62          subd     $2362
7F86:  FD 10 18          std      $1018
7F89:  1C 20 C0          bset     32, x; #-64

loc_7F8C:
7F8C:  7E 7F FC          jmp      $7ffc ; $7FFC=loc_7FFC | xrefs $7F72:branch, $7F77:branch

loc_7F8F:
7F8F:  1E 20 40 2B       brset    32, x; #64; $7fbe ; $7FBE=loc_7FBE | xrefs $7F3B:branch
7F93:  13 A0 80 08       brclr    $a0, #-128, $7f9f ; $7F9F=loc_7F9F
7F97:  1C 50 20          bset     80, x; #32
7F9A:  15 A0 80          bclr     $a0, #-128
7F9D:  20 06             bra      $7fa5 ; $7FA5=loc_7FA5

loc_7F9F:
7F9F:  1D 50 20          bclr     80, x; #32 ; xrefs $7F93:branch
7FA2:  14 A0 80          bset     $a0, #-128

loc_7FA5:
7FA5:  FC 23 5A          ldd      $235a ; xrefs $7F9D:branch
7FA8:  F3 10 18          addd     $1018
7FAB:  FD 10 18          std      $1018
7FAE:  CE 10 00          ldx      #4096
7FB1:  1C 20 C0          bset     32, x; #-64
7FB4:  C6 02             ldab     #2
7FB6:  F7 10 23          stab     $1023 ; $1023=TFLG1
7FB9:  BD BC 1A          jsr      $bc1a ; $BC1A=sub_BC1A
7FBC:  20 3E             bra      $7ffc ; $7FFC=loc_7FFC

loc_7FBE:
7FBE:  FC 10 18          ldd      $1018 ; xrefs $7F8F:branch
7FC1:  DD DF             std      $df
7FC3:  FC 23 58          ldd      $2358
7FC6:  F3 10 18          addd     $1018
7FC9:  FD 10 18          std      $1018
7FCC:  1D 20 40          bclr     32, x; #64
7FCF:  1D 22 40          bclr     34, x; #64
7FD2:  1F 23 02 0D       brclr    35, x; #2; $7fe3 ; $7FE3=loc_7FE3
7FD6:  FC 10 12          ldd      $1012
7FD9:  B3 10 18          subd     $1018
7FDC:  2A 05             bpl      $7fe3 ; $7FE3=loc_7FE3
7FDE:  C6 02             ldab     #2
7FE0:  F7 10 23          stab     $1023 ; $1023=TFLG1

loc_7FE3:
7FE3:  1C 22 02          bset     34, x; #2 ; xrefs $7FD2:branch, $7FDC:branch
7FE6:  13 AE 04 12       brclr    $ae, #4, $7ffc ; $7FFC=loc_7FFC
7FEA:  13 A0 80 08       brclr    $a0, #-128, $7ff6 ; $7FF6=loc_7FF6
7FEE:  BD 7C 57          jsr      $7c57 ; $7C57=sub_7C57
7FF1:  BD 7C 6E          jsr      $7c6e ; $7C6E=sub_7C6E
7FF4:  20 06             bra      $7ffc ; $7FFC=loc_7FFC

loc_7FF6:
7FF6:  BD 7C 8A          jsr      $7c8a ; $7C8A=sub_7C8A | xrefs $7FEA:branch
7FF9:  BD 7C A1          jsr      $7ca1 ; $7CA1=sub_7CA1

loc_7FFC:
7FFC:  3B                rti       ; xrefs $7F49:jump, $7F8C:jump, $7FBC:branch, $7FE6:branch, $7FF4:branch

; ---- unreached/data gap $7FFD-$9314 ----

        .org $9315
9315:  CE 10 00          ldx      #4096
9318:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
931B:  81 06             cmpa     #6
931D:  27 23             beq      $9342 ; $9342=loc_9342
931F:  81 05             cmpa     #5
9321:  26 26             bne      $9349 ; $9349=loc_9349
9323:  A6 22             ldaa     34, x
9325:  84 FD             anda     #-3
9327:  A7 22             staa     34, x
9329:  1D 00 40          bclr     0, x; #64
932C:  FC 10 0E          ldd      $100e ; $100E=TCNT
932F:  93 85             subd     $85
9331:  DD 87             std      $87
9333:  25 03             bcs      $9338 ; $9338=loc_9338
9335:  7E 93 BC          jmp      $93bc ; $93BC=loc_93BC

loc_9338:
9338:  CC 00 00          ldd      #0 ; xrefs $9333:branch
933B:  93 87             subd     $87
933D:  DD 87             std      $87
933F:  7E 93 BC          jmp      $93bc ; $93BC=loc_93BC

loc_9342:
9342:  86 02             ldaa     #2 ; xrefs $931D:branch
9344:  A7 23             staa     35, x
9346:  7E E0 80          jmp      $e080 ; $E080=loc_E080

loc_9349:
9349:  1D 22 02          bclr     34, x; #2 ; xrefs $9321:branch
934C:  FC 10 12          ldd      $1012
934F:  93 DF             subd     $df
9351:  8F                xgdx     
9352:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
9355:  81 05             cmpa     #5
9357:  8F                xgdx     
9358:  26 13             bne      $936d ; $936D=loc_936D
935A:  CE 10 00          ldx      #4096
935D:  36                psha     
935E:  86 02             ldaa     #2
9360:  B7 10 23          staa     $1023 ; $1023=TFLG1
9363:  32                pula     
9364:  1D 20 40          bclr     32, x; #64
9367:  1C 0B 40          bset     11, x; #64
936A:  1C 22 02          bset     34, x; #2

loc_936D:
936D:  CE 10 00          ldx      #4096 ; xrefs $9358:branch
9370:  12 A0 80 22       brset    $a0, #-128, $9396 ; $9396=loc_9396
9374:  14 AC 40          bset     $ac, #64
9377:  15 9B 04          bclr     $9b, #4
937A:  DD E9             std      $e9
937C:  7D 92 76          tst      $9276
937F:  27 3B             beq      $93bc ; $93BC=loc_93BC
9381:  1A B3 92 77       cpd      $9277
9385:  24 35             bcc      $93bc ; $93BC=loc_93BC
9387:  96 CC             ldaa     $cc
9389:  B1 92 79          cmpa     $9279
938C:  24 2E             bcc      $93bc ; $93BC=loc_93BC
938E:  14 9B 04          bset     $9b, #4
9391:  14 30 01          bset     $30, #1
9394:  20 20             bra      $93b6 ; $93B6=loc_93B6

loc_9396:
9396:  14 AC 20          bset     $ac, #32 ; xrefs $9370:branch
9399:  15 9B 40          bclr     $9b, #64
939C:  DD E7             std      $e7
939E:  7D 92 75          tst      $9275
93A1:  27 19             beq      $93bc ; $93BC=loc_93BC
93A3:  1A B3 92 77       cpd      $9277
93A7:  24 13             bcc      $93bc ; $93BC=loc_93BC
93A9:  96 CC             ldaa     $cc
93AB:  B1 92 79          cmpa     $9279
93AE:  24 0C             bcc      $93bc ; $93BC=loc_93BC
93B0:  14 9B 40          bset     $9b, #64
93B3:  14 2D 01          bset     $2d, #1

loc_93B6:
93B6:  1D 20 40          bclr     32, x; #64 ; xrefs $9394:branch
93B9:  1C 0B 40          bset     11, x; #64

loc_93BC:
93BC:  3B                rti       ; xrefs $9335:jump, $933F:jump, $937F:branch, $9385:branch, $938C:branch, $93A1:branch, $93A7:branch, $93AE:branch

; ---- unreached/data gap $93BD-$93BD ----

        .org $93BE

sub_93BE:
93BE:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $776D:call, $7B6C:call
93C1:  81 0C             cmpa     #12
93C3:  26 06             bne      $93cb ; $93CB=loc_93CB
93C5:  BD 96 DA          jsr      $96da ; $96DA=sub_96DA
93C8:  7E 94 33          jmp      $9433 ; $9433=loc_9433

loc_93CB:
93CB:  15 9B 81          bclr     $9b, #-127 ; xrefs $93C3:branch
93CE:  DC E3             ldd      $e3
93D0:  BD 94 AC          jsr      $94ac ; $94AC=sub_94AC
93D3:  FD 23 84          std      $2384
93D6:  13 AC 20 2A       brclr    $ac, #32, $9404 ; $9404=loc_9404
93DA:  15 AC 20          bclr     $ac, #32
93DD:  B6 92 75          ldaa     $9275
93E0:  27 1B             beq      $93fd ; $93FD=loc_93FD
93E2:  12 45 01 17       brset    $45, #1, $93fd ; $93FD=loc_93FD
93E6:  96 CC             ldaa     $cc
93E8:  B1 92 7C          cmpa     $927c
93EB:  25 10             bcs      $93fd ; $93FD=loc_93FD
93ED:  DC E7             ldd      $e7
93EF:  1A B3 92 7A       cpd      $927a
93F3:  25 08             bcs      $93fd ; $93FD=loc_93FD
93F5:  14 9B 80          bset     $9b, #-128
93F8:  14 2D 01          bset     $2d, #1
93FB:  20 28             bra      $9425 ; $9425=loc_9425

loc_93FD:
93FD:  DC E7             ldd      $e7 ; xrefs $93E0:branch, $93E2:branch, $93EB:branch, $93F3:branch
93FF:  BD 94 E2          jsr      $94e2 ; $94E2=sub_94E2
9402:  20 24             bra      $9428 ; $9428=loc_9428

loc_9404:
9404:  B6 92 75          ldaa     $9275 ; xrefs $93D6:branch
9407:  27 1C             beq      $9425 ; $9425=loc_9425
9409:  DC BA             ldd      $ba ; $00BA=engine_period_delta
940B:  1A B3 92 7D       cpd      $927d
940F:  25 14             bcs      $9425 ; $9425=loc_9425
9411:  1A 83 FF FF       cpd      #-1
9415:  27 04             beq      $941b ; $941B=loc_941B
9417:  12 9B 01 0A       brset    $9b, #1, $9425 ; $9425=loc_9425

loc_941B:
941B:  13 9C 02 06       brclr    $9c, #2, $9425 ; $009C=scheduler_status_flags, $9425=loc_9425 | xrefs $9415:branch
941F:  14 9B 20          bset     $9b, #32
9422:  14 2D 01          bset     $2d, #1

loc_9425:
9425:  BD 95 23          jsr      $9523 ; $9523=sub_9523 | xrefs $93FB:branch, $9407:branch, $940F:branch, $9417:branch, $941B:branch

loc_9428:
9428:  1A B3 23 84       cpd      $2384 ; xrefs $9402:branch
942C:  25 03             bcs      $9431 ; $9431=loc_9431
942E:  FC 23 84          ldd      $2384

loc_9431:
9431:  DD E3             std      $e3 ; xrefs $942C:branch

loc_9433:
9433:  39                rts       ; xrefs $93C8:jump

; ---- unreached/data gap $9434-$9434 ----

        .org $9435

sub_9435:
9435:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $7784:call, $7B83:call
9438:  81 0C             cmpa     #12
943A:  26 06             bne      $9442 ; $9442=loc_9442
943C:  BD 96 DA          jsr      $96da ; $96DA=sub_96DA
943F:  7E 94 AA          jmp      $94aa ; $94AA=loc_94AA

loc_9442:
9442:  15 9B 09          bclr     $9b, #9 ; xrefs $943A:branch
9445:  DC E5             ldd      $e5
9447:  BD 94 AC          jsr      $94ac ; $94AC=sub_94AC
944A:  FD 23 84          std      $2384
944D:  13 AC 40 2A       brclr    $ac, #64, $947b ; $947B=loc_947B
9451:  15 AC 40          bclr     $ac, #64
9454:  B6 92 76          ldaa     $9276
9457:  27 1B             beq      $9474 ; $9474=loc_9474
9459:  12 45 01 17       brset    $45, #1, $9474 ; $9474=loc_9474
945D:  96 CC             ldaa     $cc
945F:  B1 92 7C          cmpa     $927c
9462:  25 10             bcs      $9474 ; $9474=loc_9474
9464:  DC E9             ldd      $e9
9466:  1A B3 92 7A       cpd      $927a
946A:  25 08             bcs      $9474 ; $9474=loc_9474
946C:  14 9B 08          bset     $9b, #8
946F:  14 30 01          bset     $30, #1
9472:  20 28             bra      $949c ; $949C=loc_949C

loc_9474:
9474:  DC E9             ldd      $e9 ; xrefs $9457:branch, $9459:branch, $9462:branch, $946A:branch
9476:  BD 94 E2          jsr      $94e2 ; $94E2=sub_94E2
9479:  20 24             bra      $949f ; $949F=loc_949F

loc_947B:
947B:  B6 92 76          ldaa     $9276 ; xrefs $944D:branch
947E:  27 1C             beq      $949c ; $949C=loc_949C
9480:  DC BA             ldd      $ba ; $00BA=engine_period_delta
9482:  1A B3 92 7D       cpd      $927d
9486:  25 14             bcs      $949c ; $949C=loc_949C
9488:  1A 83 FF FF       cpd      #-1
948C:  27 04             beq      $9492 ; $9492=loc_9492
948E:  12 9B 01 0A       brset    $9b, #1, $949c ; $949C=loc_949C

loc_9492:
9492:  13 9C 02 06       brclr    $9c, #2, $949c ; $009C=scheduler_status_flags, $949C=loc_949C | xrefs $948C:branch
9496:  14 9B 02          bset     $9b, #2
9499:  14 30 01          bset     $30, #1

loc_949C:
949C:  BD 95 23          jsr      $9523 ; $9523=sub_9523 | xrefs $9472:branch, $947E:branch, $9486:branch, $948E:branch, $9492:branch

loc_949F:
949F:  1A B3 23 84       cpd      $2384 ; xrefs $9479:branch
94A3:  25 03             bcs      $94a8 ; $94A8=loc_94A8
94A5:  FC 23 84          ldd      $2384

loc_94A8:
94A8:  DD E5             std      $e5 ; xrefs $94A3:branch

loc_94AA:
94AA:  39                rts       ; xrefs $943F:jump

; ---- unreached/data gap $94AB-$94AB ----

        .org $94AC

sub_94AC:
94AC:  FD 23 4F          std      $234f ; xrefs $93D0:call, $9447:call
94AF:  DC BA             ldd      $ba ; $00BA=engine_period_delta
94B1:  1A 83 FF FF       cpd      #-1
94B5:  26 14             bne      $94cb ; $94CB=loc_94CB
94B7:  14 9B 01          bset     $9b, #1
94BA:  DC ED             ldd      $ed
94BC:  05                asld     
94BD:  25 09             bcs      $94c8 ; $94C8=loc_94C8
94BF:  05                asld     
94C0:  25 06             bcs      $94c8 ; $94C8=loc_94C8
94C2:  05                asld     
94C3:  25 03             bcs      $94c8 ; $94C8=loc_94C8
94C5:  05                asld     
94C6:  24 03             bcc      $94cb ; $94CB=loc_94CB

loc_94C8:
94C8:  CC FF FF          ldd      #-1 ; xrefs $94BD:branch, $94C0:branch, $94C3:branch

loc_94CB:
94CB:  B3 93 10          subd     $9310 ; xrefs $94B5:branch, $94C6:branch
94CE:  1A B3 23 4F       cpd      $234f
94D2:  22 03             bhi      $94d7 ; $94D7=loc_94D7
94D4:  14 9B 01          bset     $9b, #1

loc_94D7:
94D7:  1A B3 93 0E       cpd      $930e ; xrefs $94D2:branch
94DB:  25 03             bcs      $94e0 ; $94E0=loc_94E0
94DD:  FC 93 0E          ldd      $930e

loc_94E0:
94E0:  39                rts       ; xrefs $94DB:branch

; ---- unreached/data gap $94E1-$94E1 ----

        .org $94E2

sub_94E2:
94E2:  05                asld      ; xrefs $93FF:call, $9476:call, $E0BA:call
94E3:  37                pshb     
94E4:  F6 26 09          ldab     $2609
94E7:  3D                mul      
94E8:  8F                xgdx     
94E9:  33                pulb     
94EA:  B6 26 09          ldaa     $2609
94ED:  3D                mul      
94EE:  89 00             adca     #0
94F0:  16                tab      
94F1:  3A                abx      
94F2:  8F                xgdx     
94F3:  FD 23 51          std      $2351
94F6:  05                asld     
94F7:  37                pshb     
94F8:  F6 20 48          ldab     $2048
94FB:  2A 01             bpl      $94fe ; $94FE=loc_94FE
94FD:  50                negb     

loc_94FE:
94FE:  3D                mul       ; xrefs $94FB:branch
94FF:  8F                xgdx     
9500:  33                pulb     
9501:  B6 20 48          ldaa     $2048
9504:  2A 01             bpl      $9507 ; $9507=loc_9507
9506:  40                nega     

loc_9507:
9507:  3D                mul       ; xrefs $9504:branch
9508:  89 00             adca     #0
950A:  16                tab      
950B:  3A                abx      
950C:  8F                xgdx     
950D:  7D 20 48          tst      $2048
9510:  2A 0C             bpl      $951e ; $951E=loc_951E
9512:  FE 23 51          ldx      $2351
9515:  FD 23 51          std      $2351
9518:  8F                xgdx     
9519:  B3 23 51          subd     $2351
951C:  20 03             bra      $9521 ; $9521=loc_9521

loc_951E:
951E:  F3 23 51          addd     $2351 ; xrefs $9510:branch

loc_9521:
9521:  39                rts       ; xrefs $951C:branch

; ---- unreached/data gap $9522-$9522 ----

        .org $9523

sub_9523:
9523:  18 3C             pshy      ; xrefs $9425:call, $949C:call, $95B1:call
9525:  FC 20 40          ldd      $2040 ; $2040=scheduler_axis_index
9528:  18 CE 92 FA       ldy      #-27910
952C:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
952F:  C6 28             ldab     #40
9531:  3D                mul      
9532:  18 38             puly     
9534:  39                rts      

; ---- unreached/data gap $9535-$9535 ----

        .org $9536

sub_9536:
9536:  18 3C             pshy      ; xrefs $7948:call, $799B:call
9538:  3C                pshx     
9539:  C6 03             ldab     #3
953B:  37                pshb     
953C:  18 30             tsy      
953E:  12 AD 20 20       brset    $ad, #32, $9562 ; $9562=loc_9562
9542:  CC 00 00          ldd      #0
9545:  18 ED 01          std      1, y
9548:  8F                xgdx     
9549:  37                pshb     
954A:  F6 23 87          ldab     $2387
954D:  3D                mul      
954E:  4D                tsta     
954F:  32                pula     
9550:  27 05             beq      $9557 ; $9557=loc_9557
9552:  CE FF FF          ldx      #-1
9555:  20 0B             bra      $9562 ; $9562=loc_9562

loc_9557:
9557:  18 E7 01          stab     1, y ; xrefs $9550:branch
955A:  F6 23 87          ldab     $2387
955D:  3D                mul      
955E:  18 E3 01          addd     1, y
9561:  8F                xgdx     

loc_9562:
9562:  33                pulb      ; xrefs $953E:branch, $9555:branch
9563:  18 3A             aby      
9565:  18 35             tys      
9567:  18 38             puly     
9569:  39                rts      

; ---- unreached/data gap $956A-$956A ----

        .org $956B

; [CONFIRMED] Initialize period/timer history, including 0x00BA = 0xFFFF.
period_history_init:
956B:  CC FF FF          ldd      #-1 ; xrefs $B4A1:call, $B904:call
956E:  DD BA             std      $ba ; $00BA=engine_period_delta
9570:  FD 24 DB          std      $24db
9573:  FD 24 DD          std      $24dd
9576:  FD 24 DF          std      $24df
9579:  DD ED             std      $ed
957B:  FD 20 8C          std      $208c
957E:  B7 23 01          staa     $2301
9581:  97 DD             staa     $dd
9583:  97 DE             staa     $de
9585:  86 01             ldaa     #1
9587:  B7 23 12          staa     $2312
958A:  B7 23 1E          staa     $231e
958D:  B7 23 2A          staa     $232a
9590:  B7 23 36          staa     $2336
9593:  CC 00 00          ldd      #0
9596:  DD EF             std      $ef
9598:  97 A9             staa     $a9 ; $00A9=operating_mode_flags
959A:  97 AC             staa     $ac
959C:  97 AD             staa     $ad
959E:  14 AD 01          bset     $ad, #1
95A1:  97 AE             staa     $ae
95A3:  97 9D             staa     $9d
95A5:  97 9E             staa     $9e
95A7:  97 A0             staa     $a0
95A9:  97 B4             staa     $b4
95AB:  97 DB             staa     $db
95AD:  97 DC             staa     $dc
95AF:  97 B7             staa     $b7
95B1:  BD 95 23          jsr      $9523 ; $9523=sub_9523
95B4:  DD E3             std      $e3
95B6:  DD E5             std      $e5
95B8:  FD 23 88          std      $2388 ; $2388=scheduler_scaled_output
95BB:  86 04             ldaa     #4
95BD:  B7 23 86          staa     $2386
95C0:  B7 23 87          staa     $2387
95C3:  CE 10 00          ldx      #4096
95C6:  1C 21 06          bset     33, x; #6
95C9:  1D 21 09          bclr     33, x; #9
95CC:  86 40             ldaa     #64
95CE:  B7 10 26          staa     $1026
95D1:  86 04             ldaa     #4
95D3:  B7 23 86          staa     $2386
95D6:  B7 20 E9          staa     $20e9
95D9:  B7 23 87          staa     $2387
95DC:  B6 8C 79          ldaa     $8c79
95DF:  B7 20 E3          staa     $20e3
95E2:  B7 20 E4          staa     $20e4
95E5:  B7 20 E5          staa     $20e5
95E8:  B7 20 E2          staa     $20e2
95EB:  CE 20 E3          ldx      #8419
95EE:  FF 23 10          stx      $2310
95F1:  39                rts      

; ---- unreached/data gap $95F2-$95F2 ----

        .org $95F3

; [CONFIRMED] Vector target; exact source depends on MCU mask.
interrupt_handler_95f3:
95F3:  86 40             ldaa     #64
95F5:  B7 10 25          staa     $1025 ; $1025=TFLG2
95F8:  F6 21 A6          ldab     $21a6 ; $21A6=operating_state_selector
95FB:  C1 FF             cmpb     #-1
95FD:  27 23             beq      $9622 ; $9622=loc_9622
95FF:  C1 05             cmpb     #5
9601:  27 19             beq      $961c ; $961C=loc_961C
9603:  C1 08             cmpb     #8
9605:  26 03             bne      $960a ; $960A=loc_960A
9607:  7E 6C FB          jmp      $6cfb ; $6CFB=loc_6CFB

loc_960A:
960A:  C1 0D             cmpb     #13 ; xrefs $9605:branch
960C:  26 0A             bne      $9618 ; $9618=loc_9618
960E:  B6 21 C0          ldaa     $21c0
9611:  81 BB             cmpa     #-69
9613:  26 03             bne      $9618 ; $9618=loc_9618
9615:  7E 6D 01          jmp      $6d01 ; $6D01=loc_6D01

loc_9618:
9618:  C1 06             cmpb     #6 ; xrefs $960C:branch, $9613:branch
961A:  26 06             bne      $9622 ; $9622=loc_9622

loc_961C:
961C:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E | xrefs $9601:branch
961F:  7E 96 CF          jmp      $96cf ; $96CF=loc_96CF

loc_9622:
9622:  B6 00 D3          ldaa     >$00d3 ; xrefs $95FD:branch, $961A:branch
9625:  81 DA             cmpa     #-38
9627:  25 0D             bcs      $9636 ; $9636=loc_9636
9629:  13 A1 02 06       brclr    $a1, #2, $9633 ; $9633=loc_9633
962D:  15 A1 02          bclr     $a1, #2
9630:  7E 96 CF          jmp      $96cf ; $96CF=loc_96CF

loc_9633:
9633:  14 A1 02          bset     $a1, #2 ; xrefs $9629:branch

loc_9636:
9636:  13 A1 01 06       brclr    $a1, #1, $9640 ; $9640=loc_9640 | xrefs $9627:branch
963A:  7C 20 8E          inc      $208e
963D:  7E 96 CF          jmp      $96cf ; $96CF=loc_96CF

loc_9640:
9640:  14 A1 01          bset     $a1, #1 ; xrefs $9636:branch
9643:  B6 24 60          ldaa     $2460
9646:  27 03             beq      $964b ; $964B=loc_964B
9648:  7A 24 60          dec      $2460

loc_964B:
964B:  7A 24 66          dec      $2466 ; xrefs $9646:branch
964E:  27 03             beq      $9653 ; $9653=loc_9653
9650:  0E                cli      
9651:  20 0A             bra      $965d ; $965D=loc_965D

loc_9653:
9653:  B6 20 8F          ldaa     $208f ; xrefs $964E:branch
9656:  B7 24 66          staa     $2466
9659:  0E                cli      
965A:  BD C9 C8          jsr      $c9c8 ; $C9C8=sub_C9C8

loc_965D:
965D:  BD C9 7C          jsr      $c97c ; $C97C=sub_C97C | xrefs $9651:branch
9660:  BD 40 E5          jsr      $40e5 ; $40E5=sub_40E5
9663:  BD 9E 87          jsr      $9e87 ; $9E87=sub_9E87
9666:  BD 5E 82          jsr      $5e82 ; $5E82=adc_conversion_helper_5e82
9669:  BD 41 D6          jsr      $41d6 ; $41D6=build_transient_axis_2042
966C:  BD 97 89          jsr      $9789 ; $9789=sub_9789
966F:  BD 41 6B          jsr      $416b ; $416B=sub_416B
9672:  BD 9B FE          jsr      $9bfe ; $9BFE=sub_9BFE
9675:  BD 97 C5          jsr      $97c5 ; $97C5=sub_97C5
9678:  BD 71 01          jsr      $7101 ; $7101=sub_7101
967B:  BD 44 05          jsr      $4405 ; $4405=sub_4405
967E:  BD CB A9          jsr      $cba9 ; $CBA9=sub_CBA9
9681:  BD BD F6          jsr      $bdf6 ; $BDF6=sub_BDF6
9684:  BD A0 02          jsr      $a002 ; $A002=sub_A002
9687:  13 9E 80 05       brclr    $9e, #-128, $9690 ; $9690=loc_9690
968B:  BD BD EC          jsr      $bdec ; $BDEC=sub_BDEC
968E:  20 26             bra      $96b6 ; $96B6=loc_96B6

loc_9690:
9690:  12 AF 80 22       brset    $af, #-128, $96b6 ; $96B6=loc_96B6 | xrefs $9687:branch
9694:  13 A9 02 17       brclr    $a9, #2, $96af ; $00A9=operating_mode_flags, $96AF=loc_96AF
9698:  15 AF 01          bclr     $af, #1
969B:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
969E:  81 07             cmpa     #7
96A0:  26 14             bne      $96b6 ; $96B6=loc_96B6
96A2:  86 FF             ldaa     #-1
96A4:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
96A7:  15 B0 80          bclr     $b0, #-128
96AA:  14 AF 08          bset     $af, #8
96AD:  20 07             bra      $96b6 ; $96B6=loc_96B6

loc_96AF:
96AF:  13 AF 0A 03       brclr    $af, #10, $96b6 ; $96B6=loc_96B6 | xrefs $9694:branch
96B3:  BD 65 4C          jsr      $654c ; $654C=sub_654C

loc_96B6:
96B6:  BD 56 2A          jsr      $562a ; $562A=sub_562A | xrefs $968E:branch, $9690:branch, $96A0:branch, $96AD:branch, $96AF:branch
96B9:  BD 47 72          jsr      $4772 ; $4772=sub_4772
96BC:  BD BD 6E          jsr      $bd6e ; $BD6E=sub_BD6E
96BF:  13 8D 02 03       brclr    $8d, #2, $96c6 ; $96C6=loc_96C6
96C3:  BD 4D 21          jsr      $4d21 ; $4D21=sub_4D21

loc_96C6:
96C6:  BD 58 B7          jsr      $58b7 ; $58B7=sub_58B7 | xrefs $96BF:branch
96C9:  BD 9E C5          jsr      $9ec5 ; $9EC5=sub_9EC5
96CC:  15 A1 01          bclr     $a1, #1

loc_96CF:
96CF:  3B                rti       ; xrefs $961F:jump, $9630:jump, $963D:jump

; ---- unreached/data gap $96D0-$96D2 ----

        .org $96D3

sub_96D3:
96D3:  B6 20 07          ldaa     $2007 ; $2007=adc_processed_input_2007 | xrefs $4468:call
96D6:  44                lsra     
96D7:  97 B6             staa     $b6
96D9:  39                rts      

sub_96DA:
96DA:  B6 20 0E          ldaa     $200e ; $200E=adc_raw_input_200e | xrefs $93C5:call, $943C:call, $D5DA:call
96DD:  F6 96 D0          ldab     $96d0
96E0:  3D                mul      
96E1:  DD E3             std      $e3
96E3:  DD E5             std      $e5
96E5:  FD 23 88          std      $2388 ; $2388=scheduler_scaled_output
96E8:  39                rts      

sub_96E9:
96E9:  B6 20 08          ldaa     $2008 ; $2008=adc_raw_input_2008 | xrefs $C012:call
96EC:  B7 20 A4          staa     $20a4
96EF:  7F 24 4F          clr      $244f
96F2:  39                rts      

sub_96F3:
96F3:  B6 20 0A          ldaa     $200a ; $200A=adc_raw_input_200a | xrefs $E6CB:call
96F6:  F6 96 D0          ldab     $96d0
96F9:  3D                mul      
96FA:  39                rts      

; ---- unreached/data gap $96FB-$9706 ----

        .org $9707

sub_9707:
9707:  CE 10 00          ldx      #4096 ; xrefs $BDFD:call
970A:  86 01             ldaa     #1
970C:  1F 60 10 04       brclr    96, x; #16; $9714 ; $9714=loc_9714
9710:  B6 88 8D          ldaa     $888d
9713:  4A                deca     

loc_9714:
9714:  B7 20 2B          staa     $202b ; xrefs $970C:branch
9717:  13 9D 40 08       brclr    $9d, #64, $9723 ; $9723=loc_9723
971B:  15 9D 40          bclr     $9d, #64
971E:  86 01             ldaa     #1
9720:  B7 21 DF          staa     $21df

loc_9723:
9723:  7A 21 DF          dec      $21df ; xrefs $9717:branch
9726:  26 0C             bne      $9734 ; $9734=loc_9734
9728:  B6 20 2B          ldaa     $202b
972B:  B7 21 E0          staa     $21e0
972E:  B6 88 8D          ldaa     $888d
9731:  B7 21 DF          staa     $21df

loc_9734:
9734:  B6 21 E0          ldaa     $21e0 ; xrefs $9726:branch
9737:  2F 08             ble      $9741 ; $9741=loc_9741
9739:  7A 21 E0          dec      $21e0
973C:  1C 50 04          bset     80, x; #4
973F:  20 05             bra      $9746 ; $9746=loc_9746

loc_9741:
9741:  1D 50 04          bclr     80, x; #4 ; xrefs $9737:branch
9744:  20 00             bra      $9746 ; $9746=loc_9746

loc_9746:
9746:  39                rts       ; xrefs $973F:branch, $9744:branch

sub_9747:
9747:  CE 10 00          ldx      #4096 ; xrefs $5680:call
974A:  0F                sei      
974B:  1E 60 02 05       brset    96, x; #2; $9754 ; $9754=loc_9754
974F:  1C 40 02          bset     64, x; #2
9752:  20 03             bra      $9757 ; $9757=loc_9757

loc_9754:
9754:  1D 40 02          bclr     64, x; #2 ; xrefs $974B:branch

loc_9757:
9757:  0E                cli       ; xrefs $9752:branch
9758:  39                rts      

sub_9759:
9759:  CE 10 00          ldx      #4096 ; xrefs $CAC0:call
975C:  B6 20 A4          ldaa     $20a4
975F:  B0 00 5D          suba     >$005d
9762:  2A 01             bpl      $9765 ; $9765=loc_9765
9764:  40                nega     

loc_9765:
9765:  B1 96 D2          cmpa     $96d2 ; xrefs $9762:branch
9768:  22 12             bhi      $977c ; $977C=loc_977C
976A:  7D 21 E1          tst      $21e1
976D:  27 05             beq      $9774 ; $9774=loc_9774
976F:  7A 21 E1          dec      $21e1
9772:  20 14             bra      $9788 ; $9788=loc_9788

loc_9774:
9774:  1D 50 10          bclr     80, x; #16 ; xrefs $976D:branch
9777:  14 A6 20          bset     $a6, #32
977A:  20 0C             bra      $9788 ; $9788=loc_9788

loc_977C:
977C:  B6 96 D1          ldaa     $96d1 ; xrefs $9768:branch
977F:  B7 21 E1          staa     $21e1
9782:  1C 50 10          bset     80, x; #16
9785:  15 A6 20          bclr     $a6, #32

loc_9788:
9788:  39                rts       ; xrefs $9772:branch, $977A:branch

sub_9789:
9789:  96 10             ldaa     $10 ; xrefs $966C:call
978B:  B0 89 8E          suba     $898e
978E:  91 C9             cmpa     $c9
9790:  22 0A             bhi      $979c ; $979C=loc_979C
9792:  B1 20 13          cmpa     $2013 ; $2013=processed_sensor_2013
9795:  22 05             bhi      $979c ; $979C=loc_979C
9797:  14 A9 80          bset     $a9, #-128 ; $00A9=operating_mode_flags
979A:  20 27             bra      $97c3 ; $97C3=loc_97C3

loc_979C:
979C:  B0 89 8F          suba     $898f ; xrefs $9790:branch, $9795:branch
979F:  91 C9             cmpa     $c9
97A1:  23 20             bls      $97c3 ; $97C3=loc_97C3
97A3:  15 A9 80          bclr     $a9, #-128 ; $00A9=operating_mode_flags
97A6:  96 11             ldaa     $11
97A8:  BB 89 8C          adda     $898c
97AB:  91 C9             cmpa     $c9
97AD:  25 0A             bcs      $97b9 ; $97B9=loc_97B9
97AF:  B1 20 13          cmpa     $2013 ; $2013=processed_sensor_2013
97B2:  25 05             bcs      $97b9 ; $97B9=loc_97B9
97B4:  14 A9 40          bset     $a9, #64 ; $00A9=operating_mode_flags
97B7:  20 0A             bra      $97c3 ; $97C3=loc_97C3

loc_97B9:
97B9:  BB 89 8D          adda     $898d ; xrefs $97AD:branch, $97B2:branch
97BC:  91 C9             cmpa     $c9
97BE:  22 03             bhi      $97c3 ; $97C3=loc_97C3
97C0:  15 A9 40          bclr     $a9, #64 ; $00A9=operating_mode_flags

loc_97C3:
97C3:  39                rts       ; xrefs $979A:branch, $97A1:branch, $97B7:branch, $97BE:branch

; ---- unreached/data gap $97C4-$97C4 ----

        .org $97C5

sub_97C5:
97C5:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $9675:call
97C8:  81 0C             cmpa     #12
97CA:  26 07             bne      $97d3 ; $97D3=loc_97D3
97CC:  86 80             ldaa     #-128
97CE:  97 A3             staa     $a3
97D0:  7E 9A 14          jmp      $9a14 ; $9A14=loc_9A14

loc_97D3:
97D3:  96 D3             ldaa     $d3 ; xrefs $97CA:branch
97D5:  B1 86 7D          cmpa     $867d
97D8:  22 19             bhi      $97f3 ; $97F3=loc_97F3
97DA:  FC 20 42          ldd      $2042 ; $2042=transient_helper_axis
97DD:  18 CE 86 71       ldy      #-31119
97E1:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
97E4:  B7 21 10          staa     $2110
97E7:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
97E9:  1A B3 20 20       cpd      $2020
97ED:  25 04             bcs      $97f3 ; $97F3=loc_97F3
97EF:  12 A3 80 05       brset    $a3, #-128, $97f8 ; $97F8=loc_97F8

loc_97F3:
97F3:  5F                clrb      ; xrefs $97D8:branch, $97ED:branch
97F4:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
97F6:  20 10             bra      $9808 ; $9808=loc_9808

loc_97F8:
97F8:  CE 23 8A          ldx      #9098 ; xrefs $97EF:branch
97FB:  FC 20 1C          ldd      $201c
97FE:  ED 00             std      0, x
9800:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
9802:  F6 86 7C          ldab     $867c
9805:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6

loc_9808:
9808:  FD 20 1C          std      $201c ; xrefs $97F6:branch
980B:  04                lsrd     
980C:  04                lsrd     
980D:  04                lsrd     
980E:  04                lsrd     
980F:  04                lsrd     
9810:  04                lsrd     
9811:  FD 20 1A          std      $201a
9814:  13 A3 40 11       brclr    $a3, #64, $9829 ; $9829=loc_9829
9818:  B6 20 59          ldaa     $2059
981B:  81 01             cmpa     #1
981D:  26 06             bne      $9825 ; $9825=loc_9825
981F:  7F 00 AB          clr      >$00ab
9822:  7E 99 E9          jmp      $99e9 ; $99E9=loc_99E9

loc_9825:
9825:  86 80             ldaa     #-128 ; xrefs $981D:branch
9827:  97 A3             staa     $a3

loc_9829:
9829:  13 A3 01 0B       brclr    $a3, #1, $9838 ; $9838=loc_9838 | xrefs $9814:branch
982D:  13 A9 40 07       brclr    $a9, #64, $9838 ; $00A9=operating_mode_flags, $9838=loc_9838
9831:  7F 00 AB          clr      >$00ab
9834:  86 80             ldaa     #-128
9836:  97 A3             staa     $a3

loc_9838:
9838:  12 A3 10 41       brset    $a3, #16, $987d ; $987D=loc_987D | xrefs $9829:branch, $982D:branch
983C:  13 A9 40 72       brclr    $a9, #64, $98b2 ; $00A9=operating_mode_flags, $98B2=loc_98B2
9840:  13 A3 80 6E       brclr    $a3, #-128, $98b2 ; $98B2=loc_98B2
9844:  96 D1             ldaa     $d1
9846:  81 FF             cmpa     #-1
9848:  27 68             beq      $98b2 ; $98B2=loc_98B2
984A:  F6 20 A8          ldab     $20a8
984D:  FB 86 87          addb     $8687
9850:  25 03             bcs      $9855 ; $9855=loc_9855
9852:  11                cba      
9853:  24 5D             bcc      $98b2 ; $98B2=loc_98B2

loc_9855:
9855:  13 D8 10 15       brclr    $d8, #16, $986e ; $986E=loc_986E | xrefs $9850:branch
9859:  B6 20 AA          ldaa     $20aa
985C:  27 10             beq      $986e ; $986E=loc_986E
985E:  96 90             ldaa     $90
9860:  26 07             bne      $9869 ; $9869=loc_9869
9862:  B6 20 AB          ldaa     $20ab
9865:  27 07             beq      $986e ; $986E=loc_986E
9867:  20 49             bra      $98b2 ; $98B2=loc_98B2

loc_9869:
9869:  B6 20 2D          ldaa     $202d ; xrefs $9860:branch
986C:  27 44             beq      $98b2 ; $98B2=loc_98B2

loc_986E:
986E:  86 10             ldaa     #16 ; xrefs $9855:branch, $985C:branch, $9865:branch
9870:  97 A3             staa     $a3
9872:  DC BA             ldd      $ba ; $00BA=engine_period_delta
9874:  FD 20 2E          std      $202e
9877:  7F 00 AB          clr      >$00ab
987A:  7E 99 E9          jmp      $99e9 ; $99E9=loc_99E9

loc_987D:
987D:  13 A9 40 2A       brclr    $a9, #64, $98ab ; $00A9=operating_mode_flags, $98AB=loc_98AB | xrefs $9838:branch
9881:  96 D1             ldaa     $d1
9883:  81 FF             cmpa     #-1
9885:  27 24             beq      $98ab ; $98AB=loc_98AB
9887:  F6 20 A8          ldab     $20a8
988A:  FB 86 88          addb     $8688
988D:  25 03             bcs      $9892 ; $9892=loc_9892
988F:  11                cba      
9890:  24 19             bcc      $98ab ; $98AB=loc_98AB

loc_9892:
9892:  13 D8 10 1C       brclr    $d8, #16, $98b2 ; $98B2=loc_98B2 | xrefs $988D:branch
9896:  B6 20 AA          ldaa     $20aa
9899:  27 17             beq      $98b2 ; $98B2=loc_98B2
989B:  96 90             ldaa     $90
989D:  26 07             bne      $98a6 ; $98A6=loc_98A6
989F:  B6 20 AB          ldaa     $20ab
98A2:  26 07             bne      $98ab ; $98AB=loc_98AB
98A4:  20 0C             bra      $98b2 ; $98B2=loc_98B2

loc_98A6:
98A6:  B6 20 2D          ldaa     $202d ; xrefs $989D:branch
98A9:  26 07             bne      $98b2 ; $98B2=loc_98B2

loc_98AB:
98AB:  86 80             ldaa     #-128 ; xrefs $987D:branch, $9885:branch, $9890:branch, $98A2:branch
98AD:  97 A3             staa     $a3
98AF:  7F 00 AB          clr      >$00ab

loc_98B2:
98B2:  13 A3 04 1D       brclr    $a3, #4, $98d3 ; $98D3=loc_98D3 | xrefs $983C:branch, $9840:branch, $9848:branch, $9853:branch, $9867:branch, $986C:branch, $9892:branch, $9899:branch, +2 more
98B6:  12 A9 40 19       brset    $a9, #64, $98d3 ; $00A9=operating_mode_flags, $98D3=loc_98D3
98BA:  FE 87 73          ldx      $8773
98BD:  F6 87 75          ldab     $8775
98C0:  3A                abx      
98C1:  9C CE             cpx      $ce ; $00CE=load_aircharge_word
98C3:  25 07             bcs      $98cc ; $98CC=loc_98CC
98C5:  96 D3             ldaa     $d3
98C7:  B1 23 93          cmpa     $2393
98CA:  24 07             bcc      $98d3 ; $98D3=loc_98D3

loc_98CC:
98CC:  86 80             ldaa     #-128 ; xrefs $98C3:branch
98CE:  97 A3             staa     $a3
98D0:  7F 00 AB          clr      >$00ab

loc_98D3:
98D3:  5F                clrb      ; xrefs $98B2:branch, $98B6:branch, $98CA:branch
98D4:  96 C9             ldaa     $c9
98D6:  B0 20 13          suba     $2013 ; $2013=processed_sensor_2013
98D9:  23 09             bls      $98e4 ; $98E4=loc_98E4
98DB:  F6 20 F1          ldab     $20f1
98DE:  3D                mul      
98DF:  4D                tsta     
98E0:  27 02             beq      $98e4 ; $98E4=loc_98E4
98E2:  C6 FF             ldab     #-1

loc_98E4:
98E4:  F7 20 F3          stab     $20f3 ; xrefs $98D9:branch, $98E0:branch
98E7:  13 A3 01 03       brclr    $a3, #1, $98ee ; $98EE=loc_98EE
98EB:  7E 99 71          jmp      $9971 ; $9971=loc_9971

loc_98EE:
98EE:  86 80             ldaa     #-128 ; xrefs $98E7:branch
98F0:  7D 86 6E          tst      $866e
98F3:  27 14             beq      $9909 ; $9909=loc_9909
98F5:  12 AB 20 78       brset    $ab, #32, $9971 ; $9971=loc_9971
98F9:  13 AB 10 0A       brclr    $ab, #16, $9907 ; $9907=loc_9907
98FD:  D6 C9             ldab     $c9
98FF:  F1 20 13          cmpb     $2013 ; $2013=processed_sensor_2013
9902:  24 3D             bcc      $9941 ; $9941=loc_9941
9904:  15 AB 10          bclr     $ab, #16

loc_9907:
9907:  86 10             ldaa     #16 ; xrefs $98F9:branch

loc_9909:
9909:  D6 D3             ldab     $d3 ; xrefs $98F3:branch
990B:  F1 86 7D          cmpb     $867d
990E:  22 61             bhi      $9971 ; $9971=loc_9971
9910:  F6 20 17          ldab     $2017
9913:  F1 89 8C          cmpb     $898c
9916:  23 59             bls      $9971 ; $9971=loc_9971
9918:  F6 20 F3          ldab     $20f3
991B:  F1 21 10          cmpb     $2110
991E:  23 08             bls      $9928 ; $9928=loc_9928
9920:  81 10             cmpa     #16
9922:  26 1D             bne      $9941 ; $9941=loc_9941
9924:  97 AB             staa     $ab
9926:  20 49             bra      $9971 ; $9971=loc_9971

loc_9928:
9928:  13 A3 80 45       brclr    $a3, #-128, $9971 ; $9971=loc_9971 | xrefs $991E:branch
992C:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
992E:  1A 83 03 FF       cpd      #1023
9932:  22 3D             bhi      $9971 ; $9971=loc_9971
9934:  B3 20 1A          subd     $201a
9937:  25 38             bcs      $9971 ; $9971=loc_9971
9939:  1A B3 86 7A       cpd      $867a
993D:  25 32             bcs      $9971 ; $9971=loc_9971
993F:  86 40             ldaa     #64

loc_9941:
9941:  97 AB             staa     $ab ; xrefs $9902:branch, $9922:branch
9943:  15 A9 40          bclr     $a9, #64 ; $00A9=operating_mode_flags
9946:  B6 86 6F          ldaa     $866f
9949:  B7 20 64          staa     $2064
994C:  BD E9 72          jsr      $e972 ; $E972=sub_E972
994F:  86 01             ldaa     #1
9951:  97 A3             staa     $a3
9953:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
9955:  B7 20 1E          staa     $201e
9958:  96 CA             ldaa     $ca
995A:  B1 8E 17          cmpa     $8e17
995D:  23 0D             bls      $996c ; $996C=loc_996C
995F:  B6 20 17          ldaa     $2017
9962:  B1 8E 16          cmpa     $8e16
9965:  22 05             bhi      $996c ; $996C=loc_996C
9967:  14 A9 10          bset     $a9, #16 ; $00A9=operating_mode_flags
996A:  20 03             bra      $996f ; $996F=loc_996F

loc_996C:
996C:  15 A9 10          bclr     $a9, #16 ; $00A9=operating_mode_flags | xrefs $995D:branch, $9965:branch

loc_996F:
996F:  20 78             bra      $99e9 ; $99E9=loc_99E9 | xrefs $996A:branch

loc_9971:
9971:  86 80             ldaa     #-128 ; xrefs $98EB:jump, $98F5:branch, $990E:branch, $9916:branch, $9926:branch, $9928:branch, $9932:branch, $9937:branch, +1 more
9973:  7D 86 6E          tst      $866e
9976:  27 10             beq      $9988 ; $9988=loc_9988
9978:  13 AB 20 0A       brclr    $ab, #32, $9986 ; $9986=loc_9986
997C:  D6 C9             ldab     $c9
997E:  F1 20 13          cmpb     $2013 ; $2013=processed_sensor_2013
9981:  23 43             bls      $99c6 ; $99C6=loc_99C6
9983:  15 AB 20          bclr     $ab, #32

loc_9986:
9986:  86 20             ldaa     #32 ; xrefs $9978:branch

loc_9988:
9988:  D6 D1             ldab     $d1 ; xrefs $9976:branch
998A:  C1 FF             cmpb     #-1
998C:  27 0C             beq      $999a ; $999A=loc_999A
998E:  F6 20 A8          ldab     $20a8
9991:  FB 86 82          addb     $8682
9994:  25 53             bcs      $99e9 ; $99E9=loc_99E9
9996:  D1 D1             cmpb     $d1
9998:  22 4F             bhi      $99e9 ; $99E9=loc_99E9

loc_999A:
999A:  F6 20 59          ldab     $2059 ; xrefs $998C:branch
999D:  C1 02             cmpb     #2
999F:  23 48             bls      $99e9 ; $99E9=loc_99E9
99A1:  13 A3 81 44       brclr    $a3, #-127, $99e9 ; $99E9=loc_99E9
99A5:  12 A9 40 40       brset    $a9, #64, $99e9 ; $00A9=operating_mode_flags, $99E9=loc_99E9
99A9:  F6 20 13          ldab     $2013 ; $2013=processed_sensor_2013
99AC:  D0 C9             subb     $c9
99AE:  23 39             bls      $99e9 ; $99E9=loc_99E9
99B0:  36                psha     
99B1:  B6 20 F2          ldaa     $20f2
99B4:  3D                mul      
99B5:  4D                tsta     
99B6:  32                pula     
99B7:  26 05             bne      $99be ; $99BE=loc_99BE
99B9:  F1 86 81          cmpb     $8681
99BC:  23 2B             bls      $99e9 ; $99E9=loc_99E9

loc_99BE:
99BE:  81 20             cmpa     #32 ; xrefs $99B7:branch
99C0:  26 04             bne      $99c6 ; $99C6=loc_99C6
99C2:  97 AB             staa     $ab
99C4:  20 23             bra      $99e9 ; $99E9=loc_99E9

loc_99C6:
99C6:  97 AB             staa     $ab ; xrefs $9981:branch, $99C0:branch
99C8:  86 08             ldaa     #8
99CA:  97 A3             staa     $a3
99CC:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
99CE:  B7 20 1E          staa     $201e
99D1:  DC BA             ldd      $ba ; $00BA=engine_period_delta
99D3:  FD 20 2E          std      $202e
99D6:  B6 86 83          ldaa     $8683
99D9:  B7 20 76          staa     $2076
99DC:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
99DE:  FD 23 94          std      $2394
99E1:  DC D4             ldd      $d4
99E3:  FD 23 96          std      $2396
99E6:  BD E9 93          jsr      $e993 ; $E993=sub_E993

loc_99E9:
99E9:  96 C9             ldaa     $c9 ; xrefs $9822:jump, $987A:jump, $996F:branch, $9994:branch, $9998:branch, $999F:branch, $99A1:branch, $99A5:branch, +3 more
99EB:  B1 20 13          cmpa     $2013 ; $2013=processed_sensor_2013
99EE:  27 0E             beq      $99fe ; $99FE=loc_99FE
99F0:  22 06             bhi      $99f8 ; $99F8=loc_99F8
99F2:  4F                clra     
99F3:  F6 86 80          ldab     $8680
99F6:  20 16             bra      $9a0e ; $9A0E=loc_9A0E

loc_99F8:
99F8:  B6 86 70          ldaa     $8670 ; xrefs $99F0:branch
99FB:  5F                clrb     
99FC:  20 10             bra      $9a0e ; $9A0E=loc_9A0E

loc_99FE:
99FE:  F6 20 F2          ldab     $20f2 ; xrefs $99EE:branch
9A01:  C0 01             subb     #1
9A03:  24 01             bcc      $9a06 ; $9A06=loc_9A06
9A05:  5F                clrb     

loc_9A06:
9A06:  B6 20 F1          ldaa     $20f1 ; xrefs $9A03:branch
9A09:  80 01             suba     #1
9A0B:  24 01             bcc      $9a0e ; $9A0E=loc_9A0E
9A0D:  4F                clra     

loc_9A0E:
9A0E:  B7 20 F1          staa     $20f1 ; xrefs $99F6:branch, $99FC:branch, $9A0B:branch
9A11:  F7 20 F2          stab     $20f2

loc_9A14:
9A14:  39                rts       ; xrefs $97D0:jump

; ---- unreached/data gap $9A15-$9A15 ----

        .org $9A16

sub_9A16:
9A16:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $B46E:call
9A19:  81 0C             cmpa     #12
9A1B:  26 07             bne      $9a24 ; $9A24=loc_9A24
9A1D:  86 80             ldaa     #-128
9A1F:  97 A3             staa     $a3
9A21:  7E 9B 60          jmp      $9b60 ; $9B60=loc_9B60

loc_9A24:
9A24:  13 A3 01 1B       brclr    $a3, #1, $9a43 ; $9A43=loc_9A43 | xrefs $9A1B:branch
9A28:  B6 20 64          ldaa     $2064
9A2B:  27 06             beq      $9a33 ; $9A33=loc_9A33
9A2D:  4A                deca     
9A2E:  B7 20 64          staa     $2064
9A31:  20 10             bra      $9a43 ; $9A43=loc_9A43

loc_9A33:
9A33:  FC 20 65          ldd      $2065 ; xrefs $9A2B:branch
9A36:  1A B3 86 7E       cpd      $867e
9A3A:  24 07             bcc      $9a43 ; $9A43=loc_9A43
9A3C:  86 80             ldaa     #-128
9A3E:  97 A3             staa     $a3
9A40:  7F 00 AB          clr      >$00ab

loc_9A43:
9A43:  13 A3 08 2B       brclr    $a3, #8, $9a72 ; $9A72=loc_9A72 | xrefs $9A24:branch, $9A31:branch, $9A3A:branch
9A47:  B6 20 76          ldaa     $2076
9A4A:  27 06             beq      $9a52 ; $9A52=loc_9A52
9A4C:  4A                deca     
9A4D:  B7 20 76          staa     $2076
9A50:  20 08             bra      $9a5a ; $9A5A=loc_9A5A

loc_9A52:
9A52:  DC C7             ldd      $c7 ; xrefs $9A4A:branch
9A54:  1A B3 86 84       cpd      $8684
9A58:  23 11             bls      $9a6b ; $9A6B=loc_9A6B

loc_9A5A:
9A5A:  96 D1             ldaa     $d1 ; xrefs $9A50:branch
9A5C:  81 FF             cmpa     #-1
9A5E:  27 12             beq      $9a72 ; $9A72=loc_9A72
9A60:  F6 20 A8          ldab     $20a8
9A63:  FB 86 86          addb     $8686
9A66:  25 03             bcs      $9a6b ; $9A6B=loc_9A6B
9A68:  11                cba      
9A69:  24 07             bcc      $9a72 ; $9A72=loc_9A72

loc_9A6B:
9A6B:  86 80             ldaa     #-128 ; xrefs $9A58:branch, $9A66:branch
9A6D:  97 A3             staa     $a3
9A6F:  7F 00 AB          clr      >$00ab

loc_9A72:
9A72:  13 A3 04 25       brclr    $a3, #4, $9a9b ; $9A9B=loc_9A9B | xrefs $9A43:branch, $9A5E:branch, $9A69:branch
9A76:  13 A9 40 21       brclr    $a9, #64, $9a9b ; $00A9=operating_mode_flags, $9A9B=loc_9A9B
9A7A:  B6 20 A8          ldaa     $20a8
9A7D:  BB 87 7D          adda     $877d
9A80:  24 02             bcc      $9a84 ; $9A84=loc_9A84
9A82:  86 FF             ldaa     #-1

loc_9A84:
9A84:  91 D1             cmpa     $d1 ; xrefs $9A80:branch
9A86:  23 13             bls      $9a9b ; $9A9B=loc_9A9B
9A88:  86 20             ldaa     #32
9A8A:  97 A3             staa     $a3
9A8C:  14 B1 10          bset     $b1, #16
9A8F:  B6 87 7A          ldaa     $877a
9A92:  B7 20 F7          staa     $20f7
9A95:  7F 00 AB          clr      >$00ab
9A98:  7E 9B 60          jmp      $9b60 ; $9B60=loc_9B60

loc_9A9B:
9A9B:  B6 20 59          ldaa     $2059 ; xrefs $9A72:branch, $9A76:branch, $9A86:branch
9A9E:  81 04             cmpa     #4
9AA0:  26 04             bne      $9aa6 ; $9AA6=loc_9AA6
9AA2:  13 1E 90 03       brclr    $1e, #-112, $9aa9 ; $9AA9=loc_9AA9

loc_9AA6:
9AA6:  7E 9B 4A          jmp      $9b4a ; $9B4A=loc_9B4A | xrefs $9AA0:branch

loc_9AA9:
9AA9:  CE 86 98          ldx      #-31080 ; xrefs $9AA2:branch
9AAC:  13 D8 10 07       brclr    $d8, #16, $9ab7 ; $9AB7=loc_9AB7
9AB0:  96 90             ldaa     $90
9AB2:  26 03             bne      $9ab7 ; $9AB7=loc_9AB7
9AB4:  CE 86 92          ldx      #-31086

loc_9AB7:
9AB7:  F6 20 AB          ldab     $20ab ; xrefs $9AAC:branch, $9AB2:branch
9ABA:  3A                abx      
9ABB:  B6 20 A8          ldaa     $20a8
9ABE:  44                lsra     
9ABF:  44                lsra     
9AC0:  AB 00             adda     0, x
9AC2:  24 02             bcc      $9ac6 ; $9AC6=loc_9AC6
9AC4:  86 FF             ldaa     #-1

loc_9AC6:
9AC6:  16                tab       ; xrefs $9AC2:branch
9AC7:  B7 23 93          staa     $2393
9ACA:  91 D3             cmpa     $d3
9ACC:  24 7C             bcc      $9b4a ; $9B4A=loc_9B4A
9ACE:  13 A3 88 78       brclr    $a3, #-120, $9b4a ; $9B4A=loc_9B4A
9AD2:  96 CA             ldaa     $ca
9AD4:  B1 20 F6          cmpa     $20f6
9AD7:  25 71             bcs      $9b4a ; $9B4A=loc_9B4A
9AD9:  B6 87 72          ldaa     $8772
9ADC:  1B                aba      
9ADD:  24 02             bcc      $9ae1 ; $9AE1=loc_9AE1
9ADF:  86 FF             ldaa     #-1

loc_9AE1:
9AE1:  91 D3             cmpa     $d3 ; xrefs $9ADD:branch
9AE3:  22 0A             bhi      $9aef ; $9AEF=loc_9AEF
9AE5:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
9AE7:  1A B3 87 73       cpd      $8773
9AEB:  24 02             bcc      $9aef ; $9AEF=loc_9AEF
9AED:  20 04             bra      $9af3 ; $9AF3=loc_9AF3

loc_9AEF:
9AEF:  13 A9 40 57       brclr    $a9, #64, $9b4a ; $00A9=operating_mode_flags, $9B4A=loc_9B4A | xrefs $9AE3:branch, $9AEB:branch

loc_9AF3:
9AF3:  B6 86 99          ldaa     $8699 ; xrefs $9AED:branch
9AF6:  27 1C             beq      $9b14 ; $9B14=loc_9B14
9AF8:  B6 20 AB          ldaa     $20ab
9AFB:  81 01             cmpa     #1
9AFD:  27 2B             beq      $9b2a ; $9B2A=loc_9B2A
9AFF:  13 A9 40 11       brclr    $a9, #64, $9b14 ; $00A9=operating_mode_flags, $9B14=loc_9B14
9B03:  13 A3 08 0D       brclr    $a3, #8, $9b14 ; $9B14=loc_9B14
9B07:  DC D4             ldd      $d4
9B09:  B3 23 96          subd     $2396
9B0C:  25 06             bcs      $9b14 ; $9B14=loc_9B14
9B0E:  1A B3 87 76       cpd      $8776
9B12:  24 2B             bcc      $9b3f ; $9B3F=loc_9B3F

loc_9B14:
9B14:  B6 23 92          ldaa     $2392 ; xrefs $9AF6:branch, $9AFF:branch, $9B03:branch, $9B0C:branch
9B17:  26 07             bne      $9b20 ; $9B20=loc_9B20
9B19:  43                coma     
9B1A:  B7 23 92          staa     $2392
9B1D:  BD 9B 79          jsr      $9b79 ; $9B79=sub_9B79

loc_9B20:
9B20:  B6 23 91          ldaa     $2391 ; $2391=fuel_cut_state_countdown | xrefs $9B17:branch
9B23:  27 1A             beq      $9b3f ; $9B3F=loc_9B3F
9B25:  7A 23 91          dec      $2391 ; $2391=fuel_cut_state_countdown
9B28:  20 27             bra      $9b51 ; $9B51=loc_9B51

loc_9B2A:
9B2A:  13 A9 40 23       brclr    $a9, #64, $9b51 ; $00A9=operating_mode_flags, $9B51=loc_9B51 | xrefs $9AFD:branch
9B2E:  13 A3 08 1F       brclr    $a3, #8, $9b51 ; $9B51=loc_9B51
9B32:  DC D4             ldd      $d4
9B34:  B3 23 96          subd     $2396
9B37:  25 18             bcs      $9b51 ; $9B51=loc_9B51
9B39:  1A B3 87 78       cpd      $8778
9B3D:  25 12             bcs      $9b51 ; $9B51=loc_9B51

loc_9B3F:
9B3F:  86 04             ldaa     #4 ; xrefs $9B12:branch, $9B23:branch
9B41:  97 A3             staa     $a3
9B43:  CC 00 00          ldd      #0
9B46:  DD C3             std      $c3 ; $00C3=final_fuel_duration
9B48:  97 AB             staa     $ab

loc_9B4A:
9B4A:  4F                clra      ; xrefs $9AA6:jump, $9ACC:branch, $9ACE:branch, $9AD7:branch, $9AEF:branch
9B4B:  B7 23 92          staa     $2392
9B4E:  B7 23 91          staa     $2391 ; $2391=fuel_cut_state_countdown

loc_9B51:
9B51:  13 A3 20 0B       brclr    $a3, #32, $9b60 ; $9B60=loc_9B60 | xrefs $9B28:branch, $9B2A:branch, $9B2E:branch, $9B37:branch, $9B3D:branch
9B55:  12 B1 10 07       brset    $b1, #16, $9b60 ; $9B60=loc_9B60
9B59:  86 80             ldaa     #-128
9B5B:  97 A3             staa     $a3
9B5D:  7F 00 AB          clr      >$00ab

loc_9B60:
9B60:  39                rts       ; xrefs $9A21:jump, $9A98:jump, $9B51:branch, $9B55:branch

sub_9B61:
9B61:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index | xrefs $B910:call
9B64:  18 CE 86 89       ldy      #-31095
9B68:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
9B6B:  B7 20 F6          staa     $20f6
9B6E:  BD 9B B5          jsr      $9bb5 ; $9BB5=sub_9BB5
9B71:  4F                clra     
9B72:  B7 23 92          staa     $2392
9B75:  B7 23 91          staa     $2391 ; $2391=fuel_cut_state_countdown
9B78:  39                rts      

sub_9B79:
9B79:  18 CE 23 8A       ldy      #9098 ; xrefs $9B1D:call
9B7D:  FC 20 14          ldd      $2014
9B80:  B3 23 94          subd     $2394
9B83:  25 0F             bcs      $9b94 ; $9B94=loc_9B94
9B85:  1A 83 02 00       cpd      #512
9B89:  25 05             bcs      $9b90 ; $9B90=loc_9B90
9B8B:  CC 08 00          ldd      #2048
9B8E:  20 07             bra      $9b97 ; $9B97=loc_9B97

loc_9B90:
9B90:  05                asld      ; xrefs $9B89:branch
9B91:  05                asld     
9B92:  20 03             bra      $9b97 ; $9B97=loc_9B97

loc_9B94:
9B94:  CC 00 00          ldd      #0 ; xrefs $9B83:branch

loc_9B97:
9B97:  FD 23 98          std      $2398 ; xrefs $9B8E:branch, $9B92:branch
9B9A:  18 ED 00          std      0, y
9B9D:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
9BA0:  18 ED 02          std      2, y
9BA3:  CC 86 9A          ldd      #-31078
9BA6:  18 ED 04          std      4, y
9BA9:  86 09             ldaa     #9
9BAB:  18 A7 06          staa     6, y
9BAE:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
9BB1:  B7 23 91          staa     $2391 ; $2391=fuel_cut_state_countdown
9BB4:  39                rts      

sub_9BB5:
9BB5:  CC 00 00          ldd      #0 ; xrefs $9B6E:call, $9C02:call
9BB8:  97 A2             staa     $a2 ; $00A2=spark_mode_flags
9BBA:  FD 20 03          std      $2003
9BBD:  FD 20 F9          std      $20f9
9BC0:  FD 20 FB          std      $20fb
9BC3:  15 B3 03          bclr     $b3, #3
9BC6:  B6 00 CB          ldaa     >$00cb
9BC9:  B1 89 BA          cmpa     $89ba
9BCC:  25 2F             bcs      $9bfd ; $9BFD=loc_9BFD
9BCE:  96 CA             ldaa     $ca
9BD0:  B1 89 B7          cmpa     $89b7
9BD3:  24 0A             bcc      $9bdf ; $9BDF=loc_9BDF
9BD5:  B1 89 B6          cmpa     $89b6
9BD8:  25 05             bcs      $9bdf ; $9BDF=loc_9BDF
9BDA:  14 B3 01          bset     $b3, #1
9BDD:  20 0F             bra      $9bee ; $9BEE=loc_9BEE

loc_9BDF:
9BDF:  96 CA             ldaa     $ca ; xrefs $9BD3:branch, $9BD8:branch
9BE1:  B1 89 B9          cmpa     $89b9
9BE4:  24 17             bcc      $9bfd ; $9BFD=loc_9BFD
9BE6:  B1 89 B8          cmpa     $89b8
9BE9:  25 12             bcs      $9bfd ; $9BFD=loc_9BFD
9BEB:  14 B3 02          bset     $b3, #2

loc_9BEE:
9BEE:  14 A2 10          bset     $a2, #16 ; $00A2=spark_mode_flags | xrefs $9BDD:branch
9BF1:  FC 89 BB          ldd      $89bb
9BF4:  FD 20 05          std      $2005
9BF7:  CC FF FF          ldd      #-1
9BFA:  FD 20 F9          std      $20f9

loc_9BFD:
9BFD:  39                rts       ; xrefs $9BCC:branch, $9BE4:branch, $9BE9:branch

sub_9BFE:
9BFE:  12 A9 01 06       brset    $a9, #1, $9c08 ; $00A9=operating_mode_flags, $9C08=loc_9C08 | xrefs $9672:call
9C02:  BD 9B B5          jsr      $9bb5 ; $9BB5=sub_9BB5
9C05:  7E 9C A1          jmp      $9ca1 ; $9CA1=loc_9CA1

loc_9C08:
9C08:  13 A2 F0 3F       brclr    $a2, #-16, $9c4b ; $00A2=spark_mode_flags, $9C4B=loc_9C4B | xrefs $9BFE:branch
9C0C:  FC 20 05          ldd      $2005
9C0F:  26 47             bne      $9c58 ; $9C58=loc_9C58
9C11:  13 A2 10 0B       brclr    $a2, #16, $9c20 ; $00A2=spark_mode_flags, $9C20=loc_9C20
9C15:  15 A2 10          bclr     $a2, #16 ; $00A2=spark_mode_flags
9C18:  14 A2 20          bset     $a2, #32 ; $00A2=spark_mode_flags
9C1B:  FC 89 BD          ldd      $89bd
9C1E:  20 28             bra      $9c48 ; $9C48=loc_9C48

loc_9C20:
9C20:  13 A2 20 17       brclr    $a2, #32, $9c3b ; $00A2=spark_mode_flags, $9C3B=loc_9C3B | xrefs $9C11:branch
9C24:  15 A2 20          bclr     $a2, #32 ; $00A2=spark_mode_flags
9C27:  13 B3 02 08       brclr    $b3, #2, $9c33 ; $9C33=loc_9C33
9C2B:  CC 00 00          ldd      #0
9C2E:  FD 20 F9          std      $20f9
9C31:  20 6E             bra      $9ca1 ; $9CA1=loc_9CA1

loc_9C33:
9C33:  14 A2 40          bset     $a2, #64 ; $00A2=spark_mode_flags | xrefs $9C27:branch
9C36:  FC 89 BF          ldd      $89bf
9C39:  20 0D             bra      $9c48 ; $9C48=loc_9C48

loc_9C3B:
9C3B:  13 A2 40 0E       brclr    $a2, #64, $9c4d ; $00A2=spark_mode_flags, $9C4D=loc_9C4D | xrefs $9C20:branch
9C3F:  15 A2 40          bclr     $a2, #64 ; $00A2=spark_mode_flags
9C42:  14 A2 80          bset     $a2, #-128 ; $00A2=spark_mode_flags
9C45:  FC 89 C1          ldd      $89c1

loc_9C48:
9C48:  FD 20 05          std      $2005 ; xrefs $9C1E:branch, $9C39:branch

loc_9C4B:
9C4B:  20 54             bra      $9ca1 ; $9CA1=loc_9CA1 | xrefs $9C08:branch

loc_9C4D:
9C4D:  15 A2 80          bclr     $a2, #-128 ; $00A2=spark_mode_flags | xrefs $9C3B:branch
9C50:  CC 00 00          ldd      #0
9C53:  FD 20 F9          std      $20f9
9C56:  20 49             bra      $9ca1 ; $9CA1=loc_9CA1

loc_9C58:
9C58:  83 00 01          subd     #1 ; xrefs $9C0F:branch
9C5B:  FD 20 05          std      $2005
9C5E:  13 A3 01 3F       brclr    $a3, #1, $9ca1 ; $9CA1=loc_9CA1
9C62:  13 A2 20 1A       brclr    $a2, #32, $9c80 ; $00A2=spark_mode_flags, $9C80=loc_9C80
9C66:  14 A2 04          bset     $a2, #4 ; $00A2=spark_mode_flags
9C69:  13 B3 02 06       brclr    $b3, #2, $9c73 ; $9C73=loc_9C73
9C6D:  FC 89 C3          ldd      $89c3
9C70:  FD 20 FB          std      $20fb

loc_9C73:
9C73:  B6 89 B2          ldaa     $89b2 ; xrefs $9C69:branch
9C76:  7D 00 90          tst      >$0090
9C79:  26 17             bne      $9c92 ; $9C92=loc_9C92
9C7B:  B6 89 B4          ldaa     $89b4
9C7E:  20 12             bra      $9c92 ; $9C92=loc_9C92

loc_9C80:
9C80:  13 A2 80 1D       brclr    $a2, #-128, $9ca1 ; $00A2=spark_mode_flags, $9CA1=loc_9CA1 | xrefs $9C62:branch
9C84:  14 A2 08          bset     $a2, #8 ; $00A2=spark_mode_flags
9C87:  B6 89 B3          ldaa     $89b3
9C8A:  7D 00 90          tst      >$0090
9C8D:  26 03             bne      $9c92 ; $9C92=loc_9C92
9C8F:  B6 89 B5          ldaa     $89b5

loc_9C92:
9C92:  C6 F4             ldab     #-12 ; xrefs $9C79:branch, $9C7E:branch, $9C8D:branch
9C94:  3D                mul      
9C95:  FD 20 F9          std      $20f9
9C98:  FC 89 C5          ldd      $89c5
9C9B:  FD 20 03          std      $2003
9C9E:  15 A2 F0          bclr     $a2, #-16 ; $00A2=spark_mode_flags

loc_9CA1:
9CA1:  13 A3 81 65       brclr    $a3, #-127, $9d0a ; $9D0A=loc_9D0A | xrefs $9C05:jump, $9C31:branch, $9C4B:branch, $9C56:branch, $9C5E:branch, $9C80:branch
9CA5:  B6 20 59          ldaa     $2059
9CA8:  81 04             cmpa     #4
9CAA:  26 5E             bne      $9d0a ; $9D0A=loc_9D0A
9CAC:  13 1E 90 0D       brclr    $1e, #-112, $9cbd ; $9CBD=loc_9CBD
9CB0:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
9CB2:  F3 89 97          addd     $8997
9CB5:  1A B3 20 14       cpd      $2014
9CB9:  25 4F             bcs      $9d0a ; $9D0A=loc_9D0A
9CBB:  20 0C             bra      $9cc9 ; $9CC9=loc_9CC9

loc_9CBD:
9CBD:  B6 20 F5          ldaa     $20f5 ; xrefs $9CAC:branch
9CC0:  91 C9             cmpa     $c9
9CC2:  22 34             bhi      $9cf8 ; $9CF8=loc_9CF8
9CC4:  B1 20 13          cmpa     $2013 ; $2013=processed_sensor_2013
9CC7:  22 2F             bhi      $9cf8 ; $9CF8=loc_9CF8

loc_9CC9:
9CC9:  FC 20 F9          ldd      $20f9 ; xrefs $9CBB:branch, $9D08:branch
9CCC:  27 21             beq      $9cef ; $9CEF=loc_9CEF
9CCE:  83 00 01          subd     #1
9CD1:  FD 20 F9          std      $20f9
9CD4:  13 B3 02 0E       brclr    $b3, #2, $9ce6 ; $9CE6=loc_9CE6
9CD8:  13 A2 04 0A       brclr    $a2, #4, $9ce6 ; $00A2=spark_mode_flags, $9CE6=loc_9CE6
9CDC:  FC 20 FB          ldd      $20fb
9CDF:  26 05             bne      $9ce6 ; $9CE6=loc_9CE6
9CE1:  FD 20 F9          std      $20f9
9CE4:  20 09             bra      $9cef ; $9CEF=loc_9CEF

loc_9CE6:
9CE6:  14 A2 01          bset     $a2, #1 ; $00A2=spark_mode_flags | xrefs $9CD4:branch, $9CD8:branch, $9CDF:branch
9CE9:  15 A9 20          bclr     $a9, #32 ; $00A9=operating_mode_flags
9CEC:  7E 9D 23          jmp      $9d23 ; $9D23=loc_9D23

loc_9CEF:
9CEF:  14 A9 20          bset     $a9, #32 ; $00A9=operating_mode_flags | xrefs $9CCC:branch, $9CE4:branch
9CF2:  15 A2 01          bclr     $a2, #1 ; $00A2=spark_mode_flags
9CF5:  7E 9D 23          jmp      $9d23 ; $9D23=loc_9D23

loc_9CF8:
9CF8:  13 A9 20 0E       brclr    $a9, #32, $9d0a ; $00A9=operating_mode_flags, $9D0A=loc_9D0A | xrefs $9CC2:branch, $9CC7:branch
9CFC:  B0 89 99          suba     $8999
9CFF:  91 C9             cmpa     $c9
9D01:  22 07             bhi      $9d0a ; $9D0A=loc_9D0A
9D03:  B1 20 13          cmpa     $2013 ; $2013=processed_sensor_2013
9D06:  22 02             bhi      $9d0a ; $9D0A=loc_9D0A
9D08:  20 BF             bra      $9cc9 ; $9CC9=loc_9CC9

loc_9D0A:
9D0A:  15 A9 20          bclr     $a9, #32 ; $00A9=operating_mode_flags | xrefs $9CA1:branch, $9CAA:branch, $9CB9:branch, $9CF8:branch, $9D01:branch, $9D06:branch
9D0D:  15 A2 01          bclr     $a2, #1 ; $00A2=spark_mode_flags
9D10:  7E 9D 23          jmp      $9d23 ; $9D23=loc_9D23

sub_9D13:
9D13:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis | xrefs $D4A9:call
9D16:  18 CE 89 9A       ldy      #-30310
9D1A:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
9D1D:  40                nega     
9D1E:  9B 10             adda     $10
9D20:  B7 20 F5          staa     $20f5

loc_9D23:
9D23:  39                rts       ; xrefs $9CEC:jump, $9CF5:jump, $9D10:jump

; ---- unreached/data gap $9D24-$9D24 ----

        .org $9D25

; [OPEN] Periodic runtime stage.
runtime_stage_9d25:
9D25:  FC 20 03          ldd      $2003 ; xrefs $D3E2:call
9D28:  27 1A             beq      $9d44 ; $9D44=loc_9D44
9D2A:  83 00 01          subd     #1
9D2D:  FD 20 03          std      $2003
9D30:  27 0F             beq      $9d41 ; $9D41=loc_9D41
9D32:  7D 00 90          tst      >$0090
9D35:  27 0A             beq      $9d41 ; $9D41=loc_9D41
9D37:  7D 20 2D          tst      $202d
9D3A:  26 05             bne      $9d41 ; $9D41=loc_9D41
9D3C:  14 A2 02          bset     $a2, #2 ; $00A2=spark_mode_flags
9D3F:  20 03             bra      $9d44 ; $9D44=loc_9D44

loc_9D41:
9D41:  15 A2 02          bclr     $a2, #2 ; $00A2=spark_mode_flags | xrefs $9D30:branch, $9D35:branch, $9D3A:branch

loc_9D44:
9D44:  FC 20 FB          ldd      $20fb ; xrefs $9D28:branch, $9D3F:branch
9D47:  27 06             beq      $9d4f ; $9D4F=loc_9D4F
9D49:  83 00 01          subd     #1
9D4C:  FD 20 FB          std      $20fb

loc_9D4F:
9D4F:  39                rts       ; xrefs $9D47:branch

; ---- unreached/data gap $9D50-$9D50 ----

        .org $9D51

sub_9D51:
9D51:  8D 03             bsr      $9d56 ; $9D56=sub_9D56 | xrefs $D616:call
9D53:  8D 33             bsr      $9d88 ; $9D88=sub_9D88
9D55:  39                rts      

sub_9D56:
9D56:  13 A9 01 21       brclr    $a9, #1, $9d7b ; $00A9=operating_mode_flags, $9D7B=loc_9D7B | xrefs $9D51:call
9D5A:  12 F2 04 1A       brset    $f2, #4, $9d78 ; $9D78=loc_9D78
9D5E:  12 A9 02 16       brset    $a9, #2, $9d78 ; $00A9=operating_mode_flags, $9D78=loc_9D78
9D62:  14 F2 01          bset     $f2, #1
9D65:  12 F2 02 12       brset    $f2, #2, $9d7b ; $9D7B=loc_9D7B
9D69:  B6 10 60          ldaa     $1060
9D6C:  84 02             anda     #2
9D6E:  B1 23 EA          cmpa     $23ea
9D71:  27 08             beq      $9d7b ; $9D7B=loc_9D7B
9D73:  14 F2 02          bset     $f2, #2
9D76:  20 03             bra      $9d7b ; $9D7B=loc_9D7B

loc_9D78:
9D78:  14 F2 04          bset     $f2, #4 ; xrefs $9D5A:branch, $9D5E:branch

loc_9D7B:
9D7B:  39                rts       ; xrefs $9D56:branch, $9D65:branch, $9D71:branch, $9D76:branch

; ---- unreached/data gap $9D7C-$9D87 ----

        .org $9D88

sub_9D88:
9D88:  F6 10 60          ldab     $1060 ; xrefs $9D53:call
9D8B:  C4 02             andb     #2
9D8D:  27 02             beq      $9d91 ; $9D91=loc_9D91
9D8F:  C6 FF             ldab     #-1

loc_9D91:
9D91:  CE 9D 7C          ldx      #-25220 ; xrefs $9D8D:branch
9D94:  17                tba      
9D95:  D6 91             ldab     $91
9D97:  5A                decb     
9D98:  58                aslb     
9D99:  3A                abx      
9D9A:  EE 00             ldx      0, x
9D9C:  16                tab      
9D9D:  6E 00             jmp      0, x

; ---- unreached/data gap $9D9F-$9E86 ----

        .org $9E87

sub_9E87:
9E87:  CE 10 00          ldx      #4096 ; xrefs $9663:call
9E8A:  1F 60 02 09       brclr    96, x; #2; $9e97 ; $9E97=loc_9E97
9E8E:  B6 23 EB          ldaa     $23eb
9E91:  27 04             beq      $9e97 ; $9E97=loc_9E97
9E93:  4A                deca     
9E94:  B7 23 EB          staa     $23eb

loc_9E97:
9E97:  39                rts       ; xrefs $9E8A:branch, $9E91:branch

sub_9E98:
9E98:  B6 10 60          ldaa     $1060 ; xrefs $B8DD:call
9E9B:  84 02             anda     #2
9E9D:  B7 23 EA          staa     $23ea
9EA0:  7D 00 95          tst      >$0095
9EA3:  27 03             beq      $9ea8 ; $9EA8=loc_9EA8
9EA5:  4F                clra     
9EA6:  20 04             bra      $9eac ; $9EAC=loc_9EAC

loc_9EA8:
9EA8:  96 F2             ldaa     $f2 ; xrefs $9EA3:branch
9EAA:  84 04             anda     #4

loc_9EAC:
9EAC:  97 F2             staa     $f2 ; xrefs $9EA6:branch
9EAE:  39                rts      

sub_9EAF:
9EAF:  96 91             ldaa     $91 ; xrefs $B887:call
9EB1:  81 01             cmpa     #1
9EB3:  27 08             beq      $9ebd ; $9EBD=loc_9EBD
9EB5:  81 02             cmpa     #2
9EB7:  27 04             beq      $9ebd ; $9EBD=loc_9EBD
9EB9:  81 05             cmpa     #5
9EBB:  26 07             bne      $9ec4 ; $9EC4=loc_9EC4

loc_9EBD:
9EBD:  96 92             ldaa     $92 ; xrefs $9EB3:branch, $9EB7:branch
9EBF:  27 03             beq      $9ec4 ; $9EC4=loc_9EC4
9EC1:  7A 00 92          dec      >$0092

loc_9EC4:
9EC4:  39                rts       ; xrefs $9EBB:branch, $9EBF:branch

sub_9EC5:
9EC5:  BD A7 59          jsr      $a759 ; $A759=sub_A759 | xrefs $96C9:call
9EC8:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
9ECB:  81 00             cmpa     #0
9ECD:  27 04             beq      $9ed3 ; $9ED3=loc_9ED3
9ECF:  13 F3 04 45       brclr    $f3, #4, $9f18 ; $9F18=loc_9F18

loc_9ED3:
9ED3:  13 F3 04 2B       brclr    $f3, #4, $9f02 ; $9F02=spi_status_stream | xrefs $9ECD:branch
9ED7:  B6 10 08          ldaa     $1008 ; $1008=PORTD
9EDA:  84 20             anda     #32
9EDC:  27 37             beq      $9f15 ; $9F15=loc_9F15
9EDE:  7A 21 E2          dec      $21e2
9EE1:  26 32             bne      $9f15 ; $9F15=loc_9F15
9EE3:  15 F3 04          bclr     $f3, #4
9EE6:  15 F3 02          bclr     $f3, #2
9EE9:  15 F3 01          bclr     $f3, #1
9EEC:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9EEF:  B6 10 2A          ldaa     $102a ; $102A=SPDR
9EF2:  86 5C             ldaa     #92
9EF4:  B7 10 28          staa     $1028 ; $1028=SPCR
9EF7:  C6 1A             ldab     #26
9EF9:  F7 10 09          stab     $1009 ; $1009=DDRD
9EFC:  B7 10 28          staa     $1028 ; $1028=SPCR
9EFF:  7E A0 01          jmp      $a001 ; $A001=loc_A001

; [CONFIRMED] Stream selected live RAM/status bytes through the SPI peripheral using pointer frame 0x8010.
spi_status_stream:
9F02:  18 CE 80 10       ldy      #-32752 ; xrefs $9ED3:branch
9F06:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F09:  84 10             anda     #16
9F0B:  27 25             beq      $9f32 ; $9F32=loc_9F32
9F0D:  14 F3 04          bset     $f3, #4
9F10:  86 0F             ldaa     #15
9F12:  B7 21 E2          staa     $21e2

loc_9F15:
9F15:  7E A0 01          jmp      $a001 ; $A001=loc_A001 | xrefs $9EDC:branch, $9EE1:branch

loc_9F18:
9F18:  18 CE 80 10       ldy      #-32752 ; xrefs $9ECF:branch
9F1C:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F1F:  84 10             anda     #16
9F21:  27 0B             beq      $9f2e ; $9F2E=loc_9F2E
9F23:  14 F3 04          bset     $f3, #4
9F26:  86 0F             ldaa     #15
9F28:  B7 21 E2          staa     $21e2
9F2B:  7E A0 01          jmp      $a001 ; $A001=loc_A001

loc_9F2E:
9F2E:  4F                clra      ; xrefs $9F21:branch
9F2F:  7E 9F 4B          jmp      $9f4b ; $9F4B=loc_9F4B

loc_9F32:
9F32:  86 10             ldaa     #16 ; xrefs $9F0B:branch
9F34:  F6 10 29          ldab     $1029 ; $1029=SPSR
9F37:  B7 10 2A          staa     $102a ; $102A=SPDR
9F3A:  01                nop      
9F3B:  01                nop      
9F3C:  01                nop      
9F3D:  01                nop      
9F3E:  01                nop      
9F3F:  C6 00             ldab     #0
9F41:  8B 00             adda     #0
9F43:  36                psha     
9F44:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F47:  F7 10 2A          stab     $102a ; $102A=SPDR
9F4A:  32                pula     

loc_9F4B:
9F4B:  CD EE 00          ldx      0, y ; xrefs $9F2F:jump
9F4E:  E6 00             ldab     0, x
9F50:  1B                aba      
9F51:  36                psha     
9F52:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F55:  F7 10 2A          stab     $102a ; $102A=SPDR
9F58:  32                pula     
9F59:  CD EE 02          ldx      2, y
9F5C:  E6 00             ldab     0, x
9F5E:  1B                aba      
9F5F:  36                psha     
9F60:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F63:  F7 10 2A          stab     $102a ; $102A=SPDR
9F66:  32                pula     
9F67:  CD EE 04          ldx      4, y
9F6A:  E6 00             ldab     0, x
9F6C:  1B                aba      
9F6D:  36                psha     
9F6E:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F71:  F7 10 2A          stab     $102a ; $102A=SPDR
9F74:  32                pula     
9F75:  CD EE 06          ldx      6, y
9F78:  E6 00             ldab     0, x
9F7A:  1B                aba      
9F7B:  36                psha     
9F7C:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F7F:  F7 10 2A          stab     $102a ; $102A=SPDR
9F82:  32                pula     
9F83:  CD EE 08          ldx      8, y
9F86:  E6 00             ldab     0, x
9F88:  1B                aba      
9F89:  36                psha     
9F8A:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F8D:  F7 10 2A          stab     $102a ; $102A=SPDR
9F90:  32                pula     
9F91:  CD EE 0A          ldx      10, y
9F94:  E6 00             ldab     0, x
9F96:  1B                aba      
9F97:  36                psha     
9F98:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9F9B:  F7 10 2A          stab     $102a ; $102A=SPDR
9F9E:  0F                sei      
9F9F:  32                pula     
9FA0:  CD EE 0C          ldx      12, y
9FA3:  E6 00             ldab     0, x
9FA5:  1B                aba      
9FA6:  36                psha     
9FA7:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FAA:  F7 10 2A          stab     $102a ; $102A=SPDR
9FAD:  32                pula     
9FAE:  CD EE 0E          ldx      14, y
9FB1:  E6 00             ldab     0, x
9FB3:  1B                aba      
9FB4:  36                psha     
9FB5:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FB8:  F7 10 2A          stab     $102a ; $102A=SPDR
9FBB:  32                pula     
9FBC:  CD EE 10          ldx      16, y
9FBF:  E6 00             ldab     0, x
9FC1:  1B                aba      
9FC2:  36                psha     
9FC3:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FC6:  F7 10 2A          stab     $102a ; $102A=SPDR
9FC9:  32                pula     
9FCA:  CD EE 12          ldx      18, y
9FCD:  E6 00             ldab     0, x
9FCF:  1B                aba      
9FD0:  36                psha     
9FD1:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FD4:  F7 10 2A          stab     $102a ; $102A=SPDR
9FD7:  32                pula     
9FD8:  CD EE 14          ldx      20, y
9FDB:  E6 00             ldab     0, x
9FDD:  1B                aba      
9FDE:  36                psha     
9FDF:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FE2:  F7 10 2A          stab     $102a ; $102A=SPDR
9FE5:  32                pula     
9FE6:  CD EE 16          ldx      22, y
9FE9:  E6 00             ldab     0, x
9FEB:  1B                aba      
9FEC:  36                psha     
9FED:  B6 10 29          ldaa     $1029 ; $1029=SPSR
9FF0:  F7 10 2A          stab     $102a ; $102A=SPDR
9FF3:  32                pula     
9FF4:  01                nop      
9FF5:  01                nop      
9FF6:  01                nop      
9FF7:  01                nop      
9FF8:  01                nop      
9FF9:  01                nop      
9FFA:  F6 10 29          ldab     $1029 ; $1029=SPSR
9FFD:  B7 10 2A          staa     $102a ; $102A=SPDR
A000:  0E                cli      

loc_A001:
A001:  39                rts       ; xrefs $9EFF:jump, $9F15:jump, $9F2B:jump

sub_A002:
A002:  12 F3 04 0B       brset    $f3, #4, $a011 ; $A011=loc_A011 | xrefs $9684:call
A006:  B6 10 29          ldaa     $1029 ; $1029=SPSR
A009:  B6 10 2A          ldaa     $102a ; $102A=SPDR
A00C:  86 55             ldaa     #85
A00E:  B7 10 2A          staa     $102a ; $102A=SPDR

loc_A011:
A011:  39                rts       ; xrefs $A002:branch

sub_A012:
A012:  86 00             ldaa     #0 ; xrefs $B913:call
A014:  97 F3             staa     $f3
A016:  B6 10 29          ldaa     $1029 ; $1029=SPSR
A019:  86 5C             ldaa     #92
A01B:  B7 10 28          staa     $1028 ; $1028=SPCR
A01E:  B7 10 28          staa     $1028 ; $1028=SPCR
A021:  39                rts      

; ---- unreached/data gap $A022-$A03C ----

        .org $A03D

loc_A03D:
A03D:  96 F5             ldaa     $f5 ; xrefs $A3E5:jump, $A3EC:jump
A03F:  27 1A             beq      $a05b ; $A05B=loc_A05B
A041:  18 CE 22 80       ldy      #8832
A045:  18 FF 23 F4       sty      $23f4
A049:  18 FF 23 F2       sty      $23f2
A04D:  13 F4 01 03       brclr    $f4, #1, $a054 ; $A054=loc_A054
A051:  7E A0 6F          jmp      $a06f ; $A06F=loc_A06F

loc_A054:
A054:  13 F4 02 03       brclr    $f4, #2, $a05b ; $A05B=loc_A05B | xrefs $A04D:branch
A058:  7E A2 F3          jmp      $a2f3 ; $A2F3=loc_A2F3

loc_A05B:
A05B:  13 F6 80 0D       brclr    $f6, #-128, $a06c ; $A06C=loc_A06C | xrefs $A03F:branch, $A054:branch
A05F:  15 F6 80          bclr     $f6, #-128
A062:  86 02             ldaa     #2
A064:  97 F5             staa     $f5
A066:  97 F4             staa     $f4
A068:  4F                clra     
A069:  B7 24 14          staa     $2414

loc_A06C:
A06C:  7E A6 95          jmp      $a695 ; $A695=loc_A695 | xrefs $A05B:branch

loc_A06F:
A06F:  15 F7 01          bclr     $f7, #1 ; xrefs $A051:jump
A072:  7F 00 F5          clr      >$00f5
A075:  CE 22 00          ldx      #8704
A078:  FF 23 F0          stx      $23f0
A07B:  C6 16             ldab     #22
A07D:  18 E7 00          stab     0, y
A080:  08                inx      
A081:  18 08             iny      
A083:  E6 00             ldab     0, x
A085:  17                tba      
A086:  84 0F             anda     #15
A088:  81 01             cmpa     #1
A08A:  27 18             beq      $a0a4 ; $A0A4=loc_A0A4
A08C:  7F 00 F5          clr      >$00f5
A08F:  14 F5 02          bset     $f5, #2
A092:  CE 22 00          ldx      #8704
A095:  FF 23 EE          stx      $23ee
A098:  FF 23 F0          stx      $23f0
A09B:  7F 00 F4          clr      >$00f4
A09E:  14 F4 02          bset     $f4, #2
A0A1:  7E A6 95          jmp      $a695 ; $A695=loc_A695

loc_A0A4:
A0A4:  86 10             ldaa     #16 ; xrefs $A08A:branch
A0A6:  3D                mul      
A0A7:  8B 10             adda     #16
A0A9:  18 A7 00          staa     0, y
A0AC:  B7 23 FC          staa     $23fc
A0AF:  08                inx      
A0B0:  18 08             iny      
A0B2:  E6 00             ldab     0, x
A0B4:  18 E7 00          stab     0, y
A0B7:  F7 23 FE          stab     $23fe
A0BA:  1B                aba      
A0BB:  B7 23 FC          staa     $23fc
A0BE:  08                inx      
A0BF:  18 08             iny      
A0C1:  A6 00             ldaa     0, x
A0C3:  16                tab      
A0C4:  C4 40             andb     #64
A0C6:  27 13             beq      $a0db ; $A0DB=loc_A0DB
A0C8:  8A 80             oraa     #-128
A0CA:  18 A7 00          staa     0, y
A0CD:  36                psha     
A0CE:  BB 23 FC          adda     $23fc
A0D1:  B7 23 FC          staa     $23fc
A0D4:  32                pula     
A0D5:  08                inx      
A0D6:  18 08             iny      
A0D8:  7E A3 77          jmp      $a377 ; $A377=loc_A377

loc_A0DB:
A0DB:  81 00             cmpa     #0 ; xrefs $A0C6:branch
A0DD:  26 11             bne      $a0f0 ; $A0F0=loc_A0F0
A0DF:  8A 40             oraa     #64
A0E1:  18 A7 00          staa     0, y
A0E4:  BB 23 FC          adda     $23fc
A0E7:  B7 23 FC          staa     $23fc
A0EA:  08                inx      
A0EB:  18 08             iny      
A0ED:  7E A3 77          jmp      $a377 ; $A377=loc_A377

loc_A0F0:
A0F0:  81 01             cmpa     #1 ; xrefs $A0DD:branch
A0F2:  26 79             bne      $a16d ; $A16D=loc_A16D
A0F4:  8A 40             oraa     #64
A0F6:  18 A7 00          staa     0, y
A0F9:  BB 23 FC          adda     $23fc
A0FC:  B7 23 FC          staa     $23fc
A0FF:  08                inx      
A100:  18 08             iny      
A102:  A6 00             ldaa     0, x
A104:  B7 24 06          staa     $2406
A107:  18 A7 00          staa     0, y
A10A:  BB 23 FC          adda     $23fc
A10D:  B7 23 FC          staa     $23fc
A110:  08                inx      
A111:  18 08             iny      
A113:  A6 00             ldaa     0, x
A115:  18 A7 00          staa     0, y
A118:  36                psha     
A119:  BB 23 FC          adda     $23fc
A11C:  B7 23 FC          staa     $23fc
A11F:  32                pula     
A120:  7A 24 06          dec      $2406
A123:  08                inx      
A124:  18 08             iny      
A126:  E6 00             ldab     0, x
A128:  18 E7 00          stab     0, y
A12B:  08                inx      
A12C:  18 08             iny      
A12E:  37                pshb     
A12F:  FB 23 FC          addb     $23fc
A132:  F7 23 FC          stab     $23fc
A135:  33                pulb     
A136:  7A 24 06          dec      $2406

loc_A139:
A139:  1A 83 A0 25       cpd      #-24539 ; xrefs $A168:branch
A13D:  2D 06             blt      $a145 ; $A145=loc_A145
A13F:  1A 83 A0 3D       cpd      #-24515
A143:  2F 0D             ble      $a152 ; $A152=loc_A152

loc_A145:
A145:  18 3C             pshy      ; xrefs $A13D:branch
A147:  18 8F             xgdy     
A149:  A6 00             ldaa     0, x
A14B:  18 A7 00          staa     0, y
A14E:  18 8F             xgdy     
A150:  18 38             puly     

loc_A152:
A152:  3C                pshx      ; xrefs $A143:branch
A153:  8F                xgdx     
A154:  A6 00             ldaa     0, x
A156:  18 A7 00          staa     0, y
A159:  BB 23 FC          adda     $23fc
A15C:  B7 23 FC          staa     $23fc
A15F:  08                inx      
A160:  8F                xgdx     
A161:  38                pulx     
A162:  08                inx      
A163:  18 08             iny      
A165:  7A 24 06          dec      $2406
A168:  26 CF             bne      $a139 ; $A139=loc_A139
A16A:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A16D:
A16D:  81 02             cmpa     #2 ; xrefs $A0F2:branch
A16F:  26 6F             bne      $a1e0 ; $A1E0=loc_A1E0
A171:  8A 40             oraa     #64
A173:  18 A7 00          staa     0, y
A176:  BB 23 FC          adda     $23fc
A179:  B7 23 FC          staa     $23fc
A17C:  08                inx      
A17D:  18 08             iny      
A17F:  08                inx      
A180:  18 08             iny      
A182:  A6 00             ldaa     0, x
A184:  18 A7 00          staa     0, y
A187:  36                psha     
A188:  BB 23 FC          adda     $23fc
A18B:  B7 23 FC          staa     $23fc
A18E:  32                pula     
A18F:  08                inx      
A190:  18 08             iny      
A192:  E6 00             ldab     0, x
A194:  18 E7 00          stab     0, y
A197:  37                pshb     
A198:  FB 23 FC          addb     $23fc
A19B:  F7 23 FC          stab     $23fc
A19E:  33                pulb     
A19F:  08                inx      
A1A0:  18 08             iny      
A1A2:  37                pshb     
A1A3:  36                psha     
A1A4:  A6 00             ldaa     0, x
A1A6:  B7 24 08          staa     $2408
A1A9:  8B 02             adda     #2
A1AB:  18 3C             pshy     
A1AD:  18 CE 22 80       ldy      #8832
A1B1:  C6 04             ldab     #4
A1B3:  18 3A             aby      
A1B5:  18 A7 00          staa     0, y
A1B8:  BB 23 FC          adda     $23fc
A1BB:  B7 23 FC          staa     $23fc
A1BE:  18 38             puly     
A1C0:  38                pulx     
A1C1:  4F                clra     
A1C2:  B1 24 08          cmpa     $2408
A1C5:  26 03             bne      $a1ca ; $A1CA=loc_A1CA
A1C7:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A1CA:
A1CA:  A6 00             ldaa     0, x ; xrefs $A1C5:branch, $A1DB:branch
A1CC:  18 A7 00          staa     0, y
A1CF:  BB 23 FC          adda     $23fc
A1D2:  B7 23 FC          staa     $23fc
A1D5:  08                inx      
A1D6:  18 08             iny      
A1D8:  7A 24 08          dec      $2408
A1DB:  26 ED             bne      $a1ca ; $A1CA=loc_A1CA
A1DD:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A1E0:
A1E0:  81 03             cmpa     #3 ; xrefs $A16F:branch
A1E2:  26 6C             bne      $a250 ; $A250=loc_A250
A1E4:  8A 40             oraa     #64
A1E6:  18 A7 00          staa     0, y
A1E9:  BB 23 FC          adda     $23fc
A1EC:  B7 23 FC          staa     $23fc
A1EF:  08                inx      
A1F0:  18 08             iny      
A1F2:  3C                pshx     
A1F3:  CE 23 9A          ldx      #9114
A1F6:  FF 24 01          stx      $2401
A1F9:  FF 24 03          stx      $2403
A1FC:  38                pulx     
A1FD:  A6 00             ldaa     0, x
A1FF:  B7 24 06          staa     $2406
A202:  36                psha     
A203:  44                lsra     
A204:  B7 24 07          staa     $2407
A207:  32                pula     
A208:  18 A7 00          staa     0, y
A20B:  26 06             bne      $a213 ; $A213=loc_A213
A20D:  08                inx      
A20E:  18 08             iny      
A210:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A213:
A213:  BB 23 FC          adda     $23fc ; xrefs $A20B:branch
A216:  B7 23 FC          staa     $23fc
A219:  08                inx      
A21A:  18 08             iny      
A21C:  3C                pshx     
A21D:  CE 22 80          ldx      #8832
A220:  08                inx      
A221:  A6 00             ldaa     0, x
A223:  B7 24 05          staa     $2405
A226:  38                pulx     

loc_A227:
A227:  A6 00             ldaa     0, x ; xrefs $A24B:branch
A229:  18 A7 00          staa     0, y
A22C:  36                psha     
A22D:  BB 23 FC          adda     $23fc
A230:  B7 23 FC          staa     $23fc
A233:  32                pula     
A234:  08                inx      
A235:  18 08             iny      
A237:  18 3C             pshy     
A239:  18 FE 24 01       ldy      $2401
A23D:  18 A7 00          staa     0, y
A240:  18 08             iny      
A242:  18 FF 24 01       sty      $2401
A246:  18 38             puly     
A248:  7A 24 06          dec      $2406
A24B:  26 DA             bne      $a227 ; $A227=loc_A227
A24D:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A250:
A250:  81 05             cmpa     #5 ; xrefs $A1E2:branch
A252:  27 2D             beq      $a281 ; $A281=loc_A281
A254:  7F 00 F4          clr      >$00f4
A257:  7F 00 F5          clr      >$00f5
A25A:  14 F5 02          bset     $f5, #2
A25D:  14 F4 02          bset     $f4, #2
A260:  18 CE 22 00       ldy      #8704
A264:  18 FF 23 EE       sty      $23ee
A268:  18 FF 23 F0       sty      $23f0
A26C:  8A 80             oraa     #-128
A26E:  8A 40             oraa     #64
A270:  18 A7 00          staa     0, y
A273:  36                psha     
A274:  BB 23 FC          adda     $23fc
A277:  B7 23 FC          staa     $23fc
A27A:  32                pula     
A27B:  08                inx      
A27C:  18 08             iny      
A27E:  7E A3 77          jmp      $a377 ; $A377=loc_A377

loc_A281:
A281:  86 FF             ldaa     #-1 ; xrefs $A252:branch
A283:  B7 24 0A          staa     $240a
A286:  14 F7 01          bset     $f7, #1
A289:  08                inx      
A28A:  08                inx      
A28B:  A6 00             ldaa     0, x
A28D:  08                inx      
A28E:  E6 00             ldab     0, x
A290:  37                pshb     
A291:  36                psha     
A292:  08                inx      
A293:  A6 00             ldaa     0, x
A295:  08                inx      
A296:  81 FF             cmpa     #-1
A298:  27 29             beq      $a2c3 ; $A2C3=loc_A2C3
A29A:  81 00             cmpa     #0
A29C:  27 05             beq      $a2a3 ; $A2A3=loc_A2A3
A29E:  18 38             puly     
A2A0:  7E A2 E1          jmp      $a2e1 ; $A2E1=loc_A2E1

loc_A2A3:
A2A3:  18 38             puly      ; xrefs $A29C:branch
A2A5:  0C                clc      
A2A6:  E6 00             ldab     0, x
A2A8:  2B 0D             bmi      $a2b7 ; $A2B7=loc_A2B7
A2AA:  18 EB 00          addb     0, y
A2AD:  25 03             bcs      $a2b2 ; $A2B2=loc_A2B2
A2AF:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2B2:
A2B2:  C6 FF             ldab     #-1 ; xrefs $A2AD:branch
A2B4:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2B7:
A2B7:  18 EB 00          addb     0, y ; xrefs $A2A8:branch
A2BA:  22 03             bhi      $a2bf ; $A2BF=loc_A2BF
A2BC:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2BF:
A2BF:  5F                clrb      ; xrefs $A2BA:branch
A2C0:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2C3:
A2C3:  18 38             puly      ; xrefs $A298:branch
A2C5:  0C                clc      
A2C6:  E6 00             ldab     0, x
A2C8:  2B 0D             bmi      $a2d7 ; $A2D7=loc_A2D7
A2CA:  18 EB 00          addb     0, y
A2CD:  29 03             bvs      $a2d2 ; $A2D2=loc_A2D2
A2CF:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2D2:
A2D2:  C6 7F             ldab     #127 ; xrefs $A2CD:branch
A2D4:  7E A2 DE          jmp      $a2de ; $A2DE=loc_A2DE

loc_A2D7:
A2D7:  18 EB 00          addb     0, y ; xrefs $A2C8:branch
A2DA:  28 02             bvc      $a2de ; $A2DE=loc_A2DE
A2DC:  C6 80             ldab     #-128

loc_A2DE:
A2DE:  18 E7 00          stab     0, y ; xrefs $A2AF:jump, $A2B4:jump, $A2BC:jump, $A2C0:jump, $A2CF:jump, $A2D4:jump, $A2DA:branch

loc_A2E1:
A2E1:  CE 22 00          ldx      #8704 ; xrefs $A2A0:jump
A2E4:  FF 23 EE          stx      $23ee
A2E7:  FF 23 F0          stx      $23f0
A2EA:  86 02             ldaa     #2
A2EC:  97 F4             staa     $f4
A2EE:  97 F5             staa     $f5
A2F0:  7E A6 95          jmp      $a695 ; $A695=loc_A695

loc_A2F3:
A2F3:  CE 23 9A          ldx      #9114 ; xrefs $A058:jump
A2F6:  BC 24 01          cpx      $2401
A2F9:  26 03             bne      $a2fe ; $A2FE=loc_A2FE
A2FB:  7E A6 95          jmp      $a695 ; $A695=loc_A695

loc_A2FE:
A2FE:  13 F6 02 03       brclr    $f6, #2, $a305 ; $A305=loc_A305 | xrefs $A2F9:branch
A302:  7E A6 95          jmp      $a695 ; $A695=loc_A695

loc_A305:
A305:  B6 24 00          ldaa     $2400 ; xrefs $A2FE:branch
A308:  B7 24 0A          staa     $240a
A30B:  14 F7 01          bset     $f7, #1
A30E:  7F 00 F5          clr      >$00f5
A311:  18 CE 22 80       ldy      #8832
A315:  18 FF 23 F2       sty      $23f2
A319:  18 FF 23 F4       sty      $23f4
A31D:  FF 24 03          stx      $2403
A320:  86 16             ldaa     #22
A322:  18 A7 00          staa     0, y
A325:  18 08             iny      
A327:  B6 24 05          ldaa     $2405
A32A:  18 A7 00          staa     0, y
A32D:  B7 23 FC          staa     $23fc
A330:  18 08             iny      
A332:  4F                clra     
A333:  18 A7 00          staa     0, y
A336:  18 08             iny      
A338:  8A 40             oraa     #64
A33A:  8A 04             oraa     #4
A33C:  18 A7 00          staa     0, y
A33F:  BB 23 FC          adda     $23fc
A342:  B7 23 FC          staa     $23fc
A345:  18 08             iny      
A347:  B6 24 07          ldaa     $2407
A34A:  18 A7 00          staa     0, y
A34D:  B7 24 06          staa     $2406
A350:  BB 23 FC          adda     $23fc
A353:  B7 23 FC          staa     $23fc
A356:  18 08             iny      

loc_A358:
A358:  A6 00             ldaa     0, x ; xrefs $A372:branch
A35A:  08                inx      
A35B:  E6 00             ldab     0, x
A35D:  08                inx      
A35E:  3C                pshx     
A35F:  8F                xgdx     
A360:  A6 00             ldaa     0, x
A362:  18 A7 00          staa     0, y
A365:  BB 23 FC          adda     $23fc
A368:  B7 23 FC          staa     $23fc
A36B:  18 08             iny      
A36D:  8F                xgdx     
A36E:  38                pulx     
A36F:  7A 24 06          dec      $2406
A372:  26 E4             bne      $a358 ; $A358=loc_A358
A374:  7E A3 9F          jmp      $a39f ; $A39F=loc_A39F

loc_A377:
A377:  A6 00             ldaa     0, x ; xrefs $A0D8:jump, $A0ED:jump, $A27E:jump
A379:  18 A7 00          staa     0, y
A37C:  36                psha     
A37D:  BB 23 FC          adda     $23fc
A380:  B7 23 FC          staa     $23fc
A383:  32                pula     
A384:  08                inx      
A385:  18 08             iny      
A387:  B7 24 06          staa     $2406
A38A:  27 13             beq      $a39f ; $A39F=loc_A39F

loc_A38C:
A38C:  A6 00             ldaa     0, x ; xrefs $A39D:branch
A38E:  18 A7 00          staa     0, y
A391:  BB 23 FC          adda     $23fc
A394:  B7 23 FC          staa     $23fc
A397:  08                inx      
A398:  18 08             iny      
A39A:  7A 24 06          dec      $2406
A39D:  26 ED             bne      $a38c ; $A38C=loc_A38C

loc_A39F:
A39F:  B6 23 FC          ldaa     $23fc ; xrefs $A16A:jump, $A1C7:jump, $A1DD:jump, $A210:jump, $A24D:jump, $A374:jump, $A38A:branch
A3A2:  18 A7 00          staa     0, y
A3A5:  18 08             iny      
A3A7:  18 FF 23 F2       sty      $23f2
A3AB:  CE 22 80          ldx      #8832
A3AE:  FF 23 F4          stx      $23f4
A3B1:  F6 10 2E          ldab     $102e ; $102E=SCSR
A3B4:  A6 00             ldaa     0, x
A3B6:  13 F7 01 0D       brclr    $f7, #1, $a3c7 ; $A3C7=loc_A3C7
A3BA:  12 F4 02 09       brset    $f4, #2, $a3c7 ; $A3C7=loc_A3C7
A3BE:  7F 00 F5          clr      >$00f5
A3C1:  14 F5 02          bset     $f5, #2
A3C4:  7E A6 95          jmp      $a695 ; $A695=loc_A695

loc_A3C7:
A3C7:  7F 00 F5          clr      >$00f5 ; xrefs $A3B6:branch, $A3BA:branch
A3CA:  C6 09             ldab     #9
A3CC:  F7 24 14          stab     $2414
A3CF:  B7 10 2F          staa     $102f ; $102F=SCDR
A3D2:  B6 23 FF          ldaa     $23ff
A3D5:  B7 24 09          staa     $2409
A3D8:  14 F6 01          bset     $f6, #1
A3DB:  7E A6 95          jmp      $a695 ; $A695=loc_A695

sub_A3DE:
A3DE:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $D5B3:call
A3E1:  81 01             cmpa     #1
A3E3:  26 03             bne      $a3e8 ; $A3E8=loc_A3E8
A3E5:  7E A0 3D          jmp      $a03d ; $A03D=loc_A03D

loc_A3E8:
A3E8:  81 02             cmpa     #2 ; xrefs $A3E3:branch
A3EA:  26 03             bne      $a3ef ; $A3EF=loc_A3EF
A3EC:  7E A0 3D          jmp      $a03d ; $A03D=loc_A03D

loc_A3EF:
A3EF:  12 F5 01 0E       brset    $f5, #1, $a401 ; $A401=loc_A401 | xrefs $A3EA:branch
A3F3:  12 F5 02 0D       brset    $f5, #2, $a404 ; $A404=loc_A404
A3F7:  B6 23 F5          ldaa     $23f5
A3FA:  B0 23 F3          suba     $23f3
A3FD:  81 10             cmpa     #16
A3FF:  24 03             bcc      $a404 ; $A404=loc_A404

loc_A401:
A401:  7E A6 81          jmp      $a681 ; $A681=loc_A681 | xrefs $A3EF:branch

loc_A404:
A404:  12 F4 02 15       brset    $f4, #2, $a41d ; $A41D=loc_A41D | xrefs $A3F3:branch, $A3FF:branch, $A43B:jump
A408:  12 F4 01 32       brset    $f4, #1, $a43e ; $A43E=loc_A43E
A40C:  B6 23 EF          ldaa     $23ef
A40F:  B0 23 F1          suba     $23f1
A412:  26 05             bne      $a419 ; $A419=loc_A419
A414:  14 F4 02          bset     $f4, #2
A417:  20 04             bra      $a41d ; $A41D=loc_A41D

loc_A419:
A419:  81 10             cmpa     #16 ; xrefs $A412:branch
A41B:  24 21             bcc      $a43e ; $A43E=loc_A43E

loc_A41D:
A41D:  7E A6 95          jmp      $a695 ; $A695=loc_A695 | xrefs $A404:branch, $A417:branch

loc_A420:
A420:  C6 01             ldab     #1 ; xrefs $A455:branch
A422:  20 09             bra      $a42d ; $A42D=loc_A42D

loc_A424:
A424:  C6 02             ldab     #2 ; xrefs $A485:branch
A426:  20 02             bra      $a42a ; $A42A=loc_A42A

loc_A428:
A428:  C6 03             ldab     #3 ; xrefs $A4BB:jump

loc_A42A:
A42A:  7C 23 F1          inc      $23f1 ; xrefs $A426:branch

loc_A42D:
A42D:  7C 23 F1          inc      $23f1 ; xrefs $A422:branch
A430:  B6 23 FB          ldaa     $23fb
A433:  26 03             bne      $a438 ; $A438=loc_A438
A435:  F7 23 FB          stab     $23fb

loc_A438:
A438:  15 F4 01          bclr     $f4, #1 ; xrefs $A433:branch
A43B:  7E A4 04          jmp      $a404 ; $A404=loc_A404

loc_A43E:
A43E:  18 FE 23 F2       ldy      $23f2 ; xrefs $A408:branch, $A41B:branch
A442:  FE 23 F0          ldx      $23f0
A445:  C6 16             ldab     #22
A447:  A6 00             ldaa     0, x
A449:  18 E7 00          stab     0, y
A44C:  8F                xgdx     
A44D:  5C                incb     
A44E:  8F                xgdx     
A44F:  18 8F             xgdy     
A451:  5C                incb     
A452:  18 8F             xgdy     
A454:  11                cba      
A455:  26 C9             bne      $a420 ; $A420=loc_A420
A457:  E6 00             ldab     0, x
A459:  86 10             ldaa     #16
A45B:  3D                mul      
A45C:  8B 10             adda     #16
A45E:  18 A7 00          staa     0, y
A461:  B7 23 FC          staa     $23fc
A464:  81 13             cmpa     #19
A466:  27 04             beq      $a46c ; $A46C=loc_A46C
A468:  81 12             cmpa     #18
A46A:  26 05             bne      $a471 ; $A471=loc_A471

loc_A46C:
A46C:  14 B0 40          bset     $b0, #64 ; xrefs $A466:branch
A46F:  20 06             bra      $a477 ; $A477=loc_A477

loc_A471:
A471:  15 B0 40          bclr     $b0, #64 ; xrefs $A46A:branch
A474:  15 AF 80          bclr     $af, #-128

loc_A477:
A477:  A6 00             ldaa     0, x ; xrefs $A46F:branch
A479:  8F                xgdx     
A47A:  5C                incb     
A47B:  8F                xgdx     
A47C:  18 8F             xgdy     
A47E:  5C                incb     
A47F:  18 8F             xgdy     
A481:  C4 F0             andb     #-16
A483:  C8 10             eorb     #16
A485:  26 9D             bne      $a424 ; $A424=loc_A424
A487:  E6 00             ldab     0, x
A489:  18 E7 00          stab     0, y
A48C:  F7 23 FE          stab     $23fe
A48F:  1B                aba      
A490:  FB 23 FC          addb     $23fc
A493:  F7 23 FC          stab     $23fc
A496:  8F                xgdx     
A497:  5C                incb     
A498:  8F                xgdx     
A499:  18 8F             xgdy     
A49B:  5C                incb     
A49C:  18 8F             xgdy     
A49E:  C6 0C             ldab     #12
A4A0:  F7 23 FA          stab     $23fa

loc_A4A3:
A4A3:  E6 00             ldab     0, x ; xrefs $A4B4:branch
A4A5:  18 E7 00          stab     0, y
A4A8:  1B                aba      
A4A9:  8F                xgdx     
A4AA:  5C                incb     
A4AB:  8F                xgdx     
A4AC:  18 8F             xgdy     
A4AE:  5C                incb     
A4AF:  18 8F             xgdy     
A4B1:  7A 23 FA          dec      $23fa
A4B4:  26 ED             bne      $a4a3 ; $A4A3=loc_A4A3
A4B6:  E6 00             ldab     0, x
A4B8:  11                cba      
A4B9:  27 03             beq      $a4be ; $A4BE=loc_A4BE
A4BB:  7E A4 28          jmp      $a428 ; $A428=loc_A428

loc_A4BE:
A4BE:  5F                clrb      ; xrefs $A4B9:branch
A4BF:  F7 23 FB          stab     $23fb
A4C2:  8F                xgdx     
A4C3:  5C                incb     
A4C4:  8F                xgdx     
A4C5:  FF 23 F0          stx      $23f0
A4C8:  13 B0 40 13       brclr    $b0, #64, $a4df ; $A4DF=loc_A4DF
A4CC:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
A4CF:  81 FF             cmpa     #-1
A4D1:  27 09             beq      $a4dc ; $A4DC=loc_A4DC
A4D3:  81 07             cmpa     #7
A4D5:  25 05             bcs      $a4dc ; $A4DC=loc_A4DC
A4D7:  15 AF 80          bclr     $af, #-128
A4DA:  20 03             bra      $a4df ; $A4DF=loc_A4DF

loc_A4DC:
A4DC:  14 AF 80          bset     $af, #-128 ; xrefs $A4D1:branch, $A4D5:branch

loc_A4DF:
A4DF:  FC 23 F2          ldd      $23f2 ; xrefs $A4C8:branch, $A4DA:branch
A4E2:  CB 03             addb     #3
A4E4:  8F                xgdx     
A4E5:  A6 00             ldaa     0, x
A4E7:  16                tab      
A4E8:  FB 23 FC          addb     $23fc
A4EB:  F7 23 FC          stab     $23fc
A4EE:  8F                xgdx     
A4EF:  5C                incb     
A4F0:  8F                xgdx     
A4F1:  81 00             cmpa     #0
A4F3:  27 47             beq      $a53c ; $A53C=loc_A53C
A4F5:  4A                deca     
A4F6:  26 03             bne      $a4fb ; $A4FB=loc_A4FB
A4F8:  7E A5 6F          jmp      $a56f ; $A56F=loc_A56F

loc_A4FB:
A4FB:  4A                deca      ; xrefs $A4F6:branch
A4FC:  27 18             beq      $a516 ; $A516=loc_A516
A4FE:  4A                deca     
A4FF:  27 23             beq      $a524 ; $A524=loc_A524
A501:  4A                deca     
A502:  26 03             bne      $a507 ; $A507=loc_A507

loc_A504:
A504:  7E A5 BA          jmp      $a5ba ; $A5BA=loc_A5BA | xrefs $A538:branch

loc_A507:
A507:  4A                deca      ; xrefs $A502:branch
A508:  26 03             bne      $a50d ; $A50D=loc_A50D
A50A:  7E A5 30          jmp      $a530 ; $A530=loc_A530

loc_A50D:
A50D:  86 FF             ldaa     #-1 ; xrefs $A508:branch

loc_A50F:
A50F:  7E A5 E0          jmp      $a5e0 ; $A5E0=loc_A5E0 | xrefs $A514:branch, $A52E:branch, $A53A:branch

loc_A512:
A512:  86 02             ldaa     #2 ; xrefs $A51A:branch, $A51F:branch
A514:  20 F9             bra      $a50f ; $A50F=loc_A50F

loc_A516:
A516:  C6 FF             ldab     #-1 ; xrefs $A4FC:branch
A518:  E1 00             cmpb     0, x
A51A:  26 F6             bne      $a512 ; $A512=loc_A512
A51C:  F6 23 FE          ldab     $23fe
A51F:  26 F1             bne      $a512 ; $A512=loc_A512

loc_A521:
A521:  7E A5 9B          jmp      $a59b ; $A59B=loc_A59B | xrefs $A52C:branch

loc_A524:
A524:  C6 07             ldab     #7 ; xrefs $A4FF:branch
A526:  F7 23 FD          stab     $23fd
A529:  BD A6 19          jsr      $a619 ; $A619=sub_A619
A52C:  27 F3             beq      $a521 ; $A521=loc_A521
A52E:  20 DF             bra      $a50f ; $A50F=loc_A50F

loc_A530:
A530:  C6 00             ldab     #0 ; xrefs $A50A:jump
A532:  F7 23 FD          stab     $23fd
A535:  BD A6 19          jsr      $a619 ; $A619=sub_A619
A538:  27 CA             beq      $a504 ; $A504=loc_A504
A53A:  20 D3             bra      $a50f ; $A50F=loc_A50F

loc_A53C:
A53C:  C6 07             ldab     #7 ; xrefs $A4F3:branch
A53E:  F7 23 FD          stab     $23fd
A541:  BD A6 19          jsr      $a619 ; $A619=sub_A619
A544:  27 03             beq      $a549 ; $A549=loc_A549
A546:  7E A5 E0          jmp      $a5e0 ; $A5E0=loc_A5E0

loc_A549:
A549:  BD A5 F7          jsr      $a5f7 ; $A5F7=sub_A5F7 | xrefs $A544:branch
A54C:  C6 08             ldab     #8
A54E:  F7 23 FA          stab     $23fa

loc_A551:
A551:  18 FE 23 F6       ldy      $23f6 ; xrefs $A56A:branch
A555:  E6 00             ldab     0, x
A557:  18 3A             aby      
A559:  18 A6 00          ldaa     0, y
A55C:  A7 00             staa     0, x
A55E:  BB 23 FC          adda     $23fc
A561:  B7 23 FC          staa     $23fc
A564:  8F                xgdx     
A565:  5C                incb     
A566:  8F                xgdx     
A567:  7A 23 FA          dec      $23fa
A56A:  26 E5             bne      $a551 ; $A551=loc_A551
A56C:  7E A6 6B          jmp      $a66b ; $A66B=loc_A66B

loc_A56F:
A56F:  C6 07             ldab     #7 ; xrefs $A4F8:jump
A571:  F7 23 FD          stab     $23fd
A574:  BD A6 19          jsr      $a619 ; $A619=sub_A619
A577:  27 03             beq      $a57c ; $A57C=loc_A57C
A579:  7E A5 E0          jmp      $a5e0 ; $A5E0=loc_A5E0

loc_A57C:
A57C:  BD A5 F7          jsr      $a5f7 ; $A5F7=sub_A5F7 | xrefs $A577:branch
A57F:  18 FE 23 F6       ldy      $23f6
A583:  C6 08             ldab     #8

loc_A585:
A585:  18 A6 00          ldaa     0, y ; xrefs $A596:branch
A588:  18 08             iny      
A58A:  A7 00             staa     0, x
A58C:  8F                xgdx     
A58D:  5C                incb     
A58E:  8F                xgdx     
A58F:  BB 23 FC          adda     $23fc
A592:  B7 23 FC          staa     $23fc
A595:  5A                decb     
A596:  26 ED             bne      $a585 ; $A585=loc_A585
A598:  7E A6 6B          jmp      $a66b ; $A66B=loc_A66B

loc_A59B:
A59B:  BD A5 F7          jsr      $a5f7 ; $A5F7=sub_A5F7 | xrefs $A521:jump
A59E:  18 FE 23 F6       ldy      $23f6
A5A2:  C6 08             ldab     #8

loc_A5A4:
A5A4:  A6 00             ldaa     0, x ; xrefs $A5B5:branch
A5A6:  18 A7 00          staa     0, y
A5A9:  BB 23 FC          adda     $23fc
A5AC:  B7 23 FC          staa     $23fc
A5AF:  8F                xgdx     
A5B0:  5C                incb     
A5B1:  8F                xgdx     
A5B2:  18 08             iny      
A5B4:  5A                decb     
A5B5:  26 ED             bne      $a5a4 ; $A5A4=loc_A5A4
A5B7:  7E A6 6B          jmp      $a66b ; $A66B=loc_A66B

loc_A5BA:
A5BA:  BD A5 F7          jsr      $a5f7 ; $A5F7=sub_A5F7 | xrefs $A504:jump
A5BD:  18 FE 23 F6       ldy      $23f6
A5C1:  E6 00             ldab     0, x
A5C3:  8F                xgdx     
A5C4:  5C                incb     
A5C5:  8F                xgdx     
A5C6:  18 E7 00          stab     0, y
A5C9:  FB 23 FC          addb     $23fc
A5CC:  F7 23 FC          stab     $23fc
A5CF:  4F                clra     
A5D0:  C6 07             ldab     #7

loc_A5D2:
A5D2:  A7 00             staa     0, x ; xrefs $A5D8:branch
A5D4:  8F                xgdx     
A5D5:  5C                incb     
A5D6:  8F                xgdx     
A5D7:  5A                decb     
A5D8:  26 F8             bne      $a5d2 ; $A5D2=loc_A5D2
A5DA:  B6 23 FC          ldaa     $23fc
A5DD:  7E A6 6B          jmp      $a66b ; $A66B=loc_A66B

loc_A5E0:
A5E0:  8B 10             adda     #16 ; xrefs $A50F:jump, $A546:jump, $A579:jump
A5E2:  A7 00             staa     0, x
A5E4:  8F                xgdx     
A5E5:  5C                incb     
A5E6:  8F                xgdx     
A5E7:  BB 23 FC          adda     $23fc
A5EA:  C6 0A             ldab     #10

loc_A5EC:
A5EC:  AB 00             adda     0, x ; xrefs $A5F2:branch
A5EE:  8F                xgdx     
A5EF:  5C                incb     
A5F0:  8F                xgdx     
A5F1:  5A                decb     
A5F2:  26 F8             bne      $a5ec ; $A5EC=loc_A5EC
A5F4:  7E A6 6B          jmp      $a66b ; $A66B=loc_A66B

sub_A5F7:
A5F7:  86 10             ldaa     #16 ; xrefs $A549:call, $A57C:call, $A59B:call, $A5BA:call
A5F9:  A7 00             staa     0, x
A5FB:  BB 23 FC          adda     $23fc
A5FE:  B7 23 FC          staa     $23fc
A601:  8F                xgdx     
A602:  5C                incb     
A603:  8F                xgdx     
A604:  E6 00             ldab     0, x
A606:  8F                xgdx     
A607:  5C                incb     
A608:  8F                xgdx     
A609:  A6 00             ldaa     0, x
A60B:  8F                xgdx     
A60C:  5C                incb     
A60D:  8F                xgdx     
A60E:  FD 23 F6          std      $23f6
A611:  1B                aba      
A612:  BB 23 FC          adda     $23fc
A615:  B7 23 FC          staa     $23fc
A618:  39                rts      

sub_A619:
A619:  FF 23 F6          stx      $23f6 ; xrefs $A529:call, $A535:call, $A541:call, $A574:call
A61C:  B6 80 07          ldaa     $8007
A61F:  81 DE             cmpa     #-34
A621:  26 03             bne      $a626 ; $A626=loc_A626
A623:  7E A6 61          jmp      $a661 ; $A661=loc_A661

loc_A626:
A626:  8F                xgdx      ; xrefs $A621:branch
A627:  5C                incb     
A628:  8F                xgdx     
A629:  E6 00             ldab     0, x
A62B:  8F                xgdx     
A62C:  5C                incb     
A62D:  8F                xgdx     
A62E:  A6 00             ldaa     0, x
A630:  FD 23 F8          std      $23f8
A633:  C6 06             ldab     #6
A635:  F7 23 FA          stab     $23fa
A638:  18 CE A0 25       ldy      #-24539

loc_A63C:
A63C:  FE 23 F8          ldx      $23f8 ; xrefs $A65F:branch
A63F:  CD AC 00          cpx      0, y
A642:  25 09             bcs      $a64d ; $A64D=loc_A64D
A644:  27 1E             beq      $a664 ; $A664=loc_A664
A646:  CD AC 02          cpx      2, y
A649:  22 0D             bhi      $a658 ; $A658=loc_A658
A64B:  20 17             bra      $a664 ; $A664=loc_A664

loc_A64D:
A64D:  F6 23 FD          ldab     $23fd ; xrefs $A642:branch
A650:  3A                abx      
A651:  CD AC 00          cpx      0, y
A654:  25 0B             bcs      $a661 ; $A661=loc_A661
A656:  20 0C             bra      $a664 ; $A664=loc_A664

loc_A658:
A658:  C6 04             ldab     #4 ; xrefs $A649:branch
A65A:  18 3A             aby      
A65C:  7A 23 FA          dec      $23fa
A65F:  2E DB             bgt      $a63c ; $A63C=loc_A63C

loc_A661:
A661:  4F                clra      ; xrefs $A623:jump, $A654:branch
A662:  20 02             bra      $a666 ; $A666=loc_A666

loc_A664:
A664:  86 0F             ldaa     #15 ; xrefs $A644:branch, $A64B:branch, $A656:branch

loc_A666:
A666:  FE 23 F6          ldx      $23f6 ; xrefs $A662:branch
A669:  4D                tsta     
A66A:  39                rts      

loc_A66B:
A66B:  A7 00             staa     0, x ; xrefs $A56C:jump, $A598:jump, $A5B7:jump, $A5DD:jump, $A5F4:jump
A66D:  8F                xgdx     
A66E:  5C                incb     
A66F:  8F                xgdx     
A670:  FF 23 F2          stx      $23f2
A673:  15 F4 01          bclr     $f4, #1
A676:  B6 23 EF          ldaa     $23ef
A679:  B0 23 F1          suba     $23f1
A67C:  26 03             bne      $a681 ; $A681=loc_A681
A67E:  14 F4 02          bset     $f4, #2

loc_A681:
A681:  15 F5 02          bclr     $f5, #2 ; xrefs $A401:jump, $A67C:branch
A684:  CE 10 00          ldx      #4096
A687:  1C 2D 40          bset     45, x; #64
A68A:  B6 23 F5          ldaa     $23f5
A68D:  B0 23 F3          suba     $23f3
A690:  26 03             bne      $a695 ; $A695=loc_A695
A692:  14 F5 01          bset     $f5, #1

loc_A695:
A695:  39                rts       ; xrefs $A06C:jump, $A0A1:jump, $A2F0:jump, $A2FB:jump, $A302:jump, $A3C4:jump, $A3DB:jump, $A41D:jump, +1 more

; [STRONG] Initialize SCI diagnostic mode from calibration/config bytes 0x8009/0x800B.
sci_mode_init:
A696:  4F                clra      ; xrefs $B896:call
A697:  5F                clrb     
A698:  97 B0             staa     $b0
A69A:  97 AF             staa     $af
A69C:  B7 21 A4          staa     $21a4
A69F:  B7 21 A7          staa     $21a7
A6A2:  18 CE 21 A9       ldy      #8617
A6A6:  18 ED 01          std      1, y
A6A9:  18 ED 03          std      3, y
A6AC:  18 ED 05          std      5, y
A6AF:  CE 10 00          ldx      #4096
A6B2:  B6 80 0B          ldaa     $800b
A6B5:  26 13             bne      $a6ca ; $A6CA=loc_A6CA
A6B7:  86 00             ldaa     #0
A6B9:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
A6BC:  B6 80 09          ldaa     $8009
A6BF:  B7 10 2B          staa     $102b ; $102B=BAUD
A6C2:  7F 24 15          clr      $2415
A6C5:  1C 2D 08          bset     45, x; #8
A6C8:  20 1A             bra      $a6e4 ; $A6E4=loc_A6E4

loc_A6CA:
A6CA:  14 AF 21          bset     $af, #33 ; xrefs $A6B5:branch
A6CD:  1E 60 20 08       brset    96, x; #32; $a6d9 ; $A6D9=loc_A6D9
A6D1:  15 B0 04          bclr     $b0, #4
A6D4:  14 AF 02          bset     $af, #2
A6D7:  20 06             bra      $a6df ; $A6DF=loc_A6DF

loc_A6D9:
A6D9:  14 B0 04          bset     $b0, #4 ; xrefs $A6CD:branch
A6DC:  14 AF 08          bset     $af, #8

loc_A6DF:
A6DF:  86 FF             ldaa     #-1 ; xrefs $A6D7:branch
A6E1:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector

loc_A6E4:
A6E4:  39                rts       ; xrefs $A6C8:branch

; [STRONG] Initialize SCI/service buffers and packet state.
sci_buffers_init:
A6E5:  4F                clra      ; xrefs $B893:call
A6E6:  B7 24 15          staa     $2415
A6E9:  B7 24 14          staa     $2414
A6EC:  B7 24 13          staa     $2413
A6EF:  B7 24 21          staa     $2421
A6F2:  B7 21 BE          staa     $21be
A6F5:  B7 21 BF          staa     $21bf
A6F8:  B7 24 20          staa     $2420
A6FB:  B7 21 C0          staa     $21c0
A6FE:  97 F6             staa     $f6
A700:  96 8B             ldaa     $8b
A702:  B7 21 BC          staa     $21bc
A705:  CE 22 80          ldx      #8832
A708:  FF 23 F2          stx      $23f2
A70B:  FF 23 F4          stx      $23f4
A70E:  CE 22 00          ldx      #8704
A711:  FF 23 EE          stx      $23ee
A714:  FF 23 F0          stx      $23f0
A717:  CE 23 9A          ldx      #9114
A71A:  FF 24 01          stx      $2401
A71D:  FF 24 03          stx      $2403
A720:  86 02             ldaa     #2
A722:  97 F5             staa     $f5
A724:  97 F4             staa     $f4
A726:  86 0F             ldaa     #15
A728:  B7 23 FB          staa     $23fb
A72B:  86 00             ldaa     #0
A72D:  B7 10 2C          staa     $102c ; $102C=SCCR1
A730:  86 24             ldaa     #36
A732:  B7 10 2D          staa     $102d ; $102D=SCCR2
A735:  14 AF 01          bset     $af, #1
A738:  CE 10 00          ldx      #4096
A73B:  1C 08 02          bset     8, x; #2
A73E:  86 33             ldaa     #51
A740:  B7 10 2B          staa     $102b ; $102B=BAUD
A743:  B6 A0 22          ldaa     $a022
A746:  B7 23 FF          staa     $23ff
A749:  B7 24 09          staa     $2409
A74C:  B6 A0 23          ldaa     $a023
A74F:  B7 24 00          staa     $2400
A752:  B7 24 0A          staa     $240a
A755:  14 AF 01          bset     $af, #1
A758:  39                rts      

sub_A759:
A759:  12 F6 01 0F       brset    $f6, #1, $a76c ; $A76C=loc_A76C | xrefs $9EC5:call
A75D:  13 F6 02 16       brclr    $f6, #2, $a777 ; $A777=loc_A777
A761:  7A 24 0A          dec      $240a
A764:  26 11             bne      $a777 ; $A777=loc_A777
A766:  15 F6 02          bclr     $f6, #2
A769:  7E A7 77          jmp      $a777 ; $A777=loc_A777

loc_A76C:
A76C:  7A 24 09          dec      $2409 ; xrefs $A759:branch
A76F:  26 06             bne      $a777 ; $A777=loc_A777
A771:  15 F6 01          bclr     $f6, #1
A774:  14 F6 80          bset     $f6, #-128

loc_A777:
A777:  39                rts       ; xrefs $A75D:branch, $A764:branch, $A769:jump, $A76F:branch

; ---- unreached/data gap $A778-$A7DD ----

        .org $A7DE
A7DE:  FC 10 0E          ldd      $100e ; $100E=TCNT
A7E1:  FD 24 0B          std      $240b
A7E4:  CE 10 00          ldx      #4096
A7E7:  18 CE 00 00       ldy      #0
A7EB:  1F 2E 20 14       brclr    46, x; #32; $a803 ; $A803=loc_A803
A7EF:  36                psha     
A7F0:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
A7F3:  81 01             cmpa     #1
A7F5:  27 08             beq      $a7ff ; $A7FF=loc_A7FF
A7F7:  81 02             cmpa     #2
A7F9:  27 04             beq      $a7ff ; $A7FF=loc_A7FF
A7FB:  32                pula     
A7FC:  7E A9 EB          jmp      $a9eb ; $A9EB=loc_A9EB

loc_A7FF:
A7FF:  32                pula      ; xrefs $A7F5:branch, $A7F9:branch
A800:  7E AE 77          jmp      $ae77 ; $AE77=loc_AE77

loc_A803:
A803:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $A7EB:branch
A806:  81 05             cmpa     #5
A808:  27 2B             beq      $a835 ; $A835=loc_A835
A80A:  81 0D             cmpa     #13
A80C:  27 27             beq      $a835 ; $A835=loc_A835
A80E:  81 06             cmpa     #6
A810:  26 03             bne      $a815 ; $A815=loc_A815
A812:  7E D9 83          jmp      $d983 ; $D983=loc_D983

loc_A815:
A815:  F6 21 BD          ldab     $21bd ; xrefs $A810:branch
A818:  36                psha     
A819:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
A81C:  81 01             cmpa     #1
A81E:  32                pula     
A81F:  27 0D             beq      $a82e ; $A82E=loc_A82E
A821:  36                psha     
A822:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
A825:  81 02             cmpa     #2
A827:  32                pula     
A828:  27 04             beq      $a82e ; $A82E=loc_A82E
A82A:  C1 0D             cmpb     #13
A82C:  27 07             beq      $a835 ; $A835=loc_A835

loc_A82E:
A82E:  13 F5 02 03       brclr    $f5, #2, $a835 ; $A835=loc_A835 | xrefs $A81F:branch, $A828:branch
A832:  7E A9 E4          jmp      $a9e4 ; $A9E4=loc_A9E4

loc_A835:
A835:  36                psha      ; xrefs $A808:branch, $A80C:branch, $A82C:branch, $A82E:branch
A836:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
A839:  81 01             cmpa     #1
A83B:  27 0A             beq      $a847 ; $A847=loc_A847
A83D:  81 02             cmpa     #2
A83F:  27 06             beq      $a847 ; $A847=loc_A847
A841:  32                pula     
A842:  CE A7 78          ldx      #-22664
A845:  20 04             bra      $a84b ; $A84B=loc_A84B

loc_A847:
A847:  32                pula      ; xrefs $A83B:branch, $A83F:branch
A848:  CE A7 A6          ldx      #-22618

loc_A84B:
A84B:  F6 24 15          ldab     $2415 ; xrefs $A845:branch
A84E:  0C                clc      
A84F:  59                rolb     
A850:  3A                abx      
A851:  EE 00             ldx      0, x
A853:  6E 00             jmp      0, x

; ---- unreached/data gap $A855-$A9E3 ----

        .org $A9E4

loc_A9E4:
A9E4:  CE 10 00          ldx      #4096 ; xrefs $A832:jump
A9E7:  1D 2D 40          bclr     45, x; #64
A9EA:  3B                rti      

loc_A9EB:
A9EB:  F6 21 A6          ldab     $21a6 ; $21A6=operating_state_selector | xrefs $A7FC:jump
A9EE:  C1 06             cmpb     #6
A9F0:  26 03             bne      $a9f5 ; $A9F5=loc_A9F5
A9F2:  7E E1 64          jmp      $e164 ; $E164=loc_E164

loc_A9F5:
A9F5:  B6 10 2F          ldaa     $102f ; $102F=SCDR | xrefs $A9F0:branch
A9F8:  C1 05             cmpb     #5
A9FA:  26 03             bne      $a9ff ; $A9FF=loc_A9FF
A9FC:  7E AB 5C          jmp      $ab5c ; $AB5C=loc_AB5C

loc_A9FF:
A9FF:  C1 0D             cmpb     #13 ; xrefs $A9FA:branch
AA01:  26 03             bne      $aa06 ; $AA06=loc_AA06
AA03:  7E AB 5C          jmp      $ab5c ; $AB5C=loc_AB5C

loc_AA06:
AA06:  12 AF 01 03       brset    $af, #1, $aa0d ; $AA0D=loc_AA0D | xrefs $AA01:branch
AA0A:  7E AB 52          jmp      $ab52 ; $AB52=loc_AB52

loc_AA0D:
AA0D:  CE A7 D8          ldx      #-22568 ; xrefs $AA06:branch, $AE92:jump, $AE9F:jump
AA10:  F6 24 13          ldab     $2413
AA13:  0C                clc      
AA14:  59                rolb     
AA15:  3A                abx      
AA16:  EE 00             ldx      0, x
AA18:  6E 00             jmp      0, x

; ---- unreached/data gap $AA1A-$AACF ----

        .org $AAD0

; [STRONG] SCI/service dispatch path that can jump to hardware service initialization at 0x4F10.
sci_service_dispatch_aad0:
AAD0:  7E 4F 10          jmp      $4f10 ; $4F10=hardware_io_service_init

; ---- unreached/data gap $AAD3-$AADF ----

        .org $AAE0

; [CONFIRMED] Special SCI response/service entry: sets mode 0x06, stack 0x916A, then jumps to 0xD80B.
sci_service_55_entry:
AAE0:  0B                sev      
AAE1:  86 06             ldaa     #6
AAE3:  B7 21 A6          staa     $21a6 ; $21A6=operating_state_selector
AAE6:  BE 91 6A          lds      $916a ; $916A=expected_stack_top
AAE9:  7E D8 0B          jmp      $d80b ; $D80B=loc_D80B

; ---- unreached/data gap $AAEC-$AB51 ----

        .org $AB52

loc_AB52:
AB52:  13 F4 01 03       brclr    $f4, #1, $ab59 ; $AB59=loc_AB59 | xrefs $AA0A:jump
AB56:  7E AE 70          jmp      $ae70 ; $AE70=loc_AE70

loc_AB59:
AB59:  15 F4 02          bclr     $f4, #2 ; xrefs $AB52:branch

loc_AB5C:
AB5C:  36                psha      ; xrefs $A9FC:jump, $AA03:jump, $AE8B:jump, $AE99:jump
AB5D:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
AB60:  81 01             cmpa     #1
AB62:  27 0A             beq      $ab6e ; $AB6E=loc_AB6E
AB64:  81 02             cmpa     #2
AB66:  27 06             beq      $ab6e ; $AB6E=loc_AB6E
AB68:  32                pula     
AB69:  CE A7 92          ldx      #-22638
AB6C:  20 04             bra      $ab72 ; $AB72=loc_AB72

loc_AB6E:
AB6E:  32                pula      ; xrefs $AB62:branch, $AB66:branch
AB6F:  CE A7 C0          ldx      #-22592

loc_AB72:
AB72:  F6 24 14          ldab     $2414 ; xrefs $AB6C:branch
AB75:  0C                clc      
AB76:  59                rolb     
AB77:  3A                abx      
AB78:  EE 00             ldx      0, x
AB7A:  6E 00             jmp      0, x

; ---- unreached/data gap $AB7C-$AE6F ----

        .org $AE70

loc_AE70:
AE70:  15 F4 02          bclr     $f4, #2 ; xrefs $AB56:jump
AE73:  14 F4 01          bset     $f4, #1
AE76:  3B                rti      

loc_AE77:
AE77:  15 F6 01          bclr     $f6, #1 ; xrefs $A800:jump
AE7A:  F6 21 A6          ldab     $21a6 ; $21A6=operating_state_selector
AE7D:  C1 06             cmpb     #6
AE7F:  26 03             bne      $ae84 ; $AE84=loc_AE84
AE81:  7E E1 64          jmp      $e164 ; $E164=loc_E164

loc_AE84:
AE84:  B6 10 2F          ldaa     $102f ; $102F=SCDR | xrefs $AE7F:branch
AE87:  C1 05             cmpb     #5
AE89:  26 03             bne      $ae8e ; $AE8E=loc_AE8E
AE8B:  7E AB 5C          jmp      $ab5c ; $AB5C=loc_AB5C

loc_AE8E:
AE8E:  13 AF 01 03       brclr    $af, #1, $ae95 ; $AE95=loc_AE95 | xrefs $AE89:branch
AE92:  7E AA 0D          jmp      $aa0d ; $AA0D=loc_AA0D

loc_AE95:
AE95:  C1 FF             cmpb     #-1 ; xrefs $AE8E:branch
AE97:  27 03             beq      $ae9c ; $AE9C=loc_AE9C
AE99:  7E AB 5C          jmp      $ab5c ; $AB5C=loc_AB5C

loc_AE9C:
AE9C:  14 AF 01          bset     $af, #1 ; xrefs $AE97:branch
AE9F:  7E AA 0D          jmp      $aa0d ; $AA0D=loc_AA0D

; ---- unreached/data gap $AEA2-$AFBF ----

        .org $AFC0

sub_AFC0:
AFC0:  15 D7 20          bclr     $d7, #32 ; xrefs $B471:call
AFC3:  B6 20 BB          ldaa     $20bb
AFC6:  2A 35             bpl      $affd ; $AFFD=loc_AFFD
AFC8:  13 A3 81 31       brclr    $a3, #-127, $affd ; $AFFD=loc_AFFD
AFCC:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
AFCE:  B1 8A 09          cmpa     $8a09
AFD1:  25 2A             bcs      $affd ; $AFFD=loc_AFFD
AFD3:  14 D7 20          bset     $d7, #32
AFD6:  13 3F 90 03       brclr    $3f, #-112, $afdd ; $AFDD=loc_AFDD
AFDA:  7E B2 5D          jmp      $b25d ; $B25D=loc_B25D

loc_AFDD:
AFDD:  18 CE 20 CE       ldy      #8398 ; xrefs $AFD6:branch
AFE1:  CE 20 C2          ldx      #8386
AFE4:  F6 20 E9          ldab     $20e9
AFE7:  5A                decb     
AFE8:  3A                abx      
AFE9:  18 3A             aby      
AFEB:  A6 00             ldaa     0, x
AFED:  18 A1 00          cmpa     0, y
AFF0:  24 0B             bcc      $affd ; $AFFD=loc_AFFD
AFF2:  14 D7 80          bset     $d7, #-128
AFF5:  B6 89 F1          ldaa     $89f1
AFF8:  B7 20 C1          staa     $20c1
AFFB:  20 09             bra      $b006 ; $B006=loc_B006

loc_AFFD:
AFFD:  B6 20 C1          ldaa     $20c1 ; xrefs $AFC6:branch, $AFC8:branch, $AFD1:branch, $AFF0:branch
B000:  27 04             beq      $b006 ; $B006=loc_B006
B002:  4A                deca     
B003:  B7 20 C1          staa     $20c1

loc_B006:
B006:  F6 20 E9          ldab     $20e9 ; xrefs $AFFB:branch, $B000:branch
B009:  C1 04             cmpb     #4
B00B:  27 50             beq      $b05d ; $B05D=loc_B05D
B00D:  C1 03             cmpb     #3
B00F:  27 34             beq      $b045 ; $B045=loc_B045
B011:  C1 02             cmpb     #2
B013:  27 18             beq      $b02d ; $B02D=loc_B02D
B015:  B6 20 CE          ldaa     $20ce
B018:  15 D6 10          bclr     $d6, #16
B01B:  13 D7 80 06       brclr    $d7, #-128, $b025 ; $B025=loc_B025
B01F:  14 D6 10          bset     $d6, #16
B022:  B6 20 C6          ldaa     $20c6

loc_B025:
B025:  B7 24 22          staa     $2422 ; xrefs $B01B:branch
B028:  14 D6 01          bset     $d6, #1
B02B:  20 46             bra      $b073 ; $B073=loc_B073

loc_B02D:
B02D:  B6 20 CF          ldaa     $20cf ; xrefs $B013:branch
B030:  15 D6 80          bclr     $d6, #-128
B033:  13 D7 80 06       brclr    $d7, #-128, $b03d ; $B03D=loc_B03D
B037:  14 D6 80          bset     $d6, #-128
B03A:  B6 20 C8          ldaa     $20c8

loc_B03D:
B03D:  B7 24 23          staa     $2423 ; xrefs $B033:branch
B040:  14 D6 08          bset     $d6, #8
B043:  20 2E             bra      $b073 ; $B073=loc_B073

loc_B045:
B045:  B6 20 D0          ldaa     $20d0 ; xrefs $B00F:branch
B048:  15 D6 40          bclr     $d6, #64
B04B:  13 D7 80 06       brclr    $d7, #-128, $b055 ; $B055=loc_B055
B04F:  14 D6 40          bset     $d6, #64
B052:  B6 20 CA          ldaa     $20ca

loc_B055:
B055:  B7 24 24          staa     $2424 ; xrefs $B04B:branch
B058:  14 D6 04          bset     $d6, #4
B05B:  20 16             bra      $b073 ; $B073=loc_B073

loc_B05D:
B05D:  B6 20 D1          ldaa     $20d1 ; xrefs $B00B:branch
B060:  15 D6 20          bclr     $d6, #32
B063:  13 D7 80 06       brclr    $d7, #-128, $b06d ; $B06D=loc_B06D
B067:  14 D6 20          bset     $d6, #32
B06A:  B6 20 CC          ldaa     $20cc

loc_B06D:
B06D:  B7 24 25          staa     $2425 ; xrefs $B063:branch
B070:  14 D6 02          bset     $d6, #2

loc_B073:
B073:  15 D7 08          bclr     $d7, #8 ; xrefs $B02B:branch, $B043:branch, $B05B:branch
B076:  12 D7 20 03       brset    $d7, #32, $b07d ; $B07D=loc_B07D
B07A:  7E B0 C3          jmp      $b0c3 ; $B0C3=loc_B0C3

loc_B07D:
B07D:  96 CA             ldaa     $ca ; xrefs $B076:branch
B07F:  B1 8A 65          cmpa     $8a65
B082:  23 03             bls      $b087 ; $B087=loc_B087
B084:  14 D7 08          bset     $d7, #8

loc_B087:
B087:  B6 20 D3          ldaa     $20d3 ; xrefs $B082:branch
B08A:  26 05             bne      $b091 ; $B091=loc_B091
B08C:  CE 00 00          ldx      #0
B08F:  20 1E             bra      $b0af ; $B0AF=loc_B0AF

loc_B091:
B091:  FE 24 26          ldx      $2426 ; xrefs $B08A:branch
B094:  08                inx      
B095:  BC 8A 4D          cpx      $8a4d
B098:  25 15             bcs      $b0af ; $B0AF=loc_B0AF
B09A:  CE 00 00          ldx      #0
B09D:  FF 24 26          stx      $2426
B0A0:  96 93             ldaa     $93
B0A2:  4C                inca     
B0A3:  B1 8A 51          cmpa     $8a51
B0A6:  23 03             bls      $b0ab ; $B0AB=loc_B0AB
B0A8:  B6 8A 51          ldaa     $8a51

loc_B0AB:
B0AB:  97 93             staa     $93 ; xrefs $B0A6:branch
B0AD:  20 1A             bra      $b0c9 ; $B0C9=loc_B0C9

loc_B0AF:
B0AF:  FF 24 26          stx      $2426 ; xrefs $B08F:branch, $B098:branch
B0B2:  12 D7 80 0D       brset    $d7, #-128, $b0c3 ; $B0C3=loc_B0C3
B0B6:  FE 24 28          ldx      $2428
B0B9:  09                dex      
B0BA:  26 0A             bne      $b0c6 ; $B0C6=loc_B0C6
B0BC:  96 93             ldaa     $93
B0BE:  27 06             beq      $b0c6 ; $B0C6=loc_B0C6
B0C0:  7A 00 93          dec      >$0093

loc_B0C3:
B0C3:  FE 8A 4F          ldx      $8a4f ; xrefs $B07A:jump, $B0B2:branch

loc_B0C6:
B0C6:  FF 24 28          stx      $2428 ; xrefs $B0BA:branch, $B0BE:branch

loc_B0C9:
B0C9:  13 D7 80 52       brclr    $d7, #-128, $b11f ; $B11F=loc_B11F | xrefs $B0AD:branch
B0CD:  15 D7 80          bclr     $d7, #-128
B0D0:  12 D7 40 17       brset    $d7, #64, $b0eb ; $B0EB=loc_B0EB
B0D4:  B6 20 D2          ldaa     $20d2
B0D7:  BB 8A 23          adda     $8a23
B0DA:  24 02             bcc      $b0de ; $B0DE=loc_B0DE
B0DC:  86 FF             ldaa     #-1

loc_B0DE:
B0DE:  B7 20 D2          staa     $20d2 ; xrefs $B0DA:branch
B0E1:  B1 8A 24          cmpa     $8a24
B0E4:  24 02             bcc      $b0e8 ; $B0E8=loc_B0E8
B0E6:  20 37             bra      $b11f ; $B11F=loc_B11F

loc_B0E8:
B0E8:  14 D7 40          bset     $d7, #64 ; xrefs $B0E4:branch

loc_B0EB:
B0EB:  B6 8A 25          ldaa     $8a25 ; xrefs $B0D0:branch
B0EE:  B7 20 D3          staa     $20d3
B0F1:  B6 8A 26          ldaa     $8a26
B0F4:  B7 24 2A          staa     $242a
B0F7:  CE 20 D5          ldx      #8405
B0FA:  F6 20 E9          ldab     $20e9
B0FD:  5A                decb     
B0FE:  3A                abx      
B0FF:  B6 20 D4          ldaa     $20d4
B102:  A7 00             staa     0, x
B104:  CE 20 D9          ldx      #8409
B107:  F6 20 E9          ldab     $20e9
B10A:  5A                decb     
B10B:  3A                abx      
B10C:  A6 00             ldaa     0, x
B10E:  BB 20 DD          adda     $20dd
B111:  24 02             bcc      $b115 ; $B115=loc_B115
B113:  86 FF             ldaa     #-1

loc_B115:
B115:  B1 20 E6          cmpa     $20e6 ; xrefs $B111:branch
B118:  25 03             bcs      $b11d ; $B11D=loc_B11D
B11A:  B6 20 E6          ldaa     $20e6

loc_B11D:
B11D:  A7 00             staa     0, x ; xrefs $B118:branch

loc_B11F:
B11F:  B6 20 D2          ldaa     $20d2 ; xrefs $B0C9:branch, $B0E6:branch
B122:  27 04             beq      $b128 ; $B128=loc_B128
B124:  4A                deca     
B125:  B7 20 D2          staa     $20d2

loc_B128:
B128:  12 D7 40 03       brset    $d7, #64, $b12f ; $B12F=loc_B12F | xrefs $B122:branch
B12C:  7E B1 C8          jmp      $b1c8 ; $B1C8=loc_B1C8

loc_B12F:
B12F:  B6 24 2A          ldaa     $242a ; xrefs $B128:branch
B132:  26 11             bne      $b145 ; $B145=loc_B145
B134:  B6 20 D3          ldaa     $20d3
B137:  27 0F             beq      $b148 ; $B148=loc_B148
B139:  4A                deca     
B13A:  B7 20 D3          staa     $20d3
B13D:  B6 8A 26          ldaa     $8a26
B140:  B7 24 2A          staa     $242a
B143:  20 03             bra      $b148 ; $B148=loc_B148

loc_B145:
B145:  7A 24 2A          dec      $242a ; xrefs $B132:branch

loc_B148:
B148:  B6 20 DA          ldaa     $20da ; xrefs $B137:branch, $B143:branch
B14B:  27 14             beq      $b161 ; $B161=loc_B161
B14D:  7D 20 D6          tst      $20d6
B150:  26 0C             bne      $b15e ; $B15E=loc_B15E
B152:  4A                deca     
B153:  B7 20 DA          staa     $20da
B156:  B6 20 D4          ldaa     $20d4
B159:  B7 20 D6          staa     $20d6
B15C:  20 03             bra      $b161 ; $B161=loc_B161

loc_B15E:
B15E:  7A 20 D6          dec      $20d6 ; xrefs $B150:branch

loc_B161:
B161:  B6 20 DB          ldaa     $20db ; xrefs $B14B:branch, $B15C:branch
B164:  27 14             beq      $b17a ; $B17A=loc_B17A
B166:  7D 20 D7          tst      $20d7
B169:  26 0C             bne      $b177 ; $B177=loc_B177
B16B:  4A                deca     
B16C:  B7 20 DB          staa     $20db
B16F:  B6 20 D4          ldaa     $20d4
B172:  B7 20 D7          staa     $20d7
B175:  20 03             bra      $b17a ; $B17A=loc_B17A

loc_B177:
B177:  7A 20 D7          dec      $20d7 ; xrefs $B169:branch

loc_B17A:
B17A:  B6 20 DC          ldaa     $20dc ; xrefs $B164:branch, $B175:branch
B17D:  27 14             beq      $b193 ; $B193=loc_B193
B17F:  7D 20 D8          tst      $20d8
B182:  26 0C             bne      $b190 ; $B190=loc_B190
B184:  4A                deca     
B185:  B7 20 DC          staa     $20dc
B188:  B6 20 D4          ldaa     $20d4
B18B:  B7 20 D8          staa     $20d8
B18E:  20 03             bra      $b193 ; $B193=loc_B193

loc_B190:
B190:  7A 20 D8          dec      $20d8 ; xrefs $B182:branch

loc_B193:
B193:  B6 20 D9          ldaa     $20d9 ; xrefs $B17D:branch, $B18E:branch
B196:  27 14             beq      $b1ac ; $B1AC=loc_B1AC
B198:  7D 20 D5          tst      $20d5
B19B:  26 0C             bne      $b1a9 ; $B1A9=loc_B1A9
B19D:  4A                deca     
B19E:  B7 20 D9          staa     $20d9
B1A1:  B6 20 D4          ldaa     $20d4
B1A4:  B7 20 D5          staa     $20d5
B1A7:  20 03             bra      $b1ac ; $B1AC=loc_B1AC

loc_B1A9:
B1A9:  7A 20 D5          dec      $20d5 ; xrefs $B19B:branch

loc_B1AC:
B1AC:  B6 20 D3          ldaa     $20d3 ; xrefs $B196:branch, $B1A7:branch
B1AF:  26 17             bne      $b1c8 ; $B1C8=loc_B1C8
B1B1:  B6 20 DA          ldaa     $20da
B1B4:  26 12             bne      $b1c8 ; $B1C8=loc_B1C8
B1B6:  B6 20 DB          ldaa     $20db
B1B9:  26 0D             bne      $b1c8 ; $B1C8=loc_B1C8
B1BB:  B6 20 DC          ldaa     $20dc
B1BE:  26 08             bne      $b1c8 ; $B1C8=loc_B1C8
B1C0:  B6 20 D9          ldaa     $20d9
B1C3:  26 03             bne      $b1c8 ; $B1C8=loc_B1C8
B1C5:  15 D7 40          bclr     $d7, #64

loc_B1C8:
B1C8:  F6 20 D3          ldab     $20d3 ; xrefs $B12C:jump, $B1AF:branch, $B1B4:branch, $B1B9:branch, $B1BE:branch, $B1C3:branch
B1CB:  17                tba      
B1CC:  BB 20 DA          adda     $20da
B1CF:  13 D7 08 04       brclr    $d7, #8, $b1d7 ; $B1D7=loc_B1D7
B1D3:  25 09             bcs      $b1de ; $B1DE=loc_B1DE
B1D5:  9B 93             adda     $93

loc_B1D7:
B1D7:  25 05             bcs      $b1de ; $B1DE=loc_B1DE | xrefs $B1CF:branch
B1D9:  B1 20 E6          cmpa     $20e6
B1DC:  23 03             bls      $b1e1 ; $B1E1=loc_B1E1

loc_B1DE:
B1DE:  B6 20 E6          ldaa     $20e6 ; xrefs $B1D3:branch, $B1D7:branch

loc_B1E1:
B1E1:  B7 20 DF          staa     $20df ; xrefs $B1DC:branch
B1E4:  96 B6             ldaa     $b6
B1E6:  B0 20 DF          suba     $20df
B1E9:  24 01             bcc      $b1ec ; $B1EC=loc_B1EC
B1EB:  4F                clra     

loc_B1EC:
B1EC:  B7 20 E3          staa     $20e3 ; xrefs $B1E9:branch
B1EF:  17                tba      
B1F0:  BB 20 DB          adda     $20db
B1F3:  13 D7 08 04       brclr    $d7, #8, $b1fb ; $B1FB=loc_B1FB
B1F7:  25 09             bcs      $b202 ; $B202=loc_B202
B1F9:  9B 93             adda     $93

loc_B1FB:
B1FB:  25 05             bcs      $b202 ; $B202=loc_B202 | xrefs $B1F3:branch
B1FD:  B1 20 E6          cmpa     $20e6
B200:  23 03             bls      $b205 ; $B205=loc_B205

loc_B202:
B202:  B6 20 E6          ldaa     $20e6 ; xrefs $B1F7:branch, $B1FB:branch

loc_B205:
B205:  B7 20 E0          staa     $20e0 ; xrefs $B200:branch
B208:  96 B6             ldaa     $b6
B20A:  B0 20 E0          suba     $20e0
B20D:  24 01             bcc      $b210 ; $B210=loc_B210
B20F:  4F                clra     

loc_B210:
B210:  B7 20 E4          staa     $20e4 ; xrefs $B20D:branch
B213:  17                tba      
B214:  BB 20 DC          adda     $20dc
B217:  13 D7 08 04       brclr    $d7, #8, $b21f ; $B21F=loc_B21F
B21B:  25 09             bcs      $b226 ; $B226=loc_B226
B21D:  9B 93             adda     $93

loc_B21F:
B21F:  25 05             bcs      $b226 ; $B226=loc_B226 | xrefs $B217:branch
B221:  B1 20 E6          cmpa     $20e6
B224:  23 03             bls      $b229 ; $B229=loc_B229

loc_B226:
B226:  B6 20 E6          ldaa     $20e6 ; xrefs $B21B:branch, $B21F:branch

loc_B229:
B229:  B7 20 E1          staa     $20e1 ; xrefs $B224:branch
B22C:  96 B6             ldaa     $b6
B22E:  B0 20 E1          suba     $20e1
B231:  24 01             bcc      $b234 ; $B234=loc_B234
B233:  4F                clra     

loc_B234:
B234:  B7 20 E5          staa     $20e5 ; xrefs $B231:branch
B237:  17                tba      
B238:  BB 20 D9          adda     $20d9
B23B:  13 D7 08 04       brclr    $d7, #8, $b243 ; $B243=loc_B243
B23F:  25 09             bcs      $b24a ; $B24A=loc_B24A
B241:  9B 93             adda     $93

loc_B243:
B243:  25 05             bcs      $b24a ; $B24A=loc_B24A | xrefs $B23B:branch
B245:  B1 20 E6          cmpa     $20e6
B248:  23 03             bls      $b24d ; $B24D=loc_B24D

loc_B24A:
B24A:  B6 20 E6          ldaa     $20e6 ; xrefs $B23F:branch, $B243:branch

loc_B24D:
B24D:  B7 20 DE          staa     $20de ; xrefs $B248:branch
B250:  96 B6             ldaa     $b6
B252:  B0 20 DE          suba     $20de
B255:  24 01             bcc      $b258 ; $B258=loc_B258
B257:  4F                clra     

loc_B258:
B258:  B7 20 E2          staa     $20e2 ; xrefs $B255:branch
B25B:  20 0F             bra      $b26c ; $B26C=loc_B26C

loc_B25D:
B25D:  B6 20 E6          ldaa     $20e6 ; xrefs $AFDA:jump
B260:  B7 20 DF          staa     $20df
B263:  B7 20 E0          staa     $20e0
B266:  B7 20 E1          staa     $20e1
B269:  B7 20 DE          staa     $20de

loc_B26C:
B26C:  39                rts       ; xrefs $B25B:branch

; ---- unreached/data gap $B26D-$B26D ----

        .org $B26E

; [CONFIRMED] One-dimensional 16-bit interpolation helper.
interp_1d_word:
B26E:  E6 00             ldab     0, x ; xrefs $7132:call, $D607:call, $E438:call, $E458:call, $E520:call, $E804:call, $E811:call, $E9A0:call
B270:  18 3A             aby      
B272:  18 3A             aby      
B274:  18 EC 00          ldd      0, y
B277:  18 A3 02          subd     2, y
B27A:  25 16             bcs      $b292 ; $B292=loc_B292
B27C:  36                psha     
B27D:  A6 01             ldaa     1, x
B27F:  3D                mul      
B280:  89 00             adca     #0
B282:  16                tab      
B283:  32                pula     
B284:  37                pshb     
B285:  E6 01             ldab     1, x
B287:  3D                mul      
B288:  8F                xgdx     
B289:  33                pulb     
B28A:  3A                abx      
B28B:  8F                xgdx     
B28C:  40                nega     
B28D:  50                negb     
B28E:  82 00             sbca     #0
B290:  20 14             bra      $b2a6 ; $B2A6=loc_B2A6

loc_B292:
B292:  40                nega      ; xrefs $B27A:branch
B293:  50                negb     
B294:  82 00             sbca     #0
B296:  36                psha     
B297:  A6 01             ldaa     1, x
B299:  3D                mul      
B29A:  89 00             adca     #0
B29C:  16                tab      
B29D:  32                pula     
B29E:  37                pshb     
B29F:  E6 01             ldab     1, x
B2A1:  3D                mul      
B2A2:  8F                xgdx     
B2A3:  33                pulb     
B2A4:  3A                abx      
B2A5:  8F                xgdx     

loc_B2A6:
B2A6:  18 E3 00          addd     0, y ; xrefs $B290:branch
B2A9:  39                rts      

; ---- unreached/data gap $B2AA-$B2AA ----

        .org $B2AB

; [CONFIRMED] One-dimensional unsigned byte interpolation helper.
interp_1d_u8:
B2AB:  37                pshb      ; xrefs $4353:call, $43A3:call, $44B4:call, $4599:call, $45BF:call, $46EB:call, $48FF:call, $49B0:call, +45 more
B2AC:  16                tab      
B2AD:  18 3A             aby      
B2AF:  18 A6 01          ldaa     1, y
B2B2:  18 A0 00          suba     0, y
B2B5:  33                pulb     
B2B6:  25 14             bcs      $b2cc ; $B2CC=loc_B2CC
B2B8:  20 0D             bra      $b2c7 ; $B2C7=loc_B2C7

; [STRONG] One-dimensional signed-byte interpolation helper.
interp_1d_s8:
B2BA:  37                pshb      ; xrefs $BA71:call, $D6FC:call, $E396:call
B2BB:  16                tab      
B2BC:  18 3A             aby      
B2BE:  18 A6 01          ldaa     1, y
B2C1:  18 A0 00          suba     0, y
B2C4:  33                pulb     
B2C5:  2D 05             blt      $b2cc ; $B2CC=loc_B2CC

loc_B2C7:
B2C7:  3D                mul       ; xrefs $B2B8:branch
B2C8:  89 00             adca     #0
B2CA:  20 05             bra      $b2d1 ; $B2D1=loc_B2D1

loc_B2CC:
B2CC:  40                nega      ; xrefs $B2B6:branch, $B2C5:branch
B2CD:  3D                mul      
B2CE:  89 00             adca     #0
B2D0:  40                nega     

loc_B2D1:
B2D1:  18 AB 00          adda     0, y ; xrefs $B2CA:branch
B2D4:  39                rts      

; ---- unreached/data gap $B2D5-$B2D5 ----

        .org $B2D6

; [CONFIRMED] Two-dimensional unsigned byte interpolation helper.
interp_2d_u8:
B2D6:  18 E6 06          ldab     6, y ; xrefs $4927:call, $6366:call, $6ECA:call, $7270:call, $9BAE:call, $BA57:call, $BE90:call, $C2BE:call, +4 more
B2D9:  18 A6 02          ldaa     2, y
B2DC:  3D                mul      
B2DD:  18 EB 00          addb     0, y
B2E0:  89 00             adca     #0
B2E2:  18 E3 04          addd     4, y
B2E5:  8F                xgdx     
B2E6:  18 E6 01          ldab     1, y
B2E9:  A6 01             ldaa     1, x
B2EB:  A0 00             suba     0, x
B2ED:  25 05             bcs      $b2f4 ; $B2F4=loc_B2F4
B2EF:  3D                mul      
B2F0:  89 00             adca     #0
B2F2:  20 05             bra      $b2f9 ; $B2F9=loc_B2F9

loc_B2F4:
B2F4:  40                nega      ; xrefs $B2ED:branch
B2F5:  3D                mul      
B2F6:  89 00             adca     #0
B2F8:  40                nega     

loc_B2F9:
B2F9:  AB 00             adda     0, x ; xrefs $B2F2:branch
B2FB:  18 E6 06          ldab     6, y
B2FE:  36                psha     
B2FF:  36                psha     
B300:  3A                abx      
B301:  A6 01             ldaa     1, x
B303:  A0 00             suba     0, x
B305:  18 E6 01          ldab     1, y
B308:  25 05             bcs      $b30f ; $B30F=loc_B30F
B30A:  3D                mul      
B30B:  89 00             adca     #0
B30D:  20 05             bra      $b314 ; $B314=loc_B314

loc_B30F:
B30F:  40                nega      ; xrefs $B308:branch
B310:  3D                mul      
B311:  89 00             adca     #0
B313:  40                nega     

loc_B314:
B314:  AB 00             adda     0, x ; xrefs $B30D:branch
B316:  33                pulb     
B317:  10                sba      
B318:  18 E6 03          ldab     3, y
B31B:  25 05             bcs      $b322 ; $B322=loc_B322
B31D:  3D                mul      
B31E:  89 00             adca     #0
B320:  20 05             bra      $b327 ; $B327=loc_B327

loc_B322:
B322:  40                nega      ; xrefs $B31B:branch
B323:  3D                mul      
B324:  89 00             adca     #0
B326:  40                nega     

loc_B327:
B327:  33                pulb      ; xrefs $B320:branch
B328:  1B                aba      
B329:  39                rts      

; ---- unreached/data gap $B32A-$B32A ----

        .org $B32B

; [CONFIRMED] Two-dimensional signed-byte interpolation helper.
interp_2d_s8:
B32B:  18 E6 06          ldab     6, y ; xrefs $496A:call, $E3DE:call, $E866:call, $E887:call
B32E:  18 A6 02          ldaa     2, y
B331:  3D                mul      
B332:  18 EB 00          addb     0, y
B335:  89 00             adca     #0
B337:  18 E3 04          addd     4, y
B33A:  8F                xgdx     
B33B:  18 E6 01          ldab     1, y
B33E:  A6 01             ldaa     1, x
B340:  A0 00             suba     0, x
B342:  2D 05             blt      $b349 ; $B349=loc_B349
B344:  3D                mul      
B345:  89 00             adca     #0
B347:  20 05             bra      $b34e ; $B34E=loc_B34E

loc_B349:
B349:  40                nega      ; xrefs $B342:branch
B34A:  3D                mul      
B34B:  89 00             adca     #0
B34D:  40                nega     

loc_B34E:
B34E:  AB 00             adda     0, x ; xrefs $B347:branch
B350:  18 E6 06          ldab     6, y
B353:  36                psha     
B354:  36                psha     
B355:  3A                abx      
B356:  18 E6 01          ldab     1, y
B359:  A6 01             ldaa     1, x
B35B:  A0 00             suba     0, x
B35D:  2D 05             blt      $b364 ; $B364=loc_B364
B35F:  3D                mul      
B360:  89 00             adca     #0
B362:  20 05             bra      $b369 ; $B369=loc_B369

loc_B364:
B364:  40                nega      ; xrefs $B35D:branch
B365:  3D                mul      
B366:  89 00             adca     #0
B368:  40                nega     

loc_B369:
B369:  AB 00             adda     0, x ; xrefs $B362:branch
B36B:  33                pulb     
B36C:  10                sba      
B36D:  2D 08             blt      $b377 ; $B377=loc_B377
B36F:  18 E6 03          ldab     3, y
B372:  3D                mul      
B373:  89 00             adca     #0
B375:  20 08             bra      $b37f ; $B37F=loc_B37F

loc_B377:
B377:  40                nega      ; xrefs $B36D:branch
B378:  18 E6 03          ldab     3, y
B37B:  3D                mul      
B37C:  89 00             adca     #0
B37E:  40                nega     

loc_B37F:
B37F:  33                pulb      ; xrefs $B375:branch
B380:  1B                aba      
B381:  39                rts      

; ---- unreached/data gap $B382-$B382 ----

        .org $B383

; [CONFIRMED] Axis/index helper.
axis_lookup_u8:
B383:  5D                tstb      ; xrefs $41E9:call, $4349:call, $4399:call, $5CFC:call, $5D81:call, $6354:call, $C289:call
B384:  26 03             bne      $b389 ; $B389=loc_B389
B386:  4F                clra     
B387:  20 2E             bra      $b3b7 ; $B3B7=loc_B3B7

loc_B389:
B389:  A1 00             cmpa     0, x ; xrefs $B384:branch
B38B:  22 05             bhi      $b392 ; $B392=loc_B392
B38D:  CC 00 00          ldd      #0
B390:  20 25             bra      $b3b7 ; $B3B7=loc_B3B7

loc_B392:
B392:  5A                decb      ; xrefs $B38B:branch
B393:  3A                abx      
B394:  A1 00             cmpa     0, x
B396:  25 04             bcs      $b39c ; $B39C=loc_B39C
B398:  17                tba      
B399:  5F                clrb     
B39A:  20 1B             bra      $b3b7 ; $B3B7=loc_B3B7

loc_B39C:
B39C:  5A                decb      ; xrefs $B396:branch, $B3A0:branch
B39D:  09                dex      
B39E:  A1 00             cmpa     0, x
B3A0:  25 FA             bcs      $b39c ; $B39C=loc_B39C
B3A2:  26 04             bne      $b3a8 ; $B3A8=loc_B3A8
B3A4:  17                tba      
B3A5:  5F                clrb     
B3A6:  20 0F             bra      $b3b7 ; $B3B7=loc_B3B7

loc_B3A8:
B3A8:  37                pshb      ; xrefs $B3A2:branch
B3A9:  A0 00             suba     0, x
B3AB:  E6 01             ldab     1, x
B3AD:  E0 00             subb     0, x
B3AF:  CE 00 00          ldx      #0
B3B2:  3A                abx      
B3B3:  5F                clrb     
B3B4:  02                idiv     
B3B5:  8F                xgdx     
B3B6:  32                pula     

loc_B3B7:
B3B7:  39                rts       ; xrefs $B387:branch, $B390:branch, $B39A:branch, $B3A6:branch

; ---- unreached/data gap $B3B8-$B3B8 ----

        .org $B3B9

; [CONFIRMED] Axis/index helper used to normalize engine period into the RPM axis.
period_axis_lookup:
B3B9:  1A A3 00          cpd      0, x ; xrefs $D47C:call
B3BC:  22 06             bhi      $b3c4 ; $B3C4=loc_B3C4
B3BE:  18 8F             xgdy     
B3C0:  17                tba      
B3C1:  5F                clrb     
B3C2:  20 30             bra      $b3f4 ; $B3F4=loc_B3F4

loc_B3C4:
B3C4:  18 8C 00 00       cpy      #0 ; xrefs $B3BC:branch

loc_B3C8:
B3C8:  27 0B             beq      $b3d5 ; $B3D5=loc_B3D5 | xrefs $B3D3:branch
B3CA:  1A A3 00          cpd      0, x
B3CD:  23 06             bls      $b3d5 ; $B3D5=loc_B3D5
B3CF:  09                dex      
B3D0:  09                dex      
B3D1:  18 09             dey      
B3D3:  20 F3             bra      $b3c8 ; $B3C8=loc_B3C8

loc_B3D5:
B3D5:  18 3C             pshy      ; xrefs $B3C8:branch, $B3CD:branch
B3D7:  1A A3 00          cpd      0, x
B3DA:  24 15             bcc      $b3f1 ; $B3F1=loc_B3F1
B3DC:  A3 00             subd     0, x
B3DE:  40                nega     
B3DF:  50                negb     
B3E0:  82 00             sbca     #0
B3E2:  8F                xgdx     
B3E3:  18 8F             xgdy     
B3E5:  18 EC 00          ldd      0, y
B3E8:  18 A3 02          subd     2, y
B3EB:  8F                xgdx     
B3EC:  03                fdiv     
B3ED:  8F                xgdx     
B3EE:  16                tab      
B3EF:  20 01             bra      $b3f2 ; $B3F2=loc_B3F2

loc_B3F1:
B3F1:  5F                clrb      ; xrefs $B3DA:branch

loc_B3F2:
B3F2:  32                pula      ; xrefs $B3EF:branch
B3F3:  32                pula     

loc_B3F4:
B3F4:  39                rts       ; xrefs $B3C2:branch

; ---- unreached/data gap $B3F5-$B3F5 ----

        .org $B3F6

sub_B3F6:
B3F6:  A0 00             suba     0, x ; xrefs $4182:call, $4203:call, $433A:call, $438A:call, $43D2:call, $9805:call, $BB3F:call, $C27D:call, +1 more
B3F8:  24 08             bcc      $b402 ; $B402=loc_B402
B3FA:  40                nega     
B3FB:  3D                mul      
B3FC:  40                nega     
B3FD:  50                negb     
B3FE:  82 00             sbca     #0
B400:  20 01             bra      $b403 ; $B403=loc_B403

loc_B402:
B402:  3D                mul       ; xrefs $B3F8:branch

loc_B403:
B403:  E3 00             addd     0, x ; xrefs $B400:branch
B405:  39                rts      

; ---- unreached/data gap $B406-$B406 ----

        .org $B407

sub_B407:
B407:  A3 00             subd     0, x ; xrefs $CE11:call, $D4C2:call, $D7AE:call
B409:  24 0C             bcc      $b417 ; $B417=loc_B417
B40B:  40                nega     
B40C:  50                negb     
B40D:  82 00             sbca     #0
B40F:  8D 0B             bsr      $b41c ; $B41C=sub_B41C
B411:  40                nega     
B412:  50                negb     
B413:  82 00             sbca     #0
B415:  20 02             bra      $b419 ; $B419=loc_B419

loc_B417:
B417:  8D 03             bsr      $b41c ; $B41C=sub_B41C | xrefs $B409:branch

loc_B419:
B419:  E3 00             addd     0, x ; xrefs $B415:branch
B41B:  39                rts      

sub_B41C:
B41C:  37                pshb      ; xrefs $B40F:call, $B417:call
B41D:  E6 02             ldab     2, x
B41F:  3D                mul      
B420:  18 8F             xgdy     
B422:  32                pula     
B423:  E6 02             ldab     2, x
B425:  3D                mul      
B426:  89 00             adca     #0
B428:  16                tab      
B429:  18 3A             aby      
B42B:  18 8F             xgdy     
B42D:  39                rts      

; ---- unreached/data gap $B42E-$B42E ----

        .org $B42F

sub_B42F:
B42F:  5D                tstb      ; xrefs $40B6:call, $40D4:call, $4163:call, $4328:call, $4378:call, $43EE:call
B430:  2A 07             bpl      $b439 ; $B439=loc_B439
B432:  1B                aba      
B433:  25 09             bcs      $b43e ; $B43E=loc_B43E
B435:  86 00             ldaa     #0
B437:  20 0D             bra      $b446 ; $B446=loc_B446

loc_B439:
B439:  1B                aba       ; xrefs $B430:branch
B43A:  24 02             bcc      $b43e ; $B43E=loc_B43E
B43C:  86 FF             ldaa     #-1

loc_B43E:
B43E:  E6 00             ldab     0, x ; xrefs $B433:branch, $B43A:branch
B440:  3D                mul      
B441:  05                asld     
B442:  24 02             bcc      $b446 ; $B446=loc_B446
B444:  86 FF             ldaa     #-1

loc_B446:
B446:  39                rts       ; xrefs $B437:branch, $B442:branch

; [STRONG] Central ordered fuel path: scheduler/state, signed trims, and final high-load stage.
fuel_runtime_sequence:
B447:  BD 42 92          jsr      $4292 ; $4292=sub_4292 | xrefs $7743:call
B44A:  BD B5 7F          jsr      $b57f ; $B57F=sub_B57F
B44D:  BD D0 C8          jsr      $d0c8 ; $D0C8=sub_D0C8
B450:  12 A3 01 0E       brset    $a3, #1, $b462 ; $B462=loc_B462
B454:  BD 6E EE          jsr      $6eee ; $6EEE=fuel_output_scheduler
B457:  BD E9 A8          jsr      $e9a8 ; $E9A8=afterstart_state_handler
B45A:  BD E3 8B          jsr      $e38b ; $E38B=fuel_signed_trim_lookup
B45D:  BD 6E 96          jsr      $6e96 ; $6E96=high_load_final_fuel_stage
B460:  20 0C             bra      $b46e ; $B46E=loc_B46E

loc_B462:
B462:  BD E9 A8          jsr      $e9a8 ; $E9A8=afterstart_state_handler | xrefs $B450:branch
B465:  BD E3 8B          jsr      $e38b ; $E38B=fuel_signed_trim_lookup
B468:  BD 6E 96          jsr      $6e96 ; $6E96=high_load_final_fuel_stage
B46B:  BD 6E EE          jsr      $6eee ; $6EEE=fuel_output_scheduler

loc_B46E:
B46E:  BD 9A 16          jsr      $9a16 ; $9A16=sub_9A16 | xrefs $B460:branch
B471:  BD AF C0          jsr      $afc0 ; $AFC0=sub_AFC0
B474:  39                rts      

; ---- unreached/data gap $B475-$B475 ----

        .org $B476

; [OPEN] Periodic runtime stage.
runtime_stage_b476:
B476:  CE 10 00          ldx      #4096 ; xrefs $D370:call
B479:  0F                sei      
B47A:  1E 50 01 0C       brset    80, x; #1; $b48a ; $B48A=loc_B48A
B47E:  1F 80 20 05       brclr    128, x; #32; $b487 ; $B487=loc_B487
B482:  15 9C 02          bclr     $9c, #2 ; $009C=scheduler_status_flags
B485:  20 03             bra      $b48a ; $B48A=loc_B48A

loc_B487:
B487:  14 9C 02          bset     $9c, #2 ; $009C=scheduler_status_flags | xrefs $B47E:branch

loc_B48A:
B48A:  0E                cli       ; xrefs $B47A:branch, $B485:branch
B48B:  39                rts      

; [OPEN] Periodic runtime stage.
runtime_stage_b48c:
B48C:  CE 10 00          ldx      #4096 ; xrefs $D373:call
B48F:  13 9C 01 72       brclr    $9c, #1, $b505 ; $009C=scheduler_status_flags, $B505=loc_B505
B493:  13 9C 02 30       brclr    $9c, #2, $b4c7 ; $009C=scheduler_status_flags, $B4C7=loc_B4C7
B497:  13 9C 80 09       brclr    $9c, #-128, $b4a4 ; $009C=scheduler_status_flags, $B4A4=loc_B4A4
B49B:  15 9C 80          bclr     $9c, #-128 ; $009C=scheduler_status_flags
B49E:  14 8C 40          bset     $8c, #64
B4A1:  BD 95 6B          jsr      $956b ; $956B=period_history_init

loc_B4A4:
B4A4:  96 8B             ldaa     $8b ; xrefs $B497:branch
B4A6:  81 F0             cmpa     #-16
B4A8:  27 1D             beq      $b4c7 ; $B4C7=loc_B4C7
B4AA:  CE 10 00          ldx      #4096
B4AD:  1C 50 08          bset     80, x; #8
B4B0:  1C 24 20          bset     36, x; #32
B4B3:  7F 24 8B          clr      $248b
B4B6:  13 A9 01 10       brclr    $a9, #1, $b4ca ; $00A9=operating_mode_flags, $B4CA=loc_B4CA
B4BA:  0F                sei      
B4BB:  BE 91 6A          lds      $916a ; $916A=expected_stack_top
B4BE:  FC 20 14          ldd      $2014
B4C1:  FD 21 11          std      $2111
B4C4:  7E B8 E6          jmp      $b8e6 ; $B8E6=loc_B8E6

loc_B4C7:
B4C7:  1D 24 20          bclr     36, x; #32 ; xrefs $B493:branch, $B4A8:branch

loc_B4CA:
B4CA:  B6 24 6A          ldaa     $246a ; xrefs $B4B6:branch
B4CD:  27 0E             beq      $b4dd ; $B4DD=loc_B4DD
B4CF:  7A 24 6A          dec      $246a
B4D2:  26 09             bne      $b4dd ; $B4DD=loc_B4DD
B4D4:  B6 91 03          ldaa     $9103
B4D7:  BD CB 5B          jsr      $cb5b ; $CB5B=sub_CB5B
B4DA:  14 A6 10          bset     $a6, #16

loc_B4DD:
B4DD:  B6 24 68          ldaa     $2468 ; xrefs $B4CD:branch, $B4D2:branch
B4E0:  27 03             beq      $b4e5 ; $B4E5=loc_B4E5
B4E2:  7A 24 68          dec      $2468

loc_B4E5:
B4E5:  B6 24 8B          ldaa     $248b ; xrefs $B4E0:branch
B4E8:  27 03             beq      $b4ed ; $B4ED=loc_B4ED
B4EA:  7A 24 8B          dec      $248b

loc_B4ED:
B4ED:  B6 24 6A          ldaa     $246a ; xrefs $B4E8:branch
B4F0:  BA 24 68          oraa     $2468
B4F3:  BA 24 8B          oraa     $248b
B4F6:  26 5C             bne      $b554 ; $B554=loc_B554
B4F8:  12 A6 10 58       brset    $a6, #16, $b554 ; $B554=loc_B554
B4FC:  12 9C 02 54       brset    $9c, #2, $b554 ; $009C=scheduler_status_flags, $B554=loc_B554
B500:  1D 50 03          bclr     80, x; #3
B503:  20 4F             bra      $b554 ; $B554=loc_B554

loc_B505:
B505:  12 9C 02 46       brset    $9c, #2, $b54f ; $009C=scheduler_status_flags, $B54F=loc_B54F | xrefs $B48F:branch
B509:  7A 24 69          dec      $2469
B50C:  26 46             bne      $b554 ; $B554=loc_B554
B50E:  13 A9 03 06       brclr    $a9, #3, $b518 ; $00A9=operating_mode_flags, $B518=loc_B518
B512:  96 8B             ldaa     $8b
B514:  81 F0             cmpa     #-16
B516:  26 05             bne      $b51d ; $B51D=loc_B51D

loc_B518:
B518:  1D 50 02          bclr     80, x; #2 ; xrefs $B50E:branch
B51B:  20 1F             bra      $b53c ; $B53C=loc_B53C

loc_B51D:
B51D:  14 9C 01          bset     $9c, #1 ; $009C=scheduler_status_flags | xrefs $B516:branch
B520:  14 9C 80          bset     $9c, #-128 ; $009C=scheduler_status_flags
B523:  B6 91 07          ldaa     $9107
B526:  26 02             bne      $b52a ; $B52A=loc_B52A
B528:  86 01             ldaa     #1

loc_B52A:
B52A:  B7 24 6A          staa     $246a ; xrefs $B526:branch
B52D:  15 A6 10          bclr     $a6, #16
B530:  B6 91 2F          ldaa     $912f
B533:  B7 24 68          staa     $2468
B536:  B6 89 69          ldaa     $8969
B539:  B7 24 8B          staa     $248b

loc_B53C:
B53C:  1D 50 01          bclr     80, x; #1 ; xrefs $B51B:branch
B53F:  1D 24 20          bclr     36, x; #32
B542:  86 A0             ldaa     #-96
B544:  B7 10 20          staa     $1020
B547:  86 60             ldaa     #96
B549:  B7 10 0B          staa     $100b ; $100B=CFORC
B54C:  15 A9 03          bclr     $a9, #3 ; $00A9=operating_mode_flags

loc_B54F:
B54F:  86 02             ldaa     #2 ; xrefs $B505:branch
B551:  B7 24 69          staa     $2469

loc_B554:
B554:  39                rts       ; xrefs $B4F6:branch, $B4F8:branch, $B4FC:branch, $B503:branch, $B50C:branch

; [STRONG] Initialize countdown/timer pair 0x2469/0x246A and status flag 0x009C.
countdown_init_b555:
B555:  7F 24 6A          clr      $246a ; xrefs $B922:call
B558:  86 02             ldaa     #2
B55A:  B7 24 69          staa     $2469
B55D:  86 02             ldaa     #2
B55F:  97 9C             staa     $9c ; $009C=scheduler_status_flags
B561:  39                rts      

; [OPEN] Periodic runtime state update.
runtime_stage_b562:
B562:  13 A9 04 18       brclr    $a9, #4, $b57e ; $00A9=operating_mode_flags, $B57E=loc_B57E | xrefs $D37C:call
B566:  B6 24 85          ldaa     $2485
B569:  27 13             beq      $b57e ; $B57E=loc_B57E
B56B:  F6 24 8A          ldab     $248a
B56E:  27 05             beq      $b575 ; $B575=loc_B575
B570:  7A 24 8A          dec      $248a
B573:  20 09             bra      $b57e ; $B57E=loc_B57E

loc_B575:
B575:  F6 89 68          ldab     $8968 ; xrefs $B56E:branch
B578:  F7 24 8A          stab     $248a
B57B:  7A 24 85          dec      $2485

loc_B57E:
B57E:  39                rts       ; xrefs $B562:branch, $B569:branch, $B573:branch

sub_B57F:
B57F:  7C 25 B6          inc      $25b6 ; xrefs $B44A:call
B582:  39                rts      

; ---- unreached/data gap $B583-$B7FF ----

        .org $B800

; [CONFIRMED] Reset entry: stack/register init, watchdog, calibration-window copy, subsystem init, jump to main loop.
reset_entry:
B800:  7F 00 94          clr      >$0094 ; $0094=reset_fault_cause
B803:  7C 00 8E          inc      >$008e

loc_B806:
B806:  BE 91 6A          lds      $916a ; $916A=expected_stack_top | load stack pointer from calibration word expected_stack_top | xrefs $B945:jump
B809:  86 01             ldaa     #1
B80B:  B7 10 3D          staa     $103d ; $103D=INIT
B80E:  86 BA             ldaa     #-70
B810:  B7 10 39          staa     $1039
B813:  86 01             ldaa     #1
B815:  B7 10 24          staa     $1024 ; $1024=TMSK2_or_status
B818:  86 FF             ldaa     #-1
B81A:  B7 10 08          staa     $1008 ; $1008=PORTD
B81D:  C6 1A             ldab     #26
B81F:  F7 10 09          stab     $1009 ; $1009=DDRD
B822:  86 21             ldaa     #33
B824:  B7 10 3C          staa     $103c
B827:  7C 00 8F          inc      >$008f
B82A:  86 14             ldaa     #20
B82C:  B7 10 30          staa     $1030 ; $1030=ADCTL
B82F:  86 06             ldaa     #6
B831:  B7 10 40          staa     $1040
B834:  86 03             ldaa     #3
B836:  B7 10 50          staa     $1050
B839:  86 55             ldaa     #85 ; first watchdog service byte 0x55
B83B:  B7 10 3A          staa     $103a ; $103A=COPRST
B83E:  86 AA             ldaa     #-86 ; second watchdog service byte 0xAA
B840:  B7 10 3A          staa     $103a ; $103A=COPRST
B843:  CE 80 00          ldx      #-32768 ; source pointer for calibration/data window
B846:  18 CE 80 00       ldy      #-32768 ; destination pointer for logical calibration/data window

loc_B84A:
B84A:  8C 93 15          cpx      #-27883 ; copy ends at 0x9315, therefore bytes 0x8000..0x9314 | xrefs $B857:branch
B84D:  27 0A             beq      $b859 ; $B859=loc_B859
B84F:  A6 00             ldaa     0, x
B851:  18 A7 00          staa     0, y
B854:  08                inx      
B855:  18 08             iny      
B857:  20 F1             bra      $b84a ; $B84A=loc_B84A

loc_B859:
B859:  86 55             ldaa     #85 ; xrefs $B84D:branch
B85B:  B7 10 3A          staa     $103a ; $103A=COPRST
B85E:  86 AA             ldaa     #-86
B860:  B7 10 3A          staa     $103a ; $103A=COPRST
B863:  BD 5A 79          jsr      $5a79 ; $5A79=sub_5A79
B866:  86 FF             ldaa     #-1
B868:  97 95             staa     $95
B86A:  BD E2 27          jsr      $e227 ; $E227=sub_E227
B86D:  4F                clra     
B86E:  97 9B             staa     $9b
B870:  97 9A             staa     $9a
B872:  97 96             staa     $96
B874:  97 97             staa     $97
B876:  97 98             staa     $98
B878:  15 2A 03          bclr     $2a, #3
B87B:  15 3C 01          bclr     $3c, #1
B87E:  14 3C 02          bset     $3c, #2
B881:  15 27 01          bclr     $27, #1
B884:  14 27 02          bset     $27, #2
B887:  BD 9E AF          jsr      $9eaf ; $9EAF=sub_9EAF
B88A:  BD BD EC          jsr      $bdec ; $BDEC=sub_BDEC
B88D:  BD 4A A7          jsr      $4aa7 ; $4AA7=sub_4AA7
B890:  BD 4B 63          jsr      $4b63 ; $4B63=sub_4B63
B893:  BD A6 E5          jsr      $a6e5 ; $A6E5=sci_buffers_init
B896:  BD A6 96          jsr      $a696 ; $A696=sci_mode_init
B899:  CC FF FF          ldd      #-1
B89C:  FD 21 94          std      $2194
B89F:  FD 21 99          std      $2199
B8A2:  FD 21 9B          std      $219b
B8A5:  FC 92 83          ldd      $9283
B8A8:  FD 21 9D          std      $219d
B8AB:  CC FF FF          ldd      #-1
B8AE:  FD 21 88          std      $2188
B8B1:  CC 00 00          ldd      #0
B8B4:  FD 21 8A          std      $218a
B8B7:  4F                clra     
B8B8:  B7 20 EF          staa     $20ef
B8BB:  BD 40 17          jsr      $4017 ; $4017=adc_sample_group_a
B8BE:  86 10             ldaa     #16
B8C0:  B7 10 30          staa     $1030 ; $1030=ADCTL
B8C3:  86 06             ldaa     #6
B8C5:  B7 10 40          staa     $1040
B8C8:  86 03             ldaa     #3
B8CA:  B7 10 50          staa     $1050
B8CD:  B6 92 E6          ldaa     $92e6
B8D0:  B7 20 F0          staa     $20f0
B8D3:  BD 40 34          jsr      $4034 ; $4034=adc_sample_group_b
B8D6:  BD 40 A8          jsr      $40a8 ; $40A8=sub_40A8
B8D9:  86 FF             ldaa     #-1
B8DB:  97 95             staa     $95
B8DD:  BD 9E 98          jsr      $9e98 ; $9E98=sub_9E98
B8E0:  BD EF 71          jsr      $ef71 ; $EF71=sub_EF71
B8E3:  BD 40 9C          jsr      $409c ; $409C=sub_409C

loc_B8E6:
B8E6:  BD D1 76          jsr      $d176 ; $D176=sub_D176 | xrefs $B4C4:jump, $D36C:jump
B8E9:  BD 72 9D          jsr      $729d ; $729D=sub_729D
B8EC:  BD B9 5F          jsr      $b95f ; $B95F=sub_B95F
B8EF:  BD CA D7          jsr      $cad7 ; $CAD7=sub_CAD7
B8F2:  BD BC 12          jsr      $bc12 ; $BC12=sub_BC12
B8F5:  BD CB 6E          jsr      $cb6e ; $CB6E=sub_CB6E

loc_B8F8:
B8F8:  BD 40 79          jsr      $4079 ; $4079=sub_4079 | xrefs $D34D:jump
B8FB:  BD D6 AC          jsr      $d6ac ; $D6AC=runtime_variables_init
B8FE:  CE 10 00          ldx      #4096
B901:  1C 50 08          bset     80, x; #8
B904:  BD 95 6B          jsr      $956b ; $956B=period_history_init
B907:  BD 44 21          jsr      $4421 ; $4421=sub_4421
B90A:  BD E7 7E          jsr      $e77e ; $E77E=sub_E77E
B90D:  BD CB 43          jsr      $cb43 ; $CB43=sub_CB43
B910:  BD 9B 61          jsr      $9b61 ; $9B61=sub_9B61
B913:  BD A0 12          jsr      $a012 ; $A012=sub_A012
B916:  BD CB C4          jsr      $cbc4 ; $CBC4=sub_CBC4
B919:  BD 56 52          jsr      $5652 ; $5652=mode_control_init_5652
B91C:  BD 67 A3          jsr      $67a3 ; $67A3=state_or_comms_init_67a3
B91F:  BD BB 98          jsr      $bb98 ; $BB98=ignition_output_init
B922:  BD B5 55          jsr      $b555 ; $B555=countdown_init_b555
B925:  CE 10 00          ldx      #4096
B928:  1C 24 C1          bset     36, x; #-63
B92B:  86 04             ldaa     #4
B92D:  43                coma     
B92E:  B7 10 23          staa     $1023 ; $1023=TFLG1
B931:  86 FF             ldaa     #-1
B933:  B7 10 25          staa     $1025 ; $1025=TFLG2
B936:  B7 10 27          staa     $1027
B939:  0E                cli      
B93A:  7E D2 D9          jmp      $d2d9 ; $D2D9=main_runtime_loop

; [CONFIRMED] Set RAM 0x0094 bit 0x01 and re-enter reset flow.
fault_soft_restart_bit01:
B93D:  14 94 01          bset     $94, #1 ; $0094=reset_fault_cause
B940:  20 03             bra      $b945 ; $B945=loc_B945

; [CONFIRMED] Set RAM 0x0094 bit 0x02 and re-enter reset flow.
fault_soft_restart_bit02:
B942:  14 94 02          bset     $94, #2 ; $0094=reset_fault_cause

loc_B945:
B945:  7E B8 06          jmp      $b806 ; $B806=loc_B806 | xrefs $B940:branch

; [CONFIRMED] Set RAM 0x0094 bit 0x04 and enter fatal path.
fault_fatal_bit04:
B948:  14 94 04          bset     $94, #4 ; $0094=reset_fault_cause
B94B:  20 03             bra      $b950 ; $B950=loc_B950

; [CONFIRMED] Set RAM 0x0094 bit 0x08, force outputs safe, loop forever.
fault_stop_bit08:
B94D:  14 94 08          bset     $94, #8 ; $0094=reset_fault_cause | xrefs $D816:jump, $E0F3:jump

loc_B950:
B950:  4F                clra      ; xrefs $B94B:branch
B951:  B7 10 20          staa     $1020
B954:  B7 10 00          staa     $1000 ; $1000=PORTA
B957:  B7 10 50          staa     $1050
B95A:  B7 10 40          staa     $1040

loc_B95D:
B95D:  20 FE             bra      $b95d ; $B95D=loc_B95D | xrefs $B95D:branch

sub_B95F:
B95F:  CE 00 4B          ldx      #75 ; xrefs $B8EC:call
B962:  A6 00             ldaa     0, x
B964:  27 27             beq      $b98d ; $B98D=loc_B98D

loc_B966:
B966:  84 7F             anda     #127 ; xrefs $B988:branch
B968:  18 CE 55 A0       ldy      #21920

loc_B96C:
B96C:  18 A1 00          cmpa     0, y ; xrefs $B977:branch
B96F:  27 0B             beq      $b97c ; $B97C=loc_B97C
B971:  18 08             iny      
B973:  18 8C 55 B2       cpy      #21938
B977:  26 F3             bne      $b96c ; $B96C=loc_B96C
B979:  7E BA 30          jmp      $ba30 ; $BA30=loc_BA30

loc_B97C:
B97C:  9C 5B             cpx      $5b ; xrefs $B96F:branch
B97E:  27 14             beq      $b994 ; $B994=loc_B994
B980:  8C 00 5A          cpx      #90
B983:  27 08             beq      $b98d ; $B98D=loc_B98D
B985:  08                inx      
B986:  A6 00             ldaa     0, x
B988:  26 DC             bne      $b966 ; $B966=loc_B966
B98A:  7E BA 30          jmp      $ba30 ; $BA30=loc_BA30

loc_B98D:
B98D:  9C 5B             cpx      $5b ; xrefs $B964:branch, $B983:branch
B98F:  27 03             beq      $b994 ; $B994=loc_B994
B991:  7E BA 30          jmp      $ba30 ; $BA30=loc_BA30

loc_B994:
B994:  8C 00 5A          cpx      #90 ; xrefs $B97E:branch, $B98F:branch, $B99C:branch
B997:  27 08             beq      $b9a1 ; $B9A1=loc_B9A1
B999:  08                inx      
B99A:  A6 00             ldaa     0, x
B99C:  27 F6             beq      $b994 ; $B994=loc_B994
B99E:  7E BA 30          jmp      $ba30 ; $BA30=loc_BA30

loc_B9A1:
B9A1:  96 91             ldaa     $91 ; xrefs $B997:branch
B9A3:  27 04             beq      $b9a9 ; $B9A9=loc_B9A9
B9A5:  81 06             cmpa     #6
B9A7:  23 03             bls      $b9ac ; $B9AC=loc_B9AC

loc_B9A9:
B9A9:  7E BA 30          jmp      $ba30 ; $BA30=loc_BA30 | xrefs $B9A3:branch

loc_B9AC:
B9AC:  CE 00 60          ldx      #96 ; xrefs $B9A7:branch
B9AF:  B6 90 5A          ldaa     $905a
B9B2:  C6 80             ldab     #-128

loc_B9B4:
B9B4:  A1 00             cmpa     0, x ; xrefs $B9C6:branch
B9B6:  2D 78             blt      $ba30 ; $BA30=loc_BA30
B9B8:  43                coma     
B9B9:  A1 00             cmpa     0, x
B9BB:  2F 04             ble      $b9c1 ; $B9C1=loc_B9C1
B9BD:  E1 00             cmpb     0, x
B9BF:  26 6F             bne      $ba30 ; $BA30=loc_BA30

loc_B9C1:
B9C1:  43                coma      ; xrefs $B9BB:branch
B9C2:  08                inx      
B9C3:  8C 00 69          cpx      #105
B9C6:  26 EC             bne      $b9b4 ; $B9B4=loc_B9B4
B9C8:  CE 00 69          ldx      #105
B9CB:  B6 90 5A          ldaa     $905a
B9CE:  C6 80             ldab     #-128

loc_B9D0:
B9D0:  A1 00             cmpa     0, x ; xrefs $B9E2:branch
B9D2:  2D 5C             blt      $ba30 ; $BA30=loc_BA30
B9D4:  43                coma     
B9D5:  A1 00             cmpa     0, x
B9D7:  2F 04             ble      $b9dd ; $B9DD=loc_B9DD
B9D9:  E1 00             cmpb     0, x
B9DB:  26 53             bne      $ba30 ; $BA30=loc_BA30

loc_B9DD:
B9DD:  43                coma      ; xrefs $B9D7:branch
B9DE:  08                inx      
B9DF:  8C 00 72          cpx      #114
B9E2:  26 EC             bne      $b9d0 ; $B9D0=loc_B9D0
B9E4:  96 11             ldaa     $11
B9E6:  B1 89 91          cmpa     $8991
B9E9:  22 45             bhi      $ba30 ; $BA30=loc_BA30
B9EB:  96 10             ldaa     $10
B9ED:  B1 89 90          cmpa     $8990
B9F0:  25 3E             bcs      $ba30 ; $BA30=loc_BA30
B9F2:  DE 08             ldx      $08
B9F4:  BC 8F F5          cpx      $8ff5
B9F7:  2E 37             bgt      $ba30 ; $BA30=loc_BA30
B9F9:  BC 8F F7          cpx      $8ff7
B9FC:  2D 32             blt      $ba30 ; $BA30=loc_BA30
B9FE:  DE 0C             ldx      $0c
BA00:  BC 8F F9          cpx      $8ff9
BA03:  2E 2B             bgt      $ba30 ; $BA30=loc_BA30
BA05:  BC 8F FB          cpx      $8ffb
BA08:  2D 26             blt      $ba30 ; $BA30=loc_BA30
BA0A:  DE 0A             ldx      $0a
BA0C:  8C 00 FF          cpx      #255
BA0F:  2E 1F             bgt      $ba30 ; $BA30=loc_BA30
BA11:  8C FF 00          cpx      #-256
BA14:  2D 1A             blt      $ba30 ; $BA30=loc_BA30
BA16:  DE 0E             ldx      $0e
BA18:  8C 00 FF          cpx      #255
BA1B:  2E 13             bgt      $ba30 ; $BA30=loc_BA30
BA1D:  8C FF 00          cpx      #-256
BA20:  2D 0E             blt      $ba30 ; $BA30=loc_BA30
BA22:  DE 06             ldx      $06
BA24:  BC 8F F1          cpx      $8ff1
BA27:  2E 07             bgt      $ba30 ; $BA30=loc_BA30
BA29:  BC 8F F3          cpx      $8ff3
BA2C:  2D 02             blt      $ba30 ; $BA30=loc_BA30
BA2E:  20 03             bra      $ba33 ; $BA33=loc_BA33

loc_BA30:
BA30:  BD 63 6C          jsr      $636c ; $636C=sub_636C | xrefs $B979:jump, $B98A:jump, $B991:jump, $B99E:jump, $B9A9:jump, $B9B6:branch, $B9BF:branch, $B9D2:branch, +13 more

loc_BA33:
BA33:  39                rts       ; xrefs $BA2E:branch

sub_BA34:
BA34:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis | xrefs $D60D:call
BA37:  83 04 00          subd     #1024
BA3A:  24 03             bcc      $ba3f ; $BA3F=loc_BA3F
BA3C:  CC 00 00          ldd      #0

loc_BA3F:
BA3F:  18 CE 24 32       ldy      #9266 ; xrefs $BA3A:branch
BA43:  18 ED 00          std      0, y
BA46:  FC 20 46          ldd      $2046 ; $2046=spark_transition_axis
BA49:  18 ED 02          std      2, y
BA4C:  CC 8A 0A          ldd      #-30198
BA4F:  18 ED 04          std      4, y
BA52:  C6 05             ldab     #5
BA54:  18 E7 06          stab     6, y
BA57:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
BA5A:  B7 20 BB          staa     $20bb

; [STRONG] Lookup ignition output phase/width/retard support vectors.
ignition_output_vector_lookup:
BA5D:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
BA60:  18 CE 8A 27       ldy      #-30169
BA64:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BA67:  B7 20 DD          staa     $20dd
BA6A:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
BA6D:  18 CE 89 C7       ldy      #-30265
BA71:  BD B2 BA          jsr      $b2ba ; $B2BA=interp_1d_s8
BA74:  B7 20 E7          staa     $20e7
BA77:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
BA7A:  18 CE 89 DA       ldy      #-30246
BA7E:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BA81:  B7 20 E8          staa     $20e8
BA84:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
BA87:  18 CE 8A 3A       ldy      #-30150
BA8B:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BA8E:  B7 20 D4          staa     $20d4
BA91:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
BA94:  18 CE 8A 52       ldy      #-30126
BA98:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BA9B:  B7 20 E6          staa     $20e6
BA9E:  96 D6             ldaa     $d6
BAA0:  84 0F             anda     #15
BAA2:  26 03             bne      $baa7 ; $BAA7=loc_BAA7
BAA4:  7E BB 3D          jmp      $bb3d ; $BB3D=loc_BB3D

loc_BAA7:
BAA7:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19 | xrefs $BAA2:branch
BAAA:  18 CE 89 F3       ldy      #-30221
BAAE:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BAB1:  B7 20 BC          staa     $20bc
BAB4:  5F                clrb     
BAB5:  FD 24 2F          std      $242f
BAB8:  D6 D0             ldab     $d0 ; $00D0=load_aircharge_byte
BABA:  B6 8A 07          ldaa     $8a07
BABD:  3D                mul      
BABE:  F3 24 2F          addd     $242f
BAC1:  24 03             bcc      $bac6 ; $BAC6=loc_BAC6
BAC3:  CC FF FF          ldd      #-1

loc_BAC6:
BAC6:  FD 24 2F          std      $242f ; xrefs $BAC1:branch
BAC9:  13 D6 08 19       brclr    $d6, #8, $bae6 ; $BAE6=loc_BAE6
BACD:  15 D6 08          bclr     $d6, #8
BAD0:  CE 20 C8          ldx      #8392
BAD3:  18 CE 89 EE       ldy      #-30226
BAD7:  B6 24 23          ldaa     $2423
BADA:  F6 89 ED          ldab     $89ed
BADD:  BD BB 3F          jsr      $bb3f ; $BB3F=sub_BB3F
BAE0:  B7 20 C3          staa     $20c3
BAE3:  F7 20 BE          stab     $20be

loc_BAE6:
BAE6:  13 D6 04 19       brclr    $d6, #4, $bb03 ; $BB03=loc_BB03 | xrefs $BAC9:branch
BAEA:  15 D6 04          bclr     $d6, #4
BAED:  CE 20 CA          ldx      #8394
BAF0:  18 CE 89 EF       ldy      #-30225
BAF4:  B6 24 24          ldaa     $2424
BAF7:  F6 89 ED          ldab     $89ed
BAFA:  BD BB 3F          jsr      $bb3f ; $BB3F=sub_BB3F
BAFD:  B7 20 C4          staa     $20c4
BB00:  F7 20 BF          stab     $20bf

loc_BB03:
BB03:  13 D6 02 19       brclr    $d6, #2, $bb20 ; $BB20=loc_BB20 | xrefs $BAE6:branch
BB07:  15 D6 02          bclr     $d6, #2
BB0A:  CE 20 CC          ldx      #8396
BB0D:  18 CE 89 EE       ldy      #-30226
BB11:  B6 24 25          ldaa     $2425
BB14:  F6 89 ED          ldab     $89ed
BB17:  BD BB 3F          jsr      $bb3f ; $BB3F=sub_BB3F
BB1A:  B7 20 C5          staa     $20c5
BB1D:  F7 20 C0          stab     $20c0

loc_BB20:
BB20:  13 D6 01 19       brclr    $d6, #1, $bb3d ; $BB3D=loc_BB3D | xrefs $BB03:branch
BB24:  15 D6 01          bclr     $d6, #1
BB27:  CE 20 C6          ldx      #8390
BB2A:  18 CE 89 EF       ldy      #-30225
BB2E:  B6 24 22          ldaa     $2422
BB31:  F6 89 ED          ldab     $89ed
BB34:  BD BB 3F          jsr      $bb3f ; $BB3F=sub_BB3F
BB37:  B7 20 C2          staa     $20c2
BB3A:  F7 20 BD          stab     $20bd

loc_BB3D:
BB3D:  39                rts       ; xrefs $BAA4:jump, $BB20:branch

; ---- unreached/data gap $BB3E-$BB3E ----

        .org $BB3F

sub_BB3F:
BB3F:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6 | xrefs $BADD:call, $BAFA:call, $BB17:call, $BB34:call
BB42:  ED 00             std      0, x
BB44:  F6 8A 06          ldab     $8a06
BB47:  26 05             bne      $bb4e ; $BB4E=loc_BB4E
BB49:  B6 24 2F          ldaa     $242f
BB4C:  20 0B             bra      $bb59 ; $BB59=loc_BB59

loc_BB4E:
BB4E:  3D                mul       ; xrefs $BB47:branch
BB4F:  40                nega     
BB50:  50                negb     
BB51:  82 00             sbca     #0
BB53:  F3 24 2F          addd     $242f
BB56:  25 01             bcs      $bb59 ; $BB59=loc_BB59
BB58:  4F                clra     

loc_BB59:
BB59:  36                psha      ; xrefs $BB4C:branch, $BB56:branch
BB5A:  E6 00             ldab     0, x
BB5C:  3D                mul      
BB5D:  E3 00             addd     0, x
BB5F:  25 28             bcs      $bb89 ; $BB89=loc_BB89
BB61:  18 E6 00          ldab     0, y
BB64:  3D                mul      
BB65:  05                asld     
BB66:  25 21             bcs      $bb89 ; $BB89=loc_BB89
BB68:  B7 24 31          staa     $2431
BB6B:  F6 20 C1          ldab     $20c1
BB6E:  27 0C             beq      $bb7c ; $BB7C=loc_BB7C
BB70:  F6 89 F0          ldab     $89f0
BB73:  3D                mul      
BB74:  BB 24 31          adda     $2431
BB77:  25 10             bcs      $bb89 ; $BB89=loc_BB89
BB79:  B7 24 31          staa     $2431

loc_BB7C:
BB7C:  13 A3 01 0D       brclr    $a3, #1, $bb8d ; $BB8D=loc_BB8D | xrefs $BB6E:branch
BB80:  F6 89 F2          ldab     $89f2
BB83:  3D                mul      
BB84:  BB 24 31          adda     $2431
BB87:  24 04             bcc      $bb8d ; $BB8D=loc_BB8D

loc_BB89:
BB89:  86 FF             ldaa     #-1 ; xrefs $BB5F:branch, $BB66:branch, $BB77:branch
BB8B:  20 08             bra      $bb95 ; $BB95=loc_BB95

loc_BB8D:
BB8D:  B1 8A 08          cmpa     $8a08 ; xrefs $BB7C:branch, $BB87:branch
BB90:  24 03             bcc      $bb95 ; $BB95=loc_BB95
BB92:  B6 8A 08          ldaa     $8a08

loc_BB95:
BB95:  33                pulb      ; xrefs $BB8B:branch, $BB90:branch
BB96:  39                rts      

; ---- unreached/data gap $BB97-$BB97 ----

        .org $BB98

; [STRONG] Initialize ignition output/vector state.
ignition_output_init:
BB98:  4F                clra      ; xrefs $B91F:call
BB99:  5F                clrb     
BB9A:  FD 20 EB          std      $20eb
BB9D:  FD 20 ED          std      $20ed
BBA0:  97 D6             staa     $d6
BBA2:  97 D7             staa     $d7
BBA4:  B7 20 D2          staa     $20d2
BBA7:  B7 20 DA          staa     $20da
BBAA:  B7 20 DB          staa     $20db
BBAD:  B7 20 DC          staa     $20dc
BBB0:  B7 20 D9          staa     $20d9
BBB3:  B7 20 D3          staa     $20d3
BBB6:  B7 20 DF          staa     $20df
BBB9:  B7 20 E0          staa     $20e0
BBBC:  B7 20 E1          staa     $20e1
BBBF:  B7 20 DE          staa     $20de
BBC2:  B7 24 2A          staa     $242a
BBC5:  FD 24 26          std      $2426
BBC8:  B7 20 C1          staa     $20c1
BBCB:  FC 8A 4F          ldd      $8a4f
BBCE:  FD 24 28          std      $2428
BBD1:  B6 89 C7          ldaa     $89c7 ; $89C7=ignition_phase_factor_1x19
BBD4:  B7 20 E7          staa     $20e7
BBD7:  B6 89 DA          ldaa     $89da ; $89DA=ignition_width_factor_1x19
BBDA:  B7 20 E8          staa     $20e8
BBDD:  B6 8A 3A          ldaa     $8a3a
BBE0:  B7 20 D4          staa     $20d4
BBE3:  B6 8A 52          ldaa     $8a52
BBE6:  B7 20 E6          staa     $20e6
BBE9:  B6 89 F3          ldaa     $89f3 ; $89F3=ignition_retard_gain_1x19
BBEC:  B7 20 BC          staa     $20bc
BBEF:  B6 8A 27          ldaa     $8a27
BBF2:  B7 20 DD          staa     $20dd
BBF5:  86 FF             ldaa     #-1
BBF7:  C6 FF             ldab     #-1
BBF9:  B7 20 C3          staa     $20c3
BBFC:  B7 20 C4          staa     $20c4
BBFF:  B7 20 C5          staa     $20c5
BC02:  B7 20 C2          staa     $20c2
BC05:  FD 20 C8          std      $20c8
BC08:  FD 20 CA          std      $20ca
BC0B:  FD 20 CC          std      $20cc
BC0E:  FD 20 C6          std      $20c6
BC11:  39                rts      

sub_BC12:
BC12:  96 93             ldaa     $93 ; xrefs $B8F2:call
BC14:  27 03             beq      $bc19 ; $BC19=loc_BC19
BC16:  7A 00 93          dec      >$0093

loc_BC19:
BC19:  39                rts       ; xrefs $BC14:branch

sub_BC1A:
BC1A:  CE 10 00          ldx      #4096 ; xrefs $7F46:call, $7FB9:call
BC1D:  12 D7 10 3A       brset    $d7, #16, $bc5b ; $BC5B=loc_BC5B
BC21:  86 00             ldaa     #0
BC23:  B7 10 30          staa     $1030 ; $1030=ADCTL
BC26:  C6 07             ldab     #7

loc_BC28:
BC28:  5A                decb      ; xrefs $BC29:branch
BC29:  26 FD             bne      $bc28 ; $BC28=loc_BC28
BC2B:  B6 10 31          ldaa     $1031 ; $1031=ADR1
BC2E:  16                tab      
BC2F:  B6 8A 66          ldaa     $8a66
BC32:  27 11             beq      $bc45 ; $BC45=loc_BC45
BC34:  13 D7 20 11       brclr    $d7, #32, $bc49 ; $BC49=loc_BC49
BC38:  17                tba      
BC39:  B1 8A 67          cmpa     $8a67
BC3C:  24 07             bcc      $bc45 ; $BC45=loc_BC45
BC3E:  86 FF             ldaa     #-1
BC40:  B7 20 EF          staa     $20ef
BC43:  20 16             bra      $bc5b ; $BC5B=loc_BC5B

loc_BC45:
BC45:  4F                clra      ; xrefs $BC32:branch, $BC3C:branch
BC46:  B7 20 EF          staa     $20ef

loc_BC49:
BC49:  17                tba       ; xrefs $BC34:branch
BC4A:  18 CE 20 CE       ldy      #8398
BC4E:  F6 20 E9          ldab     $20e9
BC51:  C1 04             cmpb     #4
BC53:  25 01             bcs      $bc56 ; $BC56=loc_BC56
BC55:  5F                clrb     

loc_BC56:
BC56:  18 3A             aby       ; xrefs $BC53:branch
BC58:  18 A7 00          staa     0, y

loc_BC5B:
BC5B:  1C 20 0C          bset     32, x; #12 ; xrefs $BC1D:branch, $BC43:branch
BC5E:  1C 0B 10          bset     11, x; #16
BC61:  1C 22 10          bset     34, x; #16
BC64:  FC 24 2B          ldd      $242b
BC67:  F3 20 EB          addd     $20eb
BC6A:  FD 10 1C          std      $101c ; $101C=TOC4
BC6D:  1D 20 04          bclr     32, x; #4
BC70:  FC 10 0E          ldd      $100e ; $100E=TCNT
BC73:  C3 00 20          addd     #32
BC76:  B3 24 2B          subd     $242b
BC79:  1A B3 20 EB       cpd      $20eb
BC7D:  24 07             bcc      $bc86 ; $BC86=loc_BC86
BC7F:  C6 10             ldab     #16
BC81:  F7 10 23          stab     $1023 ; $1023=TFLG1
BC84:  20 09             bra      $bc8f ; $BC8F=loc_BC8F

loc_BC86:
BC86:  FC 10 0E          ldd      $100e ; $100E=TCNT | xrefs $BC7D:branch
BC89:  C3 00 10          addd     #16
BC8C:  FD 10 1C          std      $101c ; $101C=TOC4

loc_BC8F:
BC8F:  39                rts       ; xrefs $BC84:branch

; ---- unreached/data gap $BC90-$BC90 ----

        .org $BC91
BC91:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
BC94:  81 06             cmpa     #6
BC96:  26 03             bne      $bc9b ; $BC9B=loc_BC9B
BC98:  7E E1 05          jmp      $e105 ; $E105=loc_E105

loc_BC9B:
BC9B:  CE 10 00          ldx      #4096 ; xrefs $BC96:branch
BC9E:  1F 20 08 2C       brclr    32, x; #8; $bcce ; $BCCE=loc_BCCE
BCA2:  1D 00 10          bclr     0, x; #16
BCA5:  1D 20 0C          bclr     32, x; #12
BCA8:  15 D7 10          bclr     $d7, #16
BCAB:  FC 10 1C          ldd      $101c ; $101C=TOC4
BCAE:  FD 24 2D          std      $242d
BCB1:  F3 20 ED          addd     $20ed
BCB4:  FD 10 1C          std      $101c ; $101C=TOC4
BCB7:  FC 10 0E          ldd      $100e ; $100E=TCNT
BCBA:  C3 00 0A          addd     #10
BCBD:  B3 24 2D          subd     $242d
BCC0:  1A B3 20 ED       cpd      $20ed
BCC4:  24 08             bcc      $bcce ; $BCCE=loc_BCCE
BCC6:  86 10             ldaa     #16
BCC8:  B7 10 23          staa     $1023 ; $1023=TFLG1
BCCB:  7E BD 11          jmp      $bd11 ; $BD11=loc_BD11

loc_BCCE:
BCCE:  86 00             ldaa     #0 ; xrefs $BC9E:branch, $BCC4:branch
BCD0:  B7 10 30          staa     $1030 ; $1030=ADCTL
BCD3:  C6 07             ldab     #7

loc_BCD5:
BCD5:  5A                decb      ; xrefs $BCD6:branch
BCD6:  26 FD             bne      $bcd5 ; $BCD5=loc_BCD5
BCD8:  B6 10 31          ldaa     $1031 ; $1031=ADR1
BCDB:  16                tab      
BCDC:  B6 8A 66          ldaa     $8a66
BCDF:  27 11             beq      $bcf2 ; $BCF2=loc_BCF2
BCE1:  13 D7 20 11       brclr    $d7, #32, $bcf6 ; $BCF6=loc_BCF6
BCE5:  17                tba      
BCE6:  B1 8A 67          cmpa     $8a67
BCE9:  24 07             bcc      $bcf2 ; $BCF2=loc_BCF2
BCEB:  86 FF             ldaa     #-1
BCED:  B7 20 EF          staa     $20ef
BCF0:  20 16             bra      $bd08 ; $BD08=loc_BD08

loc_BCF2:
BCF2:  4F                clra      ; xrefs $BCDF:branch, $BCE9:branch
BCF3:  B7 20 EF          staa     $20ef

loc_BCF6:
BCF6:  17                tba       ; xrefs $BCE1:branch
BCF7:  18 CE 20 CE       ldy      #8398
BCFB:  F6 20 E9          ldab     $20e9
BCFE:  C1 04             cmpb     #4
BD00:  25 01             bcs      $bd03 ; $BD03=loc_BD03
BD02:  5F                clrb     

loc_BD03:
BD03:  18 3A             aby       ; xrefs $BD00:branch
BD05:  18 A7 00          staa     0, y

loc_BD08:
BD08:  14 D7 10          bset     $d7, #16 ; xrefs $BCF0:branch
BD0B:  1C 00 10          bset     0, x; #16
BD0E:  1D 22 10          bclr     34, x; #16

loc_BD11:
BD11:  3B                rti       ; xrefs $BCCB:jump

; ---- unreached/data gap $BD12-$BD12 ----

        .org $BD13

sub_BD13:
BD13:  3C                pshx      ; xrefs $7740:call
BD14:  C6 03             ldab     #3
BD16:  37                pshb     
BD17:  18 30             tsy      
BD19:  DC B8             ldd      $b8 ; $00B8=previous_capture_or_schedule_base
BD1B:  FD 24 2B          std      $242b
BD1E:  B6 20 E7          ldaa     $20e7
BD21:  2A 0D             bpl      $bd30 ; $BD30=loc_BD30
BD23:  40                nega     
BD24:  18 A7 01          staa     1, y
BD27:  BD BD 59          jsr      $bd59 ; $BD59=sub_BD59
BD2A:  40                nega     
BD2B:  50                negb     
BD2C:  82 00             sbca     #0
BD2E:  20 06             bra      $bd36 ; $BD36=loc_BD36

loc_BD30:
BD30:  18 A7 01          staa     1, y ; xrefs $BD21:branch
BD33:  BD BD 59          jsr      $bd59 ; $BD59=sub_BD59

loc_BD36:
BD36:  F3 00 BA          addd     >$00ba ; $00BA=engine_period_delta | xrefs $BD2E:branch
BD39:  FD 20 EB          std      $20eb
BD3C:  FC 00 BA          ldd      >$00ba ; $00BA=engine_period_delta
BD3F:  37                pshb     
BD40:  F6 20 E8          ldab     $20e8
BD43:  3D                mul      
BD44:  8F                xgdx     
BD45:  32                pula     
BD46:  F6 20 E8          ldab     $20e8
BD49:  3D                mul      
BD4A:  89 00             adca     #0
BD4C:  16                tab      
BD4D:  3A                abx      
BD4E:  8F                xgdx     
BD4F:  FD 20 ED          std      $20ed
BD52:  33                pulb     
BD53:  18 3A             aby      
BD55:  18 35             tys      
BD57:  39                rts      

; ---- unreached/data gap $BD58-$BD58 ----

        .org $BD59

sub_BD59:
BD59:  FC 00 BA          ldd      >$00ba ; $00BA=engine_period_delta | xrefs $BD27:call, $BD33:call
BD5C:  37                pshb     
BD5D:  18 E6 01          ldab     1, y
BD60:  3D                mul      
BD61:  8F                xgdx     
BD62:  32                pula     
BD63:  18 E6 01          ldab     1, y
BD66:  3D                mul      
BD67:  89 00             adca     #0
BD69:  16                tab      
BD6A:  3A                abx      
BD6B:  8F                xgdx     
BD6C:  39                rts      

; ---- unreached/data gap $BD6D-$BD6D ----

        .org $BD6E

sub_BD6E:
BD6E:  B6 24 6B          ldaa     $246b ; xrefs $4FA0:call, $506A:call, $51FB:call, $52DD:call, $5419:call, $961C:call, $96BC:call
BD71:  27 3C             beq      $bdaf ; $BDAF=loc_BDAF
BD73:  F6 24 6C          ldab     $246c
BD76:  26 10             bne      $bd88 ; $BD88=loc_BD88
BD78:  CE 24 72          ldx      #9330
BD7B:  FF 24 70          stx      $2470
BD7E:  81 0C             cmpa     #12
BD80:  27 2F             beq      $bdb1 ; $BDB1=loc_BDB1
BD82:  81 0E             cmpa     #14
BD84:  27 46             beq      $bdcc ; $BDCC=loc_BDCC
BD86:  20 3B             bra      $bdc3 ; $BDC3=loc_BDC3

loc_BD88:
BD88:  5A                decb      ; xrefs $BD76:branch
BD89:  F7 24 6C          stab     $246c
BD8C:  26 15             bne      $bda3 ; $BDA3=loc_BDA3
BD8E:  7F 10 3B          clr      $103b
BD91:  FE 24 6E          ldx      $246e
BD94:  08                inx      
BD95:  FF 24 6E          stx      $246e
BD98:  7A 24 6D          dec      $246d
BD9B:  27 0F             beq      $bdac ; $BDAC=loc_BDAC
BD9D:  81 1A             cmpa     #26
BD9F:  27 22             beq      $bdc3 ; $BDC3=loc_BDC3
BDA1:  20 29             bra      $bdcc ; $BDCC=loc_BDCC

loc_BDA3:
BDA3:  C1 05             cmpb     #5 ; xrefs $BD8C:branch
BDA5:  26 08             bne      $bdaf ; $BDAF=loc_BDAF
BDA7:  7F 10 3B          clr      $103b
BDAA:  20 20             bra      $bdcc ; $BDCC=loc_BDCC

loc_BDAC:
BDAC:  7F 24 6B          clr      $246b ; xrefs $BD9B:branch

loc_BDAF:
BDAF:  20 3A             bra      $bdeb ; $BDEB=loc_BDEB | xrefs $BD71:branch, $BDA5:branch

loc_BDB1:
BDB1:  86 01             ldaa     #1 ; xrefs $BD80:branch
BDB3:  B7 24 6D          staa     $246d
BDB6:  86 05             ldaa     #5
BDB8:  B7 24 6C          staa     $246c
BDBB:  C6 06             ldab     #6
BDBD:  18 CE B6 00       ldy      #-18944
BDC1:  20 1D             bra      $bde0 ; $BDE0=loc_BDE0

loc_BDC3:
BDC3:  86 0A             ldaa     #10 ; xrefs $BD86:branch, $BD9F:branch
BDC5:  B7 24 6C          staa     $246c
BDC8:  C6 16             ldab     #22
BDCA:  20 10             bra      $bddc ; $BDDC=loc_BDDC

loc_BDCC:
BDCC:  86 05             ldaa     #5 ; xrefs $BD84:branch, $BDA1:branch, $BDAA:branch
BDCE:  B7 24 6C          staa     $246c
BDD1:  FE 24 70          ldx      $2470
BDD4:  A6 00             ldaa     0, x
BDD6:  08                inx      
BDD7:  FF 24 70          stx      $2470
BDDA:  C6 02             ldab     #2

loc_BDDC:
BDDC:  18 FE 24 6E       ldy      $246e ; xrefs $BDCA:branch

loc_BDE0:
BDE0:  CE 10 00          ldx      #4096 ; xrefs $BDC1:branch
BDE3:  E7 3B             stab     59, x
BDE5:  18 A7 00          staa     0, y
BDE8:  1C 3B 01          bset     59, x; #1

loc_BDEB:
BDEB:  39                rts       ; xrefs $BDAF:branch

sub_BDEC:
BDEC:  7F 24 6B          clr      $246b ; xrefs $4F6E:call, $968B:call, $B88A:call, $D86F:call
BDEF:  7F 24 6C          clr      $246c
BDF2:  7F 10 3B          clr      $103b
BDF5:  39                rts      

sub_BDF6:
BDF6:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $9681:call
BDF9:  81 0C             cmpa     #12
BDFB:  26 06             bne      $be03 ; $BE03=loc_BE03
BDFD:  BD 97 07          jsr      $9707 ; $9707=sub_9707
BE00:  7E BF 60          jmp      $bf60 ; $BF60=loc_BF60

loc_BE03:
BE03:  B6 24 8B          ldaa     $248b ; xrefs $BDFB:branch
BE06:  27 06             beq      $be0e ; $BE0E=loc_BE0E
BE08:  15 A9 04          bclr     $a9, #4 ; $00A9=operating_mode_flags
BE0B:  7E BF 25          jmp      $bf25 ; $BF25=loc_BF25

loc_BE0E:
BE0E:  D6 D0             ldab     $d0 ; $00D0=load_aircharge_byte | xrefs $BE06:branch
BE10:  12 A9 04 1B       brset    $a9, #4, $be2f ; $00A9=operating_mode_flags, $BE2F=loc_BE2F
BE14:  B6 20 59          ldaa     $2059
BE17:  81 04             cmpa     #4
BE19:  26 23             bne      $be3e ; $BE3E=loc_BE3E
BE1B:  13 A3 91 1F       brclr    $a3, #-111, $be3e ; $BE3E=loc_BE3E
BE1F:  F1 88 8B          cmpb     $888b
BE22:  23 1A             bls      $be3e ; $BE3E=loc_BE3E
BE24:  14 A9 04          bset     $a9, #4 ; $00A9=operating_mode_flags
BE27:  B6 89 6B          ldaa     $896b
BE2A:  B7 24 87          staa     $2487
BE2D:  20 0C             bra      $be3b ; $BE3B=loc_BE3B

loc_BE2F:
BE2F:  13 A3 91 05       brclr    $a3, #-111, $be38 ; $BE38=loc_BE38 | xrefs $BE10:branch
BE33:  F1 88 8C          cmpb     $888c
BE36:  24 06             bcc      $be3e ; $BE3E=loc_BE3E

loc_BE38:
BE38:  15 A9 04          bclr     $a9, #4 ; $00A9=operating_mode_flags | xrefs $BE2F:branch

loc_BE3B:
BE3B:  14 9D 40          bset     $9d, #64 ; xrefs $BE2D:branch

loc_BE3E:
BE3E:  12 9D 40 08       brset    $9d, #64, $be4a ; $BE4A=loc_BE4A | xrefs $BE19:branch, $BE1B:branch, $BE22:branch, $BE36:branch
BE42:  7A 24 82          dec      $2482
BE45:  27 03             beq      $be4a ; $BE4A=loc_BE4A
BE47:  7E BE F2          jmp      $bef2 ; $BEF2=loc_BEF2

loc_BE4A:
BE4A:  F6 88 8D          ldab     $888d ; xrefs $BE3E:branch, $BE45:branch
BE4D:  F7 24 82          stab     $2482
BE50:  12 A9 04 06       brset    $a9, #4, $be5a ; $00A9=operating_mode_flags, $BE5A=loc_BE5A
BE54:  F6 89 66          ldab     $8966
BE57:  7E BE E4          jmp      $bee4 ; $BEE4=loc_BEE4

loc_BE5A:
BE5A:  7A 24 89          dec      $2489 ; xrefs $BE50:branch
BE5D:  27 06             beq      $be65 ; $BE65=idle_air_control
BE5F:  F6 20 2B          ldab     $202b
BE62:  7E BE E4          jmp      $bee4 ; $BEE4=loc_BEE4

; [STRONG] Interpolate 0x888E and CTS support 0x8970, update 0x2484/0x2486 and actuator state.
idle_air_control:
BE65:  B6 89 6E          ldaa     $896e ; xrefs $BE5D:branch
BE68:  B7 24 89          staa     $2489
BE6B:  13 A9 40 05       brclr    $a9, #64, $be74 ; $00A9=operating_mode_flags, $BE74=loc_BE74
BE6F:  B6 89 67          ldaa     $8967
BE72:  20 1F             bra      $be93 ; $BE93=loc_BE93

loc_BE74:
BE74:  18 CE 24 8F       ldy      #9359 ; xrefs $BE6B:branch
BE78:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
BE7B:  18 ED 00          std      0, y
BE7E:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
BE81:  18 ED 02          std      2, y
BE84:  CC 88 8E          ldd      #-30578
BE87:  18 ED 04          std      4, y
BE8A:  B6 92 90          ldaa     $9290
BE8D:  18 A7 06          staa     6, y
BE90:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8

loc_BE93:
BE93:  B7 24 84          staa     $2484 ; $2484=idle_air_target | xrefs $BE72:branch
BE96:  18 CE 89 70       ldy      #-30352
BE9A:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
BE9D:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
BEA0:  B7 24 86          staa     $2486 ; $2486=idle_cts_target_or_cap
BEA3:  B1 24 85          cmpa     $2485
BEA6:  24 03             bcc      $beab ; $BEAB=loc_BEAB
BEA8:  B6 24 85          ldaa     $2485

loc_BEAB:
BEAB:  16                tab       ; xrefs $BEA6:branch
BEAC:  86 FF             ldaa     #-1
BEAE:  10                sba      
BEAF:  F6 24 84          ldab     $2484 ; $2484=idle_air_target
BEB2:  3D                mul      
BEB3:  89 00             adca     #0
BEB5:  F6 24 87          ldab     $2487
BEB8:  3D                mul      
BEB9:  89 00             adca     #0
BEBB:  36                psha     
BEBC:  B6 8E 6C          ldaa     $8e6c
BEBF:  B0 24 9B          suba     $249b
BEC2:  24 01             bcc      $bec5 ; $BEC5=loc_BEC5
BEC4:  4F                clra     

loc_BEC5:
BEC5:  F6 89 6D          ldab     $896d ; xrefs $BEC2:branch
BEC8:  3D                mul      
BEC9:  89 00             adca     #0
BECB:  B7 24 88          staa     $2488
BECE:  16                tab      
BECF:  32                pula     
BED0:  10                sba      
BED1:  24 01             bcc      $bed4 ; $BED4=loc_BED4
BED3:  4F                clra     

loc_BED4:
BED4:  12 9D 40 0C       brset    $9d, #64, $bee4 ; $BEE4=loc_BEE4 | xrefs $BED1:branch
BED8:  F6 20 2B          ldab     $202b
BEDB:  11                cba      
BEDC:  27 06             beq      $bee4 ; $BEE4=loc_BEE4
BEDE:  22 03             bhi      $bee3 ; $BEE3=loc_BEE3
BEE0:  5A                decb     
BEE1:  20 01             bra      $bee4 ; $BEE4=loc_BEE4

loc_BEE3:
BEE3:  5C                incb      ; xrefs $BEDE:branch

loc_BEE4:
BEE4:  15 9D 40          bclr     $9d, #64 ; xrefs $BE57:jump, $BE62:jump, $BED4:branch, $BEDC:branch, $BEE1:branch
BEE7:  F7 20 2B          stab     $202b
BEEA:  F7 24 83          stab     $2483
BEED:  86 20             ldaa     #32
BEEF:  B7 20 2C          staa     $202c

loc_BEF2:
BEF2:  F6 24 83          ldab     $2483 ; xrefs $BE47:jump
BEF5:  26 05             bne      $befc ; $BEFC=loc_BEFC
BEF7:  7F 20 2C          clr      $202c
BEFA:  20 29             bra      $bf25 ; $BF25=loc_BF25

loc_BEFC:
BEFC:  7A 24 83          dec      $2483 ; xrefs $BEF5:branch
BEFF:  7D 88 8A          tst      $888a
BF02:  26 26             bne      $bf2a ; $BF2A=loc_BF2A

loc_BF04:
BF04:  CE 10 00          ldx      #4096 ; xrefs $BF28:branch
BF07:  1D 50 04          bclr     80, x; #4
BF0A:  B6 20 B1          ldaa     $20b1 ; $20B1=spark_fuel_bank_selector
BF0D:  27 0F             beq      $bf1e ; $BF1E=loc_BF1E
BF0F:  BD BF 62          jsr      $bf62 ; $BF62=sub_BF62
BF12:  1E 80 10 02       brset    128, x; #16; $bf18 ; $BF18=loc_BF18
BF16:  20 06             bra      $bf1e ; $BF1E=loc_BF1E

loc_BF18:
BF18:  4F                clra      ; xrefs $BF12:branch
BF19:  B7 24 8D          staa     $248d
BF1C:  20 2B             bra      $bf49 ; $BF49=loc_BF49

loc_BF1E:
BF1E:  86 FF             ldaa     #-1 ; xrefs $BF0D:branch, $BF16:branch
BF20:  B7 24 8D          staa     $248d
BF23:  20 24             bra      $bf49 ; $BF49=loc_BF49

loc_BF25:
BF25:  7D 88 8A          tst      $888a ; xrefs $BE0B:jump, $BEFA:branch
BF28:  26 DA             bne      $bf04 ; $BF04=loc_BF04

loc_BF2A:
BF2A:  CE 10 00          ldx      #4096 ; xrefs $BF02:branch
BF2D:  1C 50 04          bset     80, x; #4
BF30:  B6 20 B1          ldaa     $20b1 ; $20B1=spark_fuel_bank_selector
BF33:  27 0F             beq      $bf44 ; $BF44=loc_BF44
BF35:  BD BF 62          jsr      $bf62 ; $BF62=sub_BF62
BF38:  1F 80 10 02       brclr    128, x; #16; $bf3e ; $BF3E=loc_BF3E
BF3C:  20 06             bra      $bf44 ; $BF44=loc_BF44

loc_BF3E:
BF3E:  4F                clra      ; xrefs $BF38:branch
BF3F:  B7 24 8E          staa     $248e
BF42:  20 05             bra      $bf49 ; $BF49=loc_BF49

loc_BF44:
BF44:  86 FF             ldaa     #-1 ; xrefs $BF33:branch, $BF3C:branch
BF46:  B7 24 8E          staa     $248e

loc_BF49:
BF49:  B6 24 8D          ldaa     $248d ; xrefs $BF1C:branch, $BF23:branch, $BF42:branch
BF4C:  B4 24 8E          anda     $248e
BF4F:  27 09             beq      $bf5a ; $BF5A=loc_BF5A
BF51:  14 48 02          bset     $48, #2
BF54:  15 48 01          bclr     $48, #1
BF57:  7E BF 60          jmp      $bf60 ; $BF60=loc_BF60

loc_BF5A:
BF5A:  15 48 02          bclr     $48, #2 ; xrefs $BF4F:branch
BF5D:  14 48 01          bset     $48, #1

loc_BF60:
BF60:  39                rts       ; xrefs $BE00:jump, $BF57:jump

; ---- unreached/data gap $BF61-$BF61 ----

        .org $BF62

sub_BF62:
BF62:  B6 89 81          ldaa     $8981 ; xrefs $BF0F:call, $BF35:call
BF65:  B7 24 8C          staa     $248c

loc_BF68:
BF68:  7A 24 8C          dec      $248c ; xrefs $BF6B:branch
BF6B:  26 FB             bne      $bf68 ; $BF68=loc_BF68
BF6D:  39                rts      

; ---- unreached/data gap $BF6E-$BFFF ----

        .org $C000

; [CONFIRMED] Closed-loop/adaptive state machine using calibration region 0x9000-0x912B.
closed_loop_adaptive_state_machine:
C000:  12 9C 01 04       brset    $9c, #1, $c008 ; $009C=scheduler_status_flags, $C008=loc_C008 | xrefs $D45D:call, $D599:call
C004:  13 A6 10 03       brclr    $a6, #16, $c00b ; $C00B=loc_C00B

loc_C008:
C008:  7E C9 0E          jmp      $c90e ; $C90E=loc_C90E | xrefs $C000:branch

loc_C00B:
C00B:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $C004:branch
C00E:  81 0C             cmpa     #12
C010:  26 06             bne      $c018 ; $C018=loc_C018
C012:  BD 96 E9          jsr      $96e9 ; $96E9=sub_96E9
C015:  7E C9 0E          jmp      $c90e ; $C90E=loc_C90E

loc_C018:
C018:  B6 91 05          ldaa     $9105 ; xrefs $C010:branch
C01B:  B7 20 8F          staa     $208f
C01E:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
C021:  18 CE 90 00       ldy      #-28672
C025:  7D 00 90          tst      >$0090
C028:  27 0D             beq      $c037 ; $C037=loc_C037
C02A:  18 CE 90 22       ldy      #-28638
C02E:  7D 20 2D          tst      $202d
C031:  27 04             beq      $c037 ; $C037=loc_C037
C033:  18 CE 90 11       ldy      #-28655

loc_C037:
C037:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $C028:branch, $C031:branch
C03A:  B7 20 93          staa     $2093
C03D:  B6 20 90          ldaa     $2090
C040:  81 02             cmpa     #2
C042:  27 03             beq      $c047 ; $C047=loc_C047
C044:  7E C1 16          jmp      $c116 ; $C116=loc_C116

loc_C047:
C047:  B6 8F FF          ldaa     $8fff ; xrefs $C042:branch
C04A:  27 03             beq      $c04f ; $C04F=loc_C04F
C04C:  7E C1 0D          jmp      $c10d ; $C10D=loc_C10D

loc_C04F:
C04F:  13 D8 10 57       brclr    $d8, #16, $c0aa ; $C0AA=loc_C0AA | xrefs $C04A:branch
C053:  12 A3 10 08       brset    $a3, #16, $c05f ; $C05F=loc_C05F
C057:  13 A3 80 0C       brclr    $a3, #-128, $c067 ; $C067=loc_C067
C05B:  13 A9 40 08       brclr    $a9, #64, $c067 ; $00A9=operating_mode_flags, $C067=loc_C067

loc_C05F:
C05F:  B6 20 B0          ldaa     $20b0 ; xrefs $C053:branch
C062:  B1 91 2B          cmpa     $912b
C065:  25 03             bcs      $c06a ; $C06A=loc_C06A

loc_C067:
C067:  7E C1 0D          jmp      $c10d ; $C10D=loc_C10D | xrefs $C057:branch, $C05B:branch

loc_C06A:
C06A:  86 80             ldaa     #-128 ; xrefs $C065:branch
C06C:  BB 90 66          adda     $9066
C06F:  B1 20 32          cmpa     $2032
C072:  22 03             bhi      $c077 ; $C077=loc_C077
C074:  7E C1 0D          jmp      $c10d ; $C10D=loc_C10D

loc_C077:
C077:  C6 80             ldab     #-128 ; xrefs $C072:branch
C079:  F0 90 66          subb     $9066
C07C:  F1 20 32          cmpb     $2032
C07F:  25 03             bcs      $c084 ; $C084=loc_C084
C081:  7E C1 0D          jmp      $c10d ; $C10D=loc_C10D

loc_C084:
C084:  96 D1             ldaa     $d1 ; xrefs $C07F:branch
C086:  B1 20 A8          cmpa     $20a8
C089:  23 18             bls      $c0a3 ; $C0A3=loc_C0A3
C08B:  B6 20 96          ldaa     $2096
C08E:  BA 20 9A          oraa     $209a
C091:  BA 20 9B          oraa     $209b
C094:  BA 24 43          oraa     $2443
C097:  26 74             bne      $c10d ; $C10D=loc_C10D
C099:  7D 24 63          tst      $2463
C09C:  27 44             beq      $c0e2 ; $C0E2=loc_C0E2
C09E:  7A 24 63          dec      $2463
C0A1:  20 70             bra      $c113 ; $C113=loc_C113

loc_C0A3:
C0A3:  B6 24 3F          ldaa     $243f ; xrefs $C089:branch
C0A6:  26 65             bne      $c10d ; $C10D=loc_C10D
C0A8:  20 38             bra      $c0e2 ; $C0E2=loc_C0E2

loc_C0AA:
C0AA:  13 A3 10 5F       brclr    $a3, #16, $c10d ; $C10D=loc_C10D | xrefs $C04F:branch
C0AE:  96 D1             ldaa     $d1
C0B0:  B1 20 A8          cmpa     $20a8
C0B3:  24 0B             bcc      $c0c0 ; $C0C0=loc_C0C0
C0B5:  B6 24 3F          ldaa     $243f
C0B8:  26 53             bne      $c10d ; $C10D=loc_C10D
C0BA:  12 A5 10 4F       brset    $a5, #16, $c10d ; $C10D=loc_C10D
C0BE:  20 22             bra      $c0e2 ; $C0E2=loc_C0E2

loc_C0C0:
C0C0:  B6 20 96          ldaa     $2096 ; xrefs $C0B3:branch
C0C3:  BA 20 9A          oraa     $209a
C0C6:  BA 24 44          oraa     $2444
C0C9:  26 42             bne      $c10d ; $C10D=loc_C10D
C0CB:  13 A5 80 09       brclr    $a5, #-128, $c0d8 ; $C0D8=loc_C0D8
C0CF:  B6 20 98          ldaa     $2098
C0D2:  40                nega     
C0D3:  B1 90 5E          cmpa     $905e
C0D6:  25 35             bcs      $c10d ; $C10D=loc_C10D

loc_C0D8:
C0D8:  7D 24 63          tst      $2463 ; xrefs $C0CB:branch
C0DB:  27 05             beq      $c0e2 ; $C0E2=loc_C0E2
C0DD:  7A 24 63          dec      $2463
C0E0:  20 31             bra      $c113 ; $C113=loc_C113

loc_C0E2:
C0E2:  86 03             ldaa     #3 ; xrefs $C09C:branch, $C0A8:branch, $C0BE:branch, $C0DB:branch
C0E4:  B7 20 90          staa     $2090
C0E7:  CC 00 01          ldd      #1
C0EA:  B7 20 9B          staa     $209b
C0ED:  F7 24 41          stab     $2441
C0F0:  CC 00 00          ldd      #0
C0F3:  B7 20 96          staa     $2096
C0F6:  FD 20 91          std      $2091
C0F9:  FD 24 4D          std      $244d
C0FC:  FD 24 51          std      $2451
C0FF:  B6 20 98          ldaa     $2098
C102:  40                nega     
C103:  BB 20 A2          adda     $20a2
C106:  B7 20 A6          staa     $20a6
C109:  16                tab      
C10A:  7E C7 31          jmp      $c731 ; $C731=loc_C731

loc_C10D:
C10D:  B6 90 E9          ldaa     $90e9 ; xrefs $C04C:jump, $C067:jump, $C074:jump, $C081:jump, $C097:branch, $C0A6:branch, $C0AA:branch, $C0B8:branch, +3 more
C110:  B7 24 63          staa     $2463

loc_C113:
C113:  7E C1 A1          jmp      $c1a1 ; $C1A1=loc_C1A1 | xrefs $C0A1:branch, $C0E0:branch

loc_C116:
C116:  81 01             cmpa     #1 ; xrefs $C044:jump
C118:  26 30             bne      $c14a ; $C14A=loc_C14A
C11A:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
C11D:  18 CE 90 33       ldy      #-28621
C121:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
C124:  B7 20 96          staa     $2096
C127:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
C12A:  18 CE 90 EF       ldy      #-28433
C12E:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
C131:  B7 24 3F          staa     $243f
C134:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
C137:  18 CE 90 44       ldy      #-28604
C13B:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
C13E:  B7 24 4C          staa     $244c
C141:  B7 24 5E          staa     $245e
C144:  12 A9 02 3C       brset    $a9, #2, $c184 ; $00A9=operating_mode_flags, $C184=loc_C184
C148:  20 57             bra      $c1a1 ; $C1A1=loc_C1A1

loc_C14A:
C14A:  81 03             cmpa     #3 ; xrefs $C118:branch
C14C:  26 53             bne      $c1a1 ; $C1A1=loc_C1A1
C14E:  B6 8F FF          ldaa     $8fff
C151:  26 31             bne      $c184 ; $C184=loc_C184
C153:  13 D8 10 25       brclr    $d8, #16, $c17c ; $C17C=loc_C17C
C157:  13 A9 40 29       brclr    $a9, #64, $c184 ; $00A9=operating_mode_flags, $C184=loc_C184
C15B:  B6 91 2B          ldaa     $912b
C15E:  BB 91 2A          adda     $912a
C161:  B1 20 B0          cmpa     $20b0
C164:  23 1E             bls      $c184 ; $C184=loc_C184
C166:  86 80             ldaa     #-128
C168:  BB 90 67          adda     $9067
C16B:  B1 20 32          cmpa     $2032
C16E:  25 14             bcs      $c184 ; $C184=loc_C184
C170:  C6 80             ldab     #-128
C172:  F0 90 67          subb     $9067
C175:  F1 20 32          cmpb     $2032
C178:  23 27             bls      $c1a1 ; $C1A1=loc_C1A1
C17A:  20 08             bra      $c184 ; $C184=loc_C184

loc_C17C:
C17C:  13 A3 10 04       brclr    $a3, #16, $c184 ; $C184=loc_C184 | xrefs $C153:branch
C180:  13 A5 10 1D       brclr    $a5, #16, $c1a1 ; $C1A1=loc_C1A1

loc_C184:
C184:  CC 00 01          ldd      #1 ; xrefs $C144:branch, $C151:branch, $C157:branch, $C164:branch, $C16E:branch, $C17A:branch, $C17C:branch
C187:  B7 20 9B          staa     $209b
C18A:  F7 24 41          stab     $2441
C18D:  B6 90 E9          ldaa     $90e9
C190:  B7 24 63          staa     $2463
C193:  15 A7 08          bclr     $a7, #8
C196:  CC 00 00          ldd      #0
C199:  FD 20 9E          std      $209e
C19C:  C6 02             ldab     #2
C19E:  F7 20 90          stab     $2090

loc_C1A1:
C1A1:  13 D8 10 34       brclr    $d8, #16, $c1d9 ; $C1D9=loc_C1D9 | xrefs $C113:jump, $C148:branch, $C14C:branch, $C178:branch, $C180:branch
C1A5:  B6 20 AB          ldaa     $20ab
C1A8:  26 2F             bne      $c1d9 ; $C1D9=loc_C1D9
C1AA:  B6 20 90          ldaa     $2090
C1AD:  81 03             cmpa     #3
C1AF:  26 28             bne      $c1d9 ; $C1D9=loc_C1D9
C1B1:  96 5D             ldaa     $5d
C1B3:  B1 90 E6          cmpa     $90e6
C1B6:  26 21             bne      $c1d9 ; $C1D9=loc_C1D9
C1B8:  B6 24 64          ldaa     $2464
C1BB:  26 22             bne      $c1df ; $C1DF=loc_C1DF
C1BD:  B6 20 A2          ldaa     $20a2
C1C0:  B7 20 A6          staa     $20a6
C1C3:  B7 20 A4          staa     $20a4
C1C6:  97 5D             staa     $5d
C1C8:  7F 20 A7          clr      $20a7
C1CB:  14 A7 08          bset     $a7, #8
C1CE:  14 A7 02          bset     $a7, #2
C1D1:  B6 90 5D          ldaa     $905d
C1D4:  B7 24 65          staa     $2465
C1D7:  20 06             bra      $c1df ; $C1DF=loc_C1DF

loc_C1D9:
C1D9:  B6 90 5C          ldaa     $905c ; xrefs $C1A1:branch, $C1A8:branch, $C1AF:branch, $C1B6:branch
C1DC:  B7 24 64          staa     $2464

loc_C1DF:
C1DF:  B6 20 90          ldaa     $2090 ; xrefs $C1BB:branch, $C1D7:branch
C1E2:  81 03             cmpa     #3
C1E4:  26 03             bne      $c1e9 ; $C1E9=loc_C1E9
C1E6:  7E C5 FF          jmp      $c5ff ; $C5FF=loc_C5FF

loc_C1E9:
C1E9:  B6 24 3F          ldaa     $243f ; xrefs $C1E4:branch
C1EC:  26 13             bne      $c201 ; $C201=loc_C201
C1EE:  B6 20 96          ldaa     $2096
C1F1:  27 0E             beq      $c201 ; $C201=loc_C201
C1F3:  7A 24 5E          dec      $245e
C1F6:  26 09             bne      $c201 ; $C201=loc_C201
C1F8:  B6 24 4C          ldaa     $244c
C1FB:  B7 24 5E          staa     $245e
C1FE:  7A 20 96          dec      $2096

loc_C201:
C201:  FC 20 14          ldd      $2014 ; xrefs $C1EC:branch, $C1F1:branch, $C1F6:branch
C204:  1A B3 24 39       cpd      $2439
C208:  27 20             beq      $c22a ; $C22A=loc_C22A
C20A:  FD 24 39          std      $2439
C20D:  83 03 00          subd     #768
C210:  2A 05             bpl      $c217 ; $C217=loc_C217
C212:  CC 00 00          ldd      #0
C215:  20 06             bra      $c21d ; $C21D=loc_C21D

loc_C217:
C217:  4D                tsta      ; xrefs $C210:branch
C218:  27 03             beq      $c21d ; $C21D=loc_C21D
C21A:  CC 00 FF          ldd      #255

loc_C21D:
C21D:  05                asld      ; xrefs $C215:branch, $C218:branch
C21E:  05                asld     
C21F:  05                asld     
C220:  18 CE 90 68       ldy      #-28568
C224:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
C227:  B7 20 99          staa     $2099

loc_C22A:
C22A:  12 A5 40 1A       brset    $a5, #64, $c248 ; $C248=loc_C248 | xrefs $C208:branch
C22E:  B6 20 17          ldaa     $2017
C231:  5F                clrb     
C232:  FD 20 18          std      $2018
C235:  12 A9 40 24       brset    $a9, #64, $c25d ; $00A9=operating_mode_flags, $C25D=loc_C25D
C239:  96 90             ldaa     $90
C23B:  26 2F             bne      $c26c ; $C26C=loc_C26C
C23D:  13 D8 10 2B       brclr    $d8, #16, $c26c ; $C26C=loc_C26C
C241:  B6 20 AA          ldaa     $20aa
C244:  26 26             bne      $c26c ; $C26C=loc_C26C
C246:  20 15             bra      $c25d ; $C25D=loc_C25D

loc_C248:
C248:  13 D8 10 05       brclr    $d8, #16, $c251 ; $C251=loc_C251 | xrefs $C22A:branch
C24C:  B6 20 AA          ldaa     $20aa
C24F:  27 0C             beq      $c25d ; $C25D=loc_C25D

loc_C251:
C251:  13 A9 40 17       brclr    $a9, #64, $c26c ; $00A9=operating_mode_flags, $C26C=loc_C26C | xrefs $C248:branch
C255:  B6 20 9A          ldaa     $209a
C258:  B1 90 72          cmpa     $9072
C25B:  24 0F             bcc      $c26c ; $C26C=loc_C26C

loc_C25D:
C25D:  CC 00 00          ldd      #0 ; xrefs $C235:branch, $C246:branch, $C24F:branch
C260:  FD 24 3C          std      $243c
C263:  B7 20 9A          staa     $209a
C266:  15 A5 40          bclr     $a5, #64
C269:  7E C3 32          jmp      $c332 ; $C332=loc_C332

loc_C26C:
C26C:  14 A5 40          bset     $a5, #64 ; xrefs $C23B:branch, $C23D:branch, $C244:branch, $C251:branch, $C25B:branch
C26F:  FC 20 18          ldd      $2018
C272:  CE 24 56          ldx      #9302
C275:  ED 00             std      0, x
C277:  B6 20 17          ldaa     $2017
C27A:  F6 90 E0          ldab     $90e0
C27D:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
C280:  FD 20 18          std      $2018
C283:  F6 92 9A          ldab     $929a
C286:  CE 92 91          ldx      #-28015
C289:  BD B3 83          jsr      $b383 ; $B383=axis_lookup_u8
C28C:  18 CE 24 56       ldy      #9302
C290:  18 ED 00          std      0, y
C293:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
C296:  1A 83 0A 00       cpd      #2560
C29A:  23 03             bls      $c29f ; $C29F=loc_C29F
C29C:  CC 0A 00          ldd      #2560

loc_C29F:
C29F:  18 ED 02          std      2, y ; xrefs $C29A:branch
C2A2:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
C2A5:  18 CE 90 D6       ldy      #-28458
C2A9:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
C2AC:  B7 24 3E          staa     $243e
C2AF:  18 CE 24 56       ldy      #9302
C2B3:  CC 90 73          ldd      #-28557
C2B6:  18 ED 04          std      4, y
C2B9:  C6 09             ldab     #9
C2BB:  18 E7 06          stab     6, y
C2BE:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
C2C1:  B1 24 3C          cmpa     $243c
C2C4:  27 3E             beq      $c304 ; $C304=loc_C304
C2C6:  25 21             bcs      $c2e9 ; $C2E9=loc_C2E9
C2C8:  F6 90 E2          ldab     $90e2
C2CB:  12 A6 80 05       brset    $a6, #-128, $c2d4 ; $C2D4=loc_C2D4
C2CF:  14 A6 80          bset     $a6, #-128
C2D2:  20 10             bra      $c2e4 ; $C2E4=loc_C2E4

loc_C2D4:
C2D4:  7A 24 5F          dec      $245f ; xrefs $C2CB:branch
C2D7:  26 0E             bne      $c2e7 ; $C2E7=loc_C2E7
C2D9:  7C 24 3C          inc      $243c
C2DC:  B1 24 3C          cmpa     $243c
C2DF:  22 03             bhi      $c2e4 ; $C2E4=loc_C2E4
C2E1:  B7 24 3C          staa     $243c

loc_C2E4:
C2E4:  F7 24 5F          stab     $245f ; xrefs $C2D2:branch, $C2DF:branch

loc_C2E7:
C2E7:  20 1B             bra      $c304 ; $C304=loc_C304 | xrefs $C2D7:branch

loc_C2E9:
C2E9:  15 A6 80          bclr     $a6, #-128 ; xrefs $C2C6:branch
C2EC:  5F                clrb     
C2ED:  8F                xgdx     
C2EE:  FC 24 3C          ldd      $243c
C2F1:  B3 90 E3          subd     $90e3
C2F4:  24 03             bcc      $c2f9 ; $C2F9=loc_C2F9
C2F6:  CC 00 00          ldd      #0

loc_C2F9:
C2F9:  FD 24 3C          std      $243c ; xrefs $C2F4:branch
C2FC:  BC 24 3C          cpx      $243c
C2FF:  25 03             bcs      $c304 ; $C304=loc_C304
C301:  FF 24 3C          stx      $243c

loc_C304:
C304:  B6 24 3C          ldaa     $243c ; xrefs $C2C4:branch, $C2E7:branch, $C2FF:branch
C307:  F6 20 18          ldab     $2018
C30A:  F0 20 17          subb     $2017
C30D:  25 10             bcs      $c31f ; $C31F=loc_C31F
C30F:  B6 90 E1          ldaa     $90e1
C312:  3D                mul      
C313:  89 00             adca     #0
C315:  BB 24 3C          adda     $243c
C318:  24 05             bcc      $c31f ; $C31F=loc_C31F
C31A:  B6 24 3E          ldaa     $243e
C31D:  20 06             bra      $c325 ; $C325=loc_C325

loc_C31F:
C31F:  F6 24 3E          ldab     $243e ; xrefs $C30D:branch, $C318:branch
C322:  3D                mul      
C323:  89 00             adca     #0

loc_C325:
C325:  D6 90             ldab     $90 ; xrefs $C31D:branch
C327:  27 06             beq      $c32f ; $C32F=loc_C32F
C329:  F6 90 DF          ldab     $90df
C32C:  3D                mul      
C32D:  89 00             adca     #0

loc_C32F:
C32F:  B7 20 9A          staa     $209a ; xrefs $C327:branch

loc_C332:
C332:  12 A9 40 13       brset    $a9, #64, $c349 ; $00A9=operating_mode_flags, $C349=loc_C349 | xrefs $C269:jump
C336:  12 A5 01 0C       brset    $a5, #1, $c346 ; $C346=loc_C346
C33A:  15 A5 80          bclr     $a5, #-128
C33D:  14 A5 01          bset     $a5, #1
C340:  7F 24 55          clr      $2455
C343:  7F 24 46          clr      $2446

loc_C346:
C346:  7E C3 E0          jmp      $c3e0 ; $C3E0=loc_C3E0 | xrefs $C336:branch

loc_C349:
C349:  12 A5 80 41       brset    $a5, #-128, $c38e ; $C38E=loc_C38E | xrefs $C332:branch
C34D:  B6 20 98          ldaa     $2098
C350:  27 03             beq      $c355 ; $C355=loc_C355
C352:  7E C3 E0          jmp      $c3e0 ; $C3E0=loc_C3E0

loc_C355:
C355:  12 D8 10 25       brset    $d8, #16, $c37e ; $C37E=loc_C37E | xrefs $C350:branch
C359:  13 A3 80 19       brclr    $a3, #-128, $c376 ; $C376=loc_C376
C35D:  12 A5 10 20       brset    $a5, #16, $c381 ; $C381=loc_C381
C361:  B6 20 96          ldaa     $2096
C364:  BA 20 9A          oraa     $209a
C367:  BA 24 44          oraa     $2444
C36A:  26 12             bne      $c37e ; $C37E=loc_C37E
C36C:  B6 20 30          ldaa     $2030
C36F:  B1 90 5F          cmpa     $905f
C372:  25 0D             bcs      $c381 ; $C381=loc_C381
C374:  20 08             bra      $c37e ; $C37E=loc_C37E

loc_C376:
C376:  13 A3 10 04       brclr    $a3, #16, $c37e ; $C37E=loc_C37E | xrefs $C359:branch
C37A:  12 A5 10 03       brset    $a5, #16, $c381 ; $C381=loc_C381

loc_C37E:
C37E:  7E C4 40          jmp      $c440 ; $C440=loc_C440 | xrefs $C355:branch, $C36A:branch, $C374:branch, $C376:branch

loc_C381:
C381:  14 A5 80          bset     $a5, #-128 ; xrefs $C35D:branch, $C372:branch, $C37A:branch
C384:  7F 24 47          clr      $2447
C387:  B6 90 62          ldaa     $9062
C38A:  40                nega     
C38B:  B7 24 40          staa     $2440

loc_C38E:
C38E:  96 D1             ldaa     $d1 ; xrefs $C349:branch
C390:  B1 20 A8          cmpa     $20a8
C393:  22 03             bhi      $c398 ; $C398=loc_C398
C395:  7E C4 40          jmp      $c440 ; $C440=loc_C440

loc_C398:
C398:  B6 20 98          ldaa     $2098 ; xrefs $C393:branch
C39B:  40                nega     
C39C:  B1 90 5E          cmpa     $905e
C39F:  24 23             bcc      $c3c4 ; $C3C4=loc_C3C4
C3A1:  B6 24 47          ldaa     $2447
C3A4:  B1 90 60          cmpa     $9060
C3A7:  27 1D             beq      $c3c6 ; $C3C6=loc_C3C6
C3A9:  7C 24 47          inc      $2447
C3AC:  B6 00 D2          ldaa     >$00d2
C3AF:  B7 24 50          staa     $2450
C3B2:  7F 24 45          clr      $2445
C3B5:  7F 24 46          clr      $2446
C3B8:  7F 24 48          clr      $2448
C3BB:  B6 20 98          ldaa     $2098
C3BE:  B7 24 55          staa     $2455
C3C1:  15 A5 01          bclr     $a5, #1

loc_C3C4:
C3C4:  20 7A             bra      $c440 ; $C440=loc_C440 | xrefs $C39F:branch

loc_C3C6:
C3C6:  12 A5 01 16       brset    $a5, #1, $c3e0 ; $C3E0=loc_C3E0 | xrefs $C3A7:branch
C3CA:  B6 20 98          ldaa     $2098
C3CD:  B1 24 40          cmpa     $2440
C3D0:  26 5B             bne      $c42d ; $C42D=loc_C42D
C3D2:  B6 24 48          ldaa     $2448
C3D5:  B1 90 61          cmpa     $9061
C3D8:  26 2B             bne      $c405 ; $C405=loc_C405
C3DA:  14 A5 01          bset     $a5, #1
C3DD:  7F 24 46          clr      $2446

loc_C3E0:
C3E0:  B6 24 46          ldaa     $2446 ; xrefs $C346:jump, $C352:jump, $C3C6:branch
C3E3:  27 05             beq      $c3ea ; $C3EA=loc_C3EA
C3E5:  7A 24 46          dec      $2446
C3E8:  20 56             bra      $c440 ; $C440=loc_C440

loc_C3EA:
C3EA:  B6 20 98          ldaa     $2098 ; xrefs $C3E3:branch
C3ED:  B1 24 55          cmpa     $2455
C3F0:  26 08             bne      $c3fa ; $C3FA=loc_C3FA
C3F2:  7F 24 47          clr      $2447
C3F5:  15 A5 01          bclr     $a5, #1
C3F8:  20 46             bra      $c440 ; $C440=loc_C440

loc_C3FA:
C3FA:  B6 90 64          ldaa     $9064 ; xrefs $C3F0:branch
C3FD:  B7 24 46          staa     $2446
C400:  7C 20 98          inc      $2098
C403:  20 3B             bra      $c440 ; $C440=loc_C440

loc_C405:
C405:  7C 24 48          inc      $2448 ; xrefs $C3D8:branch
C408:  B6 24 50          ldaa     $2450
C40B:  B0 00 D2          suba     >$00d2
C40E:  25 30             bcs      $c440 ; $C440=loc_C440
C410:  B1 90 65          cmpa     $9065
C413:  23 2B             bls      $c440 ; $C440=loc_C440
C415:  7F 24 48          clr      $2448
C418:  7F 24 45          clr      $2445
C41B:  B6 00 D2          ldaa     >$00d2
C41E:  B7 24 50          staa     $2450
C421:  B6 24 40          ldaa     $2440
C424:  B7 24 55          staa     $2455
C427:  B0 90 62          suba     $9062
C42A:  B7 24 40          staa     $2440

loc_C42D:
C42D:  B6 24 45          ldaa     $2445 ; xrefs $C3D0:branch
C430:  27 05             beq      $c437 ; $C437=loc_C437
C432:  7A 24 45          dec      $2445
C435:  20 09             bra      $c440 ; $C440=loc_C440

loc_C437:
C437:  B6 90 63          ldaa     $9063 ; xrefs $C430:branch
C43A:  B7 24 45          staa     $2445
C43D:  7A 20 98          dec      $2098

loc_C440:
C440:  20 0A             bra      $c44c ; $C44C=loc_C44C | xrefs $C37E:jump, $C395:jump, $C3C4:branch, $C3E8:branch, $C3F8:branch, $C403:branch, $C40E:branch, $C413:branch, +1 more

; ---- unreached/data gap $C442-$C44B ----

        .org $C44C

loc_C44C:
C44C:  13 D8 10 04       brclr    $d8, #16, $c454 ; $C454=loc_C454 | xrefs $C440:branch
C450:  13 1E 90 0C       brclr    $1e, #-112, $c460 ; $C460=loc_C460

loc_C454:
C454:  CC 00 01          ldd      #1 ; xrefs $C44C:branch
C457:  B7 20 9B          staa     $209b
C45A:  F7 24 41          stab     $2441
C45D:  7E C5 78          jmp      $c578 ; $C578=loc_C578

loc_C460:
C460:  F6 24 41          ldab     $2441 ; xrefs $C450:branch
C463:  5A                decb     
C464:  58                aslb     
C465:  CE C4 42          ldx      #-15294
C468:  3A                abx      
C469:  EE 00             ldx      0, x
C46B:  6E 00             jmp      0, x

; ---- unreached/data gap $C46D-$C577 ----

        .org $C578

loc_C578:
C578:  BD CB 43          jsr      $cb43 ; $CB43=sub_CB43 | xrefs $C45D:jump
C57B:  CE 24 56          ldx      #9302
C57E:  FC 90 E5          ldd      $90e5
C581:  ED 00             std      0, x
C583:  FC 90 E7          ldd      $90e7
C586:  ED 02             std      2, x
C588:  F6 20 94          ldab     $2094
C58B:  96 90             ldaa     $90
C58D:  27 08             beq      $c597 ; $C597=loc_C597
C58F:  B6 20 2D          ldaa     $202d
C592:  26 03             bne      $c597 ; $C597=loc_C597
C594:  F6 20 95          ldab     $2095

loc_C597:
C597:  4F                clra      ; xrefs $C58D:branch, $C592:branch
C598:  F7 24 67          stab     $2467
C59B:  5D                tstb     
C59C:  2A 02             bpl      $c5a0 ; $C5A0=loc_C5A0
C59E:  86 FF             ldaa     #-1

loc_C5A0:
C5A0:  FB 20 93          addb     $2093 ; xrefs $C59C:branch
C5A3:  89 00             adca     #0
C5A5:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5
C5A8:  7D 20 96          tst      $2096
C5AB:  27 08             beq      $c5b5 ; $C5B5=loc_C5B5
C5AD:  FB 20 96          addb     $2096
C5B0:  89 00             adca     #0
C5B2:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5B5:
C5B5:  7D 20 99          tst      $2099 ; xrefs $C5AB:branch
C5B8:  27 08             beq      $c5c2 ; $C5C2=loc_C5C2
C5BA:  FB 20 99          addb     $2099
C5BD:  89 00             adca     #0
C5BF:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5C2:
C5C2:  7D 20 97          tst      $2097 ; xrefs $C5B8:branch
C5C5:  27 08             beq      $c5cf ; $C5CF=loc_C5CF
C5C7:  FB 20 97          addb     $2097
C5CA:  89 00             adca     #0
C5CC:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5CF:
C5CF:  7D 20 98          tst      $2098 ; xrefs $C5C5:branch
C5D2:  27 08             beq      $c5dc ; $C5DC=loc_C5DC
C5D4:  FB 20 98          addb     $2098
C5D7:  89 FF             adca     #-1
C5D9:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5DC:
C5DC:  7D 20 9A          tst      $209a ; xrefs $C5D2:branch
C5DF:  27 08             beq      $c5e9 ; $C5E9=loc_C5E9
C5E1:  FB 20 9A          addb     $209a
C5E4:  89 00             adca     #0
C5E6:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5E9:
C5E9:  7D 20 9B          tst      $209b ; xrefs $C5DF:branch
C5EC:  27 08             beq      $c5f6 ; $C5F6=loc_C5F6
C5EE:  FB 20 9B          addb     $209b
C5F1:  89 00             adca     #0
C5F3:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5

loc_C5F6:
C5F6:  F7 20 A2          stab     $20a2 ; xrefs $C5EC:branch
C5F9:  F7 20 A4          stab     $20a4
C5FC:  7E C8 40          jmp      $c840 ; $C840=loc_C840

loc_C5FF:
C5FF:  CC 00 00          ldd      #0 ; xrefs $C1E6:jump
C602:  B7 24 3B          staa     $243b
C605:  FD 20 A0          std      $20a0
C608:  F6 20 A8          ldab     $20a8
C60B:  FD 24 56          std      $2456
C60E:  D6 D1             ldab     $d1
C610:  B3 24 56          subd     $2456
C613:  1A 83 00 7F       cpd      #127
C617:  2D 05             blt      $c61e ; $C61E=loc_C61E
C619:  CC 00 7F          ldd      #127
C61C:  20 09             bra      $c627 ; $C627=loc_C627

loc_C61E:
C61E:  1A 83 FF 80       cpd      #-128 ; xrefs $C617:branch
C622:  2E 03             bgt      $c627 ; $C627=loc_C627
C624:  CC FF 80          ldd      #-128

loc_C627:
C627:  FD 24 56          std      $2456 ; xrefs $C61C:branch, $C622:branch
C62A:  17                tba      
C62B:  F6 91 10          ldab     $9110
C62E:  11                cba      
C62F:  2D 25             blt      $c656 ; $C656=loc_C656
C631:  7C 24 3B          inc      $243b
C634:  10                sba      
C635:  5F                clrb     
C636:  8F                xgdx     
C637:  4F                clra     
C638:  F6 91 15          ldab     $9115
C63B:  26 01             bne      $c63e ; $C63E=loc_C63E
C63D:  5C                incb     

loc_C63E:
C63E:  8F                xgdx      ; xrefs $C63B:branch
C63F:  02                idiv     
C640:  8F                xgdx     
C641:  F3 91 11          addd     $9111
C644:  40                nega     
C645:  50                negb     
C646:  82 00             sbca     #0
C648:  CE 00 00          ldx      #0
C64B:  FF 24 51          stx      $2451
C64E:  14 A7 80          bset     $a7, #-128
C651:  15 A7 40          bclr     $a7, #64
C654:  20 77             bra      $c6cd ; $C6CD=loc_C6CD

loc_C656:
C656:  1B                aba       ; xrefs $C62F:branch
C657:  2E 21             bgt      $c67a ; $C67A=loc_C67A
C659:  7C 24 3B          inc      $243b
C65C:  40                nega     
C65D:  5F                clrb     
C65E:  8F                xgdx     
C65F:  4F                clra     
C660:  F6 91 16          ldab     $9116
C663:  26 01             bne      $c666 ; $C666=loc_C666
C665:  5C                incb     

loc_C666:
C666:  8F                xgdx      ; xrefs $C663:branch
C667:  02                idiv     
C668:  8F                xgdx     
C669:  F3 91 13          addd     $9113
C66C:  CE 00 00          ldx      #0
C66F:  FF 24 51          stx      $2451
C672:  14 A7 80          bset     $a7, #-128
C675:  15 A7 40          bclr     $a7, #64
C678:  20 53             bra      $c6cd ; $C6CD=loc_C6CD

loc_C67A:
C67A:  15 A7 80          bclr     $a7, #-128 ; xrefs $C657:branch
C67D:  14 A7 40          bset     $a7, #64
C680:  FC 24 56          ldd      $2456
C683:  F3 24 51          addd     $2451
C686:  FD 24 51          std      $2451
C689:  4F                clra     
C68A:  F6 91 10          ldab     $9110
C68D:  FB 91 17          addb     $9117
C690:  89 00             adca     #0
C692:  F3 24 51          addd     $2451
C695:  2E 0B             bgt      $c6a2 ; $C6A2=loc_C6A2
C697:  CC 00 00          ldd      #0
C69A:  FD 24 51          std      $2451
C69D:  FC 91 1B          ldd      $911b
C6A0:  20 24             bra      $c6c6 ; $C6C6=loc_C6C6

loc_C6A2:
C6A2:  4F                clra      ; xrefs $C695:branch
C6A3:  F6 91 10          ldab     $9110
C6A6:  FB 91 18          addb     $9118
C6A9:  89 00             adca     #0
C6AB:  40                nega     
C6AC:  50                negb     
C6AD:  82 00             sbca     #0
C6AF:  F3 24 51          addd     $2451
C6B2:  2D 0F             blt      $c6c3 ; $C6C3=loc_C6C3
C6B4:  CC 00 00          ldd      #0
C6B7:  FD 24 51          std      $2451
C6BA:  FC 91 19          ldd      $9119
C6BD:  40                nega     
C6BE:  50                negb     
C6BF:  82 00             sbca     #0
C6C1:  20 03             bra      $c6c6 ; $C6C6=loc_C6C6

loc_C6C3:
C6C3:  CC 00 00          ldd      #0 ; xrefs $C6B2:branch

loc_C6C6:
C6C6:  CE 00 00          ldx      #0 ; xrefs $C6A0:branch, $C6C1:branch
C6C9:  FD 20 A0          std      $20a0
C6CC:  8F                xgdx     

loc_C6CD:
C6CD:  18 8F             xgdy      ; xrefs $C654:branch, $C678:branch
C6CF:  CE 24 56          ldx      #9302
C6D2:  FC 91 1D          ldd      $911d
C6D5:  40                nega     
C6D6:  50                negb     
C6D7:  82 00             sbca     #0
C6D9:  ED 00             std      0, x
C6DB:  FC 91 1F          ldd      $911f
C6DE:  ED 02             std      2, x
C6E0:  18 8F             xgdy     
C6E2:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5
C6E5:  FD 20 9E          std      $209e
C6E8:  FC 20 9E          ldd      $209e
C6EB:  F3 20 A0          addd     $20a0
C6EE:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5
C6F1:  FD 20 9C          std      $209c
C6F4:  15 A5 02          bclr     $a5, #2
C6F7:  4D                tsta     
C6F8:  2A 03             bpl      $c6fd ; $C6FD=loc_C6FD
C6FA:  14 A5 02          bset     $a5, #2

loc_C6FD:
C6FD:  96 5D             ldaa     $5d ; xrefs $C6F8:branch
C6FF:  F6 20 A7          ldab     $20a7
C702:  F3 20 9C          addd     $209c
C705:  FD 20 A6          std      $20a6
C708:  B6 20 A5          ldaa     $20a5
C70B:  13 A5 02 04       brclr    $a5, #2, $c713 ; $C713=loc_C713
C70F:  89 FF             adca     #-1
C711:  20 02             bra      $c715 ; $C715=loc_C715

loc_C713:
C713:  89 00             adca     #0 ; xrefs $C70B:branch

loc_C715:
C715:  B7 20 A5          staa     $20a5 ; xrefs $C711:branch
C718:  86 00             ldaa     #0
C71A:  F6 20 A6          ldab     $20a6
C71D:  18 FE 90 E5       ldy      $90e5
C721:  1A EF 00          sty      0, x
C724:  18 FE 90 E7       ldy      $90e7
C728:  1A EF 02          sty      2, x
C72B:  BD CA C5          jsr      $cac5 ; $CAC5=sub_CAC5
C72E:  F7 20 A6          stab     $20a6

loc_C731:
C731:  F7 20 A4          stab     $20a4 ; xrefs $C10A:jump
C734:  18 CE 20 94       ldy      #8340
C738:  CE 00 60          ldx      #96
C73B:  96 90             ldaa     $90
C73D:  27 0C             beq      $c74b ; $C74B=loc_C74B
C73F:  B6 20 2D          ldaa     $202d
C742:  26 07             bne      $c74b ; $C74B=loc_C74B
C744:  18 CE 20 95       ldy      #8341
C748:  CE 00 69          ldx      #105

loc_C74B:
C74B:  B6 10 40          ldaa     $1040 ; xrefs $C73D:branch, $C742:branch
C74E:  85 02             bita     #2
C750:  27 1A             beq      $c76c ; $C76C=loc_C76C
C752:  13 A7 40 16       brclr    $a7, #64, $c76c ; $C76C=loc_C76C
C756:  12 33 01 12       brset    $33, #1, $c76c ; $C76C=loc_C76C
C75A:  13 33 02 0E       brclr    $33, #2, $c76c ; $C76C=loc_C76C
C75E:  B6 91 21          ldaa     $9121
C761:  27 0F             beq      $c772 ; $C772=loc_C772
C763:  13 D8 10 0B       brclr    $d8, #16, $c772 ; $C772=loc_C772
C767:  B6 20 AA          ldaa     $20aa
C76A:  27 06             beq      $c772 ; $C772=loc_C772

loc_C76C:
C76C:  15 A7 04          bclr     $a7, #4 ; xrefs $C750:branch, $C752:branch, $C756:branch, $C75A:branch
C76F:  7E C8 40          jmp      $c840 ; $C840=loc_C840

loc_C772:
C772:  14 A7 04          bset     $a7, #4 ; xrefs $C761:branch, $C763:branch, $C76A:branch
C775:  13 A7 08 19       brclr    $a7, #8, $c792 ; $C792=loc_C792
C779:  B6 24 65          ldaa     $2465
C77C:  26 11             bne      $c78f ; $C78F=loc_C78F
C77E:  B6 20 A2          ldaa     $20a2
C781:  B7 20 A6          staa     $20a6
C784:  B7 20 A4          staa     $20a4
C787:  97 5D             staa     $5d
C789:  7F 20 A7          clr      $20a7
C78C:  15 A7 08          bclr     $a7, #8

loc_C78F:
C78F:  7E C8 40          jmp      $c840 ; $C840=loc_C840 | xrefs $C77C:branch

loc_C792:
C792:  13 A7 02 03       brclr    $a7, #2, $c799 ; $C799=loc_C799 | xrefs $C775:branch
C796:  7E C8 40          jmp      $c840 ; $C840=loc_C840

loc_C799:
C799:  4F                clra      ; xrefs $C792:branch
C79A:  F6 20 A6          ldab     $20a6
C79D:  F0 20 93          subb     $2093
C7A0:  18 E0 00          subb     0, y
C7A3:  F0 20 99          subb     $2099
C7A6:  F0 20 97          subb     $2097
C7A9:  2A 01             bpl      $c7ac ; $C7AC=loc_C7AC
C7AB:  43                coma     

loc_C7AC:
C7AC:  F3 20 91          addd     $2091 ; xrefs $C7A9:branch
C7AF:  FD 20 91          std      $2091
C7B2:  FC 24 4D          ldd      $244d
C7B5:  C3 00 01          addd     #1
C7B8:  FD 24 4D          std      $244d
C7BB:  1A B3 90 58       cpd      $9058
C7BF:  25 55             bcs      $c816 ; $C816=loc_C816
C7C1:  FC 20 91          ldd      $2091
C7C4:  1A B3 90 55       cpd      $9055
C7C8:  2F 16             ble      $c7e0 ; $C7E0=loc_C7E0
C7CA:  18 A6 00          ldaa     0, y
C7CD:  BB 90 57          adda     $9057
C7D0:  B1 90 5A          cmpa     $905a
C7D3:  2F 09             ble      $c7de ; $C7DE=loc_C7DE
C7D5:  14 3C 01          bset     $3c, #1
C7D8:  15 3C 02          bclr     $3c, #2
C7DB:  B6 90 5A          ldaa     $905a

loc_C7DE:
C7DE:  20 21             bra      $c801 ; $C801=loc_C801 | xrefs $C7D3:branch

loc_C7E0:
C7E0:  40                nega      ; xrefs $C7C8:branch
C7E1:  50                negb     
C7E2:  82 00             sbca     #0
C7E4:  1A B3 90 55       cpd      $9055
C7E8:  2F 1A             ble      $c804 ; $C804=loc_C804
C7EA:  18 A6 00          ldaa     0, y
C7ED:  B0 90 57          suba     $9057
C7F0:  16                tab      
C7F1:  50                negb     
C7F2:  F1 90 5A          cmpb     $905a
C7F5:  2F 0A             ble      $c801 ; $C801=loc_C801
C7F7:  14 3C 01          bset     $3c, #1
C7FA:  15 3C 02          bclr     $3c, #2
C7FD:  B6 90 5A          ldaa     $905a
C800:  40                nega     

loc_C801:
C801:  18 A7 00          staa     0, y ; xrefs $C7DE:branch, $C7F5:branch

loc_C804:
C804:  CC 00 00          ldd      #0 ; xrefs $C7E8:branch
C807:  FD 20 91          std      $2091
C80A:  FD 24 4D          std      $244d
C80D:  3C                pshx     
C80E:  18 3C             pshy     
C810:  BD 63 12          jsr      $6312 ; $6312=sub_6312
C813:  18 38             puly     
C815:  38                pulx     

loc_C816:
C816:  18 A6 00          ldaa     0, y ; xrefs $C7BF:branch
C819:  F6 20 3C          ldab     $203c ; $203C=cts_axis_index
C81C:  3A                abx      
C81D:  D6 CA             ldab     $ca
C81F:  F1 90 5B          cmpb     $905b
C822:  25 0B             bcs      $c82f ; $C82F=loc_C82F
C824:  F6 20 3C          ldab     $203c ; $203C=cts_axis_index
C827:  C1 08             cmpb     #8
C829:  24 0B             bcc      $c836 ; $C836=loc_C836
C82B:  A7 01             staa     1, x
C82D:  20 11             bra      $c840 ; $C840=loc_C840

loc_C82F:
C82F:  F6 20 3D          ldab     $203d ; xrefs $C822:branch
C832:  C1 33             cmpb     #51
C834:  24 04             bcc      $c83a ; $C83A=loc_C83A

loc_C836:
C836:  A7 00             staa     0, x ; xrefs $C829:branch
C838:  20 06             bra      $c840 ; $C840=loc_C840

loc_C83A:
C83A:  C1 CD             cmpb     #-51 ; xrefs $C834:branch
C83C:  23 02             bls      $c840 ; $C840=loc_C840
C83E:  A7 01             staa     1, x

loc_C840:
C840:  13 A3 10 1F       brclr    $a3, #16, $c863 ; $C863=loc_C863 | xrefs $C5FC:jump, $C76F:jump, $C78F:jump, $C796:jump, $C82D:branch, $C838:branch, $C83C:branch
C844:  12 D8 10 1B       brset    $d8, #16, $c863 ; $C863=loc_C863
C848:  13 A5 10 20       brclr    $a5, #16, $c86c ; $C86C=loc_C86C
C84C:  96 D1             ldaa     $d1
C84E:  B1 20 A8          cmpa     $20a8
C851:  24 13             bcc      $c866 ; $C866=loc_C866
C853:  B6 24 4B          ldaa     $244b
C856:  8B 01             adda     #1
C858:  B7 24 4B          staa     $244b
C85B:  B1 90 EE          cmpa     $90ee
C85E:  24 03             bcc      $c863 ; $C863=loc_C863
C860:  7E C8 E4          jmp      $c8e4 ; $C8E4=loc_C8E4

loc_C863:
C863:  7E C8 D5          jmp      $c8d5 ; $C8D5=loc_C8D5 | xrefs $C840:branch, $C844:branch, $C85E:branch

loc_C866:
C866:  7F 24 4B          clr      $244b ; xrefs $C851:branch
C869:  7E C8 E4          jmp      $c8e4 ; $C8E4=loc_C8E4

loc_C86C:
C86C:  B6 20 90          ldaa     $2090 ; xrefs $C848:branch
C86F:  81 03             cmpa     #3
C871:  26 62             bne      $c8d5 ; $C8D5=loc_C8D5
C873:  96 D1             ldaa     $d1
C875:  B1 20 A8          cmpa     $20a8
C878:  23 5B             bls      $c8d5 ; $C8D5=loc_C8D5
C87A:  B6 24 49          ldaa     $2449
C87D:  B1 90 EA          cmpa     $90ea
C880:  24 16             bcc      $c898 ; $C898=loc_C898
C882:  8B 01             adda     #1
C884:  B7 24 49          staa     $2449
C887:  4F                clra     
C888:  D6 D1             ldab     $d1
C88A:  F0 00 D2          subb     >$00d2
C88D:  2A 01             bpl      $c890 ; $C890=loc_C890
C88F:  43                coma     

loc_C890:
C890:  F3 24 53          addd     $2453 ; xrefs $C88D:branch
C893:  FD 24 53          std      $2453
C896:  20 4C             bra      $c8e4 ; $C8E4=loc_C8E4

loc_C898:
C898:  FC 24 53          ldd      $2453 ; xrefs $C880:branch
C89B:  1A B3 90 EB       cpd      $90eb
C89F:  2F 34             ble      $c8d5 ; $C8D5=loc_C8D5
C8A1:  96 5D             ldaa     $5d
C8A3:  B1 90 E6          cmpa     $90e6
C8A6:  23 1F             bls      $c8c7 ; $C8C7=loc_C8C7
C8A8:  FC 20 9C          ldd      $209c
C8AB:  40                nega     
C8AC:  50                negb     
C8AD:  82 00             sbca     #0
C8AF:  1A B3 91 1D       cpd      $911d
C8B3:  2C 12             bge      $c8c7 ; $C8C7=loc_C8C7
C8B5:  FC 20 9C          ldd      $209c
C8B8:  2A 1B             bpl      $c8d5 ; $C8D5=loc_C8D5
C8BA:  B6 24 4A          ldaa     $244a
C8BD:  8B 01             adda     #1
C8BF:  B7 24 4A          staa     $244a
C8C2:  B1 90 ED          cmpa     $90ed
C8C5:  25 1D             bcs      $c8e4 ; $C8E4=loc_C8E4

loc_C8C7:
C8C7:  14 A5 10          bset     $a5, #16 ; xrefs $C8A6:branch, $C8B3:branch
C8CA:  CC 00 00          ldd      #0
C8CD:  FD 24 53          std      $2453
C8D0:  B7 24 4B          staa     $244b
C8D3:  20 0F             bra      $c8e4 ; $C8E4=loc_C8E4

loc_C8D5:
C8D5:  CC 00 00          ldd      #0 ; xrefs $C863:jump, $C871:branch, $C878:branch, $C89F:branch, $C8B8:branch
C8D8:  FD 24 53          std      $2453
C8DB:  B7 24 49          staa     $2449
C8DE:  B7 24 4A          staa     $244a
C8E1:  15 A5 10          bclr     $a5, #16

loc_C8E4:
C8E4:  F6 91 0C          ldab     $910c ; xrefs $C860:jump, $C869:jump, $C896:branch, $C8C5:branch, $C8D3:branch
C8E7:  B6 20 96          ldaa     $2096
C8EA:  BA 20 9A          oraa     $209a
C8ED:  27 05             beq      $c8f4 ; $C8F4=loc_C8F4
C8EF:  F7 24 44          stab     $2444
C8F2:  20 08             bra      $c8fc ; $C8FC=loc_C8FC

loc_C8F4:
C8F4:  7D 24 44          tst      $2444 ; xrefs $C8ED:branch
C8F7:  27 03             beq      $c8fc ; $C8FC=loc_C8FC
C8F9:  7A 24 44          dec      $2444

loc_C8FC:
C8FC:  BA 20 9B          oraa     $209b ; xrefs $C8F2:branch, $C8F7:branch
C8FF:  27 05             beq      $c906 ; $C906=loc_C906
C901:  F7 24 43          stab     $2443
C904:  20 08             bra      $c90e ; $C90E=loc_C90E

loc_C906:
C906:  7D 24 43          tst      $2443 ; xrefs $C8FF:branch
C909:  27 03             beq      $c90e ; $C90E=loc_C90E
C90B:  7A 24 43          dec      $2443

loc_C90E:
C90E:  39                rts       ; xrefs $C008:jump, $C015:jump, $C904:branch, $C909:branch

; ---- unreached/data gap $C90F-$C90F ----

        .org $C910

; [OPEN] Periodic runtime stage.
runtime_stage_c910:
C910:  13 A7 08 13       brclr    $a7, #8, $c927 ; $C927=loc_C927 | xrefs $D376:call
C914:  13 A7 04 09       brclr    $a7, #4, $c921 ; $C921=loc_C921
C918:  B6 24 65          ldaa     $2465
C91B:  4A                deca     
C91C:  2C 06             bge      $c924 ; $C924=loc_C924
C91E:  4F                clra     
C91F:  20 03             bra      $c924 ; $C924=loc_C924

loc_C921:
C921:  B6 90 5D          ldaa     $905d ; xrefs $C914:branch

loc_C924:
C924:  B7 24 65          staa     $2465 ; xrefs $C91C:branch, $C91F:branch

loc_C927:
C927:  B6 24 64          ldaa     $2464 ; xrefs $C910:branch
C92A:  4A                deca     
C92B:  2C 01             bge      $c92e ; $C92E=loc_C92E
C92D:  4F                clra     

loc_C92E:
C92E:  B7 24 64          staa     $2464 ; xrefs $C92B:branch
C931:  B6 20 90          ldaa     $2090
C934:  81 01             cmpa     #1
C936:  27 09             beq      $c941 ; $C941=loc_C941
C938:  B6 24 3F          ldaa     $243f
C93B:  27 04             beq      $c941 ; $C941=loc_C941
C93D:  4A                deca     
C93E:  B7 24 3F          staa     $243f

loc_C941:
C941:  B6 24 62          ldaa     $2462 ; xrefs $C936:branch, $C93B:branch
C944:  27 03             beq      $c949 ; $C949=loc_C949
C946:  7A 24 62          dec      $2462

loc_C949:
C949:  39                rts       ; xrefs $C944:branch

; ---- unreached/data gap $C94A-$C94A ----

        .org $C94B

; [CONFIRMED] Interpolate learned/adaptive trim cells.
adaptive_cell_interpolation:
C94B:  E6 00             ldab     0, x ; xrefs $CB4A:call, $CB54:call
C94D:  18 3A             aby      
C94F:  18 A6 01          ldaa     1, y
C952:  81 80             cmpa     #-128
C954:  26 0A             bne      $c960 ; $C960=loc_C960
C956:  18 A6 00          ldaa     0, y
C959:  81 80             cmpa     #-128
C95B:  26 1E             bne      $c97b ; $C97B=loc_C97B
C95D:  4F                clra     
C95E:  20 1B             bra      $c97b ; $C97B=loc_C97B

loc_C960:
C960:  18 E6 00          ldab     0, y ; xrefs $C954:branch
C963:  C1 80             cmpb     #-128
C965:  27 14             beq      $c97b ; $C97B=loc_C97B
C967:  10                sba      
C968:  2D 07             blt      $c971 ; $C971=loc_C971
C96A:  E6 01             ldab     1, x
C96C:  3D                mul      
C96D:  89 00             adca     #0
C96F:  20 07             bra      $c978 ; $C978=loc_C978

loc_C971:
C971:  E6 01             ldab     1, x ; xrefs $C968:branch
C973:  40                nega     
C974:  3D                mul      
C975:  89 00             adca     #0
C977:  40                nega     

loc_C978:
C978:  18 AB 00          adda     0, y ; xrefs $C96F:branch

loc_C97B:
C97B:  39                rts       ; xrefs $C95B:branch, $C95E:branch, $C965:branch

sub_C97C:
C97C:  B6 20 90          ldaa     $2090 ; xrefs $965D:call
C97F:  81 03             cmpa     #3
C981:  27 40             beq      $c9c3 ; $C9C3=loc_C9C3
C983:  B6 24 42          ldaa     $2442
C986:  27 05             beq      $c98d ; $C98D=loc_C98D
C988:  7A 24 42          dec      $2442
C98B:  20 36             bra      $c9c3 ; $C9C3=loc_C9C3

loc_C98D:
C98D:  B6 91 0B          ldaa     $910b ; xrefs $C986:branch
C990:  B7 24 42          staa     $2442
C993:  B6 24 41          ldaa     $2441
C996:  81 03             cmpa     #3
C998:  26 0A             bne      $c9a4 ; $C9A4=loc_C9A4
C99A:  B6 20 9B          ldaa     $209b
C99D:  27 24             beq      $c9c3 ; $C9C3=loc_C9C3
C99F:  7A 20 9B          dec      $209b
C9A2:  20 1F             bra      $c9c3 ; $C9C3=loc_C9C3

loc_C9A4:
C9A4:  81 05             cmpa     #5 ; xrefs $C998:branch
C9A6:  26 1B             bne      $c9c3 ; $C9C3=loc_C9C3
C9A8:  B6 20 9B          ldaa     $209b
C9AB:  81 10             cmpa     #16
C9AD:  25 0C             bcs      $c9bb ; $C9BB=loc_C9BB
C9AF:  86 10             ldaa     #16
C9B1:  B7 20 9B          staa     $209b
C9B4:  86 04             ldaa     #4
C9B6:  B7 24 41          staa     $2441
C9B9:  20 08             bra      $c9c3 ; $C9C3=loc_C9C3

loc_C9BB:
C9BB:  B1 91 09          cmpa     $9109 ; xrefs $C9AD:branch
C9BE:  27 03             beq      $c9c3 ; $C9C3=loc_C9C3
C9C0:  7C 20 9B          inc      $209b

loc_C9C3:
C9C3:  39                rts       ; xrefs $C981:branch, $C98B:branch, $C99D:branch, $C9A2:branch, $C9A6:branch, $C9B9:branch, $C9BE:branch

; ---- unreached/data gap $C9C4-$C9C7 ----

        .org $C9C8

sub_C9C8:
C9C8:  12 A5 20 0A       brset    $a5, #32, $c9d6 ; $C9D6=loc_C9D6 | xrefs $6D2F:call, $965A:call
C9CC:  B6 21 2A          ldaa     $212a
C9CF:  B1 91 00          cmpa     $9100
C9D2:  24 13             bcc      $c9e7 ; $C9E7=loc_C9E7
C9D4:  20 0B             bra      $c9e1 ; $C9E1=loc_C9E1

loc_C9D6:
C9D6:  B6 91 00          ldaa     $9100 ; xrefs $C9C8:branch
C9D9:  BB 91 01          adda     $9101
C9DC:  B1 21 2A          cmpa     $212a
C9DF:  25 06             bcs      $c9e7 ; $C9E7=loc_C9E7

loc_C9E1:
C9E1:  14 A5 20          bset     $a5, #32 ; xrefs $C9D4:branch
C9E4:  7E CA B9          jmp      $cab9 ; $CAB9=loc_CAB9

loc_C9E7:
C9E7:  15 A5 20          bclr     $a5, #32 ; xrefs $C9D2:branch, $C9DF:branch
C9EA:  18 CE C9 C4       ldy      #-13884
C9EE:  D6 5E             ldab     $5e
C9F0:  CE 00 5D          ldx      #93
C9F3:  13 A6 20 03       brclr    $a6, #32, $c9fa ; $C9FA=loc_C9FA
C9F7:  7E CA B9          jmp      $cab9 ; $CAB9=loc_CAB9

loc_C9FA:
C9FA:  B6 20 A4          ldaa     $20a4 ; xrefs $C9F3:branch
C9FD:  91 5D             cmpa     $5d
C9FF:  26 3E             bne      $ca3f ; $CA3F=loc_CA3F
CA01:  12 A6 08 11       brset    $a6, #8, $ca16 ; $CA16=loc_CA16
CA05:  13 A6 10 0A       brclr    $a6, #16, $ca13 ; $CA13=loc_CA13
CA09:  15 A6 10          bclr     $a6, #16
CA0C:  12 9C 01 03       brset    $9c, #1, $ca13 ; $009C=scheduler_status_flags, $CA13=loc_CA13
CA10:  7F 00 5F          clr      >$005f

loc_CA13:
CA13:  7E CA B6          jmp      $cab6 ; $CAB6=loc_CAB6 | xrefs $CA05:branch, $CA0C:branch

loc_CA16:
CA16:  7D 24 4F          tst      $244f ; xrefs $CA01:branch
CA19:  26 1C             bne      $ca37 ; $CA37=loc_CA37
CA1B:  15 A7 02          bclr     $a7, #2
CA1E:  15 A7 01          bclr     $a7, #1
CA21:  15 A6 08          bclr     $a6, #8
CA24:  13 A6 10 0D       brclr    $a6, #16, $ca35 ; $CA35=loc_CA35
CA28:  13 9C 01 09       brclr    $9c, #1, $ca35 ; $009C=scheduler_status_flags, $CA35=loc_CA35
CA2C:  B6 91 04          ldaa     $9104
CA2F:  B7 20 A4          staa     $20a4
CA32:  7E CA B9          jmp      $cab9 ; $CAB9=loc_CAB9

loc_CA35:
CA35:  20 7F             bra      $cab6 ; $CAB6=loc_CAB6 | xrefs $CA24:branch, $CA28:branch

loc_CA37:
CA37:  CE 24 4F          ldx      #9295 ; xrefs $CA19:branch
CA3A:  14 A7 01          bset     $a7, #1
CA3D:  20 1C             bra      $ca5b ; $CA5B=loc_CA5B

loc_CA3F:
CA3F:  25 1A             bcs      $ca5b ; $CA5B=loc_CA5B | xrefs $C9FF:branch
CA41:  13 A6 04 0A       brclr    $a6, #4, $ca4f ; $CA4F=loc_CA4F
CA45:  B6 24 60          ldaa     $2460
CA48:  26 6F             bne      $cab9 ; $CAB9=loc_CAB9
CA4A:  15 A6 04          bclr     $a6, #4
CA4D:  20 3F             bra      $ca8e ; $CA8E=loc_CA8E

loc_CA4F:
CA4F:  7F 24 61          clr      $2461 ; xrefs $CA41:branch
CA52:  6C 00             inc      0, x
CA54:  5A                decb     
CA55:  2A 37             bpl      $ca8e ; $CA8E=loc_CA8E
CA57:  C6 03             ldab     #3
CA59:  20 33             bra      $ca8e ; $CA8E=loc_CA8E

loc_CA5B:
CA5B:  12 A6 04 0A       brset    $a6, #4, $ca69 ; $CA69=loc_CA69 | xrefs $CA3D:branch, $CA3F:branch
CA5F:  B6 24 60          ldaa     $2460
CA62:  26 55             bne      $cab9 ; $CAB9=loc_CAB9
CA64:  14 A6 04          bset     $a6, #4
CA67:  20 25             bra      $ca8e ; $CA8E=loc_CA8E

loc_CA69:
CA69:  B6 90 71          ldaa     $9071 ; xrefs $CA5B:branch
CA6C:  27 18             beq      $ca86 ; $CA86=loc_CA86
CA6E:  91 5D             cmpa     $5d
CA70:  24 05             bcc      $ca77 ; $CA77=loc_CA77
CA72:  7F 24 61          clr      $2461
CA75:  20 0F             bra      $ca86 ; $CA86=loc_CA86

loc_CA77:
CA77:  B6 24 61          ldaa     $2461 ; xrefs $CA70:branch
CA7A:  81 03             cmpa     #3
CA7C:  26 05             bne      $ca83 ; $CA83=loc_CA83
CA7E:  7F 24 61          clr      $2461
CA81:  20 36             bra      $cab9 ; $CAB9=loc_CAB9

loc_CA83:
CA83:  7C 24 61          inc      $2461 ; xrefs $CA7C:branch

loc_CA86:
CA86:  6A 00             dec      0, x ; xrefs $CA6C:branch, $CA75:branch
CA88:  5C                incb     
CA89:  C1 03             cmpb     #3
CA8B:  23 01             bls      $ca8e ; $CA8E=loc_CA8E
CA8D:  5F                clrb     

loc_CA8E:
CA8E:  15 A5 08          bclr     $a5, #8 ; xrefs $CA4D:branch, $CA55:branch, $CA59:branch, $CA67:branch, $CA8B:branch
CA91:  D7 5E             stab     $5e
CA93:  18 3A             aby      
CA95:  0F                sei      
CA96:  B6 10 40          ldaa     $1040
CA99:  84 07             anda     #7
CA9B:  18 AA 00          oraa     0, y
CA9E:  15 33 01          bclr     $33, #1
CAA1:  14 33 02          bset     $33, #2
CAA4:  B7 10 40          staa     $1040
CAA7:  CE 10 00          ldx      #4096
CAAA:  1C 50 10          bset     80, x; #16
CAAD:  0E                cli      
CAAE:  B6 91 08          ldaa     $9108
CAB1:  B7 24 60          staa     $2460
CAB4:  20 03             bra      $cab9 ; $CAB9=loc_CAB9

loc_CAB6:
CAB6:  14 A5 08          bset     $a5, #8 ; xrefs $CA13:jump, $CA35:branch

loc_CAB9:
CAB9:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $C9E4:jump, $C9F7:jump, $CA32:jump, $CA48:branch, $CA62:branch, $CA81:branch, $CAB4:branch
CABC:  81 0C             cmpa     #12
CABE:  26 03             bne      $cac3 ; $CAC3=loc_CAC3
CAC0:  BD 97 59          jsr      $9759 ; $9759=sub_9759

loc_CAC3:
CAC3:  39                rts       ; xrefs $CABE:branch

; ---- unreached/data gap $CAC4-$CAC4 ----

        .org $CAC5

sub_CAC5:
CAC5:  1A A3 00          cpd      0, x ; xrefs $C5A5:call, $C5B2:call, $C5BF:call, $C5CC:call, $C5D9:call, $C5E6:call, $C5F3:call, $C6E2:call, +2 more
CAC8:  2D 09             blt      $cad3 ; $CAD3=loc_CAD3
CACA:  1A A3 02          cpd      2, x
CACD:  2F 06             ble      $cad5 ; $CAD5=loc_CAD5
CACF:  EC 02             ldd      2, x
CAD1:  20 02             bra      $cad5 ; $CAD5=loc_CAD5

loc_CAD3:
CAD3:  EC 00             ldd      0, x ; xrefs $CAC8:branch

loc_CAD5:
CAD5:  39                rts       ; xrefs $CACD:branch, $CAD1:branch

; ---- unreached/data gap $CAD6-$CAD6 ----

        .org $CAD7

sub_CAD7:
CAD7:  4F                clra      ; xrefs $B8EF:call
CAD8:  CE 24 39          ldx      #9273

loc_CADB:
CADB:  A7 00             staa     0, x ; xrefs $CAE1:branch
CADD:  08                inx      
CADE:  8C 24 66          cpx      #9318
CAE1:  26 F8             bne      $cadb ; $CADB=loc_CADB
CAE3:  B7 20 9A          staa     $209a
CAE6:  B7 20 9B          staa     $209b
CAE9:  B7 20 98          staa     $2098
CAEC:  97 A6             staa     $a6
CAEE:  B7 20 18          staa     $2018
CAF1:  97 A5             staa     $a5
CAF3:  15 A7 08          bclr     $a7, #8
CAF6:  15 A7 04          bclr     $a7, #4
CAF9:  15 A7 01          bclr     $a7, #1
CAFC:  86 01             ldaa     #1
CAFE:  B7 20 90          staa     $2090
CB01:  B7 24 41          staa     $2441
CB04:  B7 24 66          staa     $2466
CB07:  B6 91 05          ldaa     $9105
CB0A:  B7 20 8F          staa     $208f
CB0D:  96 5F             ldaa     $5f
CB0F:  81 FF             cmpa     #-1
CB11:  26 10             bne      $cb23 ; $CB23=loc_CB23
CB13:  7F 00 5E          clr      >$005e
CB16:  14 A6 10          bset     $a6, #16
CB19:  86 FF             ldaa     #-1
CB1B:  97 5D             staa     $5d
CB1D:  B6 91 03          ldaa     $9103
CB20:  BD CB 5B          jsr      $cb5b ; $CB5B=sub_CB5B

loc_CB23:
CB23:  18 CE C9 C4       ldy      #-13884 ; xrefs $CB11:branch
CB27:  D6 5E             ldab     $5e
CB29:  18 3A             aby      
CB2B:  B6 10 40          ldaa     $1040
CB2E:  84 07             anda     #7
CB30:  18 AA 00          oraa     0, y
CB33:  B7 10 40          staa     $1040
CB36:  CE 10 00          ldx      #4096
CB39:  15 33 01          bclr     $33, #1
CB3C:  14 33 02          bset     $33, #2
CB3F:  1C 50 10          bset     80, x; #16
CB42:  39                rts      

sub_CB43:
CB43:  CE 20 3C          ldx      #8252 ; xrefs $B90D:call, $C578:call
CB46:  18 CE 00 60       ldy      #96
CB4A:  BD C9 4B          jsr      $c94b ; $C94B=adaptive_cell_interpolation
CB4D:  B7 20 94          staa     $2094
CB50:  18 CE 00 69       ldy      #105
CB54:  BD C9 4B          jsr      $c94b ; $C94B=adaptive_cell_interpolation
CB57:  B7 20 95          staa     $2095
CB5A:  39                rts      

sub_CB5B:
CB5B:  B7 24 4F          staa     $244f ; xrefs $B4D7:call, $CB20:call
CB5E:  7F 20 A4          clr      $20a4
CB61:  14 A6 08          bset     $a6, #8
CB64:  14 A6 04          bset     $a6, #4
CB67:  B6 91 06          ldaa     $9106
CB6A:  B7 20 8F          staa     $208f
CB6D:  39                rts      

sub_CB6E:
CB6E:  B6 89 6A          ldaa     $896a ; xrefs $B8F5:call
CB71:  B7 24 85          staa     $2485
CB74:  B6 89 6B          ldaa     $896b
CB77:  B7 24 87          staa     $2487
CB7A:  CC 00 00          ldd      #0
CB7D:  B7 24 86          staa     $2486 ; $2486=idle_cts_target_or_cap
CB80:  B7 24 8A          staa     $248a
CB83:  B7 24 8B          staa     $248b
CB86:  B7 24 84          staa     $2484 ; $2484=idle_air_target
CB89:  B7 20 2B          staa     $202b
CB8C:  B7 24 83          staa     $2483
CB8F:  86 01             ldaa     #1
CB91:  B7 24 82          staa     $2482
CB94:  B7 24 89          staa     $2489
CB97:  15 A9 04          bclr     $a9, #4 ; $00A9=operating_mode_flags
CB9A:  39                rts      

sub_CB9B:
CB9B:  B6 24 87          ldaa     $2487 ; xrefs $D5B0:call
CB9E:  BB 89 6C          adda     $896c
CBA1:  24 02             bcc      $cba5 ; $CBA5=loc_CBA5
CBA3:  86 FF             ldaa     #-1

loc_CBA5:
CBA5:  B7 24 87          staa     $2487 ; xrefs $CBA1:branch
CBA8:  39                rts      

sub_CBA9:
CBA9:  7D 20 B1          tst      $20b1 ; $20B1=spark_fuel_bank_selector | xrefs $967E:call
CBAC:  26 0B             bne      $cbb9 ; $CBB9=loc_CBB9
CBAE:  CC 80 00          ldd      #-32768
CBB1:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word
CBB4:  FD 24 9B          std      $249b
CBB7:  20 09             bra      $cbc2 ; $CBC2=loc_CBC2

loc_CBB9:
CBB9:  BD D1 A4          jsr      $d1a4 ; $D1A4=sub_D1A4 | xrefs $CBAC:branch
CBBC:  BD CC 00          jsr      $cc00 ; $CC00=adaptive_trim_update_gate
CBBF:  BD CE 3A          jsr      $ce3a ; $CE3A=sub_CE3A

loc_CBC2:
CBC2:  39                rts       ; xrefs $CBB7:branch

; ---- unreached/data gap $CBC3-$CBC3 ----

        .org $CBC4

sub_CBC4:
CBC4:  CC 80 00          ldd      #-32768 ; xrefs $B916:call
CBC7:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word
CBCA:  FD 24 9B          std      $249b
CBCD:  4F                clra     
CBCE:  5F                clrb     
CBCF:  B7 24 9D          staa     $249d
CBD2:  FD 24 9E          std      $249e
CBD5:  97 F9             staa     $f9
CBD7:  97 FA             staa     $fa
CBD9:  97 FB             staa     $fb
CBDB:  DC 0A             ldd      $0a
CBDD:  FD 24 BF          std      $24bf
CBE0:  DC 08             ldd      $08
CBE2:  FD 24 C1          std      $24c1
CBE5:  DC 0E             ldd      $0e
CBE7:  FD 24 C3          std      $24c3
CBEA:  DC 0C             ldd      $0c
CBEC:  FD 24 C5          std      $24c5

; [CONFIRMED] Load calibration 0x800A, decrement it, and store runtime bank selector 0x20B1.
seed_bank_selector_20b1:
CBEF:  B6 80 0A          ldaa     $800a ; $800A=cal_spark_fuel_bank_config
CBF2:  26 08             bne      $cbfc ; $CBFC=loc_CBFC
CBF4:  CE 10 00          ldx      #4096
CBF7:  1E 60 04 01       brset    96, x; #4; $cbfc ; $CBFC=loc_CBFC
CBFB:  4A                deca     

loc_CBFC:
CBFC:  B7 20 B1          staa     $20b1 ; $20B1=spark_fuel_bank_selector | xrefs $CBF2:branch, $CBF7:branch
CBFF:  39                rts      

; [STRONG] Adaptive trim update/entry logic.
adaptive_trim_update_gate:
CC00:  12 9F 10 05       brset    $9f, #16, $cc09 ; $CC09=loc_CC09 | xrefs $CBBC:call
CC04:  15 FB 08          bclr     $fb, #8
CC07:  20 03             bra      $cc0c ; $CC0C=loc_CC0C

loc_CC09:
CC09:  14 FB 08          bset     $fb, #8 ; xrefs $CC00:branch

loc_CC0C:
CC0C:  13 1E 90 04       brclr    $1e, #-112, $cc14 ; $CC14=loc_CC14 | xrefs $CC07:branch
CC10:  12 A9 20 78       brset    $a9, #32, $cc8c ; $00A9=operating_mode_flags, $CC8C=loc_CC8C

loc_CC14:
CC14:  B6 20 59          ldaa     $2059 ; xrefs $CC0C:branch
CC17:  81 04             cmpa     #4
CC19:  26 71             bne      $cc8c ; $CC8C=loc_CC8C
CC1B:  12 A1 40 6D       brset    $a1, #64, $cc8c ; $CC8C=loc_CC8C
CC1F:  13 A3 91 69       brclr    $a3, #-111, $cc8c ; $CC8C=loc_CC8C
CC23:  CE 8E 3D          ldx      #-29123
CC26:  18 CE 8E 57       ldy      #-29097
CC2A:  12 FB 08 07       brset    $fb, #8, $cc35 ; $CC35=loc_CC35
CC2E:  CE 8E 36          ldx      #-29130
CC31:  18 CE 8E 46       ldy      #-29114

loc_CC35:
CC35:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19 | xrefs $CC2A:branch
CC38:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
CC3B:  9B C9             adda     $c9
CC3D:  24 02             bcc      $cc41 ; $CC41=loc_CC41
CC3F:  86 FF             ldaa     #-1

loc_CC41:
CC41:  91 10             cmpa     $10 ; xrefs $CC3D:branch
CC43:  24 47             bcc      $cc8c ; $CC8C=loc_CC8C
CC45:  96 CB             ldaa     $cb
CC47:  A1 00             cmpa     0, x
CC49:  23 41             bls      $cc8c ; $CC8C=loc_CC8C
CC4B:  DC BA             ldd      $ba ; $00BA=engine_period_delta
CC4D:  1A A3 01          cpd      1, x
CC50:  23 3A             bls      $cc8c ; $CC8C=loc_CC8C
CC52:  1A A3 05          cpd      5, x
CC55:  22 07             bhi      $cc5e ; $CC5E=loc_CC5E
CC57:  B6 20 53          ldaa     $2053
CC5A:  26 30             bne      $cc8c ; $CC8C=loc_CC8C
CC5C:  DC BA             ldd      $ba ; $00BA=engine_period_delta

loc_CC5E:
CC5E:  12 A9 40 08       brset    $a9, #64, $cc6a ; $00A9=operating_mode_flags, $CC6A=loc_CC6A | xrefs $CC55:branch
CC62:  96 CA             ldaa     $ca
CC64:  A1 04             cmpa     4, x
CC66:  23 24             bls      $cc8c ; $CC8C=loc_CC8C
CC68:  20 10             bra      $cc7a ; $CC7A=loc_CC7A

loc_CC6A:
CC6A:  13 A3 80 06       brclr    $a3, #-128, $cc74 ; $CC74=loc_CC74 | xrefs $CC5E:branch
CC6E:  1A B3 8E 44       cpd      $8e44
CC72:  23 18             bls      $cc8c ; $CC8C=loc_CC8C

loc_CC74:
CC74:  96 CA             ldaa     $ca ; xrefs $CC6A:branch
CC76:  A1 03             cmpa     3, x
CC78:  23 12             bls      $cc8c ; $CC8C=loc_CC8C

loc_CC7A:
CC7A:  14 A1 20          bset     $a1, #32 ; xrefs $CC68:branch
CC7D:  B6 92 80          ldaa     $9280
CC80:  27 04             beq      $cc86 ; $CC86=loc_CC86
CC82:  12 36 80 09       brset    $36, #-128, $cc8f ; $CC8F=loc_CC8F

loc_CC86:
CC86:  12 9F 01 17       brset    $9f, #1, $cca1 ; $CCA1=loc_CCA1 | xrefs $CC80:branch
CC8A:  20 03             bra      $cc8f ; $CC8F=loc_CC8F

loc_CC8C:
CC8C:  15 A1 20          bclr     $a1, #32 ; xrefs $CC10:branch, $CC19:branch, $CC1B:branch, $CC1F:branch, $CC43:branch, $CC49:branch, $CC50:branch, $CC5A:branch, +3 more

loc_CC8F:
CC8F:  15 9F 10          bclr     $9f, #16 ; xrefs $CC82:branch, $CC8A:branch
CC92:  7F 00 F9          clr      >$00f9
CC95:  CC 80 00          ldd      #-32768
CC98:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word
CC9B:  FD 24 9B          std      $249b
CC9E:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CCA1:
CCA1:  14 9F 10          bset     $9f, #16 ; xrefs $CC86:branch
CCA4:  15 FB 04          bclr     $fb, #4
CCA7:  12 FB 08 20       brset    $fb, #8, $cccb ; $CCCB=loc_CCCB
CCAB:  14 FB 04          bset     $fb, #4
CCAE:  4F                clra     
CCAF:  5F                clrb     
CCB0:  B7 24 9D          staa     $249d
CCB3:  FD 24 9E          std      $249e
CCB6:  FD 24 A2          std      $24a2
CCB9:  86 80             ldaa     #-128
CCBB:  B7 24 96          staa     $2496
CCBE:  B7 24 97          staa     $2497
CCC1:  14 9F 08          bset     $9f, #8
CCC4:  13 9F 04 03       brclr    $9f, #4, $cccb ; $CCCB=loc_CCCB
CCC8:  15 9F 08          bclr     $9f, #8

loc_CCCB:
CCCB:  13 9F 04 51       brclr    $9f, #4, $cd20 ; $CD20=loc_CD20 | xrefs $CCA7:branch, $CCC4:branch
CCCF:  15 FB 01          bclr     $fb, #1
CCD2:  13 9F 08 1A       brclr    $9f, #8, $ccf0 ; $CCF0=loc_CCF0
CCD6:  13 9F 20 10       brclr    $9f, #32, $ccea ; $CCEA=loc_CCEA
CCDA:  B6 24 9D          ldaa     $249d
CCDD:  26 08             bne      $cce7 ; $CCE7=loc_CCE7
CCDF:  8D 59             bsr      $cd3a ; $CD3A=sub_CD3A
CCE1:  15 9F 20          bclr     $9f, #32
CCE4:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CCE7:
CCE7:  14 FB 01          bset     $fb, #1 ; xrefs $CCDD:branch

loc_CCEA:
CCEA:  BD CD 6D          jsr      $cd6d ; $CD6D=sub_CD6D | xrefs $CCD6:branch
CCED:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CCF0:
CCF0:  12 FB 04 24       brset    $fb, #4, $cd18 ; $CD18=loc_CD18 | xrefs $CCD2:branch
CCF4:  FC 24 9E          ldd      $249e
CCF7:  26 1F             bne      $cd18 ; $CD18=loc_CD18
CCF9:  12 A3 10 1B       brset    $a3, #16, $cd18 ; $CD18=loc_CD18
CCFD:  12 FB 02 17       brset    $fb, #2, $cd18 ; $CD18=loc_CD18
CD01:  14 9F 20          bset     $9f, #32
CD04:  B6 24 AC          ldaa     $24ac
CD07:  B7 24 9D          staa     $249d
CD0A:  FC 24 AD          ldd      $24ad
CD0D:  FD 24 9E          std      $249e
CD10:  14 FB 01          bset     $fb, #1
CD13:  8D 58             bsr      $cd6d ; $CD6D=sub_CD6D
CD15:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CD18:
CD18:  15 9F 20          bclr     $9f, #32 ; xrefs $CCF0:branch, $CCF7:branch, $CCF9:branch, $CCFD:branch
CD1B:  8D 1D             bsr      $cd3a ; $CD3A=sub_CD3A
CD1D:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CD20:
CD20:  14 FB 01          bset     $fb, #1 ; xrefs $CCCB:branch
CD23:  12 9F 08 05       brset    $9f, #8, $cd2c ; $CD2C=loc_CD2C
CD27:  8D 44             bsr      $cd6d ; $CD6D=sub_CD6D
CD29:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CD2C:
CD2C:  13 9F 20 05       brclr    $9f, #32, $cd35 ; $CD35=loc_CD35 | xrefs $CD23:branch
CD30:  8D 3B             bsr      $cd6d ; $CD6D=sub_CD6D
CD32:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

loc_CD35:
CD35:  8D 03             bsr      $cd3a ; $CD3A=sub_CD3A | xrefs $CD2C:branch
CD37:  7E CE 1A          jmp      $ce1a ; $CE1A=loc_CE1A

sub_CD3A:
CD3A:  14 9F 40          bset     $9f, #64 ; xrefs $CCDF:call, $CD1B:call, $CD35:call
CD3D:  15 FB 02          bclr     $fb, #2
CD40:  B6 8E C6          ldaa     $8ec6
CD43:  B7 20 B2          staa     $20b2
CD46:  15 FB 10          bclr     $fb, #16
CD49:  FC 24 A2          ldd      $24a2
CD4C:  04                lsrd     
CD4D:  FD 24 A2          std      $24a2
CD50:  5F                clrb     
CD51:  B6 24 AB          ldaa     $24ab
CD54:  13 A3 10 03       brclr    $a3, #16, $cd5b ; $CD5B=loc_CD5B
CD58:  B6 8E 6E          ldaa     $8e6e

loc_CD5B:
CD5B:  F3 24 A2          addd     $24a2 ; xrefs $CD54:branch
CD5E:  24 03             bcc      $cd63 ; $CD63=loc_CD63
CD60:  CC FF FF          ldd      #-1

loc_CD63:
CD63:  13 FB 04 01       brclr    $fb, #4, $cd68 ; $CD68=loc_CD68 | xrefs $CD5E:branch
CD67:  04                lsrd     

loc_CD68:
CD68:  FD 24 A0          std      $24a0 ; xrefs $CD63:branch
CD6B:  20 4C             bra      $cdb9 ; $CDB9=loc_CDB9

sub_CD6D:
CD6D:  13 FB 10 45       brclr    $fb, #16, $cdb6 ; $CDB6=loc_CDB6 | xrefs $CCEA:call, $CD13:call, $CD27:call, $CD30:call
CD71:  15 FB 10          bclr     $fb, #16
CD74:  13 A3 10 0E       brclr    $a3, #16, $cd86 ; $CD86=loc_CD86
CD78:  CC 00 00          ldd      #0
CD7B:  FD 24 A2          std      $24a2
CD7E:  15 FB 02          bclr     $fb, #2
CD81:  F6 8E C5          ldab     $8ec5
CD84:  20 33             bra      $cdb9 ; $CDB9=loc_CDB9

loc_CD86:
CD86:  B6 20 B2          ldaa     $20b2 ; xrefs $CD74:branch
CD89:  27 08             beq      $cd93 ; $CD93=loc_CD93
CD8B:  4F                clra     
CD8C:  F6 24 AF          ldab     $24af
CD8F:  05                asld     
CD90:  05                asld     
CD91:  20 26             bra      $cdb9 ; $CDB9=loc_CDB9

loc_CD93:
CD93:  12 FB 02 09       brset    $fb, #2, $cda0 ; $CDA0=loc_CDA0 | xrefs $CD89:branch
CD97:  CC 00 00          ldd      #0
CD9A:  FD 24 A2          std      $24a2
CD9D:  14 FB 02          bset     $fb, #2

loc_CDA0:
CDA0:  F6 8E C4          ldab     $8ec4 ; xrefs $CD93:branch
CDA3:  05                asld     
CDA4:  05                asld     
CDA5:  36                psha     
CDA6:  37                pshb     
CDA7:  F3 24 A2          addd     $24a2
CDAA:  24 03             bcc      $cdaf ; $CDAF=loc_CDAF
CDAC:  CC FF FF          ldd      #-1

loc_CDAF:
CDAF:  FD 24 A2          std      $24a2 ; xrefs $CDAA:branch
CDB2:  33                pulb     
CDB3:  32                pula     
CDB4:  20 03             bra      $cdb9 ; $CDB9=loc_CDB9

loc_CDB6:
CDB6:  7E CE 38          jmp      $ce38 ; $CE38=loc_CE38 | xrefs $CD6D:branch

loc_CDB9:
CDB9:  FD 24 B0          std      $24b0 ; xrefs $CD6B:branch, $CD84:branch, $CD91:branch, $CDB4:branch
CDBC:  FC 20 B9          ldd      $20b9 ; $20B9=adaptive_fuel_trim_word
CDBF:  13 FB 01 17       brclr    $fb, #1, $cdda ; $CDDA=loc_CDDA
CDC3:  F3 24 B0          addd     $24b0
CDC6:  25 29             bcs      $cdf1 ; $CDF1=loc_CDF1
CDC8:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word
CDCB:  FD 24 B0          std      $24b0
CDCE:  5F                clrb     
CDCF:  B6 24 96          ldaa     $2496
CDD2:  1A B3 20 B9       cpd      $20b9 ; $20B9=adaptive_fuel_trim_word
CDD6:  25 23             bcs      $cdfb ; $CDFB=loc_CDFB
CDD8:  20 27             bra      $ce01 ; $CE01=loc_CE01

loc_CDDA:
CDDA:  B3 24 B0          subd     $24b0 ; xrefs $CDBF:branch
CDDD:  25 18             bcs      $cdf7 ; $CDF7=loc_CDF7
CDDF:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word
CDE2:  FD 24 B0          std      $24b0
CDE5:  5F                clrb     
CDE6:  B6 24 97          ldaa     $2497
CDE9:  1A B3 20 B9       cpd      $20b9 ; $20B9=adaptive_fuel_trim_word
CDED:  22 0C             bhi      $cdfb ; $CDFB=loc_CDFB
CDEF:  20 10             bra      $ce01 ; $CE01=loc_CE01

loc_CDF1:
CDF1:  5F                clrb      ; xrefs $CDC6:branch
CDF2:  B6 24 96          ldaa     $2496
CDF5:  20 04             bra      $cdfb ; $CDFB=loc_CDFB

loc_CDF7:
CDF7:  5F                clrb      ; xrefs $CDDD:branch
CDF8:  B6 24 97          ldaa     $2497

loc_CDFB:
CDFB:  FD 20 B9          std      $20b9 ; $20B9=adaptive_fuel_trim_word | xrefs $CDD6:branch, $CDED:branch, $CDF5:branch
CDFE:  FD 24 B0          std      $24b0

loc_CE01:
CE01:  CE 24 98          ldx      #9368 ; xrefs $CDD8:branch, $CDEF:branch
CE04:  FC 24 9B          ldd      $249b
CE07:  ED 00             std      0, x
CE09:  B6 8E 6D          ldaa     $8e6d
CE0C:  A7 02             staa     2, x
CE0E:  FC 20 B9          ldd      $20b9 ; $20B9=adaptive_fuel_trim_word
CE11:  BD B4 07          jsr      $b407 ; $B407=sub_B407
CE14:  FD 24 9B          std      $249b
CE17:  7E CE 38          jmp      $ce38 ; $CE38=loc_CE38

loc_CE1A:
CE1A:  14 9F 08          bset     $9f, #8 ; xrefs $CC9E:jump, $CCE4:jump, $CCED:jump, $CD15:jump, $CD1D:jump, $CD29:jump, $CD32:jump, $CD37:jump
CE1D:  12 9F 04 03       brset    $9f, #4, $ce24 ; $CE24=loc_CE24
CE21:  15 9F 08          bclr     $9f, #8

loc_CE24:
CE24:  B6 24 9D          ldaa     $249d ; xrefs $CE1D:branch
CE27:  27 04             beq      $ce2d ; $CE2D=loc_CE2D
CE29:  4A                deca     
CE2A:  B7 24 9D          staa     $249d

loc_CE2D:
CE2D:  FC 24 9E          ldd      $249e ; xrefs $CE27:branch
CE30:  27 06             beq      $ce38 ; $CE38=loc_CE38
CE32:  83 00 01          subd     #1
CE35:  FD 24 9E          std      $249e

loc_CE38:
CE38:  39                rts       ; xrefs $CDB6:jump, $CE17:jump, $CE30:branch

; ---- unreached/data gap $CE39-$CE39 ----

        .org $CE3A

sub_CE3A:
CE3A:  12 9F 40 03       brset    $9f, #64, $ce41 ; $CE41=loc_CE41 | xrefs $CBBF:call
CE3E:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

loc_CE41:
CE41:  15 9F 40          bclr     $9f, #64 ; xrefs $CE3A:branch
CE44:  12 A4 40 18       brset    $a4, #64, $ce60 ; $00A4=limiter_mode_flags, $CE60=loc_CE60
CE48:  96 CA             ldaa     $ca
CE4A:  B1 8F C6          cmpa     $8fc6
CE4D:  23 11             bls      $ce60 ; $CE60=loc_CE60
CE4F:  96 CB             ldaa     $cb
CE51:  B1 8F C7          cmpa     $8fc7
CE54:  23 0A             bls      $ce60 ; $CE60=loc_CE60
CE56:  B6 8E 6B          ldaa     $8e6b
CE59:  5F                clrb     
CE5A:  1A B3 24 9B       cpd      $249b
CE5E:  23 03             bls      $ce63 ; $CE63=loc_CE63

loc_CE60:
CE60:  7E D0 C3          jmp      $d0c3 ; $D0C3=loc_D0C3 | xrefs $CE44:branch, $CE4D:branch, $CE54:branch

loc_CE63:
CE63:  13 A3 10 6A       brclr    $a3, #16, $ced1 ; $CED1=loc_CED1 | xrefs $CE5E:branch
CE67:  B6 20 2B          ldaa     $202b
CE6A:  B1 89 6F          cmpa     $896f
CE6D:  23 2E             bls      $ce9d ; $CE9D=loc_CE9D
CE6F:  12 F9 04 58       brset    $f9, #4, $cecb ; $CECB=loc_CECB
CE73:  CC 00 0A          ldd      #10
CE76:  FD 24 BA          std      $24ba
CE79:  CC 24 BF          ldd      #9407
CE7C:  FD 24 BC          std      $24bc
CE7F:  86 02             ldaa     #2
CE81:  B7 24 BE          staa     $24be
CE84:  86 04             ldaa     #4
CE86:  97 F9             staa     $f9
CE88:  F6 8F D7          ldab     $8fd7
CE8B:  F7 20 B5          stab     $20b5
CE8E:  FE 8F D8          ldx      $8fd8
CE91:  18 FE 8F DA       ldy      $8fda
CE95:  FC 8F DC          ldd      $8fdc
CE98:  BD D0 3C          jsr      $d03c ; $D03C=sub_D03C
CE9B:  20 31             bra      $cece ; $CECE=loc_CECE

loc_CE9D:
CE9D:  12 F9 02 2A       brset    $f9, #2, $cecb ; $CECB=loc_CECB | xrefs $CE6D:branch
CEA1:  CC 00 08          ldd      #8
CEA4:  FD 24 BA          std      $24ba
CEA7:  CC 24 C1          ldd      #9409
CEAA:  FD 24 BC          std      $24bc
CEAD:  86 01             ldaa     #1
CEAF:  B7 24 BE          staa     $24be
CEB2:  86 02             ldaa     #2
CEB4:  97 F9             staa     $f9
CEB6:  F6 8F D0          ldab     $8fd0
CEB9:  F7 20 B5          stab     $20b5
CEBC:  FE 8F D1          ldx      $8fd1
CEBF:  18 FE 8F D3       ldy      $8fd3
CEC3:  FC 8F D5          ldd      $8fd5
CEC6:  BD D0 3C          jsr      $d03c ; $D03C=sub_D03C
CEC9:  20 03             bra      $cece ; $CECE=loc_CECE

loc_CECB:
CECB:  BD D0 4C          jsr      $d04c ; $D04C=sub_D04C | xrefs $CE6F:branch, $CE9D:branch

loc_CECE:
CECE:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6 | xrefs $CE9B:branch, $CEC9:branch

loc_CED1:
CED1:  12 A2 01 33       brset    $a2, #1, $cf08 ; $00A2=spark_mode_flags, $CF08=loc_CF08 | xrefs $CE63:branch
CED5:  12 A3 01 2F       brset    $a3, #1, $cf08 ; $CF08=loc_CF08
CED9:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
CEDB:  B0 20 1E          suba     $201e
CEDE:  24 01             bcc      $cee1 ; $CEE1=loc_CEE1
CEE0:  40                nega     

loc_CEE1:
CEE1:  B1 8F CE          cmpa     $8fce ; xrefs $CEDE:branch
CEE4:  24 22             bcc      $cf08 ; $CF08=loc_CF08
CEE6:  96 BA             ldaa     $ba ; $00BA=engine_period_delta
CEE8:  B1 8F C8          cmpa     $8fc8
CEEB:  24 1B             bcc      $cf08 ; $CF08=loc_CF08
CEED:  B1 8F C9          cmpa     $8fc9
CEF0:  23 16             bls      $cf08 ; $CF08=loc_CF08
CEF2:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
CEF4:  B1 8F CA          cmpa     $8fca
CEF7:  25 0F             bcs      $cf08 ; $CF08=loc_CF08
CEF9:  B1 8F CB          cmpa     $8fcb
CEFC:  23 0D             bls      $cf0b ; $CF0B=loc_CF0B
CEFE:  B1 8F CD          cmpa     $8fcd
CF01:  22 05             bhi      $cf08 ; $CF08=loc_CF08
CF03:  B1 8F CC          cmpa     $8fcc
CF06:  24 6D             bcc      $cf75 ; $CF75=loc_CF75

loc_CF08:
CF08:  7E D0 C3          jmp      $d0c3 ; $D0C3=loc_D0C3 | xrefs $CED1:branch, $CED5:branch, $CEE4:branch, $CEEB:branch, $CEF0:branch, $CEF7:branch, $CF01:branch

loc_CF0B:
CF0B:  B6 20 2B          ldaa     $202b ; xrefs $CEFC:branch
CF0E:  B1 89 6F          cmpa     $896f
CF11:  23 2E             bls      $cf41 ; $CF41=loc_CF41
CF13:  12 F9 10 58       brset    $f9, #16, $cf6f ; $CF6F=loc_CF6F
CF17:  CC 00 0E          ldd      #14
CF1A:  FD 24 BA          std      $24ba
CF1D:  CC 24 C3          ldd      #9411
CF20:  FD 24 BC          std      $24bc
CF23:  86 08             ldaa     #8
CF25:  B7 24 BE          staa     $24be
CF28:  86 10             ldaa     #16
CF2A:  97 F9             staa     $f9
CF2C:  F6 8F E5          ldab     $8fe5
CF2F:  F7 20 B5          stab     $20b5
CF32:  FE 8F E6          ldx      $8fe6
CF35:  18 FE 8F E8       ldy      $8fe8
CF39:  FC 8F EA          ldd      $8fea
CF3C:  BD D0 3C          jsr      $d03c ; $D03C=sub_D03C
CF3F:  20 31             bra      $cf72 ; $CF72=loc_CF72

loc_CF41:
CF41:  12 F9 08 2A       brset    $f9, #8, $cf6f ; $CF6F=loc_CF6F | xrefs $CF11:branch
CF45:  CC 00 0C          ldd      #12
CF48:  FD 24 BA          std      $24ba
CF4B:  CC 24 C5          ldd      #9413
CF4E:  FD 24 BC          std      $24bc
CF51:  86 04             ldaa     #4
CF53:  B7 24 BE          staa     $24be
CF56:  86 08             ldaa     #8
CF58:  97 F9             staa     $f9
CF5A:  F6 8F DE          ldab     $8fde
CF5D:  F7 20 B5          stab     $20b5
CF60:  FE 8F DF          ldx      $8fdf
CF63:  18 FE 8F E1       ldy      $8fe1
CF67:  FC 8F E3          ldd      $8fe3
CF6A:  BD D0 3C          jsr      $d03c ; $D03C=sub_D03C
CF6D:  20 03             bra      $cf72 ; $CF72=loc_CF72

loc_CF6F:
CF6F:  BD D0 4C          jsr      $d04c ; $D04C=sub_D04C | xrefs $CF13:branch, $CF41:branch

loc_CF72:
CF72:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6 | xrefs $CF3F:branch, $CF6D:branch

loc_CF75:
CF75:  12 F9 01 10       brset    $f9, #1, $cf89 ; $CF89=loc_CF89 | xrefs $CF06:branch
CF79:  86 01             ldaa     #1
CF7B:  97 F9             staa     $f9
CF7D:  CE 00 00          ldx      #0
CF80:  FF 24 B2          stx      $24b2
CF83:  B6 8F EC          ldaa     $8fec
CF86:  B7 20 B5          staa     $20b5

loc_CF89:
CF89:  F6 20 B9          ldab     $20b9 ; $20B9=adaptive_fuel_trim_word | xrefs $CF75:branch
CF8C:  4F                clra     
CF8D:  F3 24 B2          addd     $24b2
CF90:  24 03             bcc      $cf95 ; $CF95=loc_CF95
CF92:  CC FF FF          ldd      #-1

loc_CF95:
CF95:  8F                xgdx      ; xrefs $CF90:branch
CF96:  FF 24 B2          stx      $24b2
CF99:  7A 20 B5          dec      $20b5
CF9C:  26 6B             bne      $d009 ; $D009=loc_D009
CF9E:  7F 00 F9          clr      >$00f9
CFA1:  DC 06             ldd      $06
CFA3:  BC 8F ED          cpx      $8fed
CFA6:  22 13             bhi      $cfbb ; $CFBB=loc_CFBB
CFA8:  BC 8F EF          cpx      $8fef
CFAB:  24 1C             bcc      $cfc9 ; $CFC9=loc_CFC9
CFAD:  83 00 01          subd     #1
CFB0:  1A 83 FD 00       cpd      #-768
CFB4:  2C 11             bge      $cfc7 ; $CFC7=loc_CFC7
CFB6:  CC FD 00          ldd      #-768
CFB9:  20 0C             bra      $cfc7 ; $CFC7=loc_CFC7

loc_CFBB:
CFBB:  C3 00 01          addd     #1 ; xrefs $CFA6:branch
CFBE:  1A 83 03 00       cpd      #768
CFC2:  2F 03             ble      $cfc7 ; $CFC7=loc_CFC7
CFC4:  CC 03 00          ldd      #768

loc_CFC7:
CFC7:  DD 06             std      $06 ; xrefs $CFB4:branch, $CFB9:branch, $CFC2:branch

loc_CFC9:
CFC9:  13 FA 02 0C       brclr    $fa, #2, $cfd9 ; $CFD9=loc_CFD9 | xrefs $CFAB:branch
CFCD:  CE 00 0A          ldx      #10
CFD0:  BD D0 0F          jsr      $d00f ; $D00F=sub_D00F
CFD3:  FD 24 BF          std      $24bf
CFD6:  15 FA 02          bclr     $fa, #2

loc_CFD9:
CFD9:  13 FA 01 0C       brclr    $fa, #1, $cfe9 ; $CFE9=loc_CFE9 | xrefs $CFC9:branch
CFDD:  CE 00 08          ldx      #8
CFE0:  BD D0 0F          jsr      $d00f ; $D00F=sub_D00F
CFE3:  FD 24 C1          std      $24c1
CFE6:  15 FA 01          bclr     $fa, #1

loc_CFE9:
CFE9:  13 FA 08 0C       brclr    $fa, #8, $cff9 ; $CFF9=loc_CFF9 | xrefs $CFD9:branch
CFED:  CE 00 0E          ldx      #14
CFF0:  BD D0 0F          jsr      $d00f ; $D00F=sub_D00F
CFF3:  FD 24 C3          std      $24c3
CFF6:  15 FA 08          bclr     $fa, #8

loc_CFF9:
CFF9:  13 FA 04 0C       brclr    $fa, #4, $d009 ; $D009=loc_D009 | xrefs $CFE9:branch
CFFD:  CE 00 0C          ldx      #12
D000:  BD D0 0F          jsr      $d00f ; $D00F=sub_D00F
D003:  FD 24 C5          std      $24c5
D006:  15 FA 04          bclr     $fa, #4

loc_D009:
D009:  BD 62 52          jsr      $6252 ; $6252=sub_6252 | xrefs $CF9C:branch, $CFF9:branch
D00C:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

sub_D00F:
D00F:  EC 00             ldd      0, x ; xrefs $CFD0:call, $CFE0:call, $CFF0:call, $D000:call
D011:  F3 8F FD          addd     $8ffd
D014:  1A 83 00 FF       cpd      #255
D018:  2F 09             ble      $d023 ; $D023=loc_D023
D01A:  CC 00 FF          ldd      #255
D01D:  B3 8F FD          subd     $8ffd
D020:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

loc_D023:
D023:  EC 00             ldd      0, x ; xrefs $D018:branch
D025:  B3 8F FD          subd     $8ffd
D028:  1A 83 FF 00       cpd      #-256
D02C:  2C 09             bge      $d037 ; $D037=loc_D037
D02E:  CC FF 00          ldd      #-256
D031:  F3 8F FD          addd     $8ffd
D034:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

loc_D037:
D037:  EC 00             ldd      0, x ; xrefs $D02C:branch
D039:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

sub_D03C:
D03C:  FF 24 B4          stx      $24b4 ; xrefs $CE98:call, $CEC6:call, $CF3C:call, $CF6A:call
D03F:  18 FF 24 B6       sty      $24b6
D043:  FD 24 B8          std      $24b8
D046:  CC 00 00          ldd      #0
D049:  FD 24 B2          std      $24b2

sub_D04C:
D04C:  F6 20 B9          ldab     $20b9 ; $20B9=adaptive_fuel_trim_word | xrefs $CECB:call, $CF6F:call
D04F:  4F                clra     
D050:  F3 24 B2          addd     $24b2
D053:  24 03             bcc      $d058 ; $D058=loc_D058
D055:  CC FF FF          ldd      #-1

loc_D058:
D058:  8F                xgdx      ; xrefs $D053:branch
D059:  FF 24 B2          stx      $24b2
D05C:  7A 20 B5          dec      $20b5
D05F:  26 5C             bne      $d0bd ; $D0BD=loc_D0BD
D061:  7F 00 F9          clr      >$00f9
D064:  18 FE 24 BA       ldy      $24ba
D068:  18 EC 00          ldd      0, y
D06B:  BC 24 B4          cpx      $24b4
D06E:  23 1A             bls      $d08a ; $D08A=loc_D08A
D070:  F3 24 B8          addd     $24b8
D073:  18 ED 00          std      0, y
D076:  B3 8F FD          subd     $8ffd
D079:  18 FE 24 BC       ldy      $24bc
D07D:  CD A3 00          cpd      0, y
D080:  2F 33             ble      $d0b5 ; $D0B5=loc_D0B5
D082:  18 EC 00          ldd      0, y
D085:  F3 8F FD          addd     $8ffd
D088:  20 1D             bra      $d0a7 ; $D0A7=loc_D0A7

loc_D08A:
D08A:  BC 24 B6          cpx      $24b6 ; xrefs $D06E:branch
D08D:  24 2E             bcc      $d0bd ; $D0BD=loc_D0BD
D08F:  B3 24 B8          subd     $24b8
D092:  18 ED 00          std      0, y
D095:  F3 8F FD          addd     $8ffd
D098:  18 FE 24 BC       ldy      $24bc
D09C:  CD A3 00          cpd      0, y
D09F:  2C 14             bge      $d0b5 ; $D0B5=loc_D0B5
D0A1:  18 EC 00          ldd      0, y
D0A4:  B3 8F FD          subd     $8ffd

loc_D0A7:
D0A7:  18 FE 24 BA       ldy      $24ba ; xrefs $D088:branch
D0AB:  18 ED 00          std      0, y
D0AE:  B6 24 BE          ldaa     $24be
D0B1:  9A FA             oraa     $fa
D0B3:  20 06             bra      $d0bb ; $D0BB=loc_D0BB

loc_D0B5:
D0B5:  B6 24 BE          ldaa     $24be ; xrefs $D080:branch, $D09F:branch
D0B8:  43                coma     
D0B9:  94 FA             anda     $fa

loc_D0BB:
D0BB:  97 FA             staa     $fa ; xrefs $D0B3:branch

loc_D0BD:
D0BD:  BD 62 52          jsr      $6252 ; $6252=sub_6252 | xrefs $D05F:branch, $D08D:branch
D0C0:  7E D0 C6          jmp      $d0c6 ; $D0C6=loc_D0C6

loc_D0C3:
D0C3:  7F 00 F9          clr      >$00f9 ; xrefs $CE60:jump, $CF08:jump

loc_D0C6:
D0C6:  39                rts       ; xrefs $CE3E:jump, $CECE:jump, $CF72:jump, $D00C:jump, $D020:jump, $D034:jump, $D039:jump, $D0C0:jump

; ---- unreached/data gap $D0C7-$D0C7 ----

        .org $D0C8

sub_D0C8:
D0C8:  B6 20 B2          ldaa     $20b2 ; xrefs $B44D:call
D0CB:  27 04             beq      $d0d1 ; $D0D1=loc_D0D1
D0CD:  4A                deca     
D0CE:  B7 20 B2          staa     $20b2

loc_D0D1:
D0D1:  14 FB 10          bset     $fb, #16 ; xrefs $D0CB:branch
D0D4:  B6 24 96          ldaa     $2496
D0D7:  BB 8E 6A          adda     $8e6a
D0DA:  25 05             bcs      $d0e1 ; $D0E1=loc_D0E1
D0DC:  B1 8E 68          cmpa     $8e68
D0DF:  23 03             bls      $d0e4 ; $D0E4=loc_D0E4

loc_D0E1:
D0E1:  B6 8E 68          ldaa     $8e68 ; xrefs $D0DA:branch

loc_D0E4:
D0E4:  B7 24 96          staa     $2496 ; xrefs $D0DF:branch
D0E7:  B6 24 97          ldaa     $2497
D0EA:  B0 8E 6A          suba     $8e6a
D0ED:  25 05             bcs      $d0f4 ; $D0F4=loc_D0F4
D0EF:  B1 8E 69          cmpa     $8e69
D0F2:  22 03             bhi      $d0f7 ; $D0F7=loc_D0F7

loc_D0F4:
D0F4:  B6 8E 69          ldaa     $8e69 ; xrefs $D0ED:branch

loc_D0F7:
D0F7:  B7 24 97          staa     $2497 ; xrefs $D0F2:branch
D0FA:  FE 20 B3          ldx      $20b3
D0FD:  27 04             beq      $d103 ; $D103=loc_D103
D0FF:  09                dex      
D100:  FF 20 B3          stx      $20b3

loc_D103:
D103:  39                rts       ; xrefs $D0FD:branch

; ---- unreached/data gap $D104-$D104 ----

        .org $D105

sub_D105:
D105:  18 CE 24 A4       ldy      #9380 ; xrefs $D613:call
D109:  FC 20 44          ldd      $2044 ; $2044=rpm_site_index_19
D10C:  18 ED 02          std      2, y
D10F:  D6 D0             ldab     $d0 ; $00D0=load_aircharge_byte
D111:  C0 60             subb     #96
D113:  24 01             bcc      $d116 ; $D116=loc_D116
D115:  5F                clrb     

loc_D116:
D116:  4F                clra      ; xrefs $D113:branch
D117:  05                asld     
D118:  05                asld     
D119:  05                asld     
D11A:  1A 83 04 00       cpd      #1024
D11E:  23 03             bls      $d123 ; $D123=loc_D123
D120:  CC 04 00          ldd      #1024

loc_D123:
D123:  18 ED 00          std      0, y ; xrefs $D11E:branch
D126:  86 05             ldaa     #5
D128:  18 A7 06          staa     6, y
D12B:  CC 8E 6F          ldd      #-29073
D12E:  18 ED 04          std      4, y
D131:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
D134:  B7 24 AB          staa     $24ab
D137:  CC 8F 1C          ldd      #-28900
D13A:  18 ED 04          std      4, y
D13D:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
D140:  B7 24 AC          staa     $24ac
D143:  CC 8F 71          ldd      #-28815
D146:  18 ED 04          std      4, y
D149:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
D14C:  5F                clrb     
D14D:  04                lsrd     
D14E:  04                lsrd     
D14F:  04                lsrd     
D150:  04                lsrd     
D151:  FD 24 AD          std      $24ad
D154:  CC 8E C7          ldd      #-28985
D157:  18 ED 04          std      4, y
D15A:  BD B2 D6          jsr      $b2d6 ; $B2D6=interp_2d_u8
D15D:  B7 24 AF          staa     $24af
D160:  CE 24 A4          ldx      #9380
D163:  FC 20 1E          ldd      $201e
D166:  FD 24 A4          std      $24a4
D169:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
D16B:  F6 8F CF          ldab     $8fcf
D16E:  BD B3 F6          jsr      $b3f6 ; $B3F6=sub_B3F6
D171:  FD 20 1E          std      $201e
D174:  39                rts      

; ---- unreached/data gap $D175-$D175 ----

        .org $D176

sub_D176:
D176:  4F                clra      ; xrefs $B8E6:call
D177:  B7 20 B7          staa     $20b7
D17A:  97 9F             staa     $9f
D17C:  39                rts      

; [STRONG] Adaptive/closed-loop substate calculation.
adaptive_substate:
D17D:  D1 B3             cmpb     $b3
D17F:  D1 BB             cmpb     $bb
D181:  D1 C9             cmpb     $c9
D183:  D1 EC             cmpb     $ec
D185:  D2 0D             sbcb     $0d
D187:  D2 3D             sbcb     $3d
D189:  D2 61             sbcb     $61
D18B:  D2 79             sbcb     $79
D18D:  D2 9D             sbcb     $9d
D18F:  D2 B4             sbcb     $b4
D191:  D1 D5             cmpb     $d5
D193:  D2 33             sbcb     $33
D195:  D2 93             sbcb     $93
D197:  00                test     
D198:  00                test     
D199:  00                test     
D19A:  00                test     
D19B:  00                test     
D19C:  05                asld     
D19D:  05                asld     
D19E:  01                nop      
D19F:  01                nop      
D1A0:  00                test     
D1A1:  00                test     
D1A2:  01                nop      
D1A3:  01                nop      

sub_D1A4:
D1A4:  CE D1 7D          ldx      #-11907 ; xrefs $CBB9:call
D1A7:  F6 20 B7          ldab     $20b7
D1AA:  58                aslb     
D1AB:  3A                abx      
D1AC:  F6 20 B6          ldab     $20b6
D1AF:  EE 00             ldx      0, x
D1B1:  6E 00             jmp      0, x

; ---- unreached/data gap $D1B3-$D2D8 ----

        .org $D2D9

; [CONFIRMED] Timer/stack/watchdog guard followed by the fixed periodic scheduler.
main_runtime_loop:
D2D9:  FC 10 0E          ldd      $100e ; $100E=TCNT | read free-running timer | xrefs $B93A:jump, $D6A9:jump
D2DC:  B3 24 E7          subd     $24e7 ; $24E7=main_loop_previous_timer
D2DF:  1A B3 24 E5       cpd      $24e5 ; $24E5=main_loop_elapsed_max_or_budget
D2E3:  25 03             bcs      $d2e8 ; $D2E8=loc_D2E8
D2E5:  FD 24 E5          std      $24e5 ; $24E5=main_loop_elapsed_max_or_budget

loc_D2E8:
D2E8:  FC 10 0E          ldd      $100e ; $100E=TCNT | xrefs $D2E3:branch
D2EB:  FD 24 E7          std      $24e7 ; $24E7=main_loop_previous_timer
D2EE:  BF 24 EA          sts      $24ea ; $24EA=main_loop_saved_sp | save current stack pointer
D2F1:  FE 24 EA          ldx      $24ea ; $24EA=main_loop_saved_sp
D2F4:  BC 91 6A          cpx      $916a ; $916A=expected_stack_top | compare saved stack pointer with expected stack top
D2F7:  26 18             bne      $d311 ; $D311=loc_D311
D2F9:  B6 10 24          ldaa     $1024 ; $1024=TMSK2_or_status
D2FC:  12 9C 01 16       brset    $9c, #1, $d316 ; $009C=scheduler_status_flags, $D316=loc_D316
D300:  12 8D 80 04       brset    $8d, #-128, $d308 ; $D308=loc_D308
D304:  81 C1             cmpa     #-63
D306:  20 02             bra      $d30a ; $D30A=loc_D30A

loc_D308:
D308:  81 E1             cmpa     #-31 ; xrefs $D300:branch

loc_D30A:
D30A:  26 05             bne      $d311 ; $D311=loc_D311 | xrefs $D306:branch
D30C:  07                tpa      
D30D:  84 10             anda     #16
D30F:  27 05             beq      $d316 ; $D316=loc_D316

loc_D311:
D311:  14 99 01          bset     $99, #1 ; $0099=runtime_fault_flags | xrefs $D2F7:branch, $D30A:branch
D314:  20 0C             bra      $d322 ; $D322=loc_D322

loc_D316:
D316:  15 99 01          bclr     $99, #1 ; $0099=runtime_fault_flags | xrefs $D2FC:branch, $D30F:branch
D319:  86 55             ldaa     #85
D31B:  B7 10 3A          staa     $103a ; $103A=COPRST
D31E:  43                coma     
D31F:  B7 10 3A          staa     $103a ; $103A=COPRST

loc_D322:
D322:  12 B4 01 03       brset    $b4, #1, $d329 ; $D329=loc_D329 | xrefs $D314:branch
D326:  7E D3 E8          jmp      $d3e8 ; $D3E8=loc_D3E8

loc_D329:
D329:  15 B4 01          bclr     $b4, #1 ; xrefs $D322:branch
D32C:  0F                sei      
D32D:  12 B4 02 0A       brset    $b4, #2, $d33b ; $D33B=loc_D33B
D331:  13 B4 0C 3A       brclr    $b4, #12, $d36f ; $D36F=main_periodic_body
D335:  B6 92 E5          ldaa     $92e5
D338:  B7 20 F0          staa     $20f0

loc_D33B:
D33B:  CE 10 00          ldx      #4096 ; xrefs $D32D:branch
D33E:  1D 20 50          bclr     32, x; #80
D341:  1C 20 A0          bset     32, x; #-96
D344:  86 60             ldaa     #96
D346:  B7 10 0B          staa     $100b ; $100B=CFORC
D349:  12 B4 04 03       brset    $b4, #4, $d350 ; $D350=loc_D350
D34D:  7E B8 F8          jmp      $b8f8 ; $B8F8=loc_B8F8

loc_D350:
D350:  B6 92 E7          ldaa     $92e7 ; xrefs $D349:branch
D353:  C6 55             ldab     #85

loc_D355:
D355:  CE 02 99          ldx      #665 ; xrefs $D364:branch

loc_D358:
D358:  09                dex       ; xrefs $D359:branch
D359:  26 FD             bne      $d358 ; $D358=loc_D358
D35B:  F7 10 3A          stab     $103a ; $103A=COPRST
D35E:  53                comb     
D35F:  F7 10 3A          stab     $103a ; $103A=COPRST
D362:  53                comb     
D363:  4A                deca     
D364:  26 EF             bne      $d355 ; $D355=loc_D355
D366:  FC 20 14          ldd      $2014
D369:  FD 21 11          std      $2111
D36C:  7E B8 E6          jmp      $b8e6 ; $B8E6=loc_B8E6

; [CONFIRMED] Main ordered periodic call body.
main_periodic_body:
D36F:  0E                cli       ; xrefs $D331:branch
D370:  BD B4 76          jsr      $b476 ; $B476=runtime_stage_b476
D373:  BD B4 8C          jsr      $b48c ; $B48C=runtime_stage_b48c
D376:  BD C9 10          jsr      $c910 ; $C910=runtime_stage_c910
D379:  BD 58 28          jsr      $5828 ; $5828=runtime_input_processing_5828
D37C:  BD B5 62          jsr      $b562 ; $B562=runtime_stage_b562
D37F:  BD 65 0D          jsr      $650d ; $650D=runtime_state_650d
D382:  CE 00 12          ldx      #18
D385:  C6 03             ldab     #3

loc_D387:
D387:  A6 02             ldaa     2, x ; xrefs $D392:branch
D389:  27 03             beq      $d38e ; $D38E=loc_D38E
D38B:  4A                deca     
D38C:  A7 02             staa     2, x

loc_D38E:
D38E:  3A                abx       ; xrefs $D389:branch
D38F:  8C 00 4B          cpx      #75
D392:  26 F3             bne      $d387 ; $D387=loc_D387
D394:  FE 21 99          ldx      $2199
D397:  27 19             beq      $d3b2 ; $D3B2=loc_D3B2
D399:  8C FF FF          cpx      #-1
D39C:  27 06             beq      $d3a4 ; $D3A4=loc_D3A4
D39E:  09                dex      
D39F:  FF 21 99          stx      $2199
D3A2:  20 0E             bra      $d3b2 ; $D3B2=loc_D3B2

loc_D3A4:
D3A4:  FE 21 9B          ldx      $219b ; xrefs $D39C:branch
D3A7:  27 09             beq      $d3b2 ; $D3B2=loc_D3B2
D3A9:  8C FF FF          cpx      #-1
D3AC:  27 04             beq      $d3b2 ; $D3B2=loc_D3B2
D3AE:  09                dex      
D3AF:  FF 21 9B          stx      $219b

loc_D3B2:
D3B2:  B6 92 80          ldaa     $9280 ; xrefs $D397:branch, $D3A2:branch, $D3A7:branch, $D3AC:branch
D3B5:  27 13             beq      $d3ca ; $D3CA=loc_D3CA
D3B7:  13 A1 20 15       brclr    $a1, #32, $d3d0 ; $D3D0=loc_D3D0
D3BB:  B6 20 B7          ldaa     $20b7
D3BE:  81 02             cmpa     #2
D3C0:  26 08             bne      $d3ca ; $D3CA=loc_D3CA
D3C2:  FE 21 9D          ldx      $219d
D3C5:  27 09             beq      $d3d0 ; $D3D0=loc_D3D0
D3C7:  09                dex      
D3C8:  20 03             bra      $d3cd ; $D3CD=loc_D3CD

loc_D3CA:
D3CA:  FE 92 83          ldx      $9283 ; xrefs $D3B5:branch, $D3C0:branch

loc_D3CD:
D3CD:  FF 21 9D          stx      $219d ; xrefs $D3C8:branch

loc_D3D0:
D3D0:  B6 21 31          ldaa     $2131 ; xrefs $D3B7:branch, $D3C5:branch
D3D3:  B7 20 11          staa     $2011
D3D6:  7F 21 31          clr      $2131
D3D9:  BD 42 D0          jsr      $42d0 ; $42D0=sub_42D0
D3DC:  BD 4C 5B          jsr      $4c5b ; $4C5B=sub_4C5B
D3DF:  BD 4E CD          jsr      $4ecd ; $4ECD=sub_4ECD
D3E2:  BD 9D 25          jsr      $9d25 ; $9D25=runtime_stage_9d25
D3E5:  BD 42 14          jsr      $4214 ; $4214=sub_4214

loc_D3E8:
D3E8:  12 96 01 23       brset    $96, #1, $d40f ; $D40F=loc_D40F | xrefs $D326:jump
D3EC:  13 A9 02 1F       brclr    $a9, #2, $d40f ; $00A9=operating_mode_flags, $D40F=loc_D40F
D3F0:  14 96 01          bset     $96, #1
D3F3:  CE 00 12          ldx      #18
D3F6:  C6 03             ldab     #3

loc_D3F8:
D3F8:  A6 00             ldaa     0, x ; xrefs $D40D:branch
D3FA:  85 40             bita     #64
D3FC:  27 0B             beq      $d409 ; $D409=loc_D409
D3FE:  A6 01             ldaa     1, x
D400:  27 07             beq      $d409 ; $D409=loc_D409
D402:  81 FF             cmpa     #-1
D404:  27 03             beq      $d409 ; $D409=loc_D409
D406:  4A                deca     
D407:  A7 01             staa     1, x

loc_D409:
D409:  3A                abx       ; xrefs $D3FC:branch, $D400:branch, $D404:branch
D40A:  8C 00 4B          cpx      #75
D40D:  26 E9             bne      $d3f8 ; $D3F8=loc_D3F8

loc_D40F:
D40F:  BD 5A D6          jsr      $5ad6 ; $5AD6=incremental_rom_checksum | xrefs $D3E8:branch, $D3EC:branch
D412:  BD 60 2F          jsr      $602f ; $602F=runtime_stage_602f
D415:  BD 61 07          jsr      $6107 ; $6107=runtime_stage_6107
D418:  BD 61 33          jsr      $6133 ; $6133=runtime_stage_6133
D41B:  BD 61 5B          jsr      $615b ; $615B=runtime_stage_615b
D41E:  BD 61 87          jsr      $6187 ; $6187=runtime_stage_6187
D421:  BD 62 DC          jsr      $62dc ; $62DC=runtime_stage_62dc
D424:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
D427:  81 07             cmpa     #7
D429:  26 05             bne      $d430 ; $D430=loc_D430
D42B:  BD 68 36          jsr      $6836 ; $6836=mode_handler_6836
D42E:  20 29             bra      $d459 ; $D459=loc_D459

loc_D430:
D430:  81 FE             cmpa     #-2 ; xrefs $D429:branch
D432:  26 05             bne      $d439 ; $D439=loc_D439
D434:  BD 68 F3          jsr      $68f3 ; $68F3=mode_handler_68f3
D437:  20 20             bra      $d459 ; $D459=loc_D459

loc_D439:
D439:  81 08             cmpa     #8 ; xrefs $D432:branch
D43B:  26 03             bne      $d440 ; $D440=loc_D440
D43D:  7E 6B BE          jmp      $6bbe ; $6BBE=mode_handler_6bbe

loc_D440:
D440:  81 0A             cmpa     #10 ; xrefs $D43B:branch
D442:  26 05             bne      $d449 ; $D449=loc_D449
D444:  BD 6A 12          jsr      $6a12 ; $6A12=mode_handler_6a12
D447:  20 10             bra      $d459 ; $D459=loc_D459

loc_D449:
D449:  81 09             cmpa     #9 ; xrefs $D442:branch
D44B:  26 05             bne      $d452 ; $D452=loc_D452
D44D:  BD 6A 12          jsr      $6a12 ; $6A12=mode_handler_6a12
D450:  20 07             bra      $d459 ; $D459=loc_D459

loc_D452:
D452:  81 0D             cmpa     #13 ; xrefs $D44B:branch
D454:  26 03             bne      $d459 ; $D459=loc_D459
D456:  BD 6D 43          jsr      $6d43 ; $6D43=mode_handler_6d43

loc_D459:
D459:  12 AC 04 03       brset    $ac, #4, $d460 ; $D460=loc_D460 | xrefs $D42E:branch, $D437:branch, $D447:branch, $D450:branch, $D454:branch
D45D:  BD C0 00          jsr      $c000 ; $C000=closed_loop_adaptive_state_machine

loc_D460:
D460:  12 AC 08 03       brset    $ac, #8, $d467 ; $D467=loc_D467 | xrefs $D459:branch
D464:  7E D5 B3          jmp      $d5b3 ; $D5B3=loc_D5B3

loc_D467:
D467:  15 AC 08          bclr     $ac, #8 ; xrefs $D460:branch
D46A:  BD 5F 27          jsr      $5f27 ; $5F27=sub_5F27

; [CONFIRMED] Normalize RAM 0x00BA through axis 0x929E into RAM 0x2036.
build_rpm_axis_2036:
D46D:  CE 92 9E          ldx      #-28002
D470:  F6 92 CE          ldab     $92ce
D473:  5A                decb     
D474:  58                aslb     
D475:  3A                abx      
D476:  4F                clra     
D477:  54                lsrb     
D478:  18 8F             xgdy     
D47A:  DC BA             ldd      $ba ; $00BA=engine_period_delta
D47C:  BD B3 B9          jsr      $b3b9 ; $B3B9=period_axis_lookup
D47F:  FD 20 36          std      $2036 ; $2036=normalized_rpm_axis

; [CONFIRMED] Build 19-site RPM index used by ignition/adaptive support vectors.
build_rpm_index_2044:
D482:  DC D4             ldd      $d4
D484:  1A 83 1C 20       cpd      #7200
D488:  25 05             bcs      $d48f ; $D48F=loc_D48F
D48A:  CC 12 00          ldd      #4608
D48D:  20 09             bra      $d498 ; $D498=loc_D498

loc_D48F:
D48F:  CE 00 19          ldx      #25 ; xrefs $D488:branch
D492:  02                idiv     
D493:  8F                xgdx     
D494:  05                asld     
D495:  05                asld     
D496:  05                asld     
D497:  05                asld     

loc_D498:
D498:  FD 20 44          std      $2044 ; $2044=rpm_site_index_19 | xrefs $D48D:branch
D49B:  81 10             cmpa     #16
D49D:  25 05             bcs      $d4a4 ; $D4A4=loc_D4A4
D49F:  CC 04 00          ldd      #1024
D4A2:  20 02             bra      $d4a6 ; $D4A6=loc_D4A6

loc_D4A4:
D4A4:  04                lsrd      ; xrefs $D49D:branch
D4A5:  04                lsrd     

loc_D4A6:
D4A6:  FD 20 46          std      $2046 ; $2046=spark_transition_axis | xrefs $D4A2:branch
D4A9:  BD 9D 13          jsr      $9d13 ; $9D13=sub_9D13
D4AC:  CE 24 CB          ldx      #9419
D4AF:  FC 20 2E          ldd      $202e
D4B2:  ED 00             std      0, x
D4B4:  B6 89 8A          ldaa     $898a
D4B7:  12 A3 10 03       brset    $a3, #16, $d4be ; $D4BE=loc_D4BE
D4BB:  B6 89 8B          ldaa     $898b

loc_D4BE:
D4BE:  A7 02             staa     2, x ; xrefs $D4B7:branch
D4C0:  DC BA             ldd      $ba ; $00BA=engine_period_delta
D4C2:  BD B4 07          jsr      $b407 ; $B407=sub_B407
D4C5:  FD 20 2E          std      $202e
D4C8:  0F                sei      
D4C9:  DC BA             ldd      $ba ; $00BA=engine_period_delta
D4CB:  FE 24 DB          ldx      $24db
D4CE:  0E                cli      
D4CF:  FD 24 E1          std      $24e1
D4D2:  FF 24 E3          stx      $24e3
D4D5:  BD D7 03          jsr      $d703 ; $D703=sub_D703
D4D8:  F6 85 AD          ldab     $85ad
D4DB:  13 A3 24 03       brclr    $a3, #36, $d4e2 ; $D4E2=loc_D4E2
D4DF:  F6 85 94          ldab     $8594

loc_D4E2:
D4E2:  F7 24 D4          stab     $24d4 ; xrefs $D4DB:branch
D4E5:  BD D7 9B          jsr      $d79b ; $D79B=sub_D79B
D4E8:  FC 20 2E          ldd      $202e
D4EB:  1A 83 1C B8       cpd      #7352
D4EF:  23 0D             bls      $d4fe ; $D4FE=loc_D4FE
D4F1:  04                lsrd     
D4F2:  04                lsrd     
D4F3:  04                lsrd     
D4F4:  04                lsrd     
D4F5:  04                lsrd     
D4F6:  8F                xgdx     
D4F7:  CC E4 E2          ldd      #-6942
D4FA:  02                idiv     
D4FB:  8F                xgdx     
D4FC:  20 02             bra      $d500 ; $D500=loc_D500

loc_D4FE:
D4FE:  C6 FF             ldab     #-1 ; xrefs $D4EF:branch

loc_D500:
D500:  D7 D2             stab     $d2 ; xrefs $D4FC:branch
D502:  7C 20 2A          inc      $202a
D505:  BD 5B 95          jsr      $5b95 ; $5B95=sub_5B95
D508:  BD 5F 71          jsr      $5f71 ; $5F71=sub_5F71
D50B:  FE 21 94          ldx      $2194
D50E:  8C FF FF          cpx      #-1
D511:  27 04             beq      $d517 ; $D517=loc_D517
D513:  09                dex      
D514:  FF 21 94          stx      $2194

loc_D517:
D517:  BD 72 3E          jsr      $723e ; $723E=sub_723E | xrefs $D511:branch
D51A:  0F                sei      
D51B:  DE D4             ldx      $d4
D51D:  18 FE 21 2F       ldy      $212f
D521:  FC 21 2C          ldd      $212c
D524:  0E                cli      
D525:  FF 24 ED          stx      $24ed
D528:  18 FF 24 EF       sty      $24ef
D52C:  FD 24 F1          std      $24f1
D52F:  5F                clrb     
D530:  BC 93 13          cpx      $9313
D533:  24 3C             bcc      $d571 ; $D571=loc_D571
D535:  F7 24 CD          stab     $24cd
D538:  FC 24 EF          ldd      $24ef
D53B:  B3 24 ED          subd     $24ed
D53E:  24 07             bcc      $d547 ; $D547=loc_D547
D540:  40                nega     
D541:  50                negb     
D542:  82 00             sbca     #0
D544:  73 24 CD          com      $24cd

loc_D547:
D547:  1A 83 00 7F       cpd      #127 ; xrefs $D53E:branch
D54B:  23 02             bls      $d54f ; $D54F=loc_D54F
D54D:  C6 7F             ldab     #127

loc_D54F:
D54F:  B6 24 F1          ldaa     $24f1 ; xrefs $D54B:branch
D552:  3D                mul      
D553:  37                pshb     
D554:  F6 93 12          ldab     $9312
D557:  3D                mul      
D558:  8F                xgdx     
D559:  32                pula     
D55A:  F6 93 12          ldab     $9312
D55D:  3D                mul      
D55E:  89 00             adca     #0
D560:  16                tab      
D561:  3A                abx      
D562:  8F                xgdx     
D563:  1A 83 00 7F       cpd      #127
D567:  23 02             bls      $d56b ; $D56B=loc_D56B
D569:  C6 7F             ldab     #127

loc_D56B:
D56B:  7D 24 CD          tst      $24cd ; xrefs $D567:branch
D56E:  27 01             beq      $d571 ; $D571=loc_D571
D570:  50                negb     

loc_D571:
D571:  F7 24 E9          stab     $24e9 ; xrefs $D533:branch, $D56E:branch
D574:  CB 80             addb     #-128
D576:  F7 20 33          stab     $2033
D579:  13 A9 02 13       brclr    $a9, #2, $d590 ; $00A9=operating_mode_flags, $D590=loc_D590
D57D:  B6 24 EC          ldaa     $24ec
D580:  81 00             cmpa     #0
D582:  27 0C             beq      $d590 ; $D590=loc_D590
D584:  B6 86 6C          ldaa     $866c
D587:  C6 0A             ldab     #10
D589:  FD 21 81          std      $2181
D58C:  4F                clra     
D58D:  B7 24 EC          staa     $24ec

loc_D590:
D590:  BD 56 79          jsr      $5679 ; $5679=sub_5679 | xrefs $D579:branch, $D582:branch
D593:  BD 55 F8          jsr      $55f8 ; $55F8=sub_55F8
D596:  BD 44 61          jsr      $4461 ; $4461=sub_4461
D599:  BD C0 00          jsr      $c000 ; $C000=closed_loop_adaptive_state_machine
D59C:  13 AD 08 06       brclr    $ad, #8, $d5a6 ; $D5A6=loc_D5A6
D5A0:  15 AD 08          bclr     $ad, #8
D5A3:  BD 60 5B          jsr      $605b ; $605B=sub_605B

loc_D5A6:
D5A6:  13 AD 10 06       brclr    $ad, #16, $d5b0 ; $D5B0=loc_D5B0 | xrefs $D59C:branch
D5AA:  15 AD 10          bclr     $ad, #16
D5AD:  BD 60 B1          jsr      $60b1 ; $60B1=sub_60B1

loc_D5B0:
D5B0:  BD CB 9B          jsr      $cb9b ; $CB9B=sub_CB9B | xrefs $D5A6:branch

loc_D5B3:
D5B3:  BD A3 DE          jsr      $a3de ; $A3DE=sub_A3DE | xrefs $D464:jump
D5B6:  BD EB B4          jsr      $ebb4 ; $EBB4=sub_EBB4
D5B9:  BD 43 6A          jsr      $436a ; $436A=preprocess_iat_path
D5BC:  BD 43 1A          jsr      $431a ; $431A=preprocess_cts_path
D5BF:  BD 43 BA          jsr      $43ba ; $43BA=sub_43BA
D5C2:  BD 5A 29          jsr      $5a29 ; $5A29=sub_5A29
D5C5:  BD E7 DD          jsr      $e7dd ; $E7DD=sub_E7DD
D5C8:  BD D6 F5          jsr      $d6f5 ; $D6F5=sub_D6F5
D5CB:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
D5CE:  81 0C             cmpa     #12
D5D0:  26 0D             bne      $d5df ; $D5DF=loc_D5DF
D5D2:  CC 00 00          ldd      #0
D5D5:  DD BF             std      $bf ; $00BF=fuel_event_width_limit
D5D7:  FD 20 86          std      $2086 ; $2086=fuel_edge_deadline_term
D5DA:  BD 96 DA          jsr      $96da ; $96DA=sub_96DA
D5DD:  20 2E             bra      $d60d ; $D60D=loc_D60D

loc_D5DF:
D5DF:  FC 20 40          ldd      $2040 ; $2040=scheduler_axis_index | xrefs $D5D0:branch
D5E2:  18 CE 92 FA       ldy      #-27910
D5E6:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
D5E9:  C6 28             ldab     #40
D5EB:  3D                mul      
D5EC:  FD 23 88          std      $2388 ; $2388=scheduler_scaled_output
D5EF:  FC 20 40          ldd      $2040 ; $2040=scheduler_axis_index
D5F2:  18 CE 87 7E       ldy      #-30850
D5F6:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
D5F9:  5F                clrb     
D5FA:  04                lsrd     
D5FB:  04                lsrd     
D5FC:  04                lsrd     
D5FD:  04                lsrd     
D5FE:  DD BF             std      $bf ; $00BF=fuel_event_width_limit
D600:  CE 20 40          ldx      #8256
D603:  18 CE 87 89       ldy      #-30839
D607:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
D60A:  FD 20 86          std      $2086 ; $2086=fuel_edge_deadline_term

loc_D60D:
D60D:  BD BA 34          jsr      $ba34 ; $BA34=sub_BA34 | xrefs $D5DD:branch
D610:  BD 5F DC          jsr      $5fdc ; $5FDC=sub_5FDC
D613:  BD D1 05          jsr      $d105 ; $D105=sub_D105
D616:  BD 9D 51          jsr      $9d51 ; $9D51=sub_9D51
D619:  CE 87 9B          ldx      #-30821
D61C:  A6 00             ldaa     0, x
D61E:  26 1D             bne      $d63d ; $D63D=loc_D63D
D620:  CC 00 00          ldd      #0
D623:  FD 21 08          std      $2108
D626:  FD 21 06          std      $2106
D629:  FD 21 04          std      $2104
D62C:  FD 21 02          std      $2102
D62F:  FD 21 0A          std      $210a
D632:  FD 21 0C          std      $210c
D635:  B7 24 C9          staa     $24c9
D638:  B7 24 CA          staa     $24ca
D63B:  20 4E             bra      $d68b ; $D68B=loc_D68B

loc_D63D:
D63D:  1F 00 01 19       brclr    0, x; #1; $d65a ; $D65A=loc_D65A | xrefs $D61E:branch
D641:  7D 24 C9          tst      $24c9
D644:  26 45             bne      $d68b ; $D68B=loc_D68B
D646:  7C 24 C9          inc      $24c9
D649:  7F 24 CA          clr      $24ca
D64C:  CC 00 00          ldd      #0
D64F:  FD 21 0A          std      $210a
D652:  FC 10 0E          ldd      $100e ; $100E=TCNT
D655:  FD 24 C7          std      $24c7
D658:  20 31             bra      $d68b ; $D68B=loc_D68B

loc_D65A:
D65A:  1F 00 02 2D       brclr    0, x; #2; $d68b ; $D68B=loc_D68B | xrefs $D63D:branch
D65E:  7D 24 CA          tst      $24ca
D661:  26 28             bne      $d68b ; $D68B=loc_D68B
D663:  7C 24 CA          inc      $24ca
D666:  7F 24 C9          clr      $24c9
D669:  CE 00 00          ldx      #0
D66C:  FC 10 0E          ldd      $100e ; $100E=TCNT
D66F:  B3 24 C7          subd     $24c7
D672:  25 01             bcs      $d675 ; $D675=loc_D675
D674:  08                inx      

loc_D675:
D675:  F3 21 08          addd     $2108 ; xrefs $D672:branch
D678:  FD 21 08          std      $2108
D67B:  24 01             bcc      $d67e ; $D67E=loc_D67E
D67D:  08                inx      

loc_D67E:
D67E:  8F                xgdx      ; xrefs $D67B:branch
D67F:  F3 21 0A          addd     $210a
D682:  83 00 01          subd     #1
D685:  F3 21 06          addd     $2106
D688:  FD 21 06          std      $2106

loc_D68B:
D68B:  12 FC 01 05       brset    $fc, #1, $d694 ; $D694=loc_D694 | xrefs $D63B:branch, $D644:branch, $D658:branch, $D65A:branch, $D661:branch
D68F:  BD 64 51          jsr      $6451 ; $6451=sub_6451
D692:  20 12             bra      $d6a6 ; $D6A6=loc_D6A6

loc_D694:
D694:  13 FC 04 05       brclr    $fc, #4, $d69d ; $D69D=loc_D69D | xrefs $D68B:branch
D698:  BD 4E 0B          jsr      $4e0b ; $4E0B=sub_4E0B
D69B:  20 09             bra      $d6a6 ; $D6A6=loc_D6A6

loc_D69D:
D69D:  13 F1 FF 05       brclr    $f1, #-1, $d6a6 ; $D6A6=loc_D6A6 | xrefs $D694:branch
D6A1:  BD 4B CD          jsr      $4bcd ; $4BCD=sub_4BCD
D6A4:  20 00             bra      $d6a6 ; $D6A6=loc_D6A6

loc_D6A6:
D6A6:  BD 65 D8          jsr      $65d8 ; $65D8=sub_65D8 | xrefs $D692:branch, $D69B:branch, $D69D:branch, $D6A4:branch
D6A9:  7E D2 D9          jmp      $d2d9 ; $D2D9=main_runtime_loop

; [CONFIRMED] Initialize main runtime variables.
runtime_variables_init:
D6AC:  CC FF FF          ldd      #-1 ; xrefs $B8FB:call
D6AF:  FD 20 2E          std      $202e
D6B2:  CC 00 00          ldd      #0
D6B5:  FD 20 36          std      $2036 ; $2036=normalized_rpm_axis
D6B8:  FD 20 44          std      $2044 ; $2044=rpm_site_index_19
D6BB:  B7 20 30          staa     $2030
D6BE:  97 B3             staa     $b3
D6C0:  97 D1             staa     $d1
D6C2:  97 D4             staa     $d4
D6C4:  97 D3             staa     $d3
D6C6:  97 D2             staa     $d2
D6C8:  97 BE             staa     $be ; $00BE=fuel_event_phase
D6CA:  FD 24 D9          std      $24d9
D6CD:  CC 80 00          ldd      #-32768
D6D0:  FD 24 D7          std      $24d7
D6D3:  BD 43 6A          jsr      $436a ; $436A=preprocess_iat_path
D6D6:  BD 43 1A          jsr      $431a ; $431A=preprocess_cts_path
D6D9:  FC 87 89          ldd      $8789 ; $8789=fuel_edge_offset_1x9_words
D6DC:  FD 20 86          std      $2086 ; $2086=fuel_edge_deadline_term
D6DF:  BD 43 DC          jsr      $43dc ; $43DC=sub_43DC
D6E2:  5F                clrb     
D6E3:  DD CC             std      $cc
D6E5:  BD 43 F3          jsr      $43f3 ; $43F3=sub_43F3
D6E8:  BD D6 F5          jsr      $d6f5 ; $D6F5=sub_D6F5
D6EB:  CC 00 00          ldd      #0
D6EE:  FD 20 28          std      $2028
D6F1:  B7 20 2A          staa     $202a
D6F4:  39                rts      

sub_D6F5:
D6F5:  FC 20 40          ldd      $2040 ; $2040=scheduler_axis_index | xrefs $D5C8:call, $D6E8:call
D6F8:  18 CE 93 03       ldy      #-27901
D6FC:  BD B2 BA          jsr      $b2ba ; $B2BA=interp_1d_s8
D6FF:  B7 20 48          staa     $2048
D702:  39                rts      

sub_D703:
D703:  4F                clra      ; xrefs $D4D5:call
D704:  B7 24 D5          staa     $24d5
D707:  FC 24 E1          ldd      $24e1
D70A:  B3 24 E3          subd     $24e3
D70D:  24 0B             bcc      $d71a ; $D71A=loc_D71A
D70F:  86 FF             ldaa     #-1
D711:  B7 24 D5          staa     $24d5
D714:  FC 24 E3          ldd      $24e3
D717:  B3 24 E1          subd     $24e1

loc_D71A:
D71A:  36                psha      ; xrefs $D70D:branch
D71B:  86 AF             ldaa     #-81
D71D:  3D                mul      
D71E:  FD 24 CC          std      $24cc
D721:  32                pula     
D722:  C6 AF             ldab     #-81
D724:  3D                mul      
D725:  FB 24 CC          addb     $24cc
D728:  89 00             adca     #0
D72A:  FD 24 CB          std      $24cb
D72D:  FC 24 E1          ldd      $24e1
D730:  3D                mul      
D731:  89 00             adca     #0
D733:  16                tab      
D734:  4F                clra     
D735:  05                asld     
D736:  FD 24 CE          std      $24ce
D739:  B6 24 E1          ldaa     $24e1
D73C:  16                tab      
D73D:  3D                mul      
D73E:  F3 24 CE          addd     $24ce
D741:  FD 24 CE          std      $24ce
D744:  36                psha     
D745:  36                psha     
D746:  B6 24 E3          ldaa     $24e3
D749:  3D                mul      
D74A:  89 00             adca     #0
D74C:  16                tab      
D74D:  4F                clra     
D74E:  FD 24 D0          std      $24d0
D751:  32                pula     
D752:  F6 24 E4          ldab     $24e4
D755:  3D                mul      
D756:  89 00             adca     #0
D758:  16                tab      
D759:  4F                clra     
D75A:  F3 24 D0          addd     $24d0
D75D:  FD 24 D0          std      $24d0
D760:  32                pula     
D761:  F6 24 E3          ldab     $24e3
D764:  3D                mul      
D765:  F3 24 D0          addd     $24d0
D768:  FD 24 D0          std      $24d0
D76B:  8F                xgdx     
D76C:  FC 24 CC          ldd      $24cc
D76F:  7D 24 CB          tst      $24cb
D772:  27 0D             beq      $d781 ; $D781=loc_D781

loc_D774:
D774:  74 24 CB          lsr      $24cb ; xrefs $D77F:branch
D777:  46                rora     
D778:  56                rorb     
D779:  8F                xgdx     
D77A:  04                lsrd     
D77B:  8F                xgdx     
D77C:  7D 24 CB          tst      $24cb
D77F:  26 F3             bne      $d774 ; $D774=loc_D774

loc_D781:
D781:  02                idiv      ; xrefs $D772:branch
D782:  8F                xgdx     
D783:  FD 24 D2          std      $24d2
D786:  4D                tsta     
D787:  27 02             beq      $d78b ; $D78B=loc_D78B
D789:  C6 FF             ldab     #-1

loc_D78B:
D78B:  B6 24 D5          ldaa     $24d5 ; xrefs $D787:branch
D78E:  27 01             beq      $d791 ; $D791=loc_D791
D790:  53                comb     

loc_D791:
D791:  F7 24 D6          stab     $24d6 ; xrefs $D78E:branch
D794:  CB 80             addb     #-128
D796:  F7 20 31          stab     $2031
D799:  39                rts      

; ---- unreached/data gap $D79A-$D79A ----

        .org $D79B

sub_D79B:
D79B:  CE 24 CB          ldx      #9419 ; xrefs $D4E5:call
D79E:  FC 24 D7          ldd      $24d7
D7A1:  ED 00             std      0, x
D7A3:  B6 24 D4          ldaa     $24d4
D7A6:  A7 02             staa     2, x
D7A8:  FC 24 D5          ldd      $24d5
D7AB:  C3 80 00          addd     #-32768
D7AE:  BD B4 07          jsr      $b407 ; $B407=sub_B407
D7B1:  FD 24 D7          std      $24d7
D7B4:  37                pshb     
D7B5:  2A 08             bpl      $d7bf ; $D7BF=loc_D7BF
D7B7:  81 80             cmpa     #-128
D7B9:  23 02             bls      $d7bd ; $D7BD=loc_D7BD
D7BB:  C6 FF             ldab     #-1

loc_D7BD:
D7BD:  20 01             bra      $d7c0 ; $D7C0=loc_D7C0 | xrefs $D7B9:branch

loc_D7BF:
D7BF:  5F                clrb      ; xrefs $D7B5:branch

loc_D7C0:
D7C0:  F7 20 30          stab     $2030 ; xrefs $D7BD:branch
D7C3:  33                pulb     
D7C4:  C3 80 80          addd     #-32640
D7C7:  81 00             cmpa     #0
D7C9:  2E 05             bgt      $d7d0 ; $D7D0=loc_D7D0
D7CB:  27 05             beq      $d7d2 ; $D7D2=loc_D7D2
D7CD:  5F                clrb     
D7CE:  20 02             bra      $d7d2 ; $D7D2=loc_D7D2

loc_D7D0:
D7D0:  C6 FF             ldab     #-1 ; xrefs $D7C9:branch

loc_D7D2:
D7D2:  F7 20 32          stab     $2032 ; xrefs $D7CB:branch, $D7CE:branch
D7D5:  39                rts      

; ---- unreached/data gap $D7D6-$D80A ----

        .org $D80B

loc_D80B:
D80B:  0F                sei       ; xrefs $AAE9:jump
D80C:  8D 1B             bsr      $d829 ; $D829=sub_D829
D80E:  0E                cli      

loc_D80F:
D80F:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $D827:branch
D812:  81 06             cmpa     #6
D814:  27 03             beq      $d819 ; $D819=loc_D819
D816:  7E B9 4D          jmp      $b94d ; $B94D=fault_stop_bit08

loc_D819:
D819:  86 55             ldaa     #85 ; xrefs $D814:branch
D81B:  B7 10 3A          staa     $103a ; $103A=COPRST
D81E:  43                coma     
D81F:  B7 10 3A          staa     $103a ; $103A=COPRST
D822:  8D 72             bsr      $d896 ; $D896=sub_D896
D824:  BD D9 41          jsr      $d941 ; $D941=sub_D941
D827:  20 E6             bra      $d80f ; $D80F=loc_D80F

sub_D829:
D829:  7F 10 0C          clr      $100c ; xrefs $D80C:call
D82C:  7F 10 20          clr      $1020
D82F:  7F 10 22          clr      $1022
D832:  86 F0             ldaa     #-16
D834:  B7 10 25          staa     $1025 ; $1025=TFLG2
D837:  86 40             ldaa     #64
D839:  B7 10 24          staa     $1024 ; $1024=TMSK2_or_status
D83C:  86 10             ldaa     #16
D83E:  B7 10 00          staa     $1000 ; $1000=PORTA
D841:  7F 10 40          clr      $1040
D844:  7F 10 50          clr      $1050
D847:  86 FF             ldaa     #-1
D849:  B7 26 C6          staa     $26c6
D84C:  96 99             ldaa     $99 ; $0099=runtime_fault_flags
D84E:  84 08             anda     #8
D850:  B7 26 C0          staa     $26c0
D853:  96 8E             ldaa     $8e
D855:  D6 8F             ldab     $8f
D857:  DD 00             std      $00
D859:  CC 24 F3          ldd      #9459
D85C:  DD 0F             std      $0f
D85E:  DD 11             std      $11
D860:  CC 26 40          ldd      #9792
D863:  DD 15             std      $15
D865:  DD 13             std      $13
D867:  4F                clra     
D868:  97 28             staa     $28
D86A:  14 28 12          bset     $28, #18
D86D:  97 2A             staa     $2a
D86F:  BD BD EC          jsr      $bdec ; $BDEC=sub_BDEC
D872:  BD DA 5A          jsr      $da5a ; $DA5A=sub_DA5A
D875:  DD 17             std      $17
D877:  CC E1 6D          ldd      #-7827
D87A:  DD 1D             std      $1d
D87C:  86 80             ldaa     #-128
D87E:  97 30             staa     $30
D880:  CC 00 A0          ldd      #160
D883:  DD 05             std      $05
D885:  86 30             ldaa     #48
D887:  B7 10 2B          staa     $102b ; $102B=BAUD
D88A:  86 AC             ldaa     #-84
D88C:  B7 10 2D          staa     $102d ; $102D=SCCR2
D88F:  7F 10 2C          clr      $102c ; $102C=SCCR1
D892:  FC 10 2E          ldd      $102e ; $102E=SCSR
D895:  39                rts      

sub_D896:
D896:  12 28 11 02       brset    $28, #17, $d89c ; $D89C=loc_D89C | xrefs $D822:call
D89A:  20 50             bra      $d8ec ; $D8EC=loc_D8EC

loc_D89C:
D89C:  DE 0F             ldx      $0f ; xrefs $D896:branch
D89E:  18 CE 00 69       ldy      #105
D8A2:  A6 00             ldaa     0, x
D8A4:  81 04             cmpa     #4
D8A6:  27 2A             beq      $d8d2 ; $D8D2=loc_D8D2
D8A8:  C6 01             ldab     #1
D8AA:  D7 2E             stab     $2e
D8AC:  18 A7 00          staa     0, y
D8AF:  C6 26             ldab     #38
D8B1:  08                inx      
D8B2:  15 28 10          bclr     $28, #16

loc_D8B5:
D8B5:  A6 00             ldaa     0, x ; xrefs $D8C5:branch
D8B7:  81 20             cmpa     #32
D8B9:  25 2F             bcs      $d8ea ; $D8EA=loc_D8EA
D8BB:  7C 00 2E          inc      >$002e
D8BE:  18 08             iny      
D8C0:  18 A7 00          staa     0, y
D8C3:  08                inx      
D8C4:  5A                decb     
D8C5:  26 EE             bne      $d8b5 ; $D8B5=loc_D8B5
D8C7:  D7 2E             stab     $2e

loc_D8C9:
D8C9:  A6 00             ldaa     0, x ; xrefs $D8D0:branch
D8CB:  81 20             cmpa     #32
D8CD:  25 1B             bcs      $d8ea ; $D8EA=loc_D8EA
D8CF:  08                inx      
D8D0:  20 F7             bra      $d8c9 ; $D8C9=loc_D8C9

loc_D8D2:
D8D2:  12 28 80 04       brset    $28, #-128, $d8da ; $D8DA=loc_D8DA | xrefs $D8A6:branch
D8D6:  12 28 08 12       brset    $28, #8, $d8ec ; $D8EC=loc_D8EC

loc_D8DA:
D8DA:  12 28 20 0E       brset    $28, #32, $d8ec ; $D8EC=loc_D8EC | xrefs $D8D2:branch
D8DE:  7F 00 2F          clr      >$002f
D8E1:  14 28 60          bset     $28, #96
D8E4:  15 28 01          bclr     $28, #1
D8E7:  CE 24 F3          ldx      #9459

loc_D8EA:
D8EA:  DF 0F             stx      $0f ; xrefs $D8B9:branch, $D8CD:branch

loc_D8EC:
D8EC:  DE 17             ldx      $17 ; xrefs $D89A:branch, $D8D6:branch, $D8DA:branch
D8EE:  AD 00             jsr      0, x
D8F0:  13 28 18 02       brclr    $28, #24, $d8f6 ; $D8F6=loc_D8F6
D8F4:  20 12             bra      $d908 ; $D908=loc_D908

loc_D8F6:
D8F6:  96 2E             ldaa     $2e ; xrefs $D8F0:branch
D8F8:  26 04             bne      $d8fe ; $D8FE=loc_D8FE
D8FA:  8D 10             bsr      $d90c ; $D90C=sub_D90C
D8FC:  20 0A             bra      $d908 ; $D908=loc_D908

loc_D8FE:
D8FE:  96 69             ldaa     $69 ; xrefs $D8F8:branch
D900:  8D 26             bsr      $d928 ; $D928=sub_D928
D902:  18 DF 19          sty      $19
D905:  14 28 08          bset     $28, #8

loc_D908:
D908:  DE 19             ldx      $19 ; xrefs $D8F4:branch, $D8FC:branch
D90A:  6E 00             jmp      0, x

sub_D90C:
D90C:  12 28 20 17       brset    $28, #32, $d927 ; $D927=loc_D927 | xrefs $D8FA:call
D910:  96 69             ldaa     $69
D912:  C6 18             ldab     #24
D914:  DD A9             std      $a9 ; $00A9=operating_mode_flags
D916:  86 02             ldaa     #2
D918:  97 2F             staa     $2f
D91A:  14 28 30          bset     $28, #48
D91D:  12 28 80 03       brset    $28, #-128, $d924 ; $D924=loc_D924
D921:  7E DA 54          jmp      $da54 ; $DA54=loc_DA54

loc_D924:
D924:  7E DA 5A          jmp      $da5a ; $DA5A=sub_DA5A | xrefs $D91D:branch

loc_D927:
D927:  39                rts       ; xrefs $D90C:branch

sub_D928:
D928:  CE D7 D7          ldx      #-10281 ; xrefs $D900:call
D92B:  18 CE D9 DE       ldy      #-9762
D92F:  20 07             bra      $d938 ; $D938=loc_D938

loc_D931:
D931:  0D                sec       ; xrefs $D93E:branch
D932:  1F 00 FF 0A       brclr    0, x; #-1; $d940 ; $D940=loc_D940
D936:  08                inx      
D937:  08                inx      

loc_D938:
D938:  E6 01             ldab     1, x ; xrefs $D92F:branch
D93A:  18 3A             aby      
D93C:  A1 00             cmpa     0, x
D93E:  26 F1             bne      $d931 ; $D931=loc_D931

loc_D940:
D940:  39                rts       ; xrefs $D932:branch, $D941:branch, $D945:branch

sub_D941:
D941:  12 28 04 FB       brset    $28, #4, $d940 ; $D940=loc_D940 | xrefs $D824:call
D945:  13 28 20 F7       brclr    $28, #32, $d940 ; $D940=loc_D940
D949:  18 CE 00 A9       ldy      #169
D94D:  DE 13             ldx      $13
D94F:  D6 2F             ldab     $2f

loc_D951:
D951:  27 0F             beq      $d962 ; $D962=loc_D962 | xrefs $D960:branch
D953:  18 A6 00          ldaa     0, y
D956:  A7 00             staa     0, x
D958:  98 30             eora     $30
D95A:  97 30             staa     $30
D95C:  08                inx      
D95D:  18 08             iny      
D95F:  5A                decb     
D960:  20 EF             bra      $d951 ; $D951=loc_D951

loc_D962:
D962:  13 28 40 11       brclr    $28, #64, $d977 ; $D977=loc_D977 | xrefs $D951:branch
D966:  86 04             ldaa     #4
D968:  A7 00             staa     0, x
D96A:  98 30             eora     $30
D96C:  A7 01             staa     1, x
D96E:  08                inx      
D96F:  08                inx      
D970:  86 80             ldaa     #-128
D972:  97 30             staa     $30
D974:  14 28 04          bset     $28, #4

loc_D977:
D977:  15 28 60          bclr     $28, #96 ; xrefs $D962:branch
D97A:  DF 13             stx      $13
D97C:  CE 10 00          ldx      #4096
D97F:  1C 2D 80          bset     45, x; #-128
D982:  39                rts      

loc_D983:
D983:  DE 15             ldx      $15 ; xrefs $A812:jump
D985:  9C 13             cpx      $13
D987:  27 09             beq      $d992 ; $D992=loc_D992
D989:  A6 00             ldaa     0, x
D98B:  B7 10 2F          staa     $102f ; $102F=SCDR
D98E:  08                inx      
D98F:  DF 15             stx      $15
D991:  3B                rti      

loc_D992:
D992:  13 28 04 03       brclr    $28, #4, $d999 ; $D999=loc_D999 | xrefs $D987:branch
D996:  15 28 02          bclr     $28, #2

loc_D999:
D999:  CE 10 00          ldx      #4096 ; xrefs $D992:branch
D99C:  1D 2D 80          bclr     45, x; #-128
D99F:  3B                rti      

; ---- unreached/data gap $D9A0-$DA53 ----

        .org $DA54

loc_DA54:
DA54:  15 28 88          bclr     $28, #-120 ; xrefs $D921:jump
DA57:  14 28 20          bset     $28, #32

sub_DA5A:
DA5A:  CC D8 95          ldd      #-10091 ; xrefs $D872:call, $D924:jump
DA5D:  DD 19             std      $19
DA5F:  39                rts      

; ---- unreached/data gap $DA60-$DCD8 ----

        .org $DCD9

sub_DCD9:
DCD9:  CE 10 00          ldx      #4096 ; xrefs $E0A8:call
DCDC:  1D 22 02          bclr     34, x; #2
DCDF:  1D 24 80          bclr     36, x; #-128
DCE2:  8D 45             bsr      $dd29 ; $DD29=sub_DD29
DCE4:  39                rts      

; ---- unreached/data gap $DCE5-$DD28 ----

        .org $DD29

sub_DD29:
DD29:  1D 00 40          bclr     0, x; #64 ; xrefs $DCE2:call
DD2C:  39                rts      

sub_DD2D:
DD2D:  3C                pshx      ; xrefs $E096:call
DD2E:  CE 10 00          ldx      #4096
DD31:  1D 50 20          bclr     80, x; #32
DD34:  38                pulx     
DD35:  20 08             bra      $dd3f ; $DD3F=loc_DD3F

sub_DD37:
DD37:  3C                pshx      ; xrefs $E09F:call, $E0AF:call
DD38:  CE 10 00          ldx      #4096
DD3B:  1C 50 20          bset     80, x; #32
DD3E:  38                pulx     

loc_DD3F:
DD3F:  39                rts       ; xrefs $DD35:branch

; ---- unreached/data gap $DD40-$E077 ----

        .org $E078

sub_E078:
E078:  96 26             ldaa     $26 ; xrefs $EB43:call
E07A:  4C                inca     
E07B:  27 02             beq      $e07f ; $E07F=loc_E07F
E07D:  97 26             staa     $26

loc_E07F:
E07F:  39                rts       ; xrefs $E07B:branch

loc_E080:
E080:  FE 10 12          ldx      $1012 ; xrefs $9346:jump
E083:  96 2A             ldaa     $2a
E085:  81 2B             cmpa     #43
E087:  27 2E             beq      $e0b7 ; $E0B7=loc_E0B7
E089:  7C 00 26          inc      >$0026
E08C:  96 26             ldaa     $26
E08E:  81 08             cmpa     #8
E090:  23 1B             bls      $e0ad ; $E0AD=loc_E0AD
E092:  81 0A             cmpa     #10
E094:  26 05             bne      $e09b ; $E09B=loc_E09B
E096:  BD DD 2D          jsr      $dd2d ; $DD2D=sub_DD2D
E099:  20 1A             bra      $e0b5 ; $E0B5=loc_E0B5

loc_E09B:
E09B:  81 0B             cmpa     #11 ; xrefs $E094:branch
E09D:  26 05             bne      $e0a4 ; $E0A4=loc_E0A4
E09F:  BD DD 37          jsr      $dd37 ; $DD37=sub_DD37
E0A2:  20 11             bra      $e0b5 ; $E0B5=loc_E0B5

loc_E0A4:
E0A4:  81 0D             cmpa     #13 ; xrefs $E09D:branch
E0A6:  26 0D             bne      $e0b5 ; $E0B5=loc_E0B5
E0A8:  BD DC D9          jsr      $dcd9 ; $DCD9=sub_DCD9
E0AB:  20 08             bra      $e0b5 ; $E0B5=loc_E0B5

loc_E0AD:
E0AD:  26 03             bne      $e0b2 ; $E0B2=loc_E0B2 | xrefs $E090:branch
E0AF:  BD DD 37          jsr      $dd37 ; $DD37=sub_DD37

loc_E0B2:
E0B2:  8F                xgdx      ; xrefs $E0AD:branch
E0B3:  8D 17             bsr      $e0cc ; $E0CC=sub_E0CC

loc_E0B5:
E0B5:  20 14             bra      $e0cb ; $E0CB=loc_E0CB | xrefs $E099:branch, $E0A2:branch, $E0A6:branch, $E0AB:branch

loc_E0B7:
E0B7:  8F                xgdx      ; xrefs $E087:branch
E0B8:  93 1F             subd     $1f
E0BA:  BD 94 E2          jsr      $94e2 ; $94E2=sub_94E2
E0BD:  D3 1F             addd     $1f
E0BF:  FD 10 18          std      $1018
E0C2:  CE 10 00          ldx      #4096
E0C5:  1D 20 40          bclr     32, x; #64
E0C8:  1D 22 02          bclr     34, x; #2

loc_E0CB:
E0CB:  3B                rti       ; xrefs $E0B5:branch

sub_E0CC:
E0CC:  DE 1B             ldx      $1b ; xrefs $E0B3:call, $E102:call
E0CE:  ED 01             std      1, x
E0D0:  D6 27             ldab     $27
E0D2:  48                asla     
E0D3:  25 0A             bcs      $e0df ; $E0DF=loc_E0DF
E0D5:  18 CE 10 00       ldy      #4096
E0D9:  18 1F 25 80 01    brclr    37, y; #-128; $e0df ; $E0DF=loc_E0DF
E0DE:  5C                incb     

loc_E0DF:
E0DF:  E7 00             stab     0, x ; xrefs $E0D3:branch, $E0D9:branch
E0E1:  C6 03             ldab     #3
E0E3:  3A                abx      
E0E4:  DF 1B             stx      $1b
E0E6:  39                rts      
E0E7:  86 01             ldaa     #1
E0E9:  B7 10 23          staa     $1023 ; $1023=TFLG1
E0EC:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
E0EF:  81 06             cmpa     #6
E0F1:  27 03             beq      $e0f6 ; $E0F6=loc_E0F6
E0F3:  7E B9 4D          jmp      $b94d ; $B94D=fault_stop_bit08

loc_E0F6:
E0F6:  96 26             ldaa     $26 ; xrefs $E0F1:branch
E0F8:  81 02             cmpa     #2
E0FA:  22 08             bhi      $e104 ; $E104=loc_E104
E0FC:  7C 00 26          inc      >$0026
E0FF:  FC 10 14          ldd      $1014 ; $1014=TIC3
E102:  8D C8             bsr      $e0cc ; $E0CC=sub_E0CC

loc_E104:
E104:  3B                rti       ; xrefs $E0FA:branch

loc_E105:
E105:  CE 10 00          ldx      #4096 ; xrefs $BC98:jump
E108:  B6 26 C6          ldaa     $26c6
E10B:  26 19             bne      $e126 ; $E126=loc_E126
E10D:  86 00             ldaa     #0
E10F:  B7 10 30          staa     $1030 ; $1030=ADCTL

loc_E112:
E112:  1F 30 80 FC       brclr    48, x; #-128; $e112 ; $E112=loc_E112 | xrefs $E112:branch
E116:  B6 10 31          ldaa     $1031 ; $1031=ADR1
E119:  B7 20 EA          staa     $20ea
E11C:  1C 00 10          bset     0, x; #16
E11F:  86 FF             ldaa     #-1
E121:  B7 26 C6          staa     $26c6
E124:  20 04             bra      $e12a ; $E12A=loc_E12A

loc_E126:
E126:  A6 31             ldaa     49, x ; xrefs $E10B:branch
E128:  97 36             staa     $36

loc_E12A:
E12A:  1D 22 10          bclr     34, x; #16 ; xrefs $E124:branch
E12D:  3B                rti      

loc_E12E:
E12E:  7C 00 27          inc      >$0027 ; xrefs $7300:jump
E131:  3B                rti      

sub_E132:
E132:  13 28 80 06       brclr    $28, #-128, $e13c ; $E13C=loc_E13C | xrefs $640C:call
E136:  96 2A             ldaa     $2a
E138:  81 28             cmpa     #40
E13A:  27 0A             beq      $e146 ; $E146=loc_E146

loc_E13C:
E13C:  B6 10 50          ldaa     $1050 ; xrefs $E132:branch
E13F:  84 EF             anda     #-17
E141:  B7 10 50          staa     $1050
E144:  20 1D             bra      $e163 ; $E163=loc_E163

loc_E146:
E146:  96 26             ldaa     $26 ; xrefs $E13A:branch
E148:  26 19             bne      $e163 ; $E163=loc_E163
E14A:  4C                inca     
E14B:  97 26             staa     $26
E14D:  CE 10 00          ldx      #4096
E150:  EC 0E             ldd      14, x
E152:  83 00 0F          subd     #15
E155:  2B 07             bmi      $e15e ; $E15E=loc_E15E
E157:  1F 25 80 03       brclr    37, x; #-128; $e15e ; $E15E=loc_E15E
E15B:  7C 00 27          inc      >$0027

loc_E15E:
E15E:  DD 35             std      $35 ; xrefs $E155:branch, $E157:branch
E160:  1D 24 80          bclr     36, x; #-128

loc_E163:
E163:  39                rts       ; xrefs $E144:branch, $E148:branch

loc_E164:
E164:  EC 2E             ldd      46, x ; xrefs $A9F2:jump, $AE81:jump
E166:  DE 1D             ldx      $1d
E168:  84 0E             anda     #14
E16A:  AD 00             jsr      0, x
E16C:  3B                rti      

; ---- unreached/data gap $E16D-$E226 ----

        .org $E227

sub_E227:
E227:  15 99 02          bclr     $99, #2 ; $0099=runtime_fault_flags | xrefs $B86A:call
E22A:  B6 91 6F          ldaa     $916f
E22D:  27 03             beq      $e232 ; $E232=loc_E232
E22F:  14 99 02          bset     $99, #2 ; $0099=runtime_fault_flags

loc_E232:
E232:  15 FC 01          bclr     $fc, #1 ; xrefs $E22D:branch
E235:  CC B6 00          ldd      #-18944
E238:  FD 25 73          std      $2573
E23B:  CC 25 7A          ldd      #9594
E23E:  FD 25 75          std      $2575
E241:  CC FF FF          ldd      #-1
E244:  FD 25 7A          std      $257a
E247:  B7 25 7C          staa     $257c
E24A:  86 01             ldaa     #1
E24C:  B7 25 77          staa     $2577
E24F:  B7 25 78          staa     $2578
E252:  86 04             ldaa     #4
E254:  B7 25 79          staa     $2579
E257:  86 F0             ldaa     #-16
E259:  B7 25 7D          staa     $257d

loc_E25C:
E25C:  FC 25 73          ldd      $2573 ; xrefs $E287:branch
E25F:  1A 83 B7 00       cpd      #-18688
E263:  22 53             bhi      $e2b8 ; $E2B8=loc_E2B8

loc_E265:
E265:  F6 25 77          ldab     $2577 ; xrefs $E2B6:branch
E268:  F1 25 79          cmpb     $2579
E26B:  23 1C             bls      $e289 ; $E289=loc_E289
E26D:  FC 25 75          ldd      $2575
E270:  C3 00 01          addd     #1
E273:  FD 25 75          std      $2575
E276:  FC 25 73          ldd      $2573
E279:  C3 00 80          addd     #128
E27C:  FD 25 73          std      $2573
E27F:  86 01             ldaa     #1
E281:  B7 25 77          staa     $2577
E284:  B7 25 78          staa     $2578
E287:  20 D3             bra      $e25c ; $E25C=loc_E25C

loc_E289:
E289:  BD E3 3F          jsr      $e33f ; $E33F=sub_E33F | xrefs $E26B:branch
E28C:  4D                tsta     
E28D:  26 0C             bne      $e29b ; $E29B=loc_E29B
E28F:  FE 25 75          ldx      $2575
E292:  A6 00             ldaa     0, x
E294:  B8 25 78          eora     $2578
E297:  A7 00             staa     0, x
E299:  20 15             bra      $e2b0 ; $E2B0=loc_E2B0

loc_E29B:
E29B:  B6 25 7D          ldaa     $257d ; xrefs $E28D:branch
E29E:  B4 25 78          anda     $2578
E2A1:  4D                tsta     
E2A2:  26 0C             bne      $e2b0 ; $E2B0=loc_E2B0
E2A4:  BD E3 65          jsr      $e365 ; $E365=sub_E365
E2A7:  B6 25 7D          ldaa     $257d
E2AA:  BA 25 78          oraa     $2578
E2AD:  B7 25 7D          staa     $257d

loc_E2B0:
E2B0:  7C 25 77          inc      $2577 ; xrefs $E299:branch, $E2A2:branch
E2B3:  BD E3 2F          jsr      $e32f ; $E32F=sub_E32F
E2B6:  20 AD             bra      $e265 ; $E265=loc_E265

loc_E2B8:
E2B8:  7F 25 7E          clr      $257e ; xrefs $E263:branch
E2BB:  B6 25 7D          ldaa     $257d
E2BE:  81 FF             cmpa     #-1
E2C0:  26 05             bne      $e2c7 ; $E2C7=loc_E2C7
E2C2:  15 99 02          bclr     $99, #2 ; $0099=runtime_fault_flags
E2C5:  20 3C             bra      $e303 ; $E303=loc_E303

loc_E2C7:
E2C7:  84 01             anda     #1 ; xrefs $E2C0:branch
E2C9:  26 03             bne      $e2ce ; $E2CE=loc_E2CE
E2CB:  7A 25 7E          dec      $257e

loc_E2CE:
E2CE:  C6 01             ldab     #1 ; xrefs $E2C9:branch
E2D0:  F7 25 78          stab     $2578
E2D3:  F7 25 77          stab     $2577

loc_E2D6:
E2D6:  B6 25 7D          ldaa     $257d ; xrefs $E301:branch
E2D9:  81 FF             cmpa     #-1
E2DB:  27 26             beq      $e303 ; $E303=loc_E303
E2DD:  B5 25 78          bita     $2578
E2E0:  26 12             bne      $e2f4 ; $E2F4=loc_E2F4
E2E2:  CC 55 B8          ldd      #21944
E2E5:  FD 25 73          std      $2573
E2E8:  BD E3 65          jsr      $e365 ; $E365=sub_E365
E2EB:  B6 25 7D          ldaa     $257d
E2EE:  BA 25 78          oraa     $2578
E2F1:  B7 25 7D          staa     $257d

loc_E2F4:
E2F4:  F6 25 78          ldab     $2578 ; xrefs $E2E0:branch
E2F7:  C1 80             cmpb     #-128
E2F9:  27 08             beq      $e303 ; $E303=loc_E303
E2FB:  7C 25 77          inc      $2577
E2FE:  BD E3 2F          jsr      $e32f ; $E32F=sub_E32F
E301:  20 D3             bra      $e2d6 ; $E2D6=loc_E2D6

loc_E303:
E303:  CC B6 00          ldd      #-18944 ; xrefs $E2C5:branch, $E2DB:branch, $E2F9:branch
E306:  FD 25 73          std      $2573
E309:  86 01             ldaa     #1
E30B:  7D 25 7E          tst      $257e
E30E:  27 01             beq      $e311 ; $E311=loc_E311
E310:  4C                inca     

loc_E311:
E311:  B7 25 77          staa     $2577 ; xrefs $E30E:branch
E314:  B7 25 78          staa     $2578
E317:  CC 25 7A          ldd      #9594
E31A:  FD 25 75          std      $2575
E31D:  15 FC 02          bclr     $fc, #2
E320:  86 04             ldaa     #4
E322:  B7 21 A3          staa     $21a3
E325:  39                rts      

sub_E326:
E326:  F6 25 77          ldab     $2577 ; xrefs $645C:call, $E342:call, $E36C:call
E329:  5A                decb     
E32A:  58                aslb     
E32B:  58                aslb     
E32C:  58                aslb     
E32D:  58                aslb     
E32E:  39                rts      

sub_E32F:
E32F:  F6 25 77          ldab     $2577 ; xrefs $6509:call, $E2B3:call, $E2FE:call
E332:  86 01             ldaa     #1

loc_E334:
E334:  5A                decb      ; xrefs $E339:branch
E335:  5D                tstb     
E336:  27 03             beq      $e33b ; $E33B=loc_E33B
E338:  48                asla     
E339:  20 F9             bra      $e334 ; $E334=loc_E334

loc_E33B:
E33B:  B7 25 78          staa     $2578 ; xrefs $E336:branch
E33E:  39                rts      

sub_E33F:
E33F:  FE 25 73          ldx      $2573 ; xrefs $E289:call
E342:  BD E3 26          jsr      $e326 ; $E326=sub_E326
E345:  3A                abx      
E346:  FF 25 80          stx      $2580
E349:  FC 25 80          ldd      $2580
E34C:  C3 00 0E          addd     #14
E34F:  FD 25 80          std      $2580
E352:  4F                clra     
E353:  5F                clrb     

loc_E354:
E354:  E3 00             addd     0, x ; xrefs $E35B:branch
E356:  08                inx      
E357:  08                inx      
E358:  BC 25 80          cpx      $2580
E35B:  23 F7             bls      $e354 ; $E354=loc_E354
E35D:  1A 83 55 AA       cpd      #21930
E361:  27 01             beq      $e364 ; $E364=loc_E364
E363:  4F                clra     

loc_E364:
E364:  39                rts       ; xrefs $E361:branch

sub_E365:
E365:  FE 25 73          ldx      $2573 ; xrefs $E2A4:call, $E2E8:call
E368:  18 CE 26 00       ldy      #9728
E36C:  BD E3 26          jsr      $e326 ; $E326=sub_E326
E36F:  3A                abx      
E370:  18 3A             aby      
E372:  86 08             ldaa     #8
E374:  B7 25 7F          staa     $257f

loc_E377:
E377:  EC 00             ldd      0, x ; xrefs $E388:branch
E379:  18 ED 00          std      0, y
E37C:  08                inx      
E37D:  08                inx      
E37E:  18 08             iny      
E380:  18 08             iny      
E382:  7A 25 7F          dec      $257f
E385:  7D 25 7F          tst      $257f
E388:  26 ED             bne      $e377 ; $E377=loc_E377
E38A:  39                rts      

; [CONFIRMED] Select 1D/2D and A/B signed fuel trim banks, interpolate, store raw correction in 0x2084.
fuel_signed_trim_lookup:
E38B:  13 A9 20 0C       brclr    $a9, #32, $e39b ; $00A9=operating_mode_flags, $E39B=loc_E39B | begin signed fuel-trim bank selection | xrefs $B45A:call, $B465:call
E38F:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
E392:  18 CE 83 F0       ldy      #-31760
E396:  BD B2 BA          jsr      $b2ba ; $B2BA=interp_1d_s8
E399:  20 46             bra      $e3e1 ; $E3E1=loc_E3E1

loc_E39B:
E39B:  CE 82 1C          ldx      #-32228 ; xrefs $E38B:branch
E39E:  7D 20 B1          tst      $20b1 ; $20B1=spark_fuel_bank_selector
E3A1:  26 03             bne      $e3a6 ; $E3A6=loc_E3A6
E3A3:  CE 83 18          ldx      #-31976

loc_E3A6:
E3A6:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis | xrefs $E3A1:branch
E3A9:  1A 83 03 00       cpd      #768
E3AD:  22 19             bhi      $e3c8 ; $E3C8=loc_E3C8
E3AF:  13 A9 40 15       brclr    $a9, #64, $e3c8 ; $00A9=operating_mode_flags, $E3C8=loc_E3C8
E3B3:  7D 00 90          tst      >$0090
E3B6:  27 10             beq      $e3c8 ; $E3C8=loc_E3C8
E3B8:  7D 20 2D          tst      $202d
E3BB:  26 0B             bne      $e3c8 ; $E3C8=loc_E3C8
E3BD:  CE 81 F8          ldx      #-32264
E3C0:  7D 20 B1          tst      $20b1 ; $20B1=spark_fuel_bank_selector
E3C3:  26 03             bne      $e3c8 ; $E3C8=loc_E3C8
E3C5:  CE 82 F4          ldx      #-32012

loc_E3C8:
E3C8:  18 CE 25 9A       ldy      #9626 ; xrefs $E3AD:branch, $E3AF:branch, $E3B6:branch, $E3BB:branch, $E3C3:branch
E3CC:  18 ED 02          std      2, y
E3CF:  FC 20 34          ldd      $2034 ; $2034=normalized_load_axis
E3D2:  18 ED 00          std      0, y
E3D5:  CD EF 04          stx      4, y
E3D8:  B6 92 90          ldaa     $9290
E3DB:  18 A7 06          staa     6, y
E3DE:  BD B3 2B          jsr      $b32b ; $B32B=interp_2d_s8

loc_E3E1:
E3E1:  B7 20 84          staa     $2084 ; $2084=signed_fuel_trim_raw | xrefs $E399:branch
E3E4:  FC 20 65          ldd      $2065
E3E7:  FD 25 8E          std      $258e
E3EA:  12 A3 01 0F       brset    $a3, #1, $e3fd ; $E3FD=loc_E3FD
E3EE:  CC 00 00          ldd      #0
E3F1:  FD 20 65          std      $2065
E3F4:  FD 25 90          std      $2590
E3F7:  FD 25 8B          std      $258b
E3FA:  7E E4 DE          jmp      $e4de ; $E4DE=loc_E4DE

loc_E3FD:
E3FD:  FC 20 42          ldd      $2042 ; $2042=transient_helper_axis | xrefs $E3EA:branch
E400:  18 CE 85 08       ldy      #-31480
E404:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E407:  B7 20 6D          staa     $206d
E40A:  12 AB 80 1B       brset    $ab, #-128, $e429 ; $E429=loc_E429
E40E:  CE 00 00          ldx      #0
E411:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
E413:  B3 20 67          subd     $2067
E416:  25 09             bcs      $e421 ; $E421=loc_E421
E418:  8F                xgdx     
E419:  8C 00 FF          cpx      #255
E41C:  23 03             bls      $e421 ; $E421=loc_E421
E41E:  CE 00 FF          ldx      #255

loc_E421:
E421:  8F                xgdx      ; xrefs $E416:branch, $E41C:branch
E422:  04                lsrd     
E423:  B6 85 44          ldaa     $8544
E426:  3D                mul      
E427:  20 3D             bra      $e466 ; $E466=loc_E466

loc_E429:
E429:  B6 20 64          ldaa     $2064 ; xrefs $E40A:branch
E42C:  B1 86 6F          cmpa     $866f
E42F:  26 13             bne      $e444 ; $E444=loc_E444
E431:  CE 25 92          ldx      #9618
E434:  18 CE 85 29       ldy      #-31447
E438:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E43B:  FD 20 6E          std      $206e
E43E:  FC 25 8B          ldd      $258b
E441:  FD 25 98          std      $2598

loc_E444:
E444:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis | xrefs $E42F:branch
E447:  18 CE 85 11       ldy      #-31471
E44B:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E44E:  B7 20 6C          staa     $206c
E451:  CE 20 42          ldx      #8258
E454:  18 CE 85 29       ldy      #-31447
E458:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E45B:  FD 20 70          std      $2070
E45E:  B3 20 6E          subd     $206e
E461:  24 03             bcc      $e466 ; $E466=loc_E466
E463:  CC 00 00          ldd      #0

loc_E466:
E466:  DD FD             std      $fd ; xrefs $E427:branch, $E461:branch
E468:  C6 11             ldab     #17
E46A:  B6 20 6B          ldaa     $206b
E46D:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E470:  FD 20 72          std      $2072
E473:  1A B3 25 98       cpd      $2598
E477:  22 05             bhi      $e47e ; $E47E=loc_E47E
E479:  FC 25 98          ldd      $2598
E47C:  20 06             bra      $e484 ; $E484=loc_E484

loc_E47E:
E47E:  CE 00 00          ldx      #0 ; xrefs $E477:branch
E481:  FF 25 98          stx      $2598

loc_E484:
E484:  FD 25 8B          std      $258b ; xrefs $E47C:branch
E487:  B3 20 74          subd     $2074
E48A:  24 03             bcc      $e48f ; $E48F=loc_E48F
E48C:  CC 00 00          ldd      #0

loc_E48F:
E48F:  04                lsrd      ; xrefs $E48A:branch
E490:  DD FD             std      $fd
E492:  C6 09             ldab     #9
E494:  B6 20 6D          ldaa     $206d
E497:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E49A:  FD 20 69          std      $2069
E49D:  B6 20 6C          ldaa     $206c
E4A0:  C6 05             ldab     #5
E4A2:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E4A5:  04                lsrd     
E4A6:  04                lsrd     
E4A7:  04                lsrd     
E4A8:  04                lsrd     
E4A9:  1A B3 25 88       cpd      $2588
E4AD:  25 03             bcs      $e4b2 ; $E4B2=loc_E4B2
E4AF:  FC 25 88          ldd      $2588

loc_E4B2:
E4B2:  FD 20 65          std      $2065 ; xrefs $E4AD:branch
E4B5:  F3 20 74          addd     $2074
E4B8:  25 13             bcs      $e4cd ; $E4CD=loc_E4CD
E4BA:  FD 20 74          std      $2074
E4BD:  FC 25 8E          ldd      $258e
E4C0:  26 11             bne      $e4d3 ; $E4D3=loc_E4D3
E4C2:  FC 20 65          ldd      $2065
E4C5:  FD 25 8E          std      $258e
E4C8:  F3 20 74          addd     $2074
E4CB:  24 03             bcc      $e4d0 ; $E4D0=loc_E4D0

loc_E4CD:
E4CD:  CC FF FF          ldd      #-1 ; xrefs $E4B8:branch

loc_E4D0:
E4D0:  FD 20 74          std      $2074 ; xrefs $E4CB:branch

loc_E4D3:
E4D3:  FC 20 65          ldd      $2065 ; xrefs $E4C0:branch
E4D6:  F3 25 8E          addd     $258e
E4D9:  46                rora     
E4DA:  56                rorb     
E4DB:  FD 25 90          std      $2590

loc_E4DE:
E4DE:  DC C7             ldd      $c7 ; xrefs $E3FA:jump
E4E0:  FD 25 82          std      $2582
E4E3:  13 A3 08 0D       brclr    $a3, #8, $e4f4 ; $E4F4=loc_E4F4
E4E7:  96 D3             ldaa     $d3
E4E9:  B1 85 45          cmpa     $8545
E4EC:  25 11             bcs      $e4ff ; $E4FF=loc_E4FF
E4EE:  CC FF FF          ldd      #-1
E4F1:  FD 20 82          std      $2082

loc_E4F4:
E4F4:  CC 00 00          ldd      #0 ; xrefs $E4E3:branch
E4F7:  DD C7             std      $c7
E4F9:  FD 25 84          std      $2584
E4FC:  7E E5 90          jmp      $e590 ; $E590=loc_E590

loc_E4FF:
E4FF:  FC 20 42          ldd      $2042 ; $2042=transient_helper_axis | xrefs $E4EC:branch
E502:  18 CE 85 58       ldy      #-31400
E506:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E509:  B7 20 7B          staa     $207b
E50C:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
E50F:  18 CE 85 61       ldy      #-31391
E513:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E516:  B7 20 7A          staa     $207a
E519:  CE 20 42          ldx      #8258
E51C:  18 CE 85 79       ldy      #-31367
E520:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E523:  FD 20 7E          std      $207e
E526:  B3 20 7C          subd     $207c
E529:  24 03             bcc      $e52e ; $E52E=loc_E52E
E52B:  CC 00 00          ldd      #0

loc_E52E:
E52E:  DD FD             std      $fd ; xrefs $E529:branch
E530:  C6 11             ldab     #17
E532:  B6 20 79          ldaa     $2079
E535:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E538:  FD 20 80          std      $2080
E53B:  B3 20 82          subd     $2082
E53E:  24 03             bcc      $e543 ; $E543=loc_E543
E540:  CC 00 00          ldd      #0

loc_E543:
E543:  04                lsrd      ; xrefs $E53E:branch
E544:  DD FD             std      $fd
E546:  C6 09             ldab     #9
E548:  B6 20 7B          ldaa     $207b
E54B:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E54E:  FD 20 77          std      $2077
E551:  B6 20 7A          ldaa     $207a
E554:  C6 05             ldab     #5
E556:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E559:  04                lsrd     
E55A:  04                lsrd     
E55B:  04                lsrd     
E55C:  04                lsrd     
E55D:  1A B3 25 86       cpd      $2586
E561:  25 03             bcs      $e566 ; $E566=loc_E566
E563:  FC 25 86          ldd      $2586

loc_E566:
E566:  DD FD             std      $fd ; xrefs $E561:branch
E568:  DD C7             std      $c7
E56A:  F3 20 82          addd     $2082
E56D:  25 11             bcs      $e580 ; $E580=loc_E580
E56F:  FD 20 82          std      $2082
E572:  FC 25 82          ldd      $2582
E575:  26 0F             bne      $e586 ; $E586=loc_E586
E577:  DC C7             ldd      $c7
E579:  FD 25 82          std      $2582
E57C:  20 08             bra      $e586 ; $E586=loc_E586

; ---- unreached/data gap $E57E-$E57F ----

        .org $E580

loc_E580:
E580:  CC FF FF          ldd      #-1 ; xrefs $E56D:branch
E583:  FD 20 82          std      $2082

loc_E586:
E586:  DC C7             ldd      $c7 ; xrefs $E575:branch, $E57C:branch
E588:  F3 25 82          addd     $2582
E58B:  46                rora     
E58C:  56                rorb     
E58D:  FD 25 84          std      $2584

loc_E590:
E590:  5F                clrb      ; xrefs $E4FC:jump
E591:  12 9F 10 50       brset    $9f, #16, $e5e5 ; $E5E5=loc_E5E5
E595:  13 D7 20 4C       brclr    $d7, #32, $e5e5 ; $E5E5=loc_E5E5
E599:  DE BA             ldx      $ba ; $00BA=engine_period_delta
E59B:  BC 86 34          cpx      $8634
E59E:  22 45             bhi      $e5e5 ; $E5E5=loc_E5E5
E5A0:  B6 20 DF          ldaa     $20df
E5A3:  B1 20 E0          cmpa     $20e0
E5A6:  24 03             bcc      $e5ab ; $E5AB=loc_E5AB
E5A8:  B6 20 E0          ldaa     $20e0

loc_E5AB:
E5AB:  B1 20 E1          cmpa     $20e1 ; xrefs $E5A6:branch
E5AE:  24 03             bcc      $e5b3 ; $E5B3=loc_E5B3
E5B0:  B6 20 E1          ldaa     $20e1

loc_E5B3:
E5B3:  B1 20 DE          cmpa     $20de ; xrefs $E5AE:branch
E5B6:  24 03             bcc      $e5bb ; $E5BB=loc_E5BB
E5B8:  B6 20 DE          ldaa     $20de

loc_E5BB:
E5BB:  4D                tsta      ; xrefs $E5B6:branch
E5BC:  27 27             beq      $e5e5 ; $E5E5=loc_E5E5
E5BE:  B7 25 A1          staa     $25a1
E5C1:  96 D0             ldaa     $d0 ; $00D0=load_aircharge_byte
E5C3:  F6 86 32          ldab     $8632
E5C6:  3D                mul      
E5C7:  89 00             adca     #0
E5C9:  F6 86 33          ldab     $8633
E5CC:  10                sba      
E5CD:  2A 02             bpl      $e5d1 ; $E5D1=loc_E5D1
E5CF:  86 00             ldaa     #0

loc_E5D1:
E5D1:  B7 25 A2          staa     $25a2 ; xrefs $E5CD:branch
E5D4:  B6 25 A1          ldaa     $25a1
E5D7:  F6 25 A2          ldab     $25a2
E5DA:  3D                mul      
E5DB:  04                lsrd     
E5DC:  04                lsrd     
E5DD:  04                lsrd     
E5DE:  04                lsrd     
E5DF:  81 00             cmpa     #0
E5E1:  23 02             bls      $e5e5 ; $E5E5=loc_E5E5
E5E3:  C6 FF             ldab     #-1

loc_E5E5:
E5E5:  F7 20 53          stab     $2053 ; xrefs $E591:branch, $E595:branch, $E59E:branch, $E5BC:branch, $E5E1:branch

; [STRONG] Combine load/air-charge and correction terms into base pulse-width accumulator 0x00C1.
fuel_base_accumulator:
E5E8:  FC 20 4B          ldd      $204b ; $204B=summed_fuel_correction
E5EB:  D3 CE             addd     $ce ; $00CE=load_aircharge_word
E5ED:  2C 02             bge      $e5f1 ; $E5F1=loc_E5F1
E5EF:  4F                clra     
E5F0:  5F                clrb     

loc_E5F1:
E5F1:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E5ED:branch
E5F3:  F6 20 4F          ldab     $204f
E5F6:  96 C2             ldaa     $c2
E5F8:  3D                mul      
E5F9:  89 00             adca     #0
E5FB:  16                tab      
E5FC:  8F                xgdx     
E5FD:  96 C2             ldaa     $c2
E5FF:  F6 20 4E          ldab     $204e
E602:  3D                mul      
E603:  8F                xgdx     
E604:  3A                abx      
E605:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E607:  F6 20 4E          ldab     $204e
E60A:  3D                mul      
E60B:  D7 C2             stab     $c2
E60D:  8F                xgdx     
E60E:  9B C2             adda     $c2
E610:  8F                xgdx     
E611:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E613:  F6 20 4F          ldab     $204f
E616:  3D                mul      
E617:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator
E619:  8F                xgdx     
E61A:  D3 C1             addd     $c1 ; $00C1=base_fuel_pulse_accumulator
E61C:  1A 83 0B B8       cpd      #3000
E620:  25 03             bcs      $e625 ; $E625=loc_E625
E622:  CC 0B B8          ldd      #3000

loc_E625:
E625:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E620:branch
E627:  CE 20 84          ldx      #8324
E62A:  BD E7 15          jsr      $e715 ; $E715=apply_signed_fraction
E62D:  B6 20 B9          ldaa     $20b9 ; $20B9=adaptive_fuel_trim_word
E630:  81 80             cmpa     #-128
E632:  27 03             beq      $e637 ; $E637=loc_E637
E634:  BD E7 48          jsr      $e748 ; $E748=apply_adaptive_trim

loc_E637:
E637:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E632:branch
E639:  DD FD             std      $fd
E63B:  B6 20 85          ldaa     $2085
E63E:  27 07             beq      $e647 ; $E647=loc_E647
E640:  C6 03             ldab     #3
E642:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E645:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator

loc_E647:
E647:  96 C5             ldaa     $c5 ; xrefs $E63E:branch
E649:  27 07             beq      $e652 ; $E652=fuel_final_stack
E64B:  C6 03             ldab     #3
E64D:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E650:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator

; [STRONG] Build final fuel duration path ending in RAM 0x00C3.
fuel_final_stack:
E652:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E649:branch
E654:  F3 20 55          addd     $2055
E657:  25 1A             bcs      $e673 ; $E673=loc_E673
E659:  F3 20 57          addd     $2057
E65C:  25 15             bcs      $e673 ; $E673=loc_E673
E65E:  F3 25 90          addd     $2590
E661:  25 10             bcs      $e673 ; $E673=loc_E673
E663:  B3 25 84          subd     $2584
E666:  24 05             bcc      $e66d ; $E66D=loc_E66D
E668:  CC 00 00          ldd      #0
E66B:  20 09             bra      $e676 ; $E676=loc_E676

loc_E66D:
E66D:  1A 83 7D 00       cpd      #32000 ; xrefs $E666:branch
E671:  23 03             bls      $e676 ; $E676=loc_E676

loc_E673:
E673:  CC 7D 00          ldd      #32000 ; xrefs $E657:branch, $E65C:branch, $E661:branch

loc_E676:
E676:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E66B:branch, $E671:branch
E678:  DC BA             ldd      $ba ; $00BA=engine_period_delta
E67A:  1A 93 C1          cpd      $c1 ; $00C1=base_fuel_pulse_accumulator
E67D:  24 02             bcc      $e681 ; $E681=loc_E681
E67F:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator

loc_E681:
E681:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E67D:branch
E683:  37                pshb     
E684:  F6 20 53          ldab     $2053
E687:  3D                mul      
E688:  8F                xgdx     
E689:  32                pula     
E68A:  F6 20 53          ldab     $2053
E68D:  3D                mul      
E68E:  89 00             adca     #0
E690:  16                tab      
E691:  3A                abx      
E692:  8F                xgdx     
E693:  04                lsrd     
E694:  D3 C1             addd     $c1 ; $00C1=base_fuel_pulse_accumulator
E696:  1A 83 7D 00       cpd      #32000
E69A:  23 03             bls      $e69f ; $E69F=loc_E69F
E69C:  CC 7D 00          ldd      #32000

loc_E69F:
E69F:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E69A:branch
E6A1:  FD 20 51          std      $2051
E6A4:  DD FD             std      $fd
E6A6:  B6 20 49          ldaa     $2049
E6A9:  27 19             beq      $e6c4 ; $E6C4=loc_E6C4
E6AB:  C6 02             ldab     #2
E6AD:  BD E6 DA          jsr      $e6da ; $E6DA=sub_E6DA
E6B0:  1A 83 7D 00       cpd      #32000
E6B4:  25 03             bcs      $e6b9 ; $E6B9=loc_E6B9
E6B6:  CC 7D 00          ldd      #32000

loc_E6B9:
E6B9:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E6B4:branch
E6BB:  DC BA             ldd      $ba ; $00BA=engine_period_delta
E6BD:  1A 93 C1          cpd      $c1 ; $00C1=base_fuel_pulse_accumulator
E6C0:  24 02             bcc      $e6c4 ; $E6C4=loc_E6C4
E6C2:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator

loc_E6C4:
E6C4:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector | xrefs $E6A9:branch, $E6C0:branch
E6C7:  81 0C             cmpa     #12
E6C9:  26 06             bne      $e6d1 ; $E6D1=loc_E6D1
E6CB:  BD 96 F3          jsr      $96f3 ; $96F3=sub_96F3
E6CE:  04                lsrd     
E6CF:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator

loc_E6D1:
E6D1:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E6C9:branch
E6D3:  DD C3             std      $c3 ; $00C3=final_fuel_duration
E6D5:  BD 44 05          jsr      $4405 ; $4405=sub_4405
E6D8:  39                rts      

; ---- unreached/data gap $E6D9-$E6D9 ----

        .org $E6DA

sub_E6DA:
E6DA:  DE FD             ldx      $fd ; xrefs $E46D:call, $E497:call, $E4A2:call, $E535:call, $E54B:call, $E556:call, $E642:call, $E64D:call, +1 more
E6DC:  37                pshb     
E6DD:  36                psha     
E6DE:  D6 FE             ldab     $fe
E6E0:  3D                mul      
E6E1:  DD FE             std      $fe
E6E3:  32                pula     
E6E4:  D6 FD             ldab     $fd
E6E6:  7F 00 FD          clr      >$00fd
E6E9:  3D                mul      
E6EA:  D3 FD             addd     $fd
E6EC:  DD FD             std      $fd
E6EE:  33                pulb     
E6EF:  C0 01             subb     #1

loc_E6F1:
E6F1:  54                lsrb      ; xrefs $E6FD:branch
E6F2:  25 0D             bcs      $e701 ; $E701=loc_E701
E6F4:  78 00 FF          asl      >$00ff
E6F7:  79 00 FE          rol      >$00fe
E6FA:  79 00 FD          rol      >$00fd
E6FD:  24 F2             bcc      $e6f1 ; $E6F1=loc_E6F1
E6FF:  20 0E             bra      $e70f ; $E70F=loc_E70F

loc_E701:
E701:  78 00 FF          asl      >$00ff ; xrefs $E6F2:branch
E704:  8F                xgdx     
E705:  C9 00             adcb     #0
E707:  89 00             adca     #0
E709:  25 04             bcs      $e70f ; $E70F=loc_E70F
E70B:  D3 FD             addd     $fd
E70D:  24 03             bcc      $e712 ; $E712=loc_E712

loc_E70F:
E70F:  CC FF FF          ldd      #-1 ; xrefs $E6FF:branch, $E709:branch

loc_E712:
E712:  DD FD             std      $fd ; xrefs $E70D:branch
E714:  39                rts      

; [CONFIRMED] Apply approximately value += value * signed_raw / 256.
apply_signed_fraction:
E715:  96 C2             ldaa     $c2 ; xrefs $E62A:call
E717:  E6 00             ldab     0, x
E719:  2B 13             bmi      $e72e ; $E72E=loc_E72E
E71B:  3D                mul      
E71C:  89 00             adca     #0
E71E:  97 FE             staa     $fe
E720:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E722:  5F                clrb     
E723:  D7 FD             stab     $fd
E725:  E6 00             ldab     0, x
E727:  3D                mul      
E728:  D3 FD             addd     $fd
E72A:  D3 C1             addd     $c1 ; $00C1=base_fuel_pulse_accumulator
E72C:  20 17             bra      $e745 ; $E745=loc_E745

loc_E72E:
E72E:  50                negb      ; xrefs $E719:branch
E72F:  3D                mul      
E730:  89 00             adca     #0
E732:  97 FE             staa     $fe
E734:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E736:  5F                clrb     
E737:  D7 FD             stab     $fd
E739:  E6 00             ldab     0, x
E73B:  50                negb     
E73C:  3D                mul      
E73D:  D3 FD             addd     $fd
E73F:  DD FD             std      $fd
E741:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator
E743:  93 FD             subd     $fd

loc_E745:
E745:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E72C:branch
E747:  39                rts      

; [CONFIRMED] Apply adaptive trim word centered at 0x8000.
apply_adaptive_trim:
E748:  80 80             suba     #-128 ; xrefs $E634:call
E74A:  2B 16             bmi      $e762 ; $E762=loc_E762
E74C:  36                psha     
E74D:  D6 C2             ldab     $c2
E74F:  3D                mul      
E750:  89 00             adca     #0
E752:  97 FE             staa     $fe
E754:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E756:  7F 00 FD          clr      >$00fd
E759:  33                pulb     
E75A:  3D                mul      
E75B:  D3 FD             addd     $fd
E75D:  04                lsrd     
E75E:  D3 C1             addd     $c1 ; $00C1=base_fuel_pulse_accumulator
E760:  20 19             bra      $e77b ; $E77B=loc_E77B

loc_E762:
E762:  40                nega      ; xrefs $E74A:branch
E763:  36                psha     
E764:  D6 C2             ldab     $c2
E766:  3D                mul      
E767:  89 00             adca     #0
E769:  97 FE             staa     $fe
E76B:  96 C1             ldaa     $c1 ; $00C1=base_fuel_pulse_accumulator
E76D:  7F 00 FD          clr      >$00fd
E770:  33                pulb     
E771:  3D                mul      
E772:  D3 FD             addd     $fd
E774:  04                lsrd     
E775:  DD FD             std      $fd
E777:  DC C1             ldd      $c1 ; $00C1=base_fuel_pulse_accumulator
E779:  93 FD             subd     $fd

loc_E77B:
E77B:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator | xrefs $E760:branch
E77D:  39                rts      

sub_E77E:
E77E:  DC 08             ldd      $08 ; xrefs $B90A:call
E780:  FD 25 96          std      $2596
E783:  B6 80 2B          ldaa     $802b ; $802B=fuel_iat_rpm_corr_a_24x9_s8
E786:  B7 20 4A          staa     $204a
E789:  B6 81 03          ldaa     $8103 ; $8103=fuel_iat_rpm_corr_b_24x9_s8
E78C:  B7 20 4D          staa     $204d
E78F:  B6 84 1A          ldaa     $841a
E792:  B7 20 62          staa     $2062
E795:  CC 00 00          ldd      #0
E798:  B7 20 84          staa     $2084 ; $2084=signed_fuel_trim_raw
E79B:  B7 20 85          staa     $2085
E79E:  B7 20 49          staa     $2049
E7A1:  97 B1             staa     $b1
E7A3:  B7 20 F7          staa     $20f7
E7A6:  FD 20 55          std      $2055
E7A9:  FD 20 57          std      $2057
E7AC:  DD C3             std      $c3 ; $00C3=final_fuel_duration
E7AE:  FD 20 51          std      $2051
E7B1:  B7 25 A2          staa     $25a2
E7B4:  B7 20 53          staa     $2053
E7B7:  B7 25 A1          staa     $25a1
E7BA:  DD C1             std      $c1 ; $00C1=base_fuel_pulse_accumulator
E7BC:  FD 24 D9          std      $24d9
E7BF:  FD 20 65          std      $2065
E7C2:  DD C7             std      $c7
E7C4:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
E7C7:  18 CE 84 5B       ldy      #-31653
E7CB:  7D 00 90          tst      >$0090
E7CE:  26 04             bne      $e7d4 ; $E7D4=loc_E7D4
E7D0:  18 CE 84 6C       ldy      #-31636

loc_E7D4:
E7D4:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $E7CE:branch
E7D7:  97 C5             staa     $c5
E7D9:  7F 00 C6          clr      >$00c6
E7DC:  39                rts      

sub_E7DD:
E7DD:  B6 81 DB          ldaa     $81db ; xrefs $D5C5:call
E7E0:  13 A9 40 08       brclr    $a9, #64, $e7ec ; $00A9=operating_mode_flags, $E7EC=loc_E7EC
E7E4:  12 B3 40 04       brset    $b3, #64, $e7ec ; $E7EC=loc_E7EC
E7E8:  13 A2 0C 01       brclr    $a2, #12, $e7ed ; $00A2=spark_mode_flags, $E7ED=loc_E7ED

loc_E7EC:
E7EC:  4F                clra      ; xrefs $E7E0:branch, $E7E4:branch

loc_E7ED:
E7ED:  B7 20 50          staa     $2050 ; xrefs $E7E8:branch
E7F0:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
E7F3:  18 CE 85 9F       ldy      #-31329
E7F7:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E7FA:  B7 20 54          staa     $2054
E7FD:  CE 20 3C          ldx      #8252
E800:  18 CE 84 F6       ldy      #-31498
E804:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E807:  FD 25 88          std      $2588
E80A:  CE 20 3C          ldx      #8252
E80D:  18 CE 85 46       ldy      #-31418
E811:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E814:  FD 25 86          std      $2586
E817:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
E81A:  18 CE 85 3B       ldy      #-31429
E81E:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E821:  B7 20 6B          staa     $206b
E824:  FC 20 3C          ldd      $203c ; $203C=cts_axis_index
E827:  18 CE 85 8B       ldy      #-31349
E82B:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E82E:  B7 20 79          staa     $2079
E831:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
E834:  18 CE 84 08       ldy      #-31736
E838:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E83B:  B7 20 85          staa     $2085
E83E:  FC 20 40          ldd      $2040 ; $2040=scheduler_axis_index
E841:  18 CE 84 E3       ldy      #-31517
E845:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E848:  B7 20 49          staa     $2049

; [CONFIRMED] Lookup signed 0x802B/0x8103 IAT-like by RPM correction banks.
fuel_iat_rpm_corrections:
E84B:  18 CE 25 A3       ldy      #9635
E84F:  FC 20 38          ldd      $2038 ; $2038=iat_axis_index
E852:  18 ED 00          std      0, y
E855:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
E858:  18 ED 02          std      2, y
E85B:  CE 80 2B          ldx      #-32725
E85E:  CD EF 04          stx      4, y
E861:  86 09             ldaa     #9
E863:  18 A7 06          staa     6, y
E866:  BD B3 2B          jsr      $b32b ; $B32B=interp_2d_s8
E869:  B7 20 4A          staa     $204a
E86C:  18 CE 25 A3       ldy      #9635
E870:  FC 20 38          ldd      $2038 ; $2038=iat_axis_index
E873:  18 ED 00          std      0, y
E876:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
E879:  18 ED 02          std      2, y
E87C:  CE 81 03          ldx      #-32509
E87F:  CD EF 04          stx      4, y
E882:  86 09             ldaa     #9
E884:  18 A7 06          staa     6, y
E887:  BD B3 2B          jsr      $b32b ; $B32B=interp_2d_s8
E88A:  B7 20 4D          staa     $204d
E88D:  FC 81 DC          ldd      $81dc
E890:  1A B3 20 14       cpd      $2014
E894:  25 03             bcs      $e899 ; $E899=loc_E899
E896:  14 9E 20          bset     $9e, #32

loc_E899:
E899:  F3 81 DE          addd     $81de ; xrefs $E894:branch
E89C:  1A B3 20 14       cpd      $2014
E8A0:  24 03             bcc      $e8a5 ; $E8A5=loc_E8A5
E8A2:  15 9E 20          bclr     $9e, #32

loc_E8A5:
E8A5:  13 9E 20 21       brclr    $9e, #32, $e8ca ; $E8CA=loc_E8CA | xrefs $E8A0:branch
E8A9:  CC 03 F7          ldd      #1015
E8AC:  B3 20 14          subd     $2014
E8AF:  25 19             bcs      $e8ca ; $E8CA=loc_E8CA
E8B1:  37                pshb     
E8B2:  36                psha     
E8B3:  FC 20 36          ldd      $2036 ; $2036=normalized_rpm_axis
E8B6:  18 CE 81 E0       ldy      #-32288
E8BA:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
E8BD:  33                pulb     
E8BE:  36                psha     
E8BF:  3D                mul      
E8C0:  8F                xgdx     
E8C1:  32                pula     
E8C2:  33                pulb     
E8C3:  3D                mul      
E8C4:  89 00             adca     #0
E8C6:  16                tab      
E8C7:  3A                abx      
E8C8:  20 03             bra      $e8cd ; $E8CD=loc_E8CD

loc_E8CA:
E8CA:  CE 00 00          ldx      #0 ; xrefs $E8A5:branch, $E8AF:branch

loc_E8CD:
E8CD:  FF 24 D9          stx      $24d9 ; xrefs $E8C8:branch
E8D0:  B6 25 8A          ldaa     $258a
E8D3:  80 01             suba     #1
E8D5:  B7 25 8A          staa     $258a
E8D8:  22 4D             bhi      $e927 ; $E927=sum_fuel_corrections
E8DA:  B6 80 2A          ldaa     $802a
E8DD:  B7 25 8A          staa     $258a
E8E0:  DC 08             ldd      $08
E8E2:  12 A3 10 12       brset    $a3, #16, $e8f8 ; $E8F8=loc_E8F8
E8E6:  DC 0C             ldd      $0c
E8E8:  8F                xgdx     
E8E9:  B6 20 2B          ldaa     $202b
E8EC:  B1 89 6F          cmpa     $896f
E8EF:  23 04             bls      $e8f5 ; $E8F5=loc_E8F5
E8F1:  DC 0E             ldd      $0e
E8F3:  20 0E             bra      $e903 ; $E903=loc_E903

loc_E8F5:
E8F5:  8F                xgdx      ; xrefs $E8EF:branch, $E8FF:branch
E8F6:  20 0B             bra      $e903 ; $E903=loc_E903

loc_E8F8:
E8F8:  8F                xgdx      ; xrefs $E8E2:branch
E8F9:  B6 20 2B          ldaa     $202b
E8FC:  B1 89 6F          cmpa     $896f
E8FF:  23 F4             bls      $e8f5 ; $E8F5=loc_E8F5
E901:  DC 0A             ldd      $0a

loc_E903:
E903:  B3 25 96          subd     $2596 ; xrefs $E8F3:branch, $E8F6:branch
E906:  27 1F             beq      $e927 ; $E927=sum_fuel_corrections
E908:  2C 0E             bge      $e918 ; $E918=loc_E918
E90A:  1A 83 FF FC       cpd      #-4
E90E:  2C 03             bge      $e913 ; $E913=loc_E913
E910:  CC FF FC          ldd      #-4

loc_E913:
E913:  F3 25 96          addd     $2596 ; xrefs $E90E:branch
E916:  20 0C             bra      $e924 ; $E924=loc_E924

loc_E918:
E918:  1A 83 00 04       cpd      #4 ; xrefs $E908:branch
E91C:  2F 03             ble      $e921 ; $E921=loc_E921
E91E:  CC 00 04          ldd      #4

loc_E921:
E921:  F3 25 96          addd     $2596 ; xrefs $E91C:branch

loc_E924:
E924:  FD 25 96          std      $2596 ; xrefs $E916:branch

; [STRONG] Sum correction terms into RAM 0x204B.
sum_fuel_corrections:
E927:  4F                clra      ; xrefs $E8D8:branch, $E906:branch
E928:  F6 20 4A          ldab     $204a
E92B:  2A 01             bpl      $e92e ; $E92E=loc_E92E
E92D:  43                coma     

loc_E92E:
E92E:  F3 25 96          addd     $2596 ; xrefs $E92B:branch
E931:  FD 25 A3          std      $25a3
E934:  4F                clra     
E935:  F6 20 50          ldab     $2050
E938:  2A 01             bpl      $e93b ; $E93B=loc_E93B
E93A:  43                coma     

loc_E93B:
E93B:  F3 25 A3          addd     $25a3 ; xrefs $E938:branch
E93E:  05                asld     
E93F:  FD 25 A3          std      $25a3
E942:  7D 20 B1          tst      $20b1 ; $20B1=spark_fuel_bank_selector
E945:  26 0F             bne      $e956 ; $E956=loc_E956
E947:  4F                clra     
E948:  F6 26 10          ldab     $2610
E94B:  2A 01             bpl      $e94e ; $E94E=loc_E94E
E94D:  43                coma     

loc_E94E:
E94E:  13 A9 40 01       brclr    $a9, #64, $e953 ; $00A9=operating_mode_flags, $E953=loc_E953 | xrefs $E94B:branch
E952:  05                asld     

loc_E953:
E953:  F3 25 A3          addd     $25a3 ; xrefs $E94E:branch

loc_E956:
E956:  F3 24 D9          addd     $24d9 ; xrefs $E945:branch
E959:  FD 20 4B          std      $204b ; $204B=summed_fuel_correction
E95C:  4F                clra     
E95D:  F6 20 4D          ldab     $204d
E960:  2A 01             bpl      $e963 ; $E963=loc_E963
E962:  43                coma     

loc_E963:
E963:  D3 06             addd     $06 ; xrefs $E960:branch
E965:  F3 80 28          addd     $8028
E968:  2C 03             bge      $e96d ; $E96D=loc_E96D
E96A:  CC 00 00          ldd      #0

loc_E96D:
E96D:  FD 20 4E          std      $204e ; xrefs $E968:branch
E970:  39                rts      

; ---- unreached/data gap $E971-$E971 ----

        .org $E972

sub_E972:
E972:  15 9E 10          bclr     $9e, #16 ; xrefs $994C:call
E975:  DC CE             ldd      $ce ; $00CE=load_aircharge_word
E977:  FD 20 67          std      $2067
E97A:  FC 20 42          ldd      $2042 ; $2042=transient_helper_axis
E97D:  FD 25 92          std      $2592
E980:  CC 00 00          ldd      #0
E983:  FD 20 74          std      $2074
E986:  13 A3 80 07       brclr    $a3, #-128, $e991 ; $E991=loc_E991
E98A:  13 AB 80 03       brclr    $ab, #-128, $e991 ; $E991=loc_E991
E98E:  FD 25 8B          std      $258b

loc_E991:
E991:  39                rts       ; xrefs $E986:branch, $E98A:branch

; ---- unreached/data gap $E992-$E992 ----

        .org $E993

sub_E993:
E993:  CC 00 00          ldd      #0 ; xrefs $99E6:call
E996:  FD 20 82          std      $2082
E999:  CE 20 42          ldx      #8258
E99C:  18 CE 85 79       ldy      #-31367
E9A0:  BD B2 6E          jsr      $b26e ; $B26E=interp_1d_word
E9A3:  FD 20 7C          std      $207c
E9A6:  39                rts      

; ---- unreached/data gap $E9A7-$E9A7 ----

        .org $E9A8

; [CONFIRMED] Afterstart/warmup state handler using CTS-like support vectors.
afterstart_state_handler:
E9A8:  F6 20 59          ldab     $2059 ; xrefs $B457:call, $B462:call
E9AB:  C1 04             cmpb     #4
E9AD:  27 2F             beq      $e9de ; $E9DE=loc_E9DE
E9AF:  C1 03             cmpb     #3
E9B1:  27 77             beq      $ea2a ; $EA2A=loc_EA2A
E9B3:  37                pshb     
E9B4:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
E9B7:  18 CE 84 5B       ldy      #-31653
E9BB:  7D 00 90          tst      >$0090
E9BE:  26 04             bne      $e9c4 ; $E9C4=loc_E9C4
E9C0:  18 CE 84 6C       ldy      #-31636

loc_E9C4:
E9C4:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $E9BE:branch
E9C7:  97 C5             staa     $c5
E9C9:  7F 00 C6          clr      >$00c6
E9CC:  33                pulb     
E9CD:  13 A9 02 0D       brclr    $a9, #2, $e9de ; $00A9=operating_mode_flags, $E9DE=loc_E9DE
E9D1:  C1 02             cmpb     #2
E9D3:  27 27             beq      $e9fc ; $E9FC=loc_E9FC
E9D5:  B6 20 62          ldaa     $2062
E9D8:  27 07             beq      $e9e1 ; $E9E1=loc_E9E1
E9DA:  4A                deca     
E9DB:  B7 20 62          staa     $2062

loc_E9DE:
E9DE:  7E EA 99          jmp      $ea99 ; $EA99=loc_EA99 | xrefs $E9AD:branch, $E9CD:branch

loc_E9E1:
E9E1:  86 02             ldaa     #2 ; xrefs $E9D8:branch
E9E3:  B7 20 59          staa     $2059
E9E6:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
E9E9:  18 CE 84 7D       ldy      #-31619
E9ED:  7D 00 90          tst      >$0090
E9F0:  26 04             bne      $e9f6 ; $E9F6=loc_E9F6
E9F2:  18 CE 84 8E       ldy      #-31602

loc_E9F6:
E9F6:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $E9F0:branch
E9F9:  B7 20 60          staa     $2060

loc_E9FC:
E9FC:  B6 20 60          ldaa     $2060 ; xrefs $E9D3:branch
E9FF:  27 07             beq      $ea08 ; $EA08=loc_EA08
EA01:  4A                deca     
EA02:  B7 20 60          staa     $2060
EA05:  7E EA 99          jmp      $ea99 ; $EA99=loc_EA99

loc_EA08:
EA08:  C6 03             ldab     #3 ; xrefs $E9FF:branch
EA0A:  F7 20 59          stab     $2059
EA0D:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value
EA10:  18 CE 84 9F       ldy      #-31585
EA14:  7D 00 90          tst      >$0090
EA17:  26 04             bne      $ea1d ; $EA1D=loc_EA1D
EA19:  18 CE 84 B0       ldy      #-31568

loc_EA1D:
EA1D:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $EA17:branch
EA20:  16                tab      
EA21:  96 C5             ldaa     $c5
EA23:  10                sba      
EA24:  23 69             bls      $ea8f ; $EA8F=loc_EA8F
EA26:  97 C5             staa     $c5
EA28:  20 6F             bra      $ea99 ; $EA99=loc_EA99

loc_EA2A:
EA2A:  FC 20 3E          ldd      $203e ; $203E=cts_axis_fraction_or_value | xrefs $E9B1:branch
EA2D:  18 CE 84 C1       ldy      #-31551
EA31:  7D 00 90          tst      >$0090
EA34:  26 04             bne      $ea3a ; $EA3A=loc_EA3A
EA36:  18 CE 84 D2       ldy      #-31534

loc_EA3A:
EA3A:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8 | xrefs $EA34:branch
EA3D:  B7 25 8D          staa     $258d
EA40:  7F 25 9A          clr      $259a
EA43:  D6 C6             ldab     $c6
EA45:  3D                mul      
EA46:  FD 25 9B          std      $259b
EA49:  D6 C5             ldab     $c5
EA4B:  B6 25 8D          ldaa     $258d
EA4E:  3D                mul      
EA4F:  F3 25 9A          addd     $259a
EA52:  04                lsrd     
EA53:  76 25 9C          ror      $259c
EA56:  04                lsrd     
EA57:  76 25 9C          ror      $259c
EA5A:  04                lsrd     
EA5B:  76 25 9C          ror      $259c
EA5E:  04                lsrd     
EA5F:  76 25 9C          ror      $259c
EA62:  04                lsrd     
EA63:  76 25 9C          ror      $259c
EA66:  04                lsrd     
EA67:  76 25 9C          ror      $259c
EA6A:  FD 25 9A          std      $259a
EA6D:  5F                clrb     
EA6E:  96 C6             ldaa     $c6
EA70:  B3 25 9B          subd     $259b
EA73:  FD 25 9B          std      $259b
EA76:  24 05             bcc      $ea7d ; $EA7D=loc_EA7D
EA78:  96 C5             ldaa     $c5
EA7A:  4A                deca     
EA7B:  20 02             bra      $ea7f ; $EA7F=loc_EA7F

loc_EA7D:
EA7D:  96 C5             ldaa     $c5 ; xrefs $EA76:branch

loc_EA7F:
EA7F:  F6 25 9A          ldab     $259a ; xrefs $EA7B:branch
EA82:  10                sba      
EA83:  27 0A             beq      $ea8f ; $EA8F=loc_EA8F
EA85:  B7 25 9A          staa     $259a
EA88:  FC 25 9A          ldd      $259a
EA8B:  DD C5             std      $c5
EA8D:  20 0A             bra      $ea99 ; $EA99=loc_EA99

loc_EA8F:
EA8F:  CC 00 00          ldd      #0 ; xrefs $EA24:branch, $EA83:branch
EA92:  DD C5             std      $c5
EA94:  86 04             ldaa     #4
EA96:  B7 20 59          staa     $2059

loc_EA99:
EA99:  13 B1 10 2A       brclr    $b1, #16, $eac7 ; $EAC7=loc_EAC7 | xrefs $E9DE:jump, $EA05:jump, $EA28:branch, $EA8D:branch
EA9D:  F6 85 95          ldab     $8595
EAA0:  18 CE 85 96       ldy      #-31338
EAA4:  BD EB 16          jsr      $eb16 ; $EB16=sub_EB16
EAA7:  FD 20 55          std      $2055
EAAA:  B6 20 F7          ldaa     $20f7
EAAD:  27 06             beq      $eab5 ; $EAB5=loc_EAB5
EAAF:  4A                deca     
EAB0:  B7 20 F7          staa     $20f7
EAB3:  20 12             bra      $eac7 ; $EAC7=loc_EAC7

loc_EAB5:
EAB5:  FC 20 55          ldd      $2055 ; xrefs $EAAD:branch
EAB8:  1A B3 87 7B       cpd      $877b
EABC:  22 09             bhi      $eac7 ; $EAC7=loc_EAC7
EABE:  15 B1 10          bclr     $b1, #16
EAC1:  CC 00 00          ldd      #0
EAC4:  FD 20 55          std      $2055

loc_EAC7:
EAC7:  12 B1 20 2D       brset    $b1, #32, $eaf8 ; $EAF8=loc_EAF8 | xrefs $EA99:branch, $EAB3:branch, $EABC:branch
EACB:  13 A9 40 45       brclr    $a9, #64, $eb14 ; $00A9=operating_mode_flags, $EB14=loc_EB14
EACF:  F6 20 30          ldab     $2030
EAD2:  13 A3 10 05       brclr    $a3, #16, $eadb ; $EADB=loc_EADB
EAD6:  B6 85 A8          ldaa     $85a8
EAD9:  20 07             bra      $eae2 ; $EAE2=loc_EAE2

loc_EADB:
EADB:  13 A3 80 35       brclr    $a3, #-128, $eb14 ; $EB14=loc_EB14 | xrefs $EAD2:branch
EADF:  B6 85 A9          ldaa     $85a9

loc_EAE2:
EAE2:  11                cba       ; xrefs $EAD9:branch
EAE3:  22 2F             bhi      $eb14 ; $EB14=loc_EB14
EAE5:  B6 20 A8          ldaa     $20a8
EAE8:  44                lsra     
EAE9:  44                lsra     
EAEA:  BB 85 AA          adda     $85aa
EAED:  24 02             bcc      $eaf1 ; $EAF1=loc_EAF1
EAEF:  86 FF             ldaa     #-1

loc_EAF1:
EAF1:  91 D3             cmpa     $d3 ; xrefs $EAED:branch
EAF3:  23 1F             bls      $eb14 ; $EB14=loc_EB14
EAF5:  14 B1 20          bset     $b1, #32

loc_EAF8:
EAF8:  F6 85 AE          ldab     $85ae ; xrefs $EAC7:branch
EAFB:  18 CE 85 AF       ldy      #-31313
EAFF:  BD EB 16          jsr      $eb16 ; $EB16=sub_EB16
EB02:  FD 20 57          std      $2057
EB05:  1A B3 85 AB       cpd      $85ab
EB09:  22 09             bhi      $eb14 ; $EB14=loc_EB14
EB0B:  CC 00 00          ldd      #0
EB0E:  FD 20 57          std      $2057
EB11:  15 B1 20          bclr     $b1, #32

loc_EB14:
EB14:  39                rts       ; xrefs $EACB:branch, $EADB:branch, $EAE3:branch, $EAF3:branch, $EB09:branch

; ---- unreached/data gap $EB15-$EB15 ----

        .org $EB16

sub_EB16:
EB16:  B6 20 30          ldaa     $2030 ; xrefs $EAA4:call, $EAFF:call
EB19:  10                sba      
EB1A:  24 02             bcc      $eb1e ; $EB1E=loc_EB1E
EB1C:  86 00             ldaa     #0

loc_EB1E:
EB1E:  5F                clrb      ; xrefs $EB1A:branch
EB1F:  04                lsrd     
EB20:  04                lsrd     
EB21:  04                lsrd     
EB22:  04                lsrd     
EB23:  04                lsrd     
EB24:  BD B2 AB          jsr      $b2ab ; $B2AB=interp_1d_u8
EB27:  36                psha     
EB28:  F6 20 54          ldab     $2054
EB2B:  3D                mul      
EB2C:  89 00             adca     #0
EB2E:  16                tab      
EB2F:  4F                clra     
EB30:  05                asld     
EB31:  8F                xgdx     
EB32:  33                pulb     
EB33:  3A                abx      
EB34:  8F                xgdx     
EB35:  39                rts      

; ---- unreached/data gap $EB36-$EB36 ----

        .org $EB37
EB37:  86 04             ldaa     #4
EB39:  B7 10 23          staa     $1023 ; $1023=TFLG1
EB3C:  B6 21 A6          ldaa     $21a6 ; $21A6=operating_state_selector
EB3F:  81 06             cmpa     #6
EB41:  26 06             bne      $eb49 ; $EB49=loc_EB49
EB43:  BD E0 78          jsr      $e078 ; $E078=sub_E078
EB46:  7E EB B2          jmp      $ebb2 ; $EBB2=loc_EBB2

loc_EB49:
EB49:  14 27 02          bset     $27, #2 ; xrefs $EB41:branch
EB4C:  14 D8 40          bset     $d8, #64
EB4F:  FC 25 B3          ldd      $25b3
EB52:  C3 00 01          addd     #1
EB55:  FD 25 B3          std      $25b3
EB58:  18 CE 01 00       ldy      #256
EB5C:  B6 25 B2          ldaa     $25b2
EB5F:  81 80             cmpa     #-128
EB61:  27 04             beq      $eb67 ; $EB67=loc_EB67
EB63:  4C                inca     
EB64:  B7 25 B2          staa     $25b2

loc_EB67:
EB67:  0C                clc       ; xrefs $EB61:branch

loc_EB68:
EB68:  18 8F             xgdy      ; xrefs $EB6E:branch
EB6A:  04                lsrd     
EB6B:  18 8F             xgdy     
EB6D:  44                lsra     
EB6E:  24 F8             bcc      $eb68 ; $EB68=loc_EB68
EB70:  26 3D             bne      $ebaf ; $EBAF=loc_EBAF
EB72:  B6 25 B6          ldaa     $25b6
EB75:  81 10             cmpa     #16
EB77:  25 36             bcs      $ebaf ; $EBAF=loc_EBAF
EB79:  12 D8 01 32       brset    $d8, #1, $ebaf ; $EBAF=loc_EBAF
EB7D:  F6 25 B2          ldab     $25b2

loc_EB80:
EB80:  04                lsrd      ; xrefs $EB81:branch
EB81:  24 FD             bcc      $eb80 ; $EB80=loc_EB80
EB83:  05                asld     
EB84:  FE 20 AC          ldx      $20ac
EB87:  FF 25 AA          stx      $25aa
EB8A:  FD 20 AC          std      $20ac
EB8D:  18 8F             xgdy     
EB8F:  05                asld     
EB90:  FD 20 AE          std      $20ae
EB93:  B6 25 B6          ldaa     $25b6
EB96:  81 1E             cmpa     #30
EB98:  25 06             bcs      $eba0 ; $EBA0=loc_EBA0
EB9A:  FC 20 AE          ldd      $20ae
EB9D:  05                asld     
EB9E:  20 03             bra      $eba3 ; $EBA3=loc_EBA3

loc_EBA0:
EBA0:  FC 20 AE          ldd      $20ae ; xrefs $EB98:branch

loc_EBA3:
EBA3:  FD 25 C1          std      $25c1 ; xrefs $EB9E:branch
EBA6:  14 D8 01          bset     $d8, #1
EBA9:  7F 25 B2          clr      $25b2
EBAC:  7F 25 B6          clr      $25b6

loc_EBAF:
EBAF:  7F 20 A9          clr      $20a9 ; xrefs $EB70:branch, $EB77:branch, $EB79:branch

loc_EBB2:
EBB2:  3B                rti       ; xrefs $EB46:jump

; ---- unreached/data gap $EBB3-$EBB3 ----

        .org $EBB4

sub_EBB4:
EBB4:  B6 00 D3          ldaa     >$00d3 ; xrefs $D5B6:call
EBB7:  B1 91 2C          cmpa     $912c
EBBA:  25 16             bcs      $ebd2 ; $EBD2=loc_EBD2
EBBC:  B6 20 AB          ldaa     $20ab
EBBF:  27 11             beq      $ebd2 ; $EBD2=loc_EBD2
EBC1:  CE 10 00          ldx      #4096
EBC4:  1D 22 04          bclr     34, x; #4
EBC7:  86 FF             ldaa     #-1
EBC9:  B7 20 B0          staa     $20b0
EBCC:  14 D8 80          bset     $d8, #-128
EBCF:  7E EF 28          jmp      $ef28 ; $EF28=loc_EF28

loc_EBD2:
EBD2:  13 D8 80 06       brclr    $d8, #-128, $ebdc ; $EBDC=loc_EBDC | xrefs $EBBA:branch, $EBBF:branch
EBD6:  CC 00 00          ldd      #0
EBD9:  BD EF 7D          jsr      $ef7d ; $EF7D=sub_EF7D

loc_EBDC:
EBDC:  B6 91 28          ldaa     $9128 ; xrefs $EBD2:branch
EBDF:  27 03             beq      $ebe4 ; $EBE4=loc_EBE4
EBE1:  14 D8 08          bset     $d8, #8

loc_EBE4:
EBE4:  12 D8 08 4B       brset    $d8, #8, $ec33 ; $EC33=loc_EC33 | xrefs $EBDF:branch
EBE8:  F6 91 21          ldab     $9121
EBEB:  27 60             beq      $ec4d ; $EC4D=loc_EC4D
EBED:  B6 20 A9          ldaa     $20a9
EBF0:  81 02             cmpa     #2
EBF2:  23 64             bls      $ec58 ; $EC58=loc_EC58
EBF4:  BD EF FF          jsr      $efff ; $EFFF=sub_EFFF
EBF7:  D1 8A             cmpb     $8a
EBF9:  26 38             bne      $ec33 ; $EC33=loc_EC33
EBFB:  CE 00 72          ldx      #114

loc_EBFE:
EBFE:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0 | xrefs $EC15:branch, $EC2F:branch
EC01:  18 8F             xgdy     
EC03:  08                inx      
EC04:  08                inx      
EC05:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0
EC08:  18 8F             xgdy     
EC0A:  1A B3 25 BA       cpd      $25ba
EC0E:  24 07             bcc      $ec17 ; $EC17=loc_EC17
EC10:  8C 00 7A          cpx      #122
EC13:  26 1E             bne      $ec33 ; $EC33=loc_EC33
EC15:  20 E7             bra      $ebfe ; $EBFE=loc_EBFE

loc_EC17:
EC17:  3C                pshx      ; xrefs $EC0E:branch
EC18:  8F                xgdx     
EC19:  83 00 72          subd     #114
EC1C:  54                lsrb     
EC1D:  54                lsrb     
EC1E:  24 0B             bcc      $ec2b ; $EC2B=loc_EC2B
EC20:  8F                xgdx     
EC21:  B3 25 BA          subd     $25ba
EC24:  27 05             beq      $ec2b ; $EC2B=loc_EC2B

loc_EC26:
EC26:  04                lsrd      ; xrefs $EC27:branch
EC27:  24 FD             bcc      $ec26 ; $EC26=loc_EC26
EC29:  26 08             bne      $ec33 ; $EC33=loc_EC33

loc_EC2B:
EC2B:  38                pulx      ; xrefs $EC1E:branch, $EC24:branch
EC2C:  8C 00 88          cpx      #136
EC2F:  26 CD             bne      $ebfe ; $EBFE=loc_EBFE
EC31:  20 1A             bra      $ec4d ; $EC4D=loc_EC4D

loc_EC33:
EC33:  4F                clra      ; xrefs $EBE4:branch, $EBF9:branch, $EC13:branch, $EC29:branch
EC34:  CE 00 72          ldx      #114

loc_EC37:
EC37:  A7 00             staa     0, x ; xrefs $EC3D:branch
EC39:  08                inx      
EC3A:  8C 00 8A          cpx      #138
EC3D:  26 F8             bne      $ec37 ; $EC37=loc_EC37
EC3F:  97 8A             staa     $8a
EC41:  B7 91 28          staa     $9128
EC44:  13 D8 08 05       brclr    $d8, #8, $ec4d ; $EC4D=loc_EC4D
EC48:  97 D8             staa     $d8
EC4A:  7E EF 28          jmp      $ef28 ; $EF28=loc_EF28

loc_EC4D:
EC4D:  C6 00             ldab     #0 ; xrefs $EBEB:branch, $EC31:branch, $EC44:branch
EC4F:  F7 20 AA          stab     $20aa
EC52:  7F 20 B0          clr      $20b0
EC55:  7E EE E7          jmp      $eee7 ; $EEE7=loc_EEE7

loc_EC58:
EC58:  C6 01             ldab     #1 ; xrefs $EBF2:branch
EC5A:  F7 20 AA          stab     $20aa
EC5D:  D6 90             ldab     $90
EC5F:  27 03             beq      $ec64 ; $EC64=loc_EC64
EC61:  7E EE E7          jmp      $eee7 ; $EEE7=loc_EEE7

loc_EC64:
EC64:  12 D8 01 03       brset    $d8, #1, $ec6b ; $EC6B=loc_EC6B | xrefs $EC5F:branch
EC68:  7E EF 28          jmp      $ef28 ; $EF28=loc_EF28

loc_EC6B:
EC6B:  13 D8 02 03       brclr    $d8, #2, $ec72 ; $EC72=loc_EC72 | xrefs $EC64:branch
EC6F:  7E ED 41          jmp      $ed41 ; $ED41=loc_ED41

loc_EC72:
EC72:  FC 20 AC          ldd      $20ac ; xrefs $EC6B:branch
EC75:  18 FE 25 AA       ldy      $25aa
EC79:  18 FF 25 BA       sty      $25ba
EC7D:  18 FE 25 C1       ldy      $25c1
EC81:  18 FF 25 BF       sty      $25bf
EC85:  BD EF C8          jsr      $efc8 ; $EFC8=sub_EFC8
EC88:  23 28             bls      $ecb2 ; $ECB2=loc_ECB2
EC8A:  FC 20 AC          ldd      $20ac
EC8D:  18 FE 25 AA       ldy      $25aa
EC91:  18 FF 25 BA       sty      $25ba
EC95:  18 FE 25 BD       ldy      $25bd
EC99:  18 FF 25 BF       sty      $25bf
EC9D:  BD EF C8          jsr      $efc8 ; $EFC8=sub_EFC8
ECA0:  22 03             bhi      $eca5 ; $ECA5=loc_ECA5
ECA2:  7E ED 25          jmp      $ed25 ; $ED25=loc_ED25

loc_ECA5:
ECA5:  7F 25 B7          clr      $25b7 ; xrefs $ECA0:branch
ECA8:  13 D8 04 79       brclr    $d8, #4, $ed25 ; $ED25=loc_ED25
ECAC:  15 D8 04          bclr     $d8, #4
ECAF:  7E ED 32          jmp      $ed32 ; $ED32=loc_ED32

loc_ECB2:
ECB2:  12 D8 04 46       brset    $d8, #4, $ecfc ; $ECFC=loc_ECFC | xrefs $EC88:branch
ECB6:  12 A9 40 6B       brset    $a9, #64, $ed25 ; $00A9=operating_mode_flags, $ED25=loc_ED25
ECBA:  7C 25 B7          inc      $25b7
ECBD:  CE 00 72          ldx      #114

loc_ECC0:
ECC0:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0 | xrefs $ECE2:branch
ECC3:  1A B3 20 AC       cpd      $20ac
ECC7:  27 0A             beq      $ecd3 ; $ECD3=loc_ECD3
ECC9:  B6 25 B7          ldaa     $25b7
ECCC:  B1 91 29          cmpa     $9129
ECCF:  24 13             bcc      $ece4 ; $ECE4=loc_ECE4
ECD1:  20 52             bra      $ed25 ; $ED25=loc_ED25

loc_ECD3:
ECD3:  BD EF B6          jsr      $efb6 ; $EFB6=sub_EFB6 | xrefs $ECC7:branch
ECD6:  B1 91 24          cmpa     $9124
ECD9:  25 09             bcs      $ece4 ; $ECE4=loc_ECE4
ECDB:  8C 00 88          cpx      #136
ECDE:  27 45             beq      $ed25 ; $ED25=loc_ED25
ECE0:  08                inx      
ECE1:  08                inx      
ECE2:  20 DC             bra      $ecc0 ; $ECC0=loc_ECC0

loc_ECE4:
ECE4:  14 D8 04          bset     $d8, #4 ; xrefs $ECCF:branch, $ECD9:branch
ECE7:  7F 25 B7          clr      $25b7
ECEA:  CC 00 00          ldd      #0
ECED:  FD 25 AC          std      $25ac
ECF0:  FD 25 AF          std      $25af
ECF3:  B7 25 AE          staa     $25ae
ECF6:  B7 25 B1          staa     $25b1
ECF9:  FD 25 BD          std      $25bd

loc_ECFC:
ECFC:  CE 25 AC          ldx      #9644 ; xrefs $ECB2:branch

loc_ECFF:
ECFF:  EC 00             ldd      0, x ; xrefs $ED30:branch
ED01:  26 13             bne      $ed16 ; $ED16=loc_ED16
ED03:  FC 20 AC          ldd      $20ac
ED06:  ED 00             std      0, x
ED08:  FC 20 AE          ldd      $20ae
ED0B:  1A B3 25 BD       cpd      $25bd
ED0F:  23 14             bls      $ed25 ; $ED25=loc_ED25
ED11:  FD 25 BD          std      $25bd
ED14:  20 0F             bra      $ed25 ; $ED25=loc_ED25

loc_ED16:
ED16:  1A B3 20 AC       cpd      $20ac ; xrefs $ED01:branch
ED1A:  26 0C             bne      $ed28 ; $ED28=loc_ED28
ED1C:  A6 02             ldaa     2, x
ED1E:  B1 91 24          cmpa     $9124
ED21:  24 02             bcc      $ed25 ; $ED25=loc_ED25
ED23:  6C 02             inc      2, x

loc_ED25:
ED25:  7E EE 74          jmp      $ee74 ; $EE74=loc_EE74 | xrefs $ECA2:jump, $ECA8:branch, $ECB6:branch, $ECD1:branch, $ECDE:branch, $ED0F:branch, $ED14:branch, $ED21:branch, +1 more

loc_ED28:
ED28:  8C 25 AF          cpx      #9647 ; xrefs $ED1A:branch
ED2B:  27 F8             beq      $ed25 ; $ED25=loc_ED25
ED2D:  CE 25 AF          ldx      #9647
ED30:  20 CD             bra      $ecff ; $ECFF=loc_ECFF

loc_ED32:
ED32:  FC 25 AA          ldd      $25aa ; xrefs $ECAF:jump
ED35:  1A B3 25 AC       cpd      $25ac
ED39:  23 06             bls      $ed41 ; $ED41=loc_ED41
ED3B:  1A B3 25 AF       cpd      $25af
ED3F:  22 17             bhi      $ed58 ; $ED58=loc_ED58

loc_ED41:
ED41:  F6 91 27          ldab     $9127 ; xrefs $EC6F:jump, $ED39:branch
ED44:  B6 25 BE          ldaa     $25be
ED47:  3D                mul      
ED48:  8F                xgdx     
ED49:  3C                pshx     
ED4A:  30                tsx      
ED4B:  FC 25 AA          ldd      $25aa
ED4E:  B3 20 AC          subd     $20ac
ED51:  1A A3 00          cpd      0, x
ED54:  18 38             puly     
ED56:  2C 05             bge      $ed5d ; $ED5D=loc_ED5D

loc_ED58:
ED58:  15 D8 02          bclr     $d8, #2 ; xrefs $ED3F:branch
ED5B:  20 34             bra      $ed91 ; $ED91=loc_ED91

loc_ED5D:
ED5D:  12 D8 02 05       brset    $d8, #2, $ed66 ; $ED66=loc_ED66 | xrefs $ED56:branch
ED61:  14 D8 02          bset     $d8, #2
ED64:  20 2B             bra      $ed91 ; $ED91=loc_ED91

loc_ED66:
ED66:  15 D8 02          bclr     $d8, #2 ; xrefs $ED5D:branch
ED69:  18 CE 00 00       ldy      #0
ED6D:  B6 25 AE          ldaa     $25ae
ED70:  F6 25 B1          ldab     $25b1
ED73:  B1 91 23          cmpa     $9123
ED76:  25 0A             bcs      $ed82 ; $ED82=loc_ED82
ED78:  C1 03             cmpb     #3
ED7A:  24 18             bcc      $ed94 ; $ED94=loc_ED94
ED7C:  18 FF 25 AF       sty      $25af
ED80:  20 12             bra      $ed94 ; $ED94=loc_ED94

loc_ED82:
ED82:  F1 91 23          cmpb     $9123 ; xrefs $ED76:branch
ED85:  25 0A             bcs      $ed91 ; $ED91=loc_ED91
ED87:  81 03             cmpa     #3
ED89:  24 09             bcc      $ed94 ; $ED94=loc_ED94
ED8B:  18 FF 25 AC       sty      $25ac
ED8F:  20 03             bra      $ed94 ; $ED94=loc_ED94

loc_ED91:
ED91:  7E EE 74          jmp      $ee74 ; $EE74=loc_EE74 | xrefs $ED5B:branch, $ED64:branch, $ED85:branch

loc_ED94:
ED94:  BD EF FF          jsr      $efff ; $EFFF=sub_EFFF | xrefs $ED7A:branch, $ED80:branch, $ED89:branch, $ED8F:branch
ED97:  D1 8A             cmpb     $8a
ED99:  27 06             beq      $eda1 ; $EDA1=loc_EDA1
ED9B:  14 D8 08          bset     $d8, #8
ED9E:  7E EE 74          jmp      $ee74 ; $EE74=loc_EE74

loc_EDA1:
EDA1:  18 CE 25 AC       ldy      #9644 ; xrefs $ED99:branch

loc_EDA5:
EDA5:  18 EC 00          ldd      0, y ; xrefs $EE6C:jump
EDA8:  26 03             bne      $edad ; $EDAD=loc_EDAD
EDAA:  7E EE 62          jmp      $ee62 ; $EE62=loc_EE62

loc_EDAD:
EDAD:  1A B3 91 25       cpd      $9125 ; xrefs $EDA8:branch
EDB1:  25 08             bcs      $edbb ; $EDBB=loc_EDBB
EDB3:  CE 00 72          ldx      #114
EDB6:  CC 00 78          ldd      #120
EDB9:  20 06             bra      $edc1 ; $EDC1=loc_EDC1

loc_EDBB:
EDBB:  CE 00 7A          ldx      #122 ; xrefs $EDB1:branch
EDBE:  CC 00 88          ldd      #136

loc_EDC1:
EDC1:  FF 25 C5          stx      $25c5 ; xrefs $EDB9:branch
EDC4:  FD 25 C7          std      $25c7

loc_EDC7:
EDC7:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0 | xrefs $EDDD:branch
EDCA:  18 EC 00          ldd      0, y
EDCD:  1A B3 25 BA       cpd      $25ba
EDD1:  24 0C             bcc      $eddf ; $EDDF=loc_EDDF
EDD3:  BC 25 C7          cpx      $25c7
EDD6:  26 03             bne      $eddb ; $EDDB=loc_EDDB
EDD8:  7E EE 4F          jmp      $ee4f ; $EE4F=loc_EE4F

loc_EDDB:
EDDB:  08                inx       ; xrefs $EDD6:branch
EDDC:  08                inx      
EDDD:  20 E8             bra      $edc7 ; $EDC7=loc_EDC7

loc_EDDF:
EDDF:  26 1C             bne      $edfd ; $EDFD=loc_EDFD | xrefs $EDD1:branch

loc_EDE1:
EDE1:  BD EF B6          jsr      $efb6 ; $EFB6=sub_EFB6 | xrefs $EDF8:branch
EDE4:  BD EF D4          jsr      $efd4 ; $EFD4=sub_EFD4
EDE7:  BC 25 C7          cpx      $25c7
EDEA:  27 0E             beq      $edfa ; $EDFA=loc_EDFA
EDEC:  08                inx      
EDED:  08                inx      
EDEE:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0
EDF1:  18 EC 00          ldd      0, y
EDF4:  1A B3 25 BA       cpd      $25ba
EDF8:  27 E7             beq      $ede1 ; $EDE1=loc_EDE1

loc_EDFA:
EDFA:  7E EE 62          jmp      $ee62 ; $EE62=loc_EE62 | xrefs $EDEA:branch

loc_EDFD:
EDFD:  FC 25 BD          ldd      $25bd ; xrefs $EDDF:branch
EE00:  FD 25 BF          std      $25bf
EE03:  18 EC 00          ldd      0, y
EE06:  BD EF C8          jsr      $efc8 ; $EFC8=sub_EFC8
EE09:  23 52             bls      $ee5d ; $EE5D=loc_EE5D
EE0B:  FF 25 B8          stx      $25b8
EE0E:  BC 25 C5          cpx      $25c5
EE11:  27 0D             beq      $ee20 ; $EE20=loc_EE20
EE13:  09                dex      
EE14:  09                dex      
EE15:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0
EE18:  18 EC 00          ldd      0, y
EE1B:  BD EF C8          jsr      $efc8 ; $EFC8=sub_EFC8
EE1E:  23 3D             bls      $ee5d ; $EE5D=loc_EE5D

loc_EE20:
EE20:  18 3C             pshy      ; xrefs $EE11:branch
EE22:  18 EE 00          ldy      0, y
EE25:  18 3C             pshy     
EE27:  18 3C             pshy     
EE29:  FE 25 B8          ldx      $25b8

loc_EE2C:
EE2C:  1A EE 00          ldy      0, x ; xrefs $EE36:branch
EE2F:  18 3C             pshy     
EE31:  08                inx      
EE32:  08                inx      
EE33:  BC 25 C7          cpx      $25c7
EE36:  26 F4             bne      $ee2c ; $EE2C=loc_EE2C
EE38:  18 38             puly     
EE3A:  FE 25 C7          ldx      $25c7

loc_EE3D:
EE3D:  18 38             puly      ; xrefs $EE49:branch
EE3F:  1A EF 00          sty      0, x
EE42:  BC 25 B8          cpx      $25b8
EE45:  27 04             beq      $ee4b ; $EE4B=loc_EE4B
EE47:  09                dex      
EE48:  09                dex      
EE49:  20 F2             bra      $ee3d ; $EE3D=loc_EE3D

loc_EE4B:
EE4B:  18 38             puly      ; xrefs $EE45:branch
EE4D:  20 13             bra      $ee62 ; $EE62=loc_EE62

loc_EE4F:
EE4F:  FC 25 BD          ldd      $25bd ; xrefs $EDD8:jump
EE52:  FD 25 BF          std      $25bf
EE55:  18 EC 00          ldd      0, y
EE58:  BD EF C8          jsr      $efc8 ; $EFC8=sub_EFC8
EE5B:  22 05             bhi      $ee62 ; $EE62=loc_EE62

loc_EE5D:
EE5D:  18 EC 00          ldd      0, y ; xrefs $EE09:branch, $EE1E:branch
EE60:  ED 00             std      0, x

loc_EE62:
EE62:  18 8C 25 AF       cpy      #9647 ; xrefs $EDAA:jump, $EDFA:jump, $EE4D:branch, $EE5B:branch
EE66:  27 07             beq      $ee6f ; $EE6F=loc_EE6F
EE68:  18 CE 25 AF       ldy      #9647
EE6C:  7E ED A5          jmp      $eda5 ; $EDA5=loc_EDA5

loc_EE6F:
EE6F:  BD EF FF          jsr      $efff ; $EFFF=sub_EFFF | xrefs $EE66:branch
EE72:  D7 8A             stab     $8a

loc_EE74:
EE74:  18 FE 20 AC       ldy      $20ac ; xrefs $ED25:jump, $ED91:jump, $ED9E:jump
EE78:  CE 00 72          ldx      #114

loc_EE7B:
EE7B:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0 | xrefs $EE8B:jump
EE7E:  18 BC 25 BA       cpy      $25ba
EE82:  27 34             beq      $eeb8 ; $EEB8=loc_EEB8
EE84:  8C 00 88          cpx      #136
EE87:  27 05             beq      $ee8e ; $EE8E=loc_EE8E
EE89:  08                inx      
EE8A:  08                inx      
EE8B:  7E EE 7B          jmp      $ee7b ; $EE7B=loc_EE7B

loc_EE8E:
EE8E:  F6 20 AB          ldab     $20ab ; xrefs $EE87:branch
EE91:  27 54             beq      $eee7 ; $EEE7=loc_EEE7
EE93:  C1 01             cmpb     #1
EE95:  27 0F             beq      $eea6 ; $EEA6=loc_EEA6
EE97:  58                aslb     
EE98:  58                aslb     
EE99:  4F                clra     
EE9A:  C3 00 72          addd     #114
EE9D:  8F                xgdx     
EE9E:  BD EF E0          jsr      $efe0 ; $EFE0=sub_EFE0
EEA1:  24 4B             bcc      $eeee ; $EEEE=loc_EEEE
EEA3:  7E EE E7          jmp      $eee7 ; $EEE7=loc_EEE7

loc_EEA6:
EEA6:  CE 00 72          ldx      #114 ; xrefs $EE95:branch
EEA9:  BD EF E0          jsr      $efe0 ; $EFE0=sub_EFE0
EEAC:  24 40             bcc      $eeee ; $EEEE=loc_EEEE
EEAE:  08                inx      
EEAF:  08                inx      
EEB0:  BD EF E0          jsr      $efe0 ; $EFE0=sub_EFE0
EEB3:  24 39             bcc      $eeee ; $EEEE=loc_EEEE
EEB5:  7E EE E7          jmp      $eee7 ; $EEE7=loc_EEE7

loc_EEB8:
EEB8:  8C 00 7A          cpx      #122 ; xrefs $EE82:branch
EEBB:  24 04             bcc      $eec1 ; $EEC1=loc_EEC1
EEBD:  C6 01             ldab     #1
EEBF:  20 06             bra      $eec7 ; $EEC7=loc_EEC7

loc_EEC1:
EEC1:  8F                xgdx      ; xrefs $EEBB:branch
EEC2:  83 00 72          subd     #114
EEC5:  54                lsrb     
EEC6:  54                lsrb     

loc_EEC7:
EEC7:  13 A9 40 1D       brclr    $a9, #64, $eee8 ; $00A9=operating_mode_flags, $EEE8=loc_EEE8 | xrefs $EEBF:branch
EECB:  B6 20 AB          ldaa     $20ab
EECE:  26 18             bne      $eee8 ; $EEE8=loc_EEE8
EED0:  F1 25 C4          cmpb     $25c4
EED3:  27 08             beq      $eedd ; $EEDD=loc_EEDD
EED5:  B6 91 22          ldaa     $9122
EED8:  B7 25 C3          staa     $25c3
EEDB:  20 0E             bra      $eeeb ; $EEEB=loc_EEEB

loc_EEDD:
EEDD:  B6 25 C3          ldaa     $25c3 ; xrefs $EED3:branch
EEE0:  27 06             beq      $eee8 ; $EEE8=loc_EEE8
EEE2:  7A 25 C3          dec      $25c3
EEE5:  20 07             bra      $eeee ; $EEEE=loc_EEEE

loc_EEE7:
EEE7:  5F                clrb      ; xrefs $EC55:jump, $EC61:jump, $EE91:branch, $EEA3:jump, $EEB5:jump

loc_EEE8:
EEE8:  F7 20 AB          stab     $20ab ; xrefs $EEC7:branch, $EECE:branch, $EEE0:branch

loc_EEEB:
EEEB:  F7 25 C4          stab     $25c4 ; xrefs $EEDB:branch

loc_EEEE:
EEEE:  15 D8 01          bclr     $d8, #1 ; xrefs $EEA1:branch, $EEAC:branch, $EEB3:branch, $EEE5:branch
EEF1:  96 90             ldaa     $90
EEF3:  26 07             bne      $eefc ; $EEFC=loc_EEFC
EEF5:  B6 20 AB          ldaa     $20ab
EEF8:  27 11             beq      $ef0b ; $EF0B=loc_EF0B
EEFA:  20 0A             bra      $ef06 ; $EF06=loc_EF06

loc_EEFC:
EEFC:  B6 20 2D          ldaa     $202d ; xrefs $EEF3:branch
EEFF:  26 0A             bne      $ef0b ; $EF0B=loc_EF0B
EF01:  B6 20 AA          ldaa     $20aa
EF04:  27 05             beq      $ef0b ; $EF0B=loc_EF0B

loc_EF06:
EF06:  14 D8 20          bset     $d8, #32 ; xrefs $EEFA:branch
EF09:  20 03             bra      $ef0e ; $EF0E=loc_EF0E

loc_EF0B:
EF0B:  15 D8 20          bclr     $d8, #32 ; xrefs $EEF8:branch, $EEFF:branch, $EF04:branch

loc_EF0E:
EF0E:  B6 91 21          ldaa     $9121 ; xrefs $EF09:branch
EF11:  27 12             beq      $ef25 ; $EF25=loc_EF25
EF13:  96 90             ldaa     $90
EF15:  26 0E             bne      $ef25 ; $EF25=loc_EF25
EF17:  12 27 10 0A       brset    $27, #16, $ef25 ; $EF25=loc_EF25
EF1B:  12 27 80 06       brset    $27, #-128, $ef25 ; $EF25=loc_EF25
EF1F:  14 D8 10          bset     $d8, #16
EF22:  7E EF 28          jmp      $ef28 ; $EF28=loc_EF28

loc_EF25:
EF25:  15 D8 10          bclr     $d8, #16 ; xrefs $EF11:branch, $EF15:branch, $EF17:branch, $EF1B:branch

loc_EF28:
EF28:  39                rts       ; xrefs $EBCF:jump, $EC4A:jump, $EC68:jump, $EF22:jump

; ---- unreached/data gap $EF29-$EF29 ----

        .org $EF2A

sub_EF2A:
EF2A:  12 D8 80 41       brset    $d8, #-128, $ef6f ; $EF6F=loc_EF6F | xrefs $730F:call
EF2E:  B6 20 A9          ldaa     $20a9
EF31:  81 FF             cmpa     #-1
EF33:  27 03             beq      $ef38 ; $EF38=loc_EF38
EF35:  7C 20 A9          inc      $20a9

loc_EF38:
EF38:  B6 20 AA          ldaa     $20aa ; xrefs $EF33:branch
EF3B:  26 04             bne      $ef41 ; $EF41=loc_EF41
EF3D:  C6 00             ldab     #0
EF3F:  20 25             bra      $ef66 ; $EF66=loc_EF66

loc_EF41:
EF41:  7C 25 B5          inc      $25b5 ; xrefs $EF3B:branch
EF44:  B6 25 B5          ldaa     $25b5
EF47:  81 08             cmpa     #8
EF49:  26 24             bne      $ef6f ; $EF6F=loc_EF6F
EF4B:  7F 25 B5          clr      $25b5
EF4E:  B6 25 B3          ldaa     $25b3
EF51:  C6 5C             ldab     #92
EF53:  3D                mul      
EF54:  8F                xgdx     
EF55:  B6 25 B4          ldaa     $25b4
EF58:  C6 5C             ldab     #92
EF5A:  3D                mul      
EF5B:  89 00             adca     #0
EF5D:  16                tab      
EF5E:  3A                abx      
EF5F:  8F                xgdx     
EF60:  05                asld     
EF61:  4D                tsta     
EF62:  27 02             beq      $ef66 ; $EF66=loc_EF66
EF64:  C6 FF             ldab     #-1

loc_EF66:
EF66:  F7 20 B0          stab     $20b0 ; xrefs $EF3F:branch, $EF62:branch
EF69:  CC 00 00          ldd      #0
EF6C:  FD 25 B3          std      $25b3

loc_EF6F:
EF6F:  39                rts       ; xrefs $EF2A:branch, $EF49:branch

; ---- unreached/data gap $EF70-$EF70 ----

        .org $EF71

sub_EF71:
EF71:  CC 00 00          ldd      #0 ; xrefs $B8E0:call
EF74:  B7 20 AA          staa     $20aa
EF77:  B7 20 AB          staa     $20ab
EF7A:  B7 20 B0          staa     $20b0

sub_EF7D:
EF7D:  FD 25 B3          std      $25b3 ; xrefs $EBD9:call
EF80:  7F 25 B5          clr      $25b5
EF83:  97 D8             staa     $d8
EF85:  F6 91 21          ldab     $9121
EF88:  27 2B             beq      $efb5 ; $EFB5=loc_EFB5
EF8A:  D6 90             ldab     $90
EF8C:  26 27             bne      $efb5 ; $EFB5=loc_EFB5
EF8E:  B7 25 B6          staa     $25b6
EF91:  B7 25 B7          staa     $25b7
EF94:  B7 25 B2          staa     $25b2
EF97:  5F                clrb     
EF98:  FD 20 AC          std      $20ac
EF9B:  FD 25 AA          std      $25aa
EF9E:  FD 20 AE          std      $20ae
EFA1:  FD 25 C1          std      $25c1
EFA4:  FD 25 BD          std      $25bd
EFA7:  86 04             ldaa     #4
EFA9:  B7 10 23          staa     $1023 ; $1023=TFLG1
EFAC:  CE 10 00          ldx      #4096
EFAF:  1C 21 10          bset     33, x; #16
EFB2:  1C 22 04          bset     34, x; #4

loc_EFB5:
EFB5:  39                rts       ; xrefs $EF88:branch, $EF8C:branch

sub_EFB6:
EFB6:  A6 00             ldaa     0, x ; xrefs $ECD3:call, $EDE1:call
EFB8:  44                lsra     
EFB9:  44                lsra     
EFBA:  44                lsra     
EFBB:  44                lsra     
EFBC:  B7 25 BC          staa     $25bc
EFBF:  39                rts      

sub_EFC0:
EFC0:  EC 00             ldd      0, x ; xrefs $EBFE:call, $EC05:call, $ECC0:call, $EDC7:call, $EDEE:call, $EE15:call, $EE7B:call, $EFE0:call, +1 more
EFC2:  84 0F             anda     #15
EFC4:  FD 25 BA          std      $25ba
EFC7:  39                rts      

sub_EFC8:
EFC8:  B3 25 BA          subd     $25ba ; xrefs $EC85:call, $EC9D:call, $EE06:call, $EE1B:call, $EE58:call
EFCB:  2A 02             bpl      $efcf ; $EFCF=loc_EFCF
EFCD:  43                coma     
EFCE:  50                negb     

loc_EFCF:
EFCF:  1A B3 25 BF       cpd      $25bf ; xrefs $EFCB:branch
EFD3:  39                rts      

sub_EFD4:
EFD4:  B1 91 24          cmpa     $9124 ; xrefs $EDE4:call
EFD7:  24 06             bcc      $efdf ; $EFDF=loc_EFDF
EFD9:  86 10             ldaa     #16
EFDB:  AB 00             adda     0, x
EFDD:  A7 00             staa     0, x

loc_EFDF:
EFDF:  39                rts       ; xrefs $EFD7:branch

sub_EFE0:
EFE0:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0 | xrefs $EE9E:call, $EEA9:call, $EEB0:call
EFE3:  F3 20 AE          addd     $20ae
EFE6:  1A B3 20 AC       cpd      $20ac
EFEA:  25 11             bcs      $effd ; $EFFD=loc_EFFD
EFEC:  08                inx      
EFED:  08                inx      
EFEE:  BD EF C0          jsr      $efc0 ; $EFC0=sub_EFC0
EFF1:  B3 20 AE          subd     $20ae
EFF4:  1A B3 20 AC       cpd      $20ac
EFF8:  22 03             bhi      $effd ; $EFFD=loc_EFFD
EFFA:  0C                clc      
EFFB:  20 01             bra      $effe ; $EFFE=loc_EFFE

loc_EFFD:
EFFD:  0D                sec       ; xrefs $EFEA:branch, $EFF8:branch

loc_EFFE:
EFFE:  39                rts       ; xrefs $EFFB:branch

sub_EFFF:
EFFF:  CE 00 72          ldx      #114 ; xrefs $EBF4:call, $ED94:call, $EE6F:call
F002:  18 CE 00 00       ldy      #0

loc_F006:
F006:  EC 00             ldd      0, x ; xrefs $F01C:branch

loc_F008:
F008:  1A 83 00 00       cpd      #0 ; xrefs $F013:branch
F00C:  27 07             beq      $f015 ; $F015=loc_F015

loc_F00E:
F00E:  05                asld      ; xrefs $F00F:branch
F00F:  24 FD             bcc      $f00e ; $F00E=loc_F00E
F011:  18 08             iny      
F013:  20 F3             bra      $f008 ; $F008=loc_F008

loc_F015:
F015:  8C 00 88          cpx      #136 ; xrefs $F00C:branch
F018:  27 04             beq      $f01e ; $F01E=loc_F01E
F01A:  08                inx      
F01B:  08                inx      
F01C:  20 E8             bra      $f006 ; $F006=loc_F006

loc_F01E:
F01E:  18 8F             xgdy      ; xrefs $F018:branch
F020:  39                rts      

; ---- ROM vector table ----

FFD6:  A7 DE             .word    $A7DE ; vector_slot_ffd6 -> sub_A7DE
FFD8:  B9 4D             .word    $B94D ; vector_slot_ffd8 -> fault_stop_bit08
FFDA:  B9 4D             .word    $B94D ; vector_slot_ffda -> fault_stop_bit08
FFDC:  73 92             .word    $7392 ; vector_slot_ffdc -> timer_capture_handler
FFDE:  72 CB             .word    $72CB ; vector_slot_ffde -> sub_72CB
FFE0:  58 3A             .word    $583A ; vector_slot_ffe0 -> sub_583A
FFE2:  BC 91             .word    $BC91 ; vector_slot_ffe2 -> sub_BC91
FFE4:  55 65             .word    $5565 ; vector_slot_ffe4 -> sub_5565
FFE6:  7F 33             .word    $7F33 ; vector_slot_ffe6 -> sub_7F33
FFE8:  6F E4             .word    $6FE4 ; vector_slot_ffe8 -> sub_6FE4
FFEA:  E0 E7             .word    $E0E7 ; vector_slot_ffea -> sub_E0E7
FFEC:  93 15             .word    $9315 ; vector_slot_ffec -> sub_9315
FFEE:  EB 37             .word    $EB37 ; vector_slot_ffee -> sub_EB37
FFF0:  95 F3             .word    $95F3 ; vector_fff0 -> interrupt_handler_95f3
FFF2:  64 05             .word    $6405 ; vector_fff2 -> interrupt_handler_6405
FFF4:  B9 4D             .word    $B94D ; vector_fff4 -> fault_stop_bit08
FFF6:  B9 4D             .word    $B94D ; vector_fff6 -> fault_stop_bit08
FFF8:  B9 48             .word    $B948 ; vector_fff8 -> fault_fatal_bit04
FFFA:  B9 3D             .word    $B93D ; vector_fffa -> fault_soft_restart_bit01
FFFC:  B9 42             .word    $B942 ; vector_fffc -> fault_soft_restart_bit02
FFFE:  B8 00             .word    $B800 ; reset_vector -> reset_entry
