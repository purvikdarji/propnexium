package com.propnexium.dto.response;
import com.propnexium.dto.request.SearchCriteriaDto;
import com.propnexium.entity.Property;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class SearchResultDto {

    private List<Property> properties;
    private long totalCount;
    private int totalPages;
    private int currentPage;
    private long searchTimeMs;
    private SearchCriteriaDto criteria;
}
