package com.capgroup.tess.tess_web_auto.pageobjects;

import com.capgroup.tess.tess_web_auto.PageBase;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class LandingPage extends PageBase {
    public LandingPage(WebDriver driver) {
        super(driver);
    }

    //@FindBy(xpath = "//div[contains(@class, 'v-card') and contains(text(),'Services')]")
    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[1]/div/div[1]/div/a/span/i")

    private WebElement servicesTile;

    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[2]/div/div[1]/div/a/span/i")
    private WebElement cicdTile;

    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[3]/div/div[1]/div/a/span/i")
    private WebElement qTestIntTile;

    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[4]/div/div[1]/div/a/span/i")
    private WebElement frameworkTile;

    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[5]/div/div[1]/div/a/span/i")
    private WebElement implementationsTile;

    @FindBy(xpath = "//*[@id=\"app\"]/div/main/div/div/div/section[2]/div/div/div/div[6]/div/div[1]/div/a/span/i")
    private WebElement bestPracticesTile;

    @FindBy(xpath = "//div[contains(@class,'white--text') and contains(text(),'Home')]")
    private WebElement homeButton;

    @FindBy(xpath = "//*[@id=\"logo\"]/a/span")
    public WebElement confluenceElement;



    public WebElement getHomeButton() {return waitWebElementToBeVisible(homeButton); }

    public WebElement getServicesTile() {
        return waitWebElementToBeVisible(servicesTile);
    }

    public WebElement getcicdTile() {
        return waitWebElementToBeVisible(cicdTile);
    }

    public WebElement getqTestIntTile() {
        return waitWebElementToBeVisible(qTestIntTile);
    }

    public WebElement getFrameworkTile() { return waitWebElementToBeVisible(frameworkTile); }

    public WebElement getImplementationsTile() { return waitWebElementToBeVisible(implementationsTile); }

    public WebElement getBestPracticesTile() {return waitWebElementToBeVisible(bestPracticesTile); }

    public WebElement getConfluenceLink() { return waitWebElementToBeVisible(confluenceElement); }




    public LandingPage clickHomeButton() {
        getHomeButton().click();
        return new LandingPage(driver);
    }

    public LandingPage clickServicesTile() {
        getServicesTile().click();
        return new LandingPage(driver);
    }

    public LandingPage clickCicdTile() {
        getcicdTile().click();
        return new LandingPage(driver);
    }

    public LandingPage clickQTestIntTile() {
        getqTestIntTile().click();
        return new LandingPage(driver);
    }

    public LandingPage clickFrameworkTile() {
        getFrameworkTile().click();
        return new LandingPage(driver);
    }

    public LandingPage clickmplementationsTile() {
        getImplementationsTile().click();
        return new LandingPage(driver);
    }

    public LandingPage clickBestPracticesTile() {
        getBestPracticesTile().click();
        return new LandingPage(driver);
    }
}
