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

as_xml <- function(x, tag = "root", parent = NULL, .missing_tag = "elem") {
  if (!purrr::is_vector(x)) {
    stop("Input must be a vector, not:", typeof(x), call. = FALSE)
  }
  if (!inherits(parent, "xml_node")) {
    parent <- xml_new_document()
  }
  this_node <- xml_add_child(parent, tag)
  attr <- escaped_attributes(x)
  if (length(attr) > 0) {
    purrr::map2(attr, names(attr), function(a, n) xml_attr(this_node, n) <- a)
  }
  if (purrr::is_scalar_atomic(x)) {
    xml_text(this_node) <- as.character(x)
    return(xml_root(this_node))
  }
  purrr::map2(x, names2(x, .missing_tag), ~ as_xml(.x, .y, this_node))
}
