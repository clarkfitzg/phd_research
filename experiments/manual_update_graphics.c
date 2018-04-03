// Wed Mar 28 16:10:49 PDT 2018
// Attempting to directly update graphics device
SEXP c_line()
{
    pGEDevDesc dd = GEcurrentDevice();

    //R_GE_gcontext gc;
    // I'm using the grid package and example and can't seem to find anywhere
    // this is set. It seems like it's in here in grid:
    //
    // 196  * Generate an R_GE_gcontext from a gpar
    // 197  */
    // 198 void gcontextFromgpar(SEXP gp, int i, const pGEcontext gc,
    // pGEDevDesc dd)
    //
    // The graphics package has this:
    //
    // R_GE_gcontext gc; gcontextFromGP(&gc, dd);
    //
    // Which makes me think that both base graphics and grid do the same
    // thing, namely extract the graphics context (gc) from the current device
    // description? (dd)
    //
    // Yes, grid's gcontextFromgpar is quite similar to graphics' gcontextFromGP.


    /* Following this from GraphicsEngine.h:
     *
    void GELine(double x1, double y1, double x2, double y2,
    const pGEcontext gc, pGEDevDesc dd);
            */

    GELine(0.0, 0.0, 1.0, 1.0, gc, dd)

}
