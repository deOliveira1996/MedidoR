#' @title dtfilter
#' @description
#' Function to filter the data for the data.table output
#' @importFrom tidyr gather
#' @importFrom dplyr arrange
#' @export
#' @param x Dataframe to filter.

dtfilter <- function(x) {
  x <- x |>
    tidyr::gather(
      key = "Segments",
      value = "Pixel",
      -c(
        ID,
        Frame_Score,
        F_Alt,
        TO_Alt,
        C_Alt,
        Laser_Alt,
        Measured_Date,
        Species,
        cGSD,
        EstLength,
        Obs,
        Comments,
        Drone,
        Date,
        sw,
        iw,
        flen,
        Resolution,
        imid
      )
    ) |>
    dplyr::arrange(Measured_Date, by_group = ID)
  return(x)
}

#' @title show_measurement_modal
#' @description
#' Is a helper functions to generate modal dialog
#' @importFrom shiny showModal modalDialog
#' @keywords internal

show_measurement_modal <- function(message) {
  shiny::showModal(
    shiny::modalDialog(
      title = "Measurement Update",
      message,
      footer = shiny::modalButton("OK"),
      easyClose = TRUE
    )
  )
}

#' @title update_data_table
#' @description
#' Update the data table in UI
#' @importFrom DT datatable
#' @keywords internal

update_data_table <- function(path) {
  if (file.exists(path)) {
    DT::datatable(
      readxl::read_xlsx(path),
      options = list(
        pageLength = 11,
        autoWidth = TRUE,
        serverSide = TRUE
      )
    )
  }
}

#' @title get_directory_path
#' @description
#' Get the directory paths
#' @keywords internal
get_directory_path <- function(segments, user_dir) {
  dir_name <- if (segments == 1) {
    "10%_interval"
  } else if (segments == 2) {
    "05%_interval"
  } else if (segments == 3) {
    "Free_measurements"
  }
  normalizePath(file.path(user_dir, dir_name), mustWork = FALSE)
}

#' @title get_file_paths
#' @description
#' Generate the file paths for data
#' @keywords internal
get_file_paths <- function(dir_path, segments) {
  base_name <- if (segments == 1) {
    "Measurements_10"
  } else if (segments == 2) {
    "Measurements_05"
  } else if (segments == 3) {
    "Free_Measurements"
  }

  list(
    main = file.path(dir_path, paste0(base_name, ".xlsx")),
    secondary = file.path(dir_path, paste0(base_name, "_1.xlsx"))
  )
}

#' @title Create free measurement template
#' @description Generates free measurement templates
#' @importFrom writexl write_xlsx
#' @keywords internal
create_data_free <- function(path, path2) {
  dt <- data.frame(
    Drone = character(0), Resolution = character(0), ID = character(0),
    Obs = character(0), Species = character(0), Date = character(0),
    Measured_Date = character(0), TO_Alt = numeric(0), F_Alt = numeric(0),
    C_Alt = numeric(0), Laser_Alt = numeric(0), Frame_Score = character(0),
    sw = numeric(0), iw = numeric(0), flen = numeric(0), imid = character(0),
    Segments = character(0), Pixel = numeric(0),
    cGSD = numeric(0), EstLength = numeric(0), Comments = character(0)
  )
  writexl::write_xlsx(dt, path)
  writexl::write_xlsx(dt, path2) # Mantido para padronização de pipeline
}

#' @title update_measurements
#' @description
#' Update the data with calibration model estimates
#' @keywords internal
#' @importFrom writexl write_xlsx
#' @importFrom readxl read_xlsx
#' @importFrom dplyr mutate across

# Update measurements with model predictions
update_measurements <- function(main_path, secondary_path,
         model, calib_data,
         current_data = NULL) {
  if (file.exists(main_path)) {
    if (is.null(current_data)) {
      current_data <- readxl::read_xlsx(main_path)
      current_data_1 <- MedidoR:::dtfilter(current_data)
    }

    current_data_1$cGSD <- stats::predict(model, current_data_1)
    current_data_1$EstLength <- current_data_1$cGSD * current_data_1$Pixel

    fill_data <- current_data_1 |>
      dplyr::group_by(imid) |>
      dplyr::filter(Segments == "BL") |>
      dplyr::summarise(cGSD = dplyr::first(cGSD),
                       EstLength = dplyr::first(EstLength))

    current_data <- current_data |>
      dplyr::select(-cGSD, -EstLength) |>
      dplyr::left_join(fill_data, by = "imid")

    # CORREÇÃO: ObjLength removido da seleção
    measurements_1 <- current_data_1 |>
      dplyr::mutate(
        dplyr::across(
          c(Pixel, C_Alt, TO_Alt, F_Alt, Laser_Alt,
            sw, iw, flen, EstLength, cGSD),
          \(x) round(as.numeric(x), digits = 2)
        )
      )

    writexl::write_xlsx(x = current_data, path = main_path,
                        col_names = TRUE)
    writexl::write_xlsx(x = measurements_1, path = secondary_path,
                        col_names = TRUE)

    return(current_data)
  }
  return(NULL)
}

#' @title calib
#' @description
#' Import calibration data
#' @importFrom readxl read_excel
#' @importFrom dplyr select mutate across
#' @import tidyverse
#' @param file Path to the input file.


calib <- function(file = "") {
  readxl::read_excel(file) |>
    dplyr::select(Date, Pixel, ObjLength,
                  GPSAlt, TO_Alt, Laser_Alt) |>
    dplyr::mutate(
      Date = as.factor(Date),
      dplyr::across(c(Pixel, ObjLength,
                      GPSAlt, TO_Alt, Laser_Alt), as.numeric),
      C_Alt = GPSAlt + TO_Alt,
      eGSD = round((ObjLength/100)/Pixel, 4)
    )
}

#' @title create_data
#' @description Generates interval measurement templates
#' @importFrom writexl write_xlsx
#' @keywords internal

create_data <- function(segments, path, path2) {
  if (segments == 1) {
    dt <- data.frame(
      Drone = character(0), Resolution = character(0), ID = character(0),
      Obs = character(0), Species = character(0), Date = character(0),
      Measured_Date = character(0), TO_Alt = numeric(0), F_Alt = numeric(0),
      C_Alt = numeric(0), Laser_Alt = numeric(0), Frame_Score = character(0),
      sw = numeric(0), iw = numeric(0), flen = numeric(0), imid = character(0),
      BL = numeric(0),
      WD_10 = numeric(0), WD_20 = numeric(0), WD_30 = numeric(0),
      WD_40 = numeric(0), WD_50 = numeric(0), WD_60 = numeric(0),
      WD_70 = numeric(0), WD_80 = numeric(0), WD_90 = numeric(0),
      WD_F = numeric(0), cGSD = numeric(0), EstLength = numeric(0),
      Comments = character(0)
    )
    writexl::write_xlsx(dt, path)
    writexl::write_xlsx(dtfilter(dt), path2)

  } else {
    dt <- data.frame(
      Drone = character(0), Resolution = character(0), ID = character(0),
      Obs = character(0), Species = character(0), Date = character(0),
      Measured_Date = character(0), TO_Alt = numeric(0), F_Alt = numeric(0),
      C_Alt = numeric(0), Laser_Alt = numeric(0),Frame_Score = character(0),
      sw = numeric(0), iw = numeric(0), flen = numeric(0), imid = character(0),
      BL = numeric(0),
      WD_05 = numeric(0), WD_10 = numeric(0), WD_15 = numeric(0),
      WD_20 = numeric(0), WD_25 = numeric(0), WD_30 = numeric(0),
      WD_35 = numeric(0), WD_40 = numeric(0), WD_45 = numeric(0),
      WD_50 = numeric(0), WD_55 = numeric(0), WD_60 = numeric(0),
      WD_65 = numeric(0), WD_70 = numeric(0), WD_75 = numeric(0),
      WD_80 = numeric(0), WD_85 = numeric(0), WD_90 = numeric(0),
      WD_95 = numeric(0), WD_F = numeric(0), cGSD = numeric(0),
      EstLength = numeric(0), Comments = character(0)
    )
    writexl::write_xlsx(dt, path)
    writexl::write_xlsx(dtfilter(dt), path2)
  }
}

#' @title Create measurement template
#' @description Generates interval measurement templates
#' @importFrom writexl write_xlsx
#' @keywords internal

create_data2 <- function(path) {
  dt <- data.frame(
    Drone = character(0), Resolution = character(0), ID = character(0),
    Obs = character(0), Date = character(0), Measured_Date = character(0),
    TO_Alt = numeric(0), F_Alt = numeric(0), C_Alt = numeric(0), Laser_Alt = numeric(0),
    OBJ_L = numeric(0), OBJ_P = numeric(0), sw = numeric(0), iw = numeric(0),
    flen = numeric(0), imid = character(0), Comments = character(0)
  )
  writexl::write_xlsx(dt, path, col_names = T)
}
