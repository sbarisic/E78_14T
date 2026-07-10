#!/usr/bin/env python3
"""Read-only comparison/scanner for Peugeot/Citroen Magneti Marelli IAW 8P.40 bins.

The script intentionally does not write ROM files. It prints Markdown-friendly
tables that can be pasted into the reverse-engineering notes.
"""

from __future__ import annotations

import argparse
import contextlib
import hashlib
import io
import math
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_PATH = ROOT / "EVIDENCE.md"
GENERATED_BEGIN = "<!-- BEGIN GENERATED ANALYSIS -->"
GENERATED_END = "<!-- END GENERATED ANALYSIS -->"

GENERATED_ANALYSIS_SECTIONS = ("overview", "diffs", "tables", "helpers", "ram", "trace")


@dataclass(frozen=True)
class RomSpec:
    key: str
    label: str
    path: Path


ROMS = [
    RomSpec("peugeot_stock", "Peugeot stock M27C512_original", ROOT / "M27C512_original.BIN"),
    RomSpec(
        "peugeot_stok",
        "Peugeot Stok folder duplicate",
        ROOT / "1_3L_8V_IAW8P40" / "1.3L_8V_IAW8P40_Stok.bin",
    ),
    RomSpec(
        "peugeot_mod2",
        "Peugeot MOD2",
        ROOT / "1_3L_8V_IAW8P40" / "1.3L_8V_IAW8P40_MOD2.bin",
    ),
    RomSpec(
        "xantia_607c",
        "Citroen Xantia 1.6 8v IAW 8P.40 607C",
        ROOT / "Citroen Xantia 1.6L 8v iaw 8p.40 (607C).bin",
    ),
    RomSpec(
        "peug_106rally_org",
        "Peug.106Rally.org.bin public/tuned comparison",
        ROOT / "Peug.106Rally.org.bin",
    ),
    RomSpec(
        "rally13_ori",
        "RALLY13.ORI same-family comparison",
        ROOT / "RALLY13.ORI",
    ),
]

COMPARISON_KEYS = ["peugeot_mod2", "xantia_607c", "peug_106rally_org", "rally13_ori"]


KNOWN_TABLES = [
    ("fuel_iat_rpm_corr_a_802b_signed_24x9", 0x802B, 24, 9, "signed8"),
    ("legacy_misaligned_slice_802e_21x9", 0x802E, 21, 9, "raw"),
    ("legacy_boundary_slice_802e_24x9", 0x802E, 24, 9, "raw"),
    ("legacy_signed_boundary_slice_80eb_21x9", 0x80EB, 21, 9, "signed8"),
    ("legacy_signed_alignment_probe_80f1_25x9", 0x80F1, 25, 9, "signed8"),
    ("fuel_correction_offset_8028_word", 0x8028, 1, 1, "word16 raw"),
    ("fuel_correction_timer_reload_802a", 0x802A, 1, 1, "raw"),
    ("fuel_iat_rpm_corr_b_8103_signed_24x9", 0x8103, 24, 9, "signed8"),
    ("legacy_public_probe_tail_81a8_5x9", 0x81A8, 5, 9, "raw"),
    ("fuel_correction_enable_base_81db", 0x81DB, 1, 1, "raw"),
    ("fuel_period_gate_threshold_a_81dc_word", 0x81DC, 1, 1, "word16 raw"),
    ("fuel_period_gate_threshold_b_81de_word", 0x81DE, 1, 1, "word16 raw"),
    ("signed_low_rpm_fuel_trim_a_81f8_4x9", 0x81F8, 4, 9, "signed8 raw/256 trim"),
    ("signed_fuel_quantity_trim_a_821c_24x9", 0x821C, 24, 9, "signed8 raw/256 trim"),
    ("signed_low_rpm_fuel_trim_b_82f4_4x9", 0x82F4, 4, 9, "signed8 raw/256 trim"),
    ("signed_fuel_quantity_trim_b_8318_24x9", 0x8318, 24, 9, "signed8 raw/256 trim"),
    ("rpm_only_fuel_trim_bypass_83f0_signed_1x24", 0x83F0, 1, 24, "signed8"),
    ("fuel_period_gated_rpm_multiplier_81e0_1x24", 0x81E0, 1, 24, "raw"),
    ("cts_warmup_fuel_corr_8408_1x17", 0x8408, 1, 17, "raw"),
    ("afterstart_tps_hysteresis_additive_8419", 0x8419, 1, 1, "raw"),
    ("afterstart_startup_seed_841a", 0x841A, 1, 1, "raw"),
    ("cts_afterstart_threshold_841b_1x17_words", 0x841B, 1, 17, "word16 raw"),
    ("cts_afterstart_decay_scale_843d_1x17", 0x843D, 1, 17, "raw"),
    ("afterstart_step_timer_844e", 0x844E, 1, 1, "raw"),
    ("afterstart_reference_844f_word", 0x844F, 1, 1, "word16 raw"),
    ("afterstart_decay_multiplier_8451", 0x8451, 1, 1, "raw"),
    ("cts_startup_output_seed_8452_1x9", 0x8452, 1, 9, "raw"),
    ("cts_warmup_afterstart_init_a_845b_1x17", 0x845B, 1, 17, "raw"),
    ("cts_warmup_afterstart_init_b_846c_1x17", 0x846C, 1, 17, "raw"),
    ("cts_afterstart_timer_a_847d_1x17", 0x847D, 1, 17, "raw"),
    ("cts_afterstart_timer_b_848e_1x17", 0x848E, 1, 17, "raw"),
    ("cts_afterstart_target_limit_a_849f_1x17", 0x849F, 1, 17, "raw"),
    ("cts_afterstart_target_limit_b_84b0_1x17", 0x84B0, 1, 17, "raw"),
    ("cts_afterstart_decay_blend_a_84c1_1x17", 0x84C1, 1, 17, "raw"),
    ("cts_afterstart_decay_blend_b_84d2_1x17", 0x84D2, 1, 17, "raw"),
    ("internal_2040_fuel_pulse_corr_84e3_1x9", 0x84E3, 1, 9, "raw"),
    ("scheduler_00d3_threshold_84ec_1x1", 0x84EC, 1, 1, "raw"),
    ("cts_scheduler_threshold_84ed_1x9", 0x84ED, 1, 9, "raw"),
    ("cts_transient_word_scale_a_84f6_1x9_words", 0x84F6, 1, 9, "word16 raw"),
    ("transient_2042_gain_a_8508_1x9", 0x8508, 1, 9, "raw"),
    ("rpm_transient_gain_a_8511_1x24", 0x8511, 1, 24, "raw"),
    ("transient_2042_word_target_a_8529_1x9_words", 0x8529, 1, 9, "word16 raw"),
    ("cts_transient_vector_a_853b_1x9", 0x853B, 1, 9, "raw"),
    ("transient_branch_scale_8544", 0x8544, 1, 1, "raw"),
    ("transient_decay_threshold_8545", 0x8545, 1, 1, "raw"),
    ("cts_transient_word_scale_b_8546_1x9_words", 0x8546, 1, 9, "word16 raw"),
    ("transient_2042_vector_b_8558_1x9", 0x8558, 1, 9, "raw"),
    ("rpm_transient_gain_b_8561_1x24", 0x8561, 1, 24, "raw"),
    ("transient_2042_word_target_b_8579_1x9_words", 0x8579, 1, 9, "word16 raw"),
    ("cts_transient_vector_c_858b_1x9", 0x858B, 1, 9, "raw"),
    ("transient_a_input_offset_8595", 0x8595, 1, 1, "raw"),
    ("transient_enrichment_a_8596_1x9", 0x8596, 1, 9, "raw"),
    ("cts_transient_temperature_scale_859f_1x9", 0x859F, 1, 9, "raw"),
    ("transient_b_entry_threshold_a_85a8", 0x85A8, 1, 1, "raw"),
    ("transient_b_entry_threshold_b_85a9", 0x85A9, 1, 1, "raw"),
    ("transient_b_load_rpm_additive_threshold_85aa", 0x85AA, 1, 1, "raw"),
    ("transient_b_lower_cutoff_85ab_word", 0x85AB, 1, 1, "word16 raw"),
    ("transient_b_input_offset_85ae", 0x85AE, 1, 1, "raw"),
    ("transient_enrichment_b_85af_1x9", 0x85AF, 1, 9, "raw"),
    ("high_load_fuel_pulse_extension_85ba_24x5", 0x85BA, 24, 5, "raw duration support"),
    ("cts_idle_state_target_a_8636_1x9", 0x8636, 1, 9, "raw"),
    ("cts_idle_state_target_b_863f_1x9", 0x863F, 1, 9, "raw"),
    ("cts_idle_state_target_c_8648_1x9", 0x8648, 1, 9, "raw"),
    ("state_2042_threshold_8652_1x9", 0x8652, 1, 9, "raw"),
    ("state_2042_minimum_8671_1x9", 0x8671, 1, 9, "raw"),
    ("cts_idle_state_limit_8689_1x9", 0x8689, 1, 9, "raw"),
    ("fuel_cut_state_delay_loadrise_rpm_869a_24x9", 0x869A, 24, 9, "raw countdown ticks"),
    ("transient_a_lower_cutoff_877b_word", 0x877B, 1, 1, "word16 raw"),
    ("event_width_limit_prev_width_877e_1x9", 0x877E, 1, 9, "raw"),
    ("oc3_period_fit_guard_8787_word", 0x8787, 1, 1, "word16 raw"),
    ("fuel_output_edge_offset_8789_1x9_words", 0x8789, 1, 9, "word16 raw"),
    ("spark_transition_2046_a_87a6_1x5", 0x87A6, 1, 5, "raw"),
    ("spark_transition_2046_b_87ab_1x6", 0x87AB, 1, 6, "raw"),
    ("injector_event_phase_offset_87b1_24x9", 0x87B1, 24, 9, "raw phase"),
    ("injector_phase_slew_limit_8889", 0x8889, 1, 1, "raw"),
    ("idle_air_bypass_target_888e_24x9", 0x888E, 24, 9, "raw"),
    ("idle_afterstart_condition_threshold_896f", 0x896F, 1, 1, "raw"),
    ("cts_idle_target_cap_8970_1x17", 0x8970, 1, 17, "raw"),
    ("tps_afterstart_threshold_8990", 0x8990, 1, 1, "raw"),
    ("rpm_closed_loop_entry_offset_899a_1x24", 0x899A, 1, 24, "raw"),
    ("spark_high_default_24x9", 0x8A69, 24, 9, "raw/2 deg"),
    ("spark_low_alternate_24x9", 0x8B41, 24, 9, "raw/2 deg"),
    ("wot_spark_vector_1x24", 0x8C19, 1, 24, "raw/2 deg"),
    ("spark_mode_vector_a_8c31_1x24", 0x8C31, 1, 24, "raw/2 deg"),
    ("spark_mode_vector_b_8c49_1x24", 0x8C49, 1, 24, "raw/2 deg"),
    ("spark_mode_vector_c_8c61_1x24", 0x8C61, 1, 24, "raw/2 deg"),
    ("spark_iat_load_corr_a_8c7c_signed_17x9", 0x8C7C, 17, 9, "signed8"),
    ("spark_cts_load_corr_b_8d15_signed_17x9", 0x8D15, 17, 9, "signed8"),
    ("spark_cts_temp_decay_8dae_1x17", 0x8DAE, 1, 17, "raw"),
    ("spark_cts_mode_delay_8dd9_1x9", 0x8DD9, 1, 9, "raw"),
    ("spark_state_decay_a_8e04_1x9", 0x8E04, 1, 9, "raw"),
    ("spark_state_decay_b_8e0d_1x9", 0x8E0D, 1, 9, "raw"),
    ("spark_state_decay_c_8e18_1x9", 0x8E18, 1, 9, "raw"),
    ("adaptive_entry_threshold_a_8e36_1x7", 0x8E36, 1, 7, "raw"),
    ("adaptive_entry_threshold_b_8e3d_1x7", 0x8E3D, 1, 7, "raw"),
    ("adaptive_entry_rpm_offset_a_8e46_1x17", 0x8E46, 1, 17, "raw"),
    ("adaptive_entry_rpm_offset_b_8e57_1x17", 0x8E57, 1, 17, "raw"),
    ("adaptive_trim_dynamics_a_8e6f_17x5", 0x8E6F, 17, 5, "raw"),
    ("adaptive_trim_dynamics_b_8ec7_17x5", 0x8EC7, 17, 5, "raw"),
    ("adaptive_trim_timer_8f1c_17x5", 0x8F1C, 17, 5, "raw"),
    ("adaptive_trim_hold_8f71_17x5", 0x8F71, 17, 5, "raw"),
    ("closed_loop_base_a_9000_1x17", 0x9000, 1, 17, "raw"),
    ("closed_loop_base_b_9011_1x17", 0x9011, 1, 17, "raw"),
    ("closed_loop_base_c_9022_1x17", 0x9022, 1, 17, "raw"),
    ("closed_loop_initial_delay_9033_1x17", 0x9033, 1, 17, "raw"),
    ("closed_loop_timer_reload_9044_1x17", 0x9044, 1, 17, "raw"),
    ("closed_loop_dynamic_load_9068_1x11", 0x9068, 1, 11, "raw"),
    ("closed_loop_ramp_target_9073_11x9", 0x9073, 11, 9, "raw"),
    ("closed_loop_ramp_temp_scale_90d6_1x9", 0x90D6, 1, 9, "raw"),
    ("closed_loop_state_delay_90ef_1x17", 0x90EF, 1, 17, "raw"),
    ("load_aircharge_model_factor_9187_24x9", 0x9187, 24, 9, "raw/230 hypothesis"),
    ("rpm_axis_period_1x24", 0x929E, 1, 24, "period axis"),
    ("likely_cts_adc_breakpoints_b_92cf_1x9", 0x92CF, 1, 9, "raw"),
    ("likely_iat_adc_breakpoints_a_92d9_1x9", 0x92D9, 1, 9, "raw"),
    ("fuel_output_scheduler_scale_92fa_1x9", 0x92FA, 1, 9, "raw"),
    ("scheduler_2040_signed_subvector_9303_1x10", 0x9303, 1, 10, "signed8"),
    ("temp_raw_output_c_plus_40_400e_1x9", 0x400E, 1, 9, "raw"),
    ("control_scalars_1x6", 0x89ED, 1, 6, "raw"),
    ("ignition_phase_factor_89c7_1x19", 0x89C7, 1, 19, "raw"),
    ("ignition_width_dwell_factor_89da_1x19", 0x89DA, 1, 19, "raw"),
    ("per_event_retard_gain_89f3_1x19", 0x89F3, 1, 19, "raw"),
    ("ignition_retard_activation_scalars_8a23_1x4", 0x8A23, 1, 4, "raw"),
    ("per_event_retard_cap_8a52_1x19", 0x8A52, 1, 19, "raw"),
]

TABLE_BASES = [
    0x7CDA,
    0x7CEA,
    0x802B,
    0x8010,
    0x8028,
    0x802A,
    0x802E,
    0x80EB,
    0x80F1,
    0x8103,
    0x8106,
    0x81A8,
    0x81DB,
    0x81DC,
    0x81DE,
    0x81E0,
    0x81F8,
    0x821C,
    0x82F4,
    0x8318,
    0x83F0,
    0x8408,
    0x8419,
    0x841A,
    0x841B,
    0x843D,
    0x844E,
    0x844F,
    0x8451,
    0x8452,
    0x845B,
    0x846C,
    0x847D,
    0x848E,
    0x849F,
    0x84B0,
    0x84C1,
    0x84D2,
    0x84E3,
    0x84EC,
    0x84ED,
    0x84F6,
    0x8508,
    0x8511,
    0x8529,
    0x853B,
    0x8544,
    0x8545,
    0x8546,
    0x8558,
    0x8561,
    0x8579,
    0x858B,
    0x8595,
    0x8596,
    0x859F,
    0x85A8,
    0x85A9,
    0x85AA,
    0x85AB,
    0x85AE,
    0x85AF,
    0x85BA,
    0x8636,
    0x863F,
    0x8648,
    0x8652,
    0x8671,
    0x8689,
    0x869A,
    0x877B,
    0x877E,
    0x8787,
    0x8789,
    0x87A6,
    0x87AB,
    0x87B1,
    0x879E,
    0x87A0,
    0x8889,
    0x888E,
    0x89C7,
    0x89DA,
    0x89ED,
    0x89F3,
    0x8A23,
    0x8967,
    0x896D,
    0x896E,
    0x896F,
    0x8970,
    0x8981,
    0x8990,
    0x899A,
    0x8A27,
    0x8A3A,
    0x8A52,
    0x8A69,
    0x8B41,
    0x8C19,
    0x8C31,
    0x8C49,
    0x8C61,
    0x8C7C,
    0x8D15,
    0x8DAE,
    0x8DD9,
    0x8E04,
    0x8E0D,
    0x8E18,
    0x8E36,
    0x8E3D,
    0x8E46,
    0x8E57,
    0x8E6F,
    0x8EC7,
    0x8F1C,
    0x8F71,
    0x9000,
    0x9011,
    0x9022,
    0x9033,
    0x9044,
    0x9055,
    0x9068,
    0x9073,
    0x90D6,
    0x90EF,
    0x9100,
    0x912B,
    0x9187,
    0x9291,
    0x929E,
    0x92CF,
    0x92D9,
    0x92FA,
    0x9303,
    0x400E,
]

PEUGEOT_HELPERS = [0xB2D6, 0xB2AB, 0xB383, 0xB3B9]
XANTIA_HELPERS = [0xB2CB, 0xB349]
HELPER_FOCUS_BY_ROM = {
    "peugeot_stock": PEUGEOT_HELPERS,
    "peugeot_stok": PEUGEOT_HELPERS,
    "peugeot_mod2": PEUGEOT_HELPERS,
    "peug_106rally_org": PEUGEOT_HELPERS,
    "xantia_607c": XANTIA_HELPERS,
    "rally13_ori": XANTIA_HELPERS,
}
RAM_TARGETS = [
    0x0060,
    0x0069,
    0x005D,
    0x005E,
    0x005F,
    0x00B6,
    0x00BC,
    0x00BF,
    0x00C1,
    0x00C3,
    0x00C5,
    0x00C6,
    0x00CC,
    0x00CE,
    0x00D0,
    0x100B,
    0x100E,
    0x1016,
    0x1018,
    0x101A,
    0x101C,
    0x1020,
    0x1022,
    0x1023,
    0x1028,
    0x1029,
    0x102A,
    0x1030,
    0x1031,
    0x1032,
    0x1033,
    0x1034,
    0x1050,
    0x2001,
    0x2002,
    0x2007,
    0x2008,
    0x2009,
    0x200A,
    0x200B,
    0x200C,
    0x200D,
    0x200E,
    0x2013,
    0x202B,
    0x202C,
    0x2030,
    0x2034,
    0x2036,
    0x2038,
    0x203A,
    0x203C,
    0x203E,
    0x2040,
    0x2042,
    0x2049,
    0x204A,
    0x204B,
    0x204D,
    0x204E,
    0x204F,
    0x2050,
    0x2051,
    0x2053,
    0x2055,
    0x2057,
    0x2059,
    0x2060,
    0x2062,
    0x2084,
    0x2085,
    0x2086,
    0x2090,
    0x2091,
    0x2093,
    0x2094,
    0x2095,
    0x2096,
    0x2097,
    0x2098,
    0x2099,
    0x209A,
    0x209B,
    0x209C,
    0x209E,
    0x20A0,
    0x20A2,
    0x20A4,
    0x20A6,
    0x20A8,
    0x20B1,
    0x20B9,
    0x20BC,
    0x20BD,
    0x20BE,
    0x20BF,
    0x20C0,
    0x20C1,
    0x20C2,
    0x20C3,
    0x20C4,
    0x20C5,
    0x20D3,
    0x20D4,
    0x20D5,
    0x20D6,
    0x20D7,
    0x20D8,
    0x20D9,
    0x20DA,
    0x20DB,
    0x20DC,
    0x20DD,
    0x20DE,
    0x20DF,
    0x20E0,
    0x20E1,
    0x20E2,
    0x20E3,
    0x20E4,
    0x20E5,
    0x20E6,
    0x20E7,
    0x20E8,
    0x20E9,
    0x20EB,
    0x20ED,
    0x2132,
    0x2134,
    0x2147,
    0x2148,
    0x2149,
    0x214C,
    0x2122,
    0x2124,
    0x21C6,
    0x21C8,
    0x21CB,
    0x21CD,
    0x21CF,
    0x2312,
    0x231E,
    0x232A,
    0x2336,
    0x2348,
    0x234A,
    0x234C,
    0x234D,
    0x2354,
    0x235C,
    0x235E,
    0x2369,
    0x2376,
    0x2380,
    0x2382,
    0x242B,
    0x242D,
    0x242F,
    0x2431,
    0x243C,
    0x243E,
    0x243F,
    0x244C,
    0x245E,
    0x2462,
    0x2463,
    0x2464,
    0x2465,
    0x249B,
    0x24AB,
    0x24AC,
    0x24AD,
    0x24AF,
    0x24B0,
    0x2483,
    0x2484,
    0x2486,
    0x2488,
    0x248D,
    0x248E,
    0x2584,
    0x2590,
    0x2596,
    0x25A3,
    0x2610,
]

EXTENDED_OPS = {
    0xB6: "LDAA ext",
    0xB7: "STAA ext",
    0xF6: "LDAB ext",
    0xF7: "STAB ext",
    0xFC: "LDD ext",
    0xFD: "STD ext",
    0xFE: "LDX ext",
    0xFF: "STX ext",
    0x7C: "INC ext",
    0x7A: "DEC ext",
    0x7D: "TST ext",
    0x7F: "CLR ext",
    0xBD: "JSR ext",
    0xBC: "CPX ext",
    0xB1: "CMPA ext",
    0xF1: "CMPB ext",
    0xB3: "SUBD ext",
    0xF3: "ADDD ext",
}

PREFIX18_EXTENDED_OPS = {
    0xCE: "LDY imm",
    0xFE: "LDY ext",
    0xFF: "STY ext",
    0xBC: "CPY ext",
    0xB3: "CPD? ext",
    0x83: "CPD imm",
}

DIRECT_OPS = {
    0x96: "LDAA dir",
    0x97: "STAA dir",
    0xD6: "LDAB dir",
    0xD7: "STAB dir",
    0xDC: "LDD dir",
    0xDD: "STD dir",
    0xDE: "LDX dir",
    0xDF: "STX dir",
    0x9C: "CPX dir",
    0x91: "CMPA dir",
    0xD1: "CMPB dir",
    0x93: "SUBD dir",
    0xD3: "ADDD dir",
}

PREFIX18_DIRECT_OPS = {
    0xDE: "LDY dir",
    0xDF: "STY dir",
    0x9C: "CPY dir",
}


def read_roms() -> dict[str, bytes]:
    roms: dict[str, bytes] = {}
    missing = []
    for spec in ROMS:
        if not spec.path.exists():
            missing.append(str(spec.path))
            continue
        data = spec.path.read_bytes()
        roms[spec.key] = data
    if missing:
        raise FileNotFoundError("Missing ROM files:\n" + "\n".join(missing))
    return roms


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def u16be(data: bytes, addr: int) -> int:
    if addr < 0 or addr + 1 >= len(data):
        return -1
    return (data[addr] << 8) | data[addr + 1]


def fmt_addr(addr: int) -> str:
    return f"0x{addr:04X}"


def checksum_pair(data: bytes) -> tuple[int, int]:
    return u16be(data, 0x800C), u16be(data, 0x800E)


def byte_sum(data: bytes) -> int:
    return sum(data[0x4000:]) & 0xFFFF


def checksum_valid(data: bytes) -> bool:
    w1, w2 = checksum_pair(data)
    return ((w1 + w2) & 0xFFFF) == 0xFFFF and byte_sum(data) == w2


def zero_range(data: bytes, start: int, end: int) -> bool:
    return all(value == 0 for value in data[start:end])


def find_diff_regions(a: bytes, b: bytes) -> list[tuple[int, int, int]]:
    regions = []
    start = None
    count = 0
    for i, (aa, bb) in enumerate(zip(a, b)):
        if aa != bb:
            if start is None:
                start = i
                count = 0
            count += 1
        elif start is not None:
            regions.append((start, i - 1, count))
            start = None
    if start is not None:
        regions.append((start, len(a) - 1, count))
    return regions


def table_bytes(data: bytes, addr: int, rows: int, cols: int) -> bytes:
    return data[addr : addr + rows * cols]


def signed8(value: int) -> int:
    return value - 0x100 if value & 0x80 else value


def table_values(data: bytes, addr: int, rows: int, cols: int, notes: str) -> list[int]:
    if notes.startswith("word16"):
        raw = data[addr : addr + rows * cols * 2]
        return [(raw[i] << 8) | raw[i + 1] for i in range(0, len(raw), 2)]
    values = list(table_bytes(data, addr, rows, cols))
    if notes.startswith("signed8"):
        return [signed8(value) for value in values]
    return values


def byte_stats(values: list[int]) -> dict[str, float]:
    if not values:
        return {"min": 0, "max": 0, "avg": 0.0, "zeros": 0, "ff": 0}
    return {
        "min": min(values),
        "max": max(values),
        "avg": sum(values) / len(values),
        "zeros": values.count(0),
        "ff": values.count(0xFF),
    }


def fmt_stats(stats: dict[str, float]) -> str:
    return f"{stats['min']:.0f}..{stats['max']:.0f} avg {stats['avg']:.1f}"


def rmse(left: bytes | list[int], right: bytes | list[int]) -> float:
    if not left:
        return 0.0
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(left, right)) / len(left))


def table_roughness(values: bytes | list[int], rows: int, cols: int) -> float:
    total = 0
    count = 0
    for row in range(rows):
        for col in range(cols):
            idx = row * cols + col
            if col + 1 < cols:
                total += abs(values[idx + 1] - values[idx])
                count += 1
            if row + 1 < rows:
                total += abs(values[idx + cols] - values[idx])
                count += 1
    return total / count if count else 0.0


def spark_alignment_score(stock: bytes, candidate: bytes, start: int) -> tuple[float, float, float, float]:
    stock_high = stock[0x8A69 : 0x8A69 + 216]
    stock_low = stock[0x8B41 : 0x8B41 + 216]
    stock_wot = stock[0x8C19 : 0x8C19 + 24]
    high = candidate[start : start + 216]
    low = candidate[start + 216 : start + 432]
    wot = candidate[start + 432 : start + 456]
    high_rmse = rmse(stock_high, high)
    low_rmse = rmse(stock_low, low)
    wot_rmse = rmse(stock_wot, wot)
    rough = table_roughness(high, 24, 9) + table_roughness(low, 24, 9)
    score = high_rmse + low_rmse + (wot_rmse * 0.5) + (rough * 0.15)
    return score, high_rmse, low_rmse, wot_rmse


def best_spark_alignment(stock: bytes, candidate: bytes) -> tuple[int, float, float, float, float]:
    best: tuple[int, float, float, float, float] | None = None
    for start in range(0x8900, 0x8D00):
        score, high_rmse, low_rmse, wot_rmse = spark_alignment_score(stock, candidate, start)
        row = (start, score, high_rmse, low_rmse, wot_rmse)
        if best is None or score < best[1]:
            best = row
    assert best is not None
    return best


def same_offset_table_delta(a: bytes, b: bytes, addr: int, length: int, notes: str = "raw") -> tuple[int, int, int, float]:
    av = list(a[addr : addr + length])
    bv = list(b[addr : addr + length])
    if notes.startswith("word16"):
        av = [(av[i] << 8) | av[i + 1] for i in range(0, len(av), 2)]
        bv = [(bv[i] << 8) | bv[i + 1] for i in range(0, len(bv), 2)]
    if notes.startswith("signed8"):
        av = [signed8(value) for value in av]
        bv = [signed8(value) for value in bv]
    diffs = [bb - aa for aa, bb in zip(av, bv) if aa != bb]
    if not diffs:
        return 0, 0, 0, 0.0
    return len(diffs), min(diffs), max(diffs), sum(diffs) / len(diffs)


def find_word_refs(data: bytes, value: int) -> list[tuple[int, str]]:
    hi, lo = value >> 8, value & 0xFF
    hits: list[tuple[int, str]] = []
    for i in range(0, len(data) - 1):
        if data[i] != hi or data[i + 1] != lo:
            continue
        context = "literal"
        if i >= 1:
            op = data[i - 1]
            if op == 0xCE:
                context = "LDX imm"
            elif op == 0xCC:
                context = "LDD imm"
            elif op in EXTENDED_OPS:
                context = EXTENDED_OPS[op]
        if i >= 2 and data[i - 2] == 0x18:
            context = PREFIX18_EXTENDED_OPS.get(data[i - 1], "prefix18 operand")
        hits.append((i, context))
    return hits


def scan_jsr_targets(data: bytes) -> Counter[int]:
    c: Counter[int] = Counter()
    for i in range(0, len(data) - 2):
        if data[i] == 0xBD:
            c[u16be(data, i + 1)] += 1
    return c


def call_sites(data: bytes, target: int) -> list[int]:
    hi, lo = target >> 8, target & 0xFF
    return [i for i in range(0, len(data) - 2) if data[i] == 0xBD and data[i + 1] == hi and data[i + 2] == lo]


def scan_ram_refs(data: bytes, targets: Iterable[int]) -> dict[int, list[tuple[int, str]]]:
    target_set = set(targets)
    refs: dict[int, list[tuple[int, str]]] = defaultdict(list)

    for i in range(0, len(data) - 2):
        op = data[i]
        addr = u16be(data, i + 1)
        if addr in target_set and op in EXTENDED_OPS:
            refs[addr].append((i, EXTENDED_OPS[op]))

    for i in range(0, len(data) - 3):
        if data[i] == 0x18:
            op = data[i + 1]
            addr = u16be(data, i + 2)
            if addr in target_set and op in PREFIX18_EXTENDED_OPS:
                refs[addr].append((i, PREFIX18_EXTENDED_OPS[op]))

    direct_targets = {t for t in target_set if t <= 0x00FF}
    for i in range(0, len(data) - 1):
        op = data[i]
        addr = data[i + 1]
        if addr in direct_targets and op in DIRECT_OPS:
            refs[addr].append((i, DIRECT_OPS[op]))

    for i in range(0, len(data) - 2):
        if data[i] == 0x18:
            op = data[i + 1]
            addr = data[i + 2]
            if addr in direct_targets and op in PREFIX18_DIRECT_OPS:
                refs[addr].append((i, PREFIX18_DIRECT_OPS[op]))
    return refs


def nearby_table_literals(data: bytes, site: int, radius: int = 24) -> list[str]:
    start = max(0, site - radius)
    end = min(len(data) - 2, site + radius)
    found = []
    for base in TABLE_BASES:
        hi, lo = base >> 8, base & 0xFF
        for i in range(start, end):
            if data[i] == hi and data[i + 1] == lo:
                found.append(f"{fmt_addr(base)} at {fmt_addr(i)}")
                break
    return found


def print_rom_overview(roms: dict[str, bytes]) -> None:
    print("## ROM Overview")
    print()
    print("| Key | Label | Size | SHA256 | Checksum words | Pair sum | Byte sum 0x4000-0xFFFF | Valid checksum | Zero 0x0000-0x3FFF | Zero 0xB600-0xB7FF | Reset vector |")
    print("| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |")
    for spec in ROMS:
        data = roms[spec.key]
        w1, w2 = checksum_pair(data)
        rom_byte_sum = byte_sum(data)
        reset = u16be(data, 0xFFFE)
        print(
            f"| `{spec.key}` | {spec.label} | {len(data)} | `{sha256(data)}` | "
            f"`{fmt_addr(w1)}/{fmt_addr(w2)}` | `{fmt_addr((w1 + w2) & 0xFFFF)}` | "
            f"`{fmt_addr(rom_byte_sum)}` | {'yes' if checksum_valid(data) else 'no'} | "
            f"{'yes' if zero_range(data, 0x0000, 0x4000) else 'no'} | "
            f"{'yes' if zero_range(data, 0xB600, 0xB800) else 'no'} | `{fmt_addr(reset)}` |"
        )
    print()


def print_diff_summary(roms: dict[str, bytes]) -> None:
    pairs = [("peugeot_stock", spec.key) for spec in ROMS if spec.key != "peugeot_stock"]
    print("## Diff Regions")
    print()
    for left, right in pairs:
        regions = find_diff_regions(roms[left], roms[right])
        total = sum(c for _, _, c in regions)
        print(f"### `{left}` vs `{right}`")
        print()
        print(f"Total differing bytes: `{total}` in `{len(regions)}` contiguous regions.")
        print()
        print("| Start | End | Changed bytes |")
        print("| --- | --- | ---: |")
        display = regions[:40]
        for start, end, count in display:
            print(f"| `{fmt_addr(start)}` | `{fmt_addr(end)}` | {count} |")
        if len(regions) > len(display):
            print(f"| ... | ... | {len(regions) - len(display)} more regions omitted |")
        print()


def print_known_table_stats(roms: dict[str, bytes]) -> None:
    stock = roms["peugeot_stock"]
    print("## Known Table / Candidate Stats")
    print()
    comparison_headers = " | ".join(f"{key} values / delta" for key in COMPARISON_KEYS)
    print(f"| Name | Range | Shape | Peugeot values | {comparison_headers} | Notes |")
    print(f"| --- | --- | --- | --- | {' | '.join('---' for _ in COMPARISON_KEYS)} | --- |")
    for name, addr, rows, cols, notes in KNOWN_TABLES:
        length = rows * cols * (2 if notes.startswith("word16") else 1)
        s = byte_stats(table_values(stock, addr, rows, cols, notes))
        comparison_cells = []
        for key in COMPARISON_KEYS:
            other = roms[key]
            stats = byte_stats(table_values(other, addr, rows, cols, notes))
            count, delta_min, delta_max, delta_avg = same_offset_table_delta(stock, other, addr, length, notes)
            comparison_cells.append(
                f"`{fmt_stats(stats)}; "
                f"{count} cells {delta_min:+d}..{delta_max:+d} avg {delta_avg:+.1f}`"
            )
        print(
            f"| `{name}` | `{fmt_addr(addr)}-{fmt_addr(addr + length - 1)}` | `{rows}x{cols}` | "
            f"`{fmt_stats(s)}` | "
            f"{' | '.join(comparison_cells)} | {notes} |"
        )
    print()


def print_table_refs(roms: dict[str, bytes]) -> None:
    print("## Immediate Table-Base Reference Scan")
    print()
    for spec in ROMS:
        key = spec.key
        data = roms[key]
        print(f"### `{key}`")
        print()
        print("| Base | Hits | Contexts | First sites |")
        print("| --- | ---: | --- | --- |")
        for base in TABLE_BASES:
            hits = find_word_refs(data, base)
            contexts = Counter(ctx for _, ctx in hits)
            ctx_text = ", ".join(f"{name}:{count}" for name, count in contexts.most_common())
            first = ", ".join(fmt_addr(pos) for pos, _ in hits[:8])
            print(f"| `{fmt_addr(base)}` | {len(hits)} | {ctx_text or '-'} | {first or '-'} |")
        print()


def print_helper_calls(roms: dict[str, bytes]) -> None:
    print("## Helper / JSR Scan")
    print()
    for spec in ROMS:
        key = spec.key
        helpers = HELPER_FOCUS_BY_ROM.get(key, PEUGEOT_HELPERS + XANTIA_HELPERS)
        data = roms[key]
        targets = scan_jsr_targets(data)
        print(f"### `{key}`")
        print()
        print("Most common extended JSR targets:")
        print()
        print("| Target | Count |")
        print("| --- | ---: |")
        for target, count in targets.most_common(20):
            print(f"| `{fmt_addr(target)}` | {count} |")
        print()
        print("Focused helper calls:")
        print()
        print("| Helper | Count | First call sites | Nearby known table literals |")
        print("| --- | ---: | --- | --- |")
        for helper in helpers:
            sites = call_sites(data, helper)
            nearby = []
            for site in sites[:12]:
                for item in nearby_table_literals(data, site):
                    if item not in nearby:
                        nearby.append(item)
            print(
                f"| `{fmt_addr(helper)}` | {len(sites)} | "
                f"{', '.join(fmt_addr(s) for s in sites[:12]) or '-'} | "
                f"{', '.join(nearby[:12]) or '-'} |"
            )
        print()


def print_ram_refs(roms: dict[str, bytes]) -> None:
    print("## RAM / Register Reference Scan")
    print()
    for spec in ROMS:
        key = spec.key
        refs = scan_ram_refs(roms[key], RAM_TARGETS)
        print(f"### `{key}`")
        print()
        print("| Address | Count | Operations | First sites |")
        print("| --- | ---: | --- | --- |")
        for addr in RAM_TARGETS:
            hits = sorted(refs.get(addr, []))
            operations = Counter(op for _, op in hits)
            ops = ", ".join(f"{op}:{count}" for op, count in operations.most_common())
            first = ", ".join(fmt_addr(pos) for pos, _ in hits[:10])
            print(f"| `{fmt_addr(addr)}` | {len(hits)} | {ops or '-'} | {first or '-'} |")
        print()


def print_targeted_trace_notes(roms: dict[str, bytes]) -> None:
    stock = roms["peugeot_stock"]
    print("## Targeted Trace Notes")
    print()

    for addr, rows, cols, notes in (
        (0x802B, 24, 9, "signed8"),
        (0x802E, 21, 9, "raw"),
        (0x802E, 24, 9, "raw"),
        (0x80EB, 21, 9, "signed8"),
        (0x80F1, 25, 9, "signed8"),
        (0x8103, 24, 9, "signed8"),
        (0x81A8, 5, 9, "raw"),
        (0x81F8, 4, 9, "signed8 low-rpm"),
        (0x821C, 24, 9, "signed8"),
        (0x82F4, 4, 9, "signed8 low-rpm"),
        (0x8318, 24, 9, "signed8"),
        (0x83F0, 1, 24, "signed8"),
        (0x81E0, 1, 24, "raw"),
        (0x8408, 1, 17, "raw"),
        (0x841B, 1, 17, "word16 raw"),
        (0x843D, 1, 17, "raw"),
        (0x8452, 1, 9, "raw"),
        (0x845B, 1, 17, "raw"),
        (0x846C, 1, 17, "raw"),
        (0x847D, 1, 17, "raw"),
        (0x848E, 1, 17, "raw"),
        (0x849F, 1, 17, "raw"),
        (0x84B0, 1, 17, "raw"),
        (0x84C1, 1, 17, "raw"),
        (0x84D2, 1, 17, "raw"),
        (0x84E3, 1, 9, "raw"),
        (0x84EC, 1, 1, "raw"),
        (0x84ED, 1, 9, "raw"),
        (0x84F6, 1, 9, "word16 raw"),
        (0x8508, 1, 9, "raw"),
        (0x8511, 1, 24, "raw"),
        (0x8529, 1, 9, "word16 raw"),
        (0x853B, 1, 9, "raw"),
        (0x8546, 1, 9, "word16 raw"),
        (0x8558, 1, 9, "raw"),
        (0x8561, 1, 24, "raw"),
        (0x8579, 1, 9, "word16 raw"),
        (0x858B, 1, 9, "raw"),
        (0x8596, 1, 9, "raw"),
        (0x859F, 1, 9, "raw"),
        (0x85AF, 1, 9, "raw"),
        (0x85BA, 24, 5, "raw"),
        (0x8636, 1, 9, "raw"),
        (0x863F, 1, 9, "raw"),
        (0x8648, 1, 9, "raw"),
        (0x8652, 1, 9, "raw"),
        (0x8671, 1, 9, "raw"),
        (0x8689, 1, 9, "raw"),
        (0x869A, 24, 9, "raw countdown ticks"),
        (0x877E, 1, 9, "raw"),
        (0x8787, 1, 1, "word16 raw"),
        (0x8789, 1, 9, "word16 raw"),
        (0x87A6, 1, 5, "raw"),
        (0x87AB, 1, 6, "raw"),
        (0x87B1, 24, 9, "raw"),
        (0x888E, 24, 9, "raw"),
        (0x8970, 1, 17, "raw"),
        (0x899A, 1, 24, "raw"),
        (0x8C31, 1, 24, "raw/2 deg"),
        (0x8C49, 1, 24, "raw/2 deg"),
        (0x8C61, 1, 24, "raw/2 deg"),
        (0x8C7C, 17, 9, "signed8"),
        (0x8D15, 17, 9, "signed8"),
        (0x8DAE, 1, 17, "raw"),
        (0x8DD9, 1, 9, "raw"),
        (0x8E04, 1, 9, "raw"),
        (0x8E0D, 1, 9, "raw"),
        (0x8E18, 1, 9, "raw"),
        (0x8E36, 1, 7, "raw"),
        (0x8E3D, 1, 7, "raw"),
        (0x8E46, 1, 17, "raw"),
        (0x8E57, 1, 17, "raw"),
        (0x8E6F, 17, 5, "raw"),
        (0x8EC7, 17, 5, "raw"),
        (0x8F1C, 17, 5, "raw"),
        (0x8F71, 17, 5, "raw"),
        (0x89C7, 1, 19, "raw"),
        (0x89DA, 1, 19, "raw"),
        (0x89F3, 1, 19, "raw"),
        (0x8A23, 1, 4, "raw"),
        (0x8A52, 1, 19, "raw"),
        (0x9000, 1, 17, "raw"),
        (0x9011, 1, 17, "raw"),
        (0x9022, 1, 17, "raw"),
        (0x9033, 1, 17, "raw"),
        (0x9044, 1, 17, "raw"),
        (0x9068, 1, 11, "raw"),
        (0x9073, 11, 9, "raw"),
        (0x90D6, 1, 9, "raw"),
        (0x90EF, 1, 17, "raw"),
        (0x92CF, 1, 9, "raw"),
        (0x92D9, 1, 9, "raw"),
        (0x92FA, 1, 9, "raw"),
        (0x9303, 1, 10, "signed8"),
        (0x400E, 1, 9, "raw"),
    ):
        cell_count = rows * cols
        length = cell_count * (2 if notes.startswith("word16") else 1)
        refs = find_word_refs(stock, addr)
        print(
            f"- `{fmt_addr(addr)}` `{rows}x{cols}` ({notes}): Peugeot immediate word-reference hits `{len(refs)}`."
        )
        for key in COMPARISON_KEYS:
            count, delta_min, delta_max, delta_avg = same_offset_table_delta(stock, roms[key], addr, length, notes)
            print(f"  - `{key}` differs in `{count}/{cell_count}` cells (`{delta_min:+d}..{delta_max:+d}`, avg `{delta_avg:+.1f}`).")

    print()
    print("Sensor-axis split note: `0x200A -> 0x2124 -> 0x92D9` builds runtime `0x2038/0x203A`, while `0x2008 -> 0x2122 -> 0x92CF` builds runtime `0x203C/0x203E`. Both raw helper vectors carry the NTC-matching ADC breakpoints `12,20,34,57,93,142,191,227,246`; the adjacent count bytes `0x92E2` and `0x92D8` are both `0x09`. Shared vector `0x400E` stores `160,140,120,100,80,60,40,20,0`, best interpreted as temperature raw output `deg C + 40`, so raw helper labels stay hot-to-cold as `120,100,80,60,40,20,0,-20,-40 deg C`. Runtime consumer maps use the firmware-inverted axis and display cold-to-hot labels. By consumers, `0x2038/0x203A` is now the best likely IAT/air-temperature axis and `0x203C/0x203E` is the best likely CTS/coolant axis; pin or bench proof is still pending.")
    print("Signed IAT/RPM fuel correction axis note: `0x802B` and `0x8103` use the `0x92D9 -> 0x2038` likely IAT axis and RPM labels from `0x929E -> 0x2036`; their XDF X labels now display the firmware-inverted consumer order `-40..120 deg C` rather than raw ADC breakpoints. Outputs are `0x204A`/`0x204D`.")
    print("Retired boundary-probe note: `0x80EB` is `0x802B + 0xC0`, starts at a non-row-aligned offset inside signed table A, and the old 21x9 view crosses into signed table B at `0x8103`. It has no Peugeot immediate word-reference hits and is historical evidence only, not an active XDF table.")
    print()
    print("Fuel/charge path note: `0x9187 -> 0x00D0/0x00CE` remains the upstream load/air-charge model; `0x802B/0x8103 -> 0x204B/0x204E` supplies signed likely IAT/RPM corrections; `0x821C/0x8318` signed fuel quantity trims, guarded low-RPM `0x81F8/0x82F4` 4x9 trims, or `0x83F0` RPM-only trim feed `0x2084 -> 0x00C1` through `0xE715`; and `0x00C1 -> 0x2051/0x00C3 -> 0x00BC` is the current strongest software fuel pulse-width / event-width path. `0xE715` scale is roughly fuel += fuel * signed_trim / 256, so raw 64 is about +25%.")
    print("Fast closed-loop fuel-correction note: `0x200C -> 0x5B1B -> 0x43DC -> 0x00CC -> 0x2040 -> 0x84E3 -> 0x2049 -> 0x00C1` is a code-traced fuel correction path, with `$2040 = max($00CC - 0x8000, 0) >> 4`. DHC11 labels prove `0x84E3` is a separate 1x9 vector, `0x84EC` is a standalone threshold byte, and `0x84ED` begins the CTS scheduler threshold vector. The software closed-loop role is strong, but the `0x200C` physical O2/lambda channel assignment still needs scope or harness proof.")
    print("Closed-loop/adaptive note: `0x9000-0x912B` is now best grouped as lambda / closed-loop / adaptive calibration. `0x9000/0x9011/0x9022` are CTS-like base vectors, `0x9033/0x9044/0x90EF` are delay/timer vectors, `0x9068` is dynamic load-change correction, and `0x9073` is a ramp/target table compared with `0x243C`.")
    print("Adaptive trim note: `0x20B9` is a slow closed-loop/adaptive fuel trim centred at `0x8000`. RAM cells `0x0060/0x0069` are learned adaptive trim cells interpolated by `0xC94B`; the `0x8E6F/0x8EC7/0x8F1C/0x8F71` 17x5 cluster feeds `0x24AB/0x24AF/0x24AC/0x24AD`, which are consumed by the `0xCC00-0xD0C6` adaptive state machine.")
    print("Warmup/transient note: `0x2059` is the warmup/afterstart state, with `0x00C5/0x00C6` active correction terms. `0x8408-0x84D2` are CTS warmup/afterstart fuel support maps. DHC11 adds exact warmup/startup helpers `0x841B`, `0x843D`, `0x8452`, and `0x84ED`. `0x84F6`, `0x853B`, `0x8546`, `0x858B`, and `0x859F` are CTS `$203C` transient support vectors/word tables feeding `$2588`, `$206B`, `$2586`, `$2079`, and `$2054`; `0x8508`, `0x8529`, `0x8558`, and `0x8579` are `$2042` transient support vectors/word tables feeding `$206D`, `$206E/$2070`, `$207B`, and `$207E/$207C`; `0x8511` and `0x8561` are RPM transient gain vectors feeding `$206C/$207A`; `0x8596/0x85AF` feed additive transient fuel terms `0x2055/0x2057` via the `0xEB16` helper.")
    print("Fuel-cut/state-delay note: `0x869A` is a code-confirmed `24x9` B2D6 table used by routine `0x9B79`. Its X axis is positive load rise since state entry: `$2394` snapshots `$00CE`, then the lookup uses clamped `$2014 - $2394`, scaled to internal index `0.00..8.00` with the final column saturated at `>=512` raw counts. Its Y axis is RPM `$2036`. Output stores to `$2391`, which the surrounding state machine decrements; when the delay expires, that path sets `$00A3=0x04`, clears `$00AB`, and zeros `$00C3`. Treat Z values as raw countdown ticks, not fuel quantity, spark, VE, or a limiter threshold.")
    print("Idle/actuator note: `0x888E` is best treated as an idle-air / idle-bypass target table, not fuel. It combines with likely CTS vector `0x8970` into `0x2484/0x2486`, shapes `0x202B`, and toggles external bit `0x1050.04`; actuator hardware proof remains open. DHC11 exact lookup views `0x8636/0x863F/0x8648` feed `$20A8` from `$203C`, `0x8652/0x8671` feed `$210E/$2110` from `$2042`, `0x8689` feeds `$20F6` from `$203C`, and `0x899A` feeds closed-loop entry offset `$20F5` from RPM.")
    print("SPI frame note: `0x8010-0x8027` is a pointer frame consumed by `0x9F02-0xA001` to stream live RAM/status bytes through SPI data register `0x102A`. It is not calibration; the signed fuel correction table starts at `0x802B`.")
    print("Fuel output timing note: `0x87B1 -> 0x00BE -> 0x21C6` is injector/event phase. OC1 schedules the interrupt at `TOC1=0x00B8+0x21C6` (`0x1016`), then vector `0x6FE4` configures OC3/PA5 action bits at `0x1020`, forces an OC3 edge through `0x100B`, and schedules the opposite edge at `0x101A`. `0x00C3 -> 0x00BC` is pulse width / scheduled event width, while `0x85BA -> 0x2063 -> 0x00C3` is high-load duration support.")
    print("Fuel output support-vector note: `$2040 = max($00CC - 0x8000, 0) >> 4` indexes scheduler support at `0x92FA`, `0x877E`, and `0x8789`; DHC11 also uses exact signed subvector base `0x9303` to feed `$2048`. XDF axes use decimal `$00CC` display labels `32768..65535` for the human hex mapping `0x8000, 0x9000, 0xA000, 0xB000, 0xC000, 0xD000, 0xE000, 0xF000, 0xFFFF/end`; `0x9303` uses `65536` only as a numeric display sentinel for its guard/unproven final cell. `0x92FA` is a separate unsigned 1x9 table whose interpolated byte is multiplied by 40 and stored to `$2388`; `0x9303` begins immediately afterward but is not part of that table. `0x877E` feeds `$00BF`; `0x8787` is the OC3 period-fit guard word; `0x8789` is a provisional 1x9 word vector that feeds `$2086`, an OC3 edge-offset/deadline-style term, not fuel quantity and not normal injector battery deadtime. Normal inactive-output edge timing is best summarized as `TOC3 = $21CB + $2086 + $00BC + 5`. The optional 0x8789 ms display assumes 2 us/tick; crank-degree conversion remains documented-only until E-clock and timer prescaler are proven.")
    print("Ignition event note: `0x7CDA` and `0x7CEA` are compact event selector data tables, not executable code and not tune maps. They feed four 12-byte ignition event records at `0x2312/0x231E/0x232A/0x2336`, built from final per-event spark values `0x20E2-0x20E5`.")
    print("Ignition output note: `0x2147 -> 0x2001 -> 0x00B6 -> 0x20E2-0x20E5 -> 0x2312/0x231E/0x232A/0x2336` is the current best software spark command/event chain. `0x89C7 -> 0x20E7 -> 0x20EB` looks like ignition phase, `0x89DA -> 0x20E8 -> 0x20ED` like width/dwell-window, `0x89F3 -> 0x20BC` is per-event retard/gain candidate, and `0x8A23-0x8A51` holds retard strategy scalars. DHC11 exact lookup views `0x87A6/0x87AB` feed spark transition output `$214F`, while `0x8E04/0x8E0D/0x8E18` feed `$2146` in spark-state decay branches. OC2/OC4 at `0x1018/0x101C` are the strongest software ignition-output candidates; exact coil driver/pin proof remains open.")
    print("Adaptive entry note: DHC11 exact lookup views `0x8E36/0x8E3D` are mixed byte/word threshold records used by the `0xCC00` closed-loop/adaptive entry gate, while `0x8E46/0x8E57` are `$2044`-indexed RPM-offset vectors added to `$00C9` before the same entry comparison. Values are raw because the threshold fields are heterogeneous and the state-machine naming is still provisional.")
    print()
    print("Main fuel status: a pure VE/base table is still not proven, but `0x821C/0x8318` are now the strongest signed fuel quantity trim tables. `0x81F8/0x82F4` are guarded low-RPM 4x9 trims selected by `0xE38B`, and `0x83F0` is an RPM-only trim/bypass vector. Fuel quantity/duration and fuel timing/phase are now separated: `$00C3/$00BC` is duration, `$21C6` is phase, and `$2086` is edge-offset support. The exact injector driver/pin remains a hardware-level proof item. The old `0x802E` VE-looking surface remains a legacy misaligned slice inside the signed `0x802B` table.")

    print()
    print("Spark alignment scan against Peugeot stock 24x9+24x9+1x24 bundle:")
    print()
    print("| ROM | Best high-bank start | Shift vs 0x8A69 | RMSE high | RMSE low | RMSE WOT | Notes |")
    print("| --- | --- | ---: | ---: | ---: | ---: | --- |")
    for spec in ROMS:
        key = spec.key
        start, score, high_rmse, low_rmse, wot_rmse = best_spark_alignment(stock, roms[key])
        shift = start - 0x8A69
        notes = "same-offset"
        if key == "rally13_ori" and shift == 0x1B and high_rmse == 0 and low_rmse == 0 and wot_rmse == 0:
            notes = "exact stock spark bundle shifted +0x1B"
        elif key == "peug_106rally_org" and shift == 0:
            notes = "same-offset but heavily altered spark banks; WOT vector unchanged"
        elif shift != 0:
            notes = "same-family offset candidate only"
        print(
            f"| `{key}` | `{fmt_addr(start)}` | `{shift:+d}` | "
            f"{high_rmse:.1f} | {low_rmse:.1f} | {wot_rmse:.1f} | {notes} |"
        )

    ram_refs = scan_ram_refs(stock, RAM_TARGETS)
    print()
    for addr in (
        0x00B6,
        0x00BC,
        0x00BF,
        0x00C1,
        0x00C3,
        0x00C5,
        0x00C6,
        0x00CC,
        0x2001,
        0x2002,
        0x202B,
        0x202C,
        0x2040,
        0x2049,
        0x204A,
        0x204B,
        0x204D,
        0x204E,
        0x204F,
        0x2050,
        0x2051,
        0x2053,
        0x2055,
        0x2057,
        0x2059,
        0x2060,
        0x2062,
        0x2084,
        0x2085,
        0x2086,
        0x2090,
        0x2093,
        0x2094,
        0x2095,
        0x2096,
        0x2099,
        0x209A,
        0x209B,
        0x20A2,
        0x20A4,
        0x20A6,
        0x20B9,
        0x20D3,
        0x20D4,
        0x20D9,
        0x20DA,
        0x20DB,
        0x20DC,
        0x20DE,
        0x20DF,
        0x20E0,
        0x20E1,
        0x20E2,
        0x20E3,
        0x20E4,
        0x20E5,
        0x20E6,
        0x20E7,
        0x20E8,
        0x20EB,
        0x20ED,
        0x2132,
        0x2134,
        0x21C6,
        0x21C8,
        0x21CB,
        0x21CD,
        0x21CF,
        0x2312,
        0x231E,
        0x232A,
        0x2336,
        0x243C,
        0x243E,
        0x243F,
        0x244C,
        0x245E,
        0x2483,
        0x2484,
        0x2486,
        0x2488,
        0x248D,
        0x248E,
        0x249B,
        0x24AB,
        0x24AC,
        0x24AD,
        0x24AF,
        0x24B0,
        0x2584,
        0x2590,
        0x2596,
        0x25A3,
        0x2610,
        0x100B,
        0x100E,
        0x1016,
        0x1018,
        0x101A,
        0x101C,
        0x1020,
        0x1022,
        0x1023,
        0x1028,
        0x1029,
        0x102A,
        0x1050,
        0x242B,
        0x242D,
        0x20BC,
        0x242F,
        0x2431,
    ):
        hits = sorted(ram_refs.get(addr, []))
        stores = [h for h in hits if h[1].startswith("ST") or h[1].startswith("CLR")]
        loads = [h for h in hits if h[1].startswith("LD") or h[1].startswith("CP") or h[1].startswith("ADD") or h[1].startswith("SUB")]
        print(
            f"- `{fmt_addr(addr)}`: `{len(hits)}` scanned refs; stores/clears at "
            f"{', '.join(fmt_addr(p) for p, _ in stores[:10]) or '-'}; loads/math at "
            f"{', '.join(fmt_addr(p) for p, _ in loads[:10]) or '-'}."
        )
    print()
    for addr in (0x1030, 0x1031, 0x1032, 0x1033, 0x1034, 0x2007, 0x2008, 0x2009, 0x200A, 0x200B, 0x200C, 0x200D, 0x200E, 0x2013, 0x2122, 0x2124, 0x2038, 0x203A, 0x203C, 0x203E, 0x2040, 0x2042, 0x00CE, 0x00D0, 0x2034):
        hits = sorted(ram_refs.get(addr, []))
        print(
            f"- `{fmt_addr(addr)}` ADC/load path: `{len(hits)}` scanned refs; first sites "
            f"{', '.join(fmt_addr(p) for p, _ in hits[:12]) or '-'}."
        )
    print()


SECTION_RENDERERS: dict[str, Callable[[dict[str, bytes]], None]] = {
    "overview": print_rom_overview,
    "diffs": print_diff_summary,
    "tables": print_known_table_stats,
    "refs": print_table_refs,
    "helpers": print_helper_calls,
    "ram": print_ram_refs,
    "trace": print_targeted_trace_notes,
}


def render_section(roms: dict[str, bytes], section: str) -> str:
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        SECTION_RENDERERS[section](roms)
    return out.getvalue()


def render_generated_analysis(roms: dict[str, bytes]) -> str:
    parts = [
        "## Generated Analyzer Snapshots\n",
        "Generated by `python tools/iaw8p40_analyze.py --write-analysis`.\n",
    ]
    for section in GENERATED_ANALYSIS_SECTIONS:
        parts.append(render_section(roms, section).rstrip())
        parts.append("")
    return "\n".join(parts).rstrip() + "\n"


def write_analysis_files(roms: dict[str, bytes]) -> None:
    generated = render_generated_analysis(roms)
    replacement = f"{GENERATED_BEGIN}\n{generated}{GENERATED_END}"
    text = EVIDENCE_PATH.read_text(encoding="ascii")
    begin = text.find(GENERATED_BEGIN)
    end = text.find(GENERATED_END)
    if begin == -1 or end == -1 or end < begin:
        raise ValueError(
            f"{EVIDENCE_PATH.relative_to(ROOT)} must contain "
            f"{GENERATED_BEGIN!r} and {GENERATED_END!r}"
        )
    end += len(GENERATED_END)
    updated = text[:begin] + replacement + text[end:]
    EVIDENCE_PATH.write_text(updated, encoding="ascii", newline="\n")
    print(f"updated {EVIDENCE_PATH.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--section",
        choices=["all", "overview", "diffs", "tables", "refs", "helpers", "ram", "trace"],
        default="all",
        help="Limit output to one section.",
    )
    parser.add_argument(
        "--write-analysis",
        action="store_true",
        help="Update the generated analyzer snapshot block in EVIDENCE.md and exit.",
    )
    args = parser.parse_args()

    roms = read_roms()
    for key, data in roms.items():
        if len(data) != 0x10000:
            raise ValueError(f"{key} is {len(data)} bytes, expected 65536")

    if args.write_analysis:
        write_analysis_files(roms)
        return

    sections = SECTION_RENDERERS if args.section == "all" else {args.section: SECTION_RENDERERS[args.section]}
    for section in sections:
        print(render_section(roms, section), end="")


if __name__ == "__main__":
    main()
