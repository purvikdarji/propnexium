package com.propnexium.service;

import java.util.List;
import com.propnexium.entity.PropertyReport;

public interface PropertyReportService {

    void submitReport(Long propertyId, Long reporterId, String reason, String description);

    void putUnderReview(Long reportId);

    void dismissReport(Long reportId);

    void removeListing(Long reportId);

    List<PropertyReport> findByStatus(PropertyReport.ReportStatus status);
}
