package com.propnexium.controller.web.admin;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.dto.AgentPerformanceDto;
import com.propnexium.entity.Property;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.SearchLogRepository;
import com.propnexium.service.AgentPerformanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/performance")
@PreAuthorize("hasRole('ADMIN')")
public class AdminPerformanceController {

    @Autowired private AgentPerformanceService agentPerformanceService;
    @Autowired private PropertyRepository propertyRepository;
    @Autowired private SearchLogRepository searchLogRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /** GET /admin/performance → list all agents performance */
    @GetMapping
    public String listAgentPerformance(Model model) {
        List<AgentPerformanceDto> agents = agentPerformanceService.getAllAgentPerformance();
        model.addAttribute("agents", agents);

        // ── Trending Search Analytics ─────────────────────────────────────────
        model.addAttribute("trendingSearches",
                searchLogRepository.getTrendingCityTypeCombinations());

        Map<String, Object> dist = searchLogRepository.getResultCountDistribution();
        String distJson = "{}";
        try {
            distJson = objectMapper.writeValueAsString(dist);
        } catch (Exception ignored) {}
        model.addAttribute("resultDistributionJson", distJson);

        return "admin/performance";
    }

    /** GET /admin/performance/{agentId} → individual agent detail page */
    @GetMapping("/{agentId}")
    public String agentDetail(@PathVariable Long agentId, Model model) {
        AgentPerformanceDto agent = agentPerformanceService.getAgentPerformance(agentId);
        List<Property> agentProperties = propertyRepository.findByAgentId(agentId);
        model.addAttribute("agent", agent);
        model.addAttribute("agentProperties", agentProperties);
        return "admin/agent-performance-detail";
    }
}
