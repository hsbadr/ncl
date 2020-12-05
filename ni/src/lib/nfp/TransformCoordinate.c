#include <stdio.h>

#include <proj.h>

#include "TransformCoordinate.h"

int TransformCoordinate(char * SrcProjStr, char * DstProjStr,
        double * x, double * y, double * z,
        unsigned int nPoint) {
    PJ *P;
    int Err, i;

    /* Constructing the projections */
    P = proj_create_crs_to_crs(PJ_DEFAULT_CTX, SrcProjStr, DstProjStr, 0);
    Err = proj_errno(P);
    if (P==0 || Err!=0) {
        printf("FATAL ERROR: Can not create transformation of <%s> to <%s>\n", SrcProjStr, DstProjStr);
        return (1);
    }

    /* Converting to radian if needed */
    if (proj_angular_input(P, PJ_INV)) {
        for (i = 0; i < nPoint; i++) {
            x[i] = proj_torad(x[i]);
            y[i] = proj_torad(y[i]);
        }
    }

    /* Transforming the coordinates */
    /*proj_trans_generic (P, PJ_INV,*/
    proj_trans_generic (P, PJ_FWD,
        x, sizeof(double), nPoint,
        y, sizeof(double), nPoint,
        z, sizeof(double), nPoint,
        NULL, 0, 0);

    Err = proj_errno(P);
    if (Err) {
        printf("FATAL ERROR: %s\n", proj_errno_string(Err));
        return (3);
    }

    /* converting to degree if needed */
    if (proj_angular_output(P, PJ_FWD)) {
        for (i = 0; i < nPoint; i++) {
            x[i] = proj_todeg(x[i]);
            y[i] = proj_todeg(y[i]);
        }
    }

    /* freeing the projection */
    proj_destroy(P);
    return (0);
}
