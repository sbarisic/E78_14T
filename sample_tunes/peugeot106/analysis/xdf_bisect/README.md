# TunerPro XDF Crash Bisect

These XDFs are generated from the known-good v0.14 definition unless their name says otherwise.
Load them in TunerPro in numeric order and note the first one that crashes.

1. `bisect_00_safe_v014.xdf`
   Baseline copy of the XDF version confirmed to load.
2. `bisect_01_spark_rounded_x_labels_only.xdf`
   Only changes the two spark-bank X labels from raw 0..1024 to display 0..100.
3. `bisect_02_confirmed_category_decimal10_only.xdf`
   Adds category `0xA` and moves confirmed entries into decimal category `10`.
4. `bisect_03_confirmed_category_hex0xA_only.xdf`
   Same category test, but memberships use `0xA`.
5. `bisect_04_80F1_25x9_unsigned_no_typeflags.xdf`
   Changes only table `0x218` to the 25x9 `0x80F1` alignment, unsigned/raw.
6. `bisect_05_80F1_25x9_signed_typeflags.xdf`
   Same `0x80F1` alignment, but with TunerPro signed-byte `mmedtypeflags="0x01"`.
7. `bisect_06_rounded_labels_plus_category_decimal10.xdf`
   Combines rounded spark labels with decimal Confirmed category memberships.
8. `bisect_07_rounded_labels_plus_category_hex0xA.xdf`
   Combines rounded spark labels with hex Confirmed category memberships.
9. `bisect_08_exact_head_v021_crashy_candidate.xdf`
   Byte-faithful exact committed v0.21 candidate for reproducing the crash.

Second-stage files, generated after `00` through `07` loaded and only `08` crashed:

10. `bisect_09_all_structural_v021_old_text.xdf`
    Combines the v0.21 structural changes: signed `0x80F1`, rounded spark X labels, and decimal Confirmed category memberships, while keeping older prose.
11. `bisect_10_exact_v021_with_v014_prose.xdf`
    Starts from exact v0.21, then restores v0.14 header/table prose for the changed entries.
12. `bisect_11_structural_plus_v021_header_prose.xdf`
    Adds only the v0.21 header/version prose to the structural test.
13. `bisect_12_structural_plus_v021_spark_prose.xdf`
    Adds only the v0.21 spark/RPM/helper-axis prose to the structural test.
14. `bisect_13_structural_plus_v021_fuel_probe_prose.xdf`
    Adds only the v0.21 fuel/adjacent-probe prose to the structural test.
15. `bisect_14_structural_plus_all_v021_prose.xdf`
    Adds all v0.21 changed prose back onto the structural test.

Third-stage files, generated after `08`, `12`, and `14` crashed:

16. `bisect_15_only_0x227_rpm_axis_prose.xdf`
    Adds only the v0.21 RPM-axis prose.
17. `bisect_16_only_0x228_high_spark_prose.xdf`
    Adds only the v0.21 high/default spark-bank prose.
18. `bisect_17_only_0x229_low_spark_prose.xdf`
    Adds only the v0.21 low/alternate spark-bank prose.
19. `bisect_18_only_0x22A_axis_9291_prose.xdf`
    Adds only the v0.21 0x9291 helper-axis prose.
20. `bisect_19_only_0x22B_axis_92CF_prose.xdf`
    Adds only the v0.21 0x92CF helper-axis prose.
21. `bisect_20_only_0x22C_wot_spark_prose.xdf`
    Adds only the v0.21 WOT spark-vector prose.
22. `bisect_21_0x228_0x229_bank_prose_only.xdf`
    Adds both long v0.21 spark-bank descriptions.
23. `bisect_22_small_prose_no_big_banks.xdf`
    Adds all smaller spark/RPM/helper prose but excludes the two long bank descriptions.
24. `bisect_23_candidate_v022_compact_spark_prose.xdf`
    Candidate fixed XDF: v0.21 structures with compact TunerPro-friendly spark/RPM/helper descriptions.

Result so far: `16`, `17`, and `21` do not open, which isolates the crash to the long v0.21 spark-bank descriptions for `0x228` and `0x229`. The main `IAW8P40_peugeot106_firstpass.xdf` is now updated from `bisect_23_candidate_v022_compact_spark_prose.xdf`: v0.21 structures, compact spark/RPM/helper descriptions, and file version `0.22`.
