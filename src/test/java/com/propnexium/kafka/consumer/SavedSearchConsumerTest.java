package com.propnexium.kafka.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.propnexium.entity.Property;
import com.propnexium.entity.SavedSearch;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.entity.enums.PropertyType;
import com.propnexium.kafka.event.PropertyStatusChangedEvent;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.SavedSearchRepository;
import com.propnexium.service.EmailService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.support.Acknowledgment;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link SavedSearchConsumer}.
 *
 * Tests the consumer's business logic (filtering, criteria matching, email trigger)
 * using pure Mockito — no Spring context, no Kafka broker, no DB required.
 *
 * Why unit tests (not integration)?
 * The SavedSearchConsumer injects ObjectMapper + complex JPA entities, and its
 * onPropertyStatusChanged() routing / matching logic can be fully tested by
 * directly calling the method with a mocked Acknowledgment. Integration-level
 * EmbeddedKafka is tested for EmailNotificationConsumer which has simpler
 * dependencies.
 */
@ExtendWith(MockitoExtension.class)
class SavedSearchConsumerTest {

    @Mock private EmailService emailService;
    @Mock private SavedSearchRepository savedSearchRepository;
    @Mock private PropertyRepository propertyRepository;
    @Mock private Acknowledgment ack;

    /**
     * @Spy on a real ObjectMapper so the JSON deserializer inside the consumer
     * works correctly without needing a Spring context.
     */
    @Spy
    private ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    @InjectMocks
    private SavedSearchConsumer consumer;

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private Property buildProperty(Long id, String city, PropertyType type) {
        User agent = new User(); agent.setId(10L);
        Property p = new Property();
        p.setId(id); p.setTitle("Test Property"); p.setCity(city);
        p.setType(type); p.setPrice(BigDecimal.valueOf(4500000));
        p.setStatus(PropertyStatus.AVAILABLE); p.setAgent(agent);
        return p;
    }

    private SavedSearch buildSavedSearch(Long id, String email, String filtersJson) {
        User user = new User();
        user.setId(50L + id); user.setName("Subscriber " + id); user.setEmail(email);
        SavedSearch ss = new SavedSearch();
        ss.setId(id); ss.setUser(user);
        ss.setName("Search " + id); ss.setFiltersJson(filtersJson);
        return ss;
    }

    private PropertyStatusChangedEvent availableEvent(Long propertyId, String city, String type) {
        return PropertyStatusChangedEvent.builder()
                .propertyId(propertyId).agentId(10L)
                .title("Property " + propertyId).city(city).type(type)
                .oldStatus("UNDER_REVIEW").newStatus("AVAILABLE")
                .changedAt(LocalDateTime.now()).build();
    }

    // ── Tests ─────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("AVAILABLE transition + matching criteria → sendEmail is called")
    void matchingSavedSearch_sendsEmail() {
        Long propertyId = 1L;
        Property property = buildProperty(propertyId, "Mumbai", PropertyType.APARTMENT);
        SavedSearch match = buildSavedSearch(1L, "sub@example.com",
                "{\"city\":\"Mumbai\",\"type\":\"APARTMENT\"}");

        when(propertyRepository.findById(propertyId)).thenReturn(Optional.of(property));
        when(savedSearchRepository.findAll()).thenReturn(List.of(match));

        consumer.onPropertyStatusChanged(availableEvent(propertyId, "Mumbai", "APARTMENT"),
                "propnexium.property.status.changed", 0L, ack);

        verify(emailService).sendEmail(eq("sub@example.com"), anyString(), anyString());
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("REJECTED transition → consumer skips without property lookup or email")
    void rejectedStatus_skipsAll() {
        PropertyStatusChangedEvent event = PropertyStatusChangedEvent.builder()
                .propertyId(2L).agentId(10L)
                .oldStatus("UNDER_REVIEW").newStatus("REJECTED")
                .changedAt(LocalDateTime.now()).build();

        consumer.onPropertyStatusChanged(event, "propnexium.property.status.changed", 1L, ack);

        verifyNoInteractions(propertyRepository, emailService);
        verify(ack).acknowledge(); // offset still committed
    }

    @Test
    @DisplayName("UNDER_REVIEW → UNDER_REVIEW no-op → consumer skips gracefully")
    void underReviewStatus_skips() {
        PropertyStatusChangedEvent event = PropertyStatusChangedEvent.builder()
                .propertyId(3L).agentId(10L)
                .oldStatus("UNDER_REVIEW").newStatus("UNDER_REVIEW")
                .changedAt(LocalDateTime.now()).build();

        consumer.onPropertyStatusChanged(event, "propnexium.property.status.changed", 2L, ack);

        verifyNoInteractions(propertyRepository, emailService);
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("AVAILABLE + non-matching city → no email sent")
    void nonMatchingCity_noEmail() {
        Long propertyId = 4L;
        Property property = buildProperty(propertyId, "Pune", PropertyType.VILLA);
        SavedSearch mismatch = buildSavedSearch(2L, "mismatch@example.com",
                "{\"city\":\"Mumbai\",\"type\":\"APARTMENT\"}");

        when(propertyRepository.findById(propertyId)).thenReturn(Optional.of(property));
        when(savedSearchRepository.findAll()).thenReturn(List.of(mismatch));

        consumer.onPropertyStatusChanged(availableEvent(propertyId, "Pune", "VILLA"),
                "propnexium.property.status.changed", 3L, ack);

        verify(emailService, never()).sendEmail(anyString(), anyString(), anyString());
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("AVAILABLE + property not in DB → no email, offset still committed")
    void propertyNotFound_noEmail() {
        Long propertyId = 5L;
        when(propertyRepository.findById(propertyId)).thenReturn(Optional.empty());

        consumer.onPropertyStatusChanged(availableEvent(propertyId, "Mumbai", "APARTMENT"),
                "propnexium.property.status.changed", 4L, ack);

        verifyNoInteractions(emailService);
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("AVAILABLE + multiple saved searches → only matching ones get alerted")
    void multipleSearches_onlyMatchingAlertsAreTriggered() {
        Long propertyId = 6L;
        Property property = buildProperty(propertyId, "Mumbai", PropertyType.APARTMENT);
        SavedSearch match = buildSavedSearch(3L, "match@example.com",
                "{\"city\":\"Mumbai\",\"type\":\"APARTMENT\"}");
        SavedSearch noMatch = buildSavedSearch(4L, "nomatch@example.com",
                "{\"city\":\"Delhi\",\"type\":\"VILLA\"}");

        when(propertyRepository.findById(propertyId)).thenReturn(Optional.of(property));
        when(savedSearchRepository.findAll()).thenReturn(List.of(match, noMatch));

        consumer.onPropertyStatusChanged(availableEvent(propertyId, "Mumbai", "APARTMENT"),
                "propnexium.property.status.changed", 5L, ack);

        verify(emailService, times(1)).sendEmail(eq("match@example.com"), anyString(), anyString());
        verify(emailService, never()).sendEmail(eq("nomatch@example.com"), anyString(), anyString());
        verify(ack).acknowledge();
    }

    @Test
    @DisplayName("Individual email failure → rest of searches still processed")
    void emailFailure_continuesProcessingOtherSearches() {
        Long propertyId = 7L;
        Property property = buildProperty(propertyId, "Mumbai", PropertyType.APARTMENT);
        SavedSearch first = buildSavedSearch(5L, "fail@example.com",
                "{\"city\":\"Mumbai\",\"type\":\"APARTMENT\"}");
        SavedSearch second = buildSavedSearch(6L, "succeed@example.com",
                "{\"city\":\"Mumbai\",\"type\":\"APARTMENT\"}");

        when(propertyRepository.findById(propertyId)).thenReturn(Optional.of(property));
        when(savedSearchRepository.findAll()).thenReturn(List.of(first, second));
        // First email fails
        doThrow(new RuntimeException("SMTP timeout"))
                .when(emailService).sendEmail(eq("fail@example.com"), anyString(), anyString());

        // Should NOT throw — consumer logs and continues
        consumer.onPropertyStatusChanged(availableEvent(propertyId, "Mumbai", "APARTMENT"),
                "propnexium.property.status.changed", 6L, ack);

        // Second subscriber should still receive the email despite the first failing
        verify(emailService).sendEmail(eq("succeed@example.com"), anyString(), anyString());
        verify(ack).acknowledge();
    }
}
