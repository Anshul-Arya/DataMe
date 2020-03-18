# Clear the current workspace
rm(list = ls())

# Load all the required libraries
library(rvest)
library(selectr)
library(xml2)
library(stringr)
library(jsonlite)

# Hold the URL for the webpage we want to extract data from
url <- "https://www.amazon.in/OnePlus-Mirror-Black-64GB-Memory/dp/B0756Z43QS?tag=googinhydr18418-21&tag=googinkenshoo-21&ascsubtag=aee9a916-6acd-4409-92ca-3bdbeb549f80"
# Read the URL in html format
amazonweb <- read_html(url)

# Create a function to Extract HTML nodes
get_html_content <- function(webpage, html_comp, html_comp2, flag) {
  text_html <- html_nodes(webpage, html_comp)
  if (flag == TRUE) {
    text_html <- html_nodes(text_html, html_comp2)
  }
  text <- html_text(text_html)
  text <- str_replace_all(text, "[\r\n]", "")
  str_trim(text)
  return(text)
}

# Call the Function to Get the text from webpage
# There is parameter as FLAG in the function which can be passed as FALSE or TRUE it is there to extract the data
# if we need to go down in the HTML Label as in the case of size and Color

title  <- get_html_content(amazonweb,"h1#title",'span.selection', FALSE)  
price  <- get_html_content(amazonweb,"span#priceblock_ourprice",'span.selection',FALSE)
desc   <- get_html_content(amazonweb,"div#productDescription",'span.selection', FALSE)
rating <- get_html_content(amazonweb,"span#acrPopover",'span.selection', FALSE)
size   <- get_html_content(amazonweb,"div#variation_size_name","span.selection",TRUE)
color  <- get_html_content(amazonweb,"div#variation_color_name","span.selection",TRUE)

# Create a data frame for the extracted data
product_data <- data.frame(Title = str_trim(title), Price = price,
                           Description = str_trim(desc),
                           Rating = str_trim(rating), Size = size, Color = color)

str(product_data)

# Store the data as Json file
json_data <- toJSON(product_data)
cat(json_data)


