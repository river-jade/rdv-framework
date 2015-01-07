#===============================================================================

            #  gscp_11b_network_measures_using_igraph_package.R

#===============================================================================

                    #  Code for using igraph package.

#===============================================================================

#browser()

#if (FALSE)
#{
library (igraph)

vertices = data.frame (name=c(spp_vertex_names, PU_vertex_names), 
                       type=c(rep(FALSE, num_spp),
                              rep(TRUE, num_PUs)))

    #  Does igraph require me to rename the columns to say 
    #  "from" and "to instead of "PU_ID" and "spp_ID"?
# bg = graph.data.frame (edge_df, directed=FALSE, vertices=vertices)

cat ("\n\nJust before graph.data.frame()\n")

cat ("\nnames (PU_spp_pair_indices = \n")
print (names (PU_spp_pair_indices))

cat ("\nnames (PU_spp_pair_names = \n")
print (names (PU_spp_pair_names))

#names (PU_spp_pair_indices) = c("from", "to")
#cat ("\n\nAfter changing names\n")
#cat ("\nnames (PU_spp_pair_indices = \n")
#print (names (PU_spp_pair_indices))

#bg = graph.data.frame (PU_spp_pair_indices, directed=FALSE, vertices=vertices)
bg = graph.data.frame (PU_spp_pair_names, directed=FALSE, vertices=vertices)

#names (PU_spp_pair_indices) = c(PU_col_name, spp_col_name)
#cat ("\n\nAfter reinstating old names\n")
#cat ("\nnames (PU_spp_pair_indices = \n")
#print (names (PU_spp_pair_indices))
#}

#===============================================================================

cat ("\n\n=====>  Under igraph, is.bipartite (bg) = ", is.bipartite (bg), "\n")
#Echo results...


print(bg)

print (V(bg))
print (V(bg)$type)
print (E(bg))

plot(bg)

bgp = bipartite.projection(bg)
plot(bgp$proj1)
plot(bgp$proj2)

### Compute the bipartite measures from the Latapy et al 2008 paper.

# These are extracts from point 6 of the R Recipes page of the igraph wiki:
# 
# http://igraph.wikidot.com/r-recipes
# 
# **Reference: Matthieu Latapy, Clemence Magnien, Nathalie Del Vecchio, Basic notions for the analysis of large two-mode networks, Social Networks 30 (2008) 31–48**
# 
# NOTE:  The code doesn't work as it is given on the web page.  For example, it 
# starts off by referencing a graph g that has not been defined.  Later, it 
# starts in on network transitivity and references "target", which has not been 
# defined either.  Finally, it references several functions before they're 
# defined, e.g., ccBip().  In each case, I've done a little hack to get it to 
# work here.

    # Number of top and bottom nodes
top<-length(V(bg)[type==FALSE])
bottom<-length(V(bg)[type==TRUE])

    # Number of edges
m<-ecount(bg)

    # Mean degree for top and bottom nodes
ktop<-m/top
kbottom<-m/bottom

    # Density for bipartite network
bidens<-m/(top*bottom)

    # Largest connected component for top and bottom nodes:
gclust<-clusters(bg, mode='weak')
lcc<-induced.subgraph(bg, V(bg)[gclust$membership==1])
lcctop<-length(V(lcc)[type==FALSE])
lccbottom<-length(V(lcc)[type==TRUE])

    # Mean distance for top and bottom nodes
distop<-mean(shortest.paths(lcc, v=V(lcc)[type==FALSE], to=V(lcc)[type==FALSE], mode = 'all'))
disbottom<-mean(shortest.paths(lcc, v=V(lcc)[type==TRUE], to=V(lcc)[type==TRUE], mode = 'all'))

#######################################################

    #  BTL additions to get it to work...
target = bg

    # Network transitivity
trtarget<-graph.motifs(target, 4)
ccglobal<-(2*trtarget[20])/trtarget[14]

    # The last clustering measures relies on the functions ccBip 
    # wrote by Gabor Csardi, while ccLowDot and ccTopDot are 
    # essentially the same function with only a minor change
ccBip <- function(bg) 
    {
    if (! "name" %in% list.vertex.attributes (bg)) 
        {
        V(bg)$name <- seq_len (vcount(bg))
        }
    neib <- get.adjlist (bg)
    names (neib) <- V(bg)$name
    proj <- bipartite.projection(bg)
    
    lapply (proj, 
            function(x) 
                {
                el <- get.edgelist(x)
                sapply (V(x)$name, 
                        function (v) 
                            {
                            subs <- el[,1]==v | el[,2]==v
                            
                            f <- function (un, vn) length (union (un, vn))
                            
                            vals <- E(x)[subs]$weight / 
                                    unlist (mapply (f, 
                                                    neib[el[subs,1]],
                                                    neib[el[subs,2]]))
                            mean (vals)
                            }
                        )
                }
            )
    }

ccLowDot <- function(bg) {
if (! "name" %in% list.vertex.attributes(bg)) {
  V(bg)$name <- seq_len(vcount(bg))
}
neib <- get.adjlist(bg)
names(neib) <- V(bg)$name
proj <- bipartite.projection(bg)
lapply(proj, function(x) {
  el <- get.edgelist(x)
  sapply(V(x)$name, function(v) {
    subs <- el[,1]==v | el[,2]==v
    f <- function(un, vn) min(length(un), length(vn))
    vals <- E(x)[subs]$weight /
      unlist(mapply(f, neib[el[subs,1]], neib[el[subs,2]]))
    mean(vals)
  })
})
}

ccTopDot <- function(bg) {
if (! "name" %in% list.vertex.attributes(bg)) {
  V(bg)$name <- seq_len(vcount(bg))
}
neib <- get.adjlist(bg)
names(neib) <- V(bg)$name
proj <- bipartite.projection(bg)
lapply(proj, function(x) {
  el <- get.edgelist(x)
  sapply(V(x)$name, function(v) {
    subs <- el[,1]==v | el[,2]==v
    f <- function(un, vn) max(length(un), length(vn))
    vals <- E(x)[subs]$weight /
      unlist(mapply(f, neib[el[subs,1]], neib[el[subs,2]]))
    mean(vals)
  })
})
}

    #  BTL - Had to move this code down below the definitions of the functions 
    #        used here (ccBip(), etc.).
    
    # Clustering coefficients (cc, cclowdot, cctopdot) for top and bottom nodes
ccPointTarg<-ccBip(bg)
cctop<-mean(ccPointTarg$proj1, na.rm=TRUE)
ccbottom<-mean(ccPointTarg$proj2, na.rm=TRUE)
ccLowTarg<-ccLowDot(bg)
cclowdottop<-mean(ccLowTarg$proj1, na.rm=TRUE)
cclowdotbottom<-mean(ccLowTarg$proj2, na.rm=TRUE)
ccTopTarg<-ccTopDot(bg)
cctopdottop<-mean(ccTopTarg$proj1, na.rm=TRUE)
cctopdobottom<-mean(ccTopTarg$proj2, na.rm=TRUE)

redundancy<-function(g
                        #  Added by BTL since this only seemed to do bottom.
                     , top_bottom_vertex_type=FALSE
                     )  
    {
        redundancy<-c()

                       #  Added by BTL since this only seemed to do bottom.
        for(i in V(g)[which(V(g)$type==top_bottom_vertex_type)]){
#        for(i in V(g)[which(V(g)$type==FALSE)]){
            
                overlap <- 0
                nei<-neighbors(g,i)
                
                    #  Correction suggested by Tamas Nepusz
                #if(length(nei)>0){
                if(length(nei)>1){
                    
                        comb<-combn(nei, 2)     
                        for(c in seq(1:dim(comb)[2])){
                                unei<-neighbors(g,comb[1,c])
                                wnei<-neighbors(g,comb[2,c])

                                    #  Correction suggested by Tamas Nepusz
                                #redund<-Reduce(union, list(unei,wnei))
                                #redund<-Reduce(setdiff, list(redund,i))
                                redund <- setdiff(intersect(unei, wnei), i)

                                if(length(redund)>0){
                                        overlap <- overlap + 1
                                }
                        }
                }
                if(overlap > 0){
                        n <- length(nei)
                        norm<-2.0/(n*(n-1))
                } else {
                        norm <- 1
                }
                redundancy<-append(redundancy, overlap*norm)
        }
        return(redundancy)
}

bottom_bg_redundancy = redundancy (bg, FALSE)
cat ("\n\nbottom bg_redundancy = \n")
print (bottom_bg_redundancy)
cat ("\nmean bottom_bg_redundancy = ", mean (bottom_bg_redundancy))
cat ("\nmedian bottom_bg_redundancy = ", median (bottom_bg_redundancy))

top_bg_redundancy = redundancy (bg, TRUE)
cat ("\n\ntop bg_redundancy = \n")
print (top_bg_redundancy)
cat ("\nmean top_bg_redundancy = ", mean (top_bg_redundancy))
cat ("\nmedian top_bg_redundancy = ", median (top_bg_redundancy))

cat ("\n")

#browser()

#===============================================================================

