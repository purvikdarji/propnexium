package com.propnexium.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "price_history", indexes = {
    @Index(name = "idx_property_id", columnList = "property_id"),
    @Index(name = "idx_changed_at", columnList = "changed_at")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PriceHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "property_id", nullable = false)
    @JsonIgnore
    private Property property;

    @Column(name = "old_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal oldPrice;

    @Column(name = "new_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal newPrice;

    @Column(name = "change_percent", precision = 6, scale = 2)
    private BigDecimal changePercent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    @JsonIgnore
    private User changedBy;

    @Column(name = "changed_at", nullable = false)
    private LocalDateTime changedAt;

    public java.util.Date getChangedDate() {
        if (this.changedAt == null) return null;
        return java.util.Date.from(this.changedAt.atZone(java.time.ZoneId.systemDefault()).toInstant());
    }
}
