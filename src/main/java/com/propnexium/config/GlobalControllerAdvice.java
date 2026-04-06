package com.propnexium.config;

import com.propnexium.service.SubscriberService;
import com.propnexium.util.AreaUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

    @Autowired
    private SubscriberService subscriberService;

    @ModelAttribute("isGlobalSubscribed")
    public boolean isGlobalSubscribed() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !auth.getPrincipal().equals("anonymousUser")) {
            return subscriberService.isEmailSubscribed(auth.getName());
        }
        return false;
    }

    /** Exposes all area units to every view — used by converter dropdowns. */
    @ModelAttribute("areaUnits")
    public AreaUnit[] allAreaUnits() {
        return AreaUnit.values();
    }
}
