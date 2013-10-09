This project was modified to run with Tzar 0.4, but was failing, complaining about a missing SHP file.
[FINE|2:33:33]: Initialising planning unit informationError in getinfo.shape(filen) : Error opening SHP file
[FINE|2:33:33]: Calls: extract.shape.file.attribute.table.to.data.frame -> readShapePoly
nb: I just tested it with 0.3 and it fails (on my machine) with the same error. It may be straightforward
to port to 0.4, but I can't test it.

As such, I've reverted it to the previous version (which works with 0.3). For reference, to make it work in 0.4,
someone will need to:

- Add the runner class field to projectparams.yaml
- Merge the globalparams.yaml file into projectparams.yaml
- Merge repetitions.yaml into projectparams.yaml
- Copy all required R code from ../R/ into R/
    GIS.utility.functions.R
    OffsetPool.R
    dbms.functions.R
    dbms.initialise.R
    determine.PUs.in.offset.and.dev.pools.R
    eval.cond.polygon.R
    generate.pu.assessment.biases.R
    grassland.condition.model.R
    grassland.condition.model.functions.R
    initialise.CPW.information.R
    initialise.CPW.information.functions.R
    initialise.planning.unit.information.R
    limit.evolution.of.CPW.initial.condition.R
    loss.model.R
    loss.model.functions.R
    make.Mondrian.planning.units.R
    make.patches.planning.units.R
    make.rectangular.planning.units.R
    make.rectangular.planning.units.functions.R
    random.development.R
    reserve.random.R
    reserve.random.functions.R
    stop.execution.R
    utility.functions.R
    w.R
    write.time.series.polygons.R
