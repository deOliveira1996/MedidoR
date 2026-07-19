options(shiny.maxRequestSize = 50 * 1024^2)

safe_char <- function(x) {
  if (is.null(x) || length(x) == 0 || trimws(as.character(x)) == "") {
    return(NA_character_)
  }
  return(as.character(x))
}

safe_num <- function(x) {
  if (is.null(x) || length(x) == 0 || trimws(as.character(x)) == "") {
    return(NA_real_)
  }
  val <- suppressWarnings(as.numeric(x))
  if (is.na(val)) return(NA_real_)
  return(val)
}

# Define server
server <- function(input, output, session) {

  # Reactive values ----
  rv <- shiny::reactiveValues(

    scale_measurements = data.frame(Length_X = numeric(),
                                    Length_Y = numeric()),

    main_data = NULL,
    main = NULL,
    dir_path = NULL,

    user_dir = getwd(),

    new_id = character(),
    new_res = character(),
    new_date = character(),
    new_f_alt = numeric(),
    new_to_alt = numeric(),
    new_calti = numeric(),
    new_laser_alt = numeric(),
    new_objL = numeric(),
    new_objP = numeric(),
    new_iw = numeric(),
    new_sw = numeric(),
    new_flen = numeric(),
    new_drone = character(),

    current_image = NULL,
    crop_status = FALSE,
    add_status = TRUE,
    click_save = FALSE,

    img_width = 0,
    img_height = 0,
    plot_ranges_x = NULL,
    plot_ranges_y = NULL
  )

  ############################ Path  block ############################

  # Directory handling ----
  shiny::observeEvent(input$path, {
    shiny::showModal(
      shiny::modalDialog(
        title = "Set Working Directory",
        shiny::textInput("wd", "Enter directory path:", value = getwd()),
        footer = tagList(
          shiny::actionButton("confirmBtn", "Confirm", class = "btn-primary"),
          shiny::modalButton("Cancel")
        )
      )
    )
  })

  # Confirmation  block
  shiny::observeEvent(input$confirmBtn, {
    req(input$wd)
    setwd(input$wd)
    rv$user_dir <- input$wd
    shiny::removeModal()
  })

  # Create  block
  shiny::observeEvent(input$create, {
    req(rv$user_dir)

    dir_path <- file.path(rv$user_dir)
    paths <- file.path(dir_path, paste0("calib", ".xlsx"))

    rv$main <- paths
    rv$dir_path <- dir_path

    tryCatch({
      if (!file.exists(rv$main)) {
        MedidoR:::create_data2(path = rv$main)
        shiny::showModal(shiny::modalDialog(
          title = "Success",
          "Scale calibration dataframe created",
          footer = shiny::modalButton("OK")
        ))

        rv$main_data <- readxl::read_xlsx(path = rv$main, col_names = T)

        output$mTable <- DT::renderDataTable({
          rv$main_data
        })

      } else {
        shiny::showModal(
          modalDialog(
            title = "Info",
            "Dataframe already exists, please IMPORT instead",
            footer = shiny::modalButton("OK")
          )
        )
      }
      return(TRUE)
    }, error = function(e){
      showNotification(paste("Error:", e$message), type = "error")
      return(FALSE)
    })
  })

  # Import  block
  shiny::observeEvent(input$import, {
    req(rv$user_dir)

    dir_path <- file.path(rv$user_dir)
    paths <- file.path(dir_path, paste0("calib", ".xlsx"))

    rv$main <- paths
    rv$dir_path <- dir_path

    tryCatch({
      if (file.exists(rv$main)) {
        rv$main_data <- readxl::read_xlsx(rv$main)

        shiny::showModal(
          shiny::modalDialog(
            title = "Success",
            "Scale calibration dataframe imported",
            footer = shiny::modalButton("OK")
          )
        )

        output$mTable <- DT::renderDataTable({
          rv$main_data
        })

      } else {
        shiny::showModal(
          shiny::modalDialog(
            title = "Error",
            "Dataframe not found, please CREATE instead",
            footer = shiny::modalButton("OK")
          )
        )
      }
      return(TRUE)
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error")
      return(FALSE)
    })
  })

  ############################ Image block ############################

  # Image processing ----
  shiny::observeEvent(input$file, {
    req(input$file)
    img <- imager::load.image(input$file$datapath)
    rv$current_image <- img
    rv$img_width <- imager::width(img)
    rv$img_height <- imager::height(img)
  })

  # Crop  block
  shiny::observeEvent(input$crop, {
    req(input$file)
    req(input$plot_brush)

    # Set crop area
    rv$plot_ranges_x <- c(input$plot_brush$xmin, input$plot_brush$xmax)
    rv$plot_ranges_y <- c(input$plot_brush$ymax, input$plot_brush$ymin)

    # Update states
    rv$crop_status <- TRUE
    shiny::updateActionButton(session, "crop", disabled = TRUE)
  })

  output$crop_status <- shiny::renderUI({
    req(input$file)
    if (!rv$crop_status == TRUE) {
      div(
        class = "alert alert-info",
        "Step 1: Select the area of interest on the image using the selection tool and click 'Crop'"
      )
    } else {
      div(class = "alert alert-success", "Area selected!")
    }
  })

  ############################ Image plot  block ############################

  draw_measurement_lines <- function() {
    req(rv$current_image, rv$scale_measurements)

    lp <- rv$scale_measurements
    if (nrow(lp) < 2) return()

    start <- data.frame(x = lp$Length_X[1], y = lp$Length_Y[1])
    end <- data.frame(x = lp$Length_X[2], y = lp$Length_Y[2])

    # Main lines
    graphics::segments(start$x, start$y, end$x, end$y, col = "red", lwd = 1.5)

    total_length <- sum(sqrt(diff(lp$Length_X)^2 + diff(lp$Length_Y)^2))
    rv$new_objP <- total_length
  }

  output$imagePlot <- shiny::renderPlot({
    req(rv$current_image)

    if (rv$crop_status == TRUE) {
      plot(
        rv$current_image,
        xlim = rv$plot_ranges_x,
        ylim = rv$plot_ranges_y,
        main = input$file$name,
        axes = T
      )

      if (nrow(rv$scale_measurements) > 0) {
        points_df <- rv$scale_measurements |>
          dplyr::mutate(
            x_plot = rv$scale_measurements$Length_X,
            y_plot = rv$scale_measurements$Length_Y
          )
        graphics::points(points_df$x_plot, points_df$y_plot, col = "red", cex = 1.5)
      }

      if (nrow(rv$scale_measurements) == 2) {
        draw_measurement_lines()
      }
    } else {
      plot(rv$current_image, main = "Select area of interest", axes = T)
    }
  })

  ############################ Plot click  block ############################

  shiny::observeEvent(input$plot_click, {
    req(input$crop, rv$crop_status)

    tryCatch({
      if (nrow(rv$scale_measurements) != 2) {
        rv$scale_measurements <- rbind(
          rv$scale_measurements,
          data.frame(
            Length_X = input$plot_click$x,
            Length_Y = input$plot_click$y
          )
        )
        if (nrow(rv$scale_measurements) == 2) {
          MedidoR:::show_measurement_modal("Length measurements completed.")
          shiny::showModal(
            shiny::modalDialog(
              title = "Measurement Progress",
              HTML(
                "<b>Scale measurement complete!</b><br>
             Click on ADD-IN button to proceed."
              ),
              footer = shiny::modalButton("Continue"),
              easyClose = TRUE
            )
          )
          rv$add_status <- FALSE
        }
      }
      return(TRUE)
    }, error = function(e){
      showNotification(paste("Error:", e$message), type = "error")
      return(FALSE)
    })
  })

  shiny::observe({
    req(input$file)

    if (nrow(rv$scale_measurements) > 0) {
      shiny::updateActionButton(session, "crop", disabled = TRUE)
    } else {
      shiny::updateActionButton(session, "crop", disabled = FALSE)
    }

    if (rv$add_status == TRUE) {
      shiny::updateActionButton(session, "saveBtn", disabled = TRUE)
    } else {
      shiny::updateActionButton(session, "saveBtn", disabled = FALSE)
    }

    alt_val <- as.numeric(input$alt)
    takeof_val <- as.numeric(input$takeof)

    calti_val <- sum(c(alt_val, takeof_val), na.rm = TRUE)
    if (is.na(alt_val) && is.na(takeof_val)) calti_val <- NA_real_

    date_str <- safe_char(input$Date)
    img_id_str <- safe_char(input$ImageID)

    id_parts <- c(date_str, img_id_str, calti_val)
    id_parts <- id_parts[!is.na(id_parts)]
    new_id_str <- if(length(id_parts) > 0) paste(id_parts, collapse = "-") else NA_character_

    rv$new_res = safe_char(input$ImageRES)
    rv$new_iw = safe_num(rv$img_width)
    rv$new_sw = safe_num(input$sw)
    rv$new_flen = safe_num(input$flen)
    rv$new_id = new_id_str
    rv$new_date = date_str
    rv$new_f_alt = alt_val
    rv$new_to_alt = takeof_val
    rv$new_calti = calti_val
    rv$new_laser_alt = safe_num(input$laser_alt)
    rv$new_drone = safe_char(input$drone)
    rv$new_objL = safe_num(input$objL)
    rv$new_imid = safe_char(input$file$name)
  })

  ############################ Save  block ############################

  create_new_entry2 <- function() {
    new_entry <- data.frame(
      Drone = rv$new_drone,
      Resolution = rv$new_res,
      ID = rv$new_id,
      Obs = safe_char(input$obs),
      Date = rv$new_date,
      Measured_Date = as.character(format(as.POSIXct(Sys.time()), "%Y-%m-%d %H:%M:%S")),
      TO_Alt = rv$new_to_alt,
      F_Alt = rv$new_f_alt,
      C_Alt = rv$new_calti,
      Laser_Alt = rv$new_laser_alt,
      OBJ_L = rv$new_objL,
      OBJ_P = if (!is.null(rv$new_objP) && length(rv$new_objP) > 0) round(as.numeric(rv$new_objP), 2) else NA_real_,
      sw = rv$new_sw,
      iw = rv$new_iw,
      flen = rv$new_flen,
      imid = rv$new_imid,
      Comments = safe_char(input$comments),
      stringsAsFactors = FALSE
    )
    return(new_entry)
  }

  save_data <- function(new_entry) {
    tryCatch({
      rv$main_data <- readxl::read_xlsx(rv$main, col_names = T) |>
        dplyr::mutate(
          dplyr::across(tidyselect::any_of(c("F_Alt", "TO_Alt", "C_Alt", "Laser_Alt", "OBJ_L",
                                             "OBJ_P", "sw", "iw", "flen")), as.numeric),
          dplyr::across(tidyselect::any_of(c("Drone", "Obs", "Resolution", "Date",
                                             "Measured_Date", "ID", "Comments", "imid")), as.character)
        )

      rv$current_data <- dplyr::bind_rows(rv$main_data, new_entry)

      writexl::write_xlsx(rv$current_data, rv$main)

      rv$add_status <- TRUE

      shiny::showModal(
        shiny::modalDialog(
          title = "Saved",
          "Scale measurements stored successfully",
          footer = shiny::modalButton("OK")
        )
      )
      return(TRUE)
    }, error = function(e) {
      showNotification(paste("Error when saving:", e$message), type = "error")
      return(FALSE)
    })
  }

  shiny::observeEvent(input$saveBtn, {
    req(rv$main_data)
    tryCatch({
      new_entry <- create_new_entry2()
      save_data(new_entry = new_entry)
      rv$click_save <- TRUE
      output$mTable <- DT::renderDataTable({
        rv$current_data
      })
      return(TRUE)
    }, error = function(e) {
      showNotification(paste("Error when saving:", e$message), type = "error")
      return(FALSE)
    })
  })

  output$add_status <- shiny::renderUI({
    req(input$file)
    if (rv$click_save == FALSE) {
      div(
        class = "alert alert-info",
        "Step 2: After completing the measurements, click on 'Add-IN button' to save"
      )
    } else {
      div(class = "alert alert-success",
          "The scale measurements have been saved!")
    }
  })

  # Clear  block
  shiny::observeEvent(input$clearBtn, {
    shiny::showModal(
      shiny::modalDialog(
        title = "Confirm Reset",
        "Are you sure you want to clear all current measurements?",
        footer = tagList(
          shiny::actionButton("confirm_reset", "Yes", class = "btn-danger"),
          shiny::modalButton("Cancel")
        )
      )
    )
  })

  shiny::observeEvent(input$confirm_reset, {
    rv$scale_measurements <- data.frame()

    rv$new_id = character()
    rv$new_imid = character()
    rv$new_objL = numeric()
    rv$new_objP = numeric()
    rv$new_date = character()
    rv$new_f_alt = numeric()
    rv$new_calti = numeric()
    rv$new_laser_alt = numeric()
    rv$new_sw = numeric()
    rv$new_iw = numeric()
    rv$new_flen = numeric()
    rv$crop_status = FALSE
    rv$add_status = TRUE
    rv$click_status = FALSE

    shiny::updateActionButton(session, "crop", disabled = FALSE)
    shiny::updateActionButton(session, "saveBtn", disabled = TRUE)
    shiny::updateTextInput(inputId = "comments", value = "")
    shiny::updateTextInput(inputId = "ImageID", value = "")
    shiny::updateNumericInput(inputId = "alt", value = 20)

    rv$plot_ranges_x = NULL
    rv$plot_ranges_y = NULL

    shiny::removeModal()
  })

  ################
  # Close button #
  ################

  shiny::observeEvent(input$closeBtn, {
    shiny::stopApp()
  })
}
