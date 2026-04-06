package com.propnexium.dto.request;

import lombok.*;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO carrying all search parameters submitted through the search form or URL query string.
 * Also provides helper methods used by the JSP layer:
 *   - toQueryString() – builds the URL params string for pagination links
 *   - getActiveFilterLabels() – returns display labels for active filter chips
 *   - hasFilters() – true when at least one filter is active
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SearchCriteriaDto {

    private String keyword;
    private String city;
    private String type;        // PropertyType enum value as String
    private String category;    // BUY or RENT
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private Integer bedrooms;
    private String furnishing;  // FurnishingType enum value as String

    @Builder.Default
    private int page = 0;

    @Builder.Default
    private int size = 9;

    /**
     * Returns URL query string (without leading ?) for pagination links.
     * Encodes values that may contain spaces or special characters.
     */
    public String toQueryString() {
        StringBuilder sb = new StringBuilder();
        if (keyword != null && !keyword.isEmpty())
            sb.append("&keyword=").append(URLEncoder.encode(keyword, StandardCharsets.UTF_8));
        if (city != null && !city.isEmpty())
            sb.append("&city=").append(URLEncoder.encode(city, StandardCharsets.UTF_8));
        if (type != null && !type.isEmpty())
            sb.append("&type=").append(type);
        if (category != null && !category.isEmpty())
            sb.append("&category=").append(category);
        if (minPrice != null)
            sb.append("&minPrice=").append(minPrice);
        if (maxPrice != null)
            sb.append("&maxPrice=").append(maxPrice);
        if (bedrooms != null)
            sb.append("&bedrooms=").append(bedrooms);
        if (furnishing != null && !furnishing.isEmpty())
            sb.append("&furnishing=").append(furnishing);
        return sb.toString();
    }

    /**
     * Returns human-readable labels for every active filter (used as "chips" in JSP).
     */
    public List<String> getActiveFilterLabels() {
        List<String> labels = new ArrayList<>();
        if (keyword != null && !keyword.isEmpty())
            labels.add("Keyword: " + keyword);
        if (city != null && !city.isEmpty())
            labels.add("City: " + city);
        if (type != null && !type.isEmpty())
            labels.add("Type: " + type);
        if (category != null && !category.isEmpty())
            labels.add("BUY".equals(category) ? "For Buy" : "For Rent");
        if (minPrice != null || maxPrice != null)
            labels.add("Price: " +
                    (minPrice != null ? "₹" + minPrice : "Any") + " – " +
                    (maxPrice != null ? "₹" + maxPrice : "Any"));
        if (bedrooms != null)
            labels.add(bedrooms + "+ BHK");
        if (furnishing != null && !furnishing.isEmpty())
            labels.add(furnishing);
        return labels;
    }

    /** Returns true when at least one filter field is populated. */
    public boolean hasFilters() {
        return (keyword != null && !keyword.isEmpty())
                || (city != null && !city.isEmpty())
                || type != null
                || category != null
                || minPrice != null
                || maxPrice != null
                || bedrooms != null
                || (furnishing != null && !furnishing.isEmpty());
    }
}
