package com.propnexium.service;

import com.propnexium.dto.request.InquiryDto;
import com.propnexium.entity.Inquiry;
import com.propnexium.entity.enums.InquiryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * Service interface for Inquiry operations.
 */
public interface InquiryService {

    /**
     * Submit a new inquiry for a property (works for guests and logged-in users).
     */
    Inquiry createInquiry(Long propertyId, Long userId, InquiryDto dto);

    /** All inquiries submitted by a user (newest first). */
    List<Inquiry> getByUser(Long userId);

    /** Most-recent N inquiries submitted by a user (for dashboard preview). */
    List<Inquiry> getRecentByUser(Long userId, int limit);

    /** Total inquiry count for a user. */
    long countByUser(Long userId);

    // ─── Admin methods ────────────────────────────────────────────────────────

    long countAll();

    long countByStatus(InquiryStatus status);

    // ─── Agent methods ────────────────────────────────────────────────────────

    /** Count all inquiries on properties owned by the given agent. */
    long countByAgent(Long agentId);

    /** Count inquiries by status on properties owned by the given agent. */
    long countByAgentAndStatus(Long agentId, InquiryStatus status);

    /** N most-recent inquiries across all of the agent's properties. */
    List<Inquiry> getRecentByAgent(Long agentId, int limit);

    /** Paginated inquiries for all of an agent's properties. */
    Page<Inquiry> findByAgent(Long agentId, Pageable pageable);

    /** Paginated inquiries for an agent's properties filtered by status. */
    Page<Inquiry> findByAgentIdAndStatus(Long agentId, InquiryStatus status, Pageable pageable);

    /** Load an inquiry by ID, throw ResourceNotFoundException if not found. */
    Inquiry findById(Long inquiryId);

    /**
     * Agent replies to an inquiry.
     * - Sets agentReply, status=REPLIED, repliedAt=now
     * - Sends email notification to the inquirer
     * - Creates in-app notification for the registered user (if any)
     */
    Inquiry replyToInquiry(Long inquiryId, Long agentId, String replyText);

    /**
     * Agent closes an inquiry (ownership verified).
     */
    void closeInquiry(Long inquiryId, Long agentId);
}
