package com.propnexium.controller.web;
import com.propnexium.dto.response.ApiResponse;
import com.propnexium.util.AreaConverterUtil;
import com.propnexium.util.AreaUnit;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class AreaConverterController {

    private static final List<String> STATES = List.of(
            "Gujarat", "Maharashtra", "Karnataka", "Tamil Nadu", "Kerala",
            "Andhra Pradesh", "Uttar Pradesh", "Bihar", "Rajasthan",
            "Punjab", "Delhi", "West Bengal"    );

    @GetMapping("/tools/area-converter")
    public String converterPage(Model model) {
        model.addAttribute("states", STATES);
        model.addAttribute("areaUnits", AreaUnit.values());
        return "tools/area-converter";    }

    @GetMapping("/api/v1/convert-area")
    @ResponseBody
    public ResponseEntity<ApiResponse<Map<String, Object>>> convertArea(
            @RequestParam double value,
            @RequestParam String fromUnit,
            @RequestParam String toUnit) {
        AreaUnit from;
        AreaUnit to;
        try {
            from = AreaUnit.valueOf(fromUnit.toUpperCase());
            to   = AreaUnit.valueOf(toUnit.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Invalid unit: " + e.getMessage()));        }

        double inSqft  = value * from.getSqftEquivalent();
        double result  = inSqft / to.getSqftEquivalent();

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("inputValue",       value);
        data.put("fromUnit",         from.getDisplayName());
        data.put("toUnit",           to.getDisplayName());
        data.put("result",           Math.round(result  * 10000.0) / 10000.0);
        data.put("resultFormatted",  String.format("%.4f", result));
        data.put("inSqft",           Math.round(inSqft / 1.0      * 100.0) / 100.0);
        data.put("inSqmt",           Math.round(inSqft / 10.7639  * 100.0) / 100.0);
        data.put("inAcre",           Math.round(inSqft / 43560.0  * 10000.0) / 10000.0);

        return ResponseEntity.ok(ApiResponse.success(data, "OK"));
    }

    @GetMapping("/api/v1/area-units-for-state")
    @ResponseBody
    public ResponseEntity<ApiResponse<List<Map<String, String>>>> getUnitsForState(
            @RequestParam String state) {

        List<String> unitKeys = AreaConverterUtil.STATE_UNITS
                .getOrDefault(state, AreaConverterUtil.DEFAULT_UNITS);

        List<Map<String, String>> units = unitKeys.stream()
                .map(key -> {
                    AreaUnit u = AreaUnit.valueOf(key);
                    Map<String, String> m = new LinkedHashMap<>();
                    m.put("key",  key);
                    m.put("name", u.getDisplayName());
                    return m;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(units, "OK"));
    }
}
