# PROJECT PRINCIPLES
#
# 1. A project consists of a set of analyses. 
#
# 2. An analysis consists of a set of components.
#
# 3. A component is stored as a directory and consists of either 
#      1. Data from other components, and an R script. Data generated by the 
#         run script must be stored in the same component directory where the 
#         data were created.
#      2. data only.
#
# 4. A component can depend on other components but dependencies cannot be
#    circular.
#
# 5. An analysis can depend on other analyses but dependencies cannot be
#    circular
#
# 6. A directory named "util" can be stored alongside component directories or
#    in a component directory and can hold R functions and data needed by 
#    components.

af_create_proj_yaml <- function() {
  list(version = "0.1")
}

# taken from rprojroot
find_files <- function(path, filename) {
  files <- dir(path = path, pattern = filename, all.files = TRUE,
               full.names = TRUE)
  dirs <- dir.exists(files)
  files <- files[!dirs]
  files
}

# taken from rprojroot
match_contents <- function (f, contents, n, fixed)
{
    if (is.null(contents)) {
        return(TRUE)
    }
    fc <- readLines(f, n)
    any(grepl(contents, fc, fixed = fixed))
}

# taken from rprojroot
rproj_test_fun <- function(path) {
  files <- find_files(path, "[.][Rr]proj$")
  for (f in files) {
    if (!match_contents(f, "^Version: ", 1L, FALSE)) {
      next
    }
    return(TRUE)
  }
  return(FALSE)
}

#' @importFrom rprojroot root_criterion
af_proj_root <- function() {
  root_criterion(
    function(path) length(find_files(file.path(path), ".afproj")) > 0, 
    "has an .afproj file.")
}

#' @title Get the Path of the Current Project
#' @export
af_project_dir <- function() {
  af_proj_root()$find_file()
}

#' @title Get the Path of the Current Analysis
#' @export
af_analysis_dir <- function() {
  af_analysis_root()$find_file()
}


#' @importFrom rprojroot root_criterion
af_analysis_root <- function() {
  root_criterion(
    rproj_test_fun,
    "has a .Rproj file.")
}

is_error <- function(expr) {
  tryCatch({
      expr
      FALSE
    },
    error = function(e) TRUE)
}

#' @importFrom checkmate check_class
has_rproj_root <- function(rc) {
  assert(check_class(rc, "root_criterion"))
  !is_error(rc$find_file())
}

af_is_proj <- function() {
  has_rproj_root(af_proj_root())
}

af_is_analysis <- function() {
  has_rproj_root(af_analysis_root())
}

#' @title Create a New Analysis Project
#'
#' @param proj_path the path to the new analyis project directory.
#' A file with the project name and .afproj extension will be created in the
#' directory.
#' @param setwd should the working directory be set to the new analysis
#' project directory? The default is FALSE.
#' @param ... other options passed to fs::dir_create.
#' @param verbose should extra information be put out to the console? The
#' default is `TRUE`?
#' @param proj_yaml the function to create the project yaml file. The
#' default is `af_create_proj_yaml()`.
#' @importFrom fs dir_create path path_file
#' @importFrom yaml write_yaml
#' @export
af_create_project <- 
  function(proj_path, setwd = FALSE, ..., verbose = TRUE, 
           proj_yaml = af_create_proj_yaml()) {

  dir_create(proj_path, ...)
  write_yaml(proj_yaml, 
             path(proj_path, ".afproj"))
  if (setwd) {
    if (verbose) {
      cat("Changing the directory to ", proj_path, "\n")
    }
    setwd(proj_path)
  }
  invisible(TRUE)
}

#' @title The Analysis Project Tree
#'
#' @aliases af_ptree 
#' @importFrom fs dir_tree
#' @export
af_project_tree <- function() {
  dir_tree(af_project_dir(), all = FALSE)
}

#' @export
af_ptree <- af_project_tree

#' @title The Analysis Tree
#'
#' @aliases af_atree 
#' @importFrom fs dir_tree
#' @export
af_analysis_tree <- function() {
  dir_tree(af_analysis_dir(), all = FALSE)
}

#' @export
af_atree <- af_analysis_tree

#' @importFrom checkmate assert check_character
verbatim <- function(s) {
  assert(check_character(s))
  class(s) <- "verbatim"
  s
}

#' @title the Default RStudio Project YAML file.
#' @export
af_create_rproj_yaml <- function() {
  list(
    Version = verbatim("1.0"),
    RestoreWorkspace = verbatim("No"),
    SaveWorkspace = verbatim("No"),
    AlwaysSaveHistory = verbatim("No"),
    EnableCodeIndexing = verbatim("Yes"),
    UseSpacesForTab = verbatim("Yes"),
    NumSpacesForTab = verbatim("2"),
    Encoding = verbatim("UTF-8"),
    RnwWeave = verbatim("Sweave"),
    LaTeX = verbatim("pdfLaTeX"))
}

#' @title Get the Current Project
#' @aliases af_get_proj
#' @export
af_get_project <- function() {
  basename(af_project_dir())
}

af_get_proj <- af_get_project

#' @title Get the Current Analysis
#' @export
af_get_analysis <- function() {
  basename(af_analysis_dir())
}

#' @title Create a New Analysis/Study
#' 
#' @param name the name of the analysis/study. This may be a path but a 
#' warning is generated if it is a path and it is called from within an
#' analysis project.
#' @param name the name of the new analysis.
#' @param setwd should the working directory be set to the new analysis
#' project directory? The default is FALSE.
#' @param ... other options passed to fs::dir_create.
#' @param verbose should extra information be put out to the console? The
#' default is `TRUE`?
#' @param rproj_yaml the function to create the R Studio project yaml file. The
#' default is `af_create_rproj_yaml()`.
#' @importFrom fs dir_create path path_file
#' @importFrom yaml write_yaml
#' @aliases af_create_study
#' @export
af_create_analysis <- function(name, setwd = FALSE, ..., verbose = FALSE,
                               rproj_yaml = af_create_rproj_yaml()) {

  # If create_analysis is called from inside an analysis project, then 
  # make sure the analysis is a subdirectory of the project.
  if (af_is_proj() && path_dir(name) == ".") {
    name <- path(af_project_dir(), name)
  }
  cat("Creating analysis: ", basename(name), "\n",
      "In directory: ", dirname(name), "\n\n", sep = "")
  dir_create(name, ...)
  write_yaml(rproj_yaml,
             path(name, path_file(name), ext = "rproj"))
  cat("Setting working directory to", path(name), "\n\n")
  if (setwd) {
    setwd(name)
  }
  invisible(TRUE)
}

#' @export
af_create_study <- af_create_analysis

#' @title Create a New Analysis Component
#' 
#' @importFrom fs dir_create path_split
#' @importFrom checkmate assert check_character
af_create_component <- function(name, ...) {
  assert(
    check_character(name)
  )

  nv <- unlist(path_split(name))
  if ( !(length(nv) == 1 && af_is_analysis()) ) {
    # Make sure an af anaysis is being referenced.
  }
#  if (!is_analysis) {
#    stop("You can only create components from within an analyis.")
#  }
  
  cat("Creating component: ", basename(name), "\n",
      "In directory: ", dirname(name), "\n")
  dir_create(comp_name, ...)
  # .Rproj extension.
}

# Put this off for now. Focus on project creation.
# Need to get everyone on board before implementing these.
af_read_rds <- function(file, refhook = NULL) {
  readRDS(file, refhook)
}

af_save_rds <- function(object, file = "", ascii = FALSE, version = NULL,
                        compress = TRUE, refhook = NULL) {
  saveRDS(object, file, ascii, version, compress, refhook)
}

af_source <- function(
  file, local = FALSE, echo = verbose, print.eval = echo,
  exprs, spaced = use_file,
  verbose = getOption("verbose"),
  prompt.echo = getOption("prompt"),
  max.deparse.length = 150, width.cutoff = 60L,
  deparseCtrl = "showAttributes",
  chdir = FALSE,
  encoding = getOption("encoding"),
  continue.echo = getOption("continue"),
  skip.echo = 0, keep.source = getOption("keep.source")) {

  source(file, local, echo, print.eval, exprs, spaced, verbose,
         prompt.echo, max.deparse.length, width.cutoff, deparseCtrl,
         chdir, encoding, continue.echo, skip.echo, 
         keep.source)
}

# The following could be implemented.
af_switch_analysis <- function(analysis_name) {
}

af_exit_analysis <- function() {
}

af_switch_project <- function(proj_name) {
}

af_switch_proj

af_exit_project <- function() {
}

af_exit_proj <- function() {
}

af_pushd <- function(path <- ".") {
}

af_popd <- function() {
}
