# How-to-do-FEV-Analysis
This page is intended for the general public. It provides a step by step guide on how to repeat the work completed in this repository for any river and location in the UK of your choice. 

## 1. Download Anaconda for free to get access to Spyder
Spyder is an open source data handling programme which uses Python language. https://www.anaconda.com/distribution/

## 2. Pick a flood
This could be a flood event which affected you or one which you saw in the news. Take note of the month and year that this flood took place in. 

## 3.Pick a location
Once you've determined the flood event you're interested in, you need to know which City/Town/Village you're interested in studying. 
You then need to pick a river monitoring station. This would ideally be close to your location of interest. Here is a map of the river monitoring stations in the UK. https://flood-warning-information.service.gov.uk/river-and-sea-levels

## 4. Request Data from Envrionmental Agency
You can request and obtain the height and flow data from UK river monitoring stations under the Freedom of Information Act 2000 and should recieve a response within 20 working days.

Send an email to enquiries@environment-agency.gov.uk specifying the following:
* The date range of the flood event
* The monitoring station
* Height (also known as stage) data with time
* Flow (also known as discharge) data with time
* The most recent rating curve report for this monitoring station (This will give you a function which allows you to calculate flow from height)
* A threshold height (the height of the river above which flooding occurs)

NOTE: rating curve report and threshold height may not be available. Why? 
* Some montioring stations measure flow directly and hence do not have an equation to calculate it.
* We're not sure why the threshold height isn't always availble. One of us was told that we'd have to pay for it. See later for ways you can estimate the threshold height for free.

## 5.Format Raw Data
You should recieve your data in the form of a csv. file. This can be opened, viewed and manipulated in Excel. 

Data is normally sent for a longer time period than your flood. The first thing to do is find the range of dates you want to study. From our experience, this is 4-7 days. We reccomend starting and ending with a 00:00:00 timestamp. 

Open your STAGE data in excel and select all occupied columns for your chosen time range and copy them. Open a new excel sheet and paste this data into it. Have a quick scroll down the whole data range (there are sometimes interesting comments to take note of). Delete all columns apart from the stage and time and title them "Stage" and "Time"

Open your FLOW data in excel select all occupied columns for your chosen time range and copy them. Open your new excel sheet and paste this data into it. Have a quick scroll down the whole data range (there are sometimes interesting comments to take note of). Delete all  new columns apart from the flow and time and title them "Flow" and "Time".

Check that each column has the same number of rows. This will confirm that you are not missing any data points.

You need to convert your 15 minute timestamp into a fraction of a day. Delete one "Time" column. Insert a new column and call it "Day". In the first row of the table (below the header-row) enter "0". In the row below put "= Cell Location + 15/(60 * 24)" e.g if cell B2=0, then for B3 put "=B2+15/(60 * 24)". Select and drag this function until all your timestamped cells have a corresponding day number. 

Make sure that the first row is a header-row with each column having a different title.

Create a folder named "River" and save your xlsx in there with a name which includes the River, the Station, the Month and Year of flooding e.g River_Aire_Armley_Dec2015.xlsx. Now re-save your file as a csv. e.g River_Aire_Armley_Dec2015.csv.

## 6. Processing your Formatted Data





