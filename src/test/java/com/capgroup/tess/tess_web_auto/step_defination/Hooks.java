package com.capgroup.tess.tess_web_auto.step_defination;

import com.capgroup.tess.tess_web_auto.config.SpringConfig;
import io.cucumber.java8.En;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ContextConfiguration;


//@SpringBootTest(classes = SpringBootTest.class)
//@ContextConfiguration(classes = SpringConfig.class)
public class Hooks extends BasicSteps implements En {

    public WebDriver getDriver(String browser, String url) {


        DesiredCapabilities caps = new DesiredCapabilities();
        String needVideo = System.getProperty("video", "true");
        String recordNetwork = System.getProperty("network", "false");

        logger.info(browser);
        browser_name = browser;

        caps.setCapability("name", scenarioName + " for " + browser);
        caps.setCapability("build", "3.0");
        caps.setCapability("record_video", needVideo);
        caps.setCapability("record_network", recordNetwork);

        logger.info("OS property value is " +System.getProperty("os.name").toLowerCase());
        if(System.getProperty("os.name").toLowerCase().contains("windows"))
            System.setProperty("webdriver.chrome.driver", "drivers/chromedriver.exe");
        else
            System.setProperty("webdriver.chrome.driver", "drivers/chromedriver");

        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless");
        options.addArguments("window-size=1400,1500");
        options.addArguments("--disable-gpu");
        options.addArguments("--no-sandbox");
        options.addArguments("start-maximized");
        options.addArguments("enable-automation");
        options.addArguments("--disable-infobars");
        options.addArguments("--disable-dev-shm-usage");
        RemoteWebDriver driver = new ChromeDriver(options);
        driver.get(url);
        return driver;
    }


}

