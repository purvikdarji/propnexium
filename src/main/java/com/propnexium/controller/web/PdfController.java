package com.propnexium.controller.web;

import com.propnexium.service.PdfReportService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/pdf")
public class PdfController {

    private final PdfReportService pdfReportService;

    public PdfController(PdfReportService pdfReportService) {
        this.pdfReportService = pdfReportService;
    }

    // Property detail PDF download
    @GetMapping("/property/{id}")
    public ResponseEntity<byte[]> downloadPropertyReport(@PathVariable Long id) {

        byte[] pdfBytes = pdfReportService.generatePropertyReport(id);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"property-" + id + "-report.pdf\"")
                .header(HttpHeaders.CONTENT_TYPE, "application/pdf")
                .header(HttpHeaders.CONTENT_LENGTH,
                        String.valueOf(pdfBytes.length))
                .body(pdfBytes);
    }

    // Agent listings PDF download
    @GetMapping("/agent/{id}/listings")
    public ResponseEntity<byte[]> downloadAgentListings(@PathVariable Long id) {

        byte[] pdfBytes = pdfReportService.generateAgentListingsReport(id);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"agent-" + id + "-listings.pdf\"")
                .header(HttpHeaders.CONTENT_TYPE, "application/pdf")
                .body(pdfBytes);
    }
}
