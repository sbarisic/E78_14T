;===============================================================================
; Marelli IAW 8P.40 / Peugeot 106 Rallye TU2J2 rough annotated decompile
;===============================================================================
;
; Source BIN: a6f77192-977f-43dd-be49-197eeb17f736.BIN
; SHA-256:    09e5d927bd6951ecf7b57f351ccd5d396dc95c191d12164f71671725b751a681
; Size:       65536 bytes / $10000 / 27C512 EPROM
; Checksum:   $800C=$4A65, $800E=$B59A; pair sum=$FFFF
; Reset vec:  $FFFE=$B800
;
; This is NOT a perfect complete disassembly. It is a working, assembler-like
; notebook for the important strategy paths found so far. Unknown areas are not
; decoded here. Syntax is close to common 68HC11 assemblers but may need small
; edits for a specific assembler.
;
; Key conclusions in this pass:
;   * $2036 is a very-high-confidence RPM-normalized axis built from engine period
;     RAM $00BA through the 24-point period table at $929E.
;   * $2034 is a high-confidence modeled load / air-charge axis used by spark and
;     other maps. The $9187 path can seed the upstream $00D0 -> $00CE -> $2034
;     calculation, so $9187 is best treated as a load-model / air-charge factor.
;   * $2017 plus breakpoints at $9291 form a processed throttle/load-delta axis.
;   * $2044 is an RPM-derived 19-cell 8.8 vector index built from $00D4.
;     It resolves to 400 rpm sites from 0-7200 rpm. $2046 remains a
;     secondary transient/state axis, still physically provisional.
;   * Two temperature/sensor-style axes are now separated:
;       $200A -> $2124 -> $92D9 breakpoints -> $2038/$203A.
;       $2008 -> $2122 -> $92CF breakpoints -> $203C/$203E.
;     By consumer behavior, $203C/$203E is now the best likely CTS/coolant axis
;     and $2038/$203A is the best likely IAT/air-temperature axis. Exact sensor
;     assignment still needs pin/ADC or bench proof.
;   * $200C -> $00CC -> $2040 -> $84E3 -> $2049 is the strongest lambda /
;     closed-loop fuel correction candidate found so far.
;   * $888E/$8970 feed $202B and external bit $1050.04, so $888E is now best
;     treated as idle-air / idle-bypass target, not fuel.
;   * $8010-$8027 is an SPI output pointer frame, not calibration data.
;   * The old $802E fuel/VE hypothesis is demoted: $802E is +3 inside the signed
;     24x9 table at $802B. $821C/$8318 are now the strongest main fuel trim /
;     multiplier candidates, while $00C1/$00C3/$00BC form the strongest fuel
;     pulse/event-width candidate path. The final injector pin/channel still
;     needs hardware proof.
;   * XDF-confirmed/code-referenced table metadata is mirrored here as labels and
;     comments. When a physical role is not yet proven, the label stays generic.
;
;===============================================================================
;                             CPU / MEMORY MODEL
;===============================================================================
;
; Target is Motorola/Freescale 68HC11-family code.
; EPROM logical content starts at $4000; $0000-$3FFF is zero-filled in the file.
; Internal register block is at $1000. RAM symbols below use the firmware's
; observed logical addresses.
;

                ORG     $0000

;-------------------------------------------------------------------------------
; RAM / direct-page variables used in the decoded logic
;-------------------------------------------------------------------------------
RAM_FLAGS_A2            EQU     $00A2
RAM_FLAGS_A3            EQU     $00A3
RAM_FLAGS_A4            EQU     $00A4
RAM_FLAGS_A9            EQU     $00A9
RAM_TIMER_PREV_B8       EQU     $00B8
RAM_ENGINE_PERIOD_BA    EQU     $00BA      ; period-like delta, upstream of RPM axis
RAM_FUEL_EVENT_BC       EQU     $00BC      ; duration/phase candidate derived from $00C3
RAM_FUEL_PREV_BF        EQU     $00BF      ; previous/latched event value near $6Fxx
RAM_FUEL_ACCUM_C1       EQU     $00C1      ; core fuel/charge accumulator candidate
RAM_FUEL_FINAL_C3       EQU     $00C3      ; post-correction fuel/charge value candidate
RAM_LAMBDA_FILTER_CC    EQU     $00CC      ; filtered lambda/O2 candidate
RAM_LOAD_RAW_CE         EQU     $00CE      ; raw load/aircharge word
RAM_LOAD_BYTE_D0        EQU     $00D0      ; load-model/aircharge byte
RAM_SPEED_D4            EQU     $00D4      ; inverse-period / RPM-like word
RAM_TIMER_CAPTURE_D9    EQU     $00D9
RAM_SENSOR_BASE_10      EQU     $0010      ; adaptive/minimum-like baseline area
RAM_SENSOR_BASE_11      EQU     $0011      ; subtracted from $00C9 to form $2017
RAM_SENSOR_PROC_C9      EQU     $00C9      ; processed sensor, probably TPS/load-related

; 68HC11 registers
REG_PORTA               EQU     $1000
REG_CFORC               EQU     $100B      ; compare-force register, OC3 force bit $20
REG_TCNT                EQU     $100E
REG_TIC3                EQU     $1014
REG_TOC1                EQU     $1016      ; OC1 compare, scheduler/phase interrupt
REG_OC_1016             EQU     $1016      ; alias retained for older notes
REG_TOC3                EQU     $101A      ; OC3 compare, pulse edge scheduling candidate
REG_TCTL1               EQU     $1020      ; OC2/OC3 action bits
REG_TMSK1               EQU     $1022      ; timer interrupt mask
REG_TFLG1               EQU     $1023      ; timer flag acknowledge
REG_TFLG2               EQU     $1025
REG_SPI_CTRL            EQU     $1028
REG_SPI_STATUS          EQU     $1029
REG_SPI_DATA            EQU     $102A
REG_ADCTL               EQU     $1030
REG_ADR1                EQU     $1031
REG_ADR2                EQU     $1032
REG_ADR3                EQU     $1033
REG_ADR4                EQU     $1034
REG_COPRST              EQU     $103A
REG_INIT                EQU     $103D
REG_EXT_PORT_1050       EQU     $1050      ; external/ASIC port, idle path toggles bit $04

; RAM $20xx processed channels / axes
RAM_ADC_2007            EQU     $2007
RAM_ADC_2008            EQU     $2008
RAM_ADC_2009            EQU     $2009
RAM_ADC_200A            EQU     $200A
RAM_ADC_200B            EQU     $200B
RAM_ADC_200C            EQU     $200C      ; best lambda/O2 raw input candidate
RAM_ADC_200D            EQU     $200D
RAM_ADC_200E            EQU     $200E
RAM_PROC_2013           EQU     $2013
RAM_AXIS_SRC_2014       EQU     $2014      ; modeled load / air-charge working value for $869A
RAM_THR_DELTA_2017      EQU     $2017      ; max(0, $00C9 - $0011), axis input for $9187
RAM_TRANSIENT_2030      EQU     $2030      ; signed/limited transient working axis
RAM_LOAD_AXIS_2034      EQU     $2034      ; final load/MAP-like 8.8 axis
RAM_RPM_AXIS_2036       EQU     $2036      ; RPM-normalized 8.8 axis
RAM_TEMP_AXIS_A_2038    EQU     $2038      ; temp-like axis from $200A/$2124/$92D9, likely IAT
RAM_IAT_AXIS_2038       EQU     $2038      ; likely inlet-air/air-temp correction axis
RAM_TEMP_AXIS_A2_203A   EQU     $203A      ; doubled $2038; used by $8C7C spark correction
RAM_IAT_AXIS2_203A      EQU     $203A      ; likely IAT companion axis
RAM_TEMP_AXIS_B_203C    EQU     $203C      ; temp-like axis from $2008/$2122/$92CF, likely CTS
RAM_CTS_AXIS_203C       EQU     $203C      ; likely coolant/CTS axis by warmup consumers
RAM_TEMP_AXIS_B2_203E   EQU     $203E      ; doubled $203C; warmup and $8D15 spark correction
RAM_CTS_AXIS2_203E      EQU     $203E      ; likely CTS companion axis
RAM_AXIS_2040           EQU     $2040      ; dynamic axis for phase/deadtime-style support vectors
RAM_LAMBDA_AXIS_2040    EQU     $2040      ; likely lambda/dynamic closed-loop correction axis
RAM_THR_DELTA_AXIS_2042 EQU     $2042      ; $2017 through $9291 breakpoints
RAM_AXIS_2044           EQU     $2044      ; RPM-derived 19-cell vector index, 400 rpm/site
RAM_AXIS_2046           EQU     $2046      ; secondary transient/state axis for $8A0A
RAM_TEMP_RPM_CORR_A_OUT EQU     $204A      ; signed fuel/charge correction output from $802B
RAM_FUEL_CORR_SUM_204B  EQU     $204B      ; correction stack added to $00CE into $00C1
RAM_TEMP_RPM_CORR_B_OUT EQU     $204D      ; signed fuel/charge correction output from $8103
RAM_FUEL_BLEND_204E     EQU     $204E      ; blend/scale word from $204D path
RAM_FUEL_BLEND_204F     EQU     $204F      ; adjacent blend byte used in $00C1 scaling
RAM_FUEL_CORR_2050      EQU     $2050      ; signed correction added with $204A
RAM_FUEL_CORR_2051      EQU     $2051      ; corrected fuel/charge value used near $6F48
RAM_FUEL_MULT_2053      EQU     $2053      ; multiplier/percentage-style correction on $00C1
RAM_FUEL_ADD_2055       EQU     $2055      ; additive fuel/charge correction
RAM_FUEL_ADD_2057       EQU     $2057      ; additive fuel/charge correction
RAM_FUEL_TRIM_2084      EQU     $2084      ; signed trim from $821C/$8318/$83F0
RAM_FUEL_PHASE_2086     EQU     $2086      ; scheduler phase offset from $2040 axis
RAM_IDLE_CURRENT_202B   EQU     $202B      ; idle-air/actuator current target candidate
RAM_IDLE_STEP_TIMER_202C EQU    $202C      ; idle actuator step timer/count candidate
RAM_SPARK_BANK_SEL      EQU     $20B1      ; nonzero => $8A69, zero => $8B41
RAM_VEC_89F3_OUT        EQU     $20BC
RAM_VEC_8A52_OUT        EQU     $20E6      ; output of vector $8A52; used as clamp/limit
RAM_VEC_89C7_OUT        EQU     $20E7
RAM_VEC_89DA_OUT        EQU     $20E8
RAM_TABLE_85BA_OUT      EQU     $2063
RAM_SPARK_ACCUM_2147    EQU     $2147      ; spark-angle accumulator/intermediate
RAM_SPARK_OUT_2148      EQU     $2148
RAM_LIMIT_FLAG_214F     EQU     $214F
RAM_PHASE_OFFSET_21C6   EQU     $21C6      ; phase offset built from $87B1 path
RAM_PERIOD_LIMIT_21C8   EQU     $21C8      ; event period limit / guard
RAM_OC_BASE_21CB        EQU     $21CB      ; timer base captured before TOC3 schedule
RAM_OC_REMAIN_21CD      EQU     $21CD      ; leftover/delay when pulse exceeds period
RAM_ALT_WIDTH_21CF      EQU     $21CF      ; alternate event width for some modes
RAM_CHECKSUM_PTR        EQU     $2188
RAM_CHECKSUM_SUM        EQU     $218A
RAM_DESC_9187           EQU     $218D      ; 7-byte B2D6 descriptor for table $9187
RAM_DESC_SPARK          EQU     $213A      ; 7-byte B2D6 descriptor for spark tables
RAM_DESC_TABLE_869A     EQU     $238A
RAM_TABLE_869A_OUT      EQU     $2391
RAM_TABLE_9073_REF      EQU     $243C
RAM_FILTER_2584         EQU     $2584      ; subtracted from $00C1 correction stack
RAM_SLOW_CORR_2590      EQU     $2590      ; additive correction into $00C1
RAM_ADAPT_2596          EQU     $2596      ; slow adaptation/base used with $204A
RAM_TMP_25A3            EQU     $25A3      ; temp descriptor/accumulator around $E84B/$E927
RAM_CORR_2610           EQU     $2610      ; alternate-bank signed correction term
RAM_SENSOR_FILT_2122    EQU     $2122      ; filtered $2008 path before $92CF lookup
RAM_SENSOR_FILT_2124    EQU     $2124      ; filtered $200A path before $92D9 lookup
RAM_TABLE_888E_OUT      EQU     $2484
RAM_IDLE_TARGET_2483    EQU     $2483
RAM_IDLE_MAP_OUT_2484   EQU     $2484      ; $888E idle target map result
RAM_IDLE_TEMP_CAP_2486  EQU     $2486      ; $8970 CTS-axis idle cap/vector result
RAM_IDLE_SHAPED_2488    EQU     $2488
RAM_IDLE_STATUS_248D    EQU     $248D
RAM_IDLE_STATUS_248E    EQU     $248E
RAM_LAMBDA_FUEL_2049    EQU     $2049      ; $84E3 output applied to $00C1
RAM_TABLE_8E6F_OUT      EQU     $24AB
RAM_TABLE_8F1C_OUT      EQU     $24AC
RAM_TABLE_8F71_OUT      EQU     $24AD
RAM_TABLE_8EC7_OUT      EQU     $24AF

; ROM tables / constants
CAL_SPARK_BANK_SEED     EQU     $800A
CHK_WORD                EQU     $800C
CHK_TARGET              EQU     $800E
TABLE_SPI_FRAME_8010    EQU     $8010      ; pointer frame for SPI output, not calibration
DIAG_EVENT_TABLE_55A0   EQU     $55A0      ; diagnostic/event code table, 18 cells
TABLE_TEMP_RPM_CORR_A_802B EQU  $802B      ; signed 24x9, X=$2038 likely IAT/air-temp, Y=$2036 RPM
TABLE_FUEL_CHARGE_CORR_A_802B EQU $802B    ; alias: feeds $204A -> $204B -> $00C1
TABLE_LEGACY_SLICE_802E EQU     $802E      ; +3 inside $802B; legacy visual probe only
TABLE_LEGACY_BOUNDARY_80EB EQU   $80EB      ; $802B+$C0; signed cross-boundary slice only
TABLE_TEMP_RPM_CORR_B_8103 EQU  $8103      ; signed 24x9, X=$2038 likely IAT/air-temp, Y=$2036 RPM
TABLE_FUEL_CHARGE_CORR_B_8103 EQU $8103    ; alias: feeds $204D -> $204E blend path
TABLE_FUEL_TRIM_ALT_A_81F8 EQU $81F8       ; alternate/special base selected by $E38B
TABLE_FUEL_TRIM_A_821C EQU   $821C         ; signed 24x9, X=$2034 load, Y=$2036 RPM
TABLE_FUEL_TRIM_ALT_B_82F4 EQU $82F4       ; alternate/special base selected by $E38B
TABLE_FUEL_TRIM_B_8318 EQU   $8318         ; signed 24x9 alternate bank, -> $2084
VEC_FUEL_TRIM_RPM_83F0 EQU   $83F0         ; RPM-only signed trim bypass, -> $2084
TABLE_CONF_85BA         EQU     $85BA      ; code-confirmed 24x5, axes $2034/$2036
TABLE_CONF_869A         EQU     $869A      ; code-confirmed 24x9, axes $2014-derived/$2036
TABLE_CONF_87B1         EQU     $87B1      ; code-confirmed 24x9 zero table, axes $2034/$2036
TABLE_CONF_888E         EQU     $888E      ; idle-air / idle-bypass target, axes $2034/$2036
TABLE_IDLE_BASE_888E    EQU     $888E      ; alias: $2484/$202B actuator target path
VEC_89C7_BASE           EQU     $89C7      ; $2044-indexed 19-cell vector
VEC_89DA_BASE           EQU     $89DA      ; $2044-indexed 19-cell vector
SCALAR_BLOCK_89ED       EQU     $89ED      ; code-referenced 1x6 control scalars
VEC_89F3_BASE           EQU     $89F3      ; $2044-indexed 19-cell MOD2-touched vector
TABLE_CONF_8A0A         EQU     $8A0A      ; code-confirmed 5x5, axes $2034/$2046
VEC_8A27_BASE           EQU     $8A27      ; $2044-indexed 19-cell vector
VEC_8A3A_BASE           EQU     $8A3A      ; $2044-indexed 19-cell vector
SCALAR_BLOCK_8A4D       EQU     $8A4D      ; direct scalar/sentinel references
VEC_STRATEGY_8A52       EQU     $8A52      ; $2044-indexed clamp/limit vector, 19 cells
SCALAR_BLOCK_8A65       EQU     $8A65      ; direct scalar references before $8A68
CAL_SPARK_SIGNED_OFFSET EQU     $8A68      ; code-confirmed signed offset byte
TABLE_SPARK_HIGH        EQU     $8A69      ; likely high/default spark, 24x9, raw/2 deg
TABLE_SPARK_LOW         EQU     $8B41      ; likely low/alternate spark, 24x9, raw/2 deg
TABLE_WOT_SPARK         EQU     $8C19      ; 24-point RPM-only spark vector, raw/2 deg
VEC_SPARK_MODE_A_8C31   EQU     $8C31      ; RPM-only special-mode spark vector, raw/2 deg
VEC_SPARK_MODE_B_8C49   EQU     $8C49      ; RPM-only special-mode spark vector, raw/2 deg
VEC_SPARK_MODE_C_8C61   EQU     $8C61      ; RPM-only special-mode spark vector, raw/2 deg
TABLE_SPARK_TEMP_LOAD_A_8C7C EQU $8C7C     ; signed load/temp spark correction, adds to $2147
TABLE_SPARK_TEMP_LOAD_B_8D15 EQU $8D15     ; signed load/temp spark correction, adds to $2147
VEC_SPARK_TEMP_DECAY_8DAE EQU   $8DAE      ; $203E-indexed spark decay/correction vector
TABLE_CONF_8E6F         EQU     $8E6F      ; code-confirmed 17x5 cluster table
TABLE_CONF_8EC7         EQU     $8EC7      ; code-confirmed 17x5 cluster table
TABLE_CONF_8F1C         EQU     $8F1C      ; code-confirmed 17x5 cluster table
TABLE_CONF_8F71         EQU     $8F71      ; code-confirmed 17x5 cluster table
TABLE_CONF_9073         EQU     $9073      ; code-confirmed 11x9 state/ramp table
TABLE_STATE_TRIPLES_9131 EQU    $9131      ; diagnostic/state descriptor triples, 19x3
TABLE_LOAD_FACTOR_9187  EQU     $9187      ; load/air-charge factor, 24x9
AXIS_SHARED_STRIDE_9290 EQU     $9290      ; observed stride/count byte used by some 24x9 users
AXIS_LOAD_DELTA_9291    EQU     $9291      ; 9 breakpoints for $2017 into $9187
AXIS_LOAD_DELTA_COUNT   EQU     $929A      ; count = 9
AXIS_RPM_PERIOD_929E    EQU     $929E      ; 24 period words, 15000000/period ~= RPM
AXIS_RPM_COUNT_92CE     EQU     $92CE      ; count = 24
AXIS_HELPER_92CF        EQU     $92CF      ; code-referenced 9-point helper vector
AXIS_HELPER_92D8_COUNT  EQU     $92D8      ; count = 9 for one $92CF caller
AXIS_HELPER_92D9        EQU     $92D9      ; second 9-point temp-like helper vector, $200A path
AXIS_HELPER_92E2_COUNT  EQU     $92E2      ; count = 9 for the $92D9 caller
VEC_SENSOR_TRANSFER_400E EQU    $400E      ; 160,140,120,100,80,60,40,20,0 display/transfer vector
CAL_OC3_GUARD_8787      EQU     $8787      ; word guard used in OC3 period-fit tests
VEC_IDLE_TEMP_8970      EQU     $8970      ; likely CTS-axis idle target/cap vector
CAL_IDLE_ALT_8967       EQU     $8967
CAL_IDLE_HYST_896D      EQU     $896D
CAL_IDLE_MAX_896E       EQU     $896E
CAL_IDLE_STEP_DELAY_8981 EQU    $8981
CAL_IDLE_TEMP_LIMIT_8E6C EQU    $8E6C
CAL_IDLE_DISABLE_888A   EQU     $888A

; Warmup/transient fuel-support tables identified by targeted tracing.
VEC_WARMUP_C5_A_845B        EQU $845B      ; $203E-indexed -> $00C5, mode dependent
VEC_WARMUP_C5_B_846C        EQU $846C      ; alternate $00C5 vector
VEC_AFTERSTART_TIME_A_847D  EQU $847D      ; $203E-indexed timer/count
VEC_AFTERSTART_TIME_B_848E  EQU $848E
VEC_WARMUP_BLEND_A_849F     EQU $849F
VEC_WARMUP_BLEND_B_84B0     EQU $84B0
VEC_WARMUP_BLEND_C_84C1     EQU $84C1
VEC_WARMUP_BLEND_D_84D2     EQU $84D2
VEC_AXIS2040_SCALE_84E3     EQU $84E3      ; legacy alias for $2040-indexed lambda/fuel vector
VEC_LAMBDA_FUEL_84E3        EQU $84E3      ; likely lambda/closed-loop fuel correction
VEC_TEMPB_SCALE_84F6        EQU $84F6      ; $203C-indexed word table path
VEC_THROTTLEDELTA_8508      EQU $8508      ; $2042-indexed transient vector
VEC_RPM_TRANSIENT_8511      EQU $8511      ; $2036-indexed transient vector
TABLE_TRANSIENT_A_8529      EQU $8529      ; transient word table, X=$2042
VEC_TEMPB_TRANSIENT_853B    EQU $853B      ; $203C-indexed transient scalar
VEC_TEMPB_SCALE_8546        EQU $8546      ; $203C-indexed word table path
VEC_TEMPB_TRANSIENT_8558    EQU $8558
VEC_RPM_TRANSIENT_8561      EQU $8561
TABLE_TRANSIENT_B_8579      EQU $8579      ; transient word table, X=$2042
VEC_TEMPB_TRANSIENT_858B    EQU $858B
VEC_ADDITIVE_ENRICH_A_8596  EQU $8596      ; EB16 helper -> $2055
VEC_ADDITIVE_ENRICH_B_85AF  EQU $85AF      ; EB16 helper -> $2057

; Interpolation helpers
SUB_INTERP_1D           EQU     $B2AB
SUB_INTERP_1D_ALT       EQU     $B2BA
SUB_INTERP_2D           EQU     $B2D6
SUB_INTERP_2D_SIGNED    EQU     $B32B      ; signed 2D interpolation used by $802B/$8103
SUB_AXIS_FROM_BYTE      EQU     $B383      ; monotonic byte breakpoints -> 8.8 index
SUB_AXIS_FROM_PERIOD    EQU     $B3B9      ; period table -> 8.8 RPM index

;===============================================================================
;                              RESET / BOOT FLOW
;===============================================================================

                ORG     $B800
RESET_B800:
; Reset vector points here. Performs RAM/register init, COP setup, and then calls
; many initialization routines before jumping into the main scheduler.
; Only the beginning and the important observed behavior are shown here.

B800:           CLR     $0094            ; reset/fault cause flags
B803:           INC     $008E
B806:           LDS     $916A            ; expected stack top = word at $916A ($27FF)
B809:           LDAA    #$01
B80B:           STAA    REG_INIT         ; map/register setup
B80E:           LDAA    #$BA
B810:           STAA    $1039
B813:           LDAA    #$01
B815:           STAA    $1024
B818:           LDAA    #$FF
B81A:           STAA    $1008
B81D:           LDAB    #$1A
B81F:           STAB    $1009
B822:           LDAA    #$21
B824:           STAA    $103C
B827:           INC     $008F
B82A:           LDAA    #$14
B82C:           STAA    REG_ADCTL
B82F:           LDAA    #$06
B831:           STAA    $1040
B834:           LDAA    #$03
B836:           STAA    $1050
B839:           LDAA    #$55
B83B:           STAA    REG_COPRST
B83E:           LDAA    #$AA
B840:           STAA    REG_COPRST

; Calibration/window copy loop. Source and destination are both logical $8000;
; this likely matters because of ECU memory mapping / overlay behavior.
B843:           LDX     #$8000
B846:           LDY     #$8000
B84A:   .copy:  CPX     #$9315
B84D:           BEQ     .copy_done
B84F:           LDAA    $00,X
B851:           STAA    $00,Y
B854:           INX
B855:           INY
B857:           BRA     .copy
B859: .copy_done:
; ... reset continues with many setup calls:
;     JSR $4017, $4034, $40A8, $409C, $9E98, $EF71, ...
;     JSR $D6AC, $956B, $4421, $E77E, $CB43, $9B61, ...
;     JSR $A6E5, $A696 for SCI/service setup.
;     Runtime eventually enters MAIN_LOOP_D2D9.

;===============================================================================
;                         ADC / SENSOR PRELOAD PATHS
;===============================================================================

                ORG     $4017
ADC_GROUP_A_4017:
; One ADC result group. Copies ADR bytes into RAM channels.
4017:           LDX     #$1000
401A:           BRCLR   REG_ADCTL,#$80,* ; wait/guard pattern in original bytes
401D:           LDAA    REG_ADR1
4020:           STAA    RAM_ADC_2008
4023:           LDAA    REG_ADR3
4026:           STAA    RAM_ADC_200D
4029:           JSR     $4155            ; processing helper for channel group
402C:           LDAA    REG_ADR4
402F:           STAA    RAM_ADC_200A
4032:           RTS

                ORG     $4034
ADC_GROUP_B_4034:
; Alternate ADC result group. $2007 is important: later processing can feed $00C9,
; which then contributes to $2017 = max(0, $00C9 - $0011).
4034:           LDX     #$1000
4037:           BRCLR   REG_ADCTL,#$80,*
403A:           LDAA    REG_ADR2
403D:           STAA    RAM_ADC_200C
4040:           LDAA    REG_ADR3
4043:           STAA    RAM_ADC_2007
4046:           STAA    $2197
4049:           JSR     $5E82
404C:           STAA    RAM_PROC_2013
4059:           LDAA    REG_ADR4
405C:           STAA    RAM_ADC_200E
; ... continues with initialization / filters.

;===============================================================================
;               THROTTLE/LOAD DELTA AXIS SOURCE FOR TABLE $9187
;===============================================================================

                ORG     $41D6
BUILD_DELTA_AXIS_INPUT_41D6:
; Build $2017, the byte input used by $9291 axis breakpoints before the $9187
; load/air-charge factor lookup.
;
;   $2017 = max(0, $00C9 - $0011)
;
; $00C9 is normally derived from the $2007 sensor path around $5EEC-$5F23.
; The subtraction against $0011 suggests a relative throttle/load delta rather
; than a simple absolute MAP value.
41D6:           LDAB    RAM_SENSOR_PROC_C9
41D8:           SUBB    RAM_SENSOR_BASE_11
41DA:           BCC     .non_negative
41DC:           CLRB
41DD: .non_negative:
41DD:           STAB    RAM_THR_DELTA_2017

; Also build a reusable 8.8 index at $2042 using the same $9291 axis.
41E0:           LDX     #AXIS_LOAD_DELTA_9291
41E3:           LDAA    RAM_THR_DELTA_2017
41E6:           LDAB    AXIS_LOAD_DELTA_COUNT
41E9:           JSR     SUB_AXIS_FROM_BYTE
41EC:           STD     $2042
; ... more logic follows.

                ORG     $5EEC
SENSOR_2007_TO_C9_5EEC:
; Partial path showing $2007 contributing to $00C9. This is why the $9187 X axis
; is best described as processed sensor/throttle/load delta until live data or
; further tracing proves the exact sensor.
5EEC:           LDAA    RAM_ADC_2007
; ... filter/state logic omitted ...
5F23:           STAA    RAM_SENSOR_PROC_C9

;===============================================================================
;                 LOAD / AIR-CHARGE FACTOR LOOKUP: TABLE $9187
;===============================================================================

                ORG     $6344
LOOKUP_LOAD_FACTOR_9187:
; XDF: "Load Model / Correction Factor Candidate 24x9 @ 0x9187".
; Code-confirmed structure and MOD2-touched, but physical role is still
; provisional: load-model, air-charge, fuel, or correction factor.
;
; X axis:
;   input byte  = RAM $2017 = max(0, $00C9 - $0011)
;   breakpoints = $9291, count $929A = 9
;   helper      = $B383 -> 8.8 descriptor X index
;
; Y axis:
;   RAM $2036 = RPM-normalized 8.8 index built from period table $929E.
;
; Output:
;   A = interpolated raw byte from table $9187.
;   TAB returns value in B for caller.
; XDF display hypothesis: raw/230. Do not treat as proven main fuel.
;
6344:           LDAA    RAM_THR_DELTA_2017
6347:           LDY     #RAM_DESC_9187
634B:           LDAB    AXIS_LOAD_DELTA_COUNT
634E:           STAB    $06,Y            ; descriptor stride / X count = 9
6351:           LDX     #AXIS_LOAD_DELTA_9291
6354:           JSR     SUB_AXIS_FROM_BYTE
6357:           STD     $00,Y            ; descriptor X integer/fraction
635A:           LDD     RAM_RPM_AXIS_2036
635D:           STD     $02,Y            ; descriptor Y integer/fraction
6360:           LDD     #TABLE_LOAD_FACTOR_9187
6363:           STD     $04,Y            ; descriptor table base
6366:           JSR     SUB_INTERP_2D
6369:           TAB                     ; return result in B
636A:           RTS

                ORG     $5E74
LOAD_FACTOR_TO_FINAL_LOAD_AXIS_5E74:
; One important consumer path: $9187 lookup seeds the later load-axis calculation.
; This shows $9187 is upstream of the final $2034 load/MAP-like axis.
5E74:           JSR     LOOKUP_LOAD_FACTOR_9187
5E77:           STAB    RAM_LOAD_BYTE_D0
5E79:           CLRA
5E7A:           ASLD
5E7B:           ASLD
5E7C:           STD     RAM_LOAD_RAW_CE   ; $00CE = $00D0 << 2

                ORG     $41A1
BUILD_FINAL_LOAD_AXIS_2034:
; Convert raw load/aircharge word to final 8.8 load axis used by spark maps.
;   $2034 = min($00CE << 1, $07FF)
; XDF names this a MAP/load kPa estimate axis and displays spark X labels as
; rounded 0-100 kPa values. Exact ADC transfer remains unproven.
41A1:           LDD     RAM_LOAD_RAW_CE
41A3:           ASLD
41A4:           CPD     #$07FF
41A8:           BLS     .store
41AA:           LDD     #$07FF
41AD: .store:   STD     RAM_LOAD_AXIS_2034
41B0:           RTS

;===============================================================================
;                           RPM AXIS GENERATION
;===============================================================================

                ORG     $7392
CAPTURE_TIMER_7392:
; Capture current timer value into $00D9.
7392:           LDD     REG_TIC3
7395:           STD     RAM_TIMER_CAPTURE_D9
; ... remainder omitted ...

                ORG     $7660
BUILD_ENGINE_PERIOD_7660:
; Build $00BA from timer capture delta.
7660:           LDD     RAM_ENGINE_PERIOD_BA
7662:           STD     $24DB
7667:           LDD     RAM_TIMER_CAPTURE_D9
7669:           SUBD    RAM_TIMER_PREV_B8
766B:           STD     RAM_ENGINE_PERIOD_BA
; ... guard/fallback logic omitted ...

                ORG     $7701
UPDATE_PREVIOUS_CAPTURE_7701:
7701:           STD     RAM_TIMER_PREV_B8
; ... remainder omitted ...

                ORG     $D46D
BUILD_RPM_AXIS_2036:
; Convert period-like $00BA to normalized RPM index $2036 using 24 word breakpoints.
; XDF-confirmed 1x24 period/RPM axis: $929E-$92CD, count $92CE=$18.
; Display labels use 15000000/period, giving about 550-7500 RPM.
D46D:           LDX     #AXIS_RPM_PERIOD_929E
D470:           LDAB    AXIS_RPM_COUNT_92CE
D473:           DECB
D474:           ASLB
D475:           ABX
D476:           CLRA
D477:           LSRB
D478:           XGDX
D47A:           LDD     RAM_ENGINE_PERIOD_BA
D47C:           JSR     SUB_AXIS_FROM_PERIOD
D47F:           STD     RAM_RPM_AXIS_2036

;===============================================================================
;                     19-CELL RPM-DERIVED VECTOR INDEX $2044
;===============================================================================

                ORG     $D482
BUILD_2044_AXIS_D482:
; $2044 indexes the 19-cell vector family at $89C7-$8A67.
; $00D4 is built from engine period $00BA through inverse-period math
; equivalent to roughly 15000000 / period. The code below maps $00D4 to an
; 8.8 index with 400 rpm cell spacing and a 7200 rpm / index-18 cap.
; It is not a vehicle-speed axis and not a spark-load axis.
;
; Pseudocode:
;   if $00D4 >= $1C20:       ; 7200 rpm
;       $2044 = $1200
;   else:
;       $2044 = ($00D4 / 25) << 4
;   integer cell = $2044 >> 8 = rpm / 400
;
D482:           LDD     RAM_SPEED_D4
D484:           CPD     #$1C20
D488:           BCS     .below_limit
D48A:           LDD     #$1200
D48D:           BRA     .store
D48F: .below_limit:
D48F:           LDX     #$0019
D492:           IDIV
D493:           XGDX
D494:           ASLD
D495:           ASLD
D496:           ASLD
D497:           ASLD
D498: .store:   STD     RAM_AXIS_2044
; ... also derives $2046 after this.

;===============================================================================
;                RPM-INDEXED $2044 VECTOR FAMILY / STRATEGY LIMITS
;===============================================================================

                ORG     $BA5D
LOOKUP_2044_VECTOR_FAMILY_BA5D:
; Common 1D vectors indexed by RPM-derived $2044. These are
; strategy/correction vectors.
; XDF-confirmed members include $89C7, $89DA, $89F3, $8A27, $8A3A, and $8A52.
; $89ED-$89F2, $8A4D-$8A51, and $8A65-$8A67 are exposed as scalar blocks where
; direct references treat them separately from the vectors.
; $8A52 output at $20E6 is later used as an upper clamp/limit for several
; accumulated values, so it is not a main fuel or spark curve by itself.
BA5D:           LDD     RAM_AXIS_2044
BA60:           LDY     #VEC_8A27_BASE
BA64:           JSR     SUB_INTERP_1D
BA67:           STAA    $20DD

BA6A:           LDD     RAM_AXIS_2044
BA6D:           LDY     #VEC_89C7_BASE
BA71:           JSR     SUB_INTERP_1D_ALT
BA74:           STAA    RAM_VEC_89C7_OUT

BA77:           LDD     RAM_AXIS_2044
BA7A:           LDY     #VEC_89DA_BASE
BA7E:           JSR     SUB_INTERP_1D
BA81:           STAA    RAM_VEC_89DA_OUT

BA84:           LDD     RAM_AXIS_2044
BA87:           LDY     #VEC_8A3A_BASE
BA8B:           JSR     SUB_INTERP_1D
BA8E:           STAA    $20D4

BA91:           LDD     RAM_AXIS_2044
BA94:           LDY     #VEC_STRATEGY_8A52
BA98:           JSR     SUB_INTERP_1D
BA9B:           STAA    RAM_VEC_8A52_OUT

BAA8:           LDD     RAM_AXIS_2044
BAAB:           LDY     #VEC_89F3_BASE
BAAF:           JSR     SUB_INTERP_1D
BAB2:           STAA    RAM_VEC_89F3_OUT

;===============================================================================
;                         SPARK MAP SELECTION / LOOKUP
;===============================================================================

                ORG     $CBEF
SPARK_BANK_SELECTOR_SEED_CBEF:
; Calibration byte $800A seeds runtime spark-bank selector $20B1.
; Stock $800A=$00; DECA underflows to $FF, so stock selects the nonzero bank.
CBEF:           LDAA    CAL_SPARK_BANK_SEED
CBF2:           BNE     .store_after_decrement
; ... small branch area omitted ...
CBFB:           DECA
CBFC: .store_after_decrement:
CBFC:           STAA    RAM_SPARK_BANK_SEL
CBFF:           RTS

                ORG     $48EE
SPARK_LOOKUP_48EE:
; Main banked spark lookup. XDF-confirmed structure; octane/default naming is a
; strong working label, not fully proven knock/fallback semantics.
;   If RAM $00A9 bit $20 is set, bypasses the 2D banked tables and uses RPM-only
;   vector $8C19.
;   Otherwise uses table $8A69 when $20B1 != 0, or $8B41 when $20B1 == 0.
;   2D axes: X = RAM $2034 MAP/load estimate, Y = RAM $2036 RPM axis.
;   2D and WOT spark values display as raw/2 degrees in the XDF.
;
48EE:           LDD     #$0000
48F1:           STD     RAM_SPARK_ACCUM_2147
48F4:           BRCLR   RAM_FLAGS_A9,#$20,.use_banked_tables
48F8:           LDY     #TABLE_WOT_SPARK
48FC:           LDD     RAM_RPM_AXIS_2036
48FF:           JSR     SUB_INTERP_1D
4902:           BRA     .add_result

4904: .use_banked_tables:
4904:           LDX     #TABLE_SPARK_HIGH
4907:           TST     RAM_SPARK_BANK_SEL
490A:           BNE     .bank_selected
490C:           LDX     #TABLE_SPARK_LOW
490F: .bank_selected:
490F:           LDY     #RAM_DESC_SPARK
4913:           LDD     RAM_LOAD_AXIS_2034
4916:           STD     $00,Y
4919:           LDD     RAM_RPM_AXIS_2036
491C:           STD     $02,Y
491F:           STX     $04,Y
4922:           LDAA    #$09
4924:           STAA    $06,Y
4927:           JSR     SUB_INTERP_2D

492A:           BRCLR   RAM_FLAGS_A2,#$02,.add_result
492E:           LDAB    CAL_SPARK_SIGNED_OFFSET ; optional signed offset byte
4931:           BPL     .store_offset
4933:           COM     RAM_SPARK_ACCUM_2147
4936: .store_offset:
4936:           STAB    RAM_SPARK_OUT_2148
4939: .add_result:
4939:           TAB
493A:           CLRA
493B:           ADDD    RAM_SPARK_ACCUM_2147
493E:           STD     RAM_SPARK_ACCUM_2147
4941:           RTS

;===============================================================================
;                    RPM LIMITER / THRESHOLD HYSTERESIS CANDIDATE
;===============================================================================

                ORG     $6F01
LIMITER_HYSTERESIS_6F01:
; $879E/$87A0 are code-referenced 16-bit thresholds. They compare against the
; engine-period value $00BA and set/clear bit $10 in $00A4. Because period is
; inverse RPM, compare direction must be interpreted carefully.
;
6F01:           LDD     RAM_ENGINE_PERIOD_BA
6F03:           BRCLR   RAM_FLAGS_A4,#$10,.flag_clear_path
6F07:           TST     RAM_LIMIT_FLAG_214F
6F0A:           BEQ     .normal_clear_threshold
6F0C:           CPD     $87A4            ; alternate threshold
6F10:           BRA     .after_clear_cmp
6F12: .normal_clear_threshold:
6F12:           CPD     $87A0
6F16: .after_clear_cmp:
6F16:           BLS     .done_or_branch
6F18:           BCLR    RAM_FLAGS_A4,#$10
6F1B:           BRA     .continue
6F1D: .flag_clear_path:
6F1D:           TST     RAM_LIMIT_FLAG_214F
6F20:           BEQ     .normal_set_threshold
6F22:           CPD     $87A2
6F26:           BRA     .after_set_cmp
6F28: .normal_set_threshold:
6F28:           CPD     $879E
6F2C: .after_set_cmp:
6F2C:           BCC     .set_flag
; ... rest omitted ...
6F33: .set_flag:
6F33:           BSET    RAM_FLAGS_A4,#$10

;===============================================================================
;                              CHECKSUM ROUTINE
;===============================================================================

                ORG     $5AD8
CHECKSUM_SERVICE_5AD8:
; Sums bytes through ROM and compares against $800E. Skips $B600-$B7FF.
; XDF exposes $800C as Checksum Word and $800E as Checksum Complement/target.
; $800C is one's complement of $800E. Any ROM edit outside the skipped region
; requires repairing both big-endian words.
;
; Practical repair formula:
;   sum_without_pair = sum(bytes $4000-$FFFF excluding $800C-$800F)
;   checksum_target  = (sum_without_pair + $01FE) & $FFFF
;   checksum_word    = (~checksum_target) & $FFFF
;   store word at $800C, target at $800E, big-endian.
;
5ADC:           LDX     RAM_CHECKSUM_PTR
5ADF:           LDY     RAM_CHECKSUM_SUM
5AE3:           CPX     #$B600
5AE6:           BCS     .include_byte
5AE8:           CPX     #$B7FF
5AEB:           BLS     .skip_byte
5AED: .include_byte:
5AED:           LDAB    $00,X
5AEF:           ABY
5AF1:           STY     RAM_CHECKSUM_SUM
5AF5: .skip_byte:
5AF5:           DEX
5AF6:           STX     RAM_CHECKSUM_PTR
5AF9:           CPX     #$4000
5AFC:           BCC     CHECKSUM_SERVICE_5AD8+0x40 ; continue later
5AFE:           CPY     CHK_TARGET
5B02:           BNE     .bad
5B04:           BCLR    $0099,#$04
5B07:           BRA     .reset_state
5B09: .bad:     BSET    $0099,#$04
5B0C: .reset_state:
5B0C:           LDD     #$FFFF
5B0F:           STD     RAM_CHECKSUM_PTR
5B12:           LDD     #$0000
5B15:           STD     RAM_CHECKSUM_SUM
5B18:           RTS

;===============================================================================
;                              INTERPOLATION HELPERS
;===============================================================================

                ORG     $B383
AXIS_FROM_BYTE_B383:
; Convert a monotonic byte breakpoint vector into an 8.8 index.
;
; Inputs:
;   A = input byte
;   B = count
;   X = pointer to count breakpoints
; Output:
;   D = 8.8 index, integer in A, fraction in B
;
; Pseudocode:
;   if count == 0: return 0
;   if input <= axis[0]: return 0
;   if input >= axis[count-1]: return (count-1)<<8
;   find i with axis[i] <= input < axis[i+1]
;   frac = ((input-axis[i])*256)/(axis[i+1]-axis[i])
;   return (i<<8)|frac
;
B383:           TSTB
B385:           BNE     .count_nonzero
B387:           CLRA
B388:           BRA     .return_zero
; ... complete helper omitted; logic summarized above.

                ORG     $B3B9
AXIS_FROM_PERIOD_B3B9:
; Converts engine-period word to 8.8 RPM index using descending period words at
; $929E. The breakpoints correspond to about 550-7500 RPM using 15000000/period.
; Full helper omitted here.

                ORG     $B2AB
INTERP_1D_B2AB:
; Signed-aware 1D byte interpolation.
;
; Inputs:
;   Y = vector base
;   D = 8.8 index, A integer, B fraction
; Output:
;   A = table[i] + ((table[i+1]-table[i])*fraction)/256
;
B2AB:           PSHB
B2AC:           TAB
B2AD:           ABY
B2AF:           LDAA    $01,Y
B2B2:           SUBA    $00,Y
; ... slope sign handling, MUL, add base ...
B2D1:           ADDA    $00,Y
B2D4:           RTS

                ORG     $B2D6
INTERP_2D_B2D6:
; Bilinear byte interpolation.
;
; Descriptor at Y:
;   +0 X integer index
;   +1 X fraction
;   +2 Y integer index
;   +3 Y fraction
;   +4/+5 table base pointer
;   +6 row stride / column count
;
; Output:
;   A = bilinear-interpolated byte.
;
B2D6:           LDAB    $06,Y           ; stride
B2D9:           LDAA    $02,Y           ; row integer
B2DC:           MUL
B2DD:           ADDB    $00,Y           ; + column integer
B2E2:           ADDD    $04,Y           ; + base pointer
B2E5:           XGDX                    ; X = cell pointer
; ... interpolate across X and then Y ...
B329:           RTS

;===============================================================================
;                                MAIN LOOP SUMMARY
;===============================================================================

                ORG     $D2D9
MAIN_LOOP_D2D9:
; Scheduler / watchdog / stack-integrity guard. Full body is large; this summary
; gives the observed high-level order.
;
D2D9:           LDD     REG_TCNT
D2DC:           SUBD    $24E7
D2DF:           CPD     $24E5
D2E3:           BCS     .skip_time_update
D2E5:           STD     $24E5
D2E8: .skip_time_update:
D2E8:           LDD     REG_TCNT
D2EB:           STD     $24E7
D2ED:           STS     $24EA
D2F0:           LDX     $24EA
D2F3:           CPX     $916A            ; compare against expected stack top
D2F6:           BNE     .stack_fault
; ... watchdog and periodic calls ...
;
; Important runtime tasks later in this loop:
;   JSR $5AD6      ; checksum service/check
;   JSR $42D0      ; ADC/sensor preprocessing area
;   JSR $4C5B/$4ECD/$9D25/... strategy updates
;   JSR $6344      ; load/air-charge factor lookup in some paths
;   D46D-D47F      ; build RPM axis $2036
;   D482-D498      ; build $2044 vector index
;   many output scheduling routines, including timer compare use around $BC12/$BC90
;   JMP $D2D9      ; loop

;===============================================================================
;                     SENSOR / TEMPERATURE AXIS PRODUCERS
;===============================================================================

                ORG     $431A
BUILD_SENSOR_AXIS_B_431A:
; $2008 path: filter into $2122, map through raw breakpoint vector $92CF, invert
; the 8.8 index, store $203C, and store doubled companion axis $203E. The $400E
; vector is also interpolated into $00CA as a display/transfer-style value.
; By consumer behavior this is now the best likely CTS/coolant axis: warmup,
; afterstart, idle/state, and the $8D15 spark correction all use this family.
; Exact sensor identity remains provisional until harness/ADC proof.
431A:           LDAA    RAM_ADC_2008
433D:           STD     RAM_SENSOR_FILT_2122
4340:           LDX     #AXIS_HELPER_92CF
4343:           LDAB    AXIS_HELPER_92D8_COUNT
4349:           JSR     SUB_AXIS_FROM_BYTE
434F:           LDY     #VEC_SENSOR_TRANSFER_400E
4353:           JSR     SUB_INTERP_1D
4361:           STD     RAM_TEMP_AXIS_B_203C
4364:           ASLD
4365:           STD     RAM_TEMP_AXIS_B2_203E

                ORG     $436A
BUILD_SENSOR_AXIS_A_436A:
; $200A path: filter into $2124, map through raw breakpoint vector $92D9, invert
; the 8.8 index, store $2038, and store doubled companion axis $203A. This is
; the axis used by the signed $802B/$8103 fuel temp/RPM corrections and by the
; $8C7C spark temp/load correction.
; By consumer behavior this is now the best likely IAT/air-temperature axis.
436A:           LDAA    RAM_ADC_200A
438D:           STD     RAM_SENSOR_FILT_2124
4390:           LDX     #AXIS_HELPER_92D9
4393:           LDAB    AXIS_HELPER_92E2_COUNT
4399:           JSR     SUB_AXIS_FROM_BYTE
439F:           LDY     #VEC_SENSOR_TRANSFER_400E
43A3:           JSR     SUB_INTERP_1D
43B1:           STD     RAM_TEMP_AXIS_A_2038
43B4:           ASLD
43B5:           STD     RAM_TEMP_AXIS_A2_203A

;===============================================================================
;                LAMBDA / CLOSED-LOOP FUEL CORRECTION CANDIDATE
;===============================================================================

                ORG     $5B1B
LAMBDA_INPUT_SERVICE_5B1B:
; Best current lambda/O2 input candidate. $200C is checked against calibration
; thresholds around $9267/$9268, diagnostic flags/events are updated, and caller
; $43DC filters the result into $00CC. This is not fully hardware-proven yet,
; but the downstream path reaches the central fuel accumulator.
5B1B:           LDAA    RAM_ADC_200C
5B3B:           CMPA    $9267
5B40:           CMPA    $9268
5B8E:           LDAA    RAM_ADC_200C
5B94:           RTS

                ORG     $43DC
LAMBDA_FILTER_TO_AXIS_43DC:
; $200C result is filtered into $00CC, then $43F3 builds $2040. The current best
; model is:
;   $200C -> $5B1B -> $43DC -> $00CC -> $2040 -> $84E3 -> $2049 -> $00C1.
43DC:           JSR     LAMBDA_INPUT_SERVICE_5B1B
43EE:           JSR     $B42F             ; filtered result into $00CC path

                ORG     $43F3
BUILD_LAMBDA_AXIS_2040_43F3:
; $2040 = max($00CC - $8000, 0) >> 4. This dynamic/lambda axis also indexes
; scheduler/guard vectors $92FA/$877E/$8789, so it is a shared strategy axis.
43F3:           LDD     RAM_LAMBDA_FILTER_CC
43F5:           SUBD    #$8000
43FC:           LSRD
43FD:           LSRD
43FE:           LSRD
43FF:           LSRD
4400:           STD     RAM_LAMBDA_AXIS_2040

                ORG     $E83E
LAMBDA_AXIS_TO_FUEL_CORR_E83E:
; $2040 indexes $84E3 and stores to $2049. $2049 is later applied into $00C1,
; making $84E3 the strongest lambda/closed-loop fuel correction vector candidate.
E83E:           LDD     RAM_LAMBDA_AXIS_2040
E841:           LDY     #VEC_LAMBDA_FUEL_84E3
E845:           JSR     SUB_INTERP_1D
E848:           STAA    RAM_LAMBDA_FUEL_2049

                ORG     $E6A6
APPLY_LAMBDA_FUEL_CORR_E6A6:
; If $2049 is nonzero, helper $E6DA applies a correction to $00C1. This is fuel
; quantity/closed-loop correction, not spark and not injector phase.
E6A6:           LDAA    RAM_LAMBDA_FUEL_2049
E6A9:           BEQ     .no_lambda_corr
E6AD:           JSR     $E6DA
E6B9:           STD     RAM_FUEL_ACCUM_C1
E6C4: .no_lambda_corr:
E6C4:           RTS

;===============================================================================
;                      IDLE-AIR / IDLE-BYPASS ACTUATOR PATH
;===============================================================================

                ORG     $BE65
IDLE_AIR_TARGET_BE65:
; This path moves $888E out of fuel. Normal mode looks up $888E with load/RPM,
; adds/shapes it with likely CTS-axis vector $8970 and idle constants, moves
; $202B one count toward target, and toggles external bit $1050.04. This strongly
; resembles idle stepper / idle-bypass actuator control.
BE65:           LDAA    CAL_IDLE_MAX_896E
BE74:           LDY     #$248F
BE78:           LDD     RAM_LOAD_AXIS_2034
BE7E:           LDD     RAM_RPM_AXIS_2036
BE84:           LDD     #TABLE_IDLE_BASE_888E
BE90:           JSR     SUB_INTERP_2D
BE93:           STAA    RAM_IDLE_MAP_OUT_2484
BE96:           LDY     #VEC_IDLE_TEMP_8970
BE9A:           LDD     RAM_CTS_AXIS2_203E
BE9D:           JSR     SUB_INTERP_1D
BEA0:           STAA    RAM_IDLE_TEMP_CAP_2486
BEE7:           STAB    RAM_IDLE_CURRENT_202B
BEEA:           STAB    RAM_IDLE_TARGET_2483
BEEF:           STAA    RAM_IDLE_STEP_TIMER_202C
BF07:           BCLR    $50,X,#$04        ; external bit $1050.04 clear
BF2D:           BSET    $50,X,#$04        ; external bit $1050.04 set

;===============================================================================
;                    SPI OUTPUT POINTER FRAME, NOT CALIBRATION
;===============================================================================

                ORG     $8010
SPI_OUTPUT_POINTER_FRAME_8010:
; Pointer table consumed by $9F02-$A001. It streams live RAM/status bytes through
; SPI data register $102A, so $8010-$8027 is not a fuel/spark/axis calibration
; block. $8028/$802A are constants, and the true signed fuel table starts $802B.
    FDB $00D0,$00D3,$00CA,$00CB,$00A3,$00B6,$00C9,$20B9
    FDB $00A9,$00A9,$00A9,$00A9

                ORG     $9F02
SPI_OUTPUT_WRITER_9F02:
; Loads the pointers from $8010, reads the pointed live RAM bytes, folds them,
; and writes each byte to SPDR $102A.
9F02:           LDY     #SPI_OUTPUT_POINTER_FRAME_8010
9F37:           STAA    REG_SPI_DATA
9F4B:           LDX     $00,Y
9F4E:           LDAB    $00,X
9F55:           STAB    REG_SPI_DATA

;===============================================================================
;              FUEL / CHARGE CORRECTION AND DURATION CANDIDATE PATH
;===============================================================================

                ORG     $B447
RUNTIME_FUEL_ORDER_B447:
; Main-loop ordering evidence from addendum 2. The loop calls the scheduler and
; fuel calculations in a mode-dependent order:
;   $6EEE scheduler service, $E9A8 state work, $E38B fuel-trim lookup,
;   $6E96 high-load/final publish, then sometimes $6EEE again.
; This places the $E38B/$E5E8/$E6D1 fuel path directly before the output-
; compare scheduler, but physical injector pin assignment remains hardware work.
B447:           JSR     $4292
B44A:           JSR     $B57F
B44D:           JSR     $D0C8
B450:           BRSET   RAM_FLAGS_A3,#$01,$B462
B454:           JSR     FUEL_SCHEDULER_ENTRY_6EEE
B457:           JSR     $E9A8
B45A:           JSR     FUEL_TRIM_LOOKUP_E38B
B45D:           JSR     FUEL_HIGHLOAD_6E96
B460:           BRA     $B46E
B462:           JSR     $E9A8
B465:           JSR     FUEL_TRIM_LOOKUP_E38B
B468:           JSR     FUEL_HIGHLOAD_6E96
B46B:           JSR     FUEL_SCHEDULER_ENTRY_6EEE

                ORG     $E38B
FUEL_TRIM_LOOKUP_E38B:
; Strongest current main fuel trim / multiplier candidate family.
;
; Normal mode:
;   - $20B1 selects signed 24x9 bank $821C or $8318.
;   - X axis = RAM $2034 modeled load / MAP-like axis.
;   - Y axis = RAM $2036 RPM axis.
;   - Signed 2D helper $B32B returns a signed byte stored at $2084.
;
; Bypass/special modes:
;   - $00A9 bit $20 uses RPM-only signed vector $83F0 through helper $B2BA.
;   - low-RPM/special flags select alternate bases $81F8/$82F4. These are
;     documented as alternate code paths, not exposed as normal XDF tune maps.
;
; Consumer:
;   $E627 loads X=$2084 and calls $E715, which applies the signed byte as a
;   proportional correction to central fuel accumulator $00C1.
E38B:           BRCLR   RAM_FLAGS_A9,#$20,$E39B
E38F:           LDD     RAM_RPM_AXIS_2036
E392:           LDY     #VEC_FUEL_TRIM_RPM_83F0
E396:           JSR     $B2BA
E399:           BRA     .store_2084
E39B:           LDX     #TABLE_FUEL_TRIM_A_821C
E39E:           TST     RAM_SPARK_BANK_SEL
E3A1:           BNE     .table_selected
E3A3:           LDX     #TABLE_FUEL_TRIM_B_8318
E3A6: .table_selected:
E3A6:           LDD     RAM_RPM_AXIS_2036
E3A9:           CPD     #$0300
E3AD:           BHI     .build_desc
E3AF:           BRCLR   RAM_FLAGS_A9,#$40,.build_desc
E3B3:           TST     $0090
E3B6:           BEQ     .build_desc
E3B8:           TST     $202D
E3BB:           BNE     .build_desc
E3BD:           LDX     #TABLE_FUEL_TRIM_ALT_A_81F8
E3C0:           TST     RAM_SPARK_BANK_SEL
E3C3:           BNE     .build_desc
E3C5:           LDX     #TABLE_FUEL_TRIM_ALT_B_82F4
E3C8: .build_desc:
E3C8:           LDY     #$259A
E3CC:           STD     $02,Y            ; Y axis = RPM
E3CF:           LDD     RAM_LOAD_AXIS_2034
E3D2:           STD     $00,Y            ; X axis = modeled load / MAP-like
E3D5:           STX     $04,Y            ; selected table base
E3D8:           LDAA    AXIS_SHARED_STRIDE_9290
E3DB:           STAA    $06,Y
E3DE:           JSR     SUB_INTERP_2D_SIGNED
E3E1: .store_2084:
E3E1:           STAA    RAM_FUEL_TRIM_2084

                ORG     $E84B
LOOKUP_FUEL_CHARGE_CORR_E84B:
; Signed 24x9 correction pair. Both use X=$2038 temperature-like axis from the
; $200A -> $2124 -> $92D9 producer and Y=$2036 RPM. $92D9 and $92CF currently
; share the same raw breakpoint values, but the producer paths are distinct.
E84B:           LDY     #RAM_TMP_25A3
E84F:           LDD     RAM_TEMP_AXIS_A_2038
E852:           STD     $00,Y
E855:           LDD     RAM_RPM_AXIS_2036
E858:           STD     $02,Y
E85B:           LDX     #TABLE_FUEL_CHARGE_CORR_A_802B
E85E:           STX     $04,Y
E861:           LDAA    #$09
E863:           STAA    $06,Y
E866:           JSR     SUB_INTERP_2D_SIGNED
E869:           STAA    RAM_TEMP_RPM_CORR_A_OUT

E86C:           LDY     #RAM_TMP_25A3
E870:           LDD     RAM_TEMP_AXIS_A_2038
E873:           STD     $00,Y
E876:           LDD     RAM_RPM_AXIS_2036
E879:           STD     $02,Y
E87C:           LDX     #TABLE_FUEL_CHARGE_CORR_B_8103
E87F:           STX     $04,Y
E882:           LDAA    #$09
E884:           STAA    $06,Y
E887:           JSR     SUB_INTERP_2D_SIGNED
E88A:           STAA    RAM_TEMP_RPM_CORR_B_OUT

                ORG     $E927
BUILD_FUEL_CORR_SUM_E927:
; $204A and $2050 are sign-extended, combined with slow/adaptive terms, doubled,
; optionally adjusted by $2610, and added to $24D9. The result $204B is the
; correction stack later added to raw load/air-charge $00CE.
E927:           CLRA
E928:           LDAB    RAM_TEMP_RPM_CORR_A_OUT
E92B:           BPL     .corr_a_positive
E92D:           COMA                    ; sign extend negative signed byte
E92E: .corr_a_positive:
E92E:           ADDD    RAM_ADAPT_2596
E931:           STD     RAM_TMP_25A3
; ... sign-extend $2050, double, optionally add signed $2610, add $24D9 ...
E956:           ADDD    $24D9
E959:           STD     RAM_FUEL_CORR_SUM_204B

; $204D is sign-extended and combined with direct RAM $0006 plus calibration
; word $8028. Negative values are clamped to zero and stored at $204E/$204F.
E95C:           CLRA
E95D:           LDAB    RAM_TEMP_RPM_CORR_B_OUT
E960:           BPL     .corr_b_positive
E962:           COMA
E963: .corr_b_positive:
E963:           ADDD    $0006
E965:           ADDD    $8028
E968:           BGE     .blend_nonnegative
E96A:           LDD     #$0000
E96D: .blend_nonnegative:
E96D:           STD     RAM_FUEL_BLEND_204E

                ORG     $E5E8
FUEL_CHARGE_ACCUM_E5E8:
; Strongest current fuel/charge time-path candidate:
;   $00C1 = max(0, $00CE + $204B)
; $00CE is raw load/air-charge, while $204B is the signed correction stack fed
; by $802B/$2050/$24D9. This is stronger evidence than the old visual $802E view,
; but it still does not prove the final injector hardware channel.
E5E8:           LDD     RAM_FUEL_CORR_SUM_204B
E5EB:           ADDD    RAM_LOAD_RAW_CE
E5ED:           BGE     .fuel_sum_nonnegative
E5EF:           CLRA
E5F0:           CLRB
E5F1: .fuel_sum_nonnegative:
E5F1:           STD     RAM_FUEL_ACCUM_C1
; $204E/$204F blend with $00C1/$00C2, then the result is limited at $0BB8.

                ORG     $E652
FUEL_CHARGE_LIMITS_E652:
; Additive/subtractive correction stack, saturation, and duration-like cap.
; The cap by engine period $00BA strongly suggests $00C1 is time/duration-like.
E652:           LDD     RAM_FUEL_ACCUM_C1
E654:           ADDD    RAM_FUEL_ADD_2055
E659:           ADDD    RAM_FUEL_ADD_2057
E65E:           ADDD    RAM_SLOW_CORR_2590
E663:           SUBD    RAM_FILTER_2584
; ... clamp to 0..$7D00 ...
E627:           LDX     #RAM_FUEL_TRIM_2084
E62A:           JSR     APPLY_SIGNED_PERCENT_E715
E678:           LDD     RAM_ENGINE_PERIOD_BA
E67A:           CPD     RAM_FUEL_ACCUM_C1
E67D:           BCC     .period_allows
E67F:           STD     RAM_FUEL_ACCUM_C1
; ... apply $2053 multiplier and optional $2049 scaling ...
E6A1:           STD     RAM_FUEL_CORR_2051
E6D1:           LDD     RAM_FUEL_ACCUM_C1
E6D3:           STD     RAM_FUEL_FINAL_C3
E6D5:           JSR     $4405

                ORG     $E715
APPLY_SIGNED_PERCENT_E715:
; Signed proportional correction helper used by $2084.
; X points to a signed byte. Positive values add a proportional amount to
; $00C1/$00C2; negative values subtract it. This proves $2084 is a true fuel/
; charge trim term, not a state flag.
E715:           LDAA    $00C2
E717:           LDAB    $00,X
E719:           BMI     .negative
E71B:           MUL
E71C:           ADCA    #$00
E71E:           STAA    $00FE
E720:           LDAA    RAM_FUEL_ACCUM_C1
E722:           CLRB
E723:           STAB    $00FD
E725:           LDAB    $00,X
E727:           MUL
E728:           ADDD    $00FD
E72A:           ADDD    RAM_FUEL_ACCUM_C1
E72C:           BRA     .store
E72E: .negative:
E72E:           NEGB
E72F:           MUL
E730:           ADCA    #$00
E732:           STAA    $00FE
E734:           LDAA    RAM_FUEL_ACCUM_C1
E736:           CLRB
E737:           STAB    $00FD
E739:           LDAB    $00,X
E73B:           NEGB
E73C:           MUL
E73D:           ADDD    $00FD
E73F:           STD     $00FD
E741:           LDD     RAM_FUEL_ACCUM_C1
E743:           SUBD    $00FD
E745: .store:
E745:           STD     RAM_FUEL_ACCUM_C1
E747:           RTS

                ORG     $6E96
FUEL_HIGHLOAD_6E96:
; High-load/event-width publish path. When enabled, compares $00BF/2 against
; $00C1, optionally looks up $85BA using X=$2034 and Y=$2036, adds the result
; doubled to $00C1, and publishes final fuel/charge value to $00C3. This makes
; $85BA a high-load pulse-extension / duration-support candidate, not a main
; fuel trim table.
6E96:           BRCLR   RAM_FLAGS_A3,#$80,$6EDA
6E9A:           LDD     RAM_FUEL_PREV_BF
6E9C:           LSRD
6E9D:           CPD     RAM_FUEL_ACCUM_C1
6EA0:           BLS     $6ED2
6EA5:           LDY     #$21D8
6EA9:           LDD     RAM_LOAD_AXIS_2034
6EB9:           LDD     RAM_RPM_AXIS_2036
6EBF:           LDX     #TABLE_CONF_85BA
6ECA:           JSR     SUB_INTERP_2D
6ECD:           STAA    RAM_TABLE_85BA_OUT
; ...
6EDD:           LDD     RAM_FUEL_ACCUM_C1
6EE3:           CLRA
6EE4:           LDAB    RAM_TABLE_85BA_OUT
6EE7:           ASLD
6EE8:           ADDD    RAM_FUEL_ACCUM_C1
6EEA:           STD     RAM_FUEL_FINAL_C3
6EEC:           RTS

                ORG     $D5DF
BUILD_EVENT_LIMITS_D5DF:
; Builds $00BF and $2086 from the $2040 axis using 1D tables. $00BF is later
; compared with $00C1/$00C3; $2086 becomes part of the OC3 pulse timing.
D5DF:           LDD     $2040
D5E2:           LDY     #$92FA
D5E6:           JSR     SUB_INTERP_1D
D5F2:           LDY     #$877E
D5F6:           JSR     SUB_INTERP_1D
D5FE:           STD     RAM_FUEL_PREV_BF
D600:           LDX     #$2040
D603:           LDY     #$8789
D607:           JSR     $B26E
D60A:           STD     RAM_FUEL_PHASE_2086

                ORG     $6EEE
FUEL_SCHEDULER_ENTRY_6EEE:
; Scheduler service. If OC1 is enabled, pull TOC1 close to current time; the
; normal path then prepares $00BC from $00C3 and schedules TOC1.
6EEE:           LDX     #REG_PORTA
6EF1:           BRCLR   $22,X,#$80,$6F01
6EF5:           LDD     REG_TCNT
6EF8:           ADDD    #$0004
6EFB:           STD     REG_TOC1

                ORG     $6F48
FUEL_OUTPUT_COMPARE_CANDIDATE_6F48:
; Bridge from fuel/charge value to timer scheduling. This reads $2051 and $00C3,
; derives event width $00BC from $00C3, and schedules OC1/TOC1 at $1016 using
; $21C6+$00B8. OC1 then enters $6FE4 and creates/schedules an OC3 pulse. Strong
; software evidence for fuel pulse timing; exact injector pin remains unproven.
6F48:           LDD     RAM_FUEL_CORR_2051
6F4B:           JSR     $440D
; ...
6F6C:           LDD     RAM_FUEL_FINAL_C3
6F6E:           ASLD
6F6F:           STD     RAM_FUEL_EVENT_BC
; ...
6FC0:           LDD     RAM_PHASE_OFFSET_21C6
6FC3:           ADDD    RAM_TIMER_PREV_B8
6FC5:           STD     REG_TOC1
6FD8:           STAA    REG_TFLG1
6FDE:           BSET    $22,X,#$80        ; enable OC1 interrupt

                ORG     $6FE4
OC1_VECTOR_HANDLER_6FE4:
; Vector $FFE8 points here. OC1 disables itself, prepares OC3 action bits, may
; force an OC3 edge through CFORC, then schedules TOC3 at $101A using $00BC plus
; phase terms. OC1 is therefore the interrupt scheduler, while OC3/PA5 is the
; hardware timed pulse-output path. Software evidence is strong for injector
; pulse scheduling; the exact output transistor / connector pin is hardware proof.
6FE4:           LDX     #REG_PORTA
6FE7:           BCLR    $22,X,#$80        ; disable OC1 interrupt
7010:           LDD     RAM_FUEL_FINAL_C3
7012:           ASLD
7014:           STD     RAM_FUEL_EVENT_BC
703C:           LDD     RAM_FUEL_EVENT_BC
705C:           BSET    $20,X,#$30        ; TCTL1 OC3 action: forced edge setup
7065:           BRSET   $00,X,#$20,$70C1
7069:           BSET    $0B,X,#$20        ; CFORC: force OC3 edge now
706C:           LDD     RAM_FUEL_PHASE_2086
706F:           ADDD    CAL_OC3_GUARD_8787 ; period-fit guard before edge schedule
7072:           ADDD    RAM_FUEL_EVENT_BC
7074:           CPD     RAM_PERIOD_LIMIT_21C8
707A:           LDD     RAM_FUEL_EVENT_BC
707C:           ADDD    RAM_OC_BASE_21CB
707F:           ADDD    RAM_FUEL_PHASE_2086
7082:           ADDD    #$0005
7085:           STD     REG_TOC3          ; schedule OC3 pulse edge
70AA:           BCLR    $20,X,#$10        ; change OC3 action for scheduled edge
70BC:           BSET    $0B,X,#$20        ; force/confirm OC3 action in some states

;===============================================================================
;                              TABLES AND AXES
;===============================================================================

; This section mirrors the current XDF confirmed/code-referenced entries. Some
; blocks are represented as labels and comments only so this remains a compact
; reverse-engineering notebook rather than a full reassembly listing.

                ORG     $802B
TABLE_802B_FUEL_CHARGE_CORR_A_SIGNED_24X9:
; Code-referenced signed 2D fuel/charge correction candidate. X axis is likely IAT/air-temp
; RAM $2038 from the $200A/$2124 producer with raw helper labels from $92D9:
;   12,20,34,57,93,142,191,227,246.
; Y axis is RPM RAM $2036 with labels from $929E:
;   550,750,850,950,1000,1200,1400,1600,1800,2000,2300,2600,
;   2900,3200,3501,3800,4201,4500,5000,5501,6000,6502,7003,7500.
; Output is RAM $204A and feeds $204B -> $00C1 fuel/charge accumulator candidate.
; Important correction: legacy $802E is +3 bytes inside this table, not a true
; table base and not a VE/fuel table to tune directly. Legacy $80EB is $802B+$C0,
; starts at a non-row-aligned offset inside this signed table, and crosses into
; the paired $8103 table when viewed as the old 21x9 public-index probe.

                ORG     $8103
TABLE_8103_TEMP_RPM_CORR_B_SIGNED_24X9:
; Paired signed 2D fuel/charge correction candidate using the same X=$2038 likely IAT/air-temp
; raw $92D9 labels and Y=$2036 RPM $929E labels as $802B. Output is RAM $204D.
; Its signed output feeds the $204E/$204F blend path used by the $00C1 fuel/
; charge accumulator candidate. Exact sensor identity and injector channel open.

                ORG     $821C
TABLE_821C_MAIN_FUEL_TRIM_CAND_A_SIGNED_24X9:
; Candidate main fuel trim / multiplier table. Selected by routine $E38B when
; $20B1 chooses bank A. Signed 24x9, X=RAM $2034 modeled load/MAP-like axis,
; Y=RAM $2036 RPM axis, output=$2084. $E715 applies $2084 as a signed
; proportional correction to $00C1, making this a stronger fueling knob than
; the old misaligned $802E visual view.

                ORG     $8318
TABLE_8318_MAIN_FUEL_TRIM_CAND_B_SIGNED_24X9:
; Candidate main fuel trim / multiplier table. Alternate bank selected by
; routine $E38B when $20B1 chooses bank B. Same axes and signed output path as
; $821C. Final injector output pin/channel remains unproven.

                ORG     $83F0
VEC_83F0_RPM_ONLY_FUEL_TRIM_BYPASS_SIGNED_1X24:
; RPM-only signed fuel trim / bypass vector used by $E38B when $00A9 bit $20 is
; set. Helper $B2BA uses RPM axis RAM $2036; result is stored at $2084 and then
; applied to $00C1 by $E715.

                ORG     $81F8
TABLE_81F8_FUEL_TRIM_ALT_A_SIGNED_24X9:
; Alternate/special low-RPM base selected inside $E38B under flag conditions.
; Documented for reverse-engineering context only; not exposed as a normal XDF
; tuning table in the current XDF.

                ORG     $82F4
TABLE_82F4_FUEL_TRIM_ALT_B_SIGNED_24X9:
; Alternate/special low-RPM base selected inside $E38B under flag conditions.
; Documented for reverse-engineering context only; not exposed as a normal XDF
; tuning table in the current XDF.

                ORG     $84E3
VEC_84E3_LAMBDA_CLOSED_LOOP_FUEL_1X19:
; Likely lambda / closed-loop fuel correction vector. Current traced path is:
;   $200C -> $5B1B -> $43DC -> $00CC -> $2040 -> $84E3 -> $2049 -> $00C1.
; This is strong software evidence for a closed-loop fuel trim, but $200C still
; needs scope or harness proof before calling it final lambda/O2 in hardware.

                ORG     $55A0
TABLE_55A0_DIAG_EVENT_CODES:
; XDF diagnostics/service data: 1x18 raw event-code table.
; Indexed by routine $5982 before it inserts/removes entries in event queue
; RAM $004B-$005B. Service/status data, not a tune map.

                ORG     $85BA
TABLE_85BA_CONFIRMED_24X5:
; High-load fuel pulse extension / duration-support candidate: 24x5 B2D6 byte table.
; Caller around $6E96 uses axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Interpolated result is stored at RAM $2063, doubled, and added to $00C1 before
; publishing $00C3. This affects event width, not the main fuel trim multiplier.

                ORG     $869A
TABLE_869A_CONFIRMED_24X9:
; XDF code-confirmed additional table: 24x9 B2D6 byte table.
; Used at $9B79-$9BB4. Axis 1 is derived from RAM $2014 at descriptor $238A;
; axis 2 is RAM $2036 RPM. Interpolated result is stored at RAM $2391.

                ORG     $87B1
TABLE_87B1_CONFIRMED_24X9:
; Injector/event phase candidate: 24x9 B2D6 byte table, all zero in stock.
; Used at $7254-$729B with axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Stride/count comes from $9290; result updates RAM $00BE, which is converted to
; $21C6, the OC1 schedule offset before the OC3 pulse. Tune as phase/offset only.

                ORG     $888E
TABLE_888E_CONFIRMED_24X9:
; Likely idle-air / idle-bypass target table, not fuel quantity.
; Used at $BE74-$BE93 with axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Result is stored at RAM $2484, then combined with the likely CTS-axis $8970
; vector and shaped toward RAM $202B. External bit $1050.04 is then toggled by
; the state path, so final actuator hardware still needs board/pin proof.

                ORG     $8970
VEC_8970_IDLE_CTS_TARGET_CAP_1X17:
; Likely CTS/coolant-axis idle target/cap vector. Indexed by RAM $203E in the
; BE65 idle path, stored to $2486, and combined with the $888E load/RPM target.
; Keep the CTS name as "likely" until ADC channel/pin behavior is confirmed.

                ORG     $8A0A
TABLE_8A0A_CONFIRMED_5X5:
; XDF code-confirmed additional table: 5x5 B2D6 byte table.
; Used around $BA35 with axes RAM $2034 MAP/load estimate and RAM $2046
; secondary transient/state axis. Result is stored at RAM $20BB.

                ORG     $8C31
VEC_8C31_SPARK_MODE_A_1X24:
; RPM-only spark / angle vector used by special-state spark logic around $49A3.
; Indexed by RPM axis $2036 and displayed as raw/2 degrees. Physical mode name
; remains provisional.

                ORG     $8C49
VEC_8C49_SPARK_MODE_B_1X24:
; RPM-only spark / angle vector used by the paired special-state path. Indexed
; by $2036 and displayed as raw/2 degrees.

                ORG     $8C61
VEC_8C61_SPARK_MODE_C_1X24:
; Third RPM-only special-state spark / angle vector before the signed correction
; pair at $8C7C/$8D15. Indexed by $2036 and displayed as raw/2 degrees.

                ORG     $8C7C
TABLE_8C7C_SPARK_TEMP_LOAD_A_SIGNED_17X9:
; Code-referenced signed 2D spark correction. X axis is modeled load RAM $2034;
; Y axis is likely IAT/air-temp RAM $203A from the $200A/$92D9 family. The signed result
; is sign-extended and added into spark accumulator RAM $2147.

                ORG     $8D15
TABLE_8D15_SPARK_TEMP_LOAD_B_SIGNED_17X9:
; Paired signed 2D spark correction using modeled load RAM $2034 and a
; likely CTS/coolant axis RAM $203E from the $2008/$92CF family. Signed result contributes to
; RAM $2147; exact temperature sensor naming remains provisional.

                ORG     $8DAE
VEC_8DAE_SPARK_TEMP_DECAY:
; Temperature/sensor-indexed spark correction decay or ramp vector. Indexed by
; $203E family in the $49BA path and stored into RAM $2134.

                ORG     $8E6F
TABLE_8E6F_CONFIRMED_17X5:
; XDF code-confirmed 17x5 cluster table used by $D105-$D15D.
; Axis 1 is derived from RAM $00D0 minus $60 and limited to $0400; axis 2 is
; RAM $2044. Result is stored at RAM $24AB. Physical role still open.

                ORG     $8EC7
TABLE_8EC7_CONFIRMED_17X5:
; Same confirmed $D105-$D15D 17x5 cluster and axes as $8E6F.
; Result is stored at RAM $24AF. Physical role still open.

                ORG     $8F1C
TABLE_8F1C_CONFIRMED_17X5:
; Same confirmed $D105-$D15D 17x5 cluster and axes as $8E6F.
; Result is stored at RAM $24AC. Physical role still open.

                ORG     $8F71
TABLE_8F71_CONFIRMED_17X5:
; Same confirmed $D105-$D15D 17x5 cluster and axes as $8E6F.
; Interpolated value is shifted down four bits and stored at RAM $24AD.

                ORG     $9073
TABLE_9073_CONFIRMED_11X9:
; XDF code-confirmed additional table: 11x9 B2D6 byte table.
; Used at $C282-$C2BE. Axis 1 comes from $9291 via $B383; axis 2 is derived
; from RAM $2044 with a $0A00 transform. Compared with RAM $243C and used in a
; ramp/state update. Physical role still open.

                ORG     $9131
TABLE_9131_STATE_DESCRIPTOR_TRIPLES:
; XDF diagnostics/service data: 19x3 raw state descriptor triples.
; Consumed by the $58F2 descriptor/state subsystem. This is not a normal tune
; map and should stay separate from fuel/spark candidates.

                ORG     $9291
AXIS_9291_LOAD_DELTA:
; XDF code-referenced 1x9 helper breakpoint vector A.
; Used by $B383 callers including $41E0 and the $9187 lookup at $6344.
; Physical units remain provisional; do not call it a spark-load axis.
; Decimal: 0, 3, 11, 22, 37, 54, 89, 132, 201
    FCB $00,$03,$0B,$16,$25,$36,$59,$84,$C9
AXIS_929A_LOAD_DELTA_COUNT:
    FCB $09                 ; count = 9

                ORG     $929E
AXIS_929E_RPM_PERIODS:
; 24 period breakpoints. Approx RPM = 15000000 / period.
; Approx RPMs: 550, 750, 850, 950, 1000, 1200, 1400, 1600, 1800, 2000, 2300, 2600, 2900, 3200, 3501, 3800, 4201, 4500, 5000, 5501, 6000, 6502, 7003, 7500
    FDB $6A89,$4E20,$44EF,$3DAD,$3A98,$30D4,$29DA,$249F,$208D,$1D4C,$1979,$1689,$1434,$124F,$10BD,$0F6B,$0DF3,$0D05,$0BB8,$0AA7,$09C4,$0903,$085E,$07D0
AXIS_92CE_RPM_COUNT:
    FCB $18                 ; count = 24

                ORG     $92CF
AXIS_92CF_HELPER_B:
; XDF code-referenced 1x9 helper breakpoint vector B.
; Raw labels: 12,20,34,57,93,142,191,227,246.
; Used by the $2008 -> $2122 producer for likely CTS/coolant axis RAM $203C/$203E.
; Used by $B383/$B2AB caller groups around $4340, $5D00, and $5D7B.
; Physical units remain provisional. Byte $92D8 is count=9 for one caller.
; Bytes are left in the XDF as raw until the producer/consumer group is named.

                ORG     $92D9
AXIS_92D9_HELPER_A:
; Second 1x9 temperature-like helper breakpoint vector. Same raw label shape:
; 12,20,34,57,93,142,191,227,246.
; Used by the $200A -> $2124 producer for likely IAT axis RAM $2038/$203A, including signed
; fuel temp/RPM correction tables $802B/$8103 and spark correction $8C7C.
; Byte $92E2 is count=9 for this caller group.

                ORG     $400E
VEC_400E_SENSOR_TRANSFER:
; 1x9 transfer/display vector used while building both temperature-like axes.
; Raw decimal labels: 160,140,120,100,80,60,40,20,0. This looks like a
; temperature display/linearization aid, but physical units are not confirmed.

                ORG     $9187
TABLE_9187_LOAD_AIRCHARGE_FACTOR:
; XDF: Load Model / Correction Factor Candidate 24x9 @ $9187.
; Code-confirmed and MOD2-touched, but not proven main fuel.
; X axis: RAM $2017 through $9291 breakpoints.
; Y axis: RPM index $2036 from $929E period table.
; Display hypothesis: raw/230 or percent/factor-style; not final confirmed units.
; Raw decimal rows:
;   row 00: 186 199 220 227 247 252 254 254 254
;   row 01: 186 199 220 227 247 252 254 254 254
;   row 02: 167 186 216 227 247 252 254 254 254
;   row 03: 153 174 201 227 247 252 254 254 254
;   row 04: 145 167 197 227 247 252 254 254 254
;   row 05: 130 148 183 221 243 250 254 254 254
;   row 06: 114 130 174 208 239 250 254 254 254
;   row 07:  96 112 155 188 235 247 254 254 254
;   row 08:  91 104 138 191 230 243 253 254 254
;   row 09:  77  91 130 181 222 240 252 254 254
;   row 10:  70  87 117 167 217 233 251 254 254
;   row 11:  65  85 205 153 207 231 250 254 254
;   row 12:  57  76  95 139 196 230 249 254 254
;   row 13:  52  71  87 133 188 227 248 253 254
;   row 14:  51  71  84 125 178 220 247 252 254
;   row 15:  49  72  88 123 173 216 246 252 254
;   row 16:  48  71  82 114 160 209 244 251 254
;   row 17:  44  64  77 107 146 200 242 251 254
;   row 18:  39  57  69  97 134 188 238 250 251
;   row 19:  33  50  67  84 117 172 232 247 250
;   row 20:  33  46  52  76 107 163 228 244 249
;   row 21:  33  40  52  69 103 154 224 243 248
;   row 22:  33  44  53  67  97 146 188 242 247
;   row 23:  33  44  53  67  96 137 216 239 246
    FCB $BA,$C7,$DC,$E3,$F7,$FC,$FE,$FE,$FE    ; row 00 raw: 186 199 220 227 247 252 254 254 254
    FCB $BA,$C7,$DC,$E3,$F7,$FC,$FE,$FE,$FE    ; row 01 raw: 186 199 220 227 247 252 254 254 254
    FCB $A7,$BA,$D8,$E3,$F7,$FC,$FE,$FE,$FE    ; row 02 raw: 167 186 216 227 247 252 254 254 254
    FCB $99,$AE,$C9,$E3,$F7,$FC,$FE,$FE,$FE    ; row 03 raw: 153 174 201 227 247 252 254 254 254
    FCB $91,$A7,$C5,$E3,$F7,$FC,$FE,$FE,$FE    ; row 04 raw: 145 167 197 227 247 252 254 254 254
    FCB $82,$94,$B7,$DD,$F3,$FA,$FE,$FE,$FE    ; row 05 raw: 130 148 183 221 243 250 254 254 254
    FCB $72,$82,$AE,$D0,$EF,$FA,$FE,$FE,$FE    ; row 06 raw: 114 130 174 208 239 250 254 254 254
    FCB $60,$70,$9B,$BC,$EB,$F7,$FE,$FE,$FE    ; row 07 raw:  96 112 155 188 235 247 254 254 254
    FCB $5B,$68,$8A,$BF,$E6,$F3,$FD,$FE,$FE    ; row 08 raw:  91 104 138 191 230 243 253 254 254
    FCB $4D,$5B,$82,$B5,$DE,$F0,$FC,$FE,$FE    ; row 09 raw:  77  91 130 181 222 240 252 254 254
    FCB $46,$57,$75,$A7,$D9,$E9,$FB,$FE,$FE    ; row 10 raw:  70  87 117 167 217 233 251 254 254
    FCB $41,$55,$CD,$99,$CF,$E7,$FA,$FE,$FE    ; row 11 raw:  65  85 205 153 207 231 250 254 254
    FCB $39,$4C,$5F,$8B,$C4,$E6,$F9,$FE,$FE    ; row 12 raw:  57  76  95 139 196 230 249 254 254
    FCB $34,$47,$57,$85,$BC,$E3,$F8,$FD,$FE    ; row 13 raw:  52  71  87 133 188 227 248 253 254
    FCB $33,$47,$54,$7D,$B2,$DC,$F7,$FC,$FE    ; row 14 raw:  51  71  84 125 178 220 247 252 254
    FCB $31,$48,$58,$7B,$AD,$D8,$F6,$FC,$FE    ; row 15 raw:  49  72  88 123 173 216 246 252 254
    FCB $30,$47,$52,$72,$A0,$D1,$F4,$FB,$FE    ; row 16 raw:  48  71  82 114 160 209 244 251 254
    FCB $2C,$40,$4D,$6B,$92,$C8,$F2,$FB,$FE    ; row 17 raw:  44  64  77 107 146 200 242 251 254
    FCB $27,$39,$45,$61,$86,$BC,$EE,$FA,$FB    ; row 18 raw:  39  57  69  97 134 188 238 250 251
    FCB $21,$32,$43,$54,$75,$AC,$E8,$F7,$FA    ; row 19 raw:  33  50  67  84 117 172 232 247 250
    FCB $21,$2E,$34,$4C,$6B,$A3,$E4,$F4,$F9    ; row 20 raw:  33  46  52  76 107 163 228 244 249
    FCB $21,$28,$34,$45,$67,$9A,$E0,$F3,$F8    ; row 21 raw:  33  40  52  69 103 154 224 243 248
    FCB $21,$2C,$35,$43,$61,$92,$BC,$F2,$F7    ; row 22 raw:  33  44  53  67  97 146 188 242 247
    FCB $21,$2C,$35,$43,$60,$89,$D8,$EF,$F6    ; row 23 raw:  33  44  53  67  96 137 216 239 246

                ORG     $8A52
VEC_8A52_STRATEGY_LIMIT:
; XDF code-confirmed 1x19 vector indexed by RAM $2044.
; Output stored to $20E6 and used as a clamp/limit, not a main fuel/spark map.
; Decimal: 18, 18, 18, 18, 24, 27, 30, 30, 34, 34, 34, 34, 32, 30, 26, 24, 22, 20, 24
    FCB $12,$12,$12,$12,$18,$1B,$1E,$1E,$22,$22,$22,$22,$20,$1E,$1A,$18,$16,$14,$18

                ORG     $89C7
VEC_89C7:
; XDF code-confirmed 1x19 vector indexed by RAM $2044. MOD2 unchanged.
    FCB $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$0E,$0E,$0E,$0E,$0E,$0E,$0E
                ORG     $89DA
VEC_89DA:
; XDF code-confirmed 1x19 vector indexed by RAM $2044. MOD2 unchanged.
    FCB $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$1E,$1C,$1A,$18,$16,$14
                ORG     $89ED
SCALARS_89ED_CONTROL:
; XDF code-referenced 1x6 scalar/control block between vectors $89DA and $89F3.
; Keep raw until the direct consumers are named.
                ORG     $89F3
VEC_89F3_MOD2_TOUCHED:
; XDF code-confirmed 1x19 vector indexed by RAM $2044, MOD2 touched.
; X labels: 0, 400, 800, ... 7200 rpm. Output is stored to $20BC, then also
; becomes the high byte of working word $242F in the same routine.
; Likely load-model/transient/enrichment gain; physical role remains provisional.
    FCB $40,$46,$4B,$50,$55,$5A,$5F,$78,$90,$90,$96,$96,$90,$A5,$AA,$A0,$9B,$96,$82
                ORG     $8A27
VEC_8A27:
; XDF code-confirmed 1x19 vector indexed by RAM $2044. MOD2 unchanged.
    FCB $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
                ORG     $8A3A
VEC_8A3A:
; XDF code-confirmed 1x19 vector indexed by RAM $2044. MOD2 unchanged.
    FCB $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                ORG     $8A4D
SCALARS_8A4D_CONTROL:
; XDF code-referenced 1x5 scalar/sentinel block after vector $8A3A.
; Direct references include $8A4D, $8A4F, and $8A51.
                ORG     $8A65
SCALARS_8A65_CONTROL:
; XDF code-referenced 1x3 scalar block before the signed offset byte.
; Direct references include $8A65, $8A66, and $8A67.
                ORG     $8A68
BYTE_8A68_SPARK_SIGNED_OFFSET:
; XDF code-confirmed signed offset byte used by the spark path when enabled.

                ORG     $8A69
TABLE_8A69_SPARK_HIGH_DEFAULT:
; Code-confirmed 24x9. Likely spark high/default. Display raw/2 deg.
; Axes: X = RAM $2034 MAP/load estimate; Y = RAM $2036 RPM.
; Stock $800A underflows to runtime $20B1=$FF, so this nonzero-selected bank is
; the stock/default path. Exact high-octane naming remains provisional.
; Raw rows:
;   row 00:  52  52  52  42  42  42  42  42  16
;   row 01:  44  44  44  42  42  42  42  42  22
;   row 02:  44  44  44  42  40  44  44  46  25
;   row 03:  44  44  44  40  35  44  46  48  28
;   row 04:  44  44  44  37  28  46  52  49  30
;   row 05:  46  46  46  37  26  57  56  50  36
;   row 06:  48  48  48  39  32  62  58  52  40
;   row 07:  50  50  50  48  44  65  60  53  43
;   row 08:  56  56  56  58  57  67  62  55  45
;   row 09:  60  60  60  64  64  69  64  56  47
;   row 10:  64  64  64  70  72  73  67  58  51
;   row 11:  69  69  69  77  77  75  70  62  55
;   row 12:  72  72  72  84  82  78  72  65  58
;   row 13:  74  74  74  91  87  81  75  67  61
;   row 14:  77  77  77  93  92  84  77  70  62
;   row 15:  78  78  78  93  93  85  77  72  62
;   row 16:  76  76  76  93  92  85  76  72  62
;   row 17:  72  72  72  91  89  84  74  71  62
;   row 18:  67  67  67  89  87  83  75  68  62
;   row 19:  66  66  66  87  86  83  74  66  62
;   row 20:  66  66  66  86  85  83  76  65  62
;   row 21:  66  66  66  86  84  83  75  63  62
;   row 22:  66  66  66  86  84  83  75  63  62
;   row 23:  66  66  66  84  84  83  75  63  62
    FCB $34,$34,$34,$2A,$2A,$2A,$2A,$2A,$10    ; row 00 raw:  52  52  52  42  42  42  42  42  16
    FCB $2C,$2C,$2C,$2A,$2A,$2A,$2A,$2A,$16    ; row 01 raw:  44  44  44  42  42  42  42  42  22
    FCB $2C,$2C,$2C,$2A,$28,$2C,$2C,$2E,$19    ; row 02 raw:  44  44  44  42  40  44  44  46  25
    FCB $2C,$2C,$2C,$28,$23,$2C,$2E,$30,$1C    ; row 03 raw:  44  44  44  40  35  44  46  48  28
    FCB $2C,$2C,$2C,$25,$1C,$2E,$34,$31,$1E    ; row 04 raw:  44  44  44  37  28  46  52  49  30
    FCB $2E,$2E,$2E,$25,$1A,$39,$38,$32,$24    ; row 05 raw:  46  46  46  37  26  57  56  50  36
    FCB $30,$30,$30,$27,$20,$3E,$3A,$34,$28    ; row 06 raw:  48  48  48  39  32  62  58  52  40
    FCB $32,$32,$32,$30,$2C,$41,$3C,$35,$2B    ; row 07 raw:  50  50  50  48  44  65  60  53  43
    FCB $38,$38,$38,$3A,$39,$43,$3E,$37,$2D    ; row 08 raw:  56  56  56  58  57  67  62  55  45
    FCB $3C,$3C,$3C,$40,$40,$45,$40,$38,$2F    ; row 09 raw:  60  60  60  64  64  69  64  56  47
    FCB $40,$40,$40,$46,$48,$49,$43,$3A,$33    ; row 10 raw:  64  64  64  70  72  73  67  58  51
    FCB $45,$45,$45,$4D,$4D,$4B,$46,$3E,$37    ; row 11 raw:  69  69  69  77  77  75  70  62  55
    FCB $48,$48,$48,$54,$52,$4E,$48,$41,$3A    ; row 12 raw:  72  72  72  84  82  78  72  65  58
    FCB $4A,$4A,$4A,$5B,$57,$51,$4B,$43,$3D    ; row 13 raw:  74  74  74  91  87  81  75  67  61
    FCB $4D,$4D,$4D,$5D,$5C,$54,$4D,$46,$3E    ; row 14 raw:  77  77  77  93  92  84  77  70  62
    FCB $4E,$4E,$4E,$5D,$5D,$55,$4D,$48,$3E    ; row 15 raw:  78  78  78  93  93  85  77  72  62
    FCB $4C,$4C,$4C,$5D,$5C,$55,$4C,$48,$3E    ; row 16 raw:  76  76  76  93  92  85  76  72  62
    FCB $48,$48,$48,$5B,$59,$54,$4A,$47,$3E    ; row 17 raw:  72  72  72  91  89  84  74  71  62
    FCB $43,$43,$43,$59,$57,$53,$4B,$44,$3E    ; row 18 raw:  67  67  67  89  87  83  75  68  62
    FCB $42,$42,$42,$57,$56,$53,$4A,$42,$3E    ; row 19 raw:  66  66  66  87  86  83  74  66  62
    FCB $42,$42,$42,$56,$55,$53,$4C,$41,$3E    ; row 20 raw:  66  66  66  86  85  83  76  65  62
    FCB $42,$42,$42,$56,$54,$53,$4B,$3F,$3E    ; row 21 raw:  66  66  66  86  84  83  75  63  62
    FCB $42,$42,$42,$56,$54,$53,$4B,$3F,$3E    ; row 22 raw:  66  66  66  86  84  83  75  63  62
    FCB $42,$42,$42,$54,$54,$53,$4B,$3F,$3E    ; row 23 raw:  66  66  66  84  84  83  75  63  62

                ORG     $8B41
TABLE_8B41_SPARK_LOW_ALTERNATE:
; Code-confirmed 24x9. Likely spark low/alternate. Display raw/2 deg.
; Axes: X = RAM $2034 MAP/load estimate; Y = RAM $2036 RPM.
; Selected when runtime $20B1 is zero. Usually lower in high-load columns than
; $8A69, but not lower everywhere; exact low-octane naming remains provisional.
; Raw rows:
;   row 00:  30  38  38  38  38  28  20  20  20
;   row 01:  20  42  42  42  48  32  24  20  20
;   row 02:  20  36  36  36  36  32  32  24  20
;   row 03:  20  36  36  48  48  42  32  26  20
;   row 04:  22  36  36  36  48  48  40  30  20
;   row 05:  36  36  48  64  59  48  46  42  32
;   row 06:  40  40  56  70  64  58  48  46  32
;   row 07:  44  44  60  82  64  58  52  47  44
;   row 08:  46  46  64  84  60  58  52  46  46
;   row 09:  64  64  64  84  74  70  54  50  50
;   row 10:  64  64  64  80  70  62  60  60  50
;   row 11:  64  64  64  81  72  60  58  56  50
;   row 12:  60  60  60  74  72  68  64  58  49
;   row 13:  76  76  76  90  76  72  64  62  48
;   row 14:  74  74  74  88  84  74  72  60  50
;   row 15:  84  84  84 100  80  80  68  66  52
;   row 16:  84  84  84 100  86  76  72  66  54
;   row 17:  78  78  78  94  84  76  70  66  58
;   row 18:  70  70  70  86  80  70  66  60  58
;   row 19:  72  72  72  88  80  74  66  60  58
;   row 20:  70  70  70  86  74  74  68  66  55
;   row 21:  76  76  76  92  76  68  69  62  54
;   row 22:  80  80  80  96  84  78  73  60  56
;   row 23:  72  72  72  88  84  72  72  68  56
    FCB $1E,$26,$26,$26,$26,$1C,$14,$14,$14    ; row 00 raw:  30  38  38  38  38  28  20  20  20
    FCB $14,$2A,$2A,$2A,$30,$20,$18,$14,$14    ; row 01 raw:  20  42  42  42  48  32  24  20  20
    FCB $14,$24,$24,$24,$24,$20,$20,$18,$14    ; row 02 raw:  20  36  36  36  36  32  32  24  20
    FCB $14,$24,$24,$30,$30,$2A,$20,$1A,$14    ; row 03 raw:  20  36  36  48  48  42  32  26  20
    FCB $16,$24,$24,$24,$30,$30,$28,$1E,$14    ; row 04 raw:  22  36  36  36  48  48  40  30  20
    FCB $24,$24,$30,$40,$3B,$30,$2E,$2A,$20    ; row 05 raw:  36  36  48  64  59  48  46  42  32
    FCB $28,$28,$38,$46,$40,$3A,$30,$2E,$20    ; row 06 raw:  40  40  56  70  64  58  48  46  32
    FCB $2C,$2C,$3C,$52,$40,$3A,$34,$2F,$2C    ; row 07 raw:  44  44  60  82  64  58  52  47  44
    FCB $2E,$2E,$40,$54,$3C,$3A,$34,$2E,$2E    ; row 08 raw:  46  46  64  84  60  58  52  46  46
    FCB $40,$40,$40,$54,$4A,$46,$36,$32,$32    ; row 09 raw:  64  64  64  84  74  70  54  50  50
    FCB $40,$40,$40,$50,$46,$3E,$3C,$3C,$32    ; row 10 raw:  64  64  64  80  70  62  60  60  50
    FCB $40,$40,$40,$51,$48,$3C,$3A,$38,$32    ; row 11 raw:  64  64  64  81  72  60  58  56  50
    FCB $3C,$3C,$3C,$4A,$48,$44,$40,$3A,$31    ; row 12 raw:  60  60  60  74  72  68  64  58  49
    FCB $4C,$4C,$4C,$5A,$4C,$48,$40,$3E,$30    ; row 13 raw:  76  76  76  90  76  72  64  62  48
    FCB $4A,$4A,$4A,$58,$54,$4A,$48,$3C,$32    ; row 14 raw:  74  74  74  88  84  74  72  60  50
    FCB $54,$54,$54,$64,$50,$50,$44,$42,$34    ; row 15 raw:  84  84  84 100  80  80  68  66  52
    FCB $54,$54,$54,$64,$56,$4C,$48,$42,$36    ; row 16 raw:  84  84  84 100  86  76  72  66  54
    FCB $4E,$4E,$4E,$5E,$54,$4C,$46,$42,$3A    ; row 17 raw:  78  78  78  94  84  76  70  66  58
    FCB $46,$46,$46,$56,$50,$46,$42,$3C,$3A    ; row 18 raw:  70  70  70  86  80  70  66  60  58
    FCB $48,$48,$48,$58,$50,$4A,$42,$3C,$3A    ; row 19 raw:  72  72  72  88  80  74  66  60  58
    FCB $46,$46,$46,$56,$4A,$4A,$44,$42,$37    ; row 20 raw:  70  70  70  86  74  74  68  66  55
    FCB $4C,$4C,$4C,$5C,$4C,$44,$45,$3E,$36    ; row 21 raw:  76  76  76  92  76  68  69  62  54
    FCB $50,$50,$50,$60,$54,$4E,$49,$3C,$38    ; row 22 raw:  80  80  80  96  84  78  73  60  56
    FCB $48,$48,$48,$58,$54,$48,$48,$44,$38    ; row 23 raw:  72  72  72  88  84  72  72  68  56

                ORG     $8C19
VEC_8C19_WOT_SPARK:
; XDF confirmed-category 1x24 RPM-only spark vector, display raw/2 deg.
; Used when RAM $00A9 bit $20 bypasses banked 2D spark. Likely WOT/fallback.
    FCB $10,$16,$19,$1C,$1E,$24,$28,$2A,$2D,$2F,$33,$37,$3A,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E,$3E

; Legacy note for earlier XDF work:
;   $802E was previously exposed as a smooth unsigned 21x9 fuel/VE candidate.
;   Targeted disassembly now shows the real signed table base is $802B, so $802E
;   is a misaligned +3 slice inside TABLE_802B_FUEL_CHARGE_CORR_A_SIGNED_24X9.
;   $80EB is another legacy view: $802B+$C0, beginning inside signed table A and
;   crossing into signed table B at $8103. It is a signed boundary/alignment
;   diagnostic only, with no physical RPM/load axes.
;   Main fuel table remains unfound, but $00C1/$00C3 now form the strongest
;   fuel/charge time-path candidate. Continue proving the final injector output.

;===============================================================================
;                                OPEN ITEMS / TODO
;===============================================================================
;
; 1. Trace injector driver scheduling backward to find confirmed main fuel.
;    The old $802E visual VE candidate is demoted to a legacy misaligned slice.
;
; 2. Trace $20E6 consumers to name VEC_8A52 more precisely. Current evidence says
;    clamp/limit vector, not final fuel/spark.
;
; 3. Finish physical sensor identification for $2007-$200E and $00C9/$0011.
;    This is required to name the $9291 axis as TPS delta, MAP delta, or another
;    processed load sensor quantity.
;
; 4. Trace spark accumulator $2147 to timer output compare scheduling to prove
;    final ignition output conversion.
;
;===============================================================================
; End of rough decompile.
;===============================================================================
