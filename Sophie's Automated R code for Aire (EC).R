# The following is based on the Aire graph presented on [1].
library(readxl)
River_Aire_Data <- read_excel("Desktop/University_of_Leeds/Project/ArmleyF1707Stage_and_Flow15min_25Decto30Dec.xlsx")
# edited [2][3]
# Importing data

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
# Importing data

AireC=Rating_Curves$Aire_C # simplifying Rating Curve data names
Airea=Rating_Curves$Aire_a
Aireb=Rating_Curves$Aire_b

hA=seq(from=0.16, to=6, by=0.01)
# Suggested by Supervisor [5]
# Found in RStudio help section.

# Creating a new discharge matrix for the rating curve
QA=matrix(nrow=585, ncol=1)
# [5][6]

for(i in 1:585) { 
  if(hA[i]<0.685) QA[i]=AireC[1]*(hA[i]-Airea[1])^Aireb[1]
  if(0.685<=hA[i] & hA[i]<1.917) QA[i]=AireC[2]*(hA[i]-Airea[2])^Aireb[2]
  if(1.917<=hA[i]) QA[i]=AireC[3]*(hA[i]-Airea[3])^Aireb[3]
  ## Notified of for loop by [7, p.470].
}

ht=3.9 # able to change
Qt=AireC[3]*(ht-Airea[3])^Aireb[3]
hm=4.77 # able to change
Qm=AireC[3]*(hm-Airea[3])^Aireb[3]

# scaled ht, hm, Qt, Qm
ht_sc=(ht-h_min)/(h_max-h_min)
hm_sc=(hm-h_min)/(h_max-h_min)
Qt_sc=(Qt-QA_min)/(QA_max-QA_min)
Qm_sc=(Qm-QA_min)/(QA_max-QA_min)

# FEV Calculation
deltk=900 # 15 minutes in seconds [8].
# Notified of which function by supervisor [8].
# Looked at RStudio help section for structure
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

plot(0,0, axes=FALSE, xlim=cbind(-1.1,1.1), ylim=cbind(-1.1,1.1), type="l", xlab="", ylab="")
# creating an empty plot [7, p.104-5][10]
lines(x=t_sc, y=Q_sc, type="l") # [7, p.104-5]

segments(-hm_sc, Qm_sc, 1, Qm_sc, lty=2)
# Notified of segments function by fellow project member [11]. 
# Looked at RStudio help section for structure.
segments(-ht_sc, Qt_sc, 1, Qt_sc, lty=2)
segments(tf_sc[1], -1/4, tf_sc[1], 1, lty=2) 
segments(tf_sc[tfscl], -1/4,tf_sc[tfscl], 1, lty=2)

polygon(cbind(tf_sc[1], tf_sc, tf_sc[tfscl]), cbind(Qt_sc, Qf_sc[1:tfscl], Qt_sc), col="grey") 
# Use of specific coordinates suggested by fellow group member [11].
# [12, pp.50-58].

text(cbind(0,0.25,0.5,0.75,1),cbind(-0.1,-0.1,-0.1,-0.1,-0.1), labels=cbind(25,26,27,28,29), cex=0.75) #adding in axis points by text function
# Notified of text function by [7, p.105]. 
# Looked at RStudio help section
text(cbind(-0.1,-0.1,-0.1,-0.1,-0.1,-0.1,-0.1),cbind(1/7,2/7,3/7,4/7,5/7,6/7,1), labels=cbind(50,100,150,200,250,300,350), cex=0.75)

segments(tf_sc[tfscl], Qt_sc, tf_sc[1], Qt_sc, lty=1, lwd=2)
segments(tf_sc[tfscl], Qm_sc, tf_sc[1], Qm_sc, lty=1, lwd=2)
segments(tf_sc[1], Qt_sc, tf_sc[1], Qm_sc, lty=1, lwd=2)
segments(tf_sc[tfscl], Qt_sc, tf_sc[tfscl], Qm_sc, lty=1, lwd=2)

lines(x=-hA_sc, y=QA_sc, type="l") # [6, p.104-5]
segments(-hA_sc[1], QA_sc[1], -hA_sc[585], QA_sc[585], lty=2)

segments(-hm_sc, -1, -hm_sc,Qm_sc, lty=2) 
segments(-ht_sc, -1, -ht_sc, Qt_sc, lty=2) 

lines(x=-h_sc, y=-t_sc, type="l")

axis(1, at = NULL, labels = FALSE, tick = TRUE, pos = 0,0, lwd.ticks=0)
# Adding axis. Found function via RStudio help section

text(cbind(-0.1,-0.1,-0.1,-0.1), cbind(-0.25,-0.5,-0.75,-1), labels=cbind(26,27,28,29), cex=0.75) #adding in axis points by text function
text(cbind(-1/6,-2/6,-3/6,-4/6,-5/6,-1), cbind(-0.1,-0.1,-0.1,-0.1,-0.1,-0.1), labels=cbind(1,2,3,4,5,6), cex=0.75)

axis(2, at = NULL, labels = FALSE, tick = TRUE, pos = 0,0, lwd.ticks=0)

arrows(tf_sc[1],-0.245,tf_sc[tfscl],-0.245, length=0.1) # [13, pg 79]
arrows(tf_sc[tfscl],-0.245,tf_sc[1],-0.245, length=0.1)

# Found expression function via [14]
# How to correctly insert non-ASCII characters given by: [15].
# Notified of mtext function by [7, p.105].
mtext(expression("Discharge [m"^"3"~"/s]"), 3)

# The following text (115-132) is as stated on Onno & Tom's poster [1] 
text(1.1, Qt_sc, expression("Q"[t])) 
text(1.1, Qm_sc, expression("Q"[m]))
midp=(tf_sc[1]+tf_sc[tfscl])/2
text(midp, -0.35, expression("T"[f]), cex=0.75)
text(-ht_sc, -1.1, expression("h"[t]))
text(-hm_sc, -1.1, expression("h"[m]))
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
# Adding axis labels
title(main="River Aire Data")
# Notified of title function by [7, p.105].