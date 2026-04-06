<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>PropNexium – India's Trusted Real Estate Platform</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    body {
                        font-family: 'Segoe UI', Arial, sans-serif;
                        background: #f8f9fc;
                        color: #333;
                    }

                    .navbar {
                        background: #fff;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
                        padding: 0 40px;
                        height: 64px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                    }

                    .brand {
                        font-size: 24px;
                        font-weight: 800;
                        color: #1a73e8;
                        text-decoration: none;
                    }

                    .brand span {
                        color: #0d47a1;
                    }

                    .nav-links {
                        display: flex;
                        gap: 20px;
                        align-items: center;
                    }

                    .nav-links a {
                        text-decoration: none;
                        font-size: 14px;
                        color: #555;
                        font-weight: 500;
                        padding: 8px 16px;
                        border-radius: 6px;
                        transition: background 0.2s;
                    }

                    .nav-links a:hover {
                        background: #f0f4ff;
                        color: #1a73e8;
                    }

                    .btn-primary {
                        background: linear-gradient(135deg, #1a73e8, #1557b0);
                        color: #fff !important;
                        border-radius: 8px;
                    }

                    .hero {
                        background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
                        color: #fff;
                        text-align: center;
                        padding: 80px 24px;
                    }

                    .hero h1 {
                        font-size: 44px;
                        font-weight: 800;
                        margin-bottom: 16px;
                    }

                    .hero p {
                        font-size: 18px;
                        opacity: 0.9;
                        margin-bottom: 36px;
                    }

                    .hero-btns {
                        display: flex;
                        gap: 16px;
                        justify-content: center;
                        flex-wrap: wrap;
                    }

                    .btn-white {
                        padding: 14px 32px;
                        background: #fff;
                        color: #1a73e8;
                        border-radius: 8px;
                        text-decoration: none;
                        font-weight: 700;
                        font-size: 15px;
                    }

                    .btn-outline-white {
                        padding: 14px 32px;
                        background: transparent;
                        color: #fff;
                        border: 2px solid rgba(255, 255, 255, 0.7);
                        border-radius: 8px;
                        text-decoration: none;
                        font-weight: 600;
                        font-size: 15px;
                    }

                    .stats {
                        display: flex;
                        justify-content: center;
                        gap: 40px;
                        padding: 48px;
                        background: #fff;
                        flex-wrap: wrap;
                    }

                    .stat-item {
                        text-align: center;
                    }

                    .stat-num {
                        font-size: 36px;
                        font-weight: 800;
                        color: #1a73e8;
                    }

                    .stat-lbl {
                        font-size: 14px;
                        color: #888;
                        margin-top: 4px;
                    }

                    .section {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 60px 24px;
                    }

                    .section-title {
                        font-size: 28px;
                        font-weight: 700;
                        text-align: center;
                        margin-bottom: 36px;
                    }

                    .cards {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                        gap: 24px;
                    }

                    .card {
                        background: #fff;
                        border-radius: 14px;
                        padding: 28px;
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.07);
                    }

                    .card-icon {
                        font-size: 36px;
                        margin-bottom: 14px;
                        display: block;
                    }

                    .card h3 {
                        font-size: 16px;
                        font-weight: 700;
                        margin-bottom: 8px;
                    }

                    .card p {
                        font-size: 13px;
                        color: #888;
                        line-height: 1.6;
                    }

                    footer {
                        background: #1a1a2e;
                        color: rgba(255, 255, 255, 0.6);
                        text-align: center;
                        padding: 24px;
                        font-size: 13px;
                    }
                </style>
            </head>

            <body>

                <nav class="navbar">
                    <a class="brand" href="/">🏠 Prop<span>Nexium</span></a>
                    <div class="nav-links">
                        <a href="/properties">Properties</a>
                        <a href="/blog">Blog</a>
                        <sec:authorize access="isAuthenticated()">
                            <a href="/dashboard">Dashboard</a>
                            <a href="/auth/logout">Logout</a>
                        </sec:authorize>
                        <sec:authorize access="isAnonymous()">
                            <a href="/auth/login">Sign In</a>
                            <a href="/auth/register" class="btn-primary">Register Free</a>
                        </sec:authorize>
                    </div>
                </nav>

                <div class="hero">
                    <h1>Find Your Dream Property 🏡</h1>
                    <p>India's most trusted platform for buying, selling, and renting properties</p>
                    <div class="hero-btns">
                        <a href="/properties" class="btn-white">Browse Properties</a>
                        <a href="/auth/register" class="btn-outline-white">Join for Free</a>
                    </div>
                </div>

                <div class="stats">
                    <div class="stat-item">
                        <div class="stat-num">10K+</div>
                        <div class="stat-lbl">Properties Listed</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-num">500+</div>
                        <div class="stat-lbl">Verified Agents</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-num">50K+</div>
                        <div class="stat-lbl">Happy Users</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-num">20+</div>
                        <div class="stat-lbl">Cities Covered</div>
                    </div>
                </div>

                <div class="section">
                    <div class="section-title">Why PropNexium?</div>
                    <div class="cards">
                        <div class="card"><span class="card-icon">🔍</span>
                            <h3>Smart Search</h3>
                            <p>Advanced filters to find exactly what you're looking for by location, price, size, and
                                more.</p>
                        </div>
                        <div class="card"><span class="card-icon">✅</span>
                            <h3>Verified Listings</h3>
                            <p>Every property is verified by our team and agents to ensure accurate information.</p>
                        </div>
                        <div class="card"><span class="card-icon">🤝</span>
                            <h3>Connect Directly</h3>
                            <p>Reach out to property owners and licensed agents without any middlemen.</p>
                        </div>
                        <div class="card"><span class="card-icon">🔖</span>
                            <h3>Save & Compare</h3>
                            <p>Bookmark your favorite properties and compare them side by side anytime.</p>
                        </div>
                    </div>
                </div>

                <footer>&copy; 2024 PropNexium. All rights reserved. India's Trusted Real Estate Platform.</footer>
            </body>

            </html>