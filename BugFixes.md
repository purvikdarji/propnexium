# PropNexium — Bug Fixes, Security Verification & Application Properties Review

> **Package root:** `com.propnexium`  
> **Spring Boot:** 3.x  · **Java 17+**

---

## 1. NullPointerException Guards

These guards must be applied wherever the corresponding objects are accessed.

---

### Guard 1 — `property.getImages()` before accessing index `[0]`

**Risk:** If a property has no images, `.get(0)` throws `IndexOutOfBoundsException`.  
**Apply in:** Any JSP/model-builder that extracts a "primary image" thumbnail.

**Unsafe (original):**
```java
String primaryImage = property.getImages().get(0).getImageUrl();
```

**Safe (fixed):**
```java
String primaryImage = (property.getImages() != null && !property.getImages().isEmpty())
    ? property.getImages().get(0).getImageUrl()
    : "/images/placeholder.jpg";
```

**JSP equivalent (EL):**
```jsp
<c:set var="primaryImage"
       value="${not empty property.images ? property.images[0].imageUrl : '/images/placeholder.jpg'}" />
<img src="${primaryImage}" alt="${property.title}" class="card-img-top" />
```

---

### Guard 2 — `property.getAgent()` null check before `getName()`

**Risk:** A property without an assigned agent causes NPE on any agent name access.  
**Apply in:** `PropertyWebController`, service layer, and any JSP that renders agent info.

**Unsafe (original):**
```java
String agentName = property.getAgent().getName();
```

**Safe (fixed):**
```java
String agentName = (property.getAgent() != null)
    ? property.getAgent().getName()
    : "Unknown Agent";
```

**In `PropertyWebController.propertyDetail()`**, also guards the agent profile display:
```java
model.addAttribute("agentName",
    property.getAgent() != null ? property.getAgent().getName() : "Unknown Agent");
model.addAttribute("agentEmail",
    property.getAgent() != null ? property.getAgent().getEmail() : "N/A");
```

---

### Guard 3 — `nearbyMapDataJson` defaults to `[]` when no nearby properties found

**Risk:** `mapper.writeValueAsString(emptyList)` returns `"[]"` normally, but if
`nearbyProperties` itself is null (e.g. query returns null) it NPEs.  
**Apply in:** `PropertyWebController.propertyDetail()`

**Current code in `PropertyWebController` (already partially guarded — verify it looks like this):**
```java
try {
    ObjectMapper mapper = new ObjectMapper();
    List<Map<String, Object>> nearbyMapData = nearbyProperties.stream().map(np -> {
        double[] c = propertyService.getEffectiveLatLng(np);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id",    np.getId());
        m.put("title", np.getTitle());
        m.put("price", np.getPrice());
        m.put("lat",   c[0]);
        m.put("lng",   c[1]);
        return m;
    }).collect(Collectors.toList());

    // Guard: default to empty array if nearbyMapData is empty or serialisation fails
    model.addAttribute("nearbyMapDataJson",
        nearbyMapData.isEmpty() ? "[]" : mapper.writeValueAsString(nearbyMapData));

} catch (Exception e) {
    model.addAttribute("nearbyMapDataJson", "[]");   // fallback
}
```

**Verify that the catch block is present** — the `try-catch` already handles the serialisation fault, but add the `isEmpty()` check inside the try block as shown above.

---

### Guard 4 — JSP `priceHistory` section wrapped in `<c:if>`

**Risk:** If `priceHistory` is empty or null, the table and Chart.js `<canvas>` still render
causing a blank chart section with "No data" or a JS error.  
**Apply in:** `src/main/webapp/WEB-INF/views/property/detail.jsp`

**Wrap the entire price-history block:**
```jsp
<%-- Price History: only render if at least 1 historic price change exists --%>
<c:if test="${not empty priceHistory}">
  <div class="card mb-4 shadow-sm" id="priceHistorySection">
    <div class="card-header fw-semibold">📈 Price History</div>
    <div class="card-body">

      <%-- History table --%>
      <table class="table table-sm table-hover">
        <thead>
          <tr>
            <th>Date</th>
            <th>Old Price</th>
            <th>New Price</th>
            <th>Change</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="ph" items="${priceHistory}">
            <tr>
              <td><fmt:formatDate value="${ph.changedDate}" pattern="dd MMM yyyy" /></td>
              <td><s>₹<fmt:formatNumber value="${ph.oldPrice}" pattern="#,##,##0"/></s></td>
              <td>₹<fmt:formatNumber value="${ph.newPrice}" pattern="#,##,##0"/></td>
              <td>
                <c:choose>
                  <c:when test="${ph.changePercent gt 0}">
                    <span class="badge bg-danger">▲ <fmt:formatNumber value="${ph.changePercent}" maxFractionDigits="1"/>%</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-success">▼ <fmt:formatNumber value="${ph.changePercent}" maxFractionDigits="1"/>%</span>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>

      <%-- Chart.js line chart — only rendered when history is present --%>
      <canvas id="priceHistoryChart" height="120"></canvas>
    </div>
  </div>
</c:if>
```

> **Note:** Because the `<canvas>` and Chart.js initialisation JS are inside `<c:if>`, the chart
> script only executes when there is actual data, entirely avoiding "Cannot read undefined" errors.

---

### Guard 5 — `result.getProperties()` null check before building `mapViewModels`

**Risk:** If `SearchService.search()` returns a `SearchResultDto` with a null `properties` list
(can happen on DB error or if FULLTEXT index is missing), `.stream()` NPEs.  
**Apply in:** `SearchController.searchPage()`

**Current code (already guarded — verify):**
```java
List<SearchPropertyViewModel> mapViewModels = new ArrayList<>();
if (result != null && result.getProperties() != null && !result.getProperties().isEmpty()) {
    mapViewModels = result.getProperties().stream()
        .map(p -> {
            double[] c = propertyService.getEffectiveLatLng(p);
            return new SearchPropertyViewModel(p, c[0], c[1]);
        }).collect(Collectors.toList());
}
model.addAttribute("mapViewModels", mapViewModels);
```

If the current code only checks `!result.getProperties().isEmpty()` without the `!= null` guard,
add the `result.getProperties() != null` check as shown.

---

## 2. Broken Route Verification

Test all of the following routes and confirm the expected HTTP response / behavior.

### Routes Table

| # | Route & Conditions | Expected Behavior | How to Verify |
|---|-------------------|-------------------|---------------|
| **S-01** | `GET /agent/my-properties` — not logged in | **302 → `/login`** (redirect by Spring Security) | Open private window, navigate directly; check browser URL changes to `/login` |
| **S-02** | `GET /agent/my-properties` — logged in as USER role | **403 Forbidden** page rendered; user is rejected by `@PreAuthorize("hasRole('AGENT')")` or `SecurityConfig` | Login as `user1@propnexium.com`, then navigate to `/agent/my-properties` |
| **S-03** | `GET /admin/analytics` — logged in as AGENT | **403 Forbidden** | Login as agent, navigate to `/admin/analytics` |
| **S-04** | `GET /admin/analytics` — not logged in | **302 → `/login`** | Incognito, navigate to `/admin/analytics` |
| **S-05** | `GET /compare?ids={singleValidId}` | Redirect with flash error: *"Please select at least 2 properties to compare"* | Navigate to `/compare?ids=1` (single ID) |
| **S-06** | `GET /compare?ids={validId}&ids={nonExistentId}` | Graceful error — either show what's found + error, or redirect with flash | Navigate to `/compare?ids=1&ids=99999` |
| **S-07** | `GET /pdf/property/99999` (non-existent ID) | **HTTP 404** — custom error page or "`Property not found`" message | Navigate to `/pdf/property/99999` |
| **S-08** | `GET /auth/reset-password?token=USED_TOKEN` | **Error page** rendered: *"This link has expired or has already been used"* — no 500 | Use a previously-clicked reset link |
| **S-09** | `GET /unsubscribe?token=INVALID_TOKEN` | **Redirect with flash error**: *"Invalid or expired unsubscribe link"* — no 500 | Manually visit `/unsubscribe?token=abc123xyz` |

### Fix Checklist

```
[ ] SecurityConfig: confirm /agent/** is restricted to ROLE_AGENT
[ ] SecurityConfig: confirm /admin/** is restricted to ROLE_ADMIN
[ ] CompareController: count ids param, redirect if < 2
[ ] PdfController: wrap findById in orElseThrow → ResourceNotFoundException → 404 handler
[ ] AuthController.resetPassword: check token validity before rendering reset form
[ ] SubscriberController.unsubscribe: catch invalid token → RedirectAttributes flash error
```

#### SecurityConfig snippet (verify this pattern exists):
```java
.requestMatchers("/agent/**").hasRole("AGENT")
.requestMatchers("/admin/**").hasRole("ADMIN")
```

#### CompareController guard snippet:
```java
@GetMapping("/compare")
public String comparePage(@RequestParam List<Long> ids, Model model,
                          RedirectAttributes redirectAttributes) {
    // Guard: must have at least 2 IDs to compare
    if (ids == null || ids.size() < 2) {
        redirectAttributes.addFlashAttribute("errorMessage",
            "Please select at least 2 properties to compare.");
        return "redirect:/search";
    }
    // ... rest of logic
}
```

#### PdfController guard snippet:
```java
@GetMapping("/pdf/property/{id}")
public ResponseEntity<byte[]> downloadPropertyPdf(@PathVariable Long id) {
    Property property = propertyRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Property", "id", id));
    // ... generate PDF
}
```

---

## 3. UI / Z-Index / Layout Verification Fixes

### 3A. Comparison Bar vs. Report Modal Z-Index

**Problem:** Comparison bar (bottom bar) with `z-index: 1000` overlaps the Report Property modal.

**Fix in CSS (e.g., `static/css/compare-bar.css` or inline style):**
```css
/* Comparison bar — keep below modals */
#comparison-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 500;   /* was 1000 — reduce below Bootstrap modal (z-index: 1055) */
}

/* Report modal overlay — Bootstrap default is 1050/1055, which is correct */
#reportPropertyModal .modal-dialog {
    z-index: 1060;  /* explicitly above comparison bar */
}
```

> **Bootstrap 5 z-index reference:**  
> Modal backdrop: 1040 · Modal: 1050 · Tooltip: 1070 · Toast: 1090

---

### 3B. Leaflet Map Container Height

**Problem:** If the map container `div` has no explicit height, Leaflet renders a 0px-tall invisible map.

**Fix in JSP or CSS:**
```css
/* In your map CSS file or the JSP <style> block */
#propertyMap,
#searchMap,
#locationPickerMap {
    height: 400px;   /* explicit non-zero height required by Leaflet */
    width: 100%;
    border-radius: 8px;
}
```

**Also verify in JSP:**
```jsp
<div id="propertyMap" style="height: 400px; width: 100%;"></div>
```

Never use `height: auto` or omit height on Leaflet containers.

---

### 3C. Chart.js Canvas Height Attributes

**Problem:** Chart.js canvases without a defined height render at 0px in some layout contexts.

**Fix in Admin Analytics JSP:**
```jsp
<%-- Always specify height on Chart.js canvas elements --%>
<canvas id="propertiesByCityChart"   height="120"></canvas>
<canvas id="propertiesByTypeChart"   height="120"></canvas>
<canvas id="listingsOverTimeChart"   height="120"></canvas>
<canvas id="inquiryTrendChart"       height="120"></canvas>
<canvas id="buyVsRentDistChart"      height="120"></canvas>
<canvas id="agentPerformanceChart"   height="120"></canvas>
<canvas id="priceHistoryChart"       height="120"></canvas>
```

> The parent container should also have a `max-height` or use `responsive: true` with
> `maintainAspectRatio: false` in Chart.js options when placed inside flexbox/grid parents.

---

### 3D. Flash Messages via RedirectAttributes

**Problem:** Flash messages added in a POST/action handler with `model.addAttribute()` are lost on redirect.

**Must use `RedirectAttributes.addFlashAttribute()` — never `model.addAttribute()` before a redirect:**

```java
// ✅ CORRECT — survives redirect
@PostMapping("/save-search")
public String saveSearch(..., RedirectAttributes redirectAttributes) {
    savedSearchService.save(...);
    redirectAttributes.addFlashAttribute("successMessage", "Search saved successfully!");
    return "redirect:/dashboard";
}

// ❌ WRONG — lost on redirect
@PostMapping("/save-search")
public String saveSearch(..., Model model) {
    savedSearchService.save(...);
    model.addAttribute("successMessage", "Search saved successfully!"); // This will NOT appear!
    return "redirect:/dashboard";
}
```

**Read in JSP (all pages that may receive flash):**
```jsp
<c:if test="${not empty successMessage}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>
```

---

### 3E. Toast Above Comparison Bar on Mobile

**Fix in CSS:**
```css
/* Toasts must appear above the comparison bar on small screens */
.toast-container {
    position: fixed;
    bottom: 80px;   /* leave room for 70px comparison bar + gap */
    right: 1rem;
    z-index: 1080;  /* above everything except modals */
}

@media (max-width: 576px) {
    .toast-container {
        bottom: 90px;
        left: 0.5rem;
        right: 0.5rem;
    }
    .toast {
        width: 100%;
    }
}
```

---

## 4. application.properties Review

**File:** `src/main/resources/application.properties`

### ✅ Present Keys (verified → 2026-03-28)

| Key | Value | Status |
|-----|-------|--------|
| `server.port` | `8080` | ✅ |
| `spring.application.name` | `PropNexium` | ✅ |
| `spring.datasource.url` | `jdbc:mysql://localhost:3306/propnexium_db?...` | ✅ |
| `spring.datasource.username` | `root` | ✅ |
| `spring.datasource.password` | `purvik` | ✅ |
| `spring.datasource.driver-class-name` | `com.mysql.cj.jdbc.Driver` | ✅ |
| `spring.datasource.hikari.maximum-pool-size` | `10` | ✅ |
| `spring.datasource.hikari.minimum-idle` | `2` | ✅ |
| `spring.datasource.hikari.connection-timeout` | `30000` | ✅ |
| `spring.jpa.hibernate.ddl-auto` | `update` | ✅ |
| `spring.jpa.show-sql` | `true` *(set false in production)* | ✅ |
| `spring.jpa.properties.hibernate.dialect` | `org.hibernate.dialect.MySQLDialect` | ✅ |
| `spring.jpa.open-in-view` | `true` | ✅ |
| `spring.mvc.view.prefix` | `/WEB-INF/views/` | ✅ |
| `spring.mvc.view.suffix` | `.jsp` | ✅ |
| `spring.servlet.multipart.enabled` | `true` | ✅ |
| `spring.servlet.multipart.max-file-size` | `5MB` | ✅ |
| `spring.servlet.multipart.max-request-size` | `50MB` | ✅ |
| `spring.mail.host` | `smtp.gmail.com` | ✅ |
| `spring.mail.port` | `587` | ✅ |
| `spring.mail.username` | *(Gmail address set)* | ✅ |
| `spring.mail.password` | *(App password set)* | ✅ |
| `spring.mail.properties.mail.smtp.auth` | `true` | ✅ |
| `spring.mail.properties.mail.smtp.starttls.enable` | `true` | ✅ |
| `spring.mail.properties.mail.smtp.connectiontimeout` | `5000` | ✅ |
| `spring.mail.properties.mail.smtp.timeout` | `5000` | ✅ |
| `management.endpoints.web.exposure.include` | `health,info,metrics` | ✅ |
| `management.endpoint.health.show-details` | `when-authorized` | ✅ |
| `propnexium.app.name` | `PropNexium` | ✅ |
| `propnexium.app.version` | `1.0.0` | ✅ |
| `propnexium.upload.directory` | `uploads` | ✅ |
| `propnexium.app.base-url` | `http://localhost:8080` | ✅ |
| `logging.level.com.propnexium` | `DEBUG` | ✅ |
| `logging.level.org.springframework.security` | `INFO` | ✅ |
| `logging.level.org.hibernate.SQL` | `DEBUG` | ✅ |

### ⚠️ Recommended Additions

Add the following keys to `application.properties` if not already present:

```properties
# ── Mail: write-timeout to prevent hanging threads ──────────────────────────
spring.mail.properties.mail.smtp.writetimeout=5000

# ── Async executor thread pool (for @Async email sending) ───────────────────
spring.task.execution.pool.core-size=2
spring.task.execution.pool.max-size=10
spring.task.execution.pool.queue-capacity=100

# ── Jackson: serialize null dates as null instead of throwing ─────────────────
spring.jackson.serialization.write-dates-as-timestamps=false
spring.jackson.default-property-inclusion=non_null

# ── Session timeout: 60 minutes ───────────────────────────────────────────────
server.servlet.session.timeout=60m

# ── Error handling: show full error page in dev ───────────────────────────────
server.error.include-message=always
server.error.include-binding-errors=always
server.error.include-stacktrace=on_param
server.error.include-exception=false

# ── MySQL: handle emojis (utf8mb4) ────────────────────────────────────────────
spring.datasource.url=jdbc:mysql://localhost:3306/propnexium_db\
  ?useSSL=false\
  &serverTimezone=Asia/Kolkata\
  &allowPublicKeyRetrieval=true\
  &characterEncoding=UTF-8\
  &useUnicode=true
```

### 🔴 Production Concerns (for when you go live)

```properties
# DO NOT use in production — change to:
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false
logging.level.org.hibernate.SQL=WARN
logging.level.com.propnexium=INFO

# Use environment variables for sensitive values:
spring.datasource.password=${DB_PASSWORD}
spring.mail.password=${MAIL_APP_PASSWORD}
```

---

## 5. DataLoader Quick Reference

After the database is seeded, the following credentials are available immediately:

| Role | Email | Password | Notes |
|------|-------|----------|-------|
| Admin | `admin@propnexium.com` | `Admin@123` | `isEmailVerified=true` |
| Agent 1 | `agent1@propnexium.com` | `Agent@123` | Rajesh Sharma · Sharma Realty · Mumbai |
| Agent 2 | `agent2@propnexium.com` | `Agent@123` | Priya Patel · Patel Properties · Delhi |
| Agent 3 | `agent3@propnexium.com` | `Agent@123` | Arjun Mehta · Mehta Estates · Bangalore |
| User 1 | `user1@propnexium.com` | `User@123` | `isEmailVerified=true` |
| User 2 | `user2@propnexium.com` | `User@123` | `isEmailVerified=true` |

**Properties seeded:** 15 across Mumbai (3), Delhi (2), Bangalore (3), Ahmedabad (3), Pune (2), Chennai (1), Hyderabad (1)  
**Property types covered:** APARTMENT, HOUSE, VILLA, COMMERCIAL, STUDIO, PENTHOUSE, PLOT  
**createdAt:** Randomly staggered 42–88 days in the past for realistic monthly analytics charts.

**To re-seed:** Drop all tables (or truncate `properties` table) and restart the Spring Boot application. The guard `if (propertyRepository.count() > 0) return;` prevents duplicate seeding.

---

*Generated: 2026-03-28 · PropNexium v1.0.0*
