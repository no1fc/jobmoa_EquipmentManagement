package com.jobmoa.equipment.config;

import com.jobmoa.equipment.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Slf4j
@Component
@ConditionalOnProperty(name = "seed.test-data", havingValue = "true")
@RequiredArgsConstructor
public class TestDataInitializer implements CommandLineRunner {

    private final DataSource dataSource;
    private final UserRepository userRepository;

    @Override
    public void run(String... args) {
        if (userRepository.count() > 1) {
            log.info("테스트 데이터가 이미 존재합니다. 초기화를 건너뜁니다.");
            return;
        }

        log.info("테스트 데이터를 삽입합니다...");
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScript(new ClassPathResource("sql/V009__seed_test_data.sql"));
        populator.setSeparator(";");
        populator.execute(dataSource);
        log.info("테스트 데이터 삽입 완료: 사용자 5명, 장비 20개, 대여 10건, 알림 12건");
    }
}
