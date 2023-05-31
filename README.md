[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-c66648af7eb3fe8bc4f294546bfd86ef473780cde1dea487d3c4ff354943c9ae.svg)](https://classroom.github.com/online_ide?assignment_repo_id=8592373&assignment_repo_type=AssignmentRepo)
# Advanced Data Manipulation ICE
In this assignment, you will use advanced functions in `tidyverse` to query and filter your data. These functions reduce the workload by simplifying and reducing your code.

To submit, please perform the following:
1. Rename the script file `ice_adv-data-manip.R` with the following name: `ice_lastname_firstname.R` where lastname is your last name and firstname is your first name.
1. Save your screenshots of your output to the directory `assets`. This directory exists at the same leve as `data`.
1. Link your screenshots in `submission.md` where appropriate. That is, if you have screenshots supporting your answers, link those screenshots next to your answer.
1. Answer questions in `submission.md`, linking any screenshots as necessary.
1. Push your assignment to GitHub.

## COVID-19 Pandemic in the United States
The COVID-19 pandemic in the United States is the deadliest pandemic in its history. With 842,141 confirmed deaths in [January of 2022](https://ourworldindata.org/covid-deaths), it has wrought many a change including the further polarization of American politics, increase in virtual work environments, manufacturing and supply chain complications, increase in online learning, greater engagement in video streaming and gaming, and many others.

The pandemic has negatively effected the economics of all countries including the [United States](https://en.wikipedia.org/wiki/Economic_impact_of_the_COVID-19_pandemic_in_the_United_States). A table on the linked page presents a [statistical summary](https://en.wikipedia.org/wiki/Economic_impact_of_the_COVID-19_pandemic_in_the_United_States#Statistical_summary) with various data including job levels, umemployment rate, inflation rate. The data is given for February through August.

## Scrape and Transpose Data
All the code for this subsection is provided in the R file. You have three options:
1. If you want to understand what this code is doing, then continue reading.
1. If not, just run the code in the R file starting on line 1 and ending on line 28; skip this section and start your assignment in the next section `Rename Columns`.
1. Otherwise, load the data file [transposed_data.txt](data/transposed_data.txt) and use it in the next section `Rename Columns`.

If you are reading this, then you are curious to know what some of the code is doing. For this assignment, you will scrape the data from the table in Wikipedia. For this, you will use `rvest` to pull the data. Use XPath as your selector type.

You should observe that the data you just scraped is not oriented properly. The variable names are contained on the left, with the data stretching to the right. The variable names should be located at the top row, not the left-most column. 

Transposing data can be tricky. To transpose data, at its simplest, use the function `t()`. If your data frame is named `wiki_data`, then you would do `t(wiki_data)` and save it as a new data frame. Unfortunately, transposing data is never that simple.

I recommend using the library `data.table` with its function `transpose()`. During the process of transposing the data, you will find the column headers are not the correct data. Instead, R inserted generic names. You will need to remove the header, and then convert the first row into the header. Additionally, by doing this, the indexing of the data frame will be changed and out of order. You will need to update the ordering. Below is some code showing how to perform these steps.

```R
# Transpose the data
covid_data_t = transpose(covid_data)

# Extract the 1st row of data, to be used as header
names(covid_data_t) = covid_data_t[1,]

# Remove the first row of data, which is a duplicate now
covid_data_t <- covid_data_t[-1,]

# Adjust the indexing of the data
rownames(covid_data_t) <- 1:nrow(covid_data_t)
```

Be sure you do not have `tidyverse` loaded while performing these functions. Some of the base R functions that `table.data` relies on will be changed by `tidyverse`, leading to errors.

Once the conversion is done, you will need to add the `month` data back in. During the transpose process, that data was lost. You can use the function `add_column()` from the library `tibble` (more information [here](https://tibble.tidyverse.org/reference/add_column.html)).

That is it! Your data is not ready for processing. On to the next section.

## Rename Columns (4 pts.)
With the data oriented correctly, using `dplyr`, rename columns like so:
* *Jobs, level (000s)* change to `jobs_lvl`
* *Jobs, monthly change (000s)* change to `jobs_mth`
* *Unemployment rate %* change to `unemp_rate`
* *Number unemployed (millions)* change to `unemp_mil`
* *Employment to population ratio %, age 25–54* change to `emp_pop`
* *Inflation rate % (CPI-All)* change to `infl_rate`
* *Stock market S&P 500 (avg. level)* change to `snp500_mean`
* *Debt held by public ($ trillion)* change to `public_debt`
* For the column with months, it should be named `month`

At this point, you should have a completely transposed data frame. Be aware that transposing data removes data type. This means the numerical columns are not considered numerical; they are character. In addition, when you attempt to convert data from character to numeric, you will encounter an error. Be sure all commas are removed from the data you are converting. The numeric data type does not allow commas. Convert everything except `jobs_mth` to numeric when you are ready.

You can use `str_remove_all()` from the Tidyverse library `stringr` to remove the commas from the column `jobs_lvl` like so:

```R
library(stringr)
covid_data_t$jobs_lvl = str_remove_all(covid_data_t$jobs_lvl, ',')
```

Do the same for `jobs_mth` by removing the commas. Then convert the data type from character to numeric *except* for `jobs_mth`. If you want more explanation, look at the comments in the R file.

Save the data file as a tab-dilimited file under the directory `data`. Name it `scraped_data.txt`. Link it in `submission.md`.

## Data Wrangling and Manipulation (6 pts.)
It is time to practice your data wrangling skills with R. Read your newly created data file back into R as a new data frame. Please perform the following tasks. Take a screen capture of your output and link it in `submission.md`.
1. Calculate the mean of `jobs_lvl`. (1 pt.)
1. Calculate the median of `jobs_lvl`. (1 pt.)
1. Select all columns that start with a *j* or contain an *a* (ignore case). Save it as a new data frame.  (1 pt.)
1. Using your newly created data frame, select data in which `jobs_lvl` was greater than 135,000. (1 pt.)
1. Using pipes `%>%`, perform the previous two operations together and save it as a new data frame. This means you should select columns that start with a *j* or contain an *a* (ignore case) and select months in which `jobs_lvl` was greater than 135,000. (2 pts.)
