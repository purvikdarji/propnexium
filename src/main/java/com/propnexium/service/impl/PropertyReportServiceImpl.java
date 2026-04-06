package com.propnexium.service.impl;

import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyReport;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.exception.BusinessException;
import com.propnexium.exception.ResourceNotFoundException;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.PropertyReportRepository;
import com.propnexium.repository.UserRepository;
import com.propnexium.service.EmailService;
import com.propnexium.service.PropertyReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class PropertyReportServiceImpl implements PropertyReportService {

    private final PropertyReportRepository reportRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    @Override
    public void submitReport(Long propertyId, Long reporterId, String reason, String description) {
        // Check for duplicate PENDING report
        if (reportRepository.existsByPropertyIdAndReporterIdAndStatus(
                propertyId, reporterId, PropertyReport.ReportStatus.PENDING)) {
            throw new BusinessException("You have already reported this property");
        }

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new ResourceNotFoundException("Property not found: " + propertyId));
        User reporter = userRepository.findById(reporterId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + reporterId));

        PropertyReport report = PropertyReport.builder()
                .property(property)
                .reporter(reporter)
                .reason(reason)
                .description(description)
                .status(PropertyReport.ReportStatus.PENDING)
                .build();

        reportRepository.save(report);
        log.info("Report submitted for property {} by user {}: {}", propertyId, reporterId, reason);
    }

    @Override
    public void putUnderReview(Long reportId) {
        PropertyReport report = findReportById(reportId);
        report.setStatus(PropertyReport.ReportStatus.UNDER_REVIEW);
        reportRepository.save(report);

        // Set property status to UNDER_REVIEW
        Property property = report.getProperty();
        property.setStatus(PropertyStatus.UNDER_REVIEW);
        propertyRepository.save(property);

        // Notify the agent asynchronously
        emailService.sendListingUnderReviewEmail(property.getAgent(), property);
        log.info("Report {} put under review. Property {} marked UNDER_REVIEW.", reportId, property.getId());
    }

    @Override
    public void dismissReport(Long reportId) {
        PropertyReport report = findReportById(reportId);
        report.setStatus(PropertyReport.ReportStatus.DISMISSED);
        reportRepository.save(report);
        log.info("Report {} dismissed.", reportId);
    }

    @Override
    public void removeListing(Long reportId) {
        PropertyReport report = findReportById(reportId);
        report.setStatus(PropertyReport.ReportStatus.REMOVED);
        reportRepository.save(report);

        // Soft-delete: we repurpose isDeleted using status
        Property property = report.getProperty();
        property.setStatus(PropertyStatus.REJECTED);
        propertyRepository.save(property);
        log.info("Report {} resolved. Property {} rejected/removed.", reportId, property.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<PropertyReport> findByStatus(PropertyReport.ReportStatus status) {
        return reportRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    private PropertyReport findReportById(Long reportId) {
        return reportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found: " + reportId));
    }
}
