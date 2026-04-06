package com.propnexium.dto;

import com.propnexium.entity.Property;
import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * Wraps a Property with its effective map coordinates for the search results Leaflet map.
 */
@Data
@AllArgsConstructor
public class SearchPropertyViewModel {
    private Property property;
    private double effectiveLat;
    private double effectiveLng;
}
