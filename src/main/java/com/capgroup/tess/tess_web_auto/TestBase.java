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
        logger.info("OS property value is " +System.getProperty("os.name").toLowerCase());
        if(browser.equals("local_chrome")) {
            logger.info("This will run before the Scenario: " + browser);

        if(System.getProperty("os.name").toLowerCase().contains("windows"))
            System.setProperty("webdriver.chrome.driver", "drivers/chromedriver.exe");
        else
            System.setProperty("webdriver.chrome.driver", "drivers/chromedriver");
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
