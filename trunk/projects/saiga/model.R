# Joe's current Saiga Offset model

# realias variables to tzar for backwards compatibility
tzar <- variables

set.seed(33)

# Var renames
PAR.Ak <- tzar[['PAR.Ak']]
PAR.NsWE <- tzar[['PAR.NsWE']]
PAR.NsNS <- tzar[['PAR.NsNS']]
PAR.years <- tzar[['PAR.years']]

PAR.Prate <- tzar[['PAR.Prate']]
PAR.kaz.poach <- tzar[['PAR.kaz.poach']]
PAR.uz.imm <- tzar[['PAR.uz.imm']]

PAR.saiga.output.matrix <- tzar[['PAR.saiga.output.matrix']]

OPT.Prate <- tzar[['OPT.Prate']]
OPT.offset <- tzar[['OPT.offset']]


Ns <- tzar[['PAR.NsWE']] * tzar[['PAR.NsNS']]  	#Ns is the number of sites defined
cat( '\n\nNEW CODE!!! Ns=', Ns)

As <- tzar[['PAR.Ak']] / Ns  		#As is the area of each site
Nv <- 1			                    #Nv is the number of site variables
cat( '\n\n As=', As)
cat( '\n\n Nv=', Nv)

StudyArea <- matrix(NA, nrow=PAR.NsWE, ncol=PAR.NsNS) #Basic polygon
StudyArea[] <- 1:Ns
StudyArea <- t(StudyArea)

#------------------------------------------------------------------------------#

#GIVE POLYGON THE INITIAL USTYURT CHARACTERISTICS

Kara <- StudyArea  		#Karakalpakstan is the study area
Kara[] <- 1

Kara[47,1:70] <- 0		#Railways

Kara[48,7] <- 0			  #Jaslyk town
Kara[48,43] <- 0			#Karakalpakstan town


#CREATE STARTING MATRICES FOR EACH INDEPENDENT VARIABLE

#ndvi

NDVI <- matrix(NA, ncol=PAR.NsWE, nrow=PAR.NsNS)
NDVI[] <- runif(Ns, min=0.1, max=0.3)

#climatic factors

Tmean <- matrix(NA, ncol=PAR.NsWE, nrow=PAR.NsNS)  #Mean temperature
Tmean[] <- -10

Tmax <- matrix(NA, ncol=PAR.NsWE, nrow=PAR.NsNS)	#Max temperature
Tmax[] <- 10

Tmin <- matrix(NA, ncol=PAR.NsWE, nrow=PAR.NsNS)	#Min temperature
Tmin[] <- -20

Prec <- matrix(NA, ncol=PAR.NsWE, nrow=PAR.NsNS)	#Precipitation
Prec[] <- 10
PrecBase <- Prec

Dzhut1 <- 0.5					#Likelihood of a dzhut
Dzhut2 <- sample(seq(0,1,by=0.2),1,replace=T)
if(Dzhut2>Dzhut1){Dzhut<-1}else{Dzhut<-0}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

#MAIN MODEL LOOP

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

#PAR.years <- 2  			#time period of model run
time  <- 1				    #model starts at time=0

TSaiga <- 600			#initial Ustyurt Saiga population
Smat <- matrix(0, ncol=PAR.NsWE, nrow=PAR.NsNS)	#Saiga matrix

					        #Create other necessary matrices

Pmat <- matrix(0, ncol=PAR.NsWE, nrow=PAR.NsNS)
#PAR.Prate <- 0.44			#Poaching rate

OGmat <- matrix(1, ncol=PAR.NsWE, nrow=PAR.NsNS)
BOmat <- matrix(0, ncol=PAR.NsWE, nrow=PAR.NsNS)

Sett <- Kara			
Sett[47,1:70] <- 1		#Settlement matrix excludes railway
Grate <- 0.06			    #Population growth rate

Rmat <- matrix(NA, nrow=PAR.years, ncol=8)
colnames(Rmat)<-c("Time","Saiga","Poached","Offsets","Veg","O&G","Condition", "Prate")

#------------------------------------------------------------------------------#

#Biodiversity Offsets used

if(OPT.offset == "none"){NULL}

  	#Proposed Saigachy offset
	  	if(OPT.offset == "saigachy"){BOmat[1:14,] <- 1}
      #BOmat[1:14,] <- 1


		#One type of offset, not spatially selective
    	#for(n in 1:OG)	{
		  #i <- sample(seq(1,PAR.NsNS,by=1),1,replace=F)
		  #j <- sample(seq(1,PAR.NsWE,by=1),1,replace=F)

      #if(BOmat[i,j]==1){OG <- OG + 1}
      #if(Kara[i,j]==0){OG <- OG + 1}
      #if(BOmat[i,j]!=1 & Kara[i,j]!=0){BOmat[i,j] <- 1}

		  #		}

#------------------------------------------------------------------------------#

#The run begins

for(m in 1:PAR.years){

  NDVI <- NDVI * Kara  #Update NDVI with available sites


	#Some of the Saiga arrive in Uzbekistan (ratio from population data)
	sd.uz.imm <- PAR.uz.imm * 0.5
  Stemp <- rnorm(1, PAR.uz.imm, sd.uz.imm)
  if(Stemp<0){Stemp <- 0}
	#Stemp2 <- 1 + Stemp
  Saiga <- as.integer(TSaiga * Stemp)

	Rmat[m,1] <- time
  Rmat[m,2] <- Saiga

#------------------------------------------------------------------------------#
  
#The Saiga choose the sites with the highest NDVI (north of the railway), and the Saiga matrix is updated to show where they are

NDVIt <- NDVI[1:46,1:PAR.NsWE]

for(k in 1:Saiga)	{
		q<-1

  for(j in 1:PAR.NsWE)	{
	  p<-1
			  for(i in 1:46)	{
        if(NDVIt[i,j]==max(NDVIt)){Smat[i,j] <- 1
        break}

        if(NDVIt[i,j]!=max(NDVIt)){p<-p+1}

						            }
		    if(NDVIt[i,j]==max(NDVIt)){break}
		    if(NDVIt[i,j]!=max(NDVIt)){q<-q+1}

					}

NDVIt[p,q]<-0.966*NDVIt[p,q]

				}

	NDVI <- rbind(NDVIt,NDVI[47:PAR.NsNS,])

#------------------------------------------------------------------------------#
  
#The Saiga population is partially poached

if(Saiga<=0)	{
	Saiga <- 0
	Poached <- 0
  Ptemp <- 0
			}

if(Saiga>0)	{

for(j in 1:PAR.NsWE)	{
		for(i in 1:46)	{
      Pmat[i,j] <- sample(seq(0,1,by=0.01),1,replace=T)
		  }

			}
	SBP <- sum(Smat)

	Smat <- Smat*Pmat

  if(OPT.Prate == "baseline"){NULL}
  if(OPT.Prate == "one.over.t"){PAR.Prate <- PAR.Prate * (1/time)}
  
  sdp <- PAR.Prate * 0.2
  Ptemp <- rnorm(1, mean = PAR.Prate, sd = sdp)
  if(Ptemp<0){Ptemp<-0}

for(j in 1:PAR.NsWE)	{
		for(i in 1:46)	{
if(Smat[i,j]>=Ptemp){Smat[i,j]<-1}
if(Smat[i,j]<Ptemp & BOmat[i,j]!=1){Smat[i,j]<-0}
if(Smat[i,j]<Ptemp & Smat[i,j]>0 & BOmat[i,j]==1){Smat[i,j]<-1}	
					}

			}

  #Subsequent Saiga population
	Saiga <- sum(Smat[1:PAR.NsWE,1:46])		

  #No. Saiga poached
  Poached <- as.integer(SBP-Saiga)		

			}


	#Log these results (Saiga pop)
	Rmat[m,3] <- Poached

#------------------------------------------------------------------------------#
  
#Settlements grow at a rate of 6% a year

  #SettA <- sum(Sett)
	#SettA <- Ns – SettA				#Number of settled sites
	#Grow <- as.integer(Grate*SettA)	#Number of sites to grow

  #for(p in 1:Grow)	{
	#	for(j in 1:PAR.NsWE)	{
	#		for(i in 1:PAR.NsNS)	{
  #if(i!=1 & i!=PAR.NsNS & j!=1 & j!= PAR.NsWE & #Sett[i,j]==0)	{ 
  #if(BOmat[i-1,j-1]!=1){Sett[i-1,j-1]<-0}
  #if(BOmat[i-1,j]!=1){Sett[i-1,j]<-0}
  #if(BOmat[i-1,j+1]!=1){Sett[i-1,j+1]<-0}
  #if(BOmat[i,j+1]!=1){Sett[i,j+1]<-0}
  #if(BOmat[i+1,j+1]!=1){Sett[i+1,j+1]<-0}
  #if(BOmat[i-1,j]!=1){Sett[i+1,j]<-0}
  #if(BOmat[i+1,j-1]!=1){Sett[i+1,j-1]<-0}
  #if(BOmat[i,j-1]!=1){Sett[i,j-1]<-0}
				#			}
				#		}
				#	}
#}

#------------------------------------------------------------------------------#
  
#Climate changes
  
  #Tmean <- Tmean + 0.0457			###UNFCCC Uz 2009 B2

  #Prec <- PrecBase * 0.0144		###UNFCCC Uz 2009 B2

#NDVI varies for next year

	#NDVI <- NDVI * 0.9018			###UNFCCC Uz 2009 B2

#------------------------------------------------------------------------------#
  
#Remnant Saiga population migrate to Kazakhstan

	  Smat[] <- 0
  	TSaiga <- TSaiga - Poached


    #Saiga reproduce and die - RATES NEED CHECKING (Kuehl, 2008?)
	  lambda <- rnorm(1,1.3,0.2)
  	TSaiga <- as.integer(TSaiga * lambda)

    #Saiga mortality (poaching) in Kazakh - RATES NEED CHECKING
	  sd.kaz.poach <- PAR.kaz.poach * 0.5
    KazPo <- rnorm(1, PAR.kaz.poach, sd.kaz.poach)
    if(KazPo<0){KazPo <- 0}
	  temp1 <- 1 - KazPo
  	TSaiga <- as.integer(TSaiga * temp1)

#------------------------------------------------------------------------------#
  
#Industrial development and Offsets in region

	#OG <- 20		#Number of sites developed by O&G a year
	
  #for(n in 1:OG)	{
		#i <- sample(seq(1,PAR.NsNS,by=1),1,replace=F)
		#j <- sample(seq(1,PAR.NsWE,by=1),1,replace=F)
		#if(BOmat[i,j]!=1){OGmat[i,j] <- 0}
		#		}

	  #Ind1 <- sum(OGmat)
  	#Ind2 <- Ns - Ind1
	  #Rmat[m,6] <- Ind2


	Offsets <- sum(BOmat)
	Rmat[m,4] <- Offsets

#------------------------------------------------------------------------------#
  
#Settlement growth, O&G development and veg condition are recorded

	Kara <- Kara * Sett
	#Kara <- Kara * OGmat

	Veg <- sum(Kara)
	Rmat[m,5] <- Veg

  Cond <- sum(NDVI)
  Rmat[m,7] <- Cond
  
  Rmat[m,8] <- Ptemp
  
	#Log the results
	#temp1 <- sum(BOmat)
	#temp2 <- sum(OGmat)
	#temp3 <- Ns – temp2
	#Rmat[m,3] <- temp1
	#Rmat[m,4] <- temp3


	###End of time step
	time <- time + 1

	}

#Rmat

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#


