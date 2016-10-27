## would go in utils.R
names2 <- function(x, .missing = "") {
  xnames <- names(x)
  if (is.null(xnames)) {
    rep(.missing, length(x))
  } else {
    ifelse(is.na(xnames) | !nzchar(xnames), .missing, xnames)
  }
}

## should probably be written for sharing with as_list()
escaped_attributes <- function(x) {
  attr <- attributes(x)
  special <- names(attr) %in% c("class", "comment", "dim", "dimnames", "names", "row.names", "tsp")
  # for now, I drop the special attributes vs rename them
  # I note that as_list() retains and renames:
  #names(attr)[special] <- paste0(".", names(attr)[special])
  attr <- attr[!special]
}

as_xml <- function(x, root_tag = "root", .missing_tag = "elem") {
  #doc <- xml_new_document()
  ## workaround to get UTF-8
  ## https://github.com/hadley/xml2/issues/142
  doc <- read_xml(paste0("<", root_tag, "></", root_tag, ">"))
  install_node(x, tag = root_tag, doc, .missing_tag = .missing_tag)
  xml_root(doc)
}

install_node <- function(x, tag, parent, .missing_tag = "elem") {
  x <- x %||% ""
  if (!purrr::is_vector(x)) {
    stop("Input must be a vector, not:", typeof(x), call. = FALSE)
  }
  this_node <- xml_add_child(parent, tag)
  attr <- escaped_attributes(x)
  if (length(attr) > 0) {
    purrr::map2(attr, names(attr), function(a, n) xml_attr(this_node, n) <- a)
  }
  if (purrr::is_scalar_atomic(x)) {
    if (!is.character(x)) {
      x <- as.character(x)
    }
    xml_text(this_node) <- x
    return(xml_root(this_node))
  }
  purrr::map2(x, names2(x, .missing_tag), ~ install_node(.x, .y, this_node))
}
