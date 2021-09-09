package com.capgroup.tess.tess_web_auto.step_defination;

import com.capgroup.tess.tess_web_auto.config.SpringConfig;
import com.capgroup.tess.tess_web_auto.pageobjects.LandingPage;
import io.cucumber.java8.En;

import io.cucumber.spring.CucumberContextConfiguration;
import io.cucumber.spring.CucumberTestContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Scope;
import org.testng.Assert;
import java.util.ArrayList;


@CucumberContextConfiguration
@Scope(CucumberTestContext.SCOPE_CUCUMBER_GLUE)
@SpringBootTest(classes = SpringConfig.class)
public class LandingPageService implements En {
    private static final Logger logger = LogManager.getLogger();

    @Value("${web.tess-site-url}")
    public String baseUrl;
    private Hooks hooks;
    private final String browser="local_chrome";

    public WebDriver driver;
    public LandingPage landingPage;



    public LandingPageService() {
        Before(()-> {
            logger.info("Initializing the hooks and the selenium chrome driver");
            hooks = new Hooks();
            driver = hooks.getDriver(browser, baseUrl);
            landingPage=new LandingPage(driver);
            landingPage.clickHomeButton();

        });
        After(()-> {
            logger.info("Closing the driver after feature run");
            driver.quit();
        });



        Given("^I click on \"([^\"]*)\" tile from tess website home page$", (String tile) -> {
            logger.info("Executing Given Expression with tile: "+tile);
            switch (tile.toLowerCase())
            {
                case "services":
                    landingPage.clickServicesTile();
                    break;
                case "cicd":
                    landingPage.clickCicdTile();
                    break;
                case "qtest":
                    landingPage.clickQTestIntTile();
                    break;
                case "frameworks":
                    landingPage.clickFrameworkTile();
                    break;
                case "implementations":
                    landingPage.clickmplementationsTile();
                    break;
                case "bestpractices":
                    landingPage.clickBestPracticesTile();
                    break;
            }

        });

        Then("^I validate the tile nagivates me to the correct confluence \"([^\"]*)\" page url \"([^\"]*)\"$", ( String onConfluence,String expectedURL) -> {
            logger.info("Executing the Then Expression with expected URL: " + expectedURL);
            String actualURL;
            if(onConfluence.equalsIgnoreCase("true"))
            {
                ArrayList<String> windowTabs = new ArrayList<String> (driver.getWindowHandles());
                logger.info("Number of windows tables equals : " + windowTabs.size());
                driver.switchTo().window(windowTabs.get(1));        
                logger.info("Number of windows tables equals : " + windowTabs.size());
                //landingPage.getConfluenceLink();
            }
            else
            {
                expectedURL = baseUrl+  expectedURL;
            }
                
            logger.info("Getting the current URL");
            actualURL = landingPage.getCurrentUrl();
            logger.info("expected result is : " + expectedURL);
            logger.info("actual result is : " + actualURL);
            Assert.assertTrue(actualURL.contains(expectedURL),"ExpectedURL doesn't match the ActualURL");
        });

    }
}
