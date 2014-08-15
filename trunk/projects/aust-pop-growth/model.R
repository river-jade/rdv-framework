# R file for testing the output during dry runs


# parameters is the dataframe passed in from tzar with all the input variables
p <- parameters

buff.lengths <- seq( 100, 5000, 100)
#buff.lengths <- seq( 100, 400, 100)


source( 'model.functions.R' )


source( 'load.data.R' )




# assume have 100 people per km^2
dev.den <- p$development.denisty



# now need to find the buffer length that corresponds to each city growing by 5%

cat( '\n\n************* WORK OUT BUFFERS **********************\n' )

# make a dataframe to hold the results

city.buff.lengths <- data.frame( city.id=NA, 'buff_length(m)'=NA, 'buff_area(km2)'=NA, no.people.in.buff=NA,
                                city.name=city.names, city.pop.size=NA, growth.target=NA)

for( i in 1:no.cities ) {

    growth.target <- pop.sizes[i]*p$percentage.increase/100
    
    
    cat( '\n\n City:', city.names[i], '\tPop:', pop.sizes[i]/1000, '\tGrowth target:', growth.target/1000 )

    # Convert to km^2
    cur.buff.areas <- buffs[,i] * 1e-6

    # convert to people
    cur.no.of.people <- cur.buff.areas * p$development.denisty
    
    #cat( '\n curr buff areas in people:')
    #show( cur.no.of.people/1000 )

    # find the buffer size that is closest to the growth target
    cur.buff.index <- find.closest.buffer.size(growth.target, cur.no.of.people )
    cat( '\n the closest buffer size is:', buff.lengths[cur.buff.index], '\tindex:', cur.buff.index,
        '\tppl:',cur.no.of.people[cur.buff.index]/1000 )


    city.buff.lengths[i,1] <- i
    city.buff.lengths[i,2] <- round(buff.lengths[cur.buff.index],1)
    city.buff.lengths[i,3] <- round(cur.buff.areas[cur.buff.index],1)
    city.buff.lengths[i,4] <- round(cur.no.of.people[cur.buff.index],1)
    city.buff.lengths[i,6] <- pop.sizes[i]
    city.buff.lengths[i,7] <- growth.target
    
}

write.csv(city.buff.lengths, p$output.filename.city.buff.sizes.csv, row.names=FALSE )

write.table(city.buff.lengths, p$output.filename.city.buff.sizes, row.names=FALSE )

