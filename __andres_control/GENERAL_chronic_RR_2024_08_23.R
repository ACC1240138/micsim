

## data for the various diseases, separatly for men and women
## information includes:
## disease: name of the disease
## RRCurrent: relative risk function for the (current) drinkers
## betaCurrent: coefficients for the RR function of (current) drinkers
## covBetaCurrent: covariance matrix for the beta coefficients of the (current) drinkers
## lnRRFormer: log relative risk of former drinkers
## varLnRRFormer: variance of log relative risk estimate of former drinkers


####### Epilepsy #######
####### Epilepsy #######
####### Epilepsy #######
#### male ####
epilepsymale = list(disease = "Epilepsy",
                    RRCurrent = function(x, beta) {exp(beta[2] * (x + 0.5) / 100)},
                    betaCurrent = c(0,1.22861,0,0),
                    covBetaCurrent = matrix(c(0,0,0,0,0,0.1391974^2,0,0,0,0,0,0,0,0,0,0),4,4),
                    lnRRFormer = log(1),
                    varLnRRFormer = 0^2)
#### female ####
epilepsyfemale = list(disease = "Epilepsy", 
                      RRCurrent = function(x, beta) {exp(beta[2] * (x + 0.5) / 100)},
                      betaCurrent = c(0,1.22861,0,0),
                      covBetaCurrent = matrix(c(0,0,0,0,0,0.1391974^2,0,0,0,0,0,0,0,0,0,0),4,4),
                      lnRRFormer = log(1),
                      varLnRRFormer = 0^2)



######## Pancreatitis #######
######## Pancreatitis #######
######## Pancreatitis #######
### male ###
pancreatitismale = list(disease = "Pancreatitis", 
                        RRCurrent = function(x, beta){exp(beta[1] * x)},
                        betaCurrent = c(0.0173451,0,0,0),
                        covBetaCurrent = matrix(c(0.003803^2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
                        lnRRFormer = log(2.2),
                        varLnRRFormer = 0.213^2)


pancreatitisfemale = list(disease = "Pancreatitis", 
                          RRCurrent = function(x, beta){ifelse(x>=0,
                                                               ifelse(x >= 3,ifelse(x>=15,ifelse(x>=40,ifelse(x>=108,
                                                                                                              #x>108
                                                                                                              exp(beta[1]*108 + beta[2]*(((108-3)^3-1/(40-15)*((108-15)^3*(40-3)-(108-40)^3*(15-3)))/(40-3)^2)),
                                                                                                              #108>x>=40
                                                                                                              exp(beta[1]*x + beta[2]*(((x-3)^3-1/(40-15)*((x-15)^3*(40-3)-(x-40)^3*(15-3)))/(40-3)^2))),
                                                                                                 #40>x>=15
                                                                                                 exp(beta[1]*x + beta[2]*(((x-3)^3-1/(40-15)*(x-15)^3*(40-3))/(40-3)^2))
                                                               ),
                                                               #15>x>=3
                                                               exp(beta[1]*x + beta[2]*((x-3)^3/(40-3)^2))
                                                               ),
                                                               #0<=x<3
                                                               exp(beta[1]*x)),
                                                               #x<=0
                                                               1)
                          },
                          betaCurrent = c(-0.0272886,0.0611466,0,0),
                          covBetaCurrent = matrix (c(0.0112745^2,-0.00015821,0,0,-0.00015821,0.0176205^2,0,0,0,0,0,0,0,0,0,0),4,4),
                          lnRRFormer = log(2.2),
                          varLnRRFormer = 0.213^2)




####### Tuberculosis #######
####### Tuberculosis #######
####### Tuberculosis #######
#### remark: this is a piecewise constant function ####
#### male ####
tuberculosismale = list(disease = "Tuberculosis", 
                        RRCurrent = function(x, beta){ifelse(x >= 0, ifelse(x < 150, exp(x*beta[1]), exp(150*beta[1]) ), 0)},
                        betaCurrent = c(0.0179695,0,0,0),
                        covBetaCurrent = matrix(c(0.007215^2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
                        lnRRFormer = log(1),
                        varLnRRFormer = 0^2)
#### female ####
tuberculosisfemale = list(disease = "Tuberculosis",
                          RRCurrent = function(x, beta){ifelse(x >= 0, ifelse(x < 150, exp(x*beta[1]), exp(150*beta[1]) ), 0)},
                          betaCurrent = c(0.0179695,0,0,0),
                          covBetaCurrent =  matrix(c(0.007215^2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
                          lnRRFormer = log(1),
                          varLnRRFormer = 0^2)



####### Lower Respiratory Infections ########
####### Lower Respiratory Infections ########
####### Lower Respiratory Infections ########
#### male ####
lowerrespmale = list(disease = "Lower_Respiratory_Infections", 
                     RRCurrent = function(x, beta){exp(beta[2]*((x + 0.0399999618530273) / 100))},
                     betaCurrent = c(0,0.4764038,0,0),
                     covBetaCurrent = matrix(c(0,0,0,0,0,0.1922055^2,0,0,0,0,0,0,0,0,0,0),4,4),
                     lnRRFormer = log(1),
                     varLnRRFormer = 0^2) 
#### female ####
lowerrespfemale = list(disease = "Lower_Respiratory_Infections",  
                       RRCurrent = function(x, beta){exp(beta[2]*((x + 0.0399999618530273) / 100))},
                       betaCurrent = c(0,0.4764038,0,0),
                       covBetaCurrent = matrix(c(0,0,0,0,0,0.1922055^2,0,0,0,0,0,0,0,0,0,0),4,4),
                       lnRRFormer = log(1),
                       varLnRRFormer = 0^2)



####### Hemorrhagic Stroke - Mortality #########
####### Hemorrhagic Stroke - Mortality #########
####### Hemorrhagic Stroke - Mortality #########
#### male ####
hemorrhagicstrokemale = list(disease = "Hemorrhagic_Stroke", 
                             RRCurrent = function(x, beta){ ifelse(x >= 0,
                                                                   ifelse(x <= 1, 1 - x * (1 - exp(beta[2] * (1 + 0.0028572082519531) / 100)),
                                                                          exp(beta[2] * (x + 0.0028572082519531) / 100)), 0)},
                             betaCurrent = c(0,0.6898937,0,0),
                             covBetaCurrent = matrix(c(0,0,0,0,0,0.1141980^2,0,0,0,0,0,0,0,0,0,0),4,4),
                             lnRRFormer = log(1.36),
                             varLnRRFormer = 0.20^2)
#### female ####
hemorrhagicstrokefemale = list(disease = "Hemorrhagic_Stroke", 
                               RRCurrent = function(x, beta){ ifelse(x >= 0,
                                                                     ifelse(x <= 1, 1 - x * (1 - exp(beta[2] * (1 + 0.0028572082519531) / 100)),
                                                                            exp(beta[2] * (x + 0.0028572082519531) / 100)), 0)},
                               betaCurrent = c(0,1.466406,0,0),
                               covBetaCurrent = matrix(c(0,0,0,0,0,0.3544172^2,0,0,0,0,0,0,0,0,0,0),4,4),
                               lnRRFormer = log(1.36),
                               varLnRRFormer = 0.20^2)



####### Diabetes Mellitus #######
####### Diabetes Mellitus #######
####### Diabetes Mellitus #######
## functions from Craig Knott publication 
#### male ####

diabetesmale = list(disease = "Diabetes_Mellitus", 
                    RRCurrent = function(x, beta){exp(beta[1]*x)},
                    betaCurrent = c(0.00113662,0,0,0),
                    covBetaCurrent = matrix(c(0.00062991^2,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0),4,4),
                    lnRRFormer = log(1.18),
                    varLnRRFormer = 0.136542^2)
                    
#### female ####
diabetesfemale = list(disease = "Diabetes_Mellitus", 
                      RRCurrent = function(x, beta){exp(beta[1]*x + 
                      	beta[2]*( pmax((x - 1.000)/12.9940517165868, 0)^3 + ((20.815 - 1) * pmax((x - 47.840)/12.9940517165868, 0)^3 - (47.840 - 1) * (pmax((x - 20.815)/12.9940517165868, 0)^3))  / (47.840 - 20.815)  ) + 
                      	beta[3]*( pmax((x - 9.065)/12.9940517165868, 0)^3 + ((20.815 - 9.065) * pmax((x - 47.840)/12.9940517165868, 0)^3 - (47.840 - 9.065) * (pmax((x - 20.815)/12.9940517165868, 0)^3)) / (47.840 - 20.815) )
                      	)},
                      betaCurrent = c(-0.03892253,0.20524216,-0.34804082,0),
                      covBetaCurrent = matrix(c(0.0000266642, -0.0002165703, 0.0004123293, 0, -0.0002165703, 0.0021309780, -0.0042181160, 0, 0.0004123293, -0.0042181160, 0.0084493153, 0,  0, 0, 0, 0),4,4),
                      lnRRFormer = log(1.14),
                      varLnRRFormer = 0.0714483^2)


####### Liver Cirrhosis - Mortality #######
####### Liver Cirrhosis - Mortality #######
####### Liver Cirrhosis - Mortality #######
####### Remark: The expression of the beta coefficient for this RR function is a sum of 2 coefficients which have covariance
####### Therefore, beta1 will be the first "part" of the coefficient and beta2 the second one.
#### male ####
livercirrhosismale = list(disease = "Liver_Cirrhosis", 
                          RRCurrent = function(x, beta){ ifelse(x >= 0,
                                                                ifelse(x <= 1, 1 + x * (exp((beta[1] + beta[2]) * (1 + 0.1699981689453125) / 100) - 1),
                                                                       exp((beta[1] + beta[2]) * (x + 0.1699981689453125) / 100)), 0)},
                          betaCurrent = c(1.687111,1.106413,0,0),
                          covBetaCurrent = matrix(c(.0359478,-.0359478,0,0,-.0359478,.07174495,0,0,0,0,0,0,0,0,0,0),4,4),
                          lnRRFormer = log(3.26),
                          varLnRRFormer = 0.439877088885848^2 )
#### female ####
livercirrhosisfemale = list(disease = "Liver_Cirrhosis", 
                            RRCurrent = function(x, beta){ ifelse(x >= 0,
                                                                  ifelse(x <= 1, 1 + x * (exp((beta[1] + beta[2]) * sqrt((1 + 0.1699981689453125) / 100)) - 1),
                                                                         exp((beta[1] + beta[2]) * sqrt((x + 0.1699981689453125) / 100))), 0)},
                            betaCurrent = c(2.351821,0.9002139,0,0),
                            covBetaCurrent = matrix(c(.05018842,-.05018842,0,0,-.05018842,.10270352,0,0,0,0,0,0,0,0,0,0),4,4),
                            lnRRFormer = log(3.26),
                            varLnRRFormer = 0.439877088885848^2 )






####### Conduction Disorders and other Dysrythmias #######
####### Conduction Disorders and other Dysrythmias #######
####### Conduction Disorders and other Dysrythmias #######

####### Atrial fibrillation and flutter #######
####### Atrial fibrillation and flutter #######

#### Source: Larsson et al., 2014

#### Male ####
Atrial_fibrillation_male = list(disease = "Atrial_fibrillation_and_flutter",
                              RRCurrent = function(x, beta){exp(beta[2] * x )},
                              betaCurrent = c(0,0.00641342,0,0), 
                              covBetaCurrent = matrix(c(0,0,0,0, 0,0.000787442^2,0,0,0,0,0,0,0,0,0,0),4,4),
                              lnRRFormer = log(1),
                              varLnRRFormer = 0^2)
#### Female ####
Atrial_fibrillation_female = list(disease = "Atrial_fibrillation_and_flutter",
                           	    RRCurrent = function(x, beta){exp(beta[2] * x )},
                                betaCurrent = c(0,0.00641342,0,0),
                                covBetaCurrent = matrix(c(0,0,0,0, 0,0.000787442^2,0,0,0,0,0,0,0,0,0,0),4,4),
                                lnRRFormer = log(1),
                                varLnRRFormer = 0^2)




#### male ####
conductiondisordermale = list(disease = "Conduction Disorder and other Dysrythmias",
                              RRCurrent = function(x, beta){exp(beta[2] * (x + 0.0499992370605469) / 10)},
                              betaCurrent = c(0,0.0575183,0,0), 
                              covBetaCurrent = matrix(c(0,0,0,0,0,0.0100899^2,0,0,0,0,0,0,0,0,0,0),4,4),
                              lnRRFormer = log(1),
                              varLnRRFormer = 0^2)
#### female ####
conductiondisorderfemale = list(disease = "Conduction Disorder and other Dysrythmias",
                                RRCurrent = function(x, beta){ exp(beta[2]*(x + .0499992370605469) / 10)},
                                betaCurrent = c(0,0.0575183,0,0),
                                covBetaCurrent = matrix(c(0,0,0,0,0,0.0100899^2,0,0,0,0,0,0,0,0,0,0),4,4),
                                lnRRFormer = log(1),
                                varLnRRFormer = 0^2)


####### HIV #######
####### HIV #######
####### HIV #######
#### remark: this is a piecewise constant function ####
#### male ####
HIVmale = list(disease = "HIV", 
               RRCurrent = function(x, beta){ifelse(x >= 0, ifelse(x <= 61, 1, exp(beta[1])), 0)},
               betaCurrent = c(log(1.54),0,0,0),
               covBetaCurrent = matrix(c(0.078210772^2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
               lnRRFormer = log(1),
               varLnRRFormer = 0^2)
#### female ####
HIVfemale = list(disease = "HIV",
                 RRCurrent = function(x, beta){ifelse(x >= 0, ifelse(x <= 49, 1, exp(beta[1])), 0)},
                 betaCurrent = c(log(1.54),0,0,0),
                 covBetaCurrent =  matrix(c(0.078210772^2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
                 lnRRFormer = log(1),
                 varLnRRFormer = 0^2)




######## Hypertension ########  
######## Hypertension ########  

#### Source: Liu et al., 2020
	
#### Male ####
hypertension_male = list(disease = "Hypertension",
                                        RRCurrent = function(x, beta) {ifelse(x<= 10, exp(beta[1]*x),
                                        									ifelse(x<= 30, exp( beta[1]*10 + beta[2]*(x-10) ),
                                        									 exp( beta[1]*10 + beta[2]*(20) + beta[3]*(x-30) ) )) },
                                        betaCurrent = c(0.013976194,0.00689349,0.002942025,0),
                                        covBetaCurrent = matrix(c(0.002899472^2,0,0,0, 0,0.001245533^2,0,0, 0,0,0.000212028^2,0, 0,0,0,0),4,4),
                				        lnRRFormer = log(1.05),
				                        varLnRRFormer = 0.108388569889098 ^ 2)
#### Female ####
hypertension_female = list(disease = "Hypertension",
            								 RRCurrent = function(x, beta) {ifelse(x<= 10, exp(beta[1]*x),
                                        									ifelse(x<= 30, exp( beta[1]*10 + beta[2]*(x-10) ),
                                        									 exp( beta[1]*10 + beta[2]*(20) + beta[3]*(x-30) ) )) },
                                        betaCurrent = c(0.005826891,0.005362277,0.005605865,0),
                                        covBetaCurrent = matrix(c(0.00240841^2,0,0,0, 0,0.002246634^2,0,0, 0,0,0.002193375^2,0, 0,0,0,0),4,4),
                                          lnRRFormer = log(1),
                                          varLnRRFormer = 0)  

                          
                          
















## data for the various diseases, separatly for men and women
## information includes:
## disease: name of the disease
## RRCurrent: relative risk function for the (current) drinkers
## betaCurrent: coefficients for the RR function of (current) drinkers
## covBetaCurrent: covariance matrix for the beta coefficients of the (current) drinkers
## lnRRFormer: log relative risk of former drinkers
## varLnRRFormer: variance of log relative risk estimate of former drinkers



####### Oral Cavity and Pharynx Cancer #######
####### Oral Cavity and Pharynx Cancer #######
## male
oralcancer_male = list(disease = "Oral_Cavity_and_Pharynx_Cancer",
                       RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                       betaCurrent = c(0,0.02474,-0.00004,0),
                       covBetaCurrent = matrix(c(0,0,0,0, 
                       							  0,0.000002953,-0.0000000127,0, 
                       							  0,-0.0000000127,0.000000000102,0, 
                       							  0,0,0,0),4,4),
                       lnRRFormer = log(1.2),
                       varLnRRFormer = 0.330343005747873^2)
## female
oralcancer_female = list(disease = "Oral_Cavity_and_Pharynx_Cancer",
                         RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                         betaCurrent = c(0,0.02474,-0.00004,0),
                         covBetaCurrent = matrix(c(0,0,0,0, 
                         							0,0.000002953,-0.0000000127,0, 
                         							0,-0.0000000127,0.000000000102,0, 
                         							0,0,0,0),4,4),
                         lnRRFormer = log(1.2),
                         varLnRRFormer = 0.330343005747873^2)


####### Oesophagus SCC Cancer ###########  
####### Oesophagus SCC Cancer ###########
## male
Oesophagus_SCC_cancer_male = list(disease = "Oesophagus_SCC_Cancer",
                                  RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x*log(x)*beta[4])},
                                  betaCurrent = c(0,0.05593,0,-0.00789),
                                  covBetaCurrent = matrix(c(0,0,0,0, 
                                  							0,0.000065,0,-0.00001, 
                                  							0,0,0,0, 0,-0.00001,0,0.00000264),4,4),
                                  lnRRFormer = log(1.16),
                                  varLnRRFormer = 0.243480229040442^2)
## female
Oesophagus_SCC_cancer_female = list(disease = "Oesophagus_SCC_Cancer",
                                    RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x*log(x)*beta[4])},
                                    betaCurrent = c(0,0.05593,0,-0.00789),
                                    covBetaCurrent = matrix(c(0,0,0,0, 0,0.000065,0,-0.00001, 0,0,0,0, 0,-0.00001,0,0.00000264),4,4),
                                    lnRRFormer = log(1.16),
                                    varLnRRFormer = 0.243480229040442^2)


# ####### Oesophagus Cancer ###########
# ####### Oesophagus Cancer ###########
## male
 oesophaguscancer_male = list(disease = "Oesophagus_Cancer",
                                  RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                  betaCurrent = c(0,0.0132063596418668,0,-4.14801974664481*10^(-08)),
                                  covBetaCurrent = matrix(c(0,0,0,0,0,1.5257062507551*10^(-07),0,-6.88520511004078*10^(-13),0,0,0,0,0,-6.88520511004078*10^(-13),0,8.09350992351893*10^(-18)),4,4),
                                  lnRRFormer = log(1.16),
                                  varLnRRFormer = 0.243480229040442^2)
  ## female
  oesophaguscancer_female = list(disease = "Oesophagus_Cancer",
                                  RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                  betaCurrent = c(0,0.0132063596418668,0,-4.14801974664481*10^(-08)),
                                  covBetaCurrent =  matrix(c(0,0,0,0,0,1.5257062507551*10^(-07),0,-6.88520511004078*10^(-13),0,0,0,0,0,-6.88520511004078*10^(-13),0,8.09350992351893*10^(-18)),4,4),
                                  lnRRFormer = log(1.16),
                                  varLnRRFormer = 0.243480229040442^2)


####### Stomach Cancer ###########
####### Stomach Cancer ###########
## male
Stomachcancer_male = list(disease = "Stomach_Cancer",
                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                          betaCurrent = c(0,-0.00058,0.000034,0),
                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.000001038,-0.00000000479,0, 0,-0.00000000479,0.0000000000225,0, 0,0,0,0),4,4),
                          lnRRFormer = log(1.21),
                          varLnRRFormer = 0.0465106^2)
## female
Stomachcancer_female = list(disease = "Stomach_Cancer",
                            RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                            betaCurrent = c(0,-0.00058,0.000034,0),
                            covBetaCurrent = matrix(c(0,0,0,0, 0,0.000001038,-0.00000000479,0, 0,-0.00000000479,0.0000000000225,0, 0,0,0,0),4,4),
                            lnRRFormer = log(1.44),
                            varLnRRFormer = 0.0585138^2)



####### Small intestine Cancer ###########  
####### Small intestine Cancer ###########
## male
Small_intestine_cancer_male = list(disease = "Small_intestine_Cancer",
                                   RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                   betaCurrent = c(0,0.000535,0,0),
                                   covBetaCurrent = matrix(c(0,0,0,0, 0,0.00000505,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                   lnRRFormer = log(1.21),
                                   varLnRRFormer = 0.0465106^2)
## female
Small_intestine_cancer_female = list(disease = "Small_intestine_Cancer",
                                     RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                     betaCurrent = c(0,0.000535,0,0),
                                     covBetaCurrent = matrix(c(0,0,0,0, 0,0.00000505,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                     lnRRFormer = log(1.44),
                                     varLnRRFormer = 0.0585138^2) 



####### Colorectal cancer #######
####### Colorectal cancer #######

#### Source: Vieira et al., 2017

#### Male ####
colorectalcancer_male = list(disease = "Colorectal_Cancer",
                             RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                             betaCurrent = c(0, 0.006765865, 0, 0),
                             covBetaCurrent = matrix(c(0,0,0,0,0, 0.000953764^2,0,0,0,0,0,0,0, 0,0,0),4,4),
                             lnRRFormer = log(2.19),
                             varLnRRFormer = 0.0465106^2)

#### Female ####
colorectalcancer_female = list(disease = "Colorectal_Cancer",
                               RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                               betaCurrent =c(0, 0.006765865, 0, 0),
                               covBetaCurrent = matrix(c(0,0,0,0,0, 0.000953764^2,0,0,0,0,0,0,0, 0,0,0),4,4),
                               lnRRFormer = log(1.05),
                               varLnRRFormer = 0.145968002587317^2)




######## Liver Cancer ########
######## Liver Cancer ########

#### Source: WCRF 2015

#### Male ####
Livercancer_male = list(disease = "Liver_Cancer",
  RRCurrent = function(x, beta){exp(x * beta[2] )},
  betaCurrent = c(0,0.003922071, 0,0),
  covBetaCurrent = matrix(c(0,0,0,0, 0,0.000981283^2,0,0,0,0,0,0,0,0,0,0),4,4),
  lnRRFormer = log(2.23),
  varLnRRFormer = 0.259097757^2)

#### Female ####
Livercancer_female = list(disease = "Liver_Cancer",
  RRCurrent = function(x, beta){exp(x * beta[2] )},
  betaCurrent = c(0,0.003922071, 0,0),
  covBetaCurrent = matrix(c(0,0,0,0, 0,0.000981283^2,0,0,0,0,0,0,0,0,0,0),4,4),
  lnRRFormer = log(2.68),
  varLnRRFormer = 0.272560609^2)






######## Liver Cancer ########  NEW FUNCTION NOT APPLICABLE
######## Liver Cancer ########  NEW FUNCTION NOT APPLICABLE
# 
# ## male
# Livercancer_male = list(disease = "Liver_Cancer",
#                         RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^(0.5)*beta[4])},
#                         betaCurrent = c(0,0,0.00017,-0.00069),
#                         covBetaCurrent = matrix(c(0,0,0,0, 0,0.000000000879,0,-0.000000179, 0,0,0,0, 0,-0.000000179,0,0.000164),4,4),
#                         lnRRFormer = log(1.54),
#                         varLnRRFormer = 0.12774879793686^2)
# ## female
# Livercancer_female = list(disease = "Liver_Cancer",
#                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^(0.5)*beta[4])},
#                           betaCurrent = c(0,0,0.00017,-0.00069),
#                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.000000000879,0,-0.000000179, 0,0,0,0, 0,-0.000000179,0,0.000164),4,4),
#                           lnRRFormer = log(2.28),
#                           varLnRRFormer = 0.480350887117275^2)  


######## Gallbladder Cancer ########  
######## Gallbladder Cancer ########
## male
Gallbladdercancer_male = list(disease = "Gallbladder_Cancer",
                              RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                              betaCurrent = c(0,0.006703,0,0),
                              covBetaCurrent = matrix(c(0,0,0,0, 0,0.000005849,0,0, 0,0,0,0, 0,0,0,0),4,4),
                              lnRRFormer = log(1.21),
                              varLnRRFormer = 0.0465106^2)
## female
Gallbladdercancer_female = list(disease = "Gallbladder_Cancer",
                                RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                betaCurrent = c(0,0.006703,0,0),
                                covBetaCurrent = matrix(c(0,0,0,0, 0,0.000005849,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                lnRRFormer = log(1.44),
                                varLnRRFormer = 0.0585138^2)  


######## Pancreas Cancer ########  
######## Pancreas Cancer ########
## male
Pancreascancer_male = list(disease = "Pancreas_Cancer",
                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,0.002089,0,0),
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000002426,0,0, 0,0,0,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1.21),
                           varLnRRFormer = 0.0465106^2)
## female
Pancreascancer_female = list(disease = "Pancreas_Cancer",
                             RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                             betaCurrent = c(0,0.002089,0,0),
                             covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000002426,0,0, 0,0,0,0, 0,0,0,0),4,4),
                             lnRRFormer = log(1.44),
                             varLnRRFormer = 0.0585138^2)  


######## Larynx Cancer #########  
######## Larynx Cancer #########
#### male ####
Larynxcancer_male = list(disease = "Larynx_Cancer",
                         RRCurrent = function (x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                         betaCurrent = c(0,0.01462,-0.00002,0), 
                         covBetaCurrent = matrix(c(0,0,0,0, 0,0.000003585,-0.0000000162,0, 0,-0.0000000162,0.000000000126,0, 0,0,0,0),4,4),
                         lnRRFormer = log(1.18),
                         varLnRRFormer = 0.288991189^2)
#### female ####
Larynxcancer_female = list(disease = "Larynx_Cancer",
                           RRCurrent = function (x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,0.01462,-0.00002,0), 
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.000003585,-0.0000000162,0, 0,-0.0000000162,0.000000000126,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1.18),
                           varLnRRFormer = 0.288991189^2)  


######## Lung Cancer ########  
######## Lung Cancer ########
## male
Lungcancer_male = list(disease = "Lung_Cancer",
                       RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                       betaCurrent = c(0,0.002149,0,0),
                       covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000004808,0,0, 0,0,0,0, 0,0,0,0),4,4),
                       lnRRFormer = log(1.21),
                       varLnRRFormer = 0.0465106^2)
## female
Lungcancer_female = list(disease = "Lung_Cancer",
                         RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                         betaCurrent = c(0,0.002149,0,0),
                         covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000004808,0,0, 0,0,0,0, 0,0,0,0),4,4),
                         lnRRFormer = log(1.44),
                         varLnRRFormer = 0.0585138^2)  


######## Melanoma Cancer ########  
######## Melanoma Cancer ########
## male
Melanomacancer_male = list(disease = "Melanoma_Cancer",
                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,0.01089,0,0),
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.000019,0,0, 0,0,0,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1.21),
                           varLnRRFormer = 0.0465106^2)
## female
Melanomacancer_female = list(disease = "Melanoma_Cancer",
                             RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                             betaCurrent = c(0,0.01089,0,0),
                             covBetaCurrent = matrix(c(0,0,0,0, 0,0.000019,0,0, 0,0,0,0, 0,0,0,0),4,4),
                             lnRRFormer = log(1.44),
                             varLnRRFormer = 0.0585138^2)  



####### Breast Cancer #######
####### Breast Cancer #######

#### Source: Sun et al., 2020

#### Male ####
#Place holder only DO NOT USE AS AAF
Breastcancer_male = list(disease = "Breast_Cancer",
                         RRCurrent = function (x, beta) {return(1)},
                         betaCurrent = c(0,0,0,0),
                         covBetaCurrent = matrix(c(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),4,4),
                         lnRRFormer = log(1),
                         varLnRRFormer = 0)

#### Female ####
Breastcancer_female = list(disease = "Breast_Cancer", 
                           RRCurrent = function (x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,0.009116078,0,0),
                           covBetaCurrent = matrix(c(0,0,0,0,0,0.001046086^2,0,0,0,0,0,0,0,0,0,0),4,4),
                           lnRRFormer = log(1),
                           varLnRRFormer = 0^2)



#### Female NEW####
Breastcancer_female = list(disease = "Breast_Cancer", 
                           RRCurrent = function (x, beta) {exp( x*beta[2] + 
                           									     beta[3] * (pmax((x - 5.0)/((37.5 - 5.0)^(2/3)), 0)^3 + ((15.0 - 5.0) * pmax((x - 37.5)/ ((37.5 - 5.0)^(2/3)), 0)^3 - (37.5 - 5.0) * 
        																		(pmax((x - 15.0)/((37.5 - 5.0)^(2/3)), 0)^3))/ (37.5 - 15.0))
        																		 )},
                           betaCurrent = c(0, 0.0095,-0.0087,0),
                           covBetaCurrent = matrix(c(0,0,0,0,
                           							0,6.78E-07,-1.13E-06,0,
                           							0,-1.13E-06,2.39E-06,0,
                           							0,0,0,0),4,4),
                           lnRRFormer = log(1),
                           varLnRRFormer = 0^2)










######## Cervix Cancer ########  
######## Cervix Cancer ########
## male
#Place holder only DO NOT USE AS AAF
Cervixcancer_male = list(disease = "Cervix_Cancer",
                         RRCurrent = function(x, beta) {return(1)},
                         betaCurrent = c(0,0,0,0),
                         covBetaCurrent = matrix(c(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0),4,4),
                         lnRRFormer = log(1),
                         varLnRRFormer = 0)
## female
Cervixcancer_female = list(disease = "Cervix_Cancer",
                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,-0.00566,0,0),
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.000037,0,0, 0,0,0,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1),
                           varLnRRFormer = 0)  


######## Endometrium Cancer ########  
######## Endometrium Cancer ########
## male
#Place holder only DO NOT USE AS AAF
Endometriumcancer_male = list(disease = "Endometrium_Cancer",
                              RRCurrent = function(x, beta) {return(1)},
                              betaCurrent = c(0,0,0,0),
                              covBetaCurrent = matrix(c(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0),4,4),
                              lnRRFormer = log(1),
                              varLnRRFormer = 0)
## female
Endometriumcancer_female = list(disease = "Endometrium_Cancer",
                                RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                betaCurrent = c(0,-0.00129,0,0),
                                covBetaCurrent = matrix(c(0,0,0,0, 0,0.000014,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                lnRRFormer = log(1.44),
                                varLnRRFormer = 0.0585138^2)  


######## Ovary Cancer ########  
######## Ovary Cancer ########
## male
#Place holder only DO NOT USE AS AAF
Ovarycancer_male = list(disease = "Ovary_Cancer",
                        RRCurrent = function(x, beta) {return(1)},
                        betaCurrent = c(0,0,0,0),
                        covBetaCurrent = matrix(c(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0),4,4),
                        lnRRFormer = log(1),
                        varLnRRFormer = 0)
## female
Ovarycancer_female = list(disease = "Ovary_Cancer",
                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                          betaCurrent = c(0,0.000926,0,0),
                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000011,0,0, 0,0,0,0, 0,0,0,0),4,4),
                          lnRRFormer = log(1.44),
                          varLnRRFormer = 0.0585138^2)  


######## Prostate Cancer ########  
######## Prostate Cancer ########
## male
Prostatecancer_male = list(disease = "Prostate_Cancer",
                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,0.001475,0,0),
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000003216,0,0, 0,0,0,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1.21),
                           varLnRRFormer = 0.0465106^2)
## female
Prostatecancer_female = list(disease = "Prostate_Cancer",
                             RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                             betaCurrent = c(0,0.001475,0,0),
                             covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000003216,0,0, 0,0,0,0, 0,0,0,0),4,4),
                             lnRRFormer = log(1.44),
                             varLnRRFormer = 0.0585138^2)  


######## Bladder Cancer ########  
######## Bladder Cancer ########
## male
Bladdercancer_male = list(disease = "Bladder_Cancer",
                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                          betaCurrent = c(0,0.000541,0,0),
                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.00000204,0,0, 0,0,0,0, 0,0,0,0),4,4),
                          lnRRFormer = log(1.21),
                          varLnRRFormer = 0.0465106^2)
## female
Bladdercancer_female = list(disease = "Bladder_Cancer",
                            RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                            betaCurrent = c(0,0.000541,0,0),
                            covBetaCurrent = matrix(c(0,0,0,0, 0,0.00000204,0,0, 0,0,0,0, 0,0,0,0),4,4),
                            lnRRFormer = log(1.44),
                            varLnRRFormer = 0.0585138^2)  


######## Kidney Cancer ########  
######## Kidney Cancer ########
## male
Kidneycancer_male = list(disease = "Kidney_Cancer",
                         RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                         betaCurrent = c(0,-0.01538,0.000105,0),
                         covBetaCurrent = matrix(c(0,0,0,0, 0,0.000008239,-0.0000000764,0, 0,-0.0000000764,0.000000001178,0, 0,0,0,0),4,4),
                         lnRRFormer = log(1),
                         varLnRRFormer = 0)
## female
Kidneycancer_female = list(disease = "Kidney_Cancer",
                           RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                           betaCurrent = c(0,-0.01538,0.000105,0),
                           covBetaCurrent = matrix(c(0,0,0,0, 0,0.000008239,-0.0000000764,0, 0,-0.0000000764,0.000000001178,0, 0,0,0,0),4,4),
                           lnRRFormer = log(1),
                           varLnRRFormer = 0)  


######## Thyroid Cancer ########  
######## Thyroid Cancer ########
## male
Thyroidcancer_male = list(disease = "Thyroid_Cancer",
                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                          betaCurrent = c(0,-0.01794,0.000334,0),
                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.00004,-0.000000826,0, 0,-0.000000826,0.00000002368,0, 0,0,0,0),4,4),
                          lnRRFormer = log(1),
                          varLnRRFormer = 0)
## female
Thyroidcancer_female = list(disease = "Thyroid_Cancer",
                            RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                            betaCurrent = c(0,-0.01794,0.000334,0),
                            covBetaCurrent = matrix(c(0,0,0,0, 0,0.00004,-0.000000826,0, 0,-0.000000826,0.00000002368,0, 0,0,0,0),4,4),
                            lnRRFormer = log(1),
                            varLnRRFormer = 0)    


######## Brain Cancer ########  
######## Brain Cancer ########
## male
Braincancer_male = list(disease = "Brain_Cancer",
                        RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                        betaCurrent = c(0,0.003319,0,0),
                        covBetaCurrent = matrix(c(0,0,0,0, 0,0.000014,0,0, 0,0,0,0, 0,0,0,0),4,4),
                        lnRRFormer = log(1.21),
                        varLnRRFormer = 0.0465106^2)
## female
Braincancer_female = list(disease = "Brain_Cancer",
                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                          betaCurrent = c(0,0.003319,0,0),
                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.000014,0,0, 0,0,0,0, 0,0,0,0),4,4),
                          lnRRFormer = log(1.44),
                          varLnRRFormer = 0.0585138^2)  


######## Hodgkin Lymphoma Cancer ########  
######## Hodgkin Lymphoma Cancer ########
## male
Hodgkin_Lymphoma_cancer_male = list(disease = "Hodgkin_Lymphoma_Cancer",
                                    RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                    betaCurrent = c(0,-0.00652,0,0),
                                    covBetaCurrent = matrix(c(0,0,0,0, 0,0.000004923,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                    lnRRFormer = log(1),
                                    varLnRRFormer = 0)
## female
Hodgkin_Lymphoma_cancer_female = list(disease = "Hodgkin_Lymphoma_Cancer",
                                      RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                      betaCurrent = c(0,-0.00652,0,0),
                                      covBetaCurrent = matrix(c(0,0,0,0, 0,0.000004923,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                      lnRRFormer = log(1),
                                      varLnRRFormer = 0)  


######## Non_Hodgkin_Lymphoma Cancer ########  
######## Non_Hodgkin_Lymphoma Cancer ########
## male
Non_Hodgkin_Lymphoma_cancer_male = list(disease = "Non_Hodgkin_Lymphoma",
                                        RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                        betaCurrent = c(0,-0.00423,0,0),
                                        covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000011,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                        lnRRFormer = log(1),
                                        varLnRRFormer = 0)
## female
Non_Hodgkin_Lymphoma_cancer_female = list(disease = "Non_Hodgkin_Lymphoma",
                                          RRCurrent = function(x, beta) {exp(1*beta[1] + x*beta[2] + x^2*beta[3] + x^3*beta[4])},
                                          betaCurrent = c(0,-0.00423,0,0),
                                          covBetaCurrent = matrix(c(0,0,0,0, 0,0.0000011,0,0, 0,0,0,0, 0,0,0,0),4,4),
                                          lnRRFormer = log(1),
                                          varLnRRFormer = 0)  





relativeriskmale_GENERAL = list(epilepsymale,
                        pancreatitismale,
                        tuberculosismale,
                        lowerrespmale,
                        hemorrhagicstrokemale,
                        diabetesmale,
                        livercirrhosismale,
                        #conductiondisordermale,
                        HIVmale,
                        hypertension_male)

relativeriskfemale_GENERAL = list(epilepsyfemale,
                          pancreatitisfemale,
                          tuberculosisfemale,
                          lowerrespfemale, 
                          hemorrhagicstrokefemale, 
                          diabetesfemale,
                          livercirrhosisfemale, 
                          #conductiondisorderfemale, 
                          HIVfemale,
                          hypertension_female ) 







relativeriskmale_CANCER = list(oralcancer_male,
                        oesophaguscancer_male,                     
                        colorectalcancer_male,
                        Livercancer_male,
                        Larynxcancer_male,
                        Breastcancer_male)

relativeriskfemale_CANCER = list(oralcancer_female,
                          oesophaguscancer_female,
                          colorectalcancer_female,
                          Livercancer_female,
                          Larynxcancer_female,
                          Breastcancer_female) 











