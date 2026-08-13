from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service as ChromeService
import time
from selenium.webdriver.common.by import By
import csv

driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
driver.get("https://www.naukri.com/")
time.sleep(2)

# Search inputs
designation = driver.find_element(By.XPATH, "//input[@placeholder='Enter skills / designations / companies']")
designation.send_keys("Data Analysis")

experience_box = driver.find_element(By.XPATH, "//input[@placeholder='Select experience']")
experience_box.send_keys("fresher")

location = driver.find_element(By.XPATH, "//input[@placeholder='Enter location']")
location.send_ke ys("pune")

time.sleep(2)
driver.find_element(By.XPATH, "//div[@class='qsbSubmit']").click()
time.sleep(5)

# Scraping elements
titles = driver.find_elements(
    By.XPATH,
    "//a[contains(@class,'title')]"
)

companies = driver.find_elements(
    By.XPATH,
    "//a[contains(@class,'comp-name')]"
)

experiences = driver.find_elements(
    By.XPATH,
    "//span[contains(@class,'expwdth')]"
)

# Writing to CSV
with open("naukri_jobs.csv", "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["Job Title", "Company", "Experience"])

    for i in range(min(len(titles), len(companies), len(experiences))):
        writer.writerow([
            titles[i].text.strip(),
            companies[i].text.strip(),
            experiences[i].text.strip()
        ])

print("✅ Data saved to naukri_jobs.csv")

driver.quit()   

