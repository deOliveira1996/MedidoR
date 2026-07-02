library(shinytest2)

test_that("{shinytest2} recording: free_mode_test", {
  app_dir <- system.file("shiny-apps", "MedidoR", package = "MedidoR")
  local_app_support(app_dir)
  app <- AppDriver$new(app_dir, name = "medidor_gui_test",
                       seed = 567, height = 911, width = 1619)

  app$click("path")
  app$wait_for_idle()
  medidor_wd <- system.file("extdata", "medidor_test", package = "MedidoR")
  app$set_inputs(wd = medidor_wd)
  app$click("confirmBtn")
  app$wait_for_idle()

  app$set_inputs(app_mode = "free", wait_ = FALSE)
  app$click("create")
  app$click("import")

  img_medidor_path <- system.file("extdata", "medidor_test", "example_whale.png", package = "MedidoR")
  if (img_medidor_path == "") {
    stop("Image 'example_whale.png' not found in dir inst/extdata/medidor_test.")
  }
  app$upload_file(file = img_medidor_path)
  app$wait_for_idle(timeout = 5000)

  app$set_inputs(main_tabs = "Image plot")
  app$wait_for_idle(500)

  app$set_inputs(
    Species = "Eubalaena australis",
    ImageID = "RW-1",
    ImageRES = "2.7k",
    alt = 22.5,
    takeof = 0.5,
    score = "1",
    sw = "6.4",
    flen = "7.6",
    Date = "2022-08-01",
    obs = "Observer 1",
    drone = "MA2",
    wait_ = FALSE
  )

  app$set_inputs(
    plot_brush = list(xmin = 759.7, xmax = 2067.0,
                      ymin = 532.0, ymax = 1117.8),
    allow_no_input_binding_ = TRUE
  )
  app$click("crop", wait_ = FALSE)

  app$click("new_free_measure")
  app$wait_for_idle(500)

  app$click("start_free_measure")
  app$wait_for_idle(500)

  app$set_inputs(free_measure_id = "TIP-ROSTRUM")
  app$click("start_free_measure")
  app$wait_for_idle(500)

  app$set_inputs(plot_click = list(x = 776.6, y = 813.4), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$set_inputs(plot_click = list(x = 994.3, y = 838.4), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$wait_for_idle(1000)

  app$expect_values()

  app$click("saveBtn")
  app$wait_for_idle(1000)

  app$click("continue_free")
  app$wait_for_idle(1000)

  app$click("start_free_measure")
  app$wait_for_idle(500)

  app$set_inputs(free_measure_id = "MID-GIRTH")
  app$click("start_free_measure")
  app$wait_for_idle(500)

  app$set_inputs(plot_click = list(x = 1247.0, y = 718.4), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$set_inputs(plot_click = list(x = 1248.3, y = 970.4), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$wait_for_idle(1000)

  app$expect_values()

  app$click("saveBtn")
  app$wait_for_idle(1000)

  app$click("finish_free")
  app$wait_for_idle(1000)

  app$set_inputs(main_tabs = "Dataframe")
  app$wait_for_idle(1000)

  app$expect_values()

  app$set_inputs(main_tabs = "Calibration")
  app$wait_for_idle(500)

  calib_data_path <- system.file("extdata", "medidor_test", "calib.xlsx", package = "MedidoR")
  app$set_inputs(calib_path = calib_data_path)
  app$click("calib")
  app$wait_for_idle(timeout = 5000)

  app$set_inputs(main_tabs = "Dataframe")
  app$wait_for_idle(1000)

  app$expect_values()
})
