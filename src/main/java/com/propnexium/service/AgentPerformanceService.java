package com.propnexium.service;

import com.propnexium.dto.AgentPerformanceDto;

import java.util.List;

public interface AgentPerformanceService {

    /** Returns performance metrics for ALL agents. */
    List<AgentPerformanceDto> getAllAgentPerformance();

    /** Returns performance metrics for a single agent by their user ID. */
    AgentPerformanceDto getAgentPerformance(Long agentId);
}
