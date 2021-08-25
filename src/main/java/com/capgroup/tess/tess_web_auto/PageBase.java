package com.capgroup.tess.tess_web_auto;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.io.FileUtils;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.*;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;



import java.util.List;
import java.util.concurrent.TimeUnit;


public class PageBase {

    private static final Logger logger = LogManager.getLogger();
    protected final WebDriver driver;



    public PageBase(WebDriver driver) {
        this.driver = driver;
        PageFactory.initElements(driver, this);
        waitTillPageHasBeenFullyLoaded();

    }

    public void waitTillPageHasBeenFullyLoaded() {
        ExpectedCondition<Boolean> pageLoadCondition = driver -> ((JavascriptExecutor) driver).executeScript("return document.readyState").equals("complete");
        WebDriverWait wait = new WebDriverWait(driver, 300);
        wait.until(pageLoadCondition);

        logger.info("Page Loaded...");
    }

    public WebElement waitWebElementToBeVisible(WebElement element) {
        return (new WebDriverWait(driver, 60)).until(ExpectedConditions.visibilityOf(element));
    }

    public List<WebElement> waitListWebElementsToBeVisible(List<WebElement> elements) {

        return (new WebDriverWait(driver, 30)).until(ExpectedConditions.visibilityOfAllElements(elements));
    }

    public WebElement waitWebElementToBeClickable(WebElement element) {

        return (new WebDriverWait(driver, 30)).until(ExpectedConditions.elementToBeClickable(element));
    }

    public String getCurrentUrl()
    {
        waitTillPageHasBeenFullyLoaded();
        driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
        return driver.getCurrentUrl();
    }

}
