package com.propnexium.service;
import com.propnexium.dto.request.AgentProfileDto;
import com.propnexium.entity.AgentProfile;

import java.util.List;

public interface AgentProfileService {
    AgentProfile findByUserId(Long userId);
    AgentProfile findById(Long id);
    AgentProfile updateProfile(Long userId, AgentProfileDto dto);
    void updateRating(Long agentUserId);
    List<AgentProfile> getTopAgentsByRating(int limit);
}
