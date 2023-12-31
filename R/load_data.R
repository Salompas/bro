#' @title Load Data
#'
#' @description
#' Loads and returns a specified dataset from the data registry in the given execution environment.
#'
#' @details
#' This function retrieves the data registry from the provided execution environment. It checks if the specified dataset
#' exists in the registry and if the path to the data is available. If the dataset or path is missing, an error is raised.
#' The function then loads the dataset using the specified data loader based on the data type defined in the registry.
#' Messages are displayed indicating the successful loading of the dataset along with its type and loading method.
#'
#' @param name The name of the dataset to be loaded, as specified in the data registry.
#' @param execution The execution environment containing the data registry.
#'
#' @return Returns the loaded dataset, and it is also stored in the execution environment for further use.
#'
load_data <- function(name, execution) {

  ## Get data registry from execution environment
  registry <- execution$registry

  ## Stop if data does not exist
  if(! name %in% names(registry)) {
    stop("no entry '", name, "' in ", file.path("inst", "data.yaml"))
  }

  ## Stop if path to data is missing
  if(is.null(registry[[name]]$path)) {
    stop("missing 'path' in '", name, "' in ", file.path("inst", "data.yaml"))
  }

  ## Load data
  type <- registry[[name]]$type
  path <- do.call(file.path, append(list(), registry[[name]]$path))
  loader <- eval(parse(text = bro:::connectors[[type]]$load))
  message("(bro) Loading '", name, "' (", type, ", ", bro:::connectors[[type]]$load, ")")
  execution$data[[name]] <- do.call(what = loader, args = append(list(file = path), registry[[name]]$load_args))

  return(execution$data[[name]])
}
