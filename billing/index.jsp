<%@page language="java" import="java.util.*" %>
<%!
// Password hashing utility - Updated to SHA-512 to match existing hashes
private String hashPassword(String password) throws Exception {
    java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-512");
    byte[] hash = md.digest(password.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte b : hash) {
        sb.append(String.format("%02x", b));
    }
    return sb.toString();
}
%>
<%
// Prevent caching - force fresh page load
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<jsp:useBean id="prod" class="user.userBean" scope="session" />
<%
String submittedUser = request.getParameter("username");
String submittedPass = request.getParameter("password");

boolean loginFailed = false;
boolean licenseExpired = false;

if (submittedUser != null && submittedPass != null) {
    Vector userAndPass = prod.getUserCredential(); // fetch from DB
    boolean matched = false;

    for (int i = 0; i < userAndPass.size(); i++) {
        Vector row = (Vector) userAndPass.get(i);
        String dbUser = row.elementAt(0).toString();
        String dbPass = row.elementAt(1).toString();
        int userId = Integer.parseInt(row.elementAt(2).toString());

        if (submittedUser.equals(dbUser) && hashPassword(submittedPass).equals(dbPass)) {
            // Check license validity before allowing login
            try {
                if (!prod.checkLicenseValidity()) {
                    licenseExpired = true;
                    break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // Success - Redirect to dashboard
            session.setAttribute("userId", userId);
            session.setAttribute("username", dbUser);
            response.sendRedirect(request.getContextPath() + "/billing/app.jsp");

            
            return;
        }
    }

    if (!licenseExpired) {
        loginFailed = true; // No match found
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login - JASXBILL</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link href="dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="dist/fonts/css/all.min.css">
  <link rel="stylesheet" href="assets/css/theme.css">
</head>
<body class="login-body">

  <!-- Animated Background -->
  <div class="login-bg">
    <div class="bg-orb bg-orb-1"></div>
    <div class="bg-orb bg-orb-2"></div>
    <div class="bg-orb bg-orb-3"></div>
  </div>

  <!-- Main Login Area -->
  <div class="login-main">
    <div class="lc-card">

      <!-- Brand -->
      <div class="lc-brand">
        <div class="lc-brand-icon">
          <i class="fas fa-file-invoice-dollar"></i>
        </div>
        <h1 class="lc-brand-name">JASXBILL</h1>
        <p class="lc-brand-tagline">Smart Business Management System</p>
      </div>

      <div class="lc-divider"></div>

      <div class="lc-welcome">
        <h2>Welcome Back</h2>
        <p>Sign in to access your dashboard</p>
      </div>

      <form action="<%=request.getContextPath()%>/index.jsp" method="post" autocomplete="off">

        <!-- Username -->
        <div class="lc-field">
          <span class="lc-field-icon"><i class="fas fa-user"></i></span>
          <input type="text"
                 class="lc-input"
                 name="username"
                 placeholder="Username"
                 required
                 autofocus
                 autocomplete="username">
        </div>

        <!-- Password -->
        <div class="lc-field">
          <span class="lc-field-icon"><i class="fas fa-lock"></i></span>
          <input type="password"
                 class="lc-input has-eye"
                 id="lc-password"
                 name="password"
                 placeholder="Password"
                 required
                 autocomplete="current-password">
          <button type="button" class="lc-eye-btn" onclick="toggleLcPass()" aria-label="Toggle password visibility">
            <i class="fas fa-eye" id="lc-eye-icon"></i>
          </button>
        </div>

        <% if (loginFailed) { %>
        <div class="lc-alert lc-alert-error">
          <i class="fas fa-exclamation-circle"></i>
          <span>Invalid username or password. Please try again.</span>
        </div>
        <% } %>

        <% if (licenseExpired) { %>
        <div class="lc-alert lc-alert-warning">
          <i class="fas fa-exclamation-triangle"></i>
          <div>
            <strong>Software License Expired!</strong>
            <p>Contact Software Team: 8667214152</p>
          </div>
        </div>
        <% } %>

        <button type="submit" class="lc-btn">
          <i class="fas fa-sign-in-alt"></i>
          <span>Sign In</span>
        </button>

      </form>

      <div class="lc-note">
        <i class="fas fa-info-circle"></i>
        Contact your administrator for account access
      </div>

    </div>
  </div>

  <!-- Feature Strip -->
  <div class="login-features">
    <div class="lf-card">
      <div class="lf-icon"><i class="fas fa-file-invoice"></i></div>
      <h3>Smart Invoicing</h3>
      <p>Professional invoices with automated GST</p>
    </div>
    <div class="lf-card">
      <div class="lf-icon"><i class="fas fa-warehouse"></i></div>
      <h3>Inventory</h3>
      <p>Real-time stock &amp; supplier tracking</p>
    </div>
    <div class="lf-card">
      <div class="lf-icon"><i class="fas fa-chart-bar"></i></div>
      <h3>Analytics</h3>
      <p>Powerful reports and dashboards</p>
    </div>
    <div class="lf-card">
      <div class="lf-icon"><i class="fas fa-calculator"></i></div>
      <h3>GST Compliance</h3>
      <p>Automated tax calculations</p>
    </div>
  </div>

  <!-- Footer -->
  <footer class="login-footer">
    <div class="lfoot-inner">
      <div class="lfoot-brand">
        <i class="fas fa-headset"></i>
        <span>24/7 Support Available</span>
      </div>
      <div class="lfoot-links">
        <a href="mailto:jaswavj@gmail.com" class="lfoot-link">
          <i class="fas fa-envelope"></i>
          jaswavj@gmail.com
        </a>
        <a href="tel:+918667214152" class="lfoot-link">
          <i class="fas fa-phone"></i>
          +91 8667214152 / +91 9597451419
        </a>
      </div>
    </div>
  </footer>

  <script src="dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function toggleLcPass() {
      var inp = document.getElementById('lc-password');
      var ico = document.getElementById('lc-eye-icon');
      if (inp.type === 'password') {
        inp.type = 'text';
        ico.classList.replace('fa-eye', 'fa-eye-slash');
      } else {
        inp.type = 'password';
        ico.classList.replace('fa-eye-slash', 'fa-eye');
      }
    }
  </script>

</body>
</html>
