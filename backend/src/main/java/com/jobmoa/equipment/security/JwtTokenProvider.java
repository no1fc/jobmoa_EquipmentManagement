package com.jobmoa.equipment.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey key;
    private final long accessExpiration;
    private final long refreshExpiration;

    public JwtTokenProvider(
        @Value("${jwt.secret}") String secret,
        @Value("${jwt.access-expiration}") long accessExpiration,
        @Value("${jwt.refresh-expiration}") long refreshExpiration
    ) {
        this.key = Keys.hmacShaKeyFor(Decoders.BASE64.decode(
            java.util.Base64.getEncoder().encodeToString(secret.getBytes())
        ));
        this.accessExpiration = accessExpiration;
        this.refreshExpiration = refreshExpiration;
    }

    public String generateAccessToken(Long userId, String email, String role) {
        return generateToken(userId, email, role, accessExpiration, "ACCESS");
    }

    public String generateRefreshToken(Long userId, String email, String role) {
        return generateToken(userId, email, role, refreshExpiration, "REFRESH");
    }

    private String generateToken(Long userId, String email, String role, long expiration, String tokenType) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
            .subject(userId.toString())
            .claim("email", email)
            .claim("role", role)
            .claim("type", tokenType)
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(key)
            .compact();
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = parseClaims(token);
        return Long.parseLong(claims.getSubject());
    }

    public String getRoleFromToken(String token) {
        Claims claims = parseClaims(token);
        return claims.get("role", String.class);
    }

    public boolean validateToken(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (SecurityException | MalformedJwtException e) {
            log.warn("Invalid JWT signature");
        } catch (ExpiredJwtException e) {
            log.warn("Expired JWT token");
        } catch (UnsupportedJwtException e) {
            log.warn("Unsupported JWT token");
        } catch (IllegalArgumentException e) {
            log.warn("JWT claims string is empty");
        }
        return false;
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }
}
