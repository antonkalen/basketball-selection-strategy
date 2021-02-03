save_csv <- function(x, file) {
  # Save file
  readr::write_csv(x = x, file = file)
  # Return path
  file
}

save_figure <- function(figure, path, filename, device, scale, width, height) {
  
  path <- here::here(path, paste(filename, device, sep = "."))
  
  if (device == "pdf") {
    ggplot2::ggsave(
      filename = path,
      plot = figure,
      device = Cairo::CairoPDF,
      scale = scale,
      width = width,
      height = height,
      units = "mm"
    )
  }
  
  if (device == "tiff") {
    ggplot2::ggsave(
      filename = path,
      plot = figure,
      device = "tiff",
      scale = scale,
      width = width,
      height = height,
      units = "mm"
    )
  }
  
  path
}

