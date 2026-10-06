
options(shiny.maxRequestSize = 50 * 1024^2)

# Define server
server <- function(input, output, session) {

  calib_log <- reactiveVal(data.frame(Timestamp = character(),
                                      Message = character()))

  # Reactive values ----
  rv <- shiny::reactiveValues(
    # Controle de segmentos
    segments = NULL,

    length_measurements = data.frame(Length_X = numeric(),
                                     Length_Y = numeric()),
    width_measurements = data.frame(Width_X = numeric(),
                                    Width_Y = numeric()),
    fw_measurements = data.frame(Width_X = numeric(),
                                 Width_Y = numeric()),

    main_data = NULL,
    current_data = NULL,
    main = NULL,
    secondary = NULL,
    dir_path = NULL,

    user_dir = getwd(),
    current_dir = getwd(),

    new_id = character(),
    new_score = character(),
    new_date = character(),
    new_f_alt = numeric(),
    new_to_alt = numeric(),
    new_calti = numeric(),
    new_laser_alt = numeric(),
    new_bl = numeric(),
    new_widths = numeric(),
    new_fw = numeric(),
    new_drone = character(),
    new_sw = numeric(),
    new_iw = numeric(),
    new_flen = numeric(),

    current_image = NULL,
    crop_status = FALSE,
    add_status = TRUE,
    click_save = FALSE,

    img_width = 0,
    img_height = 0,
    plot_ranges_x = NULL,
    plot_ranges_y = NULL,


    calib_path = NULL,
    calib_data = NULL,
    calib_model = NULL,
    calib_train = NULL,

    free_points = data.frame(x = numeric(), y = numeric()),
    current_free_id = character()
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

  # Assign segments dynamically
  observeEvent(c(input$segments, input$app_mode), {
    if (input$app_mode == "free") {
      rv$segments <- 3
    } else {
      rv$segments <- input$segments
    }
  })

  # Confirmation  block

  shiny::observeEvent(input$confirmBtn, {
    req(input$wd)
    setwd(input$wd)
    rv$user_dir <- input$wd
    shiny::removeModal()
  })

  # Create  block

  # Data frame management
  shiny::observeEvent(input$create, {
    tryCatch({
      req(rv$user_dir, rv$segments)

      dir_path <- MedidoR:::get_directory_path(rv$segments, rv$user_dir)
      paths <- MedidoR:::get_file_paths(dir_path, rv$segments)

      rv$main <- paths$main
      rv$secondary <- paths$secondary
      rv$dir_path <- dir_path

      if (!dir.exists(dir_path)) {
        dir.create(dir_path)

        if (rv$segments == 3) {
          MedidoR:::create_data_free(path = rv$main, path2 = rv$secondary)
          modal_msg <- "Free measurements dataframe created"
        } else {
          MedidoR:::create_data(
            segments = rv$segments,
            path = rv$main,
            path2 = rv$secondary
          )
          modal_msg <- paste(
            ifelse(rv$segments == 1, "10%", "5%"),
            "interval dataframe created"
          )
        }
        # -------------------------------------

        shiny::showModal(shiny::modalDialog(
          title = "Success",
          modal_msg,
          footer = shiny::modalButton("OK")
        ))

        rv$current_dir <- dir_path

        rv$main_data <- readxl::read_xlsx(path = rv$main, col_names = T)

        output$mTable <- DT::renderDataTable({
          MedidoR:::update_data_table(rv$secondary)
        })

      } else {
        shiny::showModal(
          shiny::modalDialog(
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
   tryCatch({
     req(rv$user_dir, rv$segments)
     dir_path <- MedidoR:::get_directory_path(rv$segments, rv$user_dir)
     paths <- MedidoR:::get_file_paths(dir_path, rv$segments)

     rv$main <- paths$main
     rv$secondary <- paths$secondary
     rv$dir_path <- dir_path

     if (file.exists(rv$secondary)) {
       rv$main_data <- readxl::read_xlsx(rv$main)

       shiny::showModal(
         shiny::modalDialog(
           title = "Success",
           "Dataframe imported",
           footer = shiny::modalButton("OK")
         )
       )

       output$mTable <- DT::renderDataTable({
         MedidoR:::update_data_table(rv$secondary)
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

  shiny::observeEvent(input$score, {
    req(input$file)
    if (input$score == 1) {
      rv$new_score <- "Good"
    }
    if (input$score == 2) {
      rv$new_score <- "Moderate"
    }
    if (input$score == 3) {
      rv$new_score <- "Bad"
    }
    if (input$score == 4) {
      rv$new_score <- "Not assigned"
    }
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

  # Crop button logic
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

  # UI feedback for crop state
  output$crop_status <- shiny::renderUI({
    req(input$file)
    if (!rv$crop_status == TRUE) {
      div(
        class = "alert alert-info",
        "Step 1: Select the area of interest on the image using the selection tool and click 'Crop'"
      )
    } else {
      div(class = "alert alert-success",
          "Area selected!")
    }
  })

  ############################ Image plot  block ############################

  # Measurement line drawer functions

  process_measurements <- function() {
    coords <- rv$width_measurements

    # Garantir que há um número par de pontos
    if (nrow(coords) %% 2 != 0) {
      showNotification("Odd number of stitches for widths!", type = "error")
      return()
    }

    pairs <- data.frame(
      x1 = coords$Width_X[seq(1, nrow(coords) - 1, 2)],
      y1 = coords$Width_Y[seq(1, nrow(coords) - 1, 2)],
      x2 = coords$Width_X[seq(2, nrow(coords), 2)],
      y2 = coords$Width_Y[seq(2, nrow(coords), 2)]
    )

    widths <- sqrt((pairs$x2 - pairs$x1)^2 + (pairs$y2 - pairs$y1)^2)
    rv$new_widths <- widths[1:(length(widths))]
    rv$new_fw <- as.numeric(sqrt((rv$fw_measurements$Width_X[2] - rv$fw_measurements$Width_X[1])^2 + (rv$fw_measurements$Width_Y[2] - rv$fw_measurements$Width_Y[1])^2))
    rv$new_id = input$ImageID
    rv$new_date = input$Date
    rv$new_f_alt = input$alt
    rv$new_to_alt = input$takeof
    rv$new_calti = input$alt + input$takeof
    rv$new_laser_alt = input$laser_alt
    rv$new_bl = sum(sqrt(
      diff(rv$length_measurements$Length_X)^2 +
        diff(rv$length_measurements$Length_Y)^2
    ))
  }

  #  Length measurements
  draw_measurement_lines <- function() {
    req(rv$current_image, rv$length_measurements, rv$segments)

    lp <- rv$length_measurements
    if (nrow(lp) < 3)
      return()

    start <- data.frame(x = lp$Length_X[1], y = lp$Length_Y[1])
    mid <- data.frame(x = lp$Length_X[2], y = lp$Length_Y[2])
    end <- data.frame(x = lp$Length_X[3], y = lp$Length_Y[3])

    # Main lines
    graphics::segments(start$x,
                       start$y,
                       mid$x,
                       mid$y,
                       col = "red",
                       lwd = 1.5)

    graphics::segments(mid$x,
                       mid$y,
                       end$x,
                       end$y,
                       col = "red",
                       lwd = 1.5)

    # Vectorial calculations
    original_dx <- end$x - start$x
    original_dy <- end$y - start$y
    perpendicular <- c(-original_dy, original_dx) / sqrt(original_dx^2 + original_dy^2)

    # Interval parameters
    intervals <- ifelse(rv$segments == 1, 9, 19)

    total_length <- sum(sqrt(diff(lp$Length_X)^2 + diff(lp$Length_Y)^2))

    for (i in 1:intervals) {
      fraction <- i / (intervals + 1)

      # Main line point
      original_x <- start$x + original_dx * fraction
      original_y <- start$y + original_dy * fraction

      # Central point convert
      center <- data.frame(x = original_x, y = original_y)

      # Calcs perpendicular summ
      line_length <- total_length * 2
      offset_x <- perpendicular[1] * line_length / 2
      offset_y <- perpendicular[2] * line_length / 2

      # Draw perpendicular lines
      graphics::segments(
        center$x - offset_x,
        center$y - offset_y,
        center$x + offset_x,
        center$y + offset_y,
        col = "blue",
        lty = "dashed"
      )
    }
  }

  # Width measurements
  handle_width_measurement <- function(x, y) {
    target <- ifelse(rv$segments == 1, 18, 38)

    if (nrow(rv$width_measurements) < target) {
      rv$width_measurements <- rbind(rv$width_measurements,
                                     data.frame(Width_X = x, Width_Y = y))
    }

    if (nrow(rv$width_measurements) == target) {
      MedidoR:::show_measurement_modal("Width measurements completed. Take Fluke width.")
    }
  }

  # Fluke measurements
  handle_fluke_measurements <- function(x, y) {
    if (nrow(rv$fw_measurements) < 2) {
      rv$fw_measurements <- rbind(rv$fw_measurements,
                                  data.frame(Width_X = x, Width_Y = y))
    }

    if (nrow(rv$fw_measurements) == 2) {
      MedidoR:::show_measurement_modal("Measurements complete")
      process_measurements()
    }
  }

  # --- Free Measurement Logic ---
  shiny::observeEvent(input$new_free_measure, {
    shiny::showModal(shiny::modalDialog(
      title = "New Free Measurement",
      shiny::textInput("free_measure_id", "Enter Measurement Name/ID (e.g., Pectoral_Fin):"),
      footer = shiny::tagList(
        shiny::actionButton("start_free_measure", "Confirm", class = "btn-primary"),
        shiny::modalButton("Cancel")
      )
    ))
  })

  shiny::observeEvent(input$start_free_measure, {
    req(input$free_measure_id)
    rv$current_free_id <- input$free_measure_id
    rv$free_points <- data.frame(x = numeric(), y = numeric())
    shiny::removeModal()
  })

  # Rendering plot
  output$imagePlot <- shiny::renderPlot({
    req(rv$current_image, rv$segments)

    if (rv$crop_status == TRUE) {
      plot(
        rv$current_image,
        xlim = rv$plot_ranges_x,
        ylim = rv$plot_ranges_y,
        main = input$file$name,
        axes = T
      )

      if (nrow(rv$length_measurements) > 0) {
        points_df <- rv$length_measurements |>
          dplyr::mutate(
            x_plot = rv$length_measurements$Length_X,
            y_plot = rv$length_measurements$Length_Y
          )
        graphics::points(points_df$x_plot,
                         points_df$y_plot,
                         col = "red",
                         cex = 1.5)
      }

      if (nrow(rv$width_measurements) > 0) {
        points_df <- rv$width_measurements |>
          dplyr::mutate(
            x_plot = rv$width_measurements$Width_X,
            y_plot = rv$width_measurements$Width_Y
          )
        graphics::points(
          points_df$x_plot,
          points_df$y_plot,
          col = "yellow",
          pch = 4,
          cex = 2
        )
      }

      if (nrow(rv$fw_measurements) > 0) {
        points_df <- rv$fw_measurements |>
          dplyr::mutate(
            x_plot = rv$fw_measurements$Width_X,
            y_plot = rv$fw_measurements$Width_Y
          )

        graphics::points(
          points_df$x_plot,
          points_df$y_plot,
          col = "purple3",
          pch = 4,
          cex = 2
        )

        graphics::segments(
          rv$fw_measurements$Width_X[1],
          rv$fw_measurements$Width_Y[1],
          rv$fw_measurements$Width_X[2],
          rv$fw_measurements$Width_Y[2],
          col = "purple",
          lwd = 1.5
        )
      }

      if (nrow(rv$length_measurements) == 3) {
        draw_measurement_lines()
      }
    } else {
      plot(rv$current_image, main = "Select area of interest", axes = T)
    }

    if (input$app_mode == "free" && nrow(rv$free_points) > 0) {
      graphics::points(rv$free_points$x, rv$free_points$y, col = "cyan", pch = 16, cex = 1.5)
      if (nrow(rv$free_points) > 1) {
        graphics::lines(rv$free_points$x, rv$free_points$y, col = "cyan", lwd = 2)
      }
    }
  })

  ############################ Plot click  block ############################
  # Measurement handling ----
  shiny::observeEvent(input$plot_click, {
    req(input$crop, rv$crop_status)

    if (input$app_mode == "free") {
      if (length(rv$current_free_id) > 0 && rv$current_free_id != "") {
        rv$free_points <- rbind(rv$free_points, data.frame(x = input$plot_click$x, y = input$plot_click$y))

        if (nrow(rv$free_points) > 1) {
          distances <- sqrt(diff(rv$free_points$x)^2 + diff(rv$free_points$y)^2)
          rv$new_bl <- sum(distances) # Armazena o somatório dos pixels
          rv$add_status <- FALSE      # Libera o botão ADD-IN

          shiny::showNotification(
            sprintf("Points: %d | Total Length: %.2f pixels", nrow(rv$free_points), rv$new_bl),
            type = "message",
            duration = 2
          )
        }
      } else {
        shiny::showNotification("Please click 'New Measurement' first to assign an ID.", type = "warning")
      }
    } else {
      if (nrow(rv$length_measurements) != 3) {
        rv$length_measurements <- rbind(
          rv$length_measurements,
          data.frame(
            Length_X = input$plot_click$x,
            Length_Y = input$plot_click$y
          )
        )
        if (nrow(rv$length_measurements) == 3) {
          MedidoR:::show_measurement_modal("Length measurements completed. Take widths.")
          shiny::showModal(
            shiny::modalDialog(
              title = "Measurement Progress",
              HTML(
                "<b>Length measurement complete!</b><br>
               Click along the perpendicular lines to measure widths."
              ),
              footer = shiny::modalButton("Continue"),
              easyClose = TRUE
            )
          )
        }
      } else {
        target <- ifelse(rv$segments == 1, 18, 38)
        if (nrow(rv$width_measurements) < target) {
          handle_width_measurement(input$plot_click$x, input$plot_click$y)
        } else {
          handle_fluke_measurements(input$plot_click$x, input$plot_click$y)
          rv$add_status <- FALSE
        }
      }
    }
  })

  shiny::observe({
    req(input$file)

    if (nrow(rv$length_measurements) > 0) {
      shiny::updateActionButton(session, "crop", disabled = TRUE)
    } else {
      shiny::updateActionButton(session, "crop", disabled = FALSE)
    }

    if (rv$add_status == TRUE) {
      shiny::updateActionButton(session, "saveBtn", disabled = TRUE)
    } else {
      shiny::updateActionButton(session, "saveBtn", disabled = FALSE)
    }

    rv$new_res = as.character(input$ImageRES)
    rv$new_iw = as.numeric(rv$img_width)
    rv$new_sw = as.numeric(input$sw)
    rv$new_flen = as.numeric(input$flen)
    rv$new_id = paste(as.character(input$Date),
                      as.character(input$ImageID),
                      c(as.numeric(input$alt) + as.numeric(input$takeof)),
                      sep = "-")
    rv$new_date = as.character(input$Date)
    rv$new_f_alt = as.numeric(input$alt)
    rv$new_to_alt = as.numeric(input$takeof)
    rv$new_calti = as.numeric(input$alt) + as.numeric(input$takeof)
    rv$new_laser_alt = as.numeric(input$laser_alt)
    rv$new_id = as.character(input$ImageID)
    rv$new_drone = as.character(input$drone)
    rv$new_objL = as.numeric(input$objL)
    rv$new_imid = as.character(input$file$name)
  })

  ############################ Save  block ############################

  # Create New Entry function
  create_new_entry <- function(segments) {
    req(input$saveBtn)

    safe_char <- function(x) { if (is.null(x) || length(x) == 0 || x == "") NA_character_ else as.character(x) }
    safe_num <- function(x) { if (is.null(x) || length(x) == 0 || is.na(x) || x == "") NA_real_ else as.numeric(x) }

    base_df <- data.frame(
      Drone = safe_char(input$drone),
      Resolution = safe_char(input$ImageRES),
      ID = safe_char(rv$new_id),
      Obs = safe_char(input$obs),
      Species = safe_char(input$Species),
      Date = safe_char(rv$new_date),
      Measured_Date = format(as.POSIXct(Sys.time()), "%Y-%m-%d %H:%M:%S"),
      TO_Alt = safe_num(rv$new_to_alt),
      F_Alt = safe_num(rv$new_f_alt),
      C_Alt = safe_num(rv$new_calti),
      Laser_Alt = safe_num(rv$new_laser_alt),
      Frame_Score = safe_char(rv$new_score),
      sw = safe_num(rv$new_sw),
      iw = safe_num(rv$new_iw),
      flen = safe_num(rv$new_flen),
      imid = safe_char(rv$new_imid),
      cGSD = NA_real_,
      EstLength = NA_real_,
      Comments = safe_char(input$comments),
      BL = safe_num(rv$new_bl),
      stringsAsFactors = FALSE
    )

    # Width columns
    if (segments == 1) {
      widths <- setNames(as.list(rv$new_widths[1:9]),
                         paste0("WD_", seq(10, 90, by = 10)))
    } else {
      widths <- setNames(
        as.list(rv$new_widths[1:19]),
        paste0("WD_", sprintf("%02d", seq(5, 95, by = 5)))
      )
    }

    widths <- lapply(widths, as.numeric)

    # Add Fluke Width (WD_F)
    widths$WD_F <- rv$new_fw

    # Combine all columns
    new_entry <- cbind(base_df, as.data.frame(widths))

    return(new_entry)
  }

  # Save data function
  save_data <- function(new_entry) {
    tryCatch({

      rv$main_data <- readxl::read_xlsx(rv$main, col_names = T) |>
        dplyr::mutate(
          dplyr::across(c(F_Alt, TO_Alt, C_Alt, Laser_Alt, sw, iw, flen,
                          BL, starts_with("WD_"),
                          cGSD, EstLength), as.numeric),
          dplyr::across(c(Drone, Obs, Species, Date, Measured_Date, ID,
                          Frame_Score, Comments, Resolution, imid), as.character)
        )

      rv$current_data <- dplyr::bind_rows(rv$main_data, new_entry)

      writexl::write_xlsx(rv$current_data, rv$main)

      filtered_data <- MedidoR::dtfilter(rv$current_data)

      writexl::write_xlsx(x = filtered_data, path = rv$secondary)

      rv$add_status <- TRUE

      shiny::showModal(
        modalDialog(
          title = "Saved",
          "Measurements stored successfully",
          footer = modalButton("OK")
        )
      )
      return(TRUE)
    }, error = function(e) {
      showNotification(paste("Error when saving:", e$message), type = "error")
      return(FALSE)
    })
  }

  # ==========================================
  # Save system ----
  # ==========================================

  is_empty <- function(x) {
    is.null(x) || length(x) == 0 || is.na(x) || trimws(as.character(x)) == ""
  }

  execute_save <- function() {
    tryCatch({
      req(rv$main_data)

      if (input$app_mode == "free") {
        req(rv$new_bl, rv$current_free_id)

        safe_char <- function(x) { if (is_empty(x)) NA_character_ else as.character(x) }
        safe_num <- function(x) { if (is_empty(x)) NA_real_ else as.numeric(x) }

        new_entry <- data.frame(
          Drone = safe_char(input$drone), Resolution = safe_char(input$ImageRES),
          ID = safe_char(rv$new_id), Obs = safe_char(input$obs),
          Species = safe_char(input$Species), Date = safe_char(rv$new_date),
          Measured_Date = format(as.POSIXct(Sys.time()), "%Y-%m-%d %H:%M:%S"),
          TO_Alt = safe_num(rv$new_to_alt), F_Alt = safe_num(rv$new_f_alt),
          C_Alt = safe_num(rv$new_calti), Laser_Alt = safe_num(rv$new_laser_alt),
          Frame_Score = safe_char(rv$new_score),
          sw = safe_num(rv$new_sw), iw = safe_num(rv$new_iw),
          flen = safe_num(rv$new_flen), imid = safe_char(rv$new_imid),
          Segments = safe_char(rv$current_free_id), Pixel = safe_num(rv$new_bl),
          cGSD = NA_real_, EstLength = NA_real_, Comments = safe_char(input$comments),
          stringsAsFactors = FALSE
        )

        rv$main_data <- readxl::read_xlsx(rv$main, col_names = TRUE) |>
          dplyr::mutate(
            dplyr::across(c(TO_Alt, F_Alt, C_Alt, Laser_Alt, sw, iw, flen, Pixel,
                            cGSD, EstLength), as.numeric),
            dplyr::across(c(Drone, Resolution, ID, Obs, Species, Date, Measured_Date,
                            Frame_Score, imid, Segments, Comments), as.character)
          )

        rv$current_data <- dplyr::bind_rows(rv$main_data, new_entry)
        writexl::write_xlsx(rv$current_data, rv$main)
        writexl::write_xlsx(rv$current_data, rv$secondary) # Estrutura plana

        rv$main_data <- rv$current_data

        shiny::showModal(shiny::modalDialog(
          title = "Measurement Saved",
          "Would you like to continue collecting free measurements on this image or finish?",
          footer = shiny::tagList(
            shiny::actionButton("continue_free", "Continue"),
            shiny::actionButton("finish_free", "Finish")
          ),
          easyClose = FALSE
        ))

      } else {
        # Rotina para Morphometrics
        new_entry <- create_new_entry(rv$segments)
        save_data(new_entry = new_entry)
        rv$click_save <- TRUE
      }

      output$mTable <- DT::renderDataTable({ MedidoR:::update_data_table(rv$secondary) })
      return(TRUE)

    }, error = function(e) {
      shiny::showNotification(paste("Error when saving:", e$message), type = "error")
      return(FALSE)
    })
  }

  shiny::observeEvent(input$saveBtn, {

    missing_fields <- c()
    if (is_empty(input$Species)) missing_fields <- c(missing_fields, "Species name")
    if (is_empty(input$ImageID)) missing_fields <- c(missing_fields, "Image-ID")
    if (is_empty(input$ImageRES)) missing_fields <- c(missing_fields, "Image Resolution")
    if (is_empty(input$alt)) missing_fields <- c(missing_fields, "Flight Altitude")
    if (is_empty(input$laser_alt)) missing_fields <- c(missing_fields, "Laser Altitude")
    if (is_empty(input$Date)) missing_fields <- c(missing_fields, "Date")
    if (is_empty(input$obs)) missing_fields <- c(missing_fields, "Observer")
    if (is_empty(input$sw)) missing_fields <- c(missing_fields, "Sensor width (sw)")
    if (is_empty(input$flen)) missing_fields <- c(missing_fields, "Focal length (flen)")
    if (is_empty(input$drone)) missing_fields <- c(missing_fields, "Drone model")

    if (length(missing_fields) > 0) {
      shiny::showModal(shiny::modalDialog(
        title = "Missing Information",
        shiny::HTML(
          paste0(
            "<p>The following fields are empty:</p><ul>",
            paste0("<li><b>", missing_fields, "</b></li>", collapse = ""),
            "</ul><p>Do you want to proceed and save anyway? Empty variables will be saved as NA.</p>"
          )
        ),
        footer = shiny::tagList(
          shiny::actionButton("force_save", "Proceed Anyway", class = "btn-warning"),
          shiny::modalButton("Cancel")
        ),
        easyClose = TRUE
      ))
    } else {
      execute_save()
    }
  })

  shiny::observeEvent(input$force_save, {
    shiny::removeModal()
    execute_save()
  })

  shiny::observeEvent(input$continue_free, {
    rv$free_points <- data.frame(x = numeric(), y = numeric())
    rv$add_status <- TRUE
    shiny::removeModal()

    # Aciona a janela de nova medida imediatamente
    shiny::showModal(shiny::modalDialog(
      title = "New Free Measurement",
      shiny::textInput("free_measure_id", "Enter Measurement Name/ID:"),
      footer = shiny::tagList(
        shiny::actionButton("start_free_measure", "Confirm", class = "btn-primary"),
        shiny::modalButton("Cancel")
      )
    ))
  })

  shiny::observeEvent(input$finish_free, {
    rv$free_points <- data.frame(x = numeric(), y = numeric())
    rv$current_free_id <- character()
    rv$add_status <- TRUE
    shiny::removeModal()
  })

  # UI feedback for add state
  output$add_status <- shiny::renderUI({
    req(input$file)
    if (rv$click_save == FALSE) {
      div(
        class = "alert alert-info",
        "Step 2: After completing the measurements, click on 'Add-IN button' to save"
      )
    } else {
      div(class = "alert alert-success",
          "The measurements have been saved!")
    }
  })

  # Clear  block

  # Measurement Reset Warning
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
    rv$length_measurements <- data.frame()
    rv$width_measurements <- data.frame()
    rv$fw_measurements <- data.frame()
    # Novos dados
    rv$new_id = character()
    rv$new_imid = character()
    rv$new_score = character()
    rv$new_date = character()
    rv$new_f_alt = numeric()
    rv$new_calti = numeric()
    rv$new_laser_alt = numeric()
    rv$new_bl = numeric()
    rv$new_widths = numeric()
    rv$new_fw = numeric()
    rv$crop_status = FALSE
    rv$add_status = TRUE
    rv$click_status = FALSE
    shiny::updateActionButton(session, "crop", disabled = FALSE)
    shiny::updateActionButton(session, "saveBtn", disabled = TRUE)
    shiny::updateTextInput(inputId = "comments", value = "")
    shiny::updateTextInput(inputId = "ImageId", value = "")
    shiny::updateRadioButtons(inputId = "score", selected = 4)
    shiny::updateNumericInput(inputId = "alt", value = 20)
    shiny::updateNumericInput(inputId = "laser_alt", value = 0)
    rv$plot_ranges_x = NULL
    rv$plot_ranges_y = NULL

    shiny::removeModal()
  })

  #################################### Calibration  block ####################################

  # Re factored Calibration Handler
  shiny::observeEvent(input$calib, {
    req(input$calib_path, rv$main, rv$secondary)

    if (input$alt_data == 1) {
      tryCatch({
        rv$calib_path <- input$calib_path

        rv$calib_data <- MedidoR:::calib(rv$calib_path) |>
          stats::na.omit()

        rv$calib_train <- caret::train(
          as.numeric(eGSD) ~ as.numeric(C_Alt),
          data = rv$calib_data,
          method = "lm",
          trControl = caret::trainControl(method = "repeatedcv",
                                          number = 10,
                                          repeats = 5)
        )

        rv$calib_model <- stats::lm(formula = as.numeric(eGSD) ~ as.numeric(C_Alt),
                                    data = rv$calib_data)

        rv$calib_data$cGSD <- stats::predict(rv$calib_model, rv$calib_data)
        rv$calib_data$LcGSD <- rv$calib_data$cGSD * rv$calib_data$OBJ_P

        if (input$app_mode == "free") {

          df_free <- readxl::read_xlsx(rv$main)

          df_free$C_Alt <- as.numeric(df_free$C_Alt)
          df_free$Pixel <- as.numeric(df_free$Pixel)

          df_free$cGSD <- stats::predict(rv$calib_model,
                                         newdata = data.frame(C_Alt = df_free$C_Alt))

          df_free$EstLength <- df_free$cGSD * df_free$Pixel

          writexl::write_xlsx(df_free, rv$main)
          writexl::write_xlsx(df_free, rv$secondary)

          rv$main_data <- df_free
          updated <- TRUE

        }

        else {
          updated <- MedidoR:::update_measurements(
            main_path = rv$main,
            secondary_path = rv$secondary,
            model = rv$calib_model,
            calib_data = rv$calib_data,
            current_data = NULL
          )
        }

        # -------------------------------------------------------------

        if (!is.null(updated)) {
          output$mTable <- DT::renderDataTable({
            MedidoR:::update_data_table(rv$secondary)
          })
          shiny::showNotification("Calibration applied successfully", type = "message")
        }

      }, error = function(e) {
        shiny::showNotification(paste("Calibration failed:", e$message), type = "error")
      })
    }

    if (input$alt_data == 0) {
      tryCatch({
        rv$calib_path <- input$calib_path

        rv$calib_data <- MedidoR:::calib(rv$calib_path) |>
          stats::na.omit()

        rv$calib_train <- caret::train(
          as.numeric(eGSD) ~ as.numeric(Laser_Alt),
          data = rv$calib_data,
          method = "lm",
          trControl = caret::trainControl(method = "repeatedcv",
                                          number = 10,
                                          repeats = 5)
        )

        rv$calib_model <- stats::lm(formula = as.numeric(eGSD) ~ as.numeric(Laser_Alt),
                                    data = rv$calib_data)

        rv$calib_data$cGSD <- stats::predict(rv$calib_model, rv$calib_data)
        rv$calib_data$LcGSD <- rv$calib_data$cGSD * rv$calib_data$Pixel

        if (input$app_mode == "free") {

          df_free <- readxl::read_xlsx(rv$main)

          df_free$C_Alt <- as.numeric(df_free$C_Alt)
          df_free$Laser_Alt <- as.numeric(df_free$Laser_Alt)
          df_free$Pixel <- as.numeric(df_free$Pixel)

          df_free$cGSD <- stats::predict(rv$calib_model, newdata = data.frame(Laser_Alt = df_free$Laser_Alt))

          df_free$EstLength <- df_free$cGSD * df_free$Pixel

          df_free <- df_free |>
            dplyr::mutate(
              dplyr::across(
                c(Pixel, C_Alt, TO_Alt, F_Alt, Laser_Alt, sw, iw, flen, EstLength),
                \(x) round(as.numeric(x), digits = 2)
              )
            )

          writexl::write_xlsx(df_free, rv$main)
          writexl::write_xlsx(df_free, rv$secondary)

          rv$main_data <- df_free
          updated <- TRUE

        } else {
          updated <- MedidoR:::update_measurements(
            main_path = rv$main,
            secondary_path = rv$secondary,
            model = rv$calib_model,
            calib_data = rv$calib_data,
            current_data = NULL
          )
        }
        # -------------------------------------------------------------

        if (!is.null(updated)) {
          output$mTable <- DT::renderDataTable({
            MedidoR:::update_data_table(rv$secondary)
          })
          shiny::showNotification("Calibration applied successfully", type = "message")
        }

      }, error = function(e) {
        shiny::showNotification(paste("Calibration failed:", e$message), type = "error")
      })
    }


    if (input$save_plot == "Y") {
      plot_dir <- file.path(rv$user_dir, "Model-Plots")
      if (!dir.exists(plot_dir)) {
        dir.create(plot_dir)
      }
    }
  })

  #################################### Model Plot Block ####################################

  output$checkm <- shiny::renderPlot({
    req(input$calib, rv$calib_model)

    tryCatch({
      old_par <- par(no.readonly = TRUE)
      on.exit(par(old_par))
      par(mfrow = c(2, 2))

      plot(rv$calib_model)

      if (input$save_plot == "Y") {
        png(file.path(rv$user_dir,"Model-Plots", "Diagnostic_plot.png"),
            width = 10, height = 6, units = "in", res = 300)
        par(mfrow = c(2, 2))
        plot(rv$calib_model)
        dev.off()
      }

    }, error = function(e) {
      showNotification(paste("Erro ao gerar gráficos de diagnóstico:", e$message),
                       type = "error")
      return(NULL)
    })
  })

  output$variance <- shiny::renderPlot({
    req(input$calib, rv$calib_data, rv$calib_train)

    tryCatch({
      if (!"C_Alt" %in% names(rv$calib_data) || !"LcGSD" %in% names(rv$calib_data) || !"ObjLength" %in% names(rv$calib_data)) {
        stop("Calibration data does not contain required columns")
      }

      p <- ggplot2::ggplot(
        as.data.frame(rv$calib_data),
        ggplot2::aes(x = as.factor(round(C_Alt, 0)), y = LcGSD)
      ) +
        ggplot2::stat_summary(
          fun.data = "mean_sdl",
          fun.args = list(mult = 1),
          geom = "errorbar",
          color = "black",
          width = 0.1
        ) +
        ggplot2::stat_summary(
          fun = mean,
          geom = "point",
          color = "black"
        ) +
        ggplot2::theme_classic(base_family = "serif", base_size = 14) +
        ggplot2::labs(x = "Altitude (m)", y = "Measurements (meters)") +
        ggplot2::ggtitle(
          "Mean and RMSE values estimated",
          subtitle = sprintf(
            "RMSE = %.3f, R² = %.3f, MAE = %.3f",
            rv$calib_train$results$RMSE,
            rv$calib_train$results$Rsquared,
            rv$calib_train$results$MAE
          )
        ) +
        ggplot2::geom_hline(
          ggplot2::aes(yintercept = unique(ObjLength) / 100,
                       linetype = paste("Object length:", round(unique(ObjLength)/100, 2), "m")),
          colour = 'blue',
          linewidth = 1
        ) +
        ggplot2::geom_hline(
          ggplot2::aes(yintercept = mean(LcGSD),
                       linetype = paste("Mean estimated length:", round(mean(LcGSD), 2), "m")),
          colour = 'red',
          linewidth = 1
        ) +
        ggplot2::scale_linetype_manual(
          name = "Reference Lines",
          values = c(1, 1),
          guide = ggplot2::guide_legend(
            override.aes = list(
              colour = c("red", "blue"),
              linewidth = 1
            )
          )
        ) +
        ggplot2::theme(
          legend.position = "bottom",
          legend.box = "horizontal",
          legend.title = ggplot2::element_text(face = "bold")
        )

      if (input$save_plot == "Y") {
        ggplot2::ggsave(filename = "Variance_plot.png",
                        plot = p,
                        path = file.path(rv$user_dir, "Model-Plots"),
                        width = 10,
                        height = 6)
      }

      print(p)

    }, error = function(e) {
      showNotification(paste("Error generating variance graph:", e$message), type = "error")
      return(NULL)
    })
  })

  output$mplot <- shiny::renderPlot({
    req(input$calib, rv$calib_data)

    tryCatch({
      if (!"C_Alt" %in% names(rv$calib_data) || !"eGSD" %in% names(rv$calib_data)) {
        stop("Dados de calibração não contêm colunas necessárias")
      }

      p <- ggplot2::ggplot(
        as.data.frame(rv$calib_data),
        ggplot2::aes(x = as.numeric(C_Alt), y = eGSD)
      ) +
        ggplot2::geom_point() +
        ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = TRUE) +
        ggplot2::theme_classic() +
        ggplot2::labs(x = "Altitude (m)", y = "eGSD")

      # Salvar o gráfico se necessário
      if (input$save_plot == "Y") {
        ggplot2::ggsave(filename = "Regression_plot.png",
                        plot = p,
                        path = file.path(rv$user_dir, "Model-Plots"),
                        width = 10,
                        height = 6)
      }

      print(p)

    }, error = function(e) {
      showNotification(paste("Error generating regression graph:", e$message), type = "error")
      return(NULL)
    })
  })

  shiny::observeEvent(input$n_whales, {
    req(rv$segments, rv$user_dir)

    if (input$n_whales != 0) {
      tryCatch({
        file_name <- ifelse(rv$segments == 1,
                            "Measurements_10_1.xlsx",
                            "Measurements_05_1.xlsx")
        file_path <- file.path(rv$dir_path, file_name)

        if (!file.exists(file_path)) {
          stop("Measurement file not found")
        }

        measurements <- readxl::read_excel(path = file_path,
                                           col_names = TRUE) |>
          dplyr::mutate(
            Date_mmd = format(as.Date(Date), "%m-%d"),
            ID_combined = paste(ID, " (", Date_mmd, ") ",
                                format(lubridate::as_datetime(Measured_Date), "%H:%M:%S"), sep = "")
          )

        if (!"ID" %in% names(measurements) || !"Date" %in% names(measurements)) {
          stop("Columns 'ID' or 'Date' not found in data")
        }

        unique_ids <- unique(measurements$ID_combined)

        if (length(unique_ids) == 0) {
          stop("No data available for display")
        }

        selected_ids <- unique_ids[1:min(input$n_whales, length(unique_ids))]
        filtered_data <- measurements[measurements$ID_combined %in% selected_ids, ]

        output$lplot <- shiny::renderPlot({
          ggplot2::ggplot(filtered_data,
                          ggplot2::aes(x = Segments, y = Pixel, fill = ID_combined)) +
            ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8),
                              show.legend = TRUE) +
            ggplot2::theme_classic() +
            ggplot2::labs(title = "Pixel Measurements per Segment",
                          x = "Segments", y = "Pixels",
                          fill = "ID (Date)") +
            ggplot2::scale_fill_viridis_d() +
            ggplot2::theme(legend.position = "bottom")
        })

        output$mwhale <- shiny::renderPlot({
          ggplot2::ggplot(filtered_data,
                          ggplot2::aes(x = Segments, y = EstLength, fill = ID_combined)) +
            ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8),
                              show.legend = TRUE) +
            ggplot2::theme_classic() +
            ggplot2::labs(title = "Estimated Lengths (meters)",
                          x = "Segments", y = "Length (m)",
                          fill = "ID (Date)") +
            ggplot2::scale_fill_viridis_d() +
            ggplot2::theme(legend.position = "bottom")
        })

      }, error = function(e) {
        showNotification(paste("Error generating graphs:", e$message),
                         type = "error")
      })
    }
  })

  shiny::observeEvent(input$undo, {
    tryCatch({

      if (input$app_mode == "free") {

        if (nrow(rv$free_points) > 0) {
          rv$free_points <- rv$free_points[-nrow(rv$free_points), , drop = FALSE]

          if (nrow(rv$free_points) > 1) {
            distances <- sqrt(diff(rv$free_points$x)^2 + diff(rv$free_points$y)^2)
            rv$new_bl <- sum(distances)
            rv$add_status <- FALSE

            shiny::showNotification(
              sprintf("Point removed. Points: %d | Total Length: %.2f pixels", nrow(rv$free_points), rv$new_bl),
              type = "message", duration = 2
            )
          } else {
            rv$new_bl <- numeric(0)
            rv$add_status <- TRUE
          }
        }

      } else {

        if (nrow(rv$length_measurements) > 0 & nrow(rv$width_measurements) == 0) {
          rv$length_measurements <- rv$length_measurements[-nrow(rv$length_measurements), , drop = FALSE]
        }

        if (nrow(rv$width_measurements) > 0 & nrow(rv$fw_measurements) == 0) {
          rv$width_measurements <- rv$width_measurements[-nrow(rv$width_measurements), , drop = FALSE]
        }

        if (nrow(rv$fw_measurements) > 0 & nrow(rv$fw_measurements) < 2) {
          rv$fw_measurements <- rv$fw_measurements[-nrow(rv$fw_measurements), , drop = FALSE]
        }
      }

      return(TRUE)

    }, error = function(e) {
      shiny::showNotification(paste("Error:", e$message), type = "error")
      return(FALSE)
    })
  })

  ################
  # Close button #
  ################

  shiny::observeEvent(input$closeBtn, {
    shiny::stopApp()
  })
}
