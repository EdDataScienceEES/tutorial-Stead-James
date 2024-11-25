
# Advanced Data Wrangling 
### Focusing on joining datsets with dplyr functions, and then advanced data wrangling with tidyr


_Created by James Stead_
  
---------------------------------------------------

## Tutorial Aims
-  to understand advanced  dyplyr functions + an introduction to tidyr functions
-  understand new dplyr functions and the uses of tidyr
-  learn how to join datasets, and then how to arrange and slice and then recombine datasets
-  functional applications

I am expecting prior knowledge of pipes in dplyr + functions like mutate and filter. As well as more intermediate dplyr functions like bind_rows.

## Learning Objectives
In this tutorial you will learn how to utilise several advanced dplyr functions including:
- how to merge data sets using the join functions
- the arrange function and versaility of slice functions
   
Introduction to tidyr, including:
- seperating columns to your needs
- how to replace NA values that arise


## Introduction

If you've come across this tutorial you'll probably be a wizz at dpylr but you're already getting bored of mutates and filters? Want to learn new exciting dplyr functions as well as an introduction to another package?? Then this is the tutorial for YOU (yes you right there I believe in you)

First off, the data we are using in this tutorial is open source data gathered by volunteers for the National Plant Monitoring Scheme (NPMS). 1 km squares are selected all across the country and then volunteers go to these squares and record 5 plots in semi-natural habitats. This data is then collated across the country and used to help  understand the health of different habitats. Here is a link to their website for more information - <https://www.npms.org.uk/index.php/>

I am using two of their data sets for this tutorial, saved in the data file of the repository.

Unzip the github repository here (or, if you know how, use version control on R and copy the URL, whatever tickles your fancy) -- <https://github.com/EdDataScienceEES/tutorial-Stead-James>


## Load the datasets
code to load the datasets

    library(dplyr)
    occurences <- read.csv("data/occurrences_2015to2023.csv")
    spatial_data <- read.csv("data/sampleinfowithlatlong_2015to2023.csv")


Look at these datasets - they each have columns which have a specific id numbers for each datapoint so they can be crossreferenced. 

Be careful though as there are multiple id columns. For the ones that relate to each other, in occurences it is sample_id while in spatial_data it is id. 

That's all very well but what can we use this for? Well we can merge these two datasets so we have the species data alongside the lat and long data. To do this we must look at the family of join functions. 

### Joins in R

![image](https://github.com/user-attachments/assets/9380f90a-7a5c-479b-b582-e8f3f002792e)


**What are Joins?**

Joins allow you to merge two datasets by matching values in a common column. This is useful when you have related information spread across multiple datasets and want to analyze it together.

For example, you might have:

- Dataset 1 (occurences): Contains species observations with a unique sample_id.
- Dataset 2 (spatial_data): Contains location data for id values.
  
By joining these datasets on sample_id and id, we can combine biological and spatial information.

-----------


Let's explore the datasets a bit before we jump into joins.

- Observations in Datasets:
   - occurences: 231,171 observations
   -  spatial_data: 23,742 observations

The differing observation counts occur because:

- occurences: Each sample_id can appear multiple times (one for each species recorded).
- spatial_data: Each id is unique (one row per location).

So lets find the number of unique sample_ids we have:

    length(unique(occurences$sample_id))

this gives us a value of 22,760, fewer than the 23,742 observations in spatial_data, confirming that there must be some IDs that exist in spatial_data but not in occurences.

----------------------------


### Four main join types


Here's a summary of the main join types you will use in R.


| Join Type | Description | Use Case |
|----------|----------|----------|
| inner_join  | Rows where IDs match in both datasets   | When you need complete overlap  |
| full_join  | All rows from both datasets, with unmatched IDs filled as NA  | When you need all data  |
| left_join | All rows from the first dataset, matched with the second | Preserving all ids from occurences
| right_join | All rows from the second dataset, matched with the first | Preserving all ids from spatial_data


### full_join
The full_join() function merges two datasets by including all rows, even if some IDs don’t have a match as we expect to happen. Unmatched rows will have NA in columns from the other dataset.

    full_data <- full_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

**Why Does full_data Have 19 Columns?**
- occurences: 7 columns
- spatial_data: 13 columns
- full_data: 19 columns, after joining, specified columns (ie sample_id and id) are merged into one.


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

This has the same number of observations as inner_data meaning that the occurences (as the left dataset) has no ids that do not overlap.
From this we expect (again as we already deduced manually) when we do right join for all the non-overlapping ids to be found (explaining the difference between inner and full join). The number therefore should be the same as full_data

    right_data <- right_join(occurences, spatial_data,
                         by = c("sample_id" = "id"))

This returns, as expected, the same number of observation as full_data, meaning that only spatial_data has ids which are not found in occurences. 




## Arrange and Slice functions
- arrange - arranges dataset by one column
- slice to look at certain rows
- slice_max to look at top values of a column (vice versa for slice_min)
- slice_sample to look at sample of dataset

### Arrange 


![image](https://github.com/user-attachments/assets/7e3aa725-e5f9-481e-aff9-2c67b93b5861)

  

first arrange - this allows us to choose the column we want to use to order the dataset. it automatically arranges that column from lowest to highest and then applies this across the whole dataset

    arrange <- left_data %>% 
        arrange(LATITUDE)

look at the data we now have the smallest latitudes at the top, and increasing as we go down the dataset. a quick check look across to the country column, all the top part now says channel islands !

now what about about getting the highest latitudes at the top of the dataset

    arrange_desc <- tidy_data %>% 
         arrange(desc(LATITUDE))

We see a latitiude of 59.9 which is the latitidue of the shetland islands!

now that we have arranged our data we can use slice to create new datasheet of the highest or lowest latitiudes

### Slice 

On its own this allows you to pick individual rows by their numerical value, lets pick the 1st one

    slice_data <- tidy_data %>% 
        arrange(desc(LATITUDE)) %>% 
        slice(1)

this gives us the row of a plant species found at most northernly point surveyed - not that useful. However we can select more.

    slice_data <- tidy_data %>% 
           arrange(desc(LATITUDE)) %>%
           slice(1, 10, 100, 1000)

this gives us four rows (to select your own just separate each value by a comma). However we can alos select by a range
 
    slice_data <- tidy_data %>% 
      arrange(desc(LATITUDE)) %>% 
      slice(1:1000)

this gives us the first 1000 rows of the datasheet by northerly plants sampled - however what if I said there was an easier way - removing the need for arrange!



### slice_max and slice_min

    slice_max <- tidy_data %>% 
         slice_max(order_by = LATITUDE, n = 1000)


slice_max includes ties, so it may return more rows than requested if there are duplicate values.

![image](https://github.com/user-attachments/assets/211dcf69-cea1-413b-8f39-04528fcbfd84)


this is very helpful in our case as it doesn't split up quadrats (each one has the same latitiude and longitude), much simpler and more helpful than using arrange() and slice().

(Can you think of a case where arrange() and slice() would be more helpful)

note: slice is also useful if you don't want to arrange the dataset at all, just don't use arrange, or where you want to find a range in the middle of a dataset.

now I'll hand it over to you try write the code for what you'd expect for looking at half the dataset by southerly species.


<details>
<summary>Click to expand code once you've had a go</summary>

    slice_min <- tidy_data %>% 
      slice_min(order_by = LATITUDE, n = 1000)

</details>

well done, as you can see the same thing happens as with slice_max returning any identical values to so we end up with 1093

![image](https://github.com/user-attachments/assets/371c6ab6-059c-4b2f-bd12-ed62ced413a8)



Using slice_max is not always ideal. For example, if we were looking for the highest number in the domin column, slice_max will incorrectly select all examples of "9" instead of "10." This happens because "9" is not written as "09," so it's treated as greater than "10" due to lexicographical ordering. Similarly, if there were numbers like "90" in the dataset, they could also be incorrectly treated as equal to "9." Using a filter in this instance would make the code's intent clearer and ensure the correct values are selected, and there are only 10 available values so choosing a value to filter by is easier.

### Slice_sample

finally I'll mention slice_sample

this neat function allows you to take a random sample of the dataset

    slice_sample <- tidy_data %>% 
      slice_sample(n = 1000)


You now have several more dpylr functions to add to your holster. 


now onto tidyr

---------------------------------------------------

# TIDYR
first load the library

    library(tidyr)

The tidyr package specializes in reshaping and cleaning datasets. Two key functions we’ll focus on are separate() (to split one column into multiple columns) and replace_na() (to handle missing values).

### Separate

The separate() function splits the values in a column into multiple columns. The key arguments are:

col: The name of the column to split.
into: A vector of names for the new columns.
sep: The character or pattern to split by.
For example, in preferred_taxon, genus and species are separated by a space. We can use separate() to create two new columns: Genus and Species."

In our dataset we want to do this to two different colums seperating by different conditions each time


    seperate_tidyr <- left_data %>% 
     separate(preferred_taxon, into = c("Genus", "Species"), sep = " ")

now instead of preferred_taxon column, we have two new columns Genus and Species

If you want to retain the original column alongside the new columns, use remove = FALSE. This is useful if you need to preserve the original format for reference or further analysis.

     seperate_tidyr <- left_data %>%
         separate(preferred_taxon, into = c("Genus", "Species"), sep = " ", remove = FALSE)
         



Pro Tip: Instead of sep = " ", you can use sep = "\ \s" to indicate a space. The \ \ tells R to treat s as a special character for space. This is especially useful if splitting by multiple characters.



After separating, you might notice some rows have only a genus (e.g., Salix), leaving the Species column as NA. Instead of filtering these out, how can we replace these missing values with something meaningful?

Well luckily tidyr has the answer for this as well.

### Replace

replace_na() allows us to fill NA values with a specified value. For example, we can replace missing species names with sp. to indicate an unspecified species.

    seperate_tidyr <- seperate_tidyr %>% 
       replace_na(list(Species = "sp."))
       
now we have any NA values in the species column have been replaced with sp.

### Separate the domin Column
Let’s apply separate() to another column. The domin column contains values like 9. 76-90%. Split this into two columns:

- domin (1–10 scale).
- percentage (percentage range).

Have a go on your own


hint: we're seperating out by multiple characters (look at the pro tip again if you're stuck)


If you're stuck here's the code

<details>
<summary>Click to expand code</summary>


    tidy_domin <- left_data %>% 
      separate(domin, into = c("domin", "percentage"), sep = "\\.\\s")

</details>

## Challenge time
I want to spatially map the most northerly and southerly acer trees in britain. For this, please create a dataset of the 100 most northerly and southerly Acer trees.

hint: after you've created objects for north and south, use bind_rows to merge them into a new dataset.


<details>
<summary>Click to expand code</summary>

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

</details>




