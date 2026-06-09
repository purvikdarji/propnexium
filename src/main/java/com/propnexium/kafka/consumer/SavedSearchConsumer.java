package com.propnexium.kafka.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.config.KafkaTopics;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.Property;
import com.propnexium.entity.SavedSearch;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.kafka.event.PropertyStatusChangedEvent;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.SavedSearchRepository;
import com.propnexium.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Kafka consumer for saved-search match alerts.
 *
 * Consumer group: {@code propnexium-saved-search-group}
 *
 * This replaces the previous {@code SavedSearchAlertService.handlePropertyApprovedEvent}
 * which was an {@code @Async @EventListener} triggered by a Spring
 * ApplicationEvent after every property status change.
 *
 * Key improvements over the old implementation:
 * 1. Durability — if the app crashes mid-alert, the Kafka offset is not
 *    committed and alerts are re-processed after restart. Previously, the
 *    JVM crash lost all pending alerts silently.
 * 2. Filtering at consumer level — only processes events where
 *    newStatus = "AVAILABLE", so the full table-scan happens less often.
 * 3. Isolated failure domain — a slow SMTP server doesn't block booking
 *    emails or in-app notifications (different consumer group).
 * 4. The full table-scan (savedSearchRepository.findAll()) is still present
 *    but could be optimized with a city/type indexed query in a future iteration.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SavedSearchConsumer {

    private final SavedSearchRepository savedSearchRepository;
    private final PropertyRepository propertyRepository;
    private final EmailService emailService;
    private final ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.PROPERTY_STATUS_CHANGED,
            containerFactory = "savedSearchKafkaListenerContainerFactory"
    )
    public void onPropertyStatusChanged(
            @Payload PropertyStatusChangedEvent event,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        // Fast filter: only act on newly AVAILABLE properties
        if (!"AVAILABLE".equals(event.getNewStatus())) {
            log.debug("[Kafka/SavedSearch] Skipping — newStatus={} is not AVAILABLE (propertyId={})",
                    event.getNewStatus(), event.getPropertyId());
            ack.acknowledge(); // still commit offset — we intentionally skip
            return;
        }

        log.info("[Kafka/SavedSearch] Processing saved-search alerts for newly approved propertyId={}",
                event.getPropertyId());

        // Fetch the full Property entity for the criteria matching logic.
        // The event DTO carries enough fields (city, type, category, price) to
        // match most criteria without a DB lookup, but we use the entity here
        // to stay compatible with the existing matchesCriteria() logic.
        Property property = propertyRepository.findById(event.getPropertyId()).orElse(null);
        if (property == null || property.getStatus() != PropertyStatus.AVAILABLE) {
            log.warn("[Kafka/SavedSearch] Property {} not found or not AVAILABLE — skipping alerts",
                    event.getPropertyId());
            ack.acknowledge();
            return;
        }

        List<SavedSearch> allSavedSearches = savedSearchRepository.findAll();
        int alertsSent = 0;

        for (SavedSearch savedSearch : allSavedSearches) {
            try {
                SearchCriteriaDto criteria = objectMapper.readValue(
                        savedSearch.getFiltersJson(), SearchCriteriaDto.class);

                if (matchesCriteria(property, criteria)) {
                    log.info("[Kafka/SavedSearch] Alerting userId={} for savedSearchId={}",
                            savedSearch.getUser().getId(), savedSearch.getId());

                    String subject = "New Property Match: " + savedSearch.getName();
                    String htmlMessage = buildMatchEmailBody(savedSearch, property);
                    emailService.sendEmail(savedSearch.getUser().getEmail(), subject, htmlMessage);
                    alertsSent++;
                }
            } catch (Exception e) {
                // Log per-search failure but continue processing remaining searches.
                // If we threw here, the entire batch would retry and re-alert
                // everyone who already received the email.
                log.error("[Kafka/SavedSearch] Failed alert for savedSearchId={}: {}",
                        savedSearch.getId(), e.getMessage(), e);
            }
        }

        log.info("[Kafka/SavedSearch] Sent {} alerts for propertyId={}", alertsSent, event.getPropertyId());
        ack.acknowledge(); // commit after full loop completes
    }

    // ─── Criteria matching (preserved from legacy SavedSearchAlertService) ───

    private boolean matchesCriteria(Property p, SearchCriteriaDto criteria) {
        if (criteria.getKeyword() != null && !criteria.getKeyword().isEmpty()) {
            String kw = criteria.getKeyword().toLowerCase();
            boolean matchKw = (p.getTitle() != null && p.getTitle().toLowerCase().contains(kw)) ||
                    (p.getDescription() != null && p.getDescription().toLowerCase().contains(kw)) ||
                    (p.getLocation() != null && p.getLocation().toLowerCase().contains(kw));
            if (!matchKw) return false;
        }
        if (criteria.getCity() != null && !criteria.getCity().isEmpty()) {
            if (!criteria.getCity().equalsIgnoreCase(p.getCity())) return false;
        }
        if (criteria.getType() != null && !criteria.getType().isEmpty()) {
            if (p.getType() == null || !criteria.getType().equalsIgnoreCase(p.getType().name())) return false;
        }
        if (criteria.getCategory() != null && !criteria.getCategory().isEmpty()) {
            if (p.getCategory() == null || !criteria.getCategory().equalsIgnoreCase(p.getCategory().name())) return false;
        }
        if (criteria.getMinPrice() != null) {
            if (p.getPrice() == null || p.getPrice().compareTo(criteria.getMinPrice()) < 0) return false;
        }
        if (criteria.getMaxPrice() != null) {
            if (p.getPrice() == null || p.getPrice().compareTo(criteria.getMaxPrice()) > 0) return false;
        }
        if (criteria.getBedrooms() != null) {
            if (p.getBedrooms() == null || p.getBedrooms() < criteria.getBedrooms()) return false;
        }
        if (criteria.getFurnishing() != null && !criteria.getFurnishing().isEmpty()) {
            if (p.getFurnishing() == null || !criteria.getFurnishing().equalsIgnoreCase(p.getFurnishing().name())) return false;
        }
        return true;
    }

    private String buildMatchEmailBody(SavedSearch savedSearch, Property p) {
        return "<html><body style='font-family:Arial,sans-serif;padding:20px;'>" +
                "<h2>New Property Match!</h2>" +
                "<p>Hi " + savedSearch.getUser().getName() + ",</p>" +
                "<p>A new property just got listed that matches your saved search " +
                "<strong>'" + savedSearch.getName() + "'</strong>!</p>" +
                "<div style='background:#f0f4ff;padding:15px;border-radius:8px;margin:15px 0;'>" +
                "<strong>" + p.getTitle() + "</strong><br>" +
                "Price: ₹ " + p.getPrice() + "<br>" +
                "Location: " + p.getLocation() + ", " + p.getCity() +
                "</div>" +
                "<p><a href='http://localhost:8080/properties/" + p.getId() +
                "' style='display:inline-block;padding:10px 20px;background:#1A73E8;" +
                "color:white;text-decoration:none;border-radius:6px;'>View Listing</a></p>" +
                "<p>Best,<br>The PropNexium Team</p>" +
                "</body></html>";
    }
}
