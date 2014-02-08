#===============================================================================

#  source ("getTruePresForEachSpp.R")

#===============================================================================

#  History

#  2014 02 07 - BTL - Created.
#  Extracted from old createTruePresences.R from guppy project and
#  from guppy/genTruePresencesPyper.R.  
#  Also, code for computing the number of true presences is derived 
#  from code in guppy/computeSppDistributions.R.

#===============================================================================
#===============================================================================
#===============================================================================

    #  The following XY functions are copied from the start of 
    #  genTruePresencesPyper.R.
    #
    #  I hope to be able to replace them with functions related to the Raster 
    #  classes for dealing with pixel layers.

#===============================================================================
#===============================================================================
#===============================================================================

xy.rel.to.lower.left.by.row <- function (n, nrow, ncol)
    {
    x = 1 + ((n-1) %% ncol)        #  %% is modulo
    y = nrow - ((n-1) %/% ncol)    #  %/% is integer divide
    
    return ( c (x,y) )
    }

#===============================================================================

#  Copied from guppySupportFunctions.R
#  BUT modified 2013.11.21 by BTL because of error in the original version
#  where it did an integer divide by ncol instead of nrow in calculating the
#  x coordinate.

xy.rel.to.lower.left.by.col <- function (n, nrow, ncol)
    {
    ###    x = 1 + ((n-1) %/% ncol)      #  integer divide  ERROR IN guppySupportFunctions.R VERSION ***
    x = 1 + ((n-1) %/% nrow)      #  integer divide
    
    y = nrow - ((n-1) %% nrow)    #  modulo
    
    return (c (x,y) )
    }

#===============================================================================

spatial.xy.rel.to.lower.left.by.row <- function (n, nrow, ncol, llcorner,  cellsize)    #**** the key function ****#
    {
    xy = xy.rel.to.lower.left.by.row (n, nrow, ncol)
        
        ###    return ( c (xllcorner + (cellsize * x), yllcorner + (cellsize * y) ) )
        ##    return (llcorner + (cellsize * xy))
        #    return (llcorner + ((cellsize * xy) -(cellsize * 0.5)))
    
        #    cat (">>>> (xy - 0.5) = ", (xy - 0.5), ", cellsize = ", cellsize, ", llcorner = ", llcorner)
        #####cat ("\n\nat END of spatial.xy.rel.to.lower.left.by.row()")
        #####cat ("\nretVal = ")
    retVal = (llcorner + (cellsize * (xy - 0.5)))
        #####print (retVal)
    
    return (llcorner + (cellsize * (xy - 0.5)))
    }

#===============================================================================

#  Copied from read.R.


#  THIS FUNCTION IS A REAL PAIN BECAUSE IT ASSUMES A VERY SPECIFIC
#  WAY OF PASSING THE FILE IN AND I CAN NEVER REMEMBER IT, I.E.,
#  FILE STEM WITHOUT THE ".ASC" AS THE FIRST ARGUMENT, THEN
#  PATH TO DIRECTORY WHERE FILE IS STORED BUT MUST HAVE "/" ON THE
#  END OF IT.
#  WOULD LIKE TO BE ABLE TO PASS IT IN ANY WAY THAT I WANT AND THEN
#  HAVE THE FUNCTION FIGURE OUT WHETHER SLASHES AND EXTENSIONS AND
#  PATHS ARE NEEDED...
#
#  ALSO NEED TO HAVE IT INTERFACE WITH SOMETHING THAT RECOVERS ALL
#  THE HEADER INFORMATION AND RETURNS THAT TOO.  I THINK THAT I'VE
#  BUILT SOMETHING LIKE THAT IN PYTHON, BUT NEED TO TRACK IT DOWN.
#  BTL - 2013.12.03


read.asc.file.to.matrix <-
    #        function (base.asc.filename.to.read, input.dir = "./")
    function (base.asc.filename.to.read, input.dir = "")
    {
        ##  name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')
        ##  asc.file.as.matrix <-
        #####  as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
        ##  as.matrix (read.table (paste (input.dir, base.asc.filename.to.read, sep=''),
        ##                           skip=6))
        
        name.of.file.to.read <- paste (base.asc.filename.to.read, '.asc', sep='')
        
        #filename.handed.in = paste (input.dir, base.asc.filename.to.read, sep='')
        filename.handed.in = paste (input.dir, name.of.file.to.read, sep='')
        cat ("\n\n====>>  In read.asc.file.to.matrix(), \n",
             "\tname.of.file.to.read = '", name.of.file.to.read, "\n",
             "\tbase.asc.filename.to.read = '", base.asc.filename.to.read, "\n",
             "\tinput.dir = '", input.dir, "\n",
             "\tfilename.handed.in = '", filename.handed.in, "\n",
             "\n", sep='')
        
        asc.file.as.matrix <-
            #  as.matrix (read.table (paste (input.dir, base.asc.filename.to.read, sep=''),
            as.matrix (read.table (paste (input.dir, name.of.file.to.read, sep=''),
                                   skip=6))
        
        
        
        return (asc.file.as.matrix)
    }

#===============================================================================
#===============================================================================
#===============================================================================

strOfCommaSepNumbersToVec = function (numberString)
    {
        #  Test string to prevent code injection possibility.
        #  Need to do this because the string comes from the yaml file and
        #  ends up getting parsed and evaluated as part of an R expression.
        #
        #  The regular expression here matches any character other than
        #  digits, space, comma, period, and minus sign.
        #  In other words, it looks for anything non-numeric or not
        #  related to making a list, i.e., minus sign, space, decimal point,
        #  or comma.  [It's conceivable we might want to allow 'e' for exponents
        #  or 'i' for imaginary numbers, but I doubt it so I'm omitting them.]
        #  If regexpr() matches any character other than those, then it
        #  returns the index location of where it was found.  Otherwise,
        #  it returns -1.  So, any return greater than 0 means we have a
        #  string that contains something other than what we were expecting
        #  and we should bail out.
        #  Based on last few lines of:
        #   http://www.stat.berkeley.edu/~nolan/stat133/Fall05/lectures/RegEx.html
    if (regexpr("[^0-9, .-]", numberString) > 0)
        {
        stop ("illegal character in list of numbers, i.e., not digit, space, comma, decimal point, or minus sign")
        }

    numStrAsCatCmdStr = paste0 ("c(", numberString, ")")

    return (eval (parse (text = numStrAsCatCmdStr)))
    }

#===============================================================================

getNumTruePresForEachSpp_usingRandom = function (numSppToCreate,
                                                 minTruePresFracOfLandscape,
                                                 maxTruePresFracOfLandscape,
                                                 numCells
                                                 )
    {
        #-------------------------------------------------------------
        #  Draw random true presence fractions and then convert them
        #  into counts.
        #-------------------------------------------------------------

    cat ("\n\nIn getNumTruePresForEachSpp_usingRandom, case: random true pres")
    sppTruePresenceFractionsOfLandscape =
        runif (numSppToCreate,    #  would poisson be better than runif to get typical rank-abundance curve?
               min = minTruePresFracOfLandscape,
               max = maxTruePresFracOfLandscape)

    cat ("\n\nsppTruePresenceFractionsOfLandscape = \n")
    print (sppTruePresenceFractionsOfLandscape)

    spp.true.presence.cts = round (numCells * sppTruePresenceFractionsOfLandscape)
    cat ("\nspp.true.presence.cts = ")
    print (spp.true.presence.cts)

    numTruePresForEachSpp = spp.true.presence.cts
    cat ("\nnumTruePresForEachSpp = ", numTruePresForEachSpp)

    return (numTruePresForEachSpp)
    }

#-------------------------------------------------------------------------------

getNumTruePresForEachSpp_usingSpecifiedCts = function (numTruePresForEachSpp_string,
                                                       numSppToCreate)
    {
        #--------------------------------------------------
        #  Use non-random, fixed counts of true presences
        #  based on fractions specified in the yaml file.
        #--------------------------------------------------

    #		numTruePresForEachSpp = variables$PAR.num.true.presences
    numTruePresForEachSpp =
        strOfCommaSepNumbersToVec (numTruePresForEachSpp_string)

    cat ("\n\nIn getNumTruePresForEachSpp_usingSpecifiedCts, case: NON-random true pres")
    cat ("\n\nnumTruePresForEachSpp = '", numTruePresForEachSpp, "'")
    cat ("\nclass (numTruePresForEachSpp) = '",
         class (numTruePresForEachSpp), "'")
    cat ("\nis.vector (numTruePresForEachSpp) = '",
         is.vector (numTruePresForEachSpp), "'", sep='')
    cat ("\nis.list (numTruePresForEachSpp) = '",
         is.list (numTruePresForEachSpp), "'", sep='')
    cat ("\nlength (numTruePresForEachSpp) = '",
         length (numTruePresForEachSpp), "'", sep='')
    for (i in 1:length (numTruePresForEachSpp))
        cat ("\n\tnumTruePresForEachSpp [", i, "] = ",
             numTruePresForEachSpp[i], sep='')

    if (length (numTruePresForEachSpp) != numSppToCreate)
        {
        stop (paste0 ("\n\nlength (numTruePresForEachSpp) = '",
                      length (numTruePresForEachSpp),
                      "' but numSppToCreate = '", numSppToCreate,
                      "'.\nMust specify same number of presence cts as ",
                      "species to be created.\n\n"))
        }

    return (numTruePresForEachSpp)
    }

#===============================================================================

getTruePresIndicesForOneSpp = function (numTruePresForCurSpp, 
                                        numRows, 
                                        numCols, 
                                        sppGenOutputDirWithSlash,
                                        trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                                        sppName
                                        )
    {
        #    norm.prob.matrix = true.rel.prob.dists.for.spp [[sppID]]
        #        filename = paste (prob.dist.layers.dir.with.slash,
    normProbFilename = paste0 (sppGenOutputDirWithSlash,
                               trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                               ".", sppName
                               #					        '.asc',
                               )
    
        #  BTL - 2013.11.22
        #  IS THIS USING THE OLD ASCII READER OR THE NEW ONE?
        #  LOOKS LIKE IT'S PROBABLY THE OLD ONE SINCE IT LOOKS LIKE IT'S RETURNING
        #  A MATRIX RATHER THAN AN OBJECT.
        #  THIS SEEMS TO BE HAPPENING IN BOTH Guppy.py AND IN genTruePresencesPyper.R.
        #  DO I NEED BOTH A PYTHON AND AN R VERSION OF THIS?
    
    normProbMatrix = read.asc.file.to.matrix (normProbFilename)
    
        #-------------------------------------------------------------
        #  Sample presences from the mapped probability distribution
        #  according to the true relative presence probabilities to
        #  get the TRUE PRESENCES.
        #-------------------------------------------------------------

    
    truePresIndices = sample (1:(numRows * numCols),
                              numTruePresForCurSpp,    #  numTruePresForEachSpp [sppID],
                              replace = FALSE,
                              prob = normProbMatrix)

    return (truePresIndices)
    }

#===============================================================================

    #  Copied from createTruePresences.R, then modified to run more
    #  stand-alone rather than embedded in the R version of guppy.

getTruePresForEachSpp = 
    function (numTruePresForEachSpp,    #  a vector, not a scalar
              trueProbDistFilePrefix,
              fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name
              
              numRows, 
              numCols, 
              
                  #  Values for writing .asc file headers
              llcorner, 
              cellsize, 
              nodataValue     #  not needed here?
              )
    {
    numSppToCreate = length (numTruePresForEachSpp)  #  Or, variables$PAR.num.spp.to.create?
    allSppTruePresLocsXY = vector (mode="list", length=numSppToCreate)
    combinedSppTruePresTable = NULL
    
    for (sppID in 1:numSppToCreate)
        {
        sppName = paste ('spp.', sppID, sep='')
        #sppName = paste ('spp.', (sppID - 1), sep='')    #  to match python...

        numTruePresForCurSpp = numTruePresForEachSpp [sppID]
        
        truePresIndices = getTruePresIndicesForOneSpp (numTruePresForCurSpp, 
                                                       numRows, 
                                                       numCols, 
                                                       sppGenOutputDirWithSlash,
                                                       trueProbDistFilePrefix,    #  Or, variables$PAR.trueProbDistFilePrefix
                                                       sppName)
        
            #----------------------------------------------------------------
            #  Convert the sample from single index values to x,y locations
            #  relative to the lower left corner of the map.
            #----------------------------------------------------------------
    
        truePresenceLocsXY =
            matrix (rep (0, (numTruePresForCurSpp * 2)),
                    nrow = numTruePresForCurSpp, ncol = 2, byrow = TRUE)

        for (curLoc in 1:numTruePresForCurSpp)    #  Use apply instead?
            {
            truePresenceLocsXY [curLoc, ] =
                spatial.xy.rel.to.lower.left.by.row (truePresIndices [curLoc],
                                                     numRows, numCols,
                                                     llcorner, cellsize)
            }

            #-----------------------------------------------------------------------
            #  Bind the species names to the presence locations to make a data frame
            #  that can be written out in one call rather than writing it out one
            #  line at a time.
            #  Unfortunately, this cbind call turns the numbers into quoted strings
            #  too.  There may be a way to fix that, but at the moment, I don't
            #  know how to do that so I'll strip all quotes in the write.csv call.
            #  That, in turn, may cause a problem for the species name if it has a
            #  space in it.  Not sure what maxent thinks of that form.
            #-----------------------------------------------------------------------

        species = rep (sppName, numTruePresForCurSpp)
        truePresTable = data.frame (cbind (species, truePresenceLocsXY))
        names (truePresTable) = c('species', 'longitude', 'latitude')

            #--------------------------------------------------------------------
            #  Write the true presences out to a .csv file to be fed to maxent.
            #  This will represent the case of "perfect" information
            #  (for a given population size), i.e., it contains the true
            #  location of every member of the population at the time of the
            #  sampling.  For stationary species like plants, this will be
            #  "more perfect" than for things that can move around.
            #--------------------------------------------------------------------


            #  2011.09.21 - BTL - Have changed the name sampled.presences.filename
            #                     to true.presences.filename here because that
            #                     seems like it was an error before but didn't
            #                     show up because it gets written over further
            #                     down in the file.  I may be wrong so I'm flagging
            #                     it for the moment with '###'.
        outfileRoot = paste (sppName, ".truePres", sep='')
            ###sampled.presences.filename = paste (samples.dir, outfileRoot, ".csv", sep='')
            ##	true.presences.filename = paste (samples.dir, outfileRoot, ".csv", sep='')
        truePresFilename = paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
                                   outfileRoot, ".csv")

        write.csv (truePresTable,
                   file = truePresFilename,    #  file = sampled.presences.filename,
                   row.names = FALSE,
                   quote=FALSE)

        allSppTruePresLocsXY [[sppID]] = truePresenceLocsXY

            #-----------------------------------------------------------------
            #  Append the true presences to a combined table of presences
            #  for all species.
            #-----------------------------------------------------------------

        combinedSppTruePresTable =
            rbind (combinedSppTruePresTable, truePresTable)

        #===========================================================================

        }  #  end for - all species

    #-------------------------------------------

        #  This last bit is copied from saveCombinedPresencesForMaxent.R.
        #  That looks like the only place where the
        #  combined.spp.true.presences.table was ever used in the old R
        #  version of guppy and all that function did was write the combined
        #  true presences and the combined sampled presences out.
        #  I have just moved the writing of the combined true presences
        #  into here so that they don't have to be returned from this routine.
    combinedTruePresencesFilename =
        paste0 (fullSppSamplesDirWithSlash,    #  cur.full.maxent.samples.dir.name, "/",
                "spp.truePres.combined", ".csv")
    write.csv (combinedSppTruePresTable,
               file = combinedTruePresencesFilename,
               row.names = FALSE,
               quote=FALSE)

    return (allSppTruePresLocsXY)
    }

#===============================================================================

