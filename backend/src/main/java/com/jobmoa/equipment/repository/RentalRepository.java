package com.jobmoa.equipment.repository;

import com.jobmoa.equipment.domain.rental.Rental;
import com.jobmoa.equipment.domain.rental.RentalStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface RentalRepository extends JpaRepository<Rental, Long> {

    @Query("""
        SELECT r FROM Rental r
        JOIN FETCH r.asset
        JOIN FETCH r.borrower
        WHERE (:status IS NULL OR r.status = :status)
        AND (:borrowerId IS NULL OR r.borrower.userId = :borrowerId)
        AND (:assetId IS NULL OR r.asset.assetId = :assetId)
        """)
    Page<Rental> findAllWithFilters(
        @Param("status") RentalStatus status,
        @Param("borrowerId") Long borrowerId,
        @Param("assetId") Long assetId,
        Pageable pageable
    );

    @Query("SELECT r FROM Rental r JOIN FETCH r.asset JOIN FETCH r.borrower WHERE r.status = 'OVERDUE'")
    List<Rental> findAllOverdue();

    @Query("""
        SELECT r FROM Rental r
        JOIN FETCH r.asset JOIN FETCH r.borrower
        WHERE r.status = 'RENTED'
        AND r.dueDate < :now
        """)
    List<Rental> findRentedPastDue(@Param("now") LocalDateTime now);

    @Query("""
        SELECT r FROM Rental r
        JOIN FETCH r.asset JOIN FETCH r.borrower
        WHERE r.asset.assetId = :assetId
        ORDER BY r.rentalDate DESC
        """)
    List<Rental> findByAssetId(@Param("assetId") Long assetId);

    long countByStatus(RentalStatus status);

    @Query("SELECT COUNT(r) FROM Rental r WHERE r.status = 'RENTED' AND r.dueDate BETWEEN :start AND :end")
    long countDueSoon(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT COUNT(r) FROM Rental r WHERE r.status = 'RETURNED' AND r.returnDate >= :today")
    long countReturnedToday(@Param("today") LocalDateTime today);
}
