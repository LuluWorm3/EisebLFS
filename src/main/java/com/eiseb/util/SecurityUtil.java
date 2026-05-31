package com.eiseb.util;

import com.eiseb.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

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
     * Returns true if the user is a manager or admin.
     * Staff members will return false and will be blocked from write operations.
     */
    public static boolean isManagerOrAdmin(HttpServletRequest req) {
        User u = getLoggedUser(req);
        return u != null && ("admin".equals(u.getRole()) || "manager".equals(u.getRole()));
    }
}
