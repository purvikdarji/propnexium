<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="_csrf" content="${_csrf.token}" />
            <meta name="_csrf_header" content="${_csrf.headerName}" />
            <title>Contact Us - PropNexium</title>
        </head>

        <body style="margin: 0; font-family: 'Inter', system-ui, -apple-system, sans-serif; background-color: #f8fafc;">

            <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                <div style="background:#1e293b;padding:60px 20px;text-align:center;">
                    <h1 style="color:white;margin:0 0 10px;font-size:36px;font-weight:800;">Contact Us</h1>
                    <p style="color:#94a3b8;font-size:16px;margin:0;">We're here to help and answer any question you
                        might have.</p>
                </div>

                <div
                    style="max-width:1000px;margin: -30px auto 60px;padding:0 20px;display:flex;gap:30px;position:relative;z-index:10;align-items:flex-start;">

                    <!-- Left: Contact Form -->
                    <div
                        style="flex:1;background:white;border-radius:12px;padding:40px;box-shadow:0 10px 30px rgba(0,0,0,0.05);border:1px solid #f1f5f9;">
                        <h2 style="margin:0 0 24px;font-size:24px;color:#1e293b;">Get In Touch</h2>

                        <c:if test="${not empty successMessage}">
                            <div
                                style="background:#f0fdf4;border-left:4px solid #22c55e;color:#16a34a;padding:16px;margin-bottom:24px;border-radius:0 8px 8px 0;font-size:14px;font-weight:500;">
                                ${successMessage}
                            </div>
                        </c:if>

                        <form action="/contact" method="POST" style="display:flex;flex-direction:column;gap:20px;">
                            <!-- Disable CSRF temporarily if not configured globally, or include standard csrf tag if available: -->
                            <!-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> -->

                            <div>
                                <label
                                    style="display:block;margin-bottom:8px;font-size:14px;font-weight:600;color:#475569;">Your
                                    Name *</label>
                                <input type="text" name="name" required
                                    style="width:100%;padding:14px;border:1px solid #e2e8f0;border-radius:8px;font-size:15px;box-sizing:border-box;outline:none;transition:border-color 0.2s;"
                                    onfocus="this.style.borderColor='#1a73e8'"
                                    onblur="this.style.borderColor='#e2e8f0'">
                            </div>

                            <div>
                                <label
                                    style="display:block;margin-bottom:8px;font-size:14px;font-weight:600;color:#475569;">Email
                                    Address *</label>
                                <input type="email" name="email" required
                                    style="width:100%;padding:14px;border:1px solid #e2e8f0;border-radius:8px;font-size:15px;box-sizing:border-box;outline:none;transition:border-color 0.2s;"
                                    onfocus="this.style.borderColor='#1a73e8'"
                                    onblur="this.style.borderColor='#e2e8f0'">
                            </div>

                            <div>
                                <label
                                    style="display:block;margin-bottom:8px;font-size:14px;font-weight:600;color:#475569;">Subject
                                    *</label>
                                <input type="text" name="subject" required
                                    style="width:100%;padding:14px;border:1px solid #e2e8f0;border-radius:8px;font-size:15px;box-sizing:border-box;outline:none;transition:border-color 0.2s;"
                                    onfocus="this.style.borderColor='#1a73e8'"
                                    onblur="this.style.borderColor='#e2e8f0'">
                            </div>

                            <div>
                                <label
                                    style="display:block;margin-bottom:8px;font-size:14px;font-weight:600;color:#475569;">Message
                                    *</label>
                                <textarea name="message" rows="5" required
                                    style="width:100%;padding:14px;border:1px solid #e2e8f0;border-radius:8px;font-size:15px;box-sizing:border-box;outline:none;transition:border-color 0.2s;resize:vertical;"
                                    onfocus="this.style.borderColor='#1a73e8'"
                                    onblur="this.style.borderColor='#e2e8f0'"></textarea>
                            </div>

                            <button type="submit"
                                style="padding:16px;background:#1a73e8;color:white;border:none;border-radius:8px;font-size:16px;font-weight:700;cursor:pointer;transition:background 0.2s;margin-top:10px;"
                                onmouseover="this.style.background='#1557b0'"
                                onmouseout="this.style.background='#1a73e8'">
                                Send Message
                            </button>
                        </form>
                    </div>

                    <!-- Right: Info -->
                    <div style="width:350px;">
                        <div
                            style="background:white;border-radius:12px;padding:30px;box-shadow:0 10px 30px rgba(0,0,0,0.05);border:1px solid #f1f5f9;margin-bottom:30px;">
                            <h3 style="margin:0 0 20px;font-size:18px;color:#1e293b;">Contact Information</h3>

                            <div style="display:flex;gap:15px;margin-bottom:20px;align-items:flex-start;">
                                <div style="font-size:20px;margin-top:2px;">📍</div>
                                <div>
                                    <div
                                        style="font-size:13px;font-weight:700;color:#64748b;text-transform:uppercase;margin-bottom:4px;">
                                        Address</div>
                                    <div style="font-size:15px;color:#1e293b;line-height:1.5;">PropNexium
                                        Headquarters<br>123 Business Park, Phase 2<br>Mumbai, Maharashtra 400001</div>
                                </div>
                            </div>

                            <div style="display:flex;gap:15px;margin-bottom:20px;align-items:flex-start;">
                                <div style="font-size:20px;margin-top:2px;">📞</div>
                                <div>
                                    <div
                                        style="font-size:13px;font-weight:700;color:#64748b;text-transform:uppercase;margin-bottom:4px;">
                                        Phone</div>
                                    <div style="font-size:15px;color:#1e293b;">+91-9876543210</div>
                                </div>
                            </div>

                            <div style="display:flex;gap:15px;margin-bottom:20px;align-items:flex-start;">
                                <div style="font-size:20px;margin-top:2px;">✉️</div>
                                <div>
                                    <div
                                        style="font-size:13px;font-weight:700;color:#64748b;text-transform:uppercase;margin-bottom:4px;">
                                        Email Address</div>
                                    <div style="font-size:15px;color:#1e293b;">support@propnexium.com</div>
                                </div>
                            </div>

                            <div style="display:flex;gap:15px;align-items:flex-start;">
                                <div style="font-size:20px;margin-top:2px;">🕒</div>
                                <div>
                                    <div
                                        style="font-size:13px;font-weight:700;color:#64748b;text-transform:uppercase;margin-bottom:4px;">
                                        Office Hours</div>
                                    <div style="font-size:15px;color:#1e293b;line-height:1.5;">Monday - Friday: 9am -
                                        6pm<br>Weekend: Closed</div>
                                </div>
                            </div>
                        </div>

                        <div
                            style="background:white;border-radius:12px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.05);border:1px solid #f1f5f9;height:250px;">
                            <iframe
                                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d120668.61868499778!2d72.76679237618995!3d19.07119102462214!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3be7c6306644edc1%3A0x5da4ed8f8d648c69!2sMumbai%2C%20Maharashtra!5e0!3m2!1sen!2sin!4v1709404289895!5m2!1sen!2sin"
                                width="100%" height="100%" style="border:0;" allowfullscreen="" loading="lazy"
                                referrerpolicy="no-referrer-when-downgrade"></iframe>
                        </div>
                    </div>
                </div>

                <!-- FOOTER -->
                <footer style="background:#1e293b;color:white;padding:40px 20px;">
                    <div style="max-width:1200px;margin:0 auto;display:flex;justify-content:center;">
                        <div style="text-align:center;color:#64748b;font-size:13px;">
                            © 2025 PropNexium. All rights reserved.
                        </div>
                    </div>
                </footer>
        </body>

        </html>