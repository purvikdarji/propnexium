package com.propnexium.controller.web.admin;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.propnexium.repository.InquiryRepository;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.SearchLogRepository;
import com.propnexium.repository.UserRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/analytics")
@PreAuthorize("hasRole('ADMIN')")
public class AdminAnalyticsController {

    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final InquiryRepository inquiryRepository;
    private final SearchLogRepository searchLogRepository;
    private final ObjectMapper mapper;

    public AdminAnalyticsController(PropertyRepository propertyRepository,
            UserRepository userRepository,
            InquiryRepository inquiryRepository,
            SearchLogRepository searchLogRepository) {
        this.propertyRepository = propertyRepository;
        this.userRepository = userRepository;
        this.inquiryRepository = inquiryRepository;
        this.searchLogRepository = searchLogRepository;
        this.mapper = new ObjectMapper();
    }

    @GetMapping
    public String analyticsPage(Model model) throws JsonProcessingException {

        // Monthly data
        List<Map<String, Object>> monthlyListings = propertyRepository.getMonthlyListingCounts();
        List<Map<String, Object>> monthlyUsers = userRepository.getMonthlyUserRegistrations();

        // Distribution data
        List<Map<String, Object>> typeDistribution = propertyRepository.getPropertyTypeDistribution();
        List<Map<String, Object>> categoryDistribution = propertyRepository.getListingCategoryDistribution();
        List<Map<String, Object>> inquiryStatus = inquiryRepository.getInquiryStatusDistribution();
        List<Map<String, Object>> searchCities = searchLogRepository.getMostSearchedCities();

        // Top lists
        List<Map<String, Object>> topAgents = userRepository.getTopAgentsByListings();
        List<Map<String, Object>> mostViewed = propertyRepository.getMostViewedProperties();

        // KPI cards
        BigDecimal platformValue = propertyRepository.getTotalPlatformValue();
        double platformValueCr = 0.0;
        if (platformValue != null) {
            platformValueCr = platformValue
                    .divide(BigDecimal.valueOf(10000000), 2, RoundingMode.HALF_UP)
                    .doubleValue();
        }

        Map<String, Object> resolutionStats = inquiryRepository.getInquiryResolutionStats();
        long totalInquiries = 0;
        long resolvedInquiries = 0;
        if (resolutionStats != null) {
            totalInquiries = ((Number) resolutionStats.getOrDefault("total", 0)).longValue();
            Object resolvedObj = resolutionStats.get("resolved");
            resolvedInquiries = resolvedObj != null ? ((Number) resolvedObj).longValue() : 0;
        }

        double resolutionPercent = totalInquiries > 0 ? Math.round((double) resolvedInquiries / totalInquiries * 100)
                : 0;

        String mostSearchedCity = searchLogRepository.getMostSearchedCity();

        // Convert to JSON strings for Chart.js
        model.addAttribute("monthlyListingsJson", mapper.writeValueAsString(monthlyListings));
        model.addAttribute("monthlyUsersJson", mapper.writeValueAsString(monthlyUsers));
        model.addAttribute("typeDistributionJson", mapper.writeValueAsString(typeDistribution));
        model.addAttribute("categoryDistributionJson", mapper.writeValueAsString(categoryDistribution));
        model.addAttribute("inquiryStatusJson", mapper.writeValueAsString(inquiryStatus));
        model.addAttribute("searchCitiesJson", mapper.writeValueAsString(searchCities));

        model.addAttribute("topAgents", topAgents);
        model.addAttribute("mostViewed", mostViewed);
        model.addAttribute("platformValueCr", platformValueCr);
        model.addAttribute("resolutionPercent", resolutionPercent);
        model.addAttribute("mostSearchedCity", mostSearchedCity != null ? mostSearchedCity : "N/A");

        return "admin/analytics";
    }
}
