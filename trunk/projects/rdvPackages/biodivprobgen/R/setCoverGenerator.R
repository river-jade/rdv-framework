#===============================================================================

        # ---
        #     title: "Set Cover Generator Test"
        # author: "BTL"
        # date: "August 29, 2014"
        # output: html_document
        # ---



                #  dependency injection?


#===============================================================================

getSmallSubsetID = function (linkColl, linkID, smallSubsetIDcol) 
    { return (linkColl [linkID, smallSubsetIDcol]) }

getLargeSubsetID = function (linkColl, linkID, largeSubsetIDcol) 
    { return (linkColl [linkID, largeSubsetIDcol]) }

getGroupIDofSubset = function (groupIDofSubset, subsetID)
    { return (groupIDofSubset [subsetID]) }

# For every subset pair whose two subsets are in the same group, 
    # put its index number in its two subsets, i.e., build cliques.
buildCliques = function (numLinks, linkColl, #curLinkID, 
                         smallSubsetIDcol, largeSubsetIDcol, 
                         groupIDofSubset, subsetsColl) 
    {
    for (curLinkID in 1:numLinks)
        {
        #  Get the subset IDs at the ends of this link.
        smallSubsetID = linkColl [curLinkID, smallSubsetIDcol]
        largeSubsetID = linkColl [curLinkID, largeSubsetIDcol]
        
        #  Find the group ID for each of the 2 subsets.
        smallSubsetGroupID = groupIDofSubset [smallSubsetID]
        largeSubsetGroupID = groupIDofSubset [largeSubsetID]
        
        #  If they're in the same group, add the link to both subsets.
        if (smallSubsetGroupID == largeSubsetGroupID)
            {
            subsetsColl [[as.character(smallSubsetID)]] = 
                append (subsetsColl [[as.character(smallSubsetID)]], curLinkID)
            subsetsColl [[as.character(largeSubsetID)]] = 
                append (subsetsColl [[as.character(largeSubsetID)]], curLinkID)
            }
        }
    
    return (subsetsColl)
    }

#===============================================================================

library (hash)

seed = 17
set.seed (seed)

    #  In "simple model ..." paper, they use:
    #       n in [8..100] while alpha = 0.52, r = 1
    #       r in [0.8..2.5] while n = 20, alpha = 0.77
    #       alpha in [0.2..1] while n = 20, r = 2.5
    #  In all 3 cases, best fit to the theory was when the parameter 
    #  was at the top of its range.  See figure 1 in the paper.
    #
    #  Values in the paper for propOfLinksBetweenGroups were more variable.
    #  See figures 2 and 3 and text in column 2 of page 4.
    #  In those examples, they had:
    #       Figure 2:   k=2, alpha=0.8, r=3, n in {20,30,40}
    #                   p in [0.14..0.36] w/ critical value Pcr ~ 0.23

numGroups = 3
alpha = 1
propOfLinksBetweenGroups = 0.5
r_density = 0.5

numSubsetsPerGroup = numGroups ^ alpha
numSubsets = numGroups ^ (alpha + 1)
numIntergroupLinkingRounds = r_density * numGroups * log (numGroups)
targetNumLinksBetweenGroups = propOfLinksBetweenGroups * (numGroups^alpha)

        # ```
        # 
        # From Xu page:
        #     
        #     1. First generate n^(alpha + 1) empty subsets 
        # 
        # a)  Create a collection (dictionary?) of empty subsets, 
        # each with an integer ID.
        # 
        # This could just be an array of lists if R allowed it.
        # It could also be a list of lists, but that's hard to use properly.
        # So, maybe a hash of lists would be a decent approximation to an array of lists?
        # ```{r}
subsetsColl = hash ()
for (curSubsetID in 1:numSubsets)
    {
    subsetsColl [[as.character (curSubsetID)]] = list()
    }
        # ```
        # 
        # b)  Uniformly divide subsets into n groups (where alpha > 0 is a constant), 
        # i.e., each of which has n^alpha empty subsets.
        # 
        # i)  What to do if n^(alpha+1) does not divide evenly by n?
        # Only allow integer alpha values?
        # Choose a different alpha?
        # Produce an error message and quit?
        # Make all groups the same size except for one remainder group?
        # 
        # ```{r}
subsetIDsInGroup = matrix (1:numSubsets, nrow=numGroups, 
                            ncol=numSubsetsPerGroup, byrow=TRUE)
groupIDofSubset = rep (0, numSubsets)
curSubsetIdx = 0
for (curGroupID in 1:numGroups)
    {
    for (curIdx in 1:numSubsetsPerGroup)
        {
        curSubsetIdx = curSubsetIdx + 1
        groupIDofSubset [curSubsetIdx] = curGroupID
        }
    }

    #  Choose the independent set to use as the complement of the solution set.
    #  Do this by randomly choosing 1 node (subset) from each group and 
    #  adding it to the independent set.

            #  USE A HASH INSTEAD, since many lookup tests required?
independentSet = rep (0, numGroups)
for (curGroupID in 1:numGroups)
    {
    independentSet [curGroupID] = sample (subsetIDsInGroup [curGroupID,], 1)
    }

        # A subset pair is an unordered pair of two subsets.  
        # Every different subset pair is indexed by a different number.  
        # 
        # c)  Create a collection (dictionary?) of link IDs and the endpoint subset 
        # IDs associated with each.
        # 
        # The number of link IDs will never change and is known from the 
        # start, so this could also just be a 3 column matrix.

numLinks = numSubsets * (numSubsets - 1) / 2
linkColl = matrix (0, nrow=numLinks, ncol=5, byrow=TRUE)
smallSubsetIDcol = 1
largeSubsetIDcol = 2
smallGroupIDcol = 3
largeGroupIDcol = 4
independentSetMemberColID = 5

curLinkID = 0
#for (curIdx in 1:numLinks)
for (smallSubsetID in 1:(numSubsets-1))
    {
#    smallSubsetID = curLinkID
    for (largeSubsetID in (smallSubsetID+1):numSubsets)
        { 
        curLinkID = curLinkID + 1
        linkColl [curLinkID, smallSubsetIDcol] = smallSubsetID
        linkColl [curLinkID, largeSubsetIDcol] = largeSubsetID
        
        linkColl [curLinkID, smallGroupIDcol] = groupIDofSubset [smallSubsetID]
        linkColl [curLinkID, largeGroupIDcol] = groupIDofSubset [largeSubsetID]
        
            #  If either endpoint of the link is in the independent set, 
            #  set the "independent set member" flag to TRUE.
        
        smallSubsetInIndependentSet = which (independentSet == smallSubsetID)
        smallSubsetInIndependentSet = (length (smallSubsetInIndependentSet) > 0)
        cat ("\nsmallSubsetInIndependentSet = ", smallSubsetInIndependentSet)
        
        largeSubsetInIndependentSet = which (independentSet == largeSubsetID)
        largeSubsetInIndependentSet = (length (largeSubsetInIndependentSet) > 0)
        cat ("\nlargeSubsetInIndependentSet = ", largeSubsetInIndependentSet)
        
        linkColl [curLinkID, independentSetMemberColID] = 
            smallSubsetInIndependentSet || largeSubsetInIndependentSet
        
        cat ("\n--- curLinkID = ", curLinkID, 
             "  smallSubsetID = ", linkColl [curLinkID, smallSubsetIDcol], 
             "  largeSubsetID = ", linkColl [curLinkID, largeSubsetIDcol],
             "  smallGroupID = ", linkColl [curLinkID, smallGroupIDcol], 
             "  largeGroupID = ", linkColl [curLinkID, largeGroupIDcol],
             "  independentSetMember = ", 
             linkColl [curLinkID, independentSetMemberColID], 
             "  (which (independentSet == smallSubsetID) = ", 
             (which (independentSet == smallSubsetID)), 
              "  (which (independentSet == largeSubsetID) = ", 
              (which (independentSet == largeSubsetID))
              )
#         cat ("\n",
#                 "    linkColl [", 
#                 curLinkID, ", ", 
#                 smallSubsetIDcol, 
#                 "] = ", 
#                 linkColl [curLinkID, smallSubsetIDcol])

#         cat ("\n",
#                 "    linkColl [", 
#                 curLinkID, ", ", 
#                 largeSubsetIDcol, 
#                 "] = ", 
#                 linkColl [curLinkID, largeSubsetIDcol])        
        }
    }
cat ("\n\n")

    # Then, for every subset pair whose two subsets are in the same group, 
    # put its index number in its two subsets, i.e., build cliques.

subsetsColl = buildCliques (numLinks, linkColl, #curLinkID, 
                            smallSubsetIDcol, largeSubsetIDcol, 
                            groupIDofSubset, subsetsColl) 

    #  Steps 2 & 3.
    #  Step 2: 
    #       - Randomly select 2 different groups
    #       - and then uniformly select w/o repetitions (replacement?)
    #         p*n^(2*alpha) subset pairs (i.e., links) (where 0 < p < 1) 
    #         from n^(2*alpha) possible ones (each of which consists of 
    #         2 subsets respectively from these two groups).
    #       - For every selected pair, put its index number in its 2 subsets.
    #  Step 3: Repeat step 2 with repetitions (replacement?) for r*n*ln(n) times.

                #  Old comment to scavenge language from?
                #  Uniformly select without repetitions (replacement?) 
                #  p*n^(2*alpha) subset pairs between the 2 groups.
                
                #  Get list of links between the 2 groups.
                #  In the process, disallow the inclusion of any link that includes 
                #  a member of the independent set.

for (curIdx in 1:numIntergroupLinkingRounds)
    {
        #  Randomly select 2 different groups
    groupPair = sample (1:numGroups, 2, replace=FALSE)
    firstGroupID = min (groupPair)
    secondGroupID = max (groupPair)
    
#browser()
    
        #  Subset out all links _between_ those groups except
        #  any links to the independent set (i.e., the complement 
        #  of the solution set).
    linkIndicesToDrawFrom = 
        which (
                    #  Both ends are not in same group.
                (linkColl [,smallGroupIDcol] != linkColl [,largeGroupIDcol])  
#                 && 
#                     #  Both ends are in one of the 2 specified groups.
#                 ((linkColl [,smallGroupIDcol] == firstGroupID) ||  
#                  (linkColl [,largeGroupIDcol] == secondGroupID))  
#                 && 
#                 ((linkColl [,smallGroupIDcol] == firstGroupID) ||  
#                  (linkColl [,largeGroupIDcol] == secondGroupID)) 
#                 &&
#                     #  Does not link into the independent set.
#                 ! linkColl [,independentSetMemberColID]
              )
#browser()
#  Need to have a statistically better way of generating the correct integer 
#  value when this is not an integer.  For the moment, I'll just round it.
targetNumLinksBetweenGroups = round (targetNumLinksBetweenGroups)
    indicesOfLinksToAddToSubsets = 
        sample (linkIndicesToDrawFrom, targetNumLinksBetweenGroups, 
                replace=FALSE)
#browser()     
    for (curLinkIdx in indicesOfLinksToAddToSubsets)
        {
        smallSubsetID = linkColl [curLinkIdx, smallSubsetIDcol]        
        subsetsColl [[as.character (smallSubsetID)]] = 
            append (subsetsColl [[as.character (smallSubsetID)]], curLinkID)

        largeSubsetID = linkColl [curLinkIdx, largeSubsetIDcol]
        subsetsColl [[as.character (largeSubsetID)]] = 
            append (subsetsColl [[as.character (largeSubsetID)]], curLinkID)
        
        }
    }

solutionSet = (1:numSubsets) [-independentSet]
cat ("\nindependentSet = ", independentSet)
cat ("\nsolutionSet = ", solutionSet, "\n\n")

#===============================================================================


