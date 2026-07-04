library(shinytest2)

test_that("{shinytest2} recording: calib_gui_test", {
  app_dir <- system.file("shiny-apps", "Calib", package = "MedidoR")
  local_app_support(app_dir)
  app <- AppDriver$new(app_dir, name = "calib_gui_test",
                       seed = 123, height = 911, width = 1619)

  app$click("path")
  app$wait_for_idle()

  calib_wd <- system.file("extdata", "calib_test", package = "MedidoR")
  app$set_inputs(wd = calib_wd)
  app$click("confirmBtn")
  app$wait_for_idle()

  app$click("create")
  app$wait_for_idle()

  app$click("import")
  app$wait_for_idle()

  img_calib_path <- system.file("extdata", "calib_test", "Calib_15M_1.png", package = "MedidoR")
  if (img_calib_path == "") {
    stop("Image 'Calib_15M_1.png' not found in dir inst/extdata/calib_test.")
  }
  app$upload_file(file = img_calib_path)
  app$wait_for_idle(timeout = 5000)

  app$set_inputs(main_tabs = "Image plot")
  app$wait_for_idle()

  app$set_inputs(
    objL = "2",
    ImageID = "15m_1",
    ImageRES = "4k",
    sw = "13.2",
    flen = "8.8",
    drone = "P4P",
    alt = 14.7,
    laser_alt = 0,
    takeof = 1.5,
    Date = "2019-08-13",
    obs = "Observer 1",
    wait_ = FALSE
  )

  app$set_inputs(
    plot_brush = list(
      xmin = 1851.803847202,
      xmax = 2587.5414925509,
      ymin = 1002.9866290425,
      ymax = 1457.6559604379
    ),
    allow_no_input_binding_ = TRUE
  )

  app$click("crop", wait_ = FALSE)

  app$set_inputs(plot_click = list(x = 2054.38, y = 1206.52), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$set_inputs(plot_click = list(x = 2369.4, y = 1202.8), allow_no_input_binding_ = TRUE, priority_ = "event")

  app$click("saveBtn")
  app$wait_for_idle()

  app$expect_values()

  app$click("clearBtn")

  app$click("confirm_reset")
  app$wait_for_idle()

  app$expect_values()

  app$set_inputs(main_tabs = "Dataframe")
  app$wait_for_idle()

  app$expect_values()
})
