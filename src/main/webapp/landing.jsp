<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String cp = request.getContextPath();
    String sent = request.getParameter("sent");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eiseb Country Traders — Livestock Financial System</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;0,900;1,400&family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --earth:   #1E0F05;
            --bark:    #3B1F0B;
            --clay:    #7A3B10;
            --savanna: #C9952A;
            --gold:    #E8B84B;
            --cream:   #F7EDD8;
            --surface: #FDFAF4;
            --muted:   #7A6A58;
            --border:  #E5D5B8;
            --text:    #1E0F05;
            --leaf:    #3D6B35;
            --sky:     #2C6E9E;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'DM Sans', sans-serif; background: var(--surface); color: var(--text); line-height: 1.6; }

        .navbar {
            position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 48px; height: 68px;
            background: rgba(30,15,5,0.92); backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(201,149,42,0.2);
        }
        .nav-brand {
            display: flex; align-items: center; gap: 12px;
            font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 700;
            color: var(--gold); text-decoration: none;
        }
        .nav-brand .logo-icon {
            width: 34px; height: 34px; background: var(--savanna); border-radius: 4px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; font-weight: 900; color: var(--earth);
        }
        .nav-brand .sub { font-size: 10px; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,0.45); font-family: 'DM Sans', sans-serif; font-weight: 400; display: block; margin-top: -2px; }
        .nav-links { display: flex; align-items: center; gap: 32px; }
        .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 13px; font-weight: 500; letter-spacing: 0.5px; transition: color 0.2s; }
        .nav-links a:hover { color: var(--gold); }

        .hero {
            min-height: 100vh;
            background-image: linear-gradient(to bottom, rgba(15,7,2,0.75) 0%, rgba(30,15,5,0.6) 60%, rgba(253,250,244,1) 100%), url('images/hero-cattle.jpg');
            background-color: #3B2A1A;
            background-size: cover; background-position: center 35%; background-attachment: scroll;
            display: flex; align-items: center; justify-content: center;
            text-align: center; padding: 120px 24px 80px; position: relative;
        }
        .hero-badge {
            display: inline-block; background: rgba(201,149,42,0.2);
            border: 1px solid rgba(201,149,42,0.5); color: var(--gold);
            font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 3px;
            padding: 7px 18px; border-radius: 20px; margin-bottom: 24px;
        }
        .hero h1 {
            font-family: 'Playfair Display', serif; font-size: clamp(42px, 7vw, 78px); font-weight: 900;
            color: #fff; line-height: 1.08; margin-bottom: 20px; letter-spacing: -1.5px;
        }
        .hero h1 em { color: var(--gold); font-style: normal; }
        .hero p {
            font-size: clamp(16px, 2vw, 19px); color: rgba(255,255,255,0.82);
            max-width: 600px; margin: 0 auto 36px; line-height: 1.7;
        }
        .hero-btns { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
        .btn-hero-primary {
            background: var(--savanna); color: white; padding: 15px 32px; border-radius: 2px;
            font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 2px;
            text-decoration: none; transition: all 0.2s;
        }
        .btn-hero-primary:hover { background: var(--gold); color: var(--earth); transform: translateY(-2px); }

        .stats-strip { background: var(--earth); padding: 0; }
        .stats-inner { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: repeat(4,1fr); }
        .stat-item { padding: 36px 28px; text-align: center; border-right: 1px solid rgba(255,255,255,0.08); }
        .stat-item:last-child { border-right: none; }
        .stat-num  { font-family: 'Playfair Display',serif; font-size: 40px; font-weight: 900; color: var(--gold); line-height: 1; }
        .stat-unit { font-size: 18px; color: var(--savanna); }
        .stat-lbl  { font-size: 12px; text-transform: uppercase; letter-spacing: 2px; color: rgba(255,255,255,0.45); margin-top: 6px; }

        section { padding: 90px 24px; }
        .section-inner { max-width: 1100px; margin: 0 auto; }
        .section-tag  { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 3px; color: var(--savanna); margin-bottom: 12px; }
        .section-title { font-family: 'Playfair Display',serif; font-size: clamp(28px,4vw,44px); font-weight: 900; line-height: 1.15; margin-bottom: 16px; }
        .section-title em { color: var(--savanna); font-style: normal; }
        .section-sub { font-size: 16px; color: var(--muted); max-width: 540px; line-height: 1.7; }
        .divider { width: 48px; height: 3px; background: var(--savanna); margin: 20px 0; border-radius: 2px; }

        .modules-bg { background: var(--surface); }
        .modules-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-top: 52px; }
        .module-card {
            background: white; border-radius: 4px; overflow: hidden;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06); border-top: 4px solid var(--border);
            transition: all 0.25s; cursor: default;
        }
        .module-card:hover { transform: translateY(-5px); box-shadow: 0 12px 32px rgba(0,0,0,0.1); border-top-color: var(--savanna); }
        .module-card-img { height: 180px; overflow: hidden; background: #e0d6c8; }
        .module-card-img img { width:100%; height:100%; object-fit:cover; transition: transform 0.4s; }
        .module-card:hover .module-card-img img { transform: scale(1.05); }
        .module-card-body { padding: 24px 22px 22px; }
        .module-card h3 { font-family:'Playfair Display',serif; font-size:19px; font-weight:700; margin-bottom:8px; color: var(--earth); }
        .module-card p  { font-size:14px; color:var(--muted); line-height:1.65; }
        .module-tag { display:inline-block; margin-top:14px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:1.5px; color:var(--savanna); }

        .finance-section { background: var(--earth); position: relative; overflow: hidden; }
        .finance-section::before {
            content: ''; position: absolute; top: -80px; right: -80px;
            width: 400px; height: 400px;
            background: radial-gradient(circle, rgba(201,149,42,0.12) 0%, transparent 70%); pointer-events: none;
        }
        .finance-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 64px; align-items: center; }
        .finance-text .section-title { color: white; }
        .finance-text .section-sub   { color: rgba(255,255,255,0.65); }
        .finance-text .section-tag   { color: var(--gold); }
        .finance-text .divider       { background: var(--gold); }
        .finance-list { margin-top: 28px; display: flex; flex-direction: column; gap: 16px; }
        .finance-item {
            display: flex; gap: 14px; align-items: flex-start;
            padding: 16px 18px; background: rgba(255,255,255,0.04);
            border-radius: 4px; border-left: 3px solid var(--savanna);
        }
        .finance-item .fi-icon {
            width: 28px; height: 28px; background: var(--savanna); border-radius: 3px;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: 700; color: var(--earth); flex-shrink: 0;
        }
        .finance-item h4 { font-size: 14px; font-weight: 700; color: var(--cream); margin-bottom: 3px; }
        .finance-item p  { font-size: 13px; color: rgba(255,255,255,0.5); line-height: 1.5; }
        .finance-visual { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .fv-card {
            background: rgba(255,255,255,0.05); border: 1px solid rgba(201,149,42,0.2);
            border-radius: 4px; padding: 22px 18px; text-align: center;
        }
        .fv-card.accent { background: rgba(201,149,42,0.12); border-color: rgba(201,149,42,0.4); }
        .fv-num  { font-family:'Playfair Display',serif; font-size:30px; font-weight:900; color:var(--gold); line-height:1; }
        .fv-lbl  { font-size:12px; color:rgba(255,255,255,0.5); text-transform:uppercase; letter-spacing:1.5px; margin-top:6px; }

        .enquiry-section { background: var(--cream); }
        .enquiry-grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 60px; align-items: start; }
        .enquiry-info h2 { font-family:'Playfair Display',serif; font-size:36px; font-weight:900; margin-bottom:12px; }
        .enquiry-info p  { font-size:15px; color:var(--muted); line-height:1.75; margin-bottom:28px; }
        .contact-item { display:flex; gap:14px; margin-bottom:20px; align-items:flex-start; }
        .contact-item .ci-icon {
            width:42px; height:42px; background:var(--earth); border-radius:3px;
            display:flex; align-items:center; justify-content:center;
            font-size:16px; font-weight:700; color: var(--gold); flex-shrink:0;
        }
        .contact-item .ci-label { font-size:11px; text-transform:uppercase; letter-spacing:1.5px; color:var(--muted); font-weight:600; }
        .contact-item .ci-val   { font-size:14px; color:var(--earth); font-weight:500; margin-top:2px; }
        .enquiry-form-card {
            background: white; border-radius: 4px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08); border-top: 5px solid var(--savanna); overflow: hidden;
        }
        .efcard-header { padding: 22px 28px; background: var(--surface); border-bottom: 1px solid var(--border); }
        .efcard-title  { font-family:'Playfair Display',serif; font-size:20px; font-weight:700; color:var(--earth); }
        .efcard-sub    { font-size:13px; color:var(--muted); margin-top:3px; }
        .efcard-body   { padding: 28px; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display:block; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:1.5px; color:var(--muted); margin-bottom:6px; }
        .form-group input, .form-group select, .form-group textarea {
            width:100%; padding:11px 14px; border:1.5px solid var(--border);
            border-radius:3px; font-family:'DM Sans',sans-serif; font-size:14px;
            background:white; color:var(--text); transition:border-color 0.2s;
        }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline:none; border-color:var(--savanna); }
        .form-row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .alert-success { background:#E8F5E9; color:#2E7D32; padding:12px 16px; border-radius:4px; margin-bottom:16px; border-left:4px solid #2E7D32; font-size:14px; }
        .btn-submit-full { width:100%; padding:14px; background:var(--earth); color:var(--cream); border:none; border-radius:3px; font-family:'DM Sans',sans-serif; font-size:14px; font-weight:700; text-transform:uppercase; letter-spacing:2px; cursor:pointer; transition:background 0.2s; }
        .btn-submit-full:hover { background:var(--bark); }

        .footer { background: var(--earth); color: rgba(255,255,255,0.55); padding: 40px 24px 24px; }
        .footer-inner { max-width:1100px; margin:0 auto; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; }
        .footer-brand { font-family:'Playfair Display',serif; font-size:18px; color:var(--gold); }
        .footer-copy  { font-size:12px; }
        .footer-staff a { font-size:12px; color:rgba(255,255,255,0.35); text-decoration:none; transition:color 0.2s; }
        .footer-staff a:hover { color:var(--gold); }

        /* Mobile Staff Portal button (hidden on desktop) */
        #mobile-staff-btn { display: none; }

        @media (max-width: 900px) {
            .navbar { padding: 0 20px; }
            .nav-links { display: none; }
            .modules-grid { grid-template-columns: 1fr 1fr; }
            .finance-grid { grid-template-columns: 1fr; gap: 40px; }
            .finance-visual { grid-template-columns: repeat(4,1fr); }
            .enquiry-grid { grid-template-columns: 1fr; }
            .stats-inner { grid-template-columns: repeat(2,1fr); }
            #mobile-staff-btn { display: inline-block !important; }
        }

        @media (max-width: 600px) {
            .modules-grid { grid-template-columns: 1fr; }
            .finance-visual { grid-template-columns: 1fr 1fr; }
            .form-row2 { grid-template-columns: 1fr; }
            .stats-inner { grid-template-columns: repeat(2,1fr); }
            section { padding: 60px 16px; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="#" class="nav-brand">
        <div class="logo-icon">E</div>
        <div>
            Eiseb Country Traders
            <span class="sub">Livestock Financial System</span>
        </div>
    </a>
    <div class="nav-links">
        <a href="#modules">Modules</a>
        <a href="#finance">Finance</a>
        <a href="#enquiry">Contact</a>
    </div>
</nav>

<section class="hero">
    <div>
        <div class="hero-badge">Omaheke Region, Namibia</div>
        <h1>Livestock<br><em>Financial</em><br>Management</h1>
        <p>A comprehensive ERP module for Eiseb Country Traders — digitising animal registration, valuations, sales tracking, expense management and financial reporting.</p>
        <div class="hero-btns">
            <a href="#enquiry" class="btn-hero-primary">Get in Touch</a>
            <a href="<%= cp %>/login" class="btn-hero-primary" id="mobile-staff-btn">Staff Portal</a>
        </div>
    </div>
</section>

<div class="stats-strip">
    <div class="stats-inner">
        <div class="stat-item">
            <div class="stat-num">7<span class="stat-unit">+</span></div>
            <div class="stat-lbl">Animals Registered</div>
        </div>
        <div class="stat-item">
            <div class="stat-num">N$<span class="stat-unit">55K</span></div>
            <div class="stat-lbl">Livestock Valued</div>
        </div>
        <div class="stat-item">
            <div class="stat-num">3</div>
            <div class="stat-lbl">Species Managed</div>
        </div>
        <div class="stat-item">
            <div class="stat-num">100<span class="stat-unit">%</span></div>
            <div class="stat-lbl">Digital Records</div>
        </div>
    </div>
</div>

<section class="modules-bg" id="modules">
    <div class="section-inner">
        <div class="section-tag">System Modules</div>
        <h2 class="section-title">Everything You Need to<br><em>Manage Your Operation</em></h2>
        <div class="divider"></div>
        <p class="section-sub">A complete ERP module for livestock financial management — covering every stage from animal registration through to financial reporting.</p>
        <div class="modules-grid">
            <div class="module-card">
                <div class="module-card-img"><img src="images/livestock-registry.jpg" alt="Livestock" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Livestock Registry</h3><p>Register animals with ear tags, species, breed, gender and date of birth. Filter by Active, Sold, or Deceased status.</p><span class="module-tag">Identification</span></div>
            </div>
            <div class="module-card">
                <div class="module-card-img"><img src="images/sales-finance.jpg" alt="Finance" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Sales & Income</h3><p>Record direct sales, auction results and export transactions. Track payment status and automatically mark animals as Sold.</p><span class="module-tag">Revenue Tracking</span></div>
            </div>
            <div class="module-card">
                <div class="module-card-img"><img src="images/reports.jpg" alt="Reports" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Financial Reports</h3><p>Income vs expense summaries, net position tracking and category-level expense breakdowns. Printable for audit purposes.</p><span class="module-tag">Analytics</span></div>
            </div>
            <div class="module-card">
                <div class="module-card-img"><img src="images/valuations.jpg" alt="Valuations" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Valuations</h3><p>Record periodic valuations per animal using market survey or veterinary assessment methods. History tracked over time.</p><span class="module-tag">Asset Valuation</span></div>
            </div>
            <div class="module-card">
                <div class="module-card-img"><img src="images/expenses.jpg" alt="Expenses" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Expenses</h3><p>Log feed, vet, transport, wages and equipment costs. Optionally link expenses to specific animals for per-animal costing.</p><span class="module-tag">Cost Management</span></div>
            </div>
            <div class="module-card">
                <div class="module-card-img"><img src="images/dashboard.jpg" alt="Dashboard" onerror="this.style.display='none'"></div>
                <div class="module-card-body"><h3>Dashboard</h3><p>Live overview of total income, expenses, net position and active livestock count. Visual charts for quick decision-making.</p><span class="module-tag">Operations Overview</span></div>
            </div>
        </div>
    </div>
</section>

<section class="finance-section" id="finance">
    <div class="section-inner">
        <div class="finance-grid">
            <div class="finance-text">
                <div class="section-tag">Financial Management</div>
                <h2 class="section-title">Real-Time<br><em>Farm Financials</em></h2>
                <div class="divider"></div>
                <p class="section-sub">Every transaction, valuation and expense is captured digitally — giving management a clear, accurate picture of the farm's financial health at all times.</p>
                <div class="finance-list">
                    <div class="finance-item"><div class="fi-icon">I</div><div><h4>Income Tracking</h4><p>Capture sale prices, buyer details, payment status and sale type in one place.</p></div></div>
                    <div class="finance-item"><div class="fi-icon">V</div><div><h4>Asset Valuation</h4><p>Maintain an up-to-date valuation history for every animal — essential for insurance, loans and annual reports.</p></div></div>
                    <div class="finance-item"><div class="fi-icon">E</div><div><h4>Expense Control</h4><p>Categorised expense logging enables targeted cost reduction.</p></div></div>
                    <div class="finance-item"><div class="fi-icon">R</div><div><h4>Printable Reports</h4><p>Generate and print a full financial summary — ready for auditors or the bank.</p></div></div>
                </div>
            </div>
            <div class="finance-visual">
                <div class="fv-card accent"><div class="fv-num">N$18.5K</div><div class="fv-lbl">Top Sale</div></div>
                <div class="fv-card"><div class="fv-num">6</div><div class="fv-lbl">Expense Categories</div></div>
                <div class="fv-card"><div class="fv-num">3</div><div class="fv-lbl">Sale Types</div></div>
                <div class="fv-card accent"><div class="fv-num">100%</div><div class="fv-lbl">Traceable</div></div>
            </div>
        </div>
    </div>
</section>

<section class="enquiry-section" id="enquiry">
    <div class="section-inner">
        <div class="enquiry-grid">
            <div class="enquiry-info">
                <div class="section-tag">Get In Touch</div>
                <h2>Contact <em style="color:var(--savanna);font-style:normal">Eiseb</em></h2>
                <div class="divider"></div>
                <p>Have a question about our operations, or want to learn more about our financial management system? Send us a message and we'll get back to you.</p>
                <div class="contact-item"><div class="ci-icon">L</div><div><div class="ci-label">Location</div><div class="ci-val">Eiseb District, Omaheke Region, Namibia</div></div></div>
                <div class="contact-item"><div class="ci-icon">P</div><div><div class="ci-label">Phone</div><div class="ci-val">+264 81 850 36 87</div></div></div>
                <div class="contact-item"><div class="ci-icon">E</div><div><div class="ci-label">Email</div><div class="ci-val">info@eiseblfs.na</div></div></div>
                <div class="contact-item"><div class="ci-icon">H</div><div><div class="ci-label">Office Hours</div><div class="ci-val">Mon–Fri: 08:00–17:00 · Sat: 08:00–13:00</div></div></div>
            </div>
            <div class="enquiry-form-card">
                <div class="efcard-header"><div class="efcard-title">Send a Message</div><div class="efcard-sub">All fields marked * are required</div></div>
                <div class="efcard-body">
                    <% if ("true".equals(sent)) { %><div class="alert-success">Your message has been sent. We will be in touch shortly!</div><% } %>
                    <form method="post" action="<%= cp %>/contact">
                        <input type="hidden" name="redirectTo" value="landing">
                        <div class="form-row2">
                            <div class="form-group"><label>Full Name *</label><input type="text" name="fullName" required placeholder="Your name"></div>
                            <div class="form-group"><label>Email *</label><input type="email" name="email" required placeholder="you@example.com"></div>
                        </div>
                        <div class="form-group"><label>Subject</label><input type="text" name="subject" placeholder="e.g. General Enquiry"></div>
                        <div class="form-group"><label>Message *</label><textarea name="message" rows="5" required placeholder="Your message..."></textarea></div>
                        <button type="submit" class="btn-submit-full">Send Message</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>

<footer class="footer">
    <div class="footer-inner">
        <div class="footer-brand">Eiseb Country Traders</div>
        <div class="footer-copy">&copy; 2026 Eiseb Country Traders · Omaheke Region, Namibia · WPM711S Group 2</div>
        <div class="footer-staff"><a href="<%= cp %>/login">Staff Portal</a></div>
    </div>
</footer>

</body>
</html>
