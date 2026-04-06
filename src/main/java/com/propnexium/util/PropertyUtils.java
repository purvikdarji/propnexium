package com.propnexium.util;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Utility methods for formatting property-related data.
 */
public final class PropertyUtils {

    private PropertyUtils() {
        /* utility class */ }

    /**
     * Format price in Indian Rupee format (e.g. ₹12,50,000).
     */
    public static String formatPrice(BigDecimal price) {
        if (price == null)
            return "N/A";
        NumberFormat formatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        return formatter.format(price);
    }

    /**
     * Convert price to human-readable label (e.g. "1.2 Cr", "45 L").
     */
    public static String toPriceLabel(BigDecimal price) {
        if (price == null)
            return "N/A";
        double val = price.doubleValue();
        if (val >= 10_000_000)
            return String.format("%.2f Cr", val / 10_000_000);
        if (val >= 100_000)
            return String.format("%.1f L", val / 100_000);
        return String.format("₹%.0f", val);
    }

    /**
     * Build a display-friendly area string.
     */
    public static String formatArea(BigDecimal areaSqft) {
        if (areaSqft == null)
            return "N/A";
        return String.format("%.0f sq.ft", areaSqft);
    }
}
