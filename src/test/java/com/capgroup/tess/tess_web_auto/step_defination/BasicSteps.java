package com.capgroup.tess.tess_web_auto.step_defination;

import com.capgroup.tess.tess_web_auto.PageBase;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.springframework.data.domain.Page;

public class BasicSteps {
    protected static final Logger logger = LogManager.getLogger();
    protected static String browser_name;
    protected static String scenarioName;
    protected static WebDriver driver;
}
