package com.eiseb.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    private static final int WORK_FACTOR = 12;

    public static String hash(String plainText) {
        try {
            return org.mindrot.jbcrypt.BCrypt.hashpw(plainText, org.mindrot.jbcrypt.BCrypt.gensalt(WORK_FACTOR));
        } catch (Throwable e) {
            System.out.println("BCrypt not available, using SHA-256 fallback: " + e.getMessage());
            return sha256Hash(plainText);
        }
    }

    public static boolean verify(String plainText, String hashed) {
        if (hashed == null) return false;
        
        // BCrypt hash
        if (hashed.startsWith("$2a$") || hashed.startsWith("$2b$") || hashed.startsWith("$2y$")) {
            try {
                return org.mindrot.jbcrypt.BCrypt.checkpw(plainText, hashed);
            } catch (Throwable e) {
                System.out.println("BCrypt verify failed: " + e.getMessage());
                return false;
            }
        }
        
        // SHA-256 fallback
        if (hashed.startsWith("SHA256:")) {
            return sha256Verify(plainText, hashed);
        }
        
        return false;
    }
    
    private static String sha256Hash(String plainText) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            md.update(salt);
            byte[] hash = md.digest(plainText.getBytes("UTF-8"));
            byte[] combined = new byte[salt.length + hash.length];
            System.arraycopy(salt, 0, combined, 0, salt.length);
            System.arraycopy(hash, 0, combined, salt.length, hash.length);
            return "SHA256:" + Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new RuntimeException("Hashing failed", e);
        }
    }
    
    private static boolean sha256Verify(String plainText, String stored) {
        try {
            String b64 = stored.substring(7);
            byte[] combined = Base64.getDecoder().decode(b64);
            byte[] salt = new byte[16];
            byte[] originalHash = new byte[combined.length - 16];
            System.arraycopy(combined, 0, salt, 0, 16);
            System.arraycopy(combined, 16, originalHash, 0, originalHash.length);
            
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] newHash = md.digest(plainText.getBytes("UTF-8"));
            
            return MessageDigest.isEqual(originalHash, newHash);
        } catch (Exception e) {
            return false;
        }
    }
}
