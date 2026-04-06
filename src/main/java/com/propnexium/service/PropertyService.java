package com.propnexium.service;

import com.propnexium.dto.request.PropertyCreateDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.enums.PropertyCategory;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.PropertyType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface PropertyService {

        Property createProperty(Property property);

        Optional<Property> findById(Long id);

        Page<Property> findAll(Pageable pageable);

        Page<Property> findByCity(String city, Pageable pageable);

        Page<Property> findByStatus(PropertyStatus status, Pageable pageable);

        /** Convenience overload used by admin controller (page/size as ints). */
        Page<Property> findByStatus(PropertyStatus status, int page, int size);

        /** Full-featured search used by the listing page. */
        Page<Property> searchProperties(String city, PropertyType type, PropertyCategory category,
                        Double minPrice, Double maxPrice, Integer bedrooms,
                        int page, int size, String sortBy, String sortDir);

        Page<Property> advancedSearch(String city, PropertyType type, PropertyCategory category,
                        BigDecimal minPrice, BigDecimal maxPrice, Integer minBedrooms,
                        Pageable pageable);

        List<Property> findSimilarProperties(String city, PropertyType type, Long excludeId, int limit);

        Property updateProperty(Property property);

        void deleteProperty(Long id);

        void updateStatus(Long propertyId, PropertyStatus status);

        void incrementViewCount(Long propertyId);

        List<Property> getFeaturedProperties();

        List<Property> findFeaturedProperties(int limit);

        List<java.util.Map<String, Object>> getPopularCitiesWithStats(int limit);

        List<Property> findAllByIdsOrdered(List<Long> ids);

        long countDistinctCities();

        // ─── Admin methods ────────────────────────────────────────────────────────

        long countAll();

        long countByStatus(PropertyStatus status);

        Map<String, Long> getPropertyCountByCity();

        Page<Property> findAllForAdmin(String status, int page, int size);

        boolean toggleFeatured(Long propertyId);

        // ─── Agent methods ────────────────────────────────────────────────────────

        long countByAgent(Long agentId);

        long countByAgentAndStatus(Long agentId, PropertyStatus status);

        /** Sum of viewCount across all properties owned by this agent. */
        long getTotalViewsByAgent(Long agentId);

        /** N most recently created properties by this agent. */
        List<Property> getRecentByAgent(Long agentId, int limit);

        Page<Property> findByAgent(Long agentId, Pageable pageable);

        // ─── Agent CRUD via DTO ───────────────────────────────────────────────────

        /**
         * Create a new property from DTO: build entity, save amenities,
         * upload images, notify admin.
         */
        Property createPropertyFromDto(PropertyCreateDto dto, Long agentId,
                        List<MultipartFile> images) throws Exception;

        /**
         * Update an existing property from DTO (ownership is verified inside).
         */
        Property updatePropertyFromDto(Long propertyId, Long agentId,
                        PropertyCreateDto dto, List<MultipartFile> newImages) throws Exception;

        /**
         * Soft-delete: marks the property as REJECTED / removes from listings.
         * Ownership is verified inside.
         */
        void softDeleteProperty(Long propertyId, Long agentId);

        /**
         * Returns distinct city names for AVAILABLE properties (used in search
         * dropdowns).
         */
        List<String> getDistinctCities();

        /**
         * Returns effective [lat, lng] for a property.
         * Falls back to city-centre coordinates if lat/lng are null/zero.
         */
        double[] getEffectiveLatLng(Property property);
}
