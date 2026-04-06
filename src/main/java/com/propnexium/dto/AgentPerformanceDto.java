package com.propnexium.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AgentPerformanceDto {

    private Long agentId;
    private String agentName;
    private String email;

    private int totalListings;
    private long totalViews;
    private long totalInquiries;
    private long repliedInquiries;

    /** repliedInquiries / totalInquiries * 100  (0 if totalInquiries=0) */
    private double responseRate;

    /** totalViews / totalListings  (0 if totalListings=0) */
    private double avgViewsPerListing;

    /** totalInquiries / totalViews * 100  (0 if totalViews=0) */
    private double inquiryConversionRate;
}
