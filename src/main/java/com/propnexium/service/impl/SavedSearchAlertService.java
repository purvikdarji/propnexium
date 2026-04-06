package com.propnexium.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.SavedSearch;
import com.propnexium.event.PropertyApprovedEvent;
import com.propnexium.repository.SavedSearchRepository;
import com.propnexium.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SavedSearchAlertService {

    private final SavedSearchRepository savedSearchRepository;
    private final EmailService emailService;
    private final ObjectMapper objectMapper;

    @Async
    @EventListener
    public void handlePropertyApprovedEvent(PropertyApprovedEvent event) {
        Property newProperty = event.getProperty();
        log.info("Processing saved search alerts for newly approved property ID: {}", newProperty.getId());

        List<SavedSearch> allSavedSearches = savedSearchRepository.findAll();
        for (SavedSearch savedSearch : allSavedSearches) {
            try {
                SearchCriteriaDto criteria = objectMapper.readValue(savedSearch.getFiltersJson(), SearchCriteriaDto.class);
                
                if (matchesCriteria(newProperty, criteria)) {
                    log.info("Alerting User ID: {} for Saved Search ID: {}", savedSearch.getUser().getId(), savedSearch.getId());
                    
                    String subject = "New Property Match: " + savedSearch.getName();
                    String htmlMessage = String.format(
                        "<html><body style='font-family:Arial,sans-serif;padding:20px;'>" +
                        "<h2>New Property Match!</h2>" +
                        "<p>Hi %s,</p>" +
                        "<p>A new property just got listed that matches your saved search <strong>'%s'</strong>!</p>" +
                        "<div style='background:#f0f4ff;padding:15px;border-radius:8px;margin:15px 0;'>" +
                        "<strong>%s</strong><br>" +
                        "Price: ₹ %s<br>" +
                        "Location: %s, %s" +
                        "</div>" +
                        "<p><a href='%s/properties/%d' style='display:inline-block;padding:10px 20px;background:#1A73E8;color:white;text-decoration:none;border-radius:6px;'>View Listing</a></p>" +
                        "<p>Best,<br>The PropNexium Team</p>" +
                        "</body></html>",
                        savedSearch.getUser().getName(),
                        savedSearch.getName(),
                        newProperty.getTitle(),
                        newProperty.getPrice().toString(),
                        newProperty.getLocation(),
                        newProperty.getCity(),
                        "http://localhost:8080", // Ideally, pull this from config if needed, but and baseUrl is private to EmailServiceImpl
                        newProperty.getId()
                    );
                    
                    emailService.sendEmail(savedSearch.getUser().getEmail(), subject, htmlMessage);
                }
            } catch (Exception e) {
                log.error("Failed to parse filtersJson or send alert for SavedSearch ID: {}", savedSearch.getId(), e);
            }
        }
    }

    private boolean matchesCriteria(Property p, SearchCriteriaDto criteria) {
        // Keyword check (title or description or location contains keyword)
        if (criteria.getKeyword() != null && !criteria.getKeyword().isEmpty()) {
            String kw = criteria.getKeyword().toLowerCase();
            boolean matchKw = (p.getTitle() != null && p.getTitle().toLowerCase().contains(kw)) ||
                              (p.getDescription() != null && p.getDescription().toLowerCase().contains(kw)) ||
                              (p.getLocation() != null && p.getLocation().toLowerCase().contains(kw));
            if (!matchKw) return false;
        }

        // City check
        if (criteria.getCity() != null && !criteria.getCity().isEmpty()) {
            if (!criteria.getCity().equalsIgnoreCase(p.getCity())) return false;
        }

        // Type check
        if (criteria.getType() != null && !criteria.getType().isEmpty()) {
            if (p.getType() == null || !criteria.getType().equalsIgnoreCase(p.getType().name())) return false;
        }

        // Category check
        if (criteria.getCategory() != null && !criteria.getCategory().isEmpty()) {
            if (p.getCategory() == null || !criteria.getCategory().equalsIgnoreCase(p.getCategory().name())) return false;
        }

        // Min price
        if (criteria.getMinPrice() != null) {
            if (p.getPrice() == null || p.getPrice().compareTo(criteria.getMinPrice()) < 0) return false;
        }

        // Max price
        if (criteria.getMaxPrice() != null) {
            if (p.getPrice() == null || p.getPrice().compareTo(criteria.getMaxPrice()) > 0) return false;
        }

        // Bedrooms
        if (criteria.getBedrooms() != null) {
            if (p.getBedrooms() == null || p.getBedrooms() < criteria.getBedrooms()) return false;
        }

        // Furnishing
        if (criteria.getFurnishing() != null && !criteria.getFurnishing().isEmpty()) {
            if (p.getFurnishing() == null || !criteria.getFurnishing().equalsIgnoreCase(p.getFurnishing().name())) return false;
        }

        return true; // Passed all criteria
    }
}
