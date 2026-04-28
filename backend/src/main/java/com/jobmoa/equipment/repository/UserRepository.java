package com.jobmoa.equipment.repository;

import com.jobmoa.equipment.domain.user.Role;
import com.jobmoa.equipment.domain.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query("""
        SELECT u FROM User u
        WHERE u.isActive = true
        AND (:role IS NULL OR u.role = :role)
        AND (:search IS NULL OR u.name LIKE %:search% OR u.email LIKE %:search%)
        """)
    Page<User> findAllWithFilters(
        @Param("role") Role role,
        @Param("search") String search,
        Pageable pageable
    );
}
