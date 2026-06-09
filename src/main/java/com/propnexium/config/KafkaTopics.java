package com.propnexium.config;

/**
 * Central registry of all Kafka topic names used in PropNexium.
 *
 * Naming convention: propnexium.<aggregate>.<event-past-tense>
 *
 * Dead Letter Topics (DLT) follow the Spring-Kafka convention of appending
 * ".DLT" to the original topic name — they are created automatically by
 * {@link KafkaConfig}'s DeadLetterPublishingRecoverer.
 */
public final class KafkaTopics {

    private KafkaTopics() { /* utility class — not instantiable */ }

    // ─── User Domain ──────────────────────────────────────────────────────────
    /** Fired when a new user completes registration. */
    public static final String USER_REGISTERED = "propnexium.user.registered";

    // ─── Property Domain ──────────────────────────────────────────────────────
    /** Fired when an agent submits a new property listing for admin review. */
    public static final String PROPERTY_SUBMITTED = "propnexium.property.submitted";

    /**
     * Fired when a property's status changes (UNDER_REVIEW → AVAILABLE,
     * AVAILABLE → REJECTED, etc.). Consumers such as the saved-search alert
     * service filter by newStatus = AVAILABLE.
     */
    public static final String PROPERTY_STATUS_CHANGED = "propnexium.property.status.changed";

    // ─── Booking Domain ───────────────────────────────────────────────────────
    /** Fired when a user creates a new site-visit booking. */
    public static final String BOOKING_CREATED = "propnexium.booking.created";

    /**
     * Fired when a booking's status changes (PENDING → CONFIRMED/RESCHEDULED/
     * CANCELLED/COMPLETED). Both user-initiated and agent-initiated transitions
     * publish to this topic; the consumer inspects the event payload to decide
     * which party to notify.
     */
    public static final String BOOKING_STATUS_CHANGED = "propnexium.booking.status.changed";

    // ─── Inquiry Domain ───────────────────────────────────────────────────────
    /** Fired when an agent replies to a buyer inquiry. */
    public static final String INQUIRY_REPLIED = "propnexium.inquiry.replied";
}
