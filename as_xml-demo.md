First try at as\_xml()
================
jenny
Wed Oct 26 15:02:10 2016

``` r
devtools::load_all(".")
#> Loading xml2
#> unloadNamespace("xml2") not successful, probably because another loaded package depends on it.Forcing unload. If you encounter problems, please restart R.
#> This is libxml2 version 2.9.2
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
#> $one
#>   a   b   c   d 
#> "a" "b" "c" "d" 
#> 
#> $two
#> $two[[1]]
#> Jan Feb Mar Apr 
#> 1.1 2.2 3.3 4.4 
#> 
#> $two$hey
#> [1]  TRUE FALSE
#> 
#> attr(,"attrib1")
#> [1] "hi"
#> attr(,"attrib2")
#> [1] "hey"
```

I think I am producing the correct XML. One problem, two questions:

-   Preliminary: I know I would need to remove the use of purrr.
-   Problem: The return value is a list, with the same overall topology as `y_list`. Each leaf is, I believe, an instance of the single thing I should actually be returning: the thing that holds pointers to the document and root node. Currently I have to go find a leaf to get that. How do I fix that?
-   Question: I'm not sure I'm handling the "missing tag" issue the best way.
-   Question: I'm not sure `parent` should be an exposed argument. Should `as_xml()` only support creation of stand-alone XML (vs. creating XML from list and installing into existing XML)?

``` r
y_xml <- as_xml(y_list)

str(y_xml)
#> List of 2
#>  $ one:List of 4
#>   ..$ a:List of 2
#>   .. ..$ node:<externalptr> 
#>   .. ..$ doc :<externalptr> 
#>   .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   ..$ b:List of 2
#>   .. ..$ node:<externalptr> 
#>   .. ..$ doc :<externalptr> 
#>   .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   ..$ c:List of 2
#>   .. ..$ node:<externalptr> 
#>   .. ..$ doc :<externalptr> 
#>   .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   ..$ d:List of 2
#>   .. ..$ node:<externalptr> 
#>   .. ..$ doc :<externalptr> 
#>   .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>  $ two:List of 2
#>   ..$    :List of 4
#>   .. ..$ Jan:List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   .. ..$ Feb:List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   .. ..$ Mar:List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   .. ..$ Apr:List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   ..$ hey:List of 2
#>   .. ..$ :List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
#>   .. ..$ :List of 2
#>   .. .. ..$ node:<externalptr> 
#>   .. .. ..$ doc :<externalptr> 
#>   .. .. ..- attr(*, "class")= chr [1:2] "xml_document" "xml_node"
y_root <- y_xml[[1]][[1]]
str(y_root)
#> List of 2
#>  $ node:<externalptr> 
#>  $ doc :<externalptr> 
#>  - attr(*, "class")= chr [1:2] "xml_document" "xml_node"
```

`y_root` is what I want. Inspect it your favorite way.

``` r
#y_root %>% xml_view() # could xml2 pretty print like this w/o printing to file?
y_root %>% as.character()     # really hard to look at
#> [1] "<?xml version=\"1.0\"?>\n<root><one><a>a</a><b>b</b><c>c</c><d>d</d></one><two attrib1=\"hi\" attrib2=\"hey\"><elem><Jan>1.1</Jan><Feb>2.2</Feb><Mar>3.3</Mar><Apr>4.4</Apr></elem><hey><elem>TRUE</elem><elem>FALSE</elem></hey></two></root>\n"
y_root %>% write_xml("y.xml")
```

Run this though `as_list()` and compare to original `y_list`. We can't really roundtrip because there's no way to recover the atomic vectors. But I think this is as close as you can reasonably get.

``` r
w <- as_list(y_root)
y_list
#> $one
#>   a   b   c   d 
#> "a" "b" "c" "d" 
#> 
#> $two
#> $two[[1]]
#> Jan Feb Mar Apr 
#> 1.1 2.2 3.3 4.4 
#> 
#> $two$hey
#> [1]  TRUE FALSE
#> 
#> attr(,"attrib1")
#> [1] "hi"
#> attr(,"attrib2")
#> [1] "hey"
w
#> $one
#> $one$a
#> $one$a[[1]]
#> [1] "a"
#> 
#> 
#> $one$b
#> $one$b[[1]]
#> [1] "b"
#> 
#> 
#> $one$c
#> $one$c[[1]]
#> [1] "c"
#> 
#> 
#> $one$d
#> $one$d[[1]]
#> [1] "d"
#> 
#> 
#> 
#> $two
#> $two$elem
#> $two$elem$Jan
#> $two$elem$Jan[[1]]
#> [1] "1.1"
#> 
#> 
#> $two$elem$Feb
#> $two$elem$Feb[[1]]
#> [1] "2.2"
#> 
#> 
#> $two$elem$Mar
#> $two$elem$Mar[[1]]
#> [1] "3.3"
#> 
#> 
#> $two$elem$Apr
#> $two$elem$Apr[[1]]
#> [1] "4.4"
#> 
#> 
#> 
#> $two$hey
#> $two$hey$elem
#> $two$hey$elem[[1]]
#> [1] "TRUE"
#> 
#> 
#> $two$hey$elem
#> $two$hey$elem[[1]]
#> [1] "FALSE"
#> 
#> 
#> 
#> attr(,"attrib1")
#> [1] "hi"
#> attr(,"attrib2")
#> [1] "hey"
```
