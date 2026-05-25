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
; Key conclusion in this pass:
;   * $9187 is a code-confirmed 24x9 load/air-charge factor table.
;   * Its X index is built from RAM $2017 using 9 breakpoints at $9291.
;   * Its Y index is the RPM-normalized axis in RAM $2036.
;   * The $9187 result can seed $00D0 -> $00CE -> $2034, so it helps create the
;     later load/MAP-like axis used by spark and other maps.
;   * $8A52 is a 19-cell $2044-indexed strategy limit/clamp vector, not a main
;     fuel or spark map.
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
RAM_LOAD_RAW_CE         EQU     $00CE      ; raw load/aircharge word
RAM_LOAD_BYTE_D0        EQU     $00D0      ; load-model/aircharge byte
RAM_SPEED_D4            EQU     $00D4      ; inverse-period / speed-like word
RAM_TIMER_CAPTURE_D9    EQU     $00D9
RAM_SENSOR_BASE_10      EQU     $0010      ; adaptive/minimum-like baseline area
RAM_SENSOR_BASE_11      EQU     $0011      ; subtracted from $00C9 to form $2017
RAM_SENSOR_PROC_C9      EQU     $00C9      ; processed sensor, probably TPS/load-related

; 68HC11 registers
REG_PORTA               EQU     $1000
REG_TCNT                EQU     $100E
REG_TIC3                EQU     $1014
REG_TFLG2               EQU     $1025
REG_ADCTL               EQU     $1030
REG_ADR1                EQU     $1031
REG_ADR2                EQU     $1032
REG_ADR3                EQU     $1033
REG_ADR4                EQU     $1034
REG_COPRST              EQU     $103A
REG_INIT                EQU     $103D

; RAM $20xx processed channels / axes
RAM_ADC_2007            EQU     $2007
RAM_ADC_2008            EQU     $2008
RAM_ADC_2009            EQU     $2009
RAM_ADC_200A            EQU     $200A
RAM_ADC_200B            EQU     $200B
RAM_ADC_200C            EQU     $200C
RAM_ADC_200D            EQU     $200D
RAM_ADC_200E            EQU     $200E
RAM_PROC_2013           EQU     $2013
RAM_AXIS_SRC_2014       EQU     $2014      ; candidate sensor/state axis source for $869A
RAM_THR_DELTA_2017      EQU     $2017      ; max(0, $00C9 - $0011), axis input for $9187
RAM_LOAD_AXIS_2034      EQU     $2034      ; final load/MAP-like 8.8 axis
RAM_RPM_AXIS_2036       EQU     $2036      ; RPM-normalized 8.8 axis
RAM_AXIS_2044           EQU     $2044      ; 19-cell speed/RPM-like vector index
RAM_AXIS_2046           EQU     $2046      ; secondary transient/state axis for $8A0A
RAM_SPARK_BANK_SEL      EQU     $20B1      ; nonzero => $8A69, zero => $8B41
RAM_VEC_89F3_OUT        EQU     $20BC
RAM_VEC_8A52_OUT        EQU     $20E6      ; output of vector $8A52; used as clamp/limit
RAM_VEC_89C7_OUT        EQU     $20E7
RAM_VEC_89DA_OUT        EQU     $20E8
RAM_TABLE_85BA_OUT      EQU     $2063
RAM_SPARK_ACCUM_2147    EQU     $2147      ; spark-angle accumulator/intermediate
RAM_SPARK_OUT_2148      EQU     $2148
RAM_LIMIT_FLAG_214F     EQU     $214F
RAM_CHECKSUM_PTR        EQU     $2188
RAM_CHECKSUM_SUM        EQU     $218A
RAM_DESC_9187           EQU     $218D      ; 7-byte B2D6 descriptor for table $9187
RAM_DESC_SPARK          EQU     $213A      ; 7-byte B2D6 descriptor for spark tables
RAM_DESC_TABLE_869A     EQU     $238A
RAM_TABLE_869A_OUT      EQU     $2391
RAM_TABLE_9073_REF      EQU     $243C
RAM_TABLE_888E_OUT      EQU     $2484
RAM_TABLE_8E6F_OUT      EQU     $24AB
RAM_TABLE_8F1C_OUT      EQU     $24AC
RAM_TABLE_8F71_OUT      EQU     $24AD
RAM_TABLE_8EC7_OUT      EQU     $24AF

; ROM tables / constants
CAL_SPARK_BANK_SEED     EQU     $800A
CHK_WORD                EQU     $800C
CHK_TARGET              EQU     $800E
DIAG_EVENT_TABLE_55A0   EQU     $55A0      ; diagnostic/event code table, 18 cells
TABLE_FUEL_CAND_802E    EQU     $802E      ; strongest unconfirmed fuel/VE candidate
TABLE_CONF_85BA         EQU     $85BA      ; code-confirmed 24x5, axes $2034/$2036
TABLE_CONF_869A         EQU     $869A      ; code-confirmed 24x9, axes $2014-derived/$2036
TABLE_CONF_87B1         EQU     $87B1      ; code-confirmed 24x9 zero table, axes $2034/$2036
TABLE_CONF_888E         EQU     $888E      ; code-confirmed 24x9, axes $2034/$2036
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

; Interpolation helpers
SUB_INTERP_1D           EQU     $B2AB
SUB_INTERP_1D_ALT       EQU     $B2BA
SUB_INTERP_2D           EQU     $B2D6
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
;                     19-CELL SPEED/RPM-LIKE VECTOR INDEX $2044
;===============================================================================

                ORG     $D482
BUILD_2044_AXIS_D482:
; $2044 indexes the 19-cell vector family at $89C7-$8A67.
; XDF keeps this as a speed/RPM-like strategy axis until the physical source is
; fully named. It is not a spark-load axis.
;
; Pseudocode:
;   if $00D4 >= $1C20:
;       $2044 = $1200
;   else:
;       $2044 = ($00D4 / 25) << 4
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
;                $2044-INDEXED VECTOR FAMILY / STRATEGY LIMITS
;===============================================================================

                ORG     $BA5D
LOOKUP_2044_VECTOR_FAMILY_BA5D:
; Common 1D vectors indexed by $2044. These are strategy/correction vectors.
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
;                              TABLES AND AXES
;===============================================================================

; This section mirrors the current XDF confirmed/code-referenced entries. Some
; blocks are represented as labels and comments only so this remains a compact
; reverse-engineering notebook rather than a full reassembly listing.

                ORG     $55A0
TABLE_55A0_DIAG_EVENT_CODES:
; XDF diagnostics/service data: 1x18 raw event-code table.
; Indexed by routine $5982 before it inserts/removes entries in event queue
; RAM $004B-$005B. Service/status data, not a tune map.

                ORG     $85BA
TABLE_85BA_CONFIRMED_24X5:
; XDF code-confirmed additional table: 24x5 B2D6 byte table.
; Caller around $6E96 uses axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Interpolated result is stored at RAM $2063. Physical role still open.

                ORG     $869A
TABLE_869A_CONFIRMED_24X9:
; XDF code-confirmed additional table: 24x9 B2D6 byte table.
; Used at $9B79-$9BB4. Axis 1 is derived from RAM $2014 at descriptor $238A;
; axis 2 is RAM $2036 RPM. Interpolated result is stored at RAM $2391.

                ORG     $87B1
TABLE_87B1_CONFIRMED_24X9:
; XDF code-confirmed additional table: 24x9 B2D6 byte table, all zero in stock.
; Used at $7254-$729B with axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Stride/count comes from $9290; result updates RAM $00BE.

                ORG     $888E
TABLE_888E_CONFIRMED_24X9:
; XDF code-confirmed additional table: 24x9 B2D6 byte table.
; Used at $BE74-$BE93 with axes RAM $2034 MAP/load estimate and RAM $2036 RPM.
; Result is stored at RAM $2484, then later combined with the $8970 vector result.

                ORG     $8A0A
TABLE_8A0A_CONFIRMED_5X5:
; XDF code-confirmed additional table: 5x5 B2D6 byte table.
; Used around $BA35 with axes RAM $2034 MAP/load estimate and RAM $2046
; secondary transient/state axis. Result is stored at RAM $20BB.

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
; Used by $B383/$B2AB caller groups around $4340, $5D00, and $5D7B.
; Physical units remain provisional. Byte $92D8 is count=9 for one caller.
; Bytes are left in the XDF as raw until the producer/consumer group is named.

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
; Likely correction/enrichment/strategy; physical role remains provisional.
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

                ORG     $802E
TABLE_802E_FUEL_VE_AIRCHARGE_CANDIDATE:
; Strongest current fuel-side candidate, but not code-confirmed main fuel.
; Preferred visual alignment is 21x9. MOD2 changes are clean positive deltas.
; XDF keeps raw display; raw/2.55 is only a percent/VE-style visualization lead.
; Do not call this final main fuel until a consumer path reaches pulse width,
; injection time, lambda/open-loop correction, or final fuel scheduling.
; Raw decimal rows:
;   row 00: 147 147 147 147 147 147 156 152 147
;   row 01: 144 144 148 146 146 146 161 154 148
;   row 02: 146 145 149 149 149 149 170 163 155
;   row 03: 153 135 152 152 152 152 174 167 159
;   row 04: 157 145 156 156 156 156 186 179 171
;   row 05: 168 164 168 168 168 168 196 189 180
;   row 06: 175 175 175 175 175 175 208 201 192
;   row 07: 187 187 187 187 187 187 214 208 200
;   row 08: 194 193 192 192 192 192 218 213 206
;   row 09: 203 203 203 203 203 203 206 202 196
;   row 10: 194 194 194 194 194 194 208 204 202
;   row 11: 196 196 196 196 196 196 220 216 210
;   row 12: 207 207 207 207 207 207 218 214 211
;   row 13: 205 205 211 209 205 205 208 203 196
;   row 14: 194 194 207 194 194 194 202 198 192
;   row 15: 189 188 192 188 188 188 201 196 189
;   row 16: 186 185 185 185 185 185 219 214 207
;   row 17: 203 200 200 200 200 200 220 215 207
;   row 18: 202 200 200 200 200 200 238 233 225
;   row 19: 221 218 217 217 217 217 248 241 232
;   row 20: 226 221 221 221 221 221 221 216 209
    FCB $93,$93,$93,$93,$93,$93,$9C,$98,$93    ; row 00 raw: 147 147 147 147 147 147 156 152 147
    FCB $90,$90,$94,$92,$92,$92,$A1,$9A,$94    ; row 01 raw: 144 144 148 146 146 146 161 154 148
    FCB $92,$91,$95,$95,$95,$95,$AA,$A3,$9B    ; row 02 raw: 146 145 149 149 149 149 170 163 155
    FCB $99,$87,$98,$98,$98,$98,$AE,$A7,$9F    ; row 03 raw: 153 135 152 152 152 152 174 167 159
    FCB $9D,$91,$9C,$9C,$9C,$9C,$BA,$B3,$AB    ; row 04 raw: 157 145 156 156 156 156 186 179 171
    FCB $A8,$A4,$A8,$A8,$A8,$A8,$C4,$BD,$B4    ; row 05 raw: 168 164 168 168 168 168 196 189 180
    FCB $AF,$AF,$AF,$AF,$AF,$AF,$D0,$C9,$C0    ; row 06 raw: 175 175 175 175 175 175 208 201 192
    FCB $BB,$BB,$BB,$BB,$BB,$BB,$D6,$D0,$C8    ; row 07 raw: 187 187 187 187 187 187 214 208 200
    FCB $C2,$C1,$C0,$C0,$C0,$C0,$DA,$D5,$CE    ; row 08 raw: 194 193 192 192 192 192 218 213 206
    FCB $CB,$CB,$CB,$CB,$CB,$CB,$CE,$CA,$C4    ; row 09 raw: 203 203 203 203 203 203 206 202 196
    FCB $C2,$C2,$C2,$C2,$C2,$C2,$D0,$CC,$CA    ; row 10 raw: 194 194 194 194 194 194 208 204 202
    FCB $C4,$C4,$C4,$C4,$C4,$C4,$DC,$D8,$D2    ; row 11 raw: 196 196 196 196 196 196 220 216 210
    FCB $CF,$CF,$CF,$CF,$CF,$CF,$DA,$D6,$D3    ; row 12 raw: 207 207 207 207 207 207 218 214 211
    FCB $CD,$CD,$D3,$D1,$CD,$CD,$D0,$CB,$C4    ; row 13 raw: 205 205 211 209 205 205 208 203 196
    FCB $C2,$C2,$CF,$C2,$C2,$C2,$CA,$C6,$C0    ; row 14 raw: 194 194 207 194 194 194 202 198 192
    FCB $BD,$BC,$C0,$BC,$BC,$BC,$C9,$C4,$BD    ; row 15 raw: 189 188 192 188 188 188 201 196 189
    FCB $BA,$B9,$B9,$B9,$B9,$B9,$DB,$D6,$CF    ; row 16 raw: 186 185 185 185 185 185 219 214 207
    FCB $CB,$C8,$C8,$C8,$C8,$C8,$DC,$D7,$CF    ; row 17 raw: 203 200 200 200 200 200 220 215 207
    FCB $CA,$C8,$C8,$C8,$C8,$C8,$EE,$E9,$E1    ; row 18 raw: 202 200 200 200 200 200 238 233 225
    FCB $DD,$DA,$D9,$D9,$D9,$D9,$F8,$F1,$E8    ; row 19 raw: 221 218 217 217 217 217 248 241 232
    FCB $E2,$DD,$DD,$DD,$DD,$DD,$DD,$D8,$D1    ; row 20 raw: 226 221 221 221 221 221 221 216 209

;===============================================================================
;                                OPEN ITEMS / TODO
;===============================================================================
;
; 1. Prove or disprove TABLE_802E as a fuel/VE/air-charge consumer.
;    Literal address search is not enough; look for indirect descriptors or copied
;    calibration-window references.
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
; 5. Trace injector driver scheduling backward to find confirmed main fuel.
;
;===============================================================================
; End of rough decompile.
;===============================================================================
