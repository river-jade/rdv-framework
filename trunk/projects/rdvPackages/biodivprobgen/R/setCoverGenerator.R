#===============================================================================

        # ---
        #     title: "Set Cover Generator Test"
        # author: "BTL"
        # date: "August 29, 2014"
        # output: html_document
        # ---



                #  dependency injection?


#===============================================================================

#  define initial option and derived values, particularly, array sizes
#  create dependent set nodes
#  build set of cliques given a set of clique IDs
    #  build clique given a set of node IDs
        #  link all nodes in clique
            #  link each node to all other nodes in clique
                #  link a node to all other nodes in clique
                    #  link 2 nodes and put link in both nodes
#  create independent set nodes
    #  attach each to a different clique
                #  link a node to all other nodes in clique
                    #  link 2 nodes and put link in both nodes
#  do rounds of interclique linking
    #  randomly choose two different cliques
        #  do rounds of linking between the given clique pair
            #  randomly choose a node pair, one node in each clique, without replacement
                        #  link 2 nodes and put link in both nodes
#  test that invariant properties hold

#===============================================================================
#  define initial option and derived values, particularly, array sizes
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

# numGroups = 20
# alpha = 0.8
# propOfLinksBetweenGroups = 0.23
# r_density = 3.0

numGroups = 3
alpha = 1
propOfLinksBetweenGroups = 0.5
r_density = 0.5

numSubsetsPerGroup = numGroups ^ alpha
numSubsets = numGroups ^ (alpha + 1)
numIntergroupLinkingRounds = r_density * numGroups * log (numGroups)
targetNumLinksBetweenGroups = propOfLinksBetweenGroups * (numGroups^alpha)

cat ("\n\nInput variable settings")
cat ("\n\t\tnumGroups = ", numGroups)
cat ("\n\t\talpha = ", alpha)
cat ("\n\t\tpropOfLinksBetweenGroups = ", propOfLinksBetweenGroups)
cat ("\n\t\tr_density = ", r_density)

cat ("\n\nDerived variable settings")
cat ("\n\t\tnumSubsetsPerGroup = ", numSubsetsPerGroup)
cat ("\n\t\tnumSubsets = ", numSubsets)
cat ("\n\t\tnumIntergroupLinkingRounds = ", numIntergroupLinkingRounds)
cat ("\n\t\ttargetNumLinksBetweenGroups = ", targetNumLinksBetweenGroups)
cat ("\n\n")

#===============================================================================

#  create dependent set nodes
#  build set of cliques given a set of clique IDs
    #  build clique given a set of node IDs
        #  link all nodes in clique
            #  link each node to all other nodes in clique
                #  link a node to all other nodes in clique
                    #  link 2 nodes and put link in both nodes
#  create independent set nodes
    #  attach each to a different clique
                #  link a node to all other nodes in clique
                    #  link 2 nodes and put link in both nodes
#  do rounds of interclique linking
    #  randomly choose two different cliques
        #  do rounds of linking between the given clique pair
            #  randomly choose a node pair, one node in each clique, without replacement
                        #  link 2 nodes and put link in both nodes
#  test that invariant properties hold

#===============================================================================

calculate_num_possible_solutions = function (num_PUs)
    {
    sum (choose (num_PUs, 1:num_PUs))
    }

#===============================================================================

#  node_contents_dict
#  node link

#===============================================================================

    #  Link 2 nodes
    #  A link is just a 2 item vector of the node IDs of the endpoints.
    #  The node IDs are in increasing order.

link_2_nodes = function (node1_ID, node2_ID)
    {
    c (min (node1_ID, node2_ID), max (node1_ID, node2_ID))
    }

#-------------------------------------------------------------------------------

put_link_in_link_set_for_node = function (link_ID, node_ID, links_for_each_node)
    {
    last_row = dim (links_for_each_node) [1]
    #    links_for_each_node [last_row + 1] = 
    }

#-------------------------------------------------------------------------------

put_link_in_end_node_link_sets = function (link_ID, node1_ID, node2_ID)
    {
    put_link_in_link_set_for_node (link_ID, node1_ID)
    put_link_in_link_set_for_node (link_ID, node2_ID)
    }

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
#  define initial option and derived values, particularly, array sizes
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
    #    ???  What is "k" in Figure 2?

# numGroups = 20
# alpha = 0.8
# propOfLinksBetweenGroups = 0.23
# r_density = 3.0

n__numGroups = 3                      #  num_cliques = 3
alpha__ = 1
p__propOfLinksBetweenGroups = 0.5    #  p__prop_of_links_between_cliques   
									 #  not the right name?
									 #  is it really the proportion of nodes in one clique 
									 #  to link to another clique during one round?
									 #  p__prop_of_nodes_in_clique_to_try_to_interlink_in_one_round?
									 #  p__prop_to_link_between_two_cliques_in_one_round?
									 #  p__prop
												
r__density = 0.5

	#  num_nodes_per_clique = num_cliques ^ alpha
numSubsetsPerGroup = numGroups ^ alpha    
	#  num_nodes = num_cliques * num_nodes_per_clique
numSubsets = numGroups ^ (alpha + 1)      #  i.e., numGroups * numSubsetsPerGroup

numIntergroupLinkingRounds = r_density * numGroups * log (numGroups)

	#  This is the target number for each linking round?
	#  Is the total number of links generated over all rounds aiming for 
	#  around target * numRounds?
targetNumLinksBetweenGroups = propOfLinksBetweenGroups * (numGroups^alpha)
								#  i.e., propOfLinksBetweenGroups * numSubsetsPerGroup

cat ("\n\nInput variable settings")
cat ("\n\t\tnumGroups = ", numGroups)
cat ("\n\t\talpha = ", alpha)
cat ("\n\t\tpropOfLinksBetweenGroups = ", propOfLinksBetweenGroups)
cat ("\n\t\tr_density = ", r_density)

cat ("\n\nDerived variable settings")
cat ("\n\t\tnumSubsetsPerGroup = ", numSubsetsPerGroup)
cat ("\n\t\tnumSubsets = ", numSubsets)
cat ("\n\t\tnumIntergroupLinkingRounds = ", numIntergroupLinkingRounds)
cat ("\n\t\ttargetNumLinksBetweenGroups = ", targetNumLinksBetweenGroups)
cat ("\n\n")

#=========================================

	#  User-supplied control parameters.
	
n__num_cliques = 3
alpha__ = 1
p__prop_of_links_between_cliques = 0.5    	#  p__prop_of_links_between_cliques   
									 		#  not the right name?
									 		#  is it really the proportion of nodes in one clique 
									 		#  to link to another clique during one round?
									 		#  p__prop_of_nodes_in_clique_to_try_to_interlink_in_one_round?
									 		#  p__prop_to_link_between_two_cliques_in_one_round?
									 		#  p__prop
												
r__density = 0.5

#-----------------------------------------

derive_control_parameters = function (
n__num_cliques = 3
alpha__ = 1
p__prop_of_links_between_cliques = 0.5    	#  p__prop_of_links_between_cliques   
									 		#  not the right name?
									 		#  is it really the proportion of nodes in one clique 
									 		#  to link to another clique during one round?
									 		#  p__prop_of_nodes_in_clique_to_try_to_interlink_in_one_round?
									 		#  p__prop_to_link_between_two_cliques_in_one_round?
									 		#  p__prop
												
r__density = 0.5
)
{
	#  Derived control parameters.
	
num_nodes_per_clique = n__num_cliques ^ alpha__
tot_num_nodes = n__num_cliques * num_nodes_per_clique

num_rounds_of_linking_between_cliques = r__density * n__num_cliques * log (n__num_cliques)

target_num_links_between_2_cliques_per_round = 
								p__prop_of_links_between_cliques * num_nodes_per_clique

num_links_within_one_clique = choose (num_nodes_per_clique, 2)
tot_num_links_inside_cliques = num_cliques * num_links_within_one_clique

max_possible_num_links_between_cliques = 
	target_num_links_between_2_cliques_per_round * num_rounds_of_linking_between_cliques
	
max_possible_tot_num_links = tot_num_links_inside_cliques + max_possible_num_links_between_cliques

cat ("\n\nInput variable settings")
cat ("\n\t\t n__num_cliques = ", n__num_cliques)
cat ("\n\t\t alpha__ = ", alpha__)
cat ("\n\t\t p__prop_of_links_between_cliques = ", p__prop_of_links_between_cliques)
cat ("\n\t\t r__density = ", r__density)

cat ("\n\nDerived variable settings")
cat ("\n\t\t num_nodes_per_clique = ", num_nodes_per_clique)
cat ("\n\t\t num_rounds_of_linking_between_cliques = ", num_rounds_of_linking_between_cliques)
cat ("\n\t\t target_num_links_between_2_cliques_per_round = ", target_num_links_between_2_cliques_per_round)
cat ("\n\t\t num_links_within_one_clique = ", num_links_within_one_clique)
cat ("\n\t\t tot_num_links_inside_cliques = ", tot_num_links_inside_cliques)
cat ("\n\t\t max_possible_num_links_between_cliques = ", max_possible_num_links_between_cliques)
cat ("\n\t\t max_possible_tot_num_links = ", max_possible_tot_num_links)
cat ("\n\n")
}

#-----------------------------------------


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
        # Change to nearest value that is divisible by n?
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

#  Could do this much differently?
#  i.e., just create the clique groups and self link them all in the process,
#  then create an independent set (with as members as there are groups/cliques)
#  and add each member of the independent set to one and only one clique and
#  link it to every member of the clique and to no one else.

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
cat ("\n\nnumLinks = ", numLinks)
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

#  Could do this better by keeping independent set completely outside the
#  other sets so that you never had to do any checks.
#  The only time that the independent set members enter into any of this is
#  when you derive the links between them and every other member of their
#  clique and put that link number into both sets.
#  Once that is done, you completely ignore the independent set, so you
#  could just store it separately and track the link number of each link
#  from it into its clique.  Probably also need to save the ID of the clique
#  it's associated with.  Still, I'm not sure either of those things are
#  necessary to remember.  All you really need to know about independent set
#  members is the set of link numbers stored in each independent set member.
#  You could have a separate dictionary of link numbers that stores the link ID,
#  the end nodes of the link, and the start and end clique numbers that it
#  connects.  Even then, almost all of that information could be derived
#  from just knowing what are the start and end node names of the link
#  since each node would know what clique it belongs to.

#  So, rewriting all this would just go something like this:
#    - create clique IDs
#    - assign node IDs to each clique
#    - create links between all members of each clique
#        - and store the link IDs into the nodes at either end of the link
#    - create the independent set
#    - "assign" each independent set member to a clique (but don't actually
#      include it in the clique)
#        - and link it to every member of the clique
#        - and store the link IDs into the nodes at either end of the link
#    - make links between nodes of different cliques according to Xu's recipe
#        - and store the link IDs into the nodes at either end of the link

#  Conditions that should be true (and can be tested?) at the end of the
#  process:
#    - every link ID should appear in exactly 2 and only 2 nodes
#    - every link from a given independent set node should go to the same clique
#    - every member of a clique should be connected to every other memeber of
#      the same clique and to one and only one independent set node and it
#      should be the same independent set node for every member of the same
#      clique

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

subsetsCollAsList = as.list (subsetsColl)
#cat ("\n\nsubsetsColl as list = \n")
#print (subsetsCollAsList)

#===============================================================================

library (reshape2)  #  for melt()
library (plyr)      #  for arrange()

gen_spp_PU_amount_table_from_melted_patch_spp_list =
        function (melted_patch_spp_list,
                  sppAmount = 1  #  Use same amount for every species
                  )
    {
    total_num_spp_PU_pairs = dim (melted_patch_spp_list) [1]

    spp_PU_amount_table =
        data.frame (species = as.numeric (unlist (melted_patch_spp_list ["value"])),
                    pu      = as.numeric (unlist (melted_patch_spp_list ["L1"])),
                    amount  = rep (sppAmount, total_num_spp_PU_pairs))

    cat ("\n\nBefore sorting, spp_PU_amount_table = \n")
    print (spp_PU_amount_table)
    cat ("\n\n-------------------")

        #  Sort the table in ascending order by species within planning unit.
        #  Taken from Wickham comment in:
        #  http://stackoverflow.com/questions/1296646/how-to-sort-a-dataframe-by-columns-in-r

    spp_PU_amount_table = arrange (spp_PU_amount_table, pu, species)

    return (spp_PU_amount_table)
    }

#===============================================================================

    #---------------------------------------------
    #  Convert the list of lists to a dataframe.
    #---------------------------------------------

cat ("\n\nBefore melting, subsetsCollAsList = \n")
print (subsetsCollAsList)
cat ("\n\n-------------------")

melted_patch_spp_list = melt (subsetsCollAsList)
cat ("\n\nAfter melting, melted_patch_spp_list = \n")
print (melted_patch_spp_list)
cat ("\n\n-------------------")

    #-----------------------------------------------
    #  Convert species and patch lists to vectors.
    #  Remove duplicates too.
    #-----------------------------------------------

spp_IDs = unlist (unique (melted_patch_spp_list ["value"]))
num_spp = length (spp_IDs)

        #---------------------------------------------------------------
        #  NOTE: the melt() function arbitrarily labelled the patch ID 
        #  column "L1".
        #---------------------------------------------------------------

PU_IDs = unlist (unique (melted_patch_spp_list ["L1"]))
num_PUs = length (PU_IDs)

    #-------------------------------------------------------------
    #  Strip out just the patch and species information from the 
    #  melted data and make it into a table.
    #  Also, marxan requires the table to be sorted in 
    #  increasing order by planning unit.
    #-------------------------------------------------------------

spp_PU_amount_table =
    gen_spp_PU_amount_table_from_melted_patch_spp_list (melted_patch_spp_list)

cat ("\n\nAfter sorting, spp_PU_amount_table = \n")
print (spp_PU_amount_table)
cat ("\n\n-------------------")


#     NOTE:  The building of the original list has allowed addition
#             of a duplicate species (i.e., 36) in the number 9 subset.
#             Is it a bug or just the way the algorithm works?
#             Should I try to preven additions like this or
#             should I just remove them at the final phase of building
#             the input table for marxan?
#             Does it hurt anything to have these duplicates?
#             Does it mess with the statistics that drive the difficulty
#             of the problem and therefore, need to prevent adding these
#             duplicates?  Was it just the result of some kind of a
#             call to sample() that should have had replace=FALSE argument?
#
#             For the moment, I will just get rid of any duplicate lines.

spp_PU_amount_table = unique (spp_PU_amount_table)

cat ("\n\nAfter unique(), spp_PU_amount_table = \n")
print (spp_PU_amount_table)
cat ("\n\n-------------------")

#===============================================================================

source ('/Users/Bill/D/rdv-framework/projects/rdvPackages/reserveselection/R/write_marxan_input_files.v2.R')

# seed = 1
# set.seed (seed)
# num_PUs = 100
# num_spp = 3

write_marxan_pu.dat_input_file (sort (PU_IDs))
write_marxan_spec.dat_input_file (sort (spp_IDs))

# spp_PU_amount_table = gen_random_spp_PU_amount_table (num_PUs, num_spp)
# write_marxan_puvspr.dat_input_file (spp_PU_amount_table)

write_marxan_puvspr.dat_input_file (spp_PU_amount_table)

solutionSet = (1:numSubsets) [-independentSet]
cat ("\nindependentSet = ", independentSet)
cat ("\nsolutionSet = ", solutionSet)

size_of_correct_solution = length (solutionSet)
cat ("\nsize of correct solution = ", size_of_correct_solution)

cat ("\n\nnumber of possible solutions of that size = ",
     choose (num_PUs, size_of_correct_solution))

num_possible_solutions = calculate_num_possible_solutions (num_PUs)
cat ("\n\ntotal number of possible solutions = ",
     num_possible_solutions, "\n\n")

#===============================================================================


