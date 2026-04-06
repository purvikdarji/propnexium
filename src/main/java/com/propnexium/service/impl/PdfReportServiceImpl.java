package com.propnexium.service.impl;

import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.canvas.draw.SolidLine;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.borders.SolidBorder;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.LineSeparator;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.layout.properties.VerticalAlignment;
import com.propnexium.entity.Property;
import com.propnexium.entity.PropertyAmenities;
import com.propnexium.entity.User;
import com.propnexium.entity.enums.PropertyStatus;
import com.propnexium.repository.PropertyRepository;
import com.propnexium.service.PdfReportService;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class PdfReportServiceImpl implements PdfReportService {

    private final PropertyRepository propertyRepository;

    private static final DeviceRgb PRIMARY_BLUE = new DeviceRgb(26, 115, 232); // #1A73E8
    private static final DeviceRgb LIGHT_BLUE = new DeviceRgb(232, 240, 254); // #E8F0FE
    private static final DeviceRgb DARK_TEXT = new DeviceRgb(30, 41, 59); // #1E293B
    private static final DeviceRgb GREY_TEXT = new DeviceRgb(100, 116, 139); // #64748B
    private static final DeviceRgb SUCCESS_GREEN = new DeviceRgb(34, 197, 94); // #22C55E
    private static final DeviceRgb GREY_LIGHT = new DeviceRgb(241, 245, 249); // #F1F5F9
    private static final DeviceRgb WHITE = new DeviceRgb(255, 255, 255);

    public PdfReportServiceImpl(PropertyRepository propertyRepository) {
        this.propertyRepository = propertyRepository;
    }

    @Override
    public byte[] generatePropertyReport(Long propertyId) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new com.propnexium.exception.ResourceNotFoundException("Property", "id", propertyId));

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc, PageSize.A4);
        document.setMargins(0, 0, 40, 0);

        // ─── SECTION 1: BLUE HEADER TABLE ───
        Table headerTable = new Table(UnitValue.createPercentArray(new float[] { 60, 40 }))
                .setWidth(UnitValue.createPercentValue(100))
                .setBackgroundColor(PRIMARY_BLUE)
                .setPadding(20)
                .setMarginBottom(0);

        Cell leftHeader = new Cell()
                .add(new Paragraph("PropNexium")
                        .setFontColor(WHITE).setFontSize(24).setBold())
                .add(new Paragraph("Property Report")
                        .setFontColor(new DeviceRgb(200, 220, 255)).setFontSize(12))
                .setBorder(Border.NO_BORDER)
                .setBackgroundColor(PRIMARY_BLUE);

        Cell rightHeader = new Cell()
                .add(new Paragraph("Report Date: " +
                        LocalDate.now().format(DateTimeFormatter.ofPattern("dd MMM yyyy")))
                        .setFontColor(WHITE).setFontSize(10).setTextAlignment(TextAlignment.RIGHT))
                .add(new Paragraph("Property ID: #" + property.getId())
                        .setFontColor(WHITE).setFontSize(10).setTextAlignment(TextAlignment.RIGHT))
                .setBorder(Border.NO_BORDER)
                .setBackgroundColor(PRIMARY_BLUE)
                .setVerticalAlignment(VerticalAlignment.MIDDLE);

        headerTable.addCell(leftHeader).addCell(rightHeader);
        document.add(headerTable);

        // ─── SECTION 2: PROPERTY TITLE BAR ───
        document.add(new Paragraph(property.getTitle())
                .setFontSize(18).setBold().setFontColor(DARK_TEXT)
                .setBackgroundColor(LIGHT_BLUE)
                .setPadding(16).setMarginTop(0).setMarginBottom(0));

        // ─── SECTION 3: 3-COLUMN PRICE / TYPE / CATEGORY TABLE ───
        Table priceTable = new Table(UnitValue.createPercentArray(new float[] { 33, 33, 34 }))
                .setWidth(UnitValue.createPercentValue(100))
                .setMarginTop(12).setMarginBottom(12)
                .setPaddingLeft(20).setPaddingRight(20);

        addPriceCell(priceTable, "Price",
                "₹" + formatIndianPrice(property.getPrice()), PRIMARY_BLUE);
        addPriceCell(priceTable, "Property Type",
                property.getType().toString(), DARK_TEXT);
        addPriceCell(priceTable, "Category",
                property.getCategory().toString(), DARK_TEXT);
        document.add(priceTable);

        // ─── SECTION 4: 4-COLUMN DETAILS TABLE (8 attributes) ───
        Table detailsTable = new Table(UnitValue.createPercentArray(
                new float[] { 25, 25, 25, 25 }))
                .setWidth(UnitValue.createPercentValue(100))
                .setMarginBottom(12)
                .setBorder(new SolidBorder(new DeviceRgb(229, 231, 235), 1));

        String[][] details = {
                { "🛏 Bedrooms", String.valueOf(property.getBedrooms()) },
                { "🚿 Bathrooms", String.valueOf(property.getBathrooms()) },
                { "📐 Total Area", property.getAreaSqft() != null ? property.getAreaSqft() + " sq ft" : "N/A" },
                { "🏠 Total Floors",
                        property.getTotalFloors() != null ? String.valueOf(property.getTotalFloors()) : "N/A" },
                { "🪑 Furnishing", property.getFurnishing() != null ? property.getFurnishing().toString() : "N/A" },
                { "🚗 Parking", property.getParking() != null ? property.getParking().toString() : "N/A" },
                { "🏢 Floor", property.getFloorNumber() != null ? String.valueOf(property.getFloorNumber()) : "N/A" },
                { "📅 Year Built", property.getYearBuilt() != null ? String.valueOf(property.getYearBuilt()) : "New" }
        };

        for (int i = 0; i < details.length; i++) {
            Cell detailCell = new Cell()
                    .add(new Paragraph(details[i][0])
                            .setFontSize(9).setFontColor(GREY_TEXT))
                    .add(new Paragraph(details[i][1])
                            .setFontSize(13).setBold().setFontColor(DARK_TEXT))
                    .setBackgroundColor(i % 2 == 0 ? WHITE : GREY_LIGHT)
                    .setPadding(12)
                    .setBorderRight(new SolidBorder(new DeviceRgb(229, 231, 235), 0.5f))
                    .setBorderBottom(new SolidBorder(new DeviceRgb(229, 231, 235), 0.5f))
                    .setBorderLeft(Border.NO_BORDER)
                    .setBorderTop(Border.NO_BORDER);
            detailsTable.addCell(detailCell);
        }
        document.add(detailsTable);

        // ─── SECTION 5: LOCATION ───
        document.add(new Paragraph("📍 Location")
                .setFontSize(13).setBold().setFontColor(DARK_TEXT)
                .setMarginBottom(4).setPaddingLeft(16));

        String addressLocation = property.getLocation() != null ? property.getLocation() + ", " : "";
        document.add(new Paragraph(
                addressLocation + property.getCity() + ", " +
                        property.getState() + " - " + property.getPincode())
                .setFontSize(11).setFontColor(GREY_TEXT)
                .setPaddingLeft(16).setMarginBottom(12));

        // ─── SECTION 6: DESCRIPTION ───
        document.add(new Paragraph("Description")
                .setFontSize(13).setBold().setFontColor(DARK_TEXT)
                .setMarginBottom(6).setPaddingLeft(16));
        document.add(new Paragraph(property.getDescription() != null ? property.getDescription() : "")
                .setFontSize(10).setFontColor(GREY_TEXT)
                .setMarginBottom(16).setPaddingLeft(16).setPaddingRight(16)
                .setTextAlignment(TextAlignment.JUSTIFIED));

        // ─── SECTION 7: AMENITIES 4-COLUMN TABLE ───
        document.add(new Paragraph("Amenities")
                .setFontSize(13).setBold().setFontColor(DARK_TEXT)
                .setMarginBottom(8).setPaddingLeft(16));

        Table amenitiesTable = new Table(UnitValue.createPercentArray(
                new float[] { 25, 25, 25, 25 }))
                .setWidth(UnitValue.createPercentValue(100))
                .setMarginBottom(16).setPaddingLeft(16).setPaddingRight(16);

        Map<String, Boolean> amenitiesMap = new LinkedHashMap<>();
        if (property.getAmenities() != null) {
            PropertyAmenities pa = property.getAmenities();
            amenitiesMap.put("Gym", pa.getHasGym());
            amenitiesMap.put("Swimming Pool", pa.getHasSwimmingPool());
            amenitiesMap.put("Security", pa.getHasSecurity());
            amenitiesMap.put("Lift", pa.getHasLift());
            amenitiesMap.put("Power Backup", pa.getHasPowerBackup());
            amenitiesMap.put("Club House", pa.getHasClubHouse());
            amenitiesMap.put("Children Play Area", pa.getHasChildrenPlayArea());
            amenitiesMap.put("Garden", pa.getHasGarden());
            amenitiesMap.put("Intercom", pa.getHasIntercom());
            amenitiesMap.put("Rainwater Harv.", pa.getHasRainwaterHarvesting());
            amenitiesMap.put("Waste Mgmt", pa.getHasWasteManagement());
            amenitiesMap.put("Visitor Parking", pa.getHasVisitorParking());
        }

        for (Map.Entry<String, Boolean> entry : amenitiesMap.entrySet()) {
            boolean hasAmenity = Boolean.TRUE.equals(entry.getValue());
            Cell amenityCell = new Cell()
                    .add(new Paragraph(
                            (hasAmenity ? "✓  " : "✗  ") + entry.getKey())
                            .setFontSize(10)
                            .setFontColor(hasAmenity ? SUCCESS_GREEN : GREY_TEXT))
                    .setBorder(Border.NO_BORDER)
                    .setPaddingBottom(6);
            amenitiesTable.addCell(amenityCell);
        }
        document.add(amenitiesTable);

        // ─── SECTION 8: AGENT INFO CARD ───
        User agent = property.getAgent();
        if (agent != null) {
            Table agentTable = new Table(UnitValue.createPercentArray(new float[] { 20, 80 }))
                    .setWidth(UnitValue.createPercentValue(100))
                    .setBackgroundColor(LIGHT_BLUE)
                    .setBorder(new SolidBorder(PRIMARY_BLUE, 1))
                    .setMarginBottom(20).setPaddingLeft(16).setPaddingRight(16);

            agentTable.addCell(new Cell()
                    .add(new Paragraph("Listed By")
                            .setFontSize(9).setFontColor(GREY_TEXT))
                    .add(new Paragraph(agent.getName())
                            .setFontSize(14).setBold().setFontColor(DARK_TEXT))
                    .add(new Paragraph(agent.getEmail())
                            .setFontSize(10).setFontColor(GREY_TEXT))
                    .add(new Paragraph(agent.getPhone() != null ? agent.getPhone() : "")
                            .setFontSize(10).setFontColor(PRIMARY_BLUE))
                    .setBorder(Border.NO_BORDER).setPadding(14)
                    .setVerticalAlignment(VerticalAlignment.MIDDLE));

            long agentListings = propertyRepository.countByAgentIdAndStatusNot(
                    agent.getId(), PropertyStatus.REJECTED);
            agentTable.addCell(new Cell()
                    .add(new Paragraph("Total Listings: " + agentListings)
                            .setFontSize(10).setFontColor(GREY_TEXT))
                    .setBorder(Border.NO_BORDER).setPadding(14)
                    .setTextAlignment(TextAlignment.RIGHT)
                    .setVerticalAlignment(VerticalAlignment.MIDDLE));

            document.add(agentTable);
        }

        // ─── SECTION 9: FOOTER with LineSeparator ───
        document.add(new LineSeparator(new SolidLine(1f))
                .setMarginBottom(8));
        document.add(new Paragraph(
                "Generated by PropNexium on " +
                        LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")) +
                        "  •  propnexium.com  •  This report is auto-generated.")
                .setFontSize(8).setFontColor(GREY_TEXT)
                .setTextAlignment(TextAlignment.CENTER));

        document.close();
        return baos.toByteArray();
    }

    @Override
    public byte[] generateAgentListingsReport(Long agentId) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc, PageSize.A4);
        document.setMargins(40, 40, 40, 40);

        document.add(new Paragraph("Agent Listings Report")
                .setFontColor(PRIMARY_BLUE).setFontSize(20).setBold()
                .setMarginBottom(16));

        Table listingsTable = new Table(
                UnitValue.createPercentArray(new float[] { 35, 15, 12, 10, 18, 10 }))
                .setWidth(UnitValue.createPercentValue(100));

        String[] headers = { "Title", "City", "Type", "Category", "Price", "Status" };
        for (String h : headers) {
            listingsTable.addHeaderCell(new Cell()
                    .add(new Paragraph(h).setFontColor(WHITE).setFontSize(10).setBold())
                    .setBackgroundColor(PRIMARY_BLUE)
                    .setPadding(8).setBorder(Border.NO_BORDER));
        }

        List<Property> agentProperties = propertyRepository.findByAgentIdAndStatusNot(agentId, PropertyStatus.REJECTED);
        int rowIndex = 0;
        for (Property p : agentProperties) {
            DeviceRgb rowBg = rowIndex++ % 2 == 0 ? WHITE : GREY_LIGHT;
            listingsTable.addCell(createDataCell(p.getTitle(), rowBg, 9));
            listingsTable.addCell(createDataCell(p.getCity(), rowBg, 9));
            listingsTable.addCell(createDataCell(p.getType().toString(), rowBg, 9));
            listingsTable.addCell(createDataCell(p.getCategory().toString(), rowBg, 9));
            listingsTable.addCell(createDataCell(
                    "₹" + formatIndianPrice(p.getPrice()), rowBg, 9));
            listingsTable.addCell(createDataCell(p.getStatus().toString(), rowBg, 9));
        }
        document.add(listingsTable);

        document.add(new LineSeparator(new SolidLine(1f))
                .setMarginBottom(8).setMarginTop(20));
        document.add(new Paragraph(
                "Generated by PropNexium on " +
                        LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")))
                .setFontSize(8).setFontColor(GREY_TEXT)
                .setTextAlignment(TextAlignment.CENTER));

        document.close();
        return baos.toByteArray();
    }

    private void addPriceCell(Table table, String label,
            String value, DeviceRgb valueColor) {
        table.addCell(new Cell()
                .add(new Paragraph(label)
                        .setFontSize(9).setFontColor(GREY_TEXT).setMarginBottom(2))
                .add(new Paragraph(value)
                        .setFontSize(16).setBold().setFontColor(valueColor))
                .setBorder(Border.NO_BORDER)
                .setPaddingLeft(16));
    }

    private Cell createDataCell(String text, DeviceRgb bgColor, int fontSize) {
        return new Cell()
                .add(new Paragraph(text != null ? text : "")
                        .setFontSize(fontSize).setFontColor(DARK_TEXT))
                .setBackgroundColor(bgColor)
                .setPadding(8).setBorder(Border.NO_BORDER);
    }

    private String formatIndianPrice(BigDecimal price) {
        if (price == null)
            return "0";
        NumberFormat formatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        String formatted = formatter.format(price);
        return formatted.replace("₹", "").replace("Rs.", "").trim(); // Depending on locale format
    }
}
