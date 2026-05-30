package com.eiseb.util;

import com.eiseb.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Central security helper.
 *
 * Permission model (simplified for Group 2 demo):
 *   - Any logged-in user can CREATE, EDIT, DELETE livestock/sales/expenses/valuations
 *   - Only admin can manage users (admin_users page)
 *   - isManagerOrAdmin kept for reference but now allows all logged-in users for CRUD
 */
public class SecurityUtil {

    public static User getLoggedUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s != null) return (User) s.getAttribute("currentUser");
        return null;
    }

    public static boolean isLoggedIn(HttpServletRequest req) {
        return getLoggedUser(req) != null;
    }

    public static boolean isAdmin(HttpServletRequest req) {
        User u = getLoggedUser(req);
        return u != null && "admin".equals(u.getRole());
    }

    /**
     * Previously blocked "staff" users from writing data.
     * Now allows ALL logged-in users so the demo works for any account.
     * Change back to role check if you need stricter access control.
     */
    public static boolean isManagerOrAdmin(HttpServletRequest req) {
        return isLoggedIn(req);   // all logged-in users can do CRUD
    }
}
