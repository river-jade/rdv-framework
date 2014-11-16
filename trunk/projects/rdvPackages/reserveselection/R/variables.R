#  Getting settings for as many of these as I can from the old framework
#  in files rdv.configuration.orig.R [abbreviated here as rco] and
#  rdv.extra.config.R [abbreviated here as rec].

cols
rows
pixel.size

repetition
reprsent.goal.scale.factor
spp.hab.info.table.A.TOT
spp.used.in.reserve.selection.vector

num.objective.funs.entries

num.planning.units.x
num.planning.units.y

PAR.species.penalty.factor
PAR.spp.representation.goals

non.habitat.indicator

hab.map.zo1.A.TOT.spp.filename.base
patch.attributes.file
pu.area.and.cost.APP.filename
Res.path
planning.units.filename
PAR.Marxan2.input.dir
PAR.objfun.results.file

BATCH
use.patches.as.planning.units

OPT.read.represenation.goals.from.file
OPT.representation.calculation
OPT.use.cost.in.marxan
OPT.use.marxan.with.multiple.actors
OPT.use.patches.in.representation
OPT.VAL.use.absolute.num.patches.in.represerntaion.goal
OPT.VAL.use.proportions.in.represerntaion.goal


#=============================================

[rec]:
cols
rows
pixel.size
        if( OPT.using.morn.pen.data ) {
            cols <- 529
            rows <- 349
            pixel.size <- 1
            #OPT.created.planning.unit.source <- OPT.VAL.user.supplied.planning.units
        }
        # note setting the num of rows and cols to match the input from the
        # grassland data

        OPT.using.melb.grassland.data <- FALSE

        if( OPT.using.melb.grassland.data ) {
            # adjust the num of rows and cols to match the
            # grassland data input file
            rows <- 782
            cols <- 832
        }

#---------------------------------------------------------

[nowhere]:
repetition
    #  In make.marxan.spec.dat() it says:
        # both repetition, and PAR.objfun.results.file are set in multi.batch.R
        # or rdv.configuration
    #  The closest I can find is in multi.batch.orig.R where it says:
        PAR.number.of.repetitions <- 1;

#---------------------------------------------------------

[rco]: reprsent.goal.scale.factor
        reprsent.goal.scale.factor <- 0.9; # this is now used to match the sel
        # factor from another method. Eg if you
        # wanted marxan to try and match the rep
        # of richness with 0.2 of patches
        # selected, then set this to

#---------------------------------------------------------

spp.hab.info.table.A.TOT
spp.used.in.reserve.selection.vector

num.objective.funs.entries

num.planning.units.x
num.planning.units.y

PAR.species.penalty.factor
PAR.spp.representation.goals

non.habitat.indicator

hab.map.zo1.A.TOT.spp.filename.base
patch.attributes.file
pu.area.and.cost.APP.filename
Res.path
planning.units.filename
PAR.Marxan2.input.dir

#  [multi.batch.orig.R]
PAR.objfun.results.file
        PAR.objfun.results.file <- 'objfun.runs_200_to_201.rs.RICHNESS.res';


BATCH
use.patches.as.planning.units

OPT.read.represenation.goals.from.file
OPT.representation.calculation
OPT.use.cost.in.marxan
OPT.use.marxan.with.multiple.actors
OPT.use.patches.in.representation
OPT.VAL.use.absolute.num.patches.in.represerntaion.goal
OPT.VAL.use.proportions.in.represerntaion.goal


