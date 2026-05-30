# Eiseb LFS — Setup & Deployment Guide
### Group 2 | Java EE + MySQL + Apache Tomcat

---

## What You Need

| Tool | Version | Download |
|------|---------|----------|
| Java JDK | 17+ | https://adoptium.net |
| Apache Tomcat | 10.1+ | https://tomcat.apache.org |
| MySQL (via XAMPP) | 8.0+ | https://www.apachefriends.org |
| Maven | 3.9+ | https://maven.apache.org |
| IDE | IntelliJ IDEA or Eclipse | — |

---

## Step 1 — Set Up the Database

1. Start **XAMPP** and start the **MySQL** module.
2. Open **phpMyAdmin** → `http://localhost/phpmyadmin`
3. Click **Import** → choose `sql/schema.sql` from this project.
4. Click **Go**. This creates the `eiseb_lfs` database with all tables and seed data.

> Default login after setup: **username:** `admin` / **password:** `admin123`

---

## Step 2 — Configure the Database Connection

Open `src/main/webapp/WEB-INF/web.xml` and find these lines:

```xml
<context-param>
    <param-name>db.user</param-name>
    <param-value>root</param-value>       <!-- change if your MySQL user is different -->
</context-param>
<context-param>
    <param-name>db.password</param-name>
    <param-value></param-value>            <!-- add your MySQL password if set -->
</context-param>
```

For a default XAMPP install, **root with no password** is correct — no changes needed.

---

## Step 3 — Build the Project

Open a terminal in the project root (where `pom.xml` is) and run:

```bash
mvn clean package
```

This produces `target/EisebLFS.war`.

---

## Step 4 — Deploy to Tomcat

**Option A — Auto deploy (easiest):**
Copy `target/EisebLFS.war` into Tomcat's `webapps/` folder.
Start Tomcat: `bin/startup.sh` (Linux/Mac) or `bin/startup.bat` (Windows).

**Option B — IntelliJ IDEA:**
1. Run → Edit Configurations → `+` → Tomcat Server → Local
2. Deployment tab → `+` → Artifact → `EisebLFS:war`
3. Application context: `/EisebLFS`
4. Click Run ▶

**Option C — Eclipse:**
1. Right-click project → Run As → Run on Server
2. Select your Tomcat 10 installation
3. Finish

---

## Step 5 — Open the App

Navigate to:
```
http://localhost:8080/EisebLFS
```

Log in with `admin` / `admin123`.

---

## Project File Structure

```
EisebLFS/
├── pom.xml                              ← Maven build file
├── sql/
│   └── schema.sql                       ← Database setup (run this first!)
└── src/main/
    ├── java/com/eiseb/
    │   ├── model/                       ← Plain Java objects (User, Livestock, Sale…)
    │   ├── dao/                         ← Database queries (UserDAO, LivestockDAO…)
    │   ├── servlet/                     ← HTTP request handlers (LoginServlet…)
    │   └── util/                        ← DBConnection, PasswordUtil
    └── webapp/
        ├── WEB-INF/
        │   ├── web.xml                  ← Servlet config & DB params
        │   └── nav.jsp                  ← Shared sidebar (included by all pages)
        ├── css/
        │   └── main.css                 ← All styling
        ├── pages/
        │   ├── dashboard.jsp
        │   ├── livestock.jsp
        │   ├── valuations.jsp
        │   ├── sales.jsp
        │   ├── expenses.jsp
        │   ├── reports.jsp
        │   ├── contact.jsp
        │   ├── error404.jsp
        │   └── error500.jsp
        └── index.jsp                    ← Login / Register page
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Make sure `mysql-connector-j` is in `WEB-INF/lib` (Maven handles this) |
| `Access denied for user 'root'` | Update `db.password` in `web.xml` |
| `Table 'eiseb_lfs.users' doesn't exist` | Re-run `schema.sql` in phpMyAdmin |
| Port 8080 in use | Change Tomcat port in `conf/server.xml` or stop other apps |
| BCrypt class not found | Check `jbcrypt-0.4.jar` is included in the WAR |

---

## How It All Connects

```
Browser → HTTP Request
  → Tomcat (Servlet Container)
    → Servlet (e.g. LivestockServlet.java)
      → DAO (e.g. LivestockDAO.java)  ←→  MySQL Database
    ← sets request attributes
  ← JSP renders HTML (e.g. livestock.jsp)
← HTTP Response (HTML page)
```

---

*Built by Group 2 — Eiseb Country Traders LFS*
