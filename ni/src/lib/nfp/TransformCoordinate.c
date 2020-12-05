#include <stdio.h>

#define ACCEPT_USE_OF_DEPRECATED_PROJ_API_H 1
#define PROJ_API_INCLUDED_FOR_PJ_VERSION_ONLY 1
#include <proj_api.h>
#if PJ_VERSION >= 600 && 1
#define _PJ_API_5
#include <proj.h>
#else
#define _PJ_API_4
#undef PROJ_API_INCLUDED_FOR_PJ_VERSION_ONLY
#include <proj_api.h>
#endif

#include "TransformCoordinate.h"

int TransformCoordinate(char * SrcProjStr, char * DstProjStr,
        double * x, double * y, double * z,
        unsigned int nPoint) {
#ifdef _PJ_API_5 /*#if PJ_VERSION >= 600*/
    PJ *P;
#else
    projPJ SrcProj, DstProj;
#endif
    int Err, i;

    /* Constructing the projections */
#ifdef _PJ_API_5 /*#if PJ_VERSION >= 600*/
    P = proj_create_crs_to_crs(PJ_DEFAULT_CTX, SrcProjStr, DstProjStr, 0);
    Err = proj_errno(P);
    if (P==0 || Err!=0) {
        printf("FATAL ERROR: Can not create transformation of <%s> to <%s>\n", SrcProjStr, DstProjStr);
        return (1);
    }
#else
    if (!(SrcProj = pj_init_plus(SrcProjStr))) {
        printf("FATAL ERROR: Can not make a projection out of <%s>\n", SrcProjStr);
        return (1);
    }
    if (!(DstProj = pj_init_plus(DstProjStr))) {
        printf("FATAL ERROR: Can not make a projection out of <%s>\n", DstProjStr);
        return (2);
    }
#endif

    /* Converting to radian if needed */
#ifdef _PJ_API_5 /*#if PJ_VERSION >= 600*/
    if (proj_angular_input(P, PJ_INV)) {
        for (i = 0; i < nPoint; i++) {
            x[i] = proj_torad(x[i]);
            y[i] = proj_torad(y[i]);
        }
    }
#else
    if (pj_is_latlong(SrcProj)) {
        for (i = 0; i < nPoint; i++) {
            x[i] *= DEG_TO_RAD;
            y[i] *= DEG_TO_RAD;
        }
    }
#endif

    /* Transforming the coordinates */
#ifdef _PJ_API_5 /*#if PJ_VERSION >= 600*/
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
#else
    if ((Err = pj_transform(SrcProj, DstProj, nPoint, 1, x, y, z)) != 0) {
        printf("FATAL ERROR: %s\n", pj_strerrno(Err));
        return (3);
    }
#endif

    /* converting to degree if needed */
#ifdef _PJ_API_5 /*#if PJ_VERSION >= 600*/
    if (proj_angular_output(P, PJ_FWD)) {
        for (i = 0; i < nPoint; i++) {
            x[i] = proj_todeg(x[i]);
            y[i] = proj_todeg(y[i]);
        }
    }
#else
    if (pj_is_latlong(DstProj)) {
        for (i = 0; i < nPoint; i++) {
            x[i] *= RAD_TO_DEG;
            y[i] *= RAD_TO_DEG;
        }
    }
#endif

#ifndef _PJ_API_5 /*#if PJ_VERSION < 600*/
    /* freeing the projection */
    pj_free(DstProj);
    pj_free(SrcProj);
#endif
    return (0);
}

