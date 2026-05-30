<%@ page import="java.sql.*, com.eiseb.util.DBConnection" %>
<html>
<body>
<h2>Database Connection Test</h2>
<%
    try {
        Connection conn = DBConnection.getConnection(application);
        out.println("<p style='color:green'><b>CONNECTED!</b> Database: " + conn.getCatalog() + "</p>");
        
        // Test users table
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users");
        rs.next();
        out.println("<p>Users in database: <b>" + rs.getInt(1) + "</b></p>");
        
        // Test admin user
        PreparedStatement ps = conn.prepareStatement("SELECT username, password FROM users WHERE username='admin'");
        ResultSet rs2 = ps.executeQuery();
        if(rs2.next()) {
            out.println("<p>Admin user found: <b>" + rs2.getString("username") + "</b></p>");
            out.println("<p>Password hash: <b>" + rs2.getString("password").substring(0,20) + "...</b></p>");
        }
        
        conn.close();
    } catch(Exception e) {
        out.println("<p style='color:red'><b>ERROR:</b> " + e.getMessage() + "</p>");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
<p><a href="index.jsp">Back to Login</a></p>
</body>
</html>
