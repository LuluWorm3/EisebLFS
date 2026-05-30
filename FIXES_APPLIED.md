# Fixes Applied - May 2026

## 1. Database Connection
- **Problem**: App was connecting as 'mammon'@'localhost' instead of eiseb_user
- **Cause**: web.xml had `db.username` but DBConnection.java read `db.user`
- **Fix**: Hardcoded credentials in DBConnection.java (temp fix)
- **Original file backed up**: DBConnection.java.orig

## 2. Password Hashing
- **Problem**: BCrypt library (jbcrypt-0.4.jar) not loading in GlassFish classloader
- **Fix**: Added SHA-256 fallback in PasswordUtil.java
- **Admin password**: Reset to SHA-256 hash

## 3. Connection Pool Errors
- **Problem**: Old eiseb_financial_pool causing errors in GlassFish
- **Fix**: Deleted the broken pool from GlassFish admin console

## To Do (Production):
- [ ] Fix web.xml to use `db.user` instead of `db.username`
- [ ] Restore original DBConnection.java from .orig backup
- [ ] Get BCrypt working properly (check GlassFish classloader settings)
- [ ] Move credentials to environment variables or GlassFish JNDI
- [ ] Set up proper connection pooling
