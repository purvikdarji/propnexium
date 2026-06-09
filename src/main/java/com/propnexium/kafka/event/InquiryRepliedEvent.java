package com.propnexium.kafka.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Kafka message payload published when an agent replies to a buyer inquiry.
 *
 * Replaces the silent catch(Exception ignored) pattern in InquiryServiceImpl
 * — previously, both the email send and the notification creation could fail
 * silently with no retry. Now failures are caught by the DLT recoverer after
 * 3 retries.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InquiryRepliedEvent {

    private Long inquiryId;
    private Long propertyId;
    private String propertyTitle;

    /** Name / email of the person who submitted the original inquiry. */
    private String inquirerName;
    private String inquirerEmail;

    /**
     * DB user ID of the inquirer — null if the inquiry was submitted as a guest.
     * Notification consumer uses this to create an in-app notification only for
     * registered users.
     */
    private Long inquirerUserId;

    private String agentReply;
    private LocalDateTime repliedAt;
}
