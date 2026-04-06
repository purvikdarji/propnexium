package com.propnexium.service.impl;

import com.propnexium.entity.PriceHistory;
import com.propnexium.entity.Property;
import com.propnexium.entity.User;
import com.propnexium.repository.PriceHistoryRepository;
import com.propnexium.service.PriceHistoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class PriceHistoryServiceImpl implements PriceHistoryService {

    private final PriceHistoryRepository priceHistoryRepository;

    @Override
    public void recordPriceChange(Property property, BigDecimal oldPrice, BigDecimal newPrice, User changedBy) {
        if (oldPrice == null || newPrice == null) {
            return; 
        }
        
        if (oldPrice.compareTo(newPrice) == 0) {
            return; // Guard: if oldPrice equals newPrice, return immediately
        }

        BigDecimal change = newPrice.subtract(oldPrice);
        BigDecimal percent = BigDecimal.ZERO;
        
        if (oldPrice.compareTo(BigDecimal.ZERO) != 0) {
            percent = change.divide(oldPrice, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100))
                    .setScale(2, RoundingMode.HALF_UP);
        }

        PriceHistory priceHistory = PriceHistory.builder()
                .property(property)
                .oldPrice(oldPrice)
                .newPrice(newPrice)
                .changePercent(percent)
                .changedBy(changedBy)
                .changedAt(LocalDateTime.now())
                .build();

        priceHistoryRepository.save(priceHistory);

        log.info("Price changed for property #{}: ₹{} → ₹{} ({}%)", 
                property.getId(), oldPrice, newPrice, percent);
    }

    @Override
    public List<PriceHistory> getPropertyPriceHistory(Long propertyId) {
        return priceHistoryRepository.findByPropertyIdOrderByChangedAtAsc(propertyId);
    }
}
