package com.capgroup.tess.tess_web_auto;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Parameters;

public class TestBase {

    private static final Logger logger = LogManager.getLogger();
    private WebDriver driver;

    @Parameters({"browser"})
    @BeforeClass
    public void setUp(String browser) {
        if(browser.equals("local_chrome")) {
            logger.info("This will run before the Scenario: " + browser);
            System.setProperty("webdriver.chrome.driver", "drivers/chromedriver.exe");
            driver = new ChromeDriver();
        }
    }

    @AfterClass
    public void tearDown() {

        if (driver != null) {

            driver.close();
        }
    }

}
