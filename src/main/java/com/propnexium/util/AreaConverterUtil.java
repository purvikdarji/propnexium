package com.propnexium.util;

import java.util.List;
import java.util.Map;

import static java.util.Map.entry;

/**
 * Utility class holding the state → available area units mapping.
 */
public final class AreaConverterUtil {

    private AreaConverterUtil() { /* utility class */ }

    /**
     * Maps each Indian state to the list of AreaUnit keys relevant for that state.
     * Falls back to universal units if a state is not listed.
     */
    public static final Map<String, List<String>> STATE_UNITS = Map.ofEntries(
        entry("Gujarat",        List.of("SQFT", "SQMT", "SQYD", "ACRE", "BIGHA_GUJARAT", "VIGHA", "VARA")),
        entry("Maharashtra",    List.of("SQFT", "SQMT", "SQYD", "ACRE", "GUNTHA", "ARE", "GUNTA")),
        entry("Karnataka",      List.of("SQFT", "SQMT", "SQYD", "ACRE", "ANKANAM", "GUNTA", "GROUND", "CENT")),
        entry("Tamil Nadu",     List.of("SQFT", "SQMT", "SQYD", "ACRE", "CENT_TN", "GROUND", "KUZHI")),
        entry("Kerala",         List.of("SQFT", "SQMT", "SQYD", "ACRE", "CENT_TN", "GROUND")),
        entry("Andhra Pradesh", List.of("SQFT", "SQMT", "SQYD", "ACRE", "ANKANAM", "GUNTA", "CENT", "GROUND")),
        entry("Uttar Pradesh",  List.of("SQFT", "SQMT", "SQYD", "ACRE", "BIGHA_NORTH", "BISWA", "KATHA_WB")),
        entry("Bihar",          List.of("SQFT", "SQMT", "SQYD", "ACRE", "KATHA_BIHAR", "BIGHA_NORTH", "BISWA")),
        entry("Rajasthan",      List.of("SQFT", "SQMT", "SQYD", "ACRE", "BIGHA_NORTH", "BIGHA_GUJARAT", "BISWA")),
        entry("Punjab",         List.of("SQFT", "SQMT", "SQYD", "ACRE", "BIGHA_NORTH", "BISWA")),
        entry("Delhi",          List.of("SQFT", "SQMT", "SQYD", "ACRE", "BIGHA_NORTH")),
        entry("West Bengal",    List.of("SQFT", "SQMT", "SQYD", "ACRE", "KATHA_WB", "BIGHA_NORTH"))
    );

    /** Default universal unit keys used when no state is selected. */
    public static final List<String> DEFAULT_UNITS =
            List.of("SQFT", "SQMT", "SQYD", "ACRE", "HECTARE");
}
