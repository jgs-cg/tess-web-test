package com.capgroup.tess.tess_web_auto;

import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;
import org.testng.annotations.DataProvider;


@CucumberOptions(features = "src/test/resources/features",
        tags = "@SmokeTest",
        glue = "com.capgroup.tess.tess_web_auto.step_defination",
        plugin = {
                "json:target/cucumber-json-testng-report.json",
                "junit:target/cucumber-json-testng-report.xml"},
        strict = true)
public class RunCucumberTestNgTest extends AbstractTestNGCucumberTests {

        @Override
        @DataProvider(parallel = false)
        public Object[][] scenarios() {
                return super.scenarios();
        }
}
