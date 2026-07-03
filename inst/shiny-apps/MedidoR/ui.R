# Define the UI

ui <- shiny::fluidPage(
  htmltools::includeCSS("photogrammetry.css"),
  shiny::titlePanel("MedidoR"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::wellPanel(
        shiny::fluidRow(shiny::strong("Input Data")),
        width = 2,
        shiny::actionButton("path",
                            "Change working directory",
                            width = "100%"),
        shiny::fileInput(
          "file",
          "Select an image file",
          accept = c(".png", ".jpeg", ".jpg",
                     ".bmp", ".gif", ".tiff")
        ),
        shiny::radioButtons(
          "app_mode",
          "Select Measurement Mode:",
          choices = list("Morphometrics" = "morpho", "Free Measurements" = "free"),
          selected = "morpho"
        ),
        shiny::conditionalPanel(
          condition = "input.app_mode == 'morpho'",
          shiny::radioButtons(
            "segments",
            "Select the desired width interval to CREATE or IMPORT the dataset:",
            choices = list("10% interval" = 1, "05% interval" = 2),
            selected = 2
          )
        ),
        shiny::fluidRow(
          column(width = 6,
                 actionButton("create",
                              "CREATE",
                              width = "100%")),
          column(width = 6,
                 actionButton("import",
                              "IMPORT",
                              width = "100%")),
          shiny::helpText("The", strong("CREATE"), "button creates a data frame
                        (for measurements every 5% or 10% of the body length)"),
          shiny::helpText("The", strong("IMPORT"), "button imports a data frame
                        (for measurements every 5% or 10% of the body length)
                        already existing in the directory.")
        )
      ),
      shiny::wellPanel(
        shiny::fluidRow(
          shiny::strong("Image parameters"),
          shiny::p(),
          shiny::textInput("Species", "Species name:",
                           placeholder = "Given Species name"),
          shiny::textInput("ImageID", "Image-ID:",
                           placeholder = "Given the Image-ID"),
          shiny::textInput("ImageRES", "Image Resolution:",
                           placeholder = "Given the Image Resolution")
        )
      ),
        shiny::fluidRow(
          shiny::column(
            width = 6,
            shiny::numericInput(
              "alt",
              "Fligth Altitude (m)",
              20,
              min = 5,
              max = 150,
              step = 5
            ),
            shiny::numericInput(
              "laser_alt",
              "Laser Altitude (m)",
              0,
              min = 0,
              max = 150,
              step = 5
            ),
            shiny::br(),
            shiny::numericInput("takeof",
                                "Take-off Altitude (m)",
                                value = 0),
            shiny::textInput("Date",
                             "Image collection date: YYYY-MM-DD",
                             value = ""),
            shiny::textInput("obs",
                             "Observer:",
                             value = "")
          ),
          shiny::column(
            width = 6,
            shiny::radioButtons(
              "score",
              "Frame Score:",
              choices =
                list(
                  "Good" = 1,
                  "Moderate" = 2,
                  "Bad" = 3,
                  "Not assingned" = 4
                ),
              selected = 4
            ),
            shiny::textInput("sw", "Camera sensor width (mm):",
                             placeholder = "Sensor width (mm)",
                             value = NULL),
            shiny::textInput("flen", "Camera focal length (mm):",
                             placeholder = "Focal length (mm)",
                             value = NULL),
            shiny::textInput("drone",
                             "Drone model:",
                             value = NULL)
          ),
        ),

        shiny::fluidRow(
          shiny::textAreaInput(
            "comments",
            "Comments here:",
            value = "",
            resize = "none"
          )
        ),

        shiny::actionButton("closeBtn",
                            "Close application",
                            width = "100%")
      ),

    shiny::mainPanel(
      width = 8,
      shiny::tabsetPanel(
        id = "main_tabs",
        type = "tabs",
        shiny::tabPanel(
          "Instructions",
          shiny::div(style = "padding: 10px 20px;",

                     # Main Header
                     shiny::div(
                       style = "background-color: #e2e6ea; padding: 20px 25px; border-radius: 8px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);",
                       shiny::h2("MedidoR: Photogrammetry Workflow Guide",
                                 style = "color: #0047AB; font-weight: bold; margin-top: 0; margin-bottom: 8px;"),
                       shiny::p("Standardized protocol for extracting morphometric measurements and biological condition indices from aerial drone imagery.",
                                style = "color: #333333; font-size: 1.1em; margin-bottom: 0;")
                     ),

                     # STEP 1: Setup
                     shiny::div(
                       style = "background-color: #f0f3f5; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); padding: 20px; border-left: 6px solid #0047AB; margin-bottom: 25px;",
                       shiny::h3(shiny::icon("folder-open"), " 1. Initialization & Data Management", style = "color: #333333; margin-top: 0;"),
                       shiny::tags$ul(style = "color: #444444; font-size: 1.05em; line-height: 1.6;",
                                      shiny::tags$li(shiny::strong("Set Working Directory:"), " Define the local folder containing your drone imagery."),
                                      shiny::tags$li(shiny::strong("Select Mode:"), " Choose between ", shiny::em("Morphometrics"), " (proportional body segmentation) or ", shiny::em("Free Measurements"), " (custom anatomical traits)."),
                                      shiny::tags$li(shiny::strong("Database Setup:"), " Click ", shiny::strong("CREATE"), " to initialize a new dataset, or ", shiny::strong("IMPORT"), " to load an existing analytical spreadsheet.")
                       )
                     ),

                     # STEP 2: Image & Metadata
                     shiny::div(
                       style = "background-color: #f0f3f5; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); padding: 20px; border-left: 6px solid #0047AB; margin-bottom: 25px;",
                       shiny::h3(shiny::icon("image"), " 2. Image Processing & Metadata", style = "color: #333333; margin-top: 0;"),
                       shiny::tags$ul(style = "color: #444444; font-size: 1.05em; line-height: 1.6;",
                                      shiny::tags$li(shiny::strong("Upload Target:"), " Import your high-resolution aerial image (JPG/PNG/TIFF)."),
                                      shiny::tags$li(shiny::strong("Flight Parameters:"), " Strictly fill all required metadata (Flight Altitude, Camera Sensor Width, Focal Length, and Species). "),
                                      shiny::tags$li(shiny::strong("Region of Interest:"), " Draw a bounding box around the target animal and click ", shiny::strong("CROP"), " to optimize the rendering canvas.")
                       )
                     ),

                     # STEP 3: Measurement Protocol
                     shiny::div(
                       style = "background-color: #f0f3f5; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); padding: 20px; border-left: 6px solid #0047AB; margin-bottom: 25px;",
                       shiny::h3(shiny::icon("ruler-combined"), " 3. Measurement Protocols", style = "color: #333333; margin-top: 0;"),

                       shiny::h4("Path A: Proportional Morphometrics", style = "color: #0047AB; margin-top: 15px;"),
                       shiny::tags$ol(style = "color: #444444; font-size: 1.05em; line-height: 1.6;",
                                      shiny::tags$li(shiny::strong("Trace Centerline:"), " Click 3 consecutive times along the body axis (1: Tip of rostrum, 2: Mid-body, 3: Fluke notch)."),
                                      shiny::tags$li(shiny::strong("Width Segments:"), " Click on the body boundaries where the perpendicular dashed guides intersect the animal's margins."),
                                      shiny::tags$li(shiny::strong("Fluke Width:"), " Complete the extraction by clicking on both outer tips of the tail fluke.")
                       ),

                       shiny::h4("Path B: Free Measurements", style = "color: #0047AB; margin-top: 15px;"),
                       shiny::tags$ol(style = "color: #444444; font-size: 1.05em; line-height: 1.6;",
                                      shiny::tags$li(shiny::strong("Initialize:"), " Click ", shiny::strong("New Measurement"), " and assign a biological ID (e.g., 'Dorsal-Fin', 'Scar-Length')."),
                                      shiny::tags$li(shiny::strong("Extract:"), " Click exactly two points on the image to compute the linear distance in pixels."),
                                      shiny::tags$li(shiny::strong("Iterate:"), " Save the trait and click ", shiny::strong("Continue"), " for additional features, or ", shiny::strong("Finish"), " to conclude.")
                       )
                     ),

                     # STEP 4: Calibration
                     shiny::div(
                       style = "background-color: #f0f3f5; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05); padding: 20px; border-left: 6px solid #0047AB; margin-bottom: 25px;",
                       shiny::h3(shiny::icon("chart-line"), " 4. Scale Calibration & Export", style = "color: #333333; margin-top: 0;"),
                       shiny::tags$ul(style = "color: #444444; font-size: 1.05em; line-height: 1.6;",
                                      shiny::tags$li(shiny::strong("Integrate Model:"), " Navigate to the ", shiny::strong("Calibration"), " tab and provide the ", shiny::em("calib.xlsx"), " spreadsheet generated by the MedidoR Scale module."),
                                      shiny::tags$li(shiny::strong("Run Validation:"), " Click ", shiny::strong("RUN Calibration"), " to fit the linear regression model correcting altitude biases."),
                                      shiny::tags$li(shiny::strong("Evaluate Accuracy:"), " Inspect the generated diagnostic plots (Homogeneity, Residuals) and statistical metrics (RMSE, R²)."),
                                      shiny::tags$li(shiny::strong("Final Export:"), " Transformed metric estimates (meters) are automatically saved to your dataset, ready for analysis in the ", shiny::strong("Dataframe"), " tab.")
                       )
                     ),

                     # Methodological Note
                     shiny::div(
                       style = "background-color: #e6f0ff; border-radius: 5px; padding: 15px; margin-top: 10px; border: 1px solid #cce0ff;",
                       shiny::h4(shiny::icon("info-circle"), " Methodological Note", style = "color: #0047AB; margin-top: 0;"),
                       shiny::p("Ensure maximum contrast during pixel selection. All extracted measurements remain in pixel units until the dynamic Ground Sample Distance (cGSD) calibration is executed in Step 4.",
                                style = "color: #333333; font-size: 0.95em; margin-bottom: 0;")
                     )
          )
        ),
        shiny::tabPanel(
          "Image plot",
          uiOutput("crop_status"),
          fluidRow(
            shiny::plotOutput(
              "imagePlot",
              height = "720",
              width = "1080",
              click = "plot_click",
              brush = brushOpts(
                id = "plot_brush",
                resetOnNew = T,
                opacity = 0.1,
                clip = T
              )
            )),
          uiOutput("add_status"),

          shiny::conditionalPanel(
            condition = "input.app_mode == 'free'",
            shiny::actionButton("new_free_measure", "New Measurement", width = "100%", style = "margin-bottom: 10px; background-color: #28a745; border-color: #28a745;")
          ),
          shiny::actionButton("saveBtn", "ADD IN", width = "100%"),
          # Modified button layout
          div(style = "margin-top: 20px;",
              shiny::actionButton("crop", "CROP", width = "32%"),
              shiny::actionButton("undo", "Undo", width = "32%"),
              shiny::actionButton("clearBtn", "CLEAR", width = "32%")
          )
        ),

        shiny::tabPanel(
          "Dataframe",
          shiny::p(),
          shinycssloaders::withSpinner(
            DT::dataTableOutput("mTable"),
            type = getOption("spinner.type",
                             default = 4)
          )
        ),

        shiny::tabPanel(
          "Calibration",
          shiny::textInput(inputId = "calib_path",
                           label = "Calibration data path",
                           value = "",
                           placeholder = "Set the desired calibration data path (.xlsx)",
                           width = "75%"
                           ),
          shiny::p(),
          shiny::actionButton("calib",
                              "RUN Calibration",
                              width = "50%"),
          shiny::radioButtons("save_plot",
                              "Save plots ?",
                              choices =
                                list("Yes" = "Y",
                                     "No" = "N"),
                              selected = "Y"
                              ),
          shiny::radioButtons("alt_data",
                              "Laser or Barometer ?",
                              choices =
                                list("Laser" = "0",
                                     "Barometer" = "1"),
                              selected = "1"
          ),
          shiny::p(),
          shiny::wellPanel(
            shiny::fluidRow(shiny::strong("Diagnostic plot")),
            shiny::p(),
            shinycssloaders::withSpinner(
              shiny::plotOutput("checkm",
                                height = "600"),
              type = getOption("spinner.type",
                               default = 4)
            )
          ),
          shiny::p(),
          shiny::wellPanel(
            shiny::fluidRow(shiny::strong("Accuracy plot")),
            shiny::p(),
            shinycssloaders::withSpinner(
              shiny::plotOutput("variance",
                                height = "600"),
              type = getOption("spinner.type",
                               default = 4)
            )
          ),
          shiny::wellPanel(
            shiny::fluidRow(shiny::strong("Regression plot")),
            shiny::p(),
            shinycssloaders::withSpinner(
              shiny::plotOutput("mplot",
                                height = "600"),
              type = getOption("spinner.type",
                               default = 4)
            )
          )
        ),

        shiny::tabPanel(
          "Measured Whales",
          shiny::h1("Measurement distribution histogram"),
          shiny::sliderInput(
            "n_whales",
            "How many samples to show ?",
            min = 0,
            max = 100,
            value = 0
          ),
          shiny::p(),
          shiny::wellPanel(
            shiny::fluidRow(
              shiny::strong("Pixel measurements")),
            shiny::p(),
            shinycssloaders::withSpinner(
              shiny::plotOutput("lplot"),
              type = getOption("spinner.type",
                               default = 4)
              )
          ),
          shiny::wellPanel(
            shiny::fluidRow(
              shiny::strong("Estimated lengths (meters)")),
            shiny::p(),
            shinycssloaders::withSpinner(
              shiny::plotOutput("mwhale"),
              type = getOption("spinner.type",
                               default = 4)
            )
          )
        )
      )
    )
  )
)
