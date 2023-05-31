## Scrape Data
library(rvest)
library(data.table)

wiki_html = read_html('https://en.wikipedia.org/wiki/Economic_impact_of_the_COVID-19_pandemic_in_the_United_States')

find_code = html_nodes(wiki_html, xpath='//div[@class="mw-parser-output"]/table[@class="wikitable"]')

wiki_table = html_table(find_code,fill=TRUE)

covid_data =  wiki_table[[1]]

# Transpose the data
covid_data_t = transpose(covid_data)

# Extract the 1st row of data, to be used as header
names(covid_data_t) = covid_data_t[1,]

# Remove the first row of data, which is a duplicate now
covid_data_t <- covid_data_t[-1,]

# Adjust the indexing of the data
rownames(covid_data_t) <- 1:nrow(covid_data_t)

library(tibble)

covid_data_t2 = add_column(covid_data_t, month = c('Feb','Mar','Apr','May','June','July','August'))

## Rename Columns
library(tidyverse)

covid_data_t3 = covid_data_t2 %>% 
rename(jobs_lvl=starts_with("Jobs, level"), jobs_mth=starts_with("Jobs, monthly"), 
unemp_rate=starts_with("Unemployment rate"), 
unemp_mil=starts_with("Number unemployed"), 
emp_pop=starts_with("Employment to population"), 
infl_rate=starts_with("Inflation rate"), 
snp500_mean=starts_with("Stock market S&P"), 
public_debt=starts_with("Debt held by public"), 
month=starts_with("month"))

## Convert to Numeric 
library(stringr)
covid_data_t3$jobs_lvl = as.numeric(str_remove_all(covid_data_t3$jobs_lvl, ','))
covid_data_t3$jobs_mth = str_remove_all(covid_data_t3$jobs_mth, ',')
covid_data_t3$snp500_mean = as.numeric(str_remove_all(covid_data_t3$snp500_mean, ','))
covid_data_t3$unemp_rate = as.numeric(str_remove_all(covid_data_t3$unemp_rate, '%'))
covid_data_t3$emp_pop = as.numeric(str_remove_all(covid_data_t3$emp_pop, '%'))
covid_data_t3$infl_rate = as.numeric(str_remove_all(covid_data_t3$infl_rate, '%'))
covid_data_t3$unemp_mil=as.numeric(covid_data_t3$unemp_mil)
covid_data_t3$public_debt=as.numeric(covid_data_t3$public_debt)


# If you want to convert jobs_mth into numeric, read this next section.
# Otherwise, just skip this and do not worry about jobs_mth.
# You cannot convert the jobs_mth into numeric because the - is not -.
# Why does that not make sense? It has to do with the encoding.
# Run these two functions and obtain the results as shown: 
#       charToRaw(covid_data_t3$jobs_mth[2])
#       charToRaw("-1373")
#
# The first returns this:
#       [1] e2 88 92 31 33 37 33
#
# The second returns this:
#       [1] 2d 31 33 37 33
#
# The results are different. Notice where the two are similar. The
# values "31 33 37 33" are similar. These are UTF-8 Hex values. The 
# value "31" corresponds to 1, the value "33" corresponds to 3, and
# "37" corresponds to 7. BTW, these are a "raw" data type.
#
# That leaves "e2 88 92" from the first and "2d" from the second function.
# Use this webpage https://www.utf8-chartable.de/unicode-utf8-table.pl?start=8704&number=128
# Find the name for the UTF-8 Hex value "e2 88 92". It is MINUS SIGN.
# Use this webpage https://www.utf8-chartable.de/unicode-utf8-table.pl.
# Find the name for the value "2d". It is HYPHEN-MINUS. While both look
# like -, they are actually different in the underlying binary of your
# computer. They are not the same.
#
# When converting a character into numeric, when "-" is in text, R
# assumes it is the HYPHEN-MINUS, not MINUS SIGN. This means you will
# need to convert the underlying encoding from one to the other. Or,
# simply detect when it is present and replace it with an alternative.

# First, obtain the HYPHEN-MINUS encoding value. We will use this
# later to check if a value in the data frame has it.
(minus_hyphen = str_remove(covid_data_t3$jobs_mth[2], '1373'))
# We want this as a raw data type. This gives us a vector of the
# UTF-8 Hex values.
(utf8hex = charToRaw(minus_hyphen))

# Create an empty vector to save our new values in as numeric
# Cannot use the existing data frame column since its data type
# is character.
jobs_mth_vec = vector()

for(i in covid_data_t3$jobs_mth) {
    check_val = charToRaw(i)
    # Compare the UTF-8 Hex values of the data to the HYPHEN-MINUS UTF-8 hex values
    # If a match does not exist, it just returns NA for each index; otherwise, it
    # indicates which index values have a match
    match_hex_vals = match(utf8hex, check_val)
    if(is.na(match_hex_vals[1]) == FALSE) {
        # A match was found, so we need to remove the HYPHEN-MINUS
        if(match_hex_vals[1] == 1 & match_hex_vals[2] == 2 & match_hex_vals[3] == 3) {
            check_val <- check_val [! check_val %in% utf8hex]
            check_val = paste("-", rawToChar(check_val), sep = '')
        }
    }
    else {
        # No match was found, so it's a positive value.
        check_val = i
    }
    jobs_mth_vec = append(jobs_mth_vec, as.numeric(check_val))
}

covid_data_t3$jobs_mth = jobs_mth_vec

write.table(covid_data_t3, file="F:\\MIS-PDS\\advanced-data-manipulation-ice-AmarnathKotagiri\\data\\scraped_data.txt", sep='\t')

covid_data2 = read.table(file = 'scraped_data.txt', header = TRUE, sep = '\t')


## Data Wrangling and Manipulation
covid_data2 %>% summarise(mean(jobs_lvl, na.rm=FALSE))

covid_data2 %>% summarise(median(jobs_lvl, na.rm=FALSE))

covid_data3 = covid_data2 %>% select(starts_with("j",ignore.case = TRUE)|contains("a",ignore.case = TRUE))

covid_data3 %>% filter(jobs_lvl>135000)

covid_data4 = covid_data2 %>% select(month,starts_with("j",ignore.case = TRUE)|contains("a",ignore.case = TRUE)) %>% filter(jobs_lvl>135000)