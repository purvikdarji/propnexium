<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<aside style="width:230px;background:#0f172a;min-height:100vh;flex-shrink:0;display:flex;flex-direction:column;position:relative;">
  <div style="text-align:center;padding:22px 12px 18px;border-bottom:1px solid #1e293b;">
    <div style="width:58px;height:58px;border-radius:50%;
      background:linear-gradient(135deg,#1a73e8,#6366f1);margin:0 auto;
      display:flex;align-items:center;justify-content:center;
      font-size:22px;font-weight:800;color:white;">
      <c:choose>
        <c:when test="${not empty agent.name}">${fn:substring(agent.name,0,1)}</c:when>
        <c:otherwise>A</c:otherwise>
      </c:choose>
    </div>
    <div style="color:white;font-weight:700;font-size:14px;margin-top:10px;font-family:'Inter',sans-serif;">${agent.name}</div>
    <div style="color:#64748b;font-size:11px;margin-top:3px;font-family:'Inter',sans-serif;">PropNexium Agent</div>
  </div>
  <div style="padding:14px 20px 5px;color:#475569;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:1.2px;font-family:'Inter',sans-serif;">Agent Panel</div>
  <nav style="display:flex;flex-direction:column;">
    <a href="/agent/dashboard" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#128202; Dashboard</a>
    <a href="/agent/properties" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#127968; My Properties</a>
    <a href="/agent/properties/add" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#10133; Add Property</a>
    <a href="/agent/inquiries" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#128172; Inquiries</a>
    <a href="/agent/bookings" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#128197; Manage Visits</a>
    <a href="/user/notifications" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#128276; Notifications</a>
    <a href="/agent/profile" style="display:flex;align-items:center;gap:10px;padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;text-decoration:none;transition:background .15s;font-family:'Inter',sans-serif;">&#128100; Agent Profile</a>
  </nav>
  <div style="margin-top:auto;border-top:1px solid #1e293b;padding:14px 20px;">
    <a href="/" style="color:#475569;font-size:13px;text-decoration:none;font-family:'Inter',sans-serif;">&#8592; View Site</a>
  </div>
  <style>
    aside nav a:hover { background: #1e293b !important; color: #f1f5f9 !important; }
    aside nav a.active { background: #1e3a5f !important; color: #60a5fa !important; border-left: 3px solid #3b82f6; }
  </style>
</aside>
