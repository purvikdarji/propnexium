package com.propnexium.event;

import com.propnexium.entity.Property;
import org.springframework.context.ApplicationEvent;

public class PropertyApprovedEvent extends ApplicationEvent {
    
    private final Property property;

    public PropertyApprovedEvent(Object source, Property property) {
        super(source);
        this.property = property;
    }

    public Property getProperty() {
        return property;
    }
}
