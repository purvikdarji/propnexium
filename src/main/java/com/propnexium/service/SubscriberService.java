package com.propnexium.service;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.Subscriber;

import java.util.List;

public interface SubscriberService {

    /** Subscribe the given email. Handles already-subscribed and re-subscribe cases. */
    ApiResponse<String> subscribe(String email);

    /** Mark the subscriber with the given token as unsubscribed. */
    void unsubscribe(String token);

    /** Return all active (subscribed) subscribers. */
    List<Subscriber> getActiveSubscribers();

    /** Count of currently active subscribers. */
    long getActiveCount();

    /** Checks if an email is actively subscribed */
    boolean isEmailSubscribed(String email);

    /** Unsubscribes by email (used when authenticated user clicks unsubscribe) */
    void unsubscribeByEmail(String email);

    /** Delete a subscriber entirely (Admin use) */
    void removeSubscriber(Long id);
}
