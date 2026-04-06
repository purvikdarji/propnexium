package com.propnexium.service.impl;

import com.propnexium.entity.Property;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.repository.SubscriberRepository;
import com.propnexium.service.ExcelExportService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ExcelExportServiceImpl implements ExcelExportService {

    @Autowired
    private PropertyRepository propertyRepository;

    @Autowired
    private SubscriberRepository subscriberRepository;

    @Override
    public byte[] exportPropertiesToExcel(String statusFilter) {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Properties");

            // ─── STYLES ───────────────────────────────────────────────────────

            // Blue header style
            XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(
                    new XSSFColor(new byte[]{(byte) 26, (byte) 115, (byte) 232}, null));
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            XSSFFont headerFont = workbook.createFont();
            headerFont.setColor(new XSSFColor(
                    new byte[]{(byte) 255, (byte) 255, (byte) 255}, null));
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(headerFont);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            // Even row style (light blue-grey)
            XSSFCellStyle evenRowStyle = workbook.createCellStyle();
            evenRowStyle.setFillForegroundColor(
                    new XSSFColor(new byte[]{(byte) 241, (byte) 245, (byte) 249}, null));
            evenRowStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            // Odd row style (plain white – default)
            XSSFCellStyle oddRowStyle = workbook.createCellStyle();

            // Currency style for price column (inherits even row colour by default;
            // we create a separate one so even/odd rows keep their background)
            DataFormat dataFormat = workbook.createDataFormat();
            short currencyFmt = dataFormat.getFormat("\"₹\"#,##0.00");

            XSSFCellStyle evenCurrencyStyle = workbook.createCellStyle();
            evenCurrencyStyle.cloneStyleFrom(evenRowStyle);
            evenCurrencyStyle.setDataFormat(currencyFmt);

            XSSFCellStyle oddCurrencyStyle = workbook.createCellStyle();
            oddCurrencyStyle.cloneStyleFrom(oddRowStyle);
            oddCurrencyStyle.setDataFormat(currencyFmt);

            // ─── HEADER ROW ───────────────────────────────────────────────────
            String[] headers = {
                    "ID", "Title", "City", "Type", "Category",
                    "Price (₹)", "Bedrooms", "Bathrooms", "Area (sqft)",
                    "Furnishing", "Status", "Agent", "Created At"
            };

            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 18 * 256);
            }
            sheet.setColumnWidth(1, 35 * 256);  // wider title
            sheet.setColumnWidth(5, 20 * 256);  // wider price

            // Freeze header row so it stays visible when scrolling
            sheet.createFreezePane(0, 1);

            // ─── DATA ROWS ────────────────────────────────────────────────────
            List<Property> properties;
            if (statusFilter != null && !statusFilter.isEmpty()) {
                properties = propertyRepository.findByStatus(
                        PropertyStatus.valueOf(statusFilter.toUpperCase()));
            } else {
                properties = propertyRepository.findAll();
            }

            int rowNum = 1;
            for (Property p : properties) {
                Row row = sheet.createRow(rowNum);
                boolean isEven = (rowNum % 2 == 0);
                XSSFCellStyle rowStyle = isEven ? evenRowStyle : oddRowStyle;
                XSSFCellStyle currStyle = isEven ? evenCurrencyStyle : oddCurrencyStyle;

                createCell(row, 0, String.valueOf(p.getId()), rowStyle);
                createCell(row, 1, safeStr(p.getTitle()), rowStyle);
                createCell(row, 2, safeStr(p.getCity()), rowStyle);
                createCell(row, 3, p.getType() != null ? p.getType().toString() : "-", rowStyle);
                createCell(row, 4, p.getCategory() != null ? p.getCategory().toString() : "-", rowStyle);

                // Price as numeric with INR currency format
                Cell priceCell = row.createCell(5);
                priceCell.setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0.0);
                priceCell.setCellStyle(currStyle);

                createCell(row, 6, p.getBedrooms() != null ? p.getBedrooms().toString() : "-", rowStyle);
                createCell(row, 7, p.getBathrooms() != null ? p.getBathrooms().toString() : "-", rowStyle);
                createCell(row, 8, p.getAreaSqft() != null ? p.getAreaSqft().toString() : "-", rowStyle);
                createCell(row, 9, p.getFurnishing() != null ? p.getFurnishing().toString() : "-", rowStyle);
                createCell(row, 10, p.getStatus() != null ? p.getStatus().toString() : "-", rowStyle);

                String agentName = (p.getAgent() != null) ? safeStr(p.getAgent().getName()) : "-";
                createCell(row, 11, agentName, rowStyle);

                String createdAt = (p.getCreatedAt() != null)
                        ? p.getCreatedAt().format(DateTimeFormatter.ofPattern("dd-MM-yyyy"))
                        : "-";
                createCell(row, 12, createdAt, rowStyle);

                rowNum++;
            }

            // Auto-size all columns for best fit
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);
            return baos.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Failed to generate Properties Excel export", e);
        }
    }

    @Override
    public byte[] exportSubscribersToExcel() {
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            XSSFSheet sheet = workbook.createSheet("Subscribers");

            // ─── STYLES (same palette as properties export) ───────────────────
            XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(
                    new XSSFColor(new byte[]{(byte) 26, (byte) 115, (byte) 232}, null));
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            XSSFFont headerFont = workbook.createFont();
            headerFont.setColor(new XSSFColor(
                    new byte[]{(byte) 255, (byte) 255, (byte) 255}, null));
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(headerFont);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            XSSFCellStyle evenRowStyle = workbook.createCellStyle();
            evenRowStyle.setFillForegroundColor(
                    new XSSFColor(new byte[]{(byte) 241, (byte) 245, (byte) 249}, null));
            evenRowStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            XSSFCellStyle oddRowStyle = workbook.createCellStyle();

            // ─── HEADER ROW ───────────────────────────────────────────────────
            String[] headers = {"ID", "Email", "Subscribed At", "Status"};
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 20 * 256);
            }
            sheet.setColumnWidth(1, 40 * 256); // wider email column
            sheet.createFreezePane(0, 1);

            // ─── DATA ROWS ────────────────────────────────────────────────────
            List<com.propnexium.entity.Subscriber> subscribers =
                    subscriberRepository.findByIsSubscribedTrue();

            int rowNum = 1;
            for (com.propnexium.entity.Subscriber s : subscribers) {
                Row row = sheet.createRow(rowNum);
                boolean isEven = (rowNum % 2 == 0);
                XSSFCellStyle rowStyle = isEven ? evenRowStyle : oddRowStyle;

                createCell(row, 0, String.valueOf(s.getId()), rowStyle);
                createCell(row, 1, safeStr(s.getEmail()), rowStyle);
                createCell(row, 2,
                        s.getSubscribedAt() != null
                                ? s.getSubscribedAt().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"))
                                : "-", rowStyle);
                createCell(row, 3, s.isSubscribed() ? "Active" : "Unsubscribed", rowStyle);
                rowNum++;
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);
            return baos.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Failed to generate Subscribers Excel export", e);
        }
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private String safeStr(String s) {
        return s != null ? s : "";
    }
}
