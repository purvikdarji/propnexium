package com.propnexium.service.impl;

import com.propnexium.dto.AgentPerformanceDto;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.InquiryStatus;
import com.propnexium.entity.enums.UserRole;
import com.propnexium.repository.InquiryRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.AgentPerformanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class AgentPerformanceServiceImpl implements AgentPerformanceService {

    @Autowired private UserRepository userRepository;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private InquiryRepository inquiryRepository;

    @Override
    public List<AgentPerformanceDto> getAllAgentPerformance() {
        List<User> agents = userRepository.findByRole(UserRole.AGENT);
        List<AgentPerformanceDto> result = new ArrayList<>();
        for (User agent : agents) {
            result.add(buildDto(agent));
        }
        return result;
    }

    @Override
    public AgentPerformanceDto getAgentPerformance(Long agentId) {
        User agent = userRepository.findById(agentId)
                .orElseThrow(() -> new RuntimeException("Agent not found: " + agentId));
        return buildDto(agent);
    }

    // ── Internal builder ──────────────────────────────────────────────────────

    private AgentPerformanceDto buildDto(User agent) {
        Long agentId = agent.getId();

        long totalListings   = propertyRepository.countByAgentId(agentId);
        long totalViews      = propertyRepository.sumViewCountByAgentId(agentId);
        long totalInquiries  = inquiryRepository.countByAgentId(agentId);
        long replied         = inquiryRepository.countByAgentIdAndStatus(agentId, InquiryStatus.REPLIED);
        long closed          = inquiryRepository.countByAgentIdAndStatus(agentId, InquiryStatus.CLOSED);
        long repliedInquiries = replied + closed;

        double responseRate         = totalInquiries > 0
                ? (repliedInquiries * 100.0 / totalInquiries) : 0.0;
        double avgViewsPerListing   = totalListings > 0
                ? ((double) totalViews / totalListings) : 0.0;
        double inquiryConversionRate = totalViews > 0
                ? (totalInquiries * 100.0 / totalViews) : 0.0;

        return AgentPerformanceDto.builder()
                .agentId(agentId)
                .agentName(agent.getName())
                .email(agent.getEmail())
                .totalListings((int) totalListings)
                .totalViews(totalViews)
                .totalInquiries(totalInquiries)
                .repliedInquiries(repliedInquiries)
                .responseRate(responseRate)
                .avgViewsPerListing(avgViewsPerListing)
                .inquiryConversionRate(inquiryConversionRate)
                .build();
    }
}
