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
  one = setNames(letters[1:4], letters[1:4]),
  two = list(
    setNames(1:4 * 1.1, month.abb[1:4]),
    hey = c(TRUE, FALSE)
  )
)
attr(y_list$two, "attrib1") <- "hi"
attr(y_list$two, "attrib2") <- "hey"
y_list

#' I think I am producing the correct XML. One problem, two questions:
#'
#'   * Preliminary: I know I would need to remove the use of purrr.
#'   * Problem: The return value is a list, with the same overall topology as
#'     `y_list`. Each leaf is, I believe, an instance of the single thing I
#'     should actually be returning: the thing that holds pointers to the
#'     document and root node. Currently I have to go find a leaf to get that.
#'     How do I fix that?
#'  * Question: I'm not sure I'm handling the "missing tag" issue the best way.
#'  * Question: I'm not sure `parent` should be an exposed argument. Should
#'     `as_xml()` only support creation of stand-alone XML (vs. creating XML
#'     from list and installing into existing XML)?
y_xml <- as_xml(y_list)

str(y_xml)
y_root <- y_xml[[1]][[1]]
str(y_root)

#' `y_root` is what I want. Inspect it your favorite way.
#y_root %>% xml_view() # could xml2 pretty print like this w/o printing to file?
y_root %>% as.character()     # really hard to look at
y_root %>% write_xml("y.xml")

#' Run this though `as_list()` and compare to original `y_list`. We can't really
#' roundtrip because there's no way to recover the atomic vectors. But I think
#' this is as close as you can reasonably get.
w <- as_list(y_root)
y_list
w

