#===============================================================================

                #  source ("getNumTruePresForEachSpp.R")

#===============================================================================

#  History

#  2014 02 09 - BTL - Created.
#  Extracted from getTruePresForEachSpp.R.

#===============================================================================

strOfCommaSepNumbersToVec = function (numberString)
    {
        #  Convert a list of numbers in comma-separated string form into 
        #  an R vector holding those numbers.
        #
        #  First need to test string to prevent code injection possibility.
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

#===============================================================================

getNumTruePresForEachSpp_usingSpecifiedCts = function (numTruePresForEachSpp_string,
                                                       numSppToCreate)
    {
        #--------------------------------------------------
        #  Use non-random, fixed counts of true presences
        #  based on fractions specified in the yaml file.
        #--------------------------------------------------
    
    #    	numTruePresForEachSpp = variables$PAR.num.true.presences
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



