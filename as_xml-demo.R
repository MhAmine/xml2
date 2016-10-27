#' ---
#' title: "First try at as_xml()"
#' output: github_document
#' ---

#+ setup, include = FALSE, cache = FALSE
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", error = TRUE)

#'
devtools::load_all(".")
library(magrittr)
#library(xmlview)

y_list <- list(
  setNames(letters[1:4], letters[1:4]),
  two = list(
    setNames(1:4 * 1.1, month.abb[1:4]),
    hey = c(TRUE, FALSE)
  ),
  three = NULL
)
attr(y_list$two, "attrib1") <- "hi"
attr(y_list$two, "attrib2") <- "hey"
y_list

y_xml <- as_xml(y_list)
#str(y_xml)

#+ include = FALSE
#y_xml %>% xml_view() # could xml2 pretty print like this w/o printing to file?
y_xml %>% as.character()     # really hard to look at
y_xml %>% write_xml("y.xml")

#' Here's the XML
#+ echo = FALSE, comment = ""
cat(htmltools::includeText("y.xml"))

#' Run this though `as_list()` and compare to original `y_list`. We can't really
#' roundtrip because there's no way to recover the atomic vectors. But I think
#' this is as close as you can reasonably get?
y_list
as_list(y_xml)
