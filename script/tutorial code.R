##advanced data wrangling - focusing on joining datsets with dplyr functions, and then advanced data wrangling with tidyr
###our data set is from the national plant survey - 
##we are going to focus on two datasets occurences and sampleinfowithlatlong - these have corresponding ids 

## aims: to understand intermediate  dyplyr functions + an introduction to tidyr functions
# understand new dplyr functions and the uses of tidyr
# learn how to join datasets, and then how to arrange and slice and then recombine datasets 
# functional uses of all of this
## I am expecting prior knowledge of pipes in dplyr + functions like mutate and filter
## in this tutorial I am going to show how to merge data sets by these ids using a family of dplyry functions (add columns of one to another)
# then demonstrate the use of arrange function and family of slice functions and touch briefly on bind_rows which can combine datasets (or in our case recombine)
## I am then going to switch to the tidyr package and look at separating columns and then how to replace NA values



library(dplyr)
occurences <- read.csv("data/occurrences_2015to2023.csv")
spatial_data <- read.csv("data/sampleinfowithlatlong_2015to2023.csv")


full_data <- full_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))



length(unique(inner_data$id))

length(unique(occurences$sample_id))
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





#this function seperates out characters in a column 
#in the dataset we want to do this to two different colums seperating by different conditions each time





### Staying with dyplyr we're going to look at arrange and slice functions
#slice_max to look at top domins (vice versa for slice_min)
#slice_sample to look at random amount
#and slice to look at certain rows 





#first arrange
#this allows us to choose the column we want to use to order the dataset. it automatically arranges that column from lowest to highest and then applies this across the whole dataset
arrange <- left_data %>% 
  arrange(LATITUDE)

#look at the data we now have the smallest latitudes at the top, and increasing as we go down the dataset -  a quick check look across to the country column, all the top part now says channel islands !
#now what about about getting the highest latitudes at the top of the dataset

arrange_desc <- tidy_data %>% 
  arrange(desc(LATITUDE))


#we see a latitiude of 59.9 which is the latitidue of the shetland islands!
#now that we have arranged our data we can use slice to create new datasheet of the highest or lowest latitiudes
#first slice - this allows you to pick individual rows by their numerical value, lets pick the middle one


slice_data <- tidy_data %>% 
  arrange(desc(LATITUDE)) %>% 
  slice(1000)


#this gives us the row of a plant species found at 1000 northernly point surveyed - not that useful 

slice_data <- tidy_data %>% 
  arrange(desc(LATITUDE)) %>% 
  slice(1:1000)

#this gives us datasheet of 1000 most northerly plants sampled - however what if I said there was an easier way - removing the need for arrange!

#introducing slice_max and slice_min

slice_max <- tidy_data %>% 
  slice_max(order_by = LATITUDE, n = 1000)


#also you may notice that slice_max has returned 1049 values, this is because if the latitidues after our 1000 are also the same, it will return these as well
#this is very helpful in our case as it doesn't split up quadrats, much simpler and more helpful than that arrange() slice() nonsense
#slice is still useful for example if you wanted to look specifically at the range around 1000 or to input a sequence looking at every 5th number, or if you didn't need to arrange the data

#now I'll hand it over to you try write the code for what you'd expect for looking at 1000 most southerly species

slice_min <- tidy_data %>% 
  slice_min(order_by = LATITUDE, n = 1000)


#well done, as you can see the same thing happens as with slice_max returning any identical values to so we end up with 1063

#Slicing is not always useful, for example if we were looking at domin it would be simpler to 



#finally I'll mention slice_sample

#this neat function allows you to take a random sample of the dataset

slice_sample <- tidy_data %>% 
  slice_sample(n = 1000)



#now onto some functions in tidyr


library(tidyr)
#THE FUNCTION has three key parts, first which column you want to seperate in our case preferred taxon, then names of the new columns you want to create (genus and species) and finally what you are seperating by. in preferred taxon, genus and species are seperated by a space and so we write " " to indicate this
#all together it looks like this after using a pipe

#this function seperates out characters in a column 
#in the dataset we want to do this to two different colums seperating by different conditions each time

seperate_tidyr <- left_data %>% 
  separate(preferred_taxon, into = c("Genus", "Species"), sep = " ")



#now instead of preferred_taxon column, we have two new columns Genus and Species

#but what if we want to keep the original column 
#simply add the code remove = FALSE
seperate_tidyr <- left_data %>%
  separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE)

#another way of writing by splitting by space is "\\s" the two backward slashes here indicate that whatever is next should be used to separate and s stands in for a space, these can be chained together if your splitting by multiple characters
#now the eagle eyed among you might have spotted that we had genus' such as salix (willow by its common name) which you may know hybridise like crazy and so its hard to determine species and so they have just been recorded by genus only
#when we separate by " " this returns NA in the new species column for all salix data and similar cases, what to do about this?

#well luckily tidyr has the answer for this as well
#we don't want to filter out all the values with NA for species instead just change NA for something more useful
#we do this using the replace_na (specifically designed for this problem!!) function in the tidyr package
seperate_tidyr <- seperate_tidyr %>% 
  replace_na(list(Species = "sp."))
#now we have replaced all NA values with sp something more useful



#next lets seperate the domin column to only keep the numeric values (this solves the syntax issue i mentioned earlier)

#try separating so we get the number from 1-10 in one column and the percentage in the other


# we can't simply write ". " and so instead must write "\\.\\s" this indicates that we want to split the column at the period followed by a space

#code
tidy_domin <- left_data %>% 
  separate(domin, into = c("domin", "percentage"), sep = "\\.\\s")





#challenge: I want to wrangle data to create a spatial graph with the 100 most southerly trees in the acer genus and same for the 100 most northerly trees in Great Britain. As well as replacing NA in the domin column with something more useful


challenge_data <- left_join(occurences, spatial_data,
                            by = c("sample_id" = "id")) %>%
  separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE) %>%
  replace_na(list(Species = "sp.")) %>% 
  replace_na(list(domin = "unknown")) %>% 
  filter(Genus == "Acer", country == "Britain") 

max <- challenge_data %>% 
  slice_max(order_by = LATITUDE, n = 100)

min <- challenge_data %>% 
  slice_min(order_by = LATITUDE, n = 100)

acer <- bind_rows(min, max)


 
#just by eyeballing the data you can see that 100 most northerly are spread across 3 bands of latitude, while southerly only 1

#code for plot - not shown on tutorial
library(ggthemes)
library(ggplot2)

(map <- ggplot(acer, aes(x = LONGITUDE, y = LATITUDE)) +
  borders("world", colour = "black", fill = "yellow", size = 0.3) + # Add base map
  coord_cartesian(xlim = c(-10, 5), ylim = c(48, 62)) + # UK bounds
  geom_point(aes(), size = 1.5, alpha = 0.8) + # Points colored by genus
  theme_map() + # Optional map theme
  theme(
    legend.position = "right", # Adjust legend position
    plot.title = element_text(size = 15, hjust = 0.5)
  ) +
  labs(title = "Spatial Distribution of Acer in the UK"))

ggsave("plots/acer_map.png", plot = map, width = 4, height = 3, dpi = 300)
