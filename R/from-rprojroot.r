# Functions in this file are private functions from the {rprojroot} 
# package and are subject to the associated license (MIT) and code of
# conduct. See https://github.com/r-lib/rprojroot for details.

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

