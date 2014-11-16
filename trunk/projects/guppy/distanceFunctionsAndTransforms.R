#===============================================================================

#  source ("distanceFunctionsAndTransforms.R")

#===============================================================================

#  History

#  2014 01 07 - BTL
#  Extracted from guppy/clusterReadingTest.R

#===============================================================================
#                    Distance functions and transforms
#===============================================================================

#  One problem with these distance functions is that it has often been shown
#  that as the number of dimensions goes up, distances all converge to being
#  very similar.

#  How might we get around that?  Would it make sense to convert to PCA
#  coordinates and use far less coordinates?  Matt explained why using PCA
#  coordinates was a bad thing for clustering, but I've forgotten his
#  explanation.  Was it in general or just for these kinds of ecological
#  clusters?

#  One possibility might also be to do the pca separately for each clustering
#  and just use the values inside that cluster as the fodder for the PCA
#  calculation.

#===============================================================================

sumSquaredDist_givenDiffVec = function (aVector)
    {
    return (sum (aVector ^ 2))
    }

#-------------------------------------------------------------------------------

#sumSquaredDist = function (vector1, vector2)
sumSquaredDist = function (vector1, vector2, minVector=NA, maxVector=NA, insideCluster=NA)
    {
    if (length (vector1) != length (vector2))
        {
        cat ("\nIn sumSquareDist(), lengths don't match.",
             "\n    length (vector1) = ", length (vector1),
             "\n    length (vector2) = ", length (vector2),
             "\n\n")
        }

    return (sumSquaredDist_givenDiffVec (vector1 - vector2))
    }

#-------------------------------------------------------------------------------

eucDist_givenDistVec = function (aVector)
    {
    return (sqrt (sumSquaredDist_givenDiffVec (aVector)))
    }

#-------------------------------------------------------------------------------

#eucDist = function (vector1, vector2)
eucDist = function (vector1, vector2, minVector=NA, maxVector=NA, insideCluster=NA)
    {
    return (eucDist_givenDistVec (vector1 - vector2))
    }

#-------------------------------------------------------------------------------

const_sqrt2pi = sqrt(2*pi)
gaussian = function (aVector, centerVector, sdVector)
    {
    exponentNumerator = -(aVector - centerVector) ^ 2
    #    cat ("\n\ngaussian exponentNumerator = ", exponentNumerator)

    exponentDenominator = 2 * (sdVector ^ 2)
    #    cat ("\n\ngaussian exponentDenominator = ", exponentDenominator)

    fullFractionDenominator = sdVector * const_sqrt2pi
    #    cat ("\n\ngaussian fullFractionDenominator = ", fullFractionDenominator)

    gaussianValue = (exp (exponentNumerator / exponentDenominator) /
                    fullFractionDenominator)
    #    cat ("\n\ngaussian gaussianValue = ", gaussianValue)

    #    cat ("\n\n")

    return (gaussianValue)
    }

#----------------------------------

outOfEnvelopeValue = Inf     #  Not sure what to put here...
#outOfEnvelopeValue = 40     #  Not sure what to put here...
                            #  In the current case, there are 20 features,
                            #  each scaled to be roughly 0-1, so the maximum
                            #  distance among them is close to 20.

#envelopeDist = function (aVector, centerVector, minVector, maxVector)
envelopeDist = function (aVector, centerVector, minVector, maxVector, insideCluster=NA)
    {
        #  If the point is fully inside the cluster's envelope,
        #  i.e., all feature values between the cluster's min and max
        #  values for the corresponding feature, then return the
        #  euclidean distance to the center of the cluster in feature
        #  space (e.g., the mean or median).

    #cat ("\n\nIN ENVELOPEDIST:")
    #cat ("\n    minVector = ", minVector)
    #cat ("\n    maxVector = ", maxVector)

    numInBoundMins = sum (aVector >= minVector)
    #cat ("\n     numInBoundMins = ", numInBoundMins)
    if (numInBoundMins < length (minVector))
        return (outOfEnvelopeValue)

    numInBoundMaxs = sum (aVector <= maxVector)
    #cat ("\n     numInBoundMaxs = ", numInBoundMaxs)
    if (sum (aVector <= maxVector) < length (minVector))
        return (outOfEnvelopeValue)

    return (eucDist (aVector, centerVector))
    }

#----------------------------------

outOfClusterValue = Inf     #  Not sure what to put here...
#outOfClusterValue = 40     #  Not sure what to put here...
#  In the current case, there are 20 features,
#  each scaled to be roughly 0-1, so the maximum
#  distance among them is close to 20.

#  NOTE:  For now at least, using this distance assumes that the po
#hardClusterDist = function (aVector, centerVector, insideCluster=TRUE)
hardClusterDist = function (aVector, centerVector, minVector=NA, maxVector=NA, insideCluster=NA)
    {
    #  If the point is fully inside the cluster,
    #  then return the euclidean distance to the
    #  center of the cluster in feature
    #  space (e.g., the mean or median).
    #  You could also just return a constant value
    #  instead, but this would at least make some
    #  differentiation among values inside the clusters.

    if (insideCluster)
    {
        return (eucDist (aVector, centerVector))
        #        return (1)
    } else
    {
        return (outOfClusterValue)
        #        return (0)
    }
}
#----------------------------------

#hardClusterDist_01only = function (aVector, centerVector, insideCluster=TRUE)
hardClusterDist_01only = function (aVector, centerVector, minVector=NA, maxVector=NA, insideCluster=NA)
    {
        #  If the point is fully inside the cluster,
        #  then return the euclidean distance to the
        #  center of the cluster in feature
        #  space (e.g., the mean or median).
        #  You could also just return a constant value
        #  instead, but this would at least make some
        #  differentiation among values inside the clusters.

    if (insideCluster)
        {
        return (0)
        } else
        {
        return (1)
        }
    }

#===============================================================================

