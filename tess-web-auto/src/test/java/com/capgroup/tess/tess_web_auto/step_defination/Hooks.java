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


@SpringBootTest(classes = SpringBootTest.class)
@ContextConfiguration(classes = SpringConfig.class)
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


        System.setProperty("webdriver.chrome.driver", "C:/Users/jgs/Downloads/tess-web-auto/drivers/chromedriver.exe");

        ChromeOptions options = new ChromeOptions();
        options.addArguments("start-maximized");
        options.addArguments("disable-impl-side-painting");
        RemoteWebDriver driver = new ChromeDriver(options);

        driver.get(url);
        return driver;
    }


}

