package com.propnexium.service;

public interface ExcelExportService {

    /**
     * Exports all properties (or filtered by status) to an Excel workbook.
     *
     * @param statusFilter optional PropertyStatus name (e.g. "AVAILABLE"), null = all
     * @return byte array of the .xlsx workbook
     */
    byte[] exportPropertiesToExcel(String statusFilter);

    /**
     * Placeholder for exporting newsletter subscribers.
     *
     * @return byte array of the .xlsx workbook
     */
    byte[] exportSubscribersToExcel();
}
