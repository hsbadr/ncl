
/*
 *      $Id: DataSupport.h,v 1.3 1994-08-25 18:00:23 ethan Exp $
 */
/************************************************************************
*									*
*			     Copyright (C)  1993			*
*	     University Corporation for Atmospheric Research		*
*			     All Rights Reserved			*
*									*
************************************************************************/
/*
 *	File:		
 *
 *	Author:		Ethan Alpert
 *			National Center for Atmospheric Research
 *			PO 3000, Boulder, Colorado
 *
 *	Date:		Tue Dec 28 10:38:48 MST 1993
 *
 *	Description:	
 */
#ifndef _DataSupport_h
#define _DataSupport_h

extern void _NclInitDataClasses(
#if	NhlNeedProto
void
#endif
);

extern struct _NclMultiDValDataRec *_NclCharMdToStringMd(
#if	NhlNeedProto
struct _NclMultiDValDataRec * /*char_md*/
#endif
);
extern struct _NclMultiDValDataRec *_NclStringMdToCharMd(
#if	NhlNeedProto
struct _NclMultiDValDataRec * /*string_md*/
#endif
);

extern char* _NclBasicDataTypeToName(
#if	NhlNeedProto
NclBasicDataTypes /*dt*/
#endif
);

extern NclBasicDataTypes _NclPromoteType(
#if  	NhlNeedProto
	NclBasicDataTypes /*dt*/
#endif
); 

extern struct _NclMultiDValDataRec * _NclCoerceData(
#if 	NhlNeedProto
struct _NclMultiDValDataRec * /*self*/,
NclObjTypes /* coerce_obj_to */,
NclScalar * /* coerce_obj_to */
#endif
);

extern void _NclPrint(
#if	NhlNeedProto
struct _NclObjRec* /* self*/,
FILE * /* fp*/
#endif
);

extern NhlErrorTypes _NclCallMonoOp(
#if	NhlNeedProto
struct _NclMultiDValDataRec* /* operand*/,
NclObj*			/* result*/,
int				/* op */
#endif
);

extern NhlErrorTypes _NclCallDualOp(
#if	NhlNeedProto
struct _NclMultiDValDataRec* /* lhs */,
struct _NclMultiDValDataRec* /* rhs */,
int				/* op */,
NclObj*			/* result*/
#endif
);

extern struct _NclMultiDValDataRec* _NclCopyVal(
#if	NhlNeedProto
struct _NclMultiDValDataRec * /*self*/,
NclScalar *	/* new_missing */
#endif
);

extern void _NclResetMissingValue(
#if	NhlNeedProto
struct _NclMultiDValDataRec * /*self*/,
NclScalar * /* missing*/
#endif
);

extern int _NclScalarCoerce(
#if  NhlNeedProto
void * /*from*/,
NclBasicDataTypes /*frtype*/,
void * /*to*/,
NclBasicDataTypes /*totype*/
#endif
);

struct _NclMultiDValDataRec * _NclCreateVal(
#if     NhlNeedProto
NclObj /*inst*/, 
NclObjClass /*theclass*/, 
NclObjTypes /*obj_type*/, 
unsigned int /*obj_type_mask*/, 
void * /*val*/, 
NclScalar * /*missing_value*/, 
int /*n_dims*/, 
int * /*dim_sizes*/, 
NclStatus /*status*/, 
NclSelectionRecord * /*sel_rec*/
#endif
);


extern NhlErrorTypes _NclAddParent(
#if NhlNeedProto
NclObj /*theobj*/ ,
NclObj /*parent*/
#endif
);

extern NhlErrorTypes _NclDelParent(
#if NhlNeedProto
NclObj /*theobj*/,
NclObj /*parent*/
#endif
);


extern NclBasicDataTypes _NclKeywordToDataType(
#if NhlNeedProto
struct _NclSymbol * /*keywd*/
#endif 
);

extern unsigned int _NclKeywordToObjType(
#if  NhlNeedProto 
struct _NclSymbol * /*keywd*/
#endif
);

extern int _NclIsMissing(
#if NhlNeedProto 
NclMultiDValData self, void* val
#endif
);

extern int _NclGetObjRefCount(
#if NhlNeedProto
int /*the_id*/
#endif
);

extern  long _NclObjTypeToName(
#if  NhlNeedProto
NclObjTypes /*obj_type*/
#endif
);

extern NclObjTypes _NclBasicDataTypeToObjType(
#if NhlNeedProto
NclBasicDataTypes /*dt*/
#endif
);

#endif /*_DataSupport_h */

