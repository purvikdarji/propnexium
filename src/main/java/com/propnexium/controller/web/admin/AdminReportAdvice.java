package com.propnexium.controller.web.admin;

import com.propnexium.entity.PropertyReport.ReportStatus;
import com.propnexium.repository.PropertyReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
@RequiredArgsConstructor
public class AdminReportAdvice {

    private final PropertyReportRepository reportRepository;

    @ModelAttribute("pendingReportCount")
    public long pendingReportCount() {
        try {
            return reportRepository.countByStatus(ReportStatus.PENDING);
        } catch (Exception e) {
            return 0L;
        }
    }
}
