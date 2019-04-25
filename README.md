# How to do FEV Analysis
This page is intended for the general public. It provides a step by step guide on how to repeat the work completed in this repository for any river and location in the UK of your choice. 

## 1. Download Anaconda for free to get access to Spyder or RStudio
Spyder is an open source data handling programme which uses Python language. RStudio is similar to Spyder in that it is also an open source programme. RStudio uses R programming language. https://www.anaconda.com/distribution/

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

NOTE: if you are not given rating curve coefficients, but you are given the height data for your chosen river you could simply remove the rating curve section of the code and use the data given to construct your graph and FEV.

### 6.1 For Spyder

```Bash
##Imput your own data here:##
#Your chosen threshold height.
ht=3.9

#Your rating curve coeffecients, listed starting from those corresponding to
#the lowest range of heights up until the heighest range.
a=[0.156,0.028,0.153]
b=[1.115,1.462,1.502]
c=[30.69,27.884,30.127]

#The upper and lower limits of the ranges of the river heights given for your
#rating curve.
lower_limits=[0.2,0.685,1.917]
upper_limits=[0.685,1.917,4.17]

#You do not have to change the following.
import matplotlib.pyplot as plt
import pandas as pd
fig, ax = plt.subplots()

#Import your data, your river height data must be saved into a csv file
#(we are using the file 'Aire Data.csv' but you must change what your csv file 
#is saved as) within the same folder as this code is saved. The first column must have the 
#heading 'Time', with time values converted into days (with the digits beyond the
#decimal point representing what the hours and seconds elapsed are in terms of a
#fraction of a day, more information on how to do this can be found at 
#https://github.com/Rivers-Project-2018/How-to-do-FEV-Analysis/blob/master/README.md) 
#and the second column must have the heading 'Height'.
Data=pd.read_csv('Aire Data.csv')
time=Data['Time']
height=Data['Height']

#####You do not have to change any of the rest of the code.#####
#But if you wish to change elements such as the colour or the x and y axis
#there are instructions on how to do so.
import bisect
import numpy as np

plt.rcParams["figure.figsize"] = [11,8]
plt.rcParams['axes.edgecolor']='white'
ax.spines['left'].set_position(('center'))
ax.spines['bottom'].set_position(('center'))
ax.spines['left'].set_color('black')
ax.spines['bottom'].set_color('black')

time_increment=(time[1]-time[0])*24*3600

number_of_days=int((len(time)*(time[1]-time[0])))

def scale(x):
    return ((x-min(x))/(max(x)-min(x)))
scaledtime=scale(time)
scaledheight=scale(height)

w=[]
for i in range(len(a)):
    w.append(i)

def Q(x):
    z=0
    while z<w[-1]:
        if x>lower_limits[z] and x<=upper_limits[z]:
            y = (c[z]*((x-a[z])**b[z]))
            break
        elif x>upper_limits[z]:
            z = z+1
    else:
        y = (c[w[-1]]*((x-a[w[-1]])**b[w[-1]]))
    return(y)

qt = Q(ht)     
    
Flow = []
for i in height:
    Flow.append(Q(i))

scaledFlow = []
for i in Flow:
    scaledFlow.append((i-min(Flow))/(max(Flow)-min(Flow)))

negheight=-scaledheight
negday=-(scaledtime)

#To change the colour, change 'conrflowerblue' to another colour such as 'pink'.
ax.plot(negheight,scaledFlow,'black',linewidth=2)
ax.plot([0,-1],[0,1],'cornflowerblue',linestyle='--',marker='',linewidth=2)
ax.plot(scaledtime, scaledFlow,'black',linewidth=2)
ax.plot(negheight, negday,'black',linewidth=2)

scaledht = (ht-min(height))/(max(height)-min(height))
scaledqt = (qt-min(Flow))/(max(Flow)-min(Flow))

QT=[]
for i in scaledFlow:
    i = scaledqt
    QT.append(i)

SF=np.array(scaledFlow)
e=np.array(QT)
    
ax.fill_between(scaledtime,SF,e,where=SF>=e,facecolor='cornflowerblue')

idx = np.argwhere(np.diff(np.sign(SF - e))).flatten()

f=scaledtime[idx[0]]
g=scaledtime[idx[-1]]

def unscaletime(x):
    return (((max(time)-min(time))*x)+min(time))

C=unscaletime(f)
d=unscaletime(g)

Tf=(d-C)*24

time_increment=(time[1]-time[0])*24*3600

flow = []
for i in Flow:
    if i>=qt:
        flow.append((i-qt)*(time_increment))

FEV=sum(flow)

Tfs=Tf*(60**2)

qm=(FEV/Tfs)+qt
scaledqm = (qm-min(Flow))/(max(Flow)-min(Flow))

hm=((qm/c[-1])**(1/b[-1]))+a[-1]
scaledhm = (hm-min(height))/(max(height)-min(height))

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
for i in np.arange(1,number_of_days+1):
    h.append(i/number_of_days)

#If you wish to set the flow to be shown on the axis by a certain increment, change all 
#appearances of 50 in lines 153 and 157 to the desired increment, e.g 25 or 100.
#Otherwise leave as is.
l=np.arange(0,max(Flow)+50,50)
m=bisect.bisect(l,min(Flow))

n=[]
for i in np.arange(l[m],max(Flow)+50,50):
    n.append(int(i))

#If you wish to set the height to be shown on the axis by a certain increment, change all 
#appearances of 1 in lines 163 and 167 to the desired increment, e.g 0.25 or 0.5.
#Otherwise leave as is.
o=np.arange(0,max(height)+1,1)
p=bisect.bisect(o,min(height))

q=[]
for i in np.arange(o[p],max(height)+1,1):
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

ax.scatter(0,0,color='white')

A=round(FEV/(10**6),2)
B=round(Tf,2)
C=round(ht,2)
D=round(hm,2)
E=round(qt,2)
F=round(qm,2)

plt.text(0.4,-0.4,'$FEV$ ≈ '+ str(A) +'Mm$^3$', size=15)
plt.text(0.4,-0.475,'$T_f$ = '+ str(B) +'hrs', size=15)
plt.text(0.4,-0.55,'$h_T$ = '+ str(C) +'m', size=15)
plt.text(0.4,-0.625,'$h_m$ = '+ str(D) +'m', size=15)
plt.text(0.4,-0.7,'$Q_T$ = '+ str(E) +'m$^3$/s', size=15)
plt.text(0.4,-0.775,'$Q_m$ = '+ str(F) +'m$^3$/s', size=15)

from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=plt.figaspect(1)*0.7)
ax = Axes3D(fig)
plt.rcParams['axes.edgecolor']='white'
plt.rcParams["figure.figsize"] = [10,8]

ax.grid(False)
ax.xaxis.pane.fill = False
ax.yaxis.pane.fill = False
ax.zaxis.pane.fill = False

ax.xaxis.pane.set_edgecolor('w')
ax.yaxis.pane.set_edgecolor('w')
ax.zaxis.pane.set_edgecolor('w')

sl = (FEV/2)**0.5

a = [sl, sl]
b = [sl, sl]
c = [2, 0]

d = [sl, 0]
e = [sl, sl]
f = [0, 0]

g = [sl, sl]
h = [sl, 0]
i = [0, 0]

ax.plot(a, b, c, '--', color = 'k')
ax.plot(d, e, f, '--', color = 'k')
ax.plot(g, h, i, '--', color = 'k')

x = [sl, sl, sl, 0, 0, 0, sl, sl, 0, 0, 0, 0]
y = [sl, 0, 0, 0, 0, sl, sl, 0, 0, 0, sl, sl]
z = [2, 2, 0, 0, 2, 2, 2, 2, 2, 0, 0, 2]

ax.plot(x, y, z, color = 'k')

ax.text(5*(sl/9), -5*(sl/9), 0, 'Side-length [m]', size=13)
ax.text(-sl/4, sl/4, 0, 'Side-length [m]', size=13)
ax.text(-0.02*sl, 1.01*sl, 0.8, 'Depth [m]',size=13)

ax.text(7*(sl/10), 5*(sl/4), 1, ''+str(int(round(sl)))+'m', size=13)
ax.text(14*(sl/10), 6*(sl/10), 1, ''+str(int(round(sl)))+'m', size=13)

ax.set_zticks([0, 2])

ax.set_xlim(sl,0)
ax.set_ylim(0,sl)
ax.set_zlim(0,10)
```
<p align="center">
  <img width="700" height="1000" src="https://github.com/Rivers-Project-2018/How-to-do-FEV-Analysis/blob/master/Automated-Graph-Aire.png">
   <figcaption>Figure 1: The plot produced by the automated code; the top left displays the computed values of FEV, Tf, ht, hm, qt and qm in that order.</figcaption>
</p>

### 6.2 For RStudio

In the R code below, the sum((Q>Q<sub>t</sub>) - Q<sub>t</sub>) x Δt approximation for FEV has been used [1]. This is evidenced by the five lines of code under the # FEV calculation comment.

```Bash
# The following is based on the Aire graph presented on [1].

# Import the data required; in RStudio the import can be made by
# clicking the file needed and selecting Import Dataset when the drop down tab appears

library(readxl)
River_Aire_Data <- read_excel("Desktop/University_of_Leeds/Project/ArmleyF1707Stage_and_Flow15min_25Decto30Dec.xlsx")
# edited [2][3]

# simplifying column names
t=River_Aire_Data$Time 
Q=River_Aire_Data$Flow
h=River_Aire_Data$Height

library(readxl)
Rating_Curves <- read_excel("Desktop/University_of_Leeds/Project/Rating Curves.xlsx", 
                            sheet = "Sheet2", col_types = c("numeric", 
                                                            "numeric", "numeric", "numeric", 
                                                            "numeric", "skip", "skip", "skip", 
                                                            "skip", "skip", "skip", "skip", 
                                                            "skip", "skip", "skip"))
# [4]

AireC=Rating_Curves$Aire_C # simplifying Rating Curve data names
Airea=Rating_Curves$Aire_a
Aireb=Rating_Curves$Aire_b

hA=seq(from=0.16, to=6, by=0.01)
# Creating a new height matrix/vector - suggested by Supervisor [5].
# Found in RStudio help section.

# Creating a new discharge matrix for the rating curve [5][6].
QA=matrix(nrow=585, ncol=1)

for(i in 1:585) { 
  if(hA[i]<0.685) QA[i]=AireC[1]*(hA[i]-Airea[1])^Aireb[1]
  if(0.685<=hA[i] & hA[i]<1.917) QA[i]=AireC[2]*(hA[i]-Airea[2])^Aireb[2]
  if(1.917<=hA[i]) QA[i]=AireC[3]*(hA[i]-Airea[3])^Aireb[3]
  ## To imput the data into the QA matrix; notified of for loop by [7, p.470].
}

ht=3.9 # able to change and Qt will automatically change
Qt=AireC[3]*(ht-Airea[3])^Aireb[3]
hm=4.77 # able to change and Qm will automatically change
Qm=AireC[3]*(hm-Airea[3])^Aireb[3]

# FEV Calculation
deltk=900 # 15 minutes in seconds [8].
# Notified of which function by supervisor [8].
# Looked at RStudio help section for structure.
QfFEV=Q[which(Q>Qt)]
FEVA=sum(QfFEV-Qt)*deltk # FEV for the Aire

# to automate the code
tf_sc=t_sc[which(Q>Qt)]
tfscl=length(tf_sc)
Qf_sc=Q_sc[which(Q>Qt)]

t_min=min(t) # Setting the min and max points for t, h, Q
t_max=max(t)
h_min=0
h_max=6
Q_min=0
Q_max=350
QA_min=0
QA_max=350

t_sc=(t-t_min)/(t_max-t_min) # Creating the scaled vectors of t, h, Q; [9].
h_sc=(h-h_min)/(h_max-h_min)
hA_sc=(hA-h_min)/(h_max-h_min)
Q_sc=(Q-Q_min)/(Q_max-Q_min)
QA_sc=(QA-QA_min)/(QA_max-QA_min)

# scaled ht, hm, Qt, Qm
ht_sc=(ht-h_min)/(h_max-h_min)
hm_sc=(hm-h_min)/(h_max-h_min)
Qt_sc=(Qt-QA_min)/(QA_max-QA_min)
Qm_sc=(Qm-QA_min)/(QA_max-QA_min)

plot(0,0, axes=FALSE, xlim=cbind(-1.1,1.1), ylim=cbind(-1.1,1.1), type="l", xlab="", ylab="")
# creating an empty graph [7, p.104-5][10] <- easiest way to combine the 3 plots
lines(x=t_sc, y=Q_sc, type="l") # [7, p.104-5]
# ^ line for Day vs. Discharge 

segments(-hm_sc, Qm_sc, 1, Qm_sc, lty=2)
# Notified of segments function by fellow project member; dotted lines for Qm and Qt [11]. 
# Looked at RStudio help section for structure.
segments(-ht_sc, Qt_sc, 1, Qt_sc, lty=2)

# lines defining Tf
segments(tf_sc[1], -1/4, tf_sc[1], 1, lty=2) 
segments(tf_sc[tfscl], -1/4,tf_sc[tfscl], 1, lty=2)

polygon(cbind(tf_sc[1], tf_sc, tf_sc[tfscl]), cbind(Qt_sc, Qf_sc[1:tfscl], Qt_sc), col="grey") 
# creation of shading above Qt, [12, pp.50-58].
# Use of specific coordinates suggested by fellow group member [11].

text(cbind(0,0.25,0.5,0.75,1),cbind(-0.1,-0.1,-0.1,-0.1,-0.1), labels=cbind(25,26,27,28,29), cex=0.75) 
# adding in axis points by text function; notified of text function by [7, p.105]. 
# Looked at RStudio help section
text(cbind(-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1),cbind(1/7,2/7,3/7,4/7,5/7,6/7,1), labels=cbind(50,100,150,200,250,300,350), cex=0.75)

# FEV box created by following
segments(tf_sc[tfscl], Qt_sc, tf_sc[1], Qt_sc, lty=1, lwd=2)
segments(tf_sc[tfscl], Qm_sc, tf_sc[1], Qm_sc, lty=1, lwd=2)
segments(tf_sc[1], Qt_sc, tf_sc[1], Qm_sc, lty=1, lwd=2)
segments(tf_sc[tfscl], Qt_sc, tf_sc[tfscl], Qm_sc, lty=1, lwd=2)

lines(x=-hA_sc, y=QA_sc, type="l") # [6, p.104-5] 
# ^ line defining the rating curve
segments(-hA_sc[1], QA_sc[1], -hA_sc[585], QA_sc[585], lty=2) # dotted line for rating curve

segments(-hm_sc, -1, -hm_sc,Qm_sc, lty=2) 
# dotted lines for hm and ht
segments(-ht_sc, -1, -ht_sc, Qt_sc, lty=2) 

lines(x=-h_sc, y=-t_sc, type="l")
# ^ line for Height vs. Day

axis(1, at = NULL, labels = FALSE, tick = TRUE, pos = 0,0, lwd.ticks=0)
# Adding horizontal axis. Found function via RStudio help section

text(cbind(-0.1,-0.1,-0.1,-0.1), cbind(-0.25,-0.5,-0.75,-1), labels=cbind(26,27,28,29), cex=0.75) 
# adding in axis points by text function
text(cbind(-1/6,-2/6,-3/6,-4/6,-5/6,-1), cbind(-0.1,-0.1,-0.1,-0.1,-0.1,-0.1), labels=cbind(1,2,3,4,5,6), cex=0.75)

axis(2, at = NULL, labels = FALSE, tick = TRUE, pos = 0,0, lwd.ticks=0)
# Adding vertical axis.

arrows(tf_sc[1],-0.245,tf_sc[tfscl],-0.245, length=0.1) # [13, pg 79]
# arrows defining/showing Tf
arrows(tf_sc[tfscl],-0.245,tf_sc[1],-0.245, length=0.1)

mtext(expression("Discharge [m"^"3"~"/s]"), 3)
# Found expression function via [14]
# expression used for subscript, superscript, and etc; how to correctly insert non-ASCII characters given by: [15].
# Adding axis labels; notified of mtext function by [7, p.105].

# The following text (140-162) is as stated on Onno & Tom's poster [1] 
text(1.1, Qt_sc, expression("Q"[t])) 
text(1.1, Qm_sc, expression("Q"[m]))
midp=(tf_sc[1]+tf_sc[tfscl])/2
text(midp, -0.35, expression("T"[f]), cex=0.75)
text(-ht_sc, -1.1, expression("h"[t]))
text(-hm_sc, -1.1, expression("h"[m]))
# ^ placement of Qt, Qm, Tf, ht, and hm 
text(0.5, -0.45, expression("FEV" %~~%  "9.34 Mm" ^ "3"),cex=0.875)
text(0.37, -0.55, expression("h"[t]), cex=0.875) 
text(0.5, -0.55,labels = "= 3.9 m", cex=0.875)
text(0.34, -0.65, expression("h"[m]), cex=0.875) 
text(0.5, -0.65,labels = "= 4.77 m", cex=0.875)
text(0.34, -0.75, expression("Q"[t]), cex=0.875)
text(0.545, -0.75, expression("= 219.1 m" ^ "3"~"/s"), cex=0.875) 
text(0.34, -0.85, expression("Q"[m]), cex=0.875)
text(0.545, -0.85, expression("= 300.2 m" ^ "3"~"/s"), cex=0.875) 
text(0.375, -0.95, expression("T"[f]), cex=0.875) 
text(0.54, -0.95, labels = "= 32hrs", cex=0.875) 

mtext("Height [m]", 2, las=1) 
mtext("Day", 4, las=1)
mtext("Day", 1, las=1)
title(main="River Aire Data")
# Notified of title function by [7, p.105].
```

<p align="center">
  <img width="700" height="700" src="https://github.com/Rivers-Project-2018/How-to-do-FEV-Analysis/blob/master/River Aire Plot from Automated RCode.png">
   <figcaption>Figure 2: The plot attained after using the automated R code.</figcaption>
</p>

**References for Section 6.2:**

1. Bokhove, O., Kelmanson, M.A., Kent, T., Piton, G. and Tacnet, J.M. *Using ‘flood-excess volume’ to assess and communicate flood-mitigation schemes*. [Online poster]. 2018. [Accessed 4 November 2018]. Available from: http://www1.maths.leeds.ac.uk/

2. Bokhove,O. *Armley F1707 Flow 15min May 15 to Mar 16.csv*. [Online]. 2018. [Accessed 8 October 2018]. Available from: https://github.com/obokhove/RiverAireDonCalder

3. Bokhove,O. *Armley F1707 Stage 15min May 15 to Mar 16.csv*. [Online]. 2018. [Accessed 8 October 2018]. Available from: https://github.com/obokhove/RiverAireDonCalder

4. Bokhove,O. *Rating Curves.xlsx*. [Online]. 2018. [Accessed 8 October 2018]. Available from: https://github.com/obokhove/RiverAireDonCalder

5. Kent, T. *Conversation with Sophie Kennett, Abbey Chapman, Jack Willis, Mary Saunders, and Antonia Feilden*, 12 November, 2018.

6. DataCamp. 2015. *R tutorial - Learn How to Create and Name Matrices in R*. 
[Online]. [Accessed November 2018]. Available from: https://www.youtube.com/

7. Verzani, J. *Using R for introductory Statistics*. 2nd ed. Boca Raton: CRC Press, Taylor \& Francis Group, 2014.

8. Kent, T. *Conversation with Sophie Kennett*, 12 March, 2019.

9. Kent, T. *Conversation with Sophie Kennett, Abbey Chapman, Jack Willis, Mary Saunders, and Antonia Feilden*, 12 October, 2018.

10. Saunders, M, and Chapman, A. *Conversation with Sophie Kennett, Abbey Chapman, Jack Willis, Mary Saunders, and Antonia Feilden*, c. 6 November, 2018.

11. Saunders, M. *Conversation with Sophie Kennett*, c. 27 November, 2018.

12. Lillis, D.A. *R Graphic Essentials*. Birmingham: Packt Publishing, 2014.

13. Murrell, P. *R Graphics*. [Online]. 2nd ed. Boca Roca: CRC Press, Taylor \& Francis Inc, 2016. [Accessed 30 October 2018]. Available from: https://books.google.co.uk/

14. StackOverflow. *Plot text containing ”approximately equal to” in R*. [Online]. [no date]. [Accessed 9 March 2019]. Available from: https://stackoverflow.com/

15. AstroStatistics. *Mathematical Annotation in R*. [Online]. [no date]. [Accessed 9 March 2019]. Available from: http://astrostatistics.psu.edu/su07/R/html/grDevices/html/plotmath.html
