# Advanced Data Wrangling 
### focusing on joining datsets with dplyr functions, and then advanced data wrangling with tidyr

## Tutorial Aims
- to understand intermediate  dyplyr functions + an introduction to tidyr functions
-  understand new dplyr functions and the uses of tidyr
-  learn how to join datasets, and then how to arrange and slice and then recombine datasets
-  functional uses of all of this

I am expecting prior knowledge of pipes in dplyr + functions like mutate and filter.

In this tutorial you will learn how to utilise several advanced dplyr functions including:
- how to merge data sets using the join functions
- the arrange function and versaility of slice functions 

I am then going to switch to the tidyr package and look at separating columns and then how to replace NA values.

## Data

the data we are using today is open source data gathered by volunteers for the national plant monitoring scheme. 1 km squares are selected all across the country and then volunteers go to these squares and record 5 plots in semi-natural habitats. This data is then collated across the country and used to help  understand the health of different habitats. Here is a link to their website for more information - https://www.npms.org.uk/index.php/ .

I am using to of their data sets for this tutorial, saved in the data file of the repository.
load the github repository here -- 



starter code to load the datasets

    library(dplyr)
    occurences <- read.csv("data/occurrences_2015to2023.csv")
    spatial_data <- read.csv("data/sampleinfowithlatlong_2015to2023.csv")


look at these datasets - they each have columns which have a specific id numbers for each datapoint so they can be crossreferenced. 

Be careful though, in occurences this column is named sample_id while in spatial_data its simply called id. 

That's all very well but what can we use this for? Well we can merge these two datasets so we have the species data alongside the latitude data. To do this we must look at the family of join functions. 

### Join functions
there are four join functions:

full_join, inner_join, left_join, right_join.

### full_join
full_join completely joins both datasets together by corresponding ids

    full_data <- full_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

this joins all our data together by sample_id for occurrences and id for spatial_data, if theres any that dont have a match in either data sheet they will still be included and the columns from the other data will return NA

look at the number of observation in the three objects we have
231171 in occurences, 23742 in spatial_data and 231171 in full_join.
    

The difference is because for each sample_id in  occurences we have multiple recordings (hence the larger number of baraibles) but only one recording for each id in spatial_data.

So lets find the number of unique sample_ids we have:

    length(unique(occurences$sample_id))

this gives us a value of 22760, slightly less than the 23740 observations seen in spatial_data. This means that there are definitely ids which are unique to spatial_data, however there might still be ids which are unique to occurences.


look at the number of variables, theres 7 in occurences and 13 in spatial_data. in full_data there's 19 this is because the two datasheets have been added together while the id and sample_id columnms have been merged into one - hence 19.

Also luckily for us, the spatial_data info is copied other for each matching id not just the first one.
Run this next code to see what I mean.

     library(tibble)
     data <- tibble(
     id = rep(10, 10),
     random_numbers = runif(10))
     space <- tibble(
     id = 10,
     no = 1)

    full_ex <- full_join(data, space,
                     by = c("value" = "value")

### Inner_join
next function: inner_join, this only returns rows where the id was found in both datasets

    inner_data <- inner_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

look at the numbers of observations in the full and inner data sets - they do not match! this means that one or both of the data sets has id numbers which do not line up with the other. (which we already deduced manually through exploring the lengths of unique ids)

### Left_join and Right_join

to check which one it is we can use left_join and right_join, left_join looks at the overlapping ids + the ids only found in the left dataset (the one written first - here it is occurences)
right join does the opposite 

    left_data <- left_join(occurences, spatial_data,
                       by = c("sample_id" = "id"))

this returns the same number as inner join meaning that the occurences (as the left dataset) has no ids that do not overlap.
from this we expect (again as we already deduced manually) when we do right join for all the non-overlapping ids to be found (explaining the difference between inner and full join). the number therefore should be the same as full_data

    right_data <- right_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

this returns, as expected, the same number of observation as full_data, meaning that only spatial_data has ids which are not found in occurences. 

### Arrange and Slice functions
- arrange - arranges dataset by one column
- slice to look at certain rows
- slice_max to look at top values of a column (vice versa for slice_min)
- slice_sample to look at sample of dataset

### Arrange

first arrange - this allows us to choose the column we want to use to order the dataset. it automatically arranges that column from lowest to highest and then applies this across the whole dataset

    arrange <- left_data %>% 
        arrange(LATITUDE)

look at the data we now have the smallest latitudes at the top, and increasing as we go down the dataset. a quick check look across to the country column, all the top part now says channel islands !

now what about about getting the highest latitudes at the top of the dataset

    arrange_desc <- tidy_data %>% 
         arrange(desc(LATITUDE))

We see a latitiude of 59.9 which is the latitidue of the shetland islands!

now that we have arranged our data we can use slice to create new datasheet of the highest or lowest latitiudes

### Slice - 
on its own this allows you to pick individual rows by their numerical value, lets pick the middle one
231171/2 = 115585.5 (lets round)

    slice_data <- tidy_data %>% 
        arrange(desc(LATITUDE)) %>% 
        slice(115586)

this gives us the row of a plant species found at most northernly point surveyed - not that useful 

    slice_data <- tidy_data %>% 
      arrange(desc(LATITUDE)) %>% 
      slice(1:115586)

this gives us half of the datasheet by northerly plants sampled - however what if I said there was an easier way - removing the need for arrange!

### slice_max and slice_min

    slice_max <- tidy_data %>% 
         slice_max(order_by = LATITUDE, n = 115586)


also you may notice that slice_max has returned 1049 values, this is because if the latitidues after our 1000 are also the same, it will return these as well.

this is very helpful in our case as it doesn't split up quadrats, much simpler and more helpful than that arrange() slice() nonsense.

note: slice is still useful for example if you wanted to look specifically at the range around 1000 or to input a sequence looking at every 5th number, or if you didn't want arranged data.

now I'll hand it over to you try write the code for what you'd expect for looking at half the dataset by southerly species.

    slice_min <- tidy_data %>% 
      slice_min(order_by = LATITUDE, n = 115586)

well done, as you can see the same thing happens as with slice_max returning any identical values to so we end up with 1063

Slicing is not always this useful, for example if we were looking at domin it would select all examples of 9. not 10 as the syntax is wrong (9 is not written as 09)  it would be simpler to use filter as this would make what the code was doing clearer.

### Slice sample

finally I'll mention slice_sample

this neat function allows you to take a random sample of the dataset

    slice_sample <- tidy_data %>% 
      slice_sample(n = 1000)

now tidyr

## TIDYR
first load the library

    library(tidyr)

we are going to look at the separate and replace_na functions.
### Separate
THE FUNCTION has three key parts, first which column you want to seperate in our case preferred taxon, then names of the new columns you want to create (genus and species) and finally what you are seperating by. for example (in our dataset) in the column preferred_taxon, genus and species are seperated by a space and so we write " " to indicate this.



this function seperates out characters in a column 
in the dataset we want to do this to two different colums seperating by different conditions each time


    seperate_tidyr <- left_data %>% 
     separate(preferred_taxon, into = c("Genus", "Species"), sep = " ")

now instead of preferred_taxon column, we have two new columns Genus and Species


but what if we want to keep the original column - simply add the code remove = FALSE


    seperate_tidyr <- left_data %>%
         separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE)




another way of writing by splitting by space is "\\s" the two backward slashes here indicate that whatever is next should be used to separate and s stands in for a space, these can be chained together if your splitting by multiple characters.

now the eagle eyed among you might have spotted that we have some where it has just been recorded by genus only. (This is the case for all salix data, as too difficult to determine between species due to hybridisation)

When we separarate these into genus and species this returns NA in the new species column for all salix data and similar cases, what to do about this?

well luckily tidyr has the answer for this as well.

### Replace

We don't want to filter out all the values with NA for species instead just change NA for something more useful.
We do this using the replace_na (specifically designed for this problem!!) function in the tidyr package

    seperate_tidyr <- seperate_tidyr %>% 
       replace_na(list(Species = "sp."))
       
now we have replaced all NA values with sp something more useful



next lets seperate the domin column:

Have a go. try separating so we get the number from 1-10 in one column and the percentage range in another


hint: we can't simply write ". " and so instead must write "\\.\\s" this indicates that we want to split the column at the period followed by a space


    tidy_domin <- left_data %>% 
      separate(domin, into = c("domin", "percentage"), sep = "\\.\\s")


## Challenge time
I want to wrangle data to create a spatial graph with the 100 most southerly trees in the acer genus and same for the 100 most northerly trees. As well as replacing NA in the domin column with something more useful.

    challenge_data <- left_join(occurences, spatial_data,
                            by = c("sample_id" = "id")) %>%
      separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE) %>%
      replace_na(list(Species = "sp.")) %>% 
      replace_na(list(domin = "unknown")) %>% 
      filter(Genus == "Acer") 

     max <- challenge_data %>% 
        slice_max(order_by = LATITUDE, n = 100)

     min <- challenge_data %>% 
       slice_min(order_by = LATITUDE, n = 100)

     acer <- bind_rows(min, max)



