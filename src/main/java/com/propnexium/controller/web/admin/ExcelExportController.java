package com.propnexium.controller.web.admin;

import com.propnexium.service.ExcelExportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Controller
@PreAuthorize("hasRole('ADMIN')")
public class ExcelExportController {

    @Autowired
    private ExcelExportService excelExportService;

    /**
     * GET /admin/export/properties?status=AVAILABLE
     * Downloads a propnexium-properties-YYYY-MM-DD.xlsx file.
     */
    @GetMapping("/admin/export/properties")
    public ResponseEntity<byte[]> exportProperties(
            @RequestParam(required = false) String status) {

        String date     = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String filename = "propnexium-properties-" + date + ".xlsx";

        byte[] excelBytes = excelExportService.exportPropertiesToExcel(status);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + filename + "\"")
                .header(HttpHeaders.CONTENT_TYPE,
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(excelBytes);
    }

    /**
     * GET /admin/export/subscribers
     * Downloads a propnexium-subscribers-YYYY-MM-DD.xlsx file.
     */
    @GetMapping("/admin/export/subscribers")
    public ResponseEntity<byte[]> exportSubscribers() {

        String date     = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String filename = "propnexium-subscribers-" + date + ".xlsx";

        byte[] excelBytes = excelExportService.exportSubscribersToExcel();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + filename + "\"")
                .header(HttpHeaders.CONTENT_TYPE,
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                .body(excelBytes);
    }
}
