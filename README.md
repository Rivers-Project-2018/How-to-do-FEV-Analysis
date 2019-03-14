# How to do FEV Analysis
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

```Bash
##Imput your own data here:
#Your chosen threshold height.
ht=3.9

#The number of days you are looking at:
number_of_days=5

#Your rating curve coeffecients, listed starting from those corresponding to
#the lowest range of heights up until the heighest range.
a=[0.156,0.028,0.153]
b=[1.115,1.462,1.502]
c=[30.69,27.884,30.127]

#The upper and lower limits of the ranges of the river heights given for your
#rating curve.
lower_limits=[0.2,0.685,1.917]
upper_limits=[0.685,1.917,4.17]

#The increments of time your river height data is given in, converted into
#seconds; e.g. 15 minute increments = 900 second increments.
time_increment=900

#You do not have to change the following.
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import bisect
plt.rcParams["figure.figsize"] = [11,8]
plt.rcParams['axes.edgecolor']='white'
fig, ax = plt.subplots()

#Import your data, your river height data must be saved into a csv file
#(we are using the file 'Aire Data.csv' but you must change what your csv file 
#is saved as) within the same folder as this code is saved. The first column must have the 
#heading 'Time', with time values converted into days (with the digits beyond the
#decimal point representing what the hours and seconds elapsed are in terms of a
#fraction of a day, and the second column must have the heading 'Height'.
Data=pd.read_csv('Aire Data.csv')
time=Data['Time']
height=Data['Height']

##You do not have to change the following.
def scale(x):
    return ((x-min(x))/(max(x)-min(x)))
scaledtime=scale(time)
scaledheight=scale(height)

HM = []
for i in height:
    if i>=ht:
        HM.append(i)
hm=sum(HM)/len(HM)

#If your rating curve has 3 ranges of river heights, then you do not have to change this. If
#,however, your rating curve has 2 ranges, then delete the 3rd line starting with
#elif, and the line below it, and replace upper_limits[1] with max(height).
#Reapeat this if you only have 1 range. If you have more than 3 ranges, replace 
#replace max height with upper_limits[2] and write: elif x<=max(height) and x>lower_limits[3]
#y = (c[3]*((x-a[3])**b[3])), below the line below that line. Continue on the same 
#vein if your rating curve has even more ranges.
def Q(x):
    if x<=upper_limits[0] and x>lower_limits[0]:
        y = (c[0]*((x-a[0])**b[0]))
    elif x<=upper_limits[1] and x>lower_limits[1]:
        y = (c[1]*((x-a[1])**b[1]))
    elif x<=max(height) and x>lower_limits[2]:
        y = (c[2]*((x-a[2])**b[2]))
    return(y)  

#You do not have to change the following.
qt = Q(ht)     
    
Flow = []
for i in height:
    Flow.append(Q(i))

scaledFlow = []
for i in Flow:
    scaledFlow.append((i-min(Flow))/(max(Flow)-min(Flow)))

negheight=-scaledheight
negday=-(scaledtime)

ax.plot(negheight,scaledFlow,'black',linewidth=2)
ax.plot([0,-1],[0,1],'grey',linestyle='--',marker='',linewidth=2)

ax.plot(scaledtime, scaledFlow,'black',linewidth=2)
ax.plot(negheight, negday,'black',linewidth=2)

scaledht = (ht-min(height))/(max(height)-min(height))
scaledhm = (hm-min(height))/(max(height)-min(height))
scaledqt = (qt-min(Flow))/(max(Flow)-min(Flow))

QT=[]
for i in scaledFlow:
    i = scaledqt
    QT.append(i)

d=np.array(scaledFlow)
e=np.array(QT)
    
ax.fill_between(scaledtime,d,e,where=d>=e,facecolor='gray')

idx = np.argwhere(np.diff(np.sign(d - e))).flatten()

f=scaledtime[idx[0]]
g=scaledtime[idx[-1]]

def unscaletime(x):
    return (((max(time)-min(time))*x)+min(time))

c=unscaletime(f)
d=unscaletime(g)

Tf=(d-c)*24

flow = []
for i in Flow:
    if i>=qt:
        flow.append((i-qt)*(time_increment))

FEV=sum(flow)

Tfs=Tf*(60**2)

qm=(FEV/Tfs)+qt

scaledqm = (qm-min(Flow))/(max(Flow)-min(Flow))

ax.plot([-scaledht,-scaledht],[-1,scaledqt],'black',linestyle='--',linewidth=1)
ax.plot([-scaledhm,-scaledhm],[-1,scaledqm],'black',linestyle='--',linewidth=1)
ax.plot([-scaledht,1],[scaledqt,scaledqt],'black',linestyle='--',linewidth=1)
ax.plot([-scaledhm,1],[scaledqm,scaledqm],'black',linestyle='--',linewidth=1)

ax.plot([f,f,f],[scaledqt,scaledqm,-1/5], 'black', linestyle='--', linewidth=1)
ax.plot([g,g,g],[scaledqt,scaledqm,-1/5], 'black', linestyle='--', linewidth=1)
ax.plot([f,f],[scaledqm,scaledqt], 'black',linewidth=1.5)
ax.plot([f,g],[scaledqm,scaledqm], 'black',linewidth=1.5)
ax.plot([f,g],[scaledqt,scaledqt], 'black',linewidth=1.5)
ax.plot([g,g],[scaledqm,scaledqt], 'black',linewidth=1.5)
plt.annotate(s='', xy=(f-1/100,-1/5), xytext=(g+1/100,-1/5), arrowprops=dict(arrowstyle='<->'))

h=[]
for i in range(1,number_of_days+1):
    h.append(i/number_of_days)

l=np.arange(0,max(Flow)+50,50)
m=bisect.bisect(l,min(Flow))

n=[]
for i in np.arange(l[m],max(Flow)+50,50):
    n.append(i)


o=np.arange(0,max(height)+0.5,0.5)
p=bisect.bisect(o,min(height))

q=[]
for i in np.arange(o[p],max(height)+0.5,0.5):
    q.append(i)

k=[]
for i in q:
    k.append(-(i-min(height))/(max(height)-min(height))) 

j=[]
for i in n:
    j.append((i-min(Flow))/(max(Flow)-min(Flow)))

ticks_x=k+h

r=[]
for i in h:
    r.append(-i)

ticks_y=r+j


s=[]
for i in np.arange(1,number_of_days+1):
    s.append(i)

Ticks_x=q+s
Ticks_y=s+n
    
ax.set_xticks(ticks_x)
ax.set_yticks(ticks_y)
ax.set_xticklabels(Ticks_x)
ax.set_yticklabels(Ticks_y)

ax.spines['left'].set_position(('center'))
ax.spines['bottom'].set_position(('center'))
ax.spines['left'].set_color('black')
ax.spines['bottom'].set_color('black')
ax.tick_params(axis='x',colors='black',direction='out',length=9,width=1)
ax.tick_params(axis='y',colors='black',direction='out',length=10,width=1)

plt.text(-scaledht+1/100, -1,'$h_T$', size=13)
plt.text(-scaledhm+1/100, -1,'$h_m$', size=13)
plt.text(1, scaledqm,'$Q_m$', size=13)
plt.text(1, scaledqt,'$Q_T$', size=13)
plt.text(((f+g)/2)-1/50,-0.18,'$T_f$',size=13)

plt.text(0.01, 1.05,'$Q$ [m$^3$/s]', size=13)
plt.text(0.95, -0.17,'$t$ [day]', size=13)
plt.text(0.01, -1.09,'$t$ [day]', size=13)
plt.text(-1.1, 0.02,'$\overline {h}$ [m]', size=13)

print(FEV)
print(Tf)
print(ht)
print(hm)
print(qt)
print(qm)

#You would now run the file and type in your own values for FEV, Tf, ht,hm, qt
#and qm (listed in the order they appear in the libes above). The value inputted here are for the exmaple aire data
plt.text(0.4,-0.4,'$FEV$ ≈ 9.34Mm$^3$', size=15)
plt.text(0.4,-0.475,'$T_f$ = 32.00hrs', size=15)
plt.text(0.4,-0.55,'$h_T$ = 3.90m', size=15)
plt.text(0.4,-0.625,'$h_m$ = 4.77m', size=15)
plt.text(0.4,-0.7,'$Q_T$ = 219.1m$^3$/s', size=15)
plt.text(0.4,-0.775,'$Q_m$ = 300.2m$^3$/s', size=15)
```
<p align="center">
  <img width="700" height="800" src="https://github.com/Rivers-Project-2018/How-to-do-FEV-Analysis/blob/master/Automated-Quadrant_Graph.png">
   <figcaption>Figure 1: The plot produced by the automated code; the top left displays the computed values of FEV, Tf, ht, hm, qt and qm in that order.</figcaption>
</p>



