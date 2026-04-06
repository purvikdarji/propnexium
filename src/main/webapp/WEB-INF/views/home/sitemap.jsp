<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sitemap - PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { margin: 0; font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #334155; line-height: 1.6; }
        .hero { background: #1e293b; padding: 60px 20px; text-align: center; color: white; }
        .hero h1 { margin: 0; font-size: 36px; font-weight: 800; }
        .hero p { color: #94a3b8; font-size: 16px; margin: 10px 0 0; }
        .sitemap-container { max-width: 1100px; margin: 40px auto 80px; padding: 0 20px; display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 30px; }
        .sitemap-section { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.03); border: 1px solid #f1f5f9; }
        .sitemap-section h2 { color: #0f172a; font-size: 18px; font-weight: 700; margin: 0 0 20px; display: flex; align-items: center; gap: 10px; }
        .sitemap-links { list-style: none; padding: 0; margin: 0; }
        .sitemap-links li { margin-bottom: 12px; }
        .sitemap-links a { color: #64748b; text-decoration: none; font-size: 15px; transition: color 0.2s; display: block; }
        .sitemap-links a:hover { color: #1a73e8; }
        .icon { font-size: 20px; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

    <div class="hero">
        <h1>Sitemap</h1>
        <p>Easily navigate through all the sections of PropNexium.</p>
    </div>

    <div class="sitemap-container">
        <!-- Section 1: Properties -->
        <div class="sitemap-section">
            <h2><span class="icon">🏠</span> Properties</h2>
            <ul class="sitemap-links">
                <li><a href="/properties">Browse All Properties</a></li>
                <li><a href="/search">Advanced Search</a></li>
                <li><a href="/properties?type=RESIDENTIAL">Residential Properties</a></li>
                <li><a href="/properties?type=COMMERCIAL">Commercial Properties</a></li>
                <li><a href="/properties?type=LAND">Land & Plots</a></li>
            </ul>
        </div>

        <!-- Section 2: Explore Cities -->
        <div class="sitemap-section">
            <h2><span class="icon">📍</span> Explore Cities</h2>
            <ul class="sitemap-links">
                <li><a href="/search?city=Mumbai">Mumbai Real Estate</a></li>
                <li><a href="/search?city=Delhi">Delhi Real Estate</a></li>
                <li><a href="/search?city=Bangalore">Bangalore Real Estate</a></li>
                <li><a href="/search?city=Pune">Pune Real Estate</a></li>
                <li><a href="/search?city=Ahmedabad">Ahmedabad Real Estate</a></li>
            </ul>
        </div>

        <!-- Section 3: Tools & Resources -->
        <div class="sitemap-section">
            <h2><span class="icon">🛠️</span> Tools & Resources</h2>
            <ul class="sitemap-links">
                <li><a href="/calculator">Mortgage Calculator</a></li>
                <li><a href="/tools/area-converter">Area Unit Converter</a></li>
                <li><a href="/blog">Real Estate Blog</a></li>
                <li><a href="/news">Market News</a></li>
            </ul>
        </div>

        <!-- Section 4: User Account -->
        <div class="sitemap-section">
            <h2><span class="icon">👤</span> My Account</h2>
            <ul class="sitemap-links">
                <li><a href="/auth/login">Login to Account</a></li>
                <li><a href="/auth/register">Create an Account</a></li>
                <li><a href="/user/dashboard">User Dashboard</a></li>
                <li><a href="/user/wishlist">Saved Properties</a></li>
            </ul>
        </div>

        <!-- Section 5: Company -->
        <div class="sitemap-section">
            <h2><span class="icon">📄</span> Company</h2>
            <ul class="sitemap-links">
                <li><a href="/contact">Contact Us</a></li>
                <li><a href="/privacy">Privacy Policy</a></li>
                <li><a href="/terms">Terms of Service</a></li>
                <li><a href="/blog">Our Story (Blog)</a></li>
            </ul>
        </div>

        <!-- Section 6: For Agents -->
        <div class="sitemap-section">
            <h2><span class="icon">💼</span> For Professionals</h2>
            <ul class="sitemap-links">
                <li><a href="/auth/register?role=AGENT">Join as an Agent</a></li>
                <li><a href="/agent/dashboard">Agent Dashboard</a></li>
                <li><a href="/agent/properties">Manage Listings</a></li>
            </ul>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
