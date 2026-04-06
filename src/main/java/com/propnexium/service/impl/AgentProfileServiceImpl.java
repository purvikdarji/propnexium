package com.propnexium.service.impl;

import com.propnexium.dto.request.AgentProfileDto;
import com.propnexium.entity.AgentProfile;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.AgentProfileRepository;
import com.propnexium.repository.ReviewRepository;
import com.propnexium.service.AgentProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AgentProfileServiceImpl implements AgentProfileService {

    private final AgentProfileRepository agentProfileRepository;
    private final ReviewRepository reviewRepository;

    @Override
    @Transactional(readOnly = true)
    public AgentProfile findByUserId(Long userId) {
        return agentProfileRepository.findByUserId(userId).orElse(null);
    }

    @Override
    @Transactional(readOnly = true)
    public AgentProfile findById(Long id) {
        return agentProfileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("AgentProfile", "id", id));
    }

    @Override
    public AgentProfile updateProfile(Long userId, AgentProfileDto dto) {
        AgentProfile profile = agentProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("AgentProfile", "userId", userId));

        profile.setAgencyName(dto.getAgencyName());
        profile.setLicenseNumber(dto.getLicenseNumber());
        profile.setExperienceYears(dto.getExperienceYears());
        profile.setBio(dto.getBio());
        profile.setWebsite(dto.getWebsite());
        return agentProfileRepository.save(profile);
    }

    @Override
    public void updateRating(Long agentUserId) {
        Double avg = reviewRepository.findAverageRatingByAgentId(agentUserId);
        AgentProfile profile = agentProfileRepository.findByUserId(agentUserId).orElse(null);

        if (profile == null) {
            return; // Do nothing if agent hasn't created a profile yet
        }

        BigDecimal newRating = (avg != null)
                ? BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;
        profile.setRating(newRating);
        agentProfileRepository.save(profile);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AgentProfile> getTopAgentsByRating(int limit) {
        return agentProfileRepository.findAll(
                PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "rating")))
                .getContent();
    }
}
