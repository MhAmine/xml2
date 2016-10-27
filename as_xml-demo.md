First try at as\_xml()
================
jenny
Wed Oct 26 23:07:43 2016

``` r
devtools::load_all(".")
#> Loading xml2
#> unloadNamespace("xml2") not successful, probably because another loaded package depends on it.Forcing unload. If you encounter problems, please restart R.
#> This is libxml2 version 2.9.2
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
#> [[1]]
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
#> 
#> $three
#> NULL

y_xml <- as_xml(y_list)
#str(y_xml)
```

Here's the XML

    <?xml version="1.0"?>
    <root>
      <elem>
        <a>a</a>
        <b>b</b>
        <c>c</c>
        <d>d</d>
      </elem>
      <two attrib1="hi" attrib2="hey">
        <elem>
          <Jan>1.1</Jan>
          <Feb>2.2</Feb>
          <Mar>3.3</Mar>
          <Apr>4.4</Apr>
        </elem>
        <hey>
          <elem>TRUE</elem>
          <elem>FALSE</elem>
        </hey>
      </two>
      <three/>
    </root>

Run this though `as_list()` and compare to original `y_list`. We can't really roundtrip because there's no way to recover the atomic vectors. But I think this is as close as you can reasonably get?

``` r
y_list
#> [[1]]
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
#> 
#> $three
#> NULL
as_list(y_xml)
#> $elem
#> $elem$a
#> $elem$a[[1]]
#> [1] "a"
#> 
#> 
#> $elem$b
#> $elem$b[[1]]
#> [1] "b"
#> 
#> 
#> $elem$c
#> $elem$c[[1]]
#> [1] "c"
#> 
#> 
#> $elem$d
#> $elem$d[[1]]
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
#> 
#> $three
#> list()
```
