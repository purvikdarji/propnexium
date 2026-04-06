package com.propnexium.util;

/**
 * Area units with their square-foot equivalents.
 * Conversion logic: 1 unit of [AreaUnit] = sqftEquivalent sq ft
 */
public enum AreaUnit {

    // ── Universal ───────────────────────────────────────────────
    SQFT("sq ft", 1.0),
    SQMT("sq mt", 10.7639),
    SQYD("sq yd", 9.0),
    ACRE("Acre", 43560.0),
    HECTARE("Hectare", 107639.0),

    // ── North India (UP, Bihar, MP, Rajasthan, Haryana, Punjab) ─
    BIGHA_NORTH("Bigha (North)", 27000.0),
    BISWA("Biswa", 1350.0),
    KATHA_BIHAR("Katha (Bihar)", 1361.0),
    KATHA_WB("Katha (WB/UP)", 720.0),

    // ── Gujarat / Rajasthan ──────────────────────────────────────
    BIGHA_GUJARAT("Bigha (Gujarat)", 17424.0),
    VIGHA("Vigha", 17424.0),
    VARA("Vara (Guj)", 9.0),

    // ── Maharashtra ──────────────────────────────────────────────
    GUNTHA("Guntha", 1089.0),
    ARE("Are", 1076.39),

    // ── South India (Karnataka, AP, Telangana) ───────────────────
    ANKANAM("Ankanam", 72.0),
    CENT("Cent", 435.6),
    GROUND("Ground", 2400.0),
    GUNTA("Gunta", 1089.0),

    // ── Tamil Nadu / Kerala ──────────────────────────────────────
    CENT_TN("Cent (TN)", 435.6),
    KUZHI("Kuzhi", 144.0);

    private final String displayName;
    private final double sqftEquivalent; // 1 unit of this = sqftEquivalent sq ft

    AreaUnit(String displayName, double sqftEquivalent) {
        this.displayName = displayName;
        this.sqftEquivalent = sqftEquivalent;
    }

    public String getDisplayName() {
        return displayName;
    }

    public double getSqftEquivalent() {
        return sqftEquivalent;
    }
}
