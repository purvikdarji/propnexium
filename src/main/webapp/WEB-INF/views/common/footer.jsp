<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!-- ── Newsletter Subscription Bar ──────────────────────────────────── -->
    <c:if test="${!isGlobalSubscribed && !hideFooterSubscribe}">
    <div style="background:#0f172a;padding:32px 40px;border-top:1px solid #1e293b;">
        <div style="max-width:520px;margin:0 auto;text-align:center;">
            <h4 style="color:white;margin:0 0 6px;font-size:15px;font-weight:700;">
                📧 Subscribe to PropNexium Updates
            </h4>
            <p style="color:#94a3b8;font-size:13px;margin:0 0 16px;">
                Get new property alerts and market news directly in your inbox.
            </p>
            <div style="display:flex;gap:8px;">
                <input type="email" id="footerEmail"
                       placeholder="Enter your email address"
                       style="flex:1;padding:11px 14px;border:none;border-radius:6px;
                              font-size:14px;outline:none;color:#1e293b;"/>
                <button onclick="subscribeNewsletter()"
                        id="subscribeBtn"
                        style="padding:11px 22px;background:#1a73e8;color:white;
                               border:none;border-radius:6px;font-size:14px;
                               font-weight:600;cursor:pointer;white-space:nowrap;
                               transition:background .2s;">
                    Subscribe
                </button>
            </div>
            <div id="subscribeMessage"
                 style="margin-top:10px;font-size:13px;display:none;"></div>
        </div>
    </div>
    </c:if>

    <!-- ── Site footer ────────────────────────────────────────────────────── -->
    <footer style="background:#0f172a; border-top:1px solid #1e293b; padding:60px 40px 30px;">
        <style>
            .f-col h4 { color: white; font-size: 16px; font-weight: 700; margin: 0 0 24px; position: relative; }
            .f-col h4::after { content: ''; position: absolute; bottom: -8px; left: 0; width: 30px; height: 2px; background: #1a73e8; }
            .f-links { list-style: none; padding: 0; margin: 0; }
            .f-links li { margin-bottom: 12px; }
            .f-links a { color: #94a3b8; text-decoration: none; font-size: 14px; transition: all 0.2s; display: inline-block; }
            .f-links a:hover { color: white; transform: translateX(5px); }
            .social-icon { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; 
                           background: #1e293b; color: #94a3b8; border-radius: 50%; margin-right: 12px; transition: all 0.2s; 
                           text-decoration: none; font-size: 18px; }
            .social-icon:hover { background: #1a73e8; color: white; transform: translateY(-3px); }
        </style>

        <div style="max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 40px; text-align: left;">
            <!-- Column 1: Brand -->
            <div class="f-col">
                <div style="font-size: 22px; font-weight: 800; color: white; margin-bottom: 16px;">
                    🏠 Prop<span style="color: #1a73e8;">Nexium</span>
                </div>
                <p style="color: #94a3b8; font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
                    India's most trusted real estate platform for buying, selling, and renting properties with verify listings and expert agents.
                </p>
                <div style="display: flex;">
                    <a href="#" class="social-icon">f</a>
                    <a href="#" class="social-icon">𝕏</a>
                    <a href="#" class="social-icon">📸</a>
                    <a href="#" class="social-icon">in</a>
                </div>
            </div>

            <!-- Column 2: Quick Links -->
            <div class="f-col">
                <h4>Quick Links</h4>
                <ul class="f-links">
                    <li><a href="/properties">Browse Properties</a></li>
                    <li><a href="/search">Advanced Search</a></li>
                    <li><a href="/blog">Real Estate Blog</a></li>
                    <li><a href="/news">Market News</a></li>
                    <li><a href="/contact">Contact Support</a></li>
                </ul>
            </div>

            <!-- Column 3: Explore by City -->
            <div class="f-col">
                <h4>Explore Cities</h4>
                <ul class="f-links">
                    <li><a href="/search?city=Mumbai">Mumbai</a></li>
                    <li><a href="/search?city=Delhi">Delhi</a></li>
                    <li><a href="/search?city=Bangalore">Bangalore</a></li>
                    <li><a href="/search?city=Ahmedabad">Ahmedabad</a></li>
                    <li><a href="/search?city=Pune">Pune</a></li>
                </ul>
            </div>

            <!-- Column 4: Tools & Resources -->
            <div class="f-col">
                <h4>Tools & Resources</h4>
                <ul class="f-links">
                    <li><a href="/calculator">Mortgage Calculator</a></li>
                    <li><a href="/tools/area-converter">Area Unit Converter</a></li>
                    <li><a href="/user/wishlist">Saved Properties</a></li>
                    <li><a href="/auth/register">List Your Property</a></li>
                </ul>
            </div>
        </div>

        <div style="max-width: 1200px; margin: 40px auto 0; padding-top: 30px; border-top: 1px solid #1e293b; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
            <p style="color: #64748b; font-size: 13px; margin: 0;">
                &copy; 2025 PropNexium. India's Trusted Real Estate Platform.
            </p>
            <div style="display: flex; gap: 20px;">
                <a href="/privacy" style="color: #64748b; text-decoration: none; font-size: 13px;">Privacy Policy</a>
                <a href="/terms" style="color: #64748b; text-decoration: none; font-size: 13px;">Terms of Service</a>
                <a href="/sitemap" style="color: #64748b; text-decoration: none; font-size: 13px;">Sitemap</a>
            </div>
        </div>
    </footer>

    <!-- ── Toast Notification Container ── -->
    <div id="prop-toast" style="position:fixed; bottom:30px; left:50%; transform:translateX(-50%); 
                                background:#1e293b; color:white; padding:12px 24px; border-radius:10px; 
                                font-size:14px; font-weight:600; z-index:9999; display:none; 
                                box-shadow:0 10px 25px rgba(0,0,0,0.2); animation: fadeInUp 0.3s ease;">
    </div>

    <style>
        @keyframes fadeInUp { from { opacity: 0; transform: translate(-50%, 20px); } to { opacity: 1; transform: translate(-50%, 0); } }
    </style>

<script>
// ─── Global Toast Utility ───
function showToast(message, type) {
    const t = document.getElementById('prop-toast');
    if (!t) return;
    t.textContent = message;
    t.style.background = type === 'success' ? '#10b981' : '#ef4444';
    t.style.display = 'block';
    
    if (t._timer) clearTimeout(t._timer);
    t._timer = setTimeout(() => {
        t.style.opacity = '0';
        t.style.transition = 'opacity 0.4s ease';
        setTimeout(() => {
            t.style.display = 'none';
            t.style.opacity = '1';
        }, 400);
    }, 3000);
}

// ─── Global Wishlist Toggle ───
function toggleWishlist(propertyId, btn) {
    // Get CSRF token from meta tags
    const csrfToken = document.querySelector("meta[name='_csrf']")?.getAttribute("content");
    const csrfHeader = document.querySelector("meta[name='_csrf_header']")?.getAttribute("content");
    
    const isWishlisted = btn.textContent.includes('❤');
    const method = isWishlisted ? 'DELETE' : 'POST';

    fetch('/api/v1/wishlist/' + propertyId, {
        method: method,
        headers: { [csrfHeader]: csrfToken }
    })
    .then(res => {
        if (res.status === 401 || res.status === 403) {
            showToast('Please login to save properties', 'error');
            return null;
        }
        return res.json();
    })
    .then(data => {
        if (!data) return;
        if (isWishlisted) {
            if (btn.id === 'wishlistBtn') {
                btn.innerHTML = '🤍 Save Property';
                btn.style.background = '#fff';
                btn.style.borderColor = '#ddd';
                btn.style.color = '#666';
            } else {
                btn.textContent = '🤍';
            }
            showToast('Removed from wishlist', 'success');
        } else {
            if (btn.id === 'wishlistBtn') {
                btn.innerHTML = '❤️ Saved';
                btn.style.background = '#e8f5e9';
                btn.style.borderColor = '#28a745';
                btn.style.color = '#28a745';
            } else {
                btn.textContent = '❤️';
            }
            showToast('Added to wishlist!', 'success');
        }
    })
    .catch(() => showToast('Please login to save properties', 'error'));
}

function subscribeNewsletter() {
    var email   = document.getElementById('footerEmail').value.trim();
    var msgDiv  = document.getElementById('subscribeMessage');
    var btn     = document.getElementById('subscribeBtn');

    if (!email || !email.includes('@')) {
        msgDiv.textContent  = 'Please enter a valid email address.';
        msgDiv.style.color  = '#ef4444';
        msgDiv.style.display = 'block';
        return;
    }

    btn.disabled    = true;
    btn.textContent = 'Subscribing…';

    // Get CSRF token from meta tag if available
    var csrfMeta  = document.querySelector('meta[name="_csrf"]');
    var csrfHeader = document.querySelector('meta[name="_csrf_header"]');
    var headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
    if (csrfMeta && csrfHeader) {
        headers[csrfHeader.getAttribute('content')] = csrfMeta.getAttribute('content');
    }

    fetch('/subscribe', {
        method: 'POST',
        headers: headers,
        body: 'email=' + encodeURIComponent(email)
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        msgDiv.textContent   = data.message || 'Thank you!';
        msgDiv.style.color   = '#22c55e';
        msgDiv.style.display = 'block';
        document.getElementById('footerEmail').value = '';
    })
    .catch(function() {
        msgDiv.textContent   = 'Something went wrong. Please try again.';
        msgDiv.style.color   = '#ef4444';
        msgDiv.style.display = 'block';
    })
    .finally(function() {
        btn.disabled    = false;
        btn.textContent = 'Subscribe';
    });
}
// Hover style for subscribe button
var sb = document.getElementById('subscribeBtn');
if (sb) {
    sb.addEventListener('mouseover', function() { this.style.background='#1557b0'; });
    sb.addEventListener('mouseout',  function() { this.style.background='#1a73e8'; });
}
</script>