package com.jobmoa.equipment;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect",
    "jwt.secret=test-jwt-secret-key-that-is-at-least-256-bits-long-for-hs256-algorithm",
    "jwt.access-expiration=1800000",
    "jwt.refresh-expiration=604800000"
})
class EquipmentManagementApplicationTests {

    @Test
    void contextLoads() {
    }
}
