package com.propnexium.service.impl;

import com.propnexium.dto.request.InquiryDto;
import com.propnexium.entity.Inquiry;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.InquiryStatus;
import com.propnexium.repository.InquiryRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.EmailService;
import com.propnexium.service.InquiryService;
import com.propnexium.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InquiryServiceImpl implements InquiryService {

    private final InquiryRepository inquiryRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final EmailService emailService;

    @Override
    @Transactional
    public Inquiry createInquiry(Long propertyId, Long userId, InquiryDto dto) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found: " + propertyId));
        User user = (userId != null) ? userRepository.findById(userId).orElse(null) : null;
        Inquiry inquiry = Inquiry.builder()
                .property(property)
                .user(user)
                .inquirerName(dto.getName())
                .inquirerEmail(dto.getEmail())
                .inquirerPhone(dto.getPhone())
                .message(dto.getMessage())
                .build();
        return inquiryRepository.save(inquiry);
    }

    @Override
    public List<Inquiry> getByUser(Long userId) {
        return inquiryRepository.findByUserId(
                userId,
                PageRequest.of(0, Integer.MAX_VALUE, Sort.by(Sort.Direction.DESC, "createdAt")))
                .getContent();
    }

    @Override
    public List<Inquiry> getRecentByUser(Long userId, int limit) {
        return inquiryRepository.findRecentByUserId(userId, PageRequest.of(0, limit));
    }

    @Override
    public long countByUser(Long userId) {
        return inquiryRepository.countByUserId(userId);
    }

    // ─── Admin methods ────────────────────────────────────────────────────────

    @Override
    public long countAll() {
        return inquiryRepository.count();
    }

    @Override
    public long countByStatus(InquiryStatus status) {
        return inquiryRepository.countByStatus(status);
    }

    // ─── Agent methods ────────────────────────────────────────────────────────

    @Override
    public long countByAgent(Long agentId) {
        return inquiryRepository.countByAgentId(agentId);
    }

    @Override
    public long countByAgentAndStatus(Long agentId, InquiryStatus status) {
        return inquiryRepository.countByAgentIdAndStatus(agentId, status);
    }

    @Override
    public List<Inquiry> getRecentByAgent(Long agentId, int limit) {
        return inquiryRepository.findRecentByAgentId(agentId, PageRequest.of(0, limit));
    }

    @Override
    public Page<Inquiry> findByAgent(Long agentId, Pageable pageable) {
        return inquiryRepository.findByAgentId(agentId, pageable);
    }

    @Override
    public Page<Inquiry> findByAgentIdAndStatus(Long agentId, InquiryStatus status, Pageable pageable) {
        return inquiryRepository.findByAgentIdAndStatus(agentId, status, pageable);
    }

    @Override
    public Inquiry findById(Long inquiryId) {
        return inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new com.propnexium.exception.ResourceNotFoundException("Inquiry", "id", inquiryId));
    }

    @Override
    @Transactional
    public Inquiry replyToInquiry(Long inquiryId, Long agentId, String replyText) {
        Inquiry inquiry = findById(inquiryId);

        // Verify the inquiry belongs to this agent's property
        if (!inquiry.getProperty().getAgent().getId().equals(agentId)) {
            throw new com.propnexium.exception.UnauthorizedAccessException(
                    "You can only reply to inquiries on your own properties");
        }

        inquiry.setAgentReply(replyText);
        inquiry.setStatus(InquiryStatus.REPLIED);
        inquiry.setRepliedAt(java.time.LocalDateTime.now());
        Inquiry saved = inquiryRepository.save(inquiry);

        // In-app notification for registered inquirers
        if (inquiry.getUser() != null) {
            try {
                notificationService.createNotification(
                        inquiry.getUser().getId(),
                        "Agent Replied to Your Inquiry",
                        "Your inquiry about \"" + inquiry.getProperty().getTitle() + "\" has been answered.",
                        com.propnexium.entity.enums.NotificationType.INQUIRY,
                        "/user/inquiries");
            } catch (Exception ignored) {
                /* never block the reply */ }
        }

        // Email notification
        try {
            if (emailService != null) {
                emailService.sendAgentReplyToUser(saved);
            }
        } catch (Exception ignored) {
            /* never block the reply */ }

        return saved;
    }

    @Override
    @Transactional
    public void closeInquiry(Long inquiryId, Long agentId) {
        Inquiry inquiry = findById(inquiryId);
        if (!inquiry.getProperty().getAgent().getId().equals(agentId)) {
            throw new com.propnexium.exception.UnauthorizedAccessException(
                    "You can only close inquiries on your own properties");
        }
        inquiry.setStatus(InquiryStatus.CLOSED);
        inquiryRepository.save(inquiry);
    }
}
