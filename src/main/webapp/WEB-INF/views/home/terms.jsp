<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terms of Service - PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { margin: 0; font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #334155; line-height: 1.6; }
        .hero { background: #1e293b; padding: 80px 20px; text-align: center; color: white; }
        .hero h1 { margin: 0; font-size: 42px; font-weight: 800; }
        .hero p { color: #94a3b8; font-size: 18px; margin: 10px 0 0; }
        .content-container { max-width: 900px; margin: -40px auto 60px; background: white; padding: 60px; border-radius: 16px; box-shadow: 0 20px 40px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; position: relative; z-index: 10; }
        h2 { color: #0f172a; font-size: 24px; font-weight: 700; margin-top: 40px; }
        h3 { color: #1e293b; font-size: 18px; font-weight: 600; margin-top: 24px; }
        p { margin-bottom: 16px; }
        ul { margin-bottom: 16px; padding-left: 20px; }
        li { margin-bottom: 8px; }
        .last-updated { color: #64748b; font-size: 14px; margin-bottom: 40px; border-bottom: 1px solid #e2e8f0; padding-bottom: 20px; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

    <div class="hero">
        <h1>Terms of Service</h1>
        <p>Your guide to using PropNexium.</p>
    </div>

    <div class="content-container">
        <div class="last-updated">Last Updated: April 3, 2026</div>

        <h2>1. Acceptance of Terms</h2>
        <p>By accessing and using PropNexium, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, please do not use our website or services.</p>

        <h2>2. Description of Service</h2>
        <p>PropNexium provides an online platform for connecting property buyers, sellers, renters, and real estate professionals. We do not personally sell, rent, or lease real estate properties.</p>

        <h2>3. User Responsibilities</h2>
        <p>As a user of PropNexium, you agree to:</p>
        <ul>
            <li>Provide accurate and complete information when registering for an account.</li>
            <li>Maintain the confidentiality of your account credentials.</li>
            <li>Use the platform only for lawful purposes.</li>
            <li>Ensure that any property listings or content you post are accurate and comply with all applicable laws.</li>
        </ul>

        <h2>4. Property Listings and Content</h2>
        <p>Users who list properties are solely responsible for the accuracy of their listings. PropNexium does not guarantee the accuracy, completeness, or quality of any content posted by users. We reserve the right to remove any content that violates our policies or is otherwise objectionable.</p>

        <h2>5. Prohibited Activities</h2>
        <p>You may not:</p>
        <ul>
            <li>Use our services for any fraudulent or illegal activity.</li>
            <li>Post or transmit any content that is defamatory, offensive, or infringing on intellectual property rights.</li>
            <li>Attempt to interfere with the proper functioning of the website.</li>
            <li>Use any automated means (such as bots or scrapers) to access or collect data from our website without our express permission.</li>
        </ul>

        <h2>6. Limitation of Liability</h2>
        <p>PropNexium is provided on an "as is" and "as available" basis. We do not warrant that our services will be uninterrupted or error-free. To the fullest extent permitted by law, PropNexium shall not be liable for any indirect, incidental, or consequential damages arising out of your use of our services.</p>

        <h2>7. Modifications to Terms</h2>
        <p>We reserve the right to modify these Terms of Service at any time. Any changes will be effective immediately upon posting on our website. Your continued use of the platform after any such changes constitutes your acceptance of the new terms.</p>

        <h2>8. Governing Law</h2>
        <p>These terms shall be governed by and construed in accordance with the laws of Maharashtra, India, without regard to its conflict of law principles.</p>

        <h2>9. Contact Information</h2>
        <p>For any questions regarding these terms, please contact us at:</p>
        <p><strong>PropNexium Support</strong><br>
        Email: support@propnexium.com<br>
        Phone: +91-9876543210</p>
    </div>

    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
