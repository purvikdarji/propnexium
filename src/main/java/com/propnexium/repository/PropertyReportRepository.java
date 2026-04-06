package com.propnexium.repository;

import com.propnexium.entity.PropertyReport;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PropertyReportRepository extends JpaRepository<PropertyReport, Long> {

    List<PropertyReport> findByStatusOrderByCreatedAtDesc(PropertyReport.ReportStatus status);

    long countByStatus(PropertyReport.ReportStatus status);

    boolean existsByPropertyIdAndReporterIdAndStatus(
            Long propertyId, Long reporterId, PropertyReport.ReportStatus status);
}
