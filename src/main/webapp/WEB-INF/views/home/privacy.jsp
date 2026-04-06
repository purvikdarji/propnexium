<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - PropNexium</title>
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
        <h1>Privacy Policy</h1>
        <p>Your privacy matters to us. Learn how we handle your data.</p>
    </div>

    <div class="content-container">
        <div class="last-updated">Last Updated: April 3, 2026</div>

        <p>Welcome to PropNexium. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us at support@propnexium.com.</p>

        <h2>1. Information We Collect</h2>
        <p>When you visit our website and use our services, we may collect several types of information from and about users of our website, including:</p>
        <ul>
            <li><strong>Personal Information:</strong> Name, email address, phone number, and mailing address when you register for an account or contact us.</li>
            <li><strong>Property Data:</strong> Information about properties you search for, save, or inquiries you make.</li>
            <li><strong>Usage Data:</strong> Details of your visits to our website, including traffic data, location data, logs, and other communication data and the resources that you access.</li>
        </ul>

        <h2>2. How We Use Your Information</h2>
        <p>We use information that we collect about you or that you provide to us, including any personal information:</p>
        <ul>
            <li>To present our website and its contents to you.</li>
            <li>To provide you with information, products, or services that you request from us.</li>
            <li>To fulfill any other purpose for which you provide it.</li>
            <li>To provide you with notices about your account.</li>
            <li>To carry out our obligations and enforce our rights arising from any contracts entered into between you and us.</li>
        </ul>

        <h2>3. Disclosure of Your Information</h2>
        <p>We may disclose personal information that we collect or you provide as described in this privacy policy:</p>
        <ul>
            <li>To our subsidiaries and affiliates.</li>
            <li>To contractors, service providers, and other third parties we use to support our business (such as agents you choose to contact).</li>
            <li>To a buyer or other successor in the event of a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of PropNexium's assets.</li>
            <li>To fulfill the purpose for which you provide it.</li>
        </ul>

        <h2>4. Data Security</h2>
        <p>We have implemented measures designed to secure your personal information from accidental loss and from unauthorized access, use, alteration, and disclosure. All information you provide to us is stored on our secure servers behind firewalls.</p>
        <p>The safety and security of your information also depends on you. Where we have given you (or where you have chosen) a password for access to certain parts of our website, you are responsible for keeping this password confidential.</p>

        <h2>5. Your Rights</h2>
        <p>You have the right to:</p>
        <ul>
            <li>Access the personal information we hold about you.</li>
            <li>Request that we correct any inaccurate or incomplete personal information.</li>
            <li>Request that we delete your personal information, subject to certain exceptions.</li>
            <li>Object to the processing of your personal information for certain purposes.</li>
        </ul>

        <h2>6. Contact Information</h2>
        <p>To ask questions or comment about this privacy policy and our privacy practices, contact us at:</p>
        <p><strong>PropNexium Support</strong><br>
        Email: support@propnexium.com<br>
        Phone: +91-9876543210</p>
    </div>

    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
