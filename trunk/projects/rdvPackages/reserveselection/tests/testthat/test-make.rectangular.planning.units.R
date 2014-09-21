#===============================================================================

#  TESTING

t.make_rectangular_PU_files <- function ()
    {
    OPT.use.new.version.of.marxan = TRUE
    path.back.to.work.dir = "../runall"
    path.to.marxan2 = "../marxan211/"
    path.to.marxan1 = "../marxan/"
    planning.units.filename = "planning.units.file"
    marxan.results.file.name = "marxan.results.file"

    num_rows = 16
    num_cols = 16
    DEBUG = TRUE
    num_PUs_x = 16
    num_PUs_y = 16
    #  reserve.design.validation.R:376:
    #      planning.units.filename.base <- 'planning.units.uid'
#    PUs_filename_base = '/Users/Bill/D/rdv-framework/projects/rdvPackages/reserveselection/tests/testthat/planning.units.uid'
    PUs_filename_base = 'planning.units.uid'

    non_habitat_indicator = 0

    PU_x = 2
    PU_y = 4


    make_rectangular_PU_files (num_rows, num_cols,
                                DEBUG,
                                num_PUs_x, num_PUs_y,
                                PUs_filename_base,

                                non_habitat_indicator,
                                PU_x, PU_y
                                )

    return (TRUE)
    }

test_that ("make_rectangular_PU_files() runs to completion",
            {
                cat ("\n\n*****  In test_that make_rect...  *****\n\n")
            expect_true (t.make_rectangular_PU_files ())
            cat ("\n\n*****  Done with test_that make_rect...  *****\n\n")

            }
          )

#===============================================================================

