package com.propnexium.service.impl;

import com.propnexium.dto.response.ApiResponse;
import com.propnexium.entity.Subscriber;
import com.propnexium.repository.SubscriberRepository;
import com.propnexium.service.SubscriberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class SubscriberServiceImpl implements SubscriberService {

    @Autowired
    private SubscriberRepository subscriberRepository;

    @Override
    public ApiResponse<String> subscribe(String email) {
        if (email == null || email.isBlank() || !email.contains("@")) {
            return ApiResponse.error("Please provide a valid email address.");
        }

        Optional<Subscriber> existing = subscriberRepository.findByEmail(email.toLowerCase().trim());

        if (existing.isPresent()) {
            Subscriber sub = existing.get();
            if (sub.isSubscribed()) {
                return ApiResponse.success(null, "You are already subscribed!");
            }
            // Re-subscribe
            sub.setSubscribed(true);
            sub.setUnsubscribeToken(UUID.randomUUID().toString());
            sub.setUnsubscribedAt(null);
            sub.setSubscribedAt(LocalDateTime.now());
            subscriberRepository.save(sub);
            return ApiResponse.success(null, "Welcome back! You are now subscribed.");
        }

        // New subscriber
        Subscriber sub = Subscriber.builder()
                .email(email.toLowerCase().trim())
                .isSubscribed(true)
                .unsubscribeToken(UUID.randomUUID().toString())
                .subscribedAt(LocalDateTime.now())
                .build();
        subscriberRepository.save(sub);
        return ApiResponse.success(null, "Thank you for subscribing!");
    }

    @Override
    public void unsubscribe(String token) {
        Subscriber sub = subscriberRepository.findByUnsubscribeToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid unsubscribe token"));
        sub.setSubscribed(false);
        sub.setUnsubscribedAt(LocalDateTime.now());
        subscriberRepository.save(sub);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Subscriber> getActiveSubscribers() {
        return subscriberRepository.findByIsSubscribedTrue();
    }

    @Override
    @Transactional(readOnly = true)
    public long getActiveCount() {
        return subscriberRepository.countByIsSubscribedTrue();
    }

    @Override
    public boolean isEmailSubscribed(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }
        return subscriberRepository.findByEmail(email)
                .map(Subscriber::isSubscribed)
                .orElse(false);
    }

    @Override
    public void unsubscribeByEmail(String email) {
        if (email == null || email.isBlank()) return;
        
        Optional<Subscriber> subOpt = subscriberRepository.findByEmail(email.toLowerCase().trim());
        if (subOpt.isPresent()) {
            Subscriber sub = subOpt.get();
            sub.setSubscribed(false);
            sub.setUnsubscribedAt(LocalDateTime.now());
            subscriberRepository.save(sub);
        }
    }

    @Override
    public void removeSubscriber(Long id) {
        subscriberRepository.deleteById(id);
    }
}
