package com.propnexium.controller.web;

import com.propnexium.dto.request.InquiryDto;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.dto.response.SearchResultDto;
import com.propnexium.entity.PriceHistory;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyCategory;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.PropertyType;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.PriceHistoryService;
import com.propnexium.service.PropertyService;
import com.propnexium.service.SearchService;
import com.propnexium.service.UserService;
import com.propnexium.service.WishlistService;
import com.propnexium.service.BookingService;
import com.propnexium.service.ReviewService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Web controller for property listing and detail pages.
 * When a keyword is present the request is routed through SearchService
 * which uses MySQL FULLTEXT search for relevance-ranked results.
 */
@Controller
@RequiredArgsConstructor
public class PropertyWebController {

    private final PropertyService propertyService;
    private final UserService userService;
    private final WishlistService wishlistService;
    private final SearchService searchService;
    private final PriceHistoryService priceHistoryService;
    private final UserRepository userRepository;
    private final PropertyRepository propertyRepository;
    private final BookingService bookingService;
    private final ReviewService reviewService;

    // ─── GET /properties ─────────────────────────────────────────────────────
    @GetMapping("/properties")
    public String listProperties(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Integer bedrooms,
            @RequestParam(required = false) String furnishing,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "9") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDir,
            Model model) {

        // Build criteria DTO
        SearchCriteriaDto criteria = SearchCriteriaDto.builder()
                .keyword(trimToNull(keyword))
                .city(trimToNull(city))
                .type(trimToNull(type))
                .category(trimToNull(category))
                .minPrice(minPrice)
                .maxPrice(maxPrice)
                .bedrooms(bedrooms)
                .furnishing(trimToNull(furnishing))
                .page(page)
                .size(size)
                .build();

        // If any filter (including keyword) is present, use FULLTEXT SearchService
        if (criteria.hasFilters()) {
            SearchResultDto result = searchService.search(criteria);
            model.addAttribute("properties", result.getProperties());
            model.addAttribute("totalPages", result.getTotalPages());
            model.addAttribute("totalElements", result.getTotalCount());
            model.addAttribute("currentPage", result.getCurrentPage());
            model.addAttribute("searchTimeMs", result.getSearchTimeMs());
            model.addAttribute("activeFilters", criteria.getActiveFilterLabels());
            model.addAttribute("searchCriteria", criteria);
        } else {
            // No filters: use plain paginated listing (faster)
            PropertyType propType = parseEnum(type, PropertyType.class);
            PropertyCategory propCat = parseEnum(category, PropertyCategory.class);

            Page<Property> propertyPage = propertyService.searchProperties(
                    city, propType, propCat,
                    minPrice != null ? minPrice.doubleValue() : null,
                    maxPrice != null ? maxPrice.doubleValue() : null,
                    bedrooms, page, size, sortBy, sortDir);

            model.addAttribute("properties", propertyPage.getContent());
            model.addAttribute("totalPages", propertyPage.getTotalPages());
            model.addAttribute("totalElements", propertyPage.getTotalElements());
            model.addAttribute("currentPage", page);
        }

        // Shared model attributes
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);

        // Filter pre-fill
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterCity", city);
        model.addAttribute("filterType", type);
        model.addAttribute("filterCategory", category);
        model.addAttribute("filterMinPrice", minPrice);
        model.addAttribute("filterMaxPrice", maxPrice);
        model.addAttribute("filterBedrooms", bedrooms);
        model.addAttribute("filterFurnishing", furnishing);

        // Dropdown options
        model.addAttribute("propertyTypes", PropertyType.values());
        model.addAttribute("propertyCategories", PropertyCategory.values());
        model.addAttribute("supportedCities",
                List.of("Mumbai", "Delhi", "Bangalore", "Pune",
                        "Hyderabad", "Chennai", "Kolkata", "Ahmedabad"));

        // Login status and wishlist for highlighting
        boolean isLoggedIn = false;
        List<Long> savedPropertyIds = new ArrayList<>();
        try {
            User currentUser = userService.getCurrentUser();
            if (currentUser != null) {
                isLoggedIn = true;
                savedPropertyIds = wishlistService.getUserWishlistPropertyIds(currentUser.getId());
            }
        } catch (Exception ignored) {}
        
        model.addAttribute("isLoggedIn", isLoggedIn);
        model.addAttribute("savedPropertyIds", savedPropertyIds);

        try {
            List<Property> currentProperties = (List<Property>) model.getAttribute("properties");
            if (currentProperties != null) {
                List<Map<String, Object>> mapMarkers = new ArrayList<>();
                for (Property p : currentProperties) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", p.getId());
                    m.put("title", p.getTitle());
                    m.put("price", p.getPrice());
                    m.put("bedrooms", p.getBedrooms());
                    
                    double[] latlng = propertyService.getEffectiveLatLng(p);
                    m.put("lat", latlng[0]);
                    m.put("lng", latlng[1]);
                    
                    if (p.getImages() != null && !p.getImages().isEmpty()) {
                        m.put("image", p.getImages().iterator().next().getImageUrl());
                    } else {
                        m.put("image", "");
                    }
                    mapMarkers.add(m);
                }
                String mapDataJson = new ObjectMapper().writeValueAsString(mapMarkers);
                model.addAttribute("mapDataJson", mapDataJson);
            }
        } catch (Exception e) {
            model.addAttribute("mapDataJson", "[]");
        }

        return "property/list";
    }

    // ─── GET /properties/{id} — detail page ──────────────────────────────────
    @GetMapping("/properties/{id}")
    public String propertyDetail(@PathVariable Long id, jakarta.servlet.http.HttpSession session, Model model) {
        Property property = propertyService.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Property", "id", id));

        propertyService.incrementViewCount(id);

        List<Property> similar = propertyService.findSimilarProperties(
                property.getCity(), property.getType(), id, 4);

        boolean isInWishlist = false;
        boolean isOwner = false;
        boolean hasBookedVisits = false;
        User currentUser = null;
        try {
            currentUser = userService.getCurrentUser();
        } catch (Exception ignored) {
            /* not authenticated */ }

        if (currentUser != null) {
            isInWishlist = wishlistService.isInWishlist(currentUser.getId(), id);
            isOwner = property.getAgent().getId().equals(currentUser.getId());
            hasBookedVisits = bookingService.hasUserBookedVisit(id, currentUser.getId());
            
            model.addAttribute("currentUserName", currentUser.getName());
            model.addAttribute("currentUserEmail", currentUser.getEmail());
            model.addAttribute("currentUserPhone", currentUser.getPhone());

            // Increment totalPropertiesViewed for authenticated users
            try {
                Integer viewed = currentUser.getTotalPropertiesViewed();
                currentUser.setTotalPropertiesViewed((viewed != null ? viewed : 0) + 1);
                userRepository.save(currentUser);
            } catch (Exception ignored) { /* non-critical tracking, don't break page load */ }
        }

        model.addAttribute("property", property);
        model.addAttribute("similarProperties", similar);
        model.addAttribute("isInWishlist", isInWishlist);
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("hasBookedVisits", hasBookedVisits);
        model.addAttribute("inquiryDto", new InquiryDto());

        // Agent rating data
        if (property.getAgent() != null) {
            Long agentId = property.getAgent().getId();
            double avgRating = reviewService.getAverageRating(agentId);
            int reviewCount = reviewService.getReviewsForAgent(agentId).size();
            model.addAttribute("agentAvgRating", avgRating);
            model.addAttribute("agentReviewCount", reviewCount);
        }
        
        List<PriceHistory> priceHistory = priceHistoryService.getPropertyPriceHistory(id);
        model.addAttribute("priceHistory", priceHistory);

        // ─── Map data ───────────────────────────────────────────────────
        double[] coords = propertyService.getEffectiveLatLng(property);
        model.addAttribute("propertyLat", coords[0]);
        model.addAttribute("propertyLng", coords[1]);

        List<Property> nearbyProperties = propertyRepository.findNearbyProperties(
                property.getCity(), PropertyStatus.AVAILABLE, property.getId(), PageRequest.of(0, 6));

        try {
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> nearbyMapData = nearbyProperties.stream().map(np -> {
                double[] c = propertyService.getEffectiveLatLng(np);
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", np.getId());
                m.put("title", np.getTitle());
                m.put("price", np.getPrice());
                m.put("lat", c[0]);
                m.put("lng", c[1]);
                return m;
            }).collect(Collectors.toList());
            model.addAttribute("nearbyMapDataJson", nearbyMapData.isEmpty() ? "[]" : mapper.writeValueAsString(nearbyMapData));
        } catch (Exception e) {
            model.addAttribute("nearbyMapDataJson", "[]");
        }

        // Track recently viewed in session
        @SuppressWarnings("unchecked")
        java.util.List<Long> recentlyViewed = (java.util.List<Long>) session.getAttribute("recentlyViewed");
        if (recentlyViewed == null)
            recentlyViewed = new java.util.ArrayList<>();

        // Remove if already exists (dedup), insert at front
        recentlyViewed.remove(id);
        recentlyViewed.add(0, id);

        // Cap at 10 entries
        if (recentlyViewed.size() > 10) {
            recentlyViewed = recentlyViewed.subList(0, 10);
        }
        session.setAttribute("recentlyViewed", recentlyViewed);

        return "property/detail";
    }

    // ─── Helper ──────────────────────────────────────────────────────────────
    private String trimToNull(String str) {
        return (str == null || str.trim().isEmpty()) ? null : str.trim();
    }

    private <E extends Enum<E>> E parseEnum(String value, Class<E> clazz) {
        if (value == null || value.isBlank())
            return null;
        try {
            return Enum.valueOf(clazz, value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
