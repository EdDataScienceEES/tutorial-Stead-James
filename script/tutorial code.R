##advanced data wrangling - focusing on joining datsets with dplyr functions, following this up with pipes and then advanced data wrangling with tidyr
###our data set is from the national plant survey - 
##we are going to focus on two datsets occurences and sampleinfowithlatlong - these have corresponding ids 

## the aim is to complete data wrangling such that I would then to be able to produce a spatial map of certain
## in this tutorial i am going to first show how to merge these datasets by these ids using a family of dplyry functions (umbrella join)
## I am expecting prior knowledge of pipes in dplyr + functions like mutate and filter
## I am then going to switch to the tidry package and look at separating columns and how to replace na values


library(dplyr)
occurences <- occurrences_2015to2023
spatial_data <- sampleinfowithlatlong_2015to2023


full_data <- full_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

##this joins all our data together by sample_id for occurrences and id for spatial_data, if theres any that dont have a match in either data sheet they will still be included 
##and the columns from the other data will return NA

##look at the number of variables, theres 7 in occurences and 13 in spatial_data. in full_data there's 19 this is because the two datasheets have been added together while the id and sample_id columnms have been merged into one - hence 19

inner_data <- inner_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

##this does the same but only joins id and samples_id which is shared by both 

##look at the numbers of observations in the full and inner data sets - they do not match! this means that one or both of the data sets has id numbers which do not line up with the other

##to check this we can use left_join and right_join, left_join looks at the overlapping ids + the ids only found in the left dataset (the one written first - here it is occurences)
#right join does the opposite

left_data <- left_join(occurences, spatial_data,
                       by = c("sample_id" = "id"))

##this returns the same number as inner join meaning that the occurences (as the left dataset) has no ids that do not overlap
##from this we expect when we do right join for all the non-overlapping ids to be found (explaining the difference between inner and full join). the number therefore should be the same as full_data


right_data <- right_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

###this returns the same number of observation as full_data, meaning that only spatial_data has ids which are not found in occurences. 

rm(list=ls())



library(tidyr)
library(dplyr)
occurences <- occurrences_2015to2023
spatial_data <- sampleinfowithlatlong_2015to2023


#tidry separate function
#this function seperates out characters in a column 
#in the dataset we want to do this to two different colums seperating by different conditions each time

left_data <- left_join(occurences, spatial_data,
                       by = c("sample_id" = "id"))

#THE FUNCTION has three key parts, first which column you want to seperate in our case preferred taxon, then names of the new columns you want to create (genus and species) and finally what you are seperating by. in preferred taxon, genus and species are seperated by a space and so we write " " to indicate this
#all together it looks like this after using a pipe
seperate_tidyr <- left_data %>% 
  separate(preferred_taxon, into = c("Genus", "Species"), sep = " ")



#now instead of preferred_taxon column, we have two new columns Genus and Species

#but what if we want to keep our column keeping them together 
#simply add the code remove = FALSE
seperate_tidyr <- left_data %>%
  separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE)

#another way of writing by spltting by space is "\\s" the two backward slashes here idnicate that whatever is next should be used to seperate and s stands in for a space, these can be chained together if your splitting by multiple characters
#now the eagle eyed among you might have spotted that we had genuses such as salix which you may know hybridise like crazy and so its hard to determine species and so they have just been written down as genus
#when we seperate by " " this returns NA in the new species column, what to do about this?

#well luckily tidyr has the answer for this as well but first lets seperate the domin column to only keep the numeric values
#try separating so we get the number from 1-9 in one column and the percentage in the other


# we can't simply write ". " and so instead must write "\\.\\s" this indicates that we want to split the column at the period followed by a space

#code
tidy_domin <- seperate_tidyr %>% 
  separate(domin, into = c("domin", "percentage"), sep = "\\.\\s")

#


#code all together


left_data <- left_join(occurences, spatial_data,
                       by = c("sample_id" = "id")) %>% 
              mutate(Genus_species = preferred_taxon) %>% 
              separate(preferred_taxon, into = c("Genus", "Species"), sep = " ") %>% 
              replace_na(list(Species = "sp.")) %>% 
              filter(Domin != "NA")
              


