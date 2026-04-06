package com.propnexium.service;

import com.propnexium.entity.PriceHistory;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;

import java.math.BigDecimal;
import java.util.List;

public interface PriceHistoryService {
    void recordPriceChange(Property property, BigDecimal oldPrice, BigDecimal newPrice, User changedBy);
    List<PriceHistory> getPropertyPriceHistory(Long propertyId);
}
