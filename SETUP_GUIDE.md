```bash
cat > /home/mammon/NetBeansProjects/EisebLFS/SETUP_GUIDE.md << 'EOF'
# Eiseb LFS — Setup & Deployment Guide
### Group 2 | Java EE (Jakarta EE) + MySQL + GlassFish / Tomcat

---

## What You Need

| Tool | Version | Linux | Windows | Mac |
|------|---------|-------|---------|-----|
| Java JDK | 17–21 | `sudo apt install openjdk-21-jdk` | https://adoptium.net | `brew install openjdk@21` |
| MySQL | 8.0+ | `sudo apt install mysql-server` | https://www.apachefriends.org (XAMPP) | `brew install mysql` |
| Maven | 3.9+ | `sudo apt install maven` | https://maven.apache.org | `brew install maven` |
| GlassFish | 7.0+ | See below | See below | See below |
| Git (optional) | 2.40+ | `sudo apt install git` | https://git-scm.com | `brew install git` |

> **Tomcat 10.1+** also works — just change the deployment folder.

---

## Step 1 — Install Java & Verify

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install openjdk-21-jdk
java -version
```

### Windows
1. Download **JDK 21** from https://adoptium.net
2. Run the `.msi` installer (check "Add to PATH")
3. Open **Command Prompt** → `java -version`

### Mac
```bash
brew install openjdk@21
sudo ln -sfn /usr/local/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
java -version
```

---

## Step 2 — Install MySQL

### Linux (Ubuntu)
```bash
sudo apt install mysql-server
sudo mysql_secure_installation
# Choose: VALIDATE PASSWORD → Yes, strength 1
# Set root password: Eiseb123@#
# Remove anonymous users: Yes
# Disallow root login remotely: Yes
# Remove test database: Yes
# Reload privilege tables: Yes

# Create database and user
sudo mysql -u root -p
```
```sql
CREATE DATABASE eiseb_lfs;
CREATE USER 'eiseb_user'@'localhost' IDENTIFIED BY 'Eiseb123@#';
GRANT ALL PRIVILEGES ON eiseb_lfs.* TO 'eiseb_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Windows (XAMPP)
1. Download XAMPP from https://www.apachefriends.org
2. Install and launch **XAMPP Control Panel**
3. Click **Start** next to MySQL
4. Click **Shell** → type:
```bash
mysql -u root
```
```sql
CREATE DATABASE eiseb_lfs;
CREATE USER 'eiseb_user'@'localhost' IDENTIFIED BY 'Eiseb123@#';
GRANT ALL PRIVILEGES ON eiseb_lfs.* TO 'eiseb_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Mac
```bash
brew install mysql
brew services start mysql
mysql_secure_installation
# Follow prompts (same as Linux above)
mysql -u root -p
```
```sql
CREATE DATABASE eiseb_lfs;
CREATE USER 'eiseb_user'@'localhost' IDENTIFIED BY 'Eiseb123@#';
GRANT ALL PRIVILEGES ON eiseb_lfs.* TO 'eiseb_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## Step 3 — Import the Database Schema

### All platforms:
```bash
# Navigate to project folder
cd EisebLFS

# Import schema
mysql -u eiseb_user -p'Eiseb123@#' eiseb_lfs < sql/schema.sql
```

### Windows (XAMPP alternative):
1. Open http://localhost/phpmyadmin
2. Click **eiseb_lfs** database (create it first if needed)
3. Click **Import** → Choose `sql/schema.sql` → **Go**

---

## Step 4 — Install GlassFish

### Linux
```bash
cd ~
wget https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.15.zip
unzip glassfish-7.0.15.zip -d GlassFish_Server
cd GlassFish_Server/glassfish/bin
chmod +x asadmin

# Start GlassFish
./asadmin start-domain

# Verify (should show running)
./asadmin list-domains
```

### Windows
1. Download from https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.15.zip
2. Extract to `C:\GlassFish_Server`
3. Open **Command Prompt as Administrator**:
```cmd
cd C:\GlassFish_Server\glassfish\bin
asadmin start-domain
```

### Mac
Same as Linux:
```bash
cd ~
curl -O https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.15.zip
unzip glassfish-7.0.15.zip -d GlassFish_Server
cd GlassFish_Server/glassfish/bin
chmod +x asadmin
./asadmin start-domain
```

---

## Step 5 — Configure Database Connection

Open `src/main/webapp/WEB-INF/web.xml` and verify:

```xml
<context-param>
    <param-name>db.url</param-name>
    <param-value>jdbc:mysql://localhost:3306/eiseb_lfs?useSSL=false&amp;serverTimezone=UTC</param-value>
</context-param>
<context-param>
    <param-name>db.user</param-name>
    <param-value>eiseb_user</param-value>
</context-param>
<context-param>
    <param-name>db.password</param-name>
    <param-value>Eiseb123@#</param-value>
</context-param>
```

> **Current state**: DBConnection.java has hardcoded values. To restore reading from web.xml, use `DBConnection.java.orig` backup.

---

## Step 6 — Build the Project

```bash
cd EisebLFS
mvn clean package
```

**Success output**: `BUILD SUCCESS` with `EisebLFS.war` in `target/`

### Windows (Command Prompt):
```cmd
cd C:\path\to\EisebLFS
mvn clean package
```

---

## Step 7 — Deploy to GlassFish

### Option A — Auto-deploy (all platforms)
```bash
cp target/EisebLFS.war ~/GlassFish_Server/glassfish/domains/domain1/autodeploy/
```

**Windows**:
```cmd
copy target\EisebLFS.war C:\GlassFish_Server\glassfish\domains\domain1\autodeploy\
```

### Option B — Admin Console
1. Open http://localhost:4848
2. Login (default: `admin` / no password)
3. Applications → Deploy → Choose `target/EisebLFS.war`
4. Click **OK**

### Option C — Command Line
```bash
~/GlassFish_Server/glassfish/bin/asadmin deploy target/EisebLFS.war
```

---

## Step 8 — Open the Application

```
http://localhost:8080/EisebLFS
```

**Login credentials**:
- Username: `admin`
- Password: `admin123`

---

## Verify Everything Works

After login, you should see the **Dashboard** with:
- Total Income / Total Expenses / Net Position
- Active Livestock count
- Recent Sales & Expenses tables

Test these pages:
- **Livestock** → Add/view animals
- **Valuations** → Record animal valuations
- **Sales** → Record sales, mark as paid
- **Expenses** → Record expenses by category
- **Reports** → View financial summaries
- **Contact** → Submit/view enquiries

---

## Project File Structure

```
EisebLFS/
├── pom.xml                              ← Maven build file
├── SETUP_GUIDE.md                       ← This file
├── FIXES_APPLIED.md                     ← Known fixes applied
├── sql/
│   └── schema.sql                       ← Database schema & seed data
└── src/main/
    ├── java/com/eiseb/
    │   ├── model/                       ← Java beans (User, Livestock, Sale…)
    │   ├── dao/                         ← Database access (UserDAO, LivestockDAO…)
    │   ├── servlet/                     ← HTTP handlers (LoginServlet…)
    │   └── util/                        ← DBConnection, PasswordUtil
    └── webapp/
        ├── WEB-INF/
        │   ├── web.xml                  ← Servlet config & DB params
        │   └── nav.jsp                  ← Shared navigation sidebar
        ├── css/
        │   └── main.css                 ← All styling
        ├── dbtest.jsp                   ← Database connection test page
        ├── pages/
        │   ├── dashboard.jsp            ← Main dashboard
        │   ├── livestock.jsp            ← Livestock management
        │   ├── valuations.jsp           ← Valuation records
        │   ├── sales.jsp                ← Sales management
        │   ├── expenses.jsp             ← Expense tracking
        │   ├── reports.jsp              ← Financial reports
        │   ├── contact.jsp              ← Enquiry/contact form
        │   ├── error404.jsp             ← 404 error page
        │   └── error500.jsp             ← 500 error page
        └── index.jsp                    ← Login / Registration page
```

---

## Troubleshooting

| Problem | Check |
|---------|-------|
| `Access denied for user` | Verify `db.user` and `db.password` in web.xml |
| `Table doesn't exist` | Re-run `sql/schema.sql` import |
| `ClassNotFoundException: com.mysql.cj.jdbc.Driver` | Check `mysql-connector-j` in `WEB-INF/lib` |
| Port 8080 in use | `lsof -i :8080` → kill the process |
| Port 4848 in use (admin console) | `lsof -i :4848` → kill the process |
| GlassFish won't start | Check `~/GlassFish_Server/glassfish/domains/domain1/logs/server.log` |
| BCrypt not working | PasswordUtil has SHA-256 fallback built in |
| Login redirects back to login | Check server log: `tail -f ~/GlassFish_Server/glassfish/domains/domain1/logs/server.log` |
| Database connection test | Visit http://localhost:8080/EisebLFS/dbtest.jsp |

---

## Architecture Flow

```
Browser → HTTP Request
  → GlassFish/Tomcat (Servlet Container)
    → Servlet (e.g. LoginServlet.java)
      → DAO (e.g. UserDAO.java)
        → DBConnection.getConnection()
          → MySQL Database (eiseb_lfs)
    ← sets request attributes
  ← JSP renders HTML (e.g. dashboard.jsp)
← HTTP Response (HTML page)
```

---

## Quick Commands Reference

```bash
# Start GlassFish
~/GlassFish_Server/glassfish/bin/asadmin start-domain

# Stop GlassFish
~/GlassFish_Server/glassfish/bin/asadmin stop-domain

# Restart GlassFish
~/GlassFish_Server/glassfish/bin/asadmin restart-domain

# Build project
cd EisebLFS && mvn clean package

# Deploy WAR
cp target/EisebLFS.war ~/GlassFish_Server/glassfish/domains/domain1/autodeploy/

# View server logs
tail -f ~/GlassFish_Server/glassfish/domains/domain1/logs/server.log

# Test database connection
mysql -u eiseb_user -p'Eiseb123@#' -e "SELECT * FROM eiseb_lfs.users;"
```

---

*Built by Group 2 — Eiseb Country Traders Livestock Financial System*
EOF

echo "Setup guide created successfully!"
```

This guide covers all three platforms with every step from installing Java to deploying and testing the app.