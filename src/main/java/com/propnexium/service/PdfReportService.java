package com.propnexium.service;

public interface PdfReportService {
    byte[] generatePropertyReport(Long propertyId);

    byte[] generateAgentListingsReport(Long agentId);
}
