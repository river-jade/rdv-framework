#===============================================================================

library ("rdvfileio")
library ("reserveselection")

#===============================================================================

    #  Support routine used in testing.

t.make_rectangular_PU_files <- function ()
    {
#     OPT.use.new.version.of.marxan = TRUE
#     path.back.to.work.dir = "../runall"
#     path.to.marxan2 = "../marxan211/"
#     path.to.marxan1 = "../marxan/"
#     planning.units.filename = "planning.units.file"
#     marxan.results.file.name = "marxan.results.file"

    num_rows = 4
    num_cols = 8
    num_PUs_x = 2
    num_PUs_y = 4
    #  reserve.design.validation.R:376:
    #      planning.units.filename.base <- 'planning.units.uid'
    #    PUs_filename_base = '/Users/Bill/D/rdv-framework/projects/rdvPackages/reserveselection/tests/testthat/planning.units.uid'
    PUs_filename_base = 'planning.units.uid'
    non_habitat_indicator = 0
    DEBUG = TRUE


    make_rectangular_planning_units (num_rows, num_cols,
                                     num_PUs_x, num_PUs_y,
                                     PUs_filename_base,
                                     non_habitat_indicator,
                                     DEBUG
                                    )

    return (TRUE)
    }

#===============================================================================

test_that ("make_rectangular_PU_files() runs to completion",
            {
                cat ("\n\n*****  In test_that make_rect...  *****\n\n")
            expect_true (t.make_rectangular_PU_files ())
            cat ("\n\n*****  Done with test_that make_rect...  *****\n\n")

            }
          )

#===============================================================================

