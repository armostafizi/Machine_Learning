library(RNetLogo)
nlDir <- "C:/Program Files (x86)/NetLogo 5.1.0"
setwd(nlDir)

nl.path <- getwd()
NLStart(nl.path)

model.path <- "Z:/Windows.Documents/Desktop/EvacProject/Evacuation Model.nlogo"
NLLoadModel(model.path)


NLCommand("set immediate-evacuation false")
NLCommand("Set Save-Output-To-File false")
NLCommand("set Alternative-Plan-Mode false")
NLCommand("Set T0-NoAction 0")
NLCommand("Set T3-VerEvac-Foot 0")
NLCommand("Set R0-NoAction 0")
NLCommand("Set R3-VerEvac-Foot 0")
NLCommand("Set Hc 0.5")
NLCommand("Set Acceleration 5")
NLCommand("Set Deceleration 25")





walkingSpeeds = c(3,4,5)
walkingSpeedVariations = c(1,2)

maxDrivingSpeeds = c(25,35,45)

preparationTaus = c(0,2,5)
preparationSigmas = c(0.5,1.5)

pedPercentages = c(0,25,50,75,100)

mortalities <- data.frame()
counter <- 1

# ws <- 3
# wsv <- 1
# mds <- 25
# pt <- 0
# ps <- 0.5
# pp <- 50

for (ws in walkingSpeeds){
  for (wsv in wakingSpeedVariations){
    for (mds in maxDrivingSpeeds){
      for (pt in preparationTaus){
        for (ps in preparationSigmas){
          for (pp in pedPercentages) {
            
            NLCommand(paste("Set T1-HorEvac-Foot", pp))
            NLCommand(paste("Set T2-HorEvac-Car", (100 - pp)))
            NLCommand(paste("Set R1-HorEvac-Foot", pp))
            NLCommand(paste("Set R2-HorEvac-Car", (100 - pp)))
            NLCommand(paste("Set Ped-Speed", ws))
            NLCommand(paste("Set Ped-Sigma", wsv))
            NLCommand(paste("Set Max-Speed", mds))
            
            NLCommand(paste("Set Rtau1", pt))
            NLCommand(paste("Set Rsig1", ps))
            NLCommand(paste("Set Rtau2", pt))
            NLCommand(paste("Set Rsig2", ps))
            NLCommand(paste("Set Rtau3", pt))
            NLCommand(paste("Set Rsig3", ps))
            
            NLCommand(paste("Set Ttau1", pt))
            NLCommand(paste("Set Tsig1", ps))
            NLCommand(paste("Set Ttau2", pt))
            NLCommand(paste("Set Tsig2", ps))
            NLCommand(paste("Set Ttau3", pt))
            NLCommand(paste("Set Tsig3", ps))
            
            
            
            NLCommand("readread")
            NLDoCommandWhile("ticks <= 3599","go")
            mr <- NLReport("count turtles with [color = red] / (count residents + count tourists + count pedestrians + count cars) * 100")
            mortalities <- rbind(mortalities, c(mr,pp,pt,ps,mds,ws,wsv))
            print(counter)
            counter <- counter + 1
          }
        }
      }
    }
  }
}

