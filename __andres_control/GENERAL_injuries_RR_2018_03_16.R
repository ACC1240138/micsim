## The relative risk for injuries is based on the results by Corrao et al from 2014.
## To account for the drinking pattern, the relative risk has an additional coefficient
## that ranges from 1 to 2, multiplying the relative risk function from Corrao. Using the 
## exposure data from 2012, the maximum and minimum values of %Bingers among drinkers was
## found, and the coefficient designed so that for the lowest value, the coefficient is 1
## and for the highest value the coefficient is 2. 






### male ###
injuries_other = list(disease = "Injuries_other",
                     RRCurrent = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[1]) 
                                                                 , exp(beta[1] * x ) ),1)} ,
                     betaCurrent = c(0.00199800266267306,0,0,0),
                     covBetaCurrent = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer = log(1),
                    varLnRRFormer = 0,

					 disease_binge = "Injuries_other",
                     RRCurrent_binge = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[2] + beta[1]) 
                                                                 ,  exp(beta[2] + beta[1] * x) ),1)},
                     betaCurrent_binge = c(0.00199800266267306,0.647103242058538,0,0),
                     covBetaCurrent_binge = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0.155119431459533^2,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer_binge = log(1),
                    varLnRRFormer_binge = 0)

injuries_other_int = list(disease = "Injuries_other_intentional",
                     RRCurrent = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[1]) 
                                                                 , exp(beta[1] * x ) ),1)},
                     betaCurrent = c(0.00199800266267306,0,0,0),
                     covBetaCurrent = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer = log(1),
                    varLnRRFormer = 0,

					 disease_binge = "Injuries_other_intentional",
                     RRCurrent_binge = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[2] + beta[1])
                                                                 ,  exp(beta[2] + beta[1] * x) ),1)},
                    
                     betaCurrent_binge = c(0.00199800266267306,0.56531380905006,0,0),
                     covBetaCurrent_binge = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0.247540294169498^2,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer_binge = log(1),
                    varLnRRFormer_binge = 0)



injuries_other_unit = list(disease = "Injuries_other_untentional",
                     RRCurrent = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[1])
                                                                 , exp(beta[1] * x ) ),1)},
                     betaCurrent = c(0.00199800266267306,0,0,0),
                     covBetaCurrent = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer = log(1),
                    varLnRRFormer = 0,
                    
					disease_binge = "Injuries_other_untentional",
                     RRCurrent_binge = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[2] + beta[1])
                                                                 ,  exp(beta[2] + beta[1] * x) ),1)},
                     betaCurrent_binge = c(0.00199800266267306, 0.703097511413113,0,0),
                     covBetaCurrent_binge = matrix (c(0.000509185879264017^2,0,0,0,
                                               0,0.198243000172775^2,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer_binge = log(1),
                    varLnRRFormer_binge = 0)




injuries_MVA = list(disease = "Injuries_MVA",
                     RRCurrent = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1, exp(beta[1])
                                                                 , exp(beta[1] * x ) ),1)},
                     betaCurrent = c(0.00299550897979837,0,0,0),
                     covBetaCurrent = matrix (c(0.000508678216036836^2,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer = log(1),
                    varLnRRFormer = 0,
                    
                    disease_binge = "Injuries_MVA",
                     RRCurrent_binge = function(x, beta){ifelse(x>=0,
                                                          ifelse(x<1,  exp(beta[2] + beta[1] )
                                                                 ,  exp(beta[2] + beta[1] * x) ),1)},
                     betaCurrent_binge = c(0.00299550897979837,0.959350221334602,0,0),
                     covBetaCurrent_binge = matrix (c(0.000508678216036836^2,0,0,0,
                                               0,0.227875857649849^2,0,0,
                                               0,0,0,0,
                                               0,0,0,0),4,4),
                    lnRRFormer_binge = log(1),
                    varLnRRFormer_binge = 0)






#### Creating a list of the diseases #####
relativeriskmale 		<- list(injuries_other, injuries_other_int, injuries_other_unit, injuries_MVA )
relativeriskfemale 		<- list(injuries_other, injuries_other_int, injuries_other_unit, injuries_MVA )