package com.propnexium.service.impl;

import com.propnexium.entity.Property;
import com.propnexium.entity.enums.PropertyCategory;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.PropertyType;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.PropertyAmenitiesRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.NotificationService;
import com.propnexium.service.PriceHistoryService;
import com.propnexium.service.PropertyService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.context.ApplicationEventPublisher;

import com.propnexium.event.PropertyApprovedEvent;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final PropertyAmenitiesRepository propertyAmenitiesRepository;
    private final NotificationService notificationService;
    private final PriceHistoryService priceHistoryService;
    private final ApplicationEventPublisher eventPublisher;

    // ─── City coordinate fallback ─────────────────────────────────────────────
    public static final Map<String, double[]> CITY_COORDINATES = Map.of(
        "Mumbai",    new double[]{19.0760, 72.8777},
        "Delhi",     new double[]{28.6139, 77.2090},
        "Bangalore", new double[]{12.9716, 77.5946},
        "Ahmedabad", new double[]{23.0225, 72.5714},
        "Pune",      new double[]{18.5204, 73.8567},
        "Chennai",   new double[]{13.0827, 80.2707},
        "Hyderabad", new double[]{17.3850, 78.4867},
        "Kolkata",   new double[]{22.5726, 88.3638}
    );

    @Override
    public double[] getEffectiveLatLng(Property property) {
        BigDecimal lat = property.getLatitude();
        BigDecimal lng = property.getLongitude();
        if (lat != null && lng != null
                && lat.compareTo(BigDecimal.ZERO) != 0
                && lng.compareTo(BigDecimal.ZERO) != 0) {
            return new double[]{lat.doubleValue(), lng.doubleValue()};
        }
        double[] fallback = CITY_COORDINATES.get(property.getCity());
        return fallback != null ? fallback : new double[]{23.0225, 72.5714};
    }

    @Override
    public Property createProperty(Property property) {
        return propertyRepository.save(property);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Property> findById(Long id) {
        return propertyRepository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findAll(Pageable pageable) {
        return propertyRepository.findAll(pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findByCity(String city, Pageable pageable) {
        return propertyRepository.findByCityIgnoreCase(city, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findByStatus(PropertyStatus status, Pageable pageable) {
        return propertyRepository.findByStatus(status, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findByStatus(PropertyStatus status, int page, int size) {
        return propertyRepository.findByStatus(
                status, PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> searchProperties(String city, PropertyType type, PropertyCategory category,
            Double minPrice, Double maxPrice, Integer bedrooms,
            int page, int size, String sortBy, String sortDir) {
        Sort sort = Sort.by("DESC".equalsIgnoreCase(sortDir)
                ? Sort.Direction.DESC
                : Sort.Direction.ASC, sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        BigDecimal min = (minPrice != null) ? BigDecimal.valueOf(minPrice) : null;
        BigDecimal max = (maxPrice != null) ? BigDecimal.valueOf(maxPrice) : null;
        return propertyRepository.advancedSearch(
                (city != null && city.isBlank()) ? null : city,
                type, category, min, max, bedrooms, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> advancedSearch(String city, PropertyType type, PropertyCategory category,
            BigDecimal minPrice, BigDecimal maxPrice, Integer minBedrooms, Pageable pageable) {
        return propertyRepository.advancedSearch(city, type, category, minPrice, maxPrice, minBedrooms, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Property> findSimilarProperties(String city, PropertyType type, Long excludeId, int limit) {
        return propertyRepository.findSimilarProperties(city, type, excludeId, PageRequest.of(0, limit));
    }

    @Override
    public Property updateProperty(Property property) {
        return propertyRepository.save(property);
    }

    @Override
    public void deleteProperty(Long id) {
        propertyRepository.deleteById(id);
    }

    @Override
    public void updateStatus(Long propertyId, PropertyStatus status) {
        propertyRepository.findById(propertyId).ifPresent(p -> {
            boolean wasNotAvailable = (p.getStatus() != PropertyStatus.AVAILABLE);

            p.setStatus(status);
            Property savedProperty = propertyRepository.save(p);

            // Trigger alert event only if the property transitions TO AVAILABLE
            if (status == PropertyStatus.AVAILABLE && wasNotAvailable) {
                eventPublisher.publishEvent(new PropertyApprovedEvent(this, savedProperty));
            }
        });
    }

    @Override
    public void incrementViewCount(Long propertyId) {
        propertyRepository.incrementViewCount(propertyId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Property> getFeaturedProperties() {
        return propertyRepository.findByIsFeaturedTrueAndStatus(PropertyStatus.AVAILABLE);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Property> findFeaturedProperties(int limit) {
        return propertyRepository.findFeaturedProperties(PageRequest.of(0, limit));
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPopularCitiesWithStats(int limit) {
        return propertyRepository.getPopularCitiesWithStats(limit);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Property> findAllByIdsOrdered(List<Long> ids) {
        if (ids == null || ids.isEmpty())
            return List.of();
        List<Property> properties = propertyRepository.findAllById(ids);

        // Re-sort the queried list according to the order of 'ids'
        Map<Long, Property> propertyMap = new java.util.HashMap<>();
        for (Property p : properties) {
            propertyMap.put(p.getId(), p);
        }

        List<Property> ordered = new java.util.ArrayList<>();
        for (Long id : ids) {
            if (propertyMap.containsKey(id)) {
                ordered.add(propertyMap.get(id));
            }
        }
        return ordered;
    }

    @Override
    @Transactional(readOnly = true)
    public long countDistinctCities() {
        return propertyRepository.countDistinctCitiesAvailable();
    }

    // ─── Admin methods ────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public long countAll() {
        return propertyRepository.count();
    }

    @Override
    @Transactional(readOnly = true)
    public long countByStatus(PropertyStatus status) {
        return propertyRepository.countByStatus(status);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Long> getPropertyCountByCity() {
        List<Object[]> rows = propertyRepository.countGroupByCity();
        Map<String, Long> map = new LinkedHashMap<>();
        for (Object[] row : rows) {
            map.put((String) row[0], (Long) row[1]);
        }
        return map;
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findAllForAdmin(String status, int page, int size) {
        PropertyStatus propStatus = null;
        if (status != null && !status.isBlank()) {
            try {
                propStatus = PropertyStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException ignored) {
            }
        }
        return propertyRepository.findAllForAdmin(
                propStatus,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    @Override
    public boolean toggleFeatured(Long propertyId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property", "id", propertyId));
        property.setIsFeatured(!property.getIsFeatured());
        propertyRepository.save(property);
        return property.getIsFeatured();
    }

    // ─── Agent methods ────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public long countByAgent(Long agentId) {
        return propertyRepository.countByAgentId(agentId);
    }

    @Override
    @Transactional(readOnly = true)
    public long countByAgentAndStatus(Long agentId, PropertyStatus status) {
        return propertyRepository.countByAgentIdAndStatus(agentId, status);
    }

    @Override
    @Transactional(readOnly = true)
    public long getTotalViewsByAgent(Long agentId) {
        return propertyRepository.sumViewCountByAgentId(agentId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Property> getRecentByAgent(Long agentId, int limit) {
        return propertyRepository.findRecentByAgentId(agentId, PageRequest.of(0, limit));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Property> findByAgent(Long agentId, Pageable pageable) {
        return propertyRepository.findByAgentId(agentId, pageable);
    }

    // ─── Agent DTO CRUD ───────────────────────────────────────────────────────

    @Override
    public Property createPropertyFromDto(com.propnexium.dto.request.PropertyCreateDto dto,
            Long agentId,
            java.util.List<org.springframework.web.multipart.MultipartFile> images)
            throws Exception {

        com.propnexium.entity.User agent = userRepository.findById(agentId)
                .orElseThrow(() -> new com.propnexium.exception.ResourceNotFoundException("User", "id", agentId));

        Property property = Property.builder()
                .agent(agent)
                .title(dto.getTitle())
                .description(dto.getDescription())
                .type(dto.getType())
                .category(dto.getCategory())
                .price(dto.getPrice() != null ? java.math.BigDecimal.valueOf(dto.getPrice())
                        : java.math.BigDecimal.ZERO)
                .priceNegotiable(Boolean.TRUE.equals(dto.getPriceNegotiable()))
                .maintenanceCharge(
                        dto.getMaintenanceCharge() != null ? java.math.BigDecimal.valueOf(dto.getMaintenanceCharge())
                                : null)
                .bedrooms(dto.getBedrooms() != null ? dto.getBedrooms() : 0)
                .bathrooms(dto.getBathrooms() != null ? dto.getBathrooms() : 0)
                .balconies(dto.getBalconies() != null ? dto.getBalconies() : 0)
                .areaSqft(dto.getAreaSqft() != null ? java.math.BigDecimal.valueOf(dto.getAreaSqft()) : null)
                .totalFloors(dto.getTotalFloors())
                .floorNumber(dto.getFloorNumber())
                .yearBuilt(dto.getYearBuilt())
                .furnishing(dto.getFurnishing() != null ? dto.getFurnishing()
                        : com.propnexium.entity.enums.Furnishing.UNFURNISHED)
                .parking(dto.getParking() != null ? dto.getParking() : com.propnexium.entity.enums.Parking.NONE)
                .facing(dto.getFacing())
                .city(dto.getCity())
                .location(dto.getLocation())
                .state(dto.getState())
                .pincode(dto.getPincode())
                .latitude(dto.getLatitude() != null ? java.math.BigDecimal.valueOf(dto.getLatitude()) : null)
                .longitude(dto.getLongitude() != null ? java.math.BigDecimal.valueOf(dto.getLongitude()) : null)
                .status(com.propnexium.entity.enums.PropertyStatus.UNDER_REVIEW)
                .build();

        Property saved = propertyRepository.save(property);

        // Save amenities
        com.propnexium.entity.PropertyAmenities amenities = com.propnexium.entity.PropertyAmenities.builder()
                .property(saved)
                .hasGym(Boolean.TRUE.equals(dto.getHasGym()))
                .hasSwimmingPool(Boolean.TRUE.equals(dto.getHasSwimmingPool()))
                .hasSecurity(Boolean.TRUE.equals(dto.getHasSecurity()))
                .hasLift(Boolean.TRUE.equals(dto.getHasLift()))
                .hasPowerBackup(Boolean.TRUE.equals(dto.getHasPowerBackup()))
                .hasClubHouse(Boolean.TRUE.equals(dto.getHasClubHouse()))
                .hasChildrenPlayArea(Boolean.TRUE.equals(dto.getHasChildrenPlayArea()))
                .hasGarden(Boolean.TRUE.equals(dto.getHasGarden()))
                .hasIntercom(Boolean.TRUE.equals(dto.getHasIntercom()))
                .hasRainwaterHarvesting(Boolean.TRUE.equals(dto.getHasRainwaterHarvesting()))
                .hasWasteManagement(Boolean.TRUE.equals(dto.getHasWasteManagement()))
                .hasVisitorParking(Boolean.TRUE.equals(dto.getHasVisitorParking()))
                .build();
        propertyAmenitiesRepository.save(amenities);

        // Notify admin(s)
        try {
            userRepository.findByRole(com.propnexium.entity.enums.UserRole.ADMIN)
                    .forEach(admin -> notificationService.createNotification(
                            admin.getId(),
                            "New Property Submitted for Review",
                            "Agent " + agent.getName() + " submitted: " + dto.getTitle(),
                            com.propnexium.entity.enums.NotificationType.SYSTEM,
                            "/properties/" + saved.getId()));
        } catch (Exception ignored) {
            // Notification failure should never block property creation
        }

        return saved;
    }

    @Override
    public Property updatePropertyFromDto(Long propertyId, Long agentId,
            com.propnexium.dto.request.PropertyCreateDto dto,
            java.util.List<org.springframework.web.multipart.MultipartFile> newImages)
            throws Exception {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(
                        () -> new com.propnexium.exception.ResourceNotFoundException("Property", "id", propertyId));

        if (!property.getAgent().getId().equals(agentId)) {
            throw new com.propnexium.exception.UnauthorizedAccessException("You can only edit your own properties");
        }

        property.setTitle(dto.getTitle());
        property.setDescription(dto.getDescription());
        property.setType(dto.getType());
        property.setCategory(dto.getCategory());
        
        if (dto.getPrice() != null) {
            BigDecimal oldPrice = property.getPrice();
            BigDecimal newPrice = BigDecimal.valueOf(dto.getPrice());
            if (oldPrice == null || oldPrice.compareTo(newPrice) != 0) {
                property.setPrice(newPrice);
                priceHistoryService.recordPriceChange(property, oldPrice != null ? oldPrice : BigDecimal.ZERO, newPrice, property.getAgent());
            }
        }
        
        property.setPriceNegotiable(Boolean.TRUE.equals(dto.getPriceNegotiable()));
        if (dto.getMaintenanceCharge() != null)
            property.setMaintenanceCharge(java.math.BigDecimal.valueOf(dto.getMaintenanceCharge()));
        if (dto.getBedrooms() != null)
            property.setBedrooms(dto.getBedrooms());
        if (dto.getBathrooms() != null)
            property.setBathrooms(dto.getBathrooms());
        if (dto.getBalconies() != null)
            property.setBalconies(dto.getBalconies());
        if (dto.getAreaSqft() != null)
            property.setAreaSqft(java.math.BigDecimal.valueOf(dto.getAreaSqft()));
        property.setTotalFloors(dto.getTotalFloors());
        property.setFloorNumber(dto.getFloorNumber());
        property.setYearBuilt(dto.getYearBuilt());
        if (dto.getFurnishing() != null)
            property.setFurnishing(dto.getFurnishing());
        if (dto.getParking() != null)
            property.setParking(dto.getParking());
        property.setFacing(dto.getFacing());
        property.setCity(dto.getCity());
        property.setLocation(dto.getLocation());
        property.setState(dto.getState());
        property.setPincode(dto.getPincode());
        if (dto.getLatitude() != null)
            property.setLatitude(java.math.BigDecimal.valueOf(dto.getLatitude()));
        if (dto.getLongitude() != null)
            property.setLongitude(java.math.BigDecimal.valueOf(dto.getLongitude()));

        Property updated = propertyRepository.save(property);

        // Update amenities
        com.propnexium.entity.PropertyAmenities amenities = propertyAmenitiesRepository.findByPropertyId(propertyId)
                .orElse(com.propnexium.entity.PropertyAmenities.builder().property(updated).build());

        amenities.setHasGym(Boolean.TRUE.equals(dto.getHasGym()));
        amenities.setHasSwimmingPool(Boolean.TRUE.equals(dto.getHasSwimmingPool()));
        amenities.setHasSecurity(Boolean.TRUE.equals(dto.getHasSecurity()));
        amenities.setHasLift(Boolean.TRUE.equals(dto.getHasLift()));
        amenities.setHasPowerBackup(Boolean.TRUE.equals(dto.getHasPowerBackup()));
        amenities.setHasClubHouse(Boolean.TRUE.equals(dto.getHasClubHouse()));
        amenities.setHasChildrenPlayArea(Boolean.TRUE.equals(dto.getHasChildrenPlayArea()));
        amenities.setHasGarden(Boolean.TRUE.equals(dto.getHasGarden()));
        amenities.setHasIntercom(Boolean.TRUE.equals(dto.getHasIntercom()));
        amenities.setHasRainwaterHarvesting(Boolean.TRUE.equals(dto.getHasRainwaterHarvesting()));
        amenities.setHasWasteManagement(Boolean.TRUE.equals(dto.getHasWasteManagement()));
        amenities.setHasVisitorParking(Boolean.TRUE.equals(dto.getHasVisitorParking()));
        propertyAmenitiesRepository.save(amenities);

        return updated;
    }

    @Override
    public void softDeleteProperty(Long propertyId, Long agentId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(
                        () -> new com.propnexium.exception.ResourceNotFoundException("Property", "id", propertyId));
        if (!property.getAgent().getId().equals(agentId)) {
            throw new com.propnexium.exception.UnauthorizedAccessException("You can only remove your own properties");
        }
        property.setStatus(com.propnexium.entity.enums.PropertyStatus.REJECTED);
        propertyRepository.save(property);
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getDistinctCities() {
        return propertyRepository.findDistinctCities();
    }
}
