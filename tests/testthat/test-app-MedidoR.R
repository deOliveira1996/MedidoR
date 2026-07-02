library(shinytest2)

test_that("{shinytest2} recording: medidor_gui_test", {
  app_dir <- system.file("shiny-apps", "MedidoR", package = "MedidoR")
  local_app_support(app_dir)
  app <- AppDriver$new(app_dir, name = "medidor_gui_test",
                       seed = 321, height = 911, width = 1619)

  app$click("path")
  app$wait_for_idle()
  medidor_wd <- system.file("extdata", "medidor_test", package = "MedidoR")
  app$set_inputs(wd = medidor_wd)
  app$click("confirmBtn")
  app$wait_for_idle()

  app$set_inputs(app_mode = "morpho", wait_ = FALSE)
  app$set_inputs(segments = "1", wait_ = FALSE)
  app$click("create")
  app$click("import")

  img_medidor_path <- system.file("extdata", "medidor_test", "example_whale.png", package = "MedidoR")
  if (img_medidor_path == "") {
    stop("Image 'example_whale.png' not found in dir inst/extdata/medidor_test.")
  }
  app$upload_file(file = img_medidor_path)
  app$wait_for_idle(timeout = 3000)

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
    plot_brush = list(xmin = 748.9, xmax = 2075.1, ymin = 556.4, ymax = 1155.8),
    allow_no_input_binding_ = TRUE
  )
  app$click("crop", wait_ = FALSE)

  app$set_inputs(plot_click = list(x = 775.4, y = 810.9), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$set_inputs(plot_click = list(x = 1527.7, y = 851.1), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$set_inputs(plot_click = list(x = 1945.4, y = 831.0), allow_no_input_binding_ = TRUE, priority_ = "event")
  app$wait_for_idle(500)

  clicks <- list(
    list(x = 892.5, y = 741.3), list(x = 891.2, y = 902.0),
    list(x = 1011.6, y = 727.9), list(x = 1009.0, y = 948.8),
    list(x = 1130.8, y = 705.2), list(x = 1124.1, y = 968.9),
    list(x = 1245.9, y = 715.9), list(x = 1239.2, y = 980.9),
    list(x = 1362.4, y = 731.9), list(x = 1358.4, y = 975.6),
    list(x = 1477.5, y = 761.4), list(x = 1474.8, y = 948.8),
    list(x = 1595.3, y = 785.5), list(x = 1594.0, y = 908.7),
    list(x = 1711.8, y = 814.9), list(x = 1710.4, y = 876.5),
    list(x = 1828.2, y = 800.2), list(x = 1826.9, y = 876.5),

    list(x = 1991.5, y = 591.4), list(x = 2045.1, y = 1055.9)
  )

  for (pt in clicks) {
    app$set_inputs(plot_click = pt, allow_no_input_binding_ = TRUE, priority_ = "event", wait_ = FALSE)
  }

  app$expect_values()

  app$click("saveBtn")
  app$wait_for_idle()

  app$click("clearBtn")
  app$click("confirm_reset")

  app$set_inputs(main_tabs = "Dataframe")
  app$wait_for_idle()

  app$expect_values()

  app$set_inputs(main_tabs = "Calibration")
  app$wait_for_idle()

  calib_data_path <- system.file("extdata", "medidor_test", "calib.xlsx", package = "MedidoR")
  app$set_inputs(calib_path = calib_data_path)
  app$click("calib")
  app$wait_for_idle(timeout = 5000)

  app$expect_values()

  app$set_inputs(main_tabs = "Measured Whales")
  app$set_inputs(n_whales = 50)
  app$wait_for_idle()

  app$expect_values()
})
