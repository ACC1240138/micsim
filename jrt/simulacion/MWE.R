# Clean workspace
rm(list = ls())

library(MicSim)
source("Simulacion/patch_micSim.R")

# -----------------------------
# 1. Simulation setup
# -----------------------------
startDate <- 20140101
endDate <- 20241231
simHorizon <- c(startDate = startDate, endDate = endDate)
set.seed(234)
maxAge <- 100
monthSchoolEnrol <- 9

# -----------------------------
# 2. Define state space
# -----------------------------
sex <- c("m", "f")
fert <- c("0", "1+")
marital <- c("NM", "M", "D", "W")
edu <- c("no", "low", "med", "high")
drink <- c("Abstainer", "Moderate", "Heavy")

stateSpace <- expand.grid(
  sex = sex,
  fert = fert,
  marital = marital,
  edu = edu,
  drink = drink
)

absStates <- c("dead", "rest")

# -----------------------------
# 3. Initial population
# -----------------------------
N <- 25
birthDates <- runif(N, min = getInDays(19500101), max = getInDays(20131231))

getRandInitState <- function(birthDate, refDate = simHorizon[1]) {
  age <- trunc((getInDays(refDate) - birthDate) / 365.25)
  s1 <- sample(sex, 1)
  s2 <- ifelse(age <= 18, fert[1], sample(fert, 1))
  s3 <- ifelse(
    age <= 18,
    marital[1],
    ifelse(age <= 22, sample(marital[1:3], 1), sample(marital, 1))
  )
  s4 <- ifelse(
    age <= 7,
    edu[1],
    ifelse(age <= 18, edu[2], ifelse(age <= 23, sample(edu[2:3], 1), sample(edu[-1], 1)))
  )
  s5 <- sample(drink, 1, prob = c(0.4, 0.4, 0.2))

  paste(c(s1, s2, s3, s4, s5), collapse = "/")
}

initPop <- data.frame(
  ID = 1:N,
  birthDate = getInDateFormat(birthDates),
  initState = sapply(birthDates, getRandInitState)
)

# -----------------------------
# 4. Immigrants
# -----------------------------
M <- 5
immigrDates <- runif(M, min = getInDays(20140101), max = getInDays(20241231))
immigrAges <- runif(M, min = 15 * 365.25, max = 70 * 365.25)
immigrBirthDates <- immigrDates - immigrAges
IDmig <- max(initPop$ID) + 1:M

immigrPop <- data.frame(
  ID = IDmig,
  immigrDate = getInDateFormat(immigrDates),
  birthDate = getInDateFormat(immigrBirthDates),
  immigrInitState = mapply(getRandInitState, immigrBirthDates, immigrDates)
)

# -----------------------------
# 5. Newborn initial states
# -----------------------------
varInitStates <- rbind(
  c("m", "0", "NM", "no", "Abstainer"),
  c("f", "0", "NM", "no", "Abstainer")
)

initStatesProb <- c(0.515, 0.485)

# -----------------------------
# 6. Transition functions
# -----------------------------
fert1Rates <- function(age, calTime) {
  b <- ifelse(calTime <= 2020, 3.9, 3.3)
  c <- ifelse(calTime <= 2020, 28, 29)
  rate <- (b / c) * (c / age)^(3 / 2) * exp(-b^2 * (c / age + age / c - 2))
  rate[age <= 15 | age >= 45] <- 0
  rate
}

fert2Rates <- function(age, calTime, duration) {
  b <- ifelse(calTime <= 2020, 3.2, 2.8)
  c <- ifelse(calTime <= 2020, 32, 33)
  rate <- (b / c) * (c / age)^(3 / 2) * exp(-b^2 * (c / age + age / c - 2))
  rate[age <= 15 | age >= 45 | duration < 0.75] <- 0
  rate
}

marriage1Rates <- function(age, calTime) {
  rate <- dnorm(age, mean = ifelse(calTime <= 2020, 25, 30), sd = 3)
  rate[age <= 16] <- 0
  rate
}

marriage2Rates <- function(age, calTime) {
  b <- ifelse(calTime <= 2020, 0.07, 0.10)
  p <- 2.7
  lambda <- ifelse(calTime <= 1950, 0.04, 0.03)
  rate <- b * p * (lambda * age)^(p - 1) / (1 + (lambda * age)^p)
  rate[age <= 18] <- 0
  rate
}

divorceRates <- function(age, calTime) {
  rate <- dnorm(age, mean = 40, sd = ifelse(calTime <= 2020, 7, 6))
  rate[age <= 18] <- 0
  rate
}

widowhoodRates <- function(age, calTime) {
  ifelse(age <= 30, 0, pgamma(age - 30, shape = 6, rate = 0.06))
}

noToLowEduRates <- function(age, calTime) {
  ifelse(age == 7, Inf, 0)
}

lowToMedEduRates <- function(age, calTime) {
  rate <- dnorm(age, mean = 16, sd = 1)
  rate[age <= 15 | age >= 25] <- 0
  rate
}

medToHighEduRates <- function(age, calTime) {
  rate <- dnorm(age, mean = 20, sd = 3)
  rate[age <= 18 | age >= 35] <- 0
  rate
}

emigrRates <- function(age, calTime) {
  ifelse(age <= 18, 0, 0.0025)
}

ModerateDead <- function(age, calTime) {
  a <- 0.00005
  b <- 0.09
  a * exp(b * age)
}

HeavyDead <- function(age, calTime) {
  a <- 0.0001
  b <- 0.1
  a * exp(b * age)
}

# -----------------------------
# 7. Transition matrix
# -----------------------------
fertTrMatrix <- cbind(c("0->1+", "1+->1+"), c("fert1Rates", "fert2Rates"))

maritalTrMatrix <- cbind(
  c("NM->M", "M->D", "M->W", "D->M", "W->M"),
  c("marriage1Rates", "divorceRates", "widowhoodRates", "marriage2Rates", "marriage2Rates")
)

eduTrMatrix <- cbind(
  c("no->low", "low->med", "med->high"),
  c("noToLowEduRates", "lowToMedEduRates", "medToHighEduRates")
)

allTransitions <- rbind(fertTrMatrix, maritalTrMatrix, eduTrMatrix)

absTransitions <- rbind(
  c("Moderate/dead", "ModerateDead"),
  c("Heavy/dead", "HeavyDead"),
  c("rest", "emigrRates")
)

transitionMatrix <- buildTransitionMatrix(
  allTransitions = allTransitions,
  absTransitions = absTransitions,
  stateSpace = stateSpace
)

fertTr <- fertTrMatrix[, 1]

# -----------------------------
# 8. Run simulation
# -----------------------------
pop <- micSim(
  initPop = initPop,
  immigrPop = immigrPop,
  transitionMatrix = transitionMatrix,
  absStates = absStates,
  varInitStates = varInitStates,
  initStatesProb = initStatesProb,
  maxAge = maxAge,
  simHorizon = simHorizon,
  fertTr = fertTr,
  monthSchoolEnrol = monthSchoolEnrol
)

if ("motherID" %in% names(pop)) {
  pop$motherID <- NULL
}

# -----------------------------
# 9. Output
# -----------------------------
head(pop, 10)
table(pop$To)



### 1. Define simulation parameters
simHorizon <- c(startDate = 20220101, endDate = 20320101)
maxAge <- 99
set.seed(123)

### 2. Define state space
states <- c("Abstainer", "Moderate", "Heavy")
attr(states, "name") <- "drinking"

### 3. Define all transitions (non-absorbing only)
# MicSim expects a CHARACTER MATRIX with two columns:
#   Column 1: transition label as "Origin->Destination"
#   Column 2: name of the R function that calculates the hazard rate

# allTransitions <- cbind(
#   c("Abstainer->Moderate", "Moderate->Heavy"),
#   c("abstToMod", "modToHeavy")
# )

# ### 4. Define absorbing transitions separately

# absTransitions <- cbind(
#   c("Heavy->Dead"),
#   c("heavyDead")
# )


allTransitions <- cbind(
  c("Abstainer->Moderate", "Moderate->Heavy"),
  c("abstToMod", "modToHeavy")
)

### 4. Define absorbing transitions separately

absTransitions <- cbind(
  c("Heavy/dead"),
  c("heavyDead")
)

### 5. Build transition matrix
transitionMatrix <- buildTransitionMatrix(
  allTransitions = allTransitions,
  absTransitions = absTransitions,
  stateSpace = states
)

### 6. Define hazard functions
# IMPORTANT: the names here must EXACTLY match the names given in
# allTransitions / absTransitions (column 2).
abstToMod  <- function(age, calTime) rep(0.02, length(age))
modToHeavy <- function(age, calTime) rep(0.05, length(age))
heavyDead  <- function(age, calTime) {
  a <- 0.0001
  b <- 0.09
  return(a * exp(b * age))
}

### 7. Define initial population
initPop <- data.frame(
  ID = 1:5,
  birthDate = c("19900101", "19850515", "19720310", "19991225", "19881130"),
  initState = c("Abstainer", "Abstainer", "Moderate", "Abstainer", "Heavy")
)

### 8. Run the simulation
simResults <- micSim(
  initPop = initPop,
  transitionMatrix = transitionMatrix,
  absStates = "dead",
  simHorizon = simHorizon,
  maxAge = maxAge
)

### 9. Review results
head(simResults)
table(simResults$To)

######################################################################################
# 1. Simple example only dealing with mortality events
######################################################################################

# Clean workspace 
rm(list=ls());gc()
library(MicSim)
source("Simulacion/patch_micSim.R")

# Defining simulation horizon
startDate <- 20000101 # yyyymmdd
endDate   <- 21001231 # yyyymmdd
simHorizon <- c(startDate=startDate, endDate=endDate)

# Seed for random number generator
set.seed(234)

# Definition of maximal age
maxAge <- 120

# Defintion of nonabsorbing and absorbing states
sex <- c("m","f")
stateSpace <- sex
attr(stateSpace,"name") <- "sex"
absStates <- "dead"

# Definition of an initial population 
birthDates <- c("19301231","19990403","19561015","19911111","19650101")
initStates <- c("f","m","f","m","m")
initPop <- data.frame(ID=1:5,birthDate=birthDates,initState=initStates)

# Definition of mortality rates (Gompertz model)
mortRates <- function(age, calTime){
  a <- 0.00003
  b <- ifelse(calTime<=2020, 0.1, 0.097)
  rate <- a*exp(b*age)
  return(rate)
}

# Transition pattern and assignment of functions specifying transition rates
absTransitions <- c("dead","mortRates")
transitionMatrix <- buildTransitionMatrix(allTransitions=NULL,
                                          absTransitions=absTransitions, stateSpace=stateSpace)

# Execute microsimulation (sequentially, i.e., using only one CPU)
pop <- micSim(initPop=initPop, transitionMatrix=transitionMatrix, absStates=absStates, 
              maxAge=maxAge, simHorizon=simHorizon)

print(pop)
 



# EXAMPLE 2
# Clean workspace 
rm(list=ls())

library(MicSim)
source("Simulacion/patch_micSim.R")

# Defining simulation horizon
startDate <- 20140101 # yyyymmdd
endDate   <- 20241231 # yyyymmdd
simHorizon <- c(startDate=startDate, endDate=endDate)

# Seed for random number generator
set.seed(234)

# Definition of maximal age 
maxAge <- 100  

# Defintion of nonabsorbing and absorbing states
sex <- c("m","f")                     
fert <- c("0","1+")           
marital <- c("NM","M","D","W")        
edu <- c("no","low","med","high")   
stateSpace <- expand.grid(sex=sex,fert=fert,marital=marital,edu=edu)
absStates <- c("dead","rest")   

# General month of enrollment to elementary school
monthSchoolEnrol <- 9

# Definition of an initial population (for illustration purposes, create a random population)
N = 100                                                       
birthDates <- runif(N, min=getInDays(19500101), max=getInDays(20131231)) 
getRandInitState <- function(birthDate){
  age <- trunc((getInDays(simHorizon[1]) - birthDate)/365.25) 
  s1 <- sample(sex,1)
  s2 <- ifelse(age<=18, fert[1], sample(fert,1))
  s3 <- ifelse(age<=18, marital[1], ifelse(age<=22, sample(marital[1:3],1), 
                                           sample(marital,1)))
  s4 <- ifelse(age<=7, edu[1], ifelse(age<=18, edu[2], ifelse(age<=23, sample(edu[2:3],1), 
                                                              sample(edu[-1],1))))
  initState <- paste(c(s1,s2,s3,s4),collapse="/")
  return(initState)
}
initPop <- data.frame(ID=1:N, birthDate=birthDates, initState=sapply(birthDates, getRandInitState))
initPop$birthDate <- getInDateFormat(initPop$birthDate)
range(initPop$birthDate)

# Definition of immigrants entering the population (for illustration purposes, create immigrants 
# randomly)
M = 20                                                           
immigrDates <- runif(M, min=getInDays(20140101), max=getInDays(20241231)) 
immigrAges <- runif(M, min=15*365.25, max=70*365.25)
immigrBirthDates <- immigrDates - immigrAges
IDmig <- max(as.numeric(initPop[,"ID"]))+(1:M)
immigrPop <- data.frame(ID = IDmig, immigrDate = immigrDates, birthDate=immigrBirthDates, 
                        immigrInitState=sapply(immigrBirthDates, getRandInitState))  
immigrPop$birthDate <- getInDateFormat(immigrPop$birthDate)
immigrPop$immigrDate <- getInDateFormat(immigrPop$immigrDate)

# Definition of initial states for newborns 
varInitStates <- rbind(c("m","0","NM","no"),c("f","0","NM","no")) 
# Definition of related occurrence probabilities
initStatesProb <- c(0.515,0.485)                              

# Definition of (possible) transition rates  
# (1) Fertility rates (Hadwiger mixture model)
fert1Rates <- function(age, calTime){  # parity 1
  b <- ifelse(calTime<=2020, 3.9, 3.3)
  c <- ifelse(calTime<=2020, 28, 29)
  rate <-  (b/c)*(c/age)^(3/2)*exp(-b^2*(c/age+age/c-2))
  rate[age<=15 | age>=45] <- 0
  return(rate)
}
fert2Rates <- function(age, calTime, duration){  # partiy 2+
  b <- ifelse(calTime<=2020, 3.2, 2.8)
  c <- ifelse(calTime<=2020, 32, 33)
  rate <-  (b/c)*(c/age)^(3/2)*exp(-b^2*(c/age+age/c-2))
  rate[age<=15 | age>=45 | duration<0.75] <- 0
  return(rate)
}
# (2) Rates for first marriage (normal density)
marriage1Rates <- function(age, calTime){  
  m <- ifelse(calTime<=2020, 25, 30)
  s <- ifelse(calTime<=2020, 3, 3)
  rate <- dnorm(age, mean=m, sd=s)
  rate[age<=16] <- 0
  return(rate)
}
# (3) Remariage rates (log-logistic model)
marriage2Rates <- function(age, calTime){  
  b <- ifelse(calTime<=2020, 0.07, 0.10)
  p <- ifelse(calTime<=2020, 2.7,2.7)
  lambda <- ifelse(calTime<=1950, 0.04, 0.03)
  rate <- b*p*(lambda*age)^(p-1)/(1+(lambda*age)^p)
  rate[age<=18] <- 0
  return(rate)
}
# (4) Divorce rates (normal density)
divorceRates <- function(age, calTime){
  m <- 40
  s <- ifelse(calTime<=2020, 7, 6)
  rate <- dnorm(age,mean=m,sd=s)
  rate[age<=18] <- 0
  return(rate)
}
# (5) Widowhood rates (gamma cdf)
widowhoodRates <- function(age, calTime){
  rate <- ifelse(age<=30, 0, pgamma(age-30, shape=6, rate=0.06))
  return(rate)
}
# (6) Rates to change educational attainment
# Set rate to `Inf' to make transition for age 7 deterministic.
noToLowEduRates <- function(age, calTime){
  rate <- ifelse(age==7,Inf,0) 
  return(rate)
}
lowToMedEduRates <- function(age, calTime){
  rate <- dnorm(age,mean=16,sd=1)
  rate[age<=15 | age>=25] <- 0
  return(rate)
}
medToHighEduRates <- function(age, calTime){
  rate <- dnorm(age,mean=20,sd=3)
  rate[age<=18 | age>=35] <- 0
  return(rate)
}
# (7) Mortality rates (Gompertz model)
mortRates <- function(age, calTime){
  a <- .00003
  b <- ifelse(calTime<=2020, 0.1, 0.097)
  rate <- a*exp(b*age)
  return(rate)
}
# (8) Emigration rates 
emigrRates <- function(age, calTime){
  rate <- ifelse(age<=18,0,0.0025)
  return(rate)
}

# Transition pattern and assignment of functions specifying transition rates
fertTrMatrix <- cbind(c("0->1+","1+->1+"),                         
                      c("fert1Rates", "fert2Rates"))
maritalTrMatrix <- cbind(c("NM->M","M->D","M->W","D->M","W->M"),              
                         c("marriage1Rates","divorceRates","widowhoodRates",
                           "marriage2Rates","marriage2Rates"))
eduTrMatrix <- cbind(c("no->low","low->med","med->high"),
                     c("noToLowEduRates","lowToMedEduRates","medToHighEduRates")) 
allTransitions <- rbind(fertTrMatrix, maritalTrMatrix, eduTrMatrix)
absTransitions <- rbind(c("dead","mortRates"),c("rest","emigrRates"))
transitionMatrix <- buildTransitionMatrix(allTransitions=allTransitions,
                                          absTransitions=absTransitions, stateSpace=stateSpace)

# Define transitions triggering a birth event
fertTr <- fertTrMatrix[,1]

# Execute microsimulation 
pop <- micSim(initPop=initPop, immigrPop=immigrPop, 
              transitionMatrix=transitionMatrix, 
              absStates=absStates, 
              varInitStates=varInitStates, 
              initStatesProb=initStatesProb, 
              maxAge=maxAge, 
              simHorizon=simHorizon, 
              fertTr=fertTr, 
              monthSchoolEnrol=monthSchoolEnrol)  

print(pop)
# micSim wrapper loaded in .GlobalEnv. MicSim namespace was not modified.
# Initialization ... 
# [1] "Starting at:  2026-05-14 17:13:19.530695"
# [1] "Ending at:  2026-05-14 17:13:19.639913"
# Simulation is running ... 
# Year:  2000 
# Year:  2006 
# Year:  2017 
# Year:  2020 
# Year:  2079 
# Year:  2086 
# Simulation has finished.
# ------------------
#   ID birthDate initState From   To transitionTime transitionAge
# 1  1  19301231         f    f dead       20170321         86.23
# 2  2  19990403         m    m dead       20861125         87.64
# 3  3  19561015         f    f dead       20060524         49.61
# 4  4  19911111         m    m dead       20790430         87.47
# 5  5  19650101         m    m dead       20201122         55.89
# micSim wrapper loaded in .GlobalEnv. MicSim namespace was not modified.
# [1] "19500129" "20130802"
# R 4.4.1 exited unexpectedly: exit code -1073741819
