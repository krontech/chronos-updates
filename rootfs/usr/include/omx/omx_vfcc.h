/*
 *  Copyright (c) 2010-2011, Texas Instruments Incorporated
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  *  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *  *  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *  *  Neither the name of Texas Instruments Incorporated nor the names of
 *     its contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  Contact information for paper mail:
 *  Texas Instruments
 *  Post Office Box 655303
 *  Dallas, Texas 75265
 *  Contact information:
 *  http://www-k.ext.ti.com/sc/technical-support/product-information-centers.htm?
 *  DCMP=TIHomeTracking&HQS=Other+OT+home_d_contact
 *  ============================================================================
 *
 */


/**
 *******************************************************************************
*   @file  omx_vfcc.h
 *  @brief  This file contains interfaces for the OMX methods of Video 
 *          capture component.
 *          A user would typically use functions and data structures defined in 
 *          this module to access different VFCC functionalites
*
*   @rev  1.0
 *******************************************************************************
 */

#ifndef _OMX_VFCC_H
#  define _OMX_VFCC_H
#  ifdef _cplusplus
extern "C"
{
#  endif                                                   /* _cplusplus */

/*******************************************************************************
*                             Compilation Control Switches
*******************************************************************************/
/* None */

/*******************************************************************************
*                             INCLUDE FILES
*******************************************************************************/
/*--------------------- system and platform files ----------------------------*/
/* None */

/*-------------------------program files -------------------------------------*/
#include "OMX_Types.h"
#include "OMX_IVCommon.h"

/*******************************************************************************
 * PUBLIC DECLARATIONS Defined here, used elsewhere
 ******************************************************************************/

/*--------------------------- macros  ----------------------------------------*/

/** 
 *  OMX_VFCC_COMP_NAME - Name of the component. This define is used when IL 
 *  client makes a getHandle call to the omx core.
 *
*/
#define OMX_VFCC_COMP_NAME "OMX.TI.VPSSM3.VFCC"

/** 
 *  OMX_VFCC_DEFAULT_START_PORT_NUM - Default port start number of VFCC comp.
 *  
*/
#define  OMX_VFCC_DEFAULT_START_PORT_NUM (0)

/** 
 *  OMX_VFCC_OUTPUT_PORT_START_INDEX - Output port Index for the VFCC OMX Comp.
 *  
*/
#define OMX_VFCC_OUTPUT_PORT_START_INDEX (OMX_VFCC_DEFAULT_START_PORT_NUM)

/** 
 *  OMX_VFCC_OUTPUT_DUP_PORT_START_INDEX - Dup Output port Index for the VFCC 
 *  OMX Comp.
 *  TODO: To include this macro
*/
/*#  define OMX_VFCC_OUTPUT_DUP_PORT_START_INDEX  (1)*/

/*******************************************************************************
*                           Enumerated Types
*******************************************************************************/
/**
 *  @brief OMX_VIDEO_CAPTURE_HWPORT_ID    : Enumerates capture ports that can be 
 *                                          controlled by the VFCC component
 *  @ param OMX_VIDEO_CaptureHWPortUnUsed : Unspecified hw port
 *  @ param OMX_VIDEO_CaptureHWPortVIP0_PORTA : VIP0_PORTA
 *  @ param OMX_VIDEO_CaptureHWPortVIP0_PORTB : VIP0_PORTB, Valid only for 8 bit
 *  @ param OMX_VIDEO_CaptureHWPortVIP1_PORTA : VIP1_PORTA
 *  @ param OMX_VIDEO_CaptureHWPortVIP1_PORTB : VIP1_PORTB, Valid only for 8 bit
 *  @ param OMX_VIDEO_CaptureHWPortALL_PORTS  : All ports. This is used in a 
 *                                              special case for applications 
 *                                              such as VS.
 *  @ param OMX_VIDEO_CaptureHWPortTIExtensions     : Reserved region for 
 *                                                    introducing 
 *                                                    TI Standard Extensions
 * @ param OMX_VIDEO_CaptureHWPortVendorStartUnused : Reserved region for 
 *                                                    introducing Vendor 
 *                                                    Extensions
 * @ param OMX_VIDEO_CaptureHWPortMax               : Indicates the max. value 
 *                                                    available.
 *
 */
typedef enum OMX_VIDEO_CAPTURE_HWPORT_ID
{
  OMX_VIDEO_CaptureHWPortUnUsed  = 0x00000000,
  OMX_VIDEO_CaptureHWPortVIP1_PORTA,
  OMX_VIDEO_CaptureHWPortVIP1_PORTB,
  OMX_VIDEO_CaptureHWPortVIP2_PORTA,
  OMX_VIDEO_CaptureHWPortVIP2_PORTB,
  OMX_VIDEO_CaptureHWPortALL_PORTS,
  OMX_VIDEO_CaptureHWPortTIExtensions = 0x6F000000,
  OMX_VIDEO_CaptureHWPortVendorStartUnused = 0x7F000000, 
  OMX_VIDEO_CaptureHWPortMax = 0x7FFFFFFF
} OMX_VIDEO_CAPTURE_HWPORT_ID;

/**
 *  @brief OMX_VIDEO_CAPTURE_HWPORT_CAPT_MODE : H/W Capture Mode 
 *  @ param OMX_VIDEO_CaptureModeUnused       : Unspecified hw port
 *  @ param OMX_VIDEO_CaptureModeSC_NON_MUX   : Single channel non-mux
 *  @ param OMX_VIDEO_CaptureModeMC_LINE_MUX  : Multi channel line mux
 *  @ param OMX_VIDEO_CaptureModeMC_PEL_MUX   : Multi channel pixel mux
 *  @ param OMX_VIDEO_CaptureModeSC_DISCRETESYNC       : Single channel 
 *                                                       Discrete sync
 *  @ param OMX_VIDEO_CaptureModeMC_LINE_MUX_SPLIT_LINE: Line Mux, split line 
 *  @ param OMX_VIDEO_CaptureModeTIExtensions     : Reserved region for 
 *                                                  introducing 
 *                                                  TI Standard Extensions
 * @ param OMX_VIDEO_CaptureModeVendorStartUnused : Reserved region for 
 *                                                  introducing Vendor 
 *                                                  Extensions
 * @ param OMX_VIDEO_CaptureModeMax               : Indicates the max. value 
 *                                                  available.
 *
 */
typedef enum OMX_VIDEO_CAPTURE_HWPORT_CAPT_MODE
{
  OMX_VIDEO_CaptureModeUnused = 0x00000000,
  OMX_VIDEO_CaptureModeSC_NON_MUX,
  OMX_VIDEO_CaptureModeMC_LINE_MUX,
  OMX_VIDEO_CaptureModeMC_PEL_MUX,
  OMX_VIDEO_CaptureModeSC_DISCRETESYNC,
  OMX_VIDEO_CaptureModeMC_LINE_MUX_SPLIT_LINE,
  OMX_VIDEO_CaptureModeSC_DISCRETESYNC_ACTVID_VSYNC,
  OMX_VIDEO_CaptureModeSC_DISCRETESYNC_ACTVID_VBLK = OMX_VIDEO_CaptureModeSC_DISCRETESYNC,
  OMX_VIDEO_CaptureModeTIExtensions = 0x6F000000,
  OMX_VIDEO_CaptureModeVendorStartUnused  = 0x7F000000,
  OMX_VIDEO_CaptureModeMax = 0x7FFFFFFF
} OMX_VIDEO_CAPTURE_HWPORT_CAPT_MODE;

/**
 *  @brief OMX_VIDEO_CAPTURE_HWPORT_VIF_MODE  : Video Interface Mode
 *  @ param OMX_VIDEO_CaptureVifModeUnused    : Unspecified Vif Mode
 *  @ param OMX_VIDEO_CaptureVifMode_08BIT    : 8 bit interface mode
 *  @ param OMX_VIDEO_CaptureVifMode_16BIT    : 16 bit interface mode
 *  @ param OMX_VIDEO_CaptureVifMode_24BIT    : 24 bit interface mode
 *  @ param OMX_VIDEO_CaptureModeTIExtensions : Reserved region for 
 *                                              introducing TI Standard 
 *                                              Extensions
 * @ param OMX_VIDEO_CaptureModeVendorStartUnused : Reserved region for 
 *                                                  introducing Vendor 
 *                                                  Extensions
 * @ param OMX_VIDEO_CaptureModeMax: Indicates the max. value available.
 *
 */
typedef enum OMX_VIDEO_CAPTURE_HWPORT_VIF_MODE
{
  OMX_VIDEO_CaptureVifModeUnused = 0x00000000,
  OMX_VIDEO_CaptureVifMode_08BIT,
  OMX_VIDEO_CaptureVifMode_16BIT,
  OMX_VIDEO_CaptureVifMode_24BIT,
  OMX_VIDEO_CaptureVifModeTIExtensions = 0x6F000000,
  OMX_VIDEO_CaptureVifModeVendorStartUnused = 0x7F000000,
  OMX_VIDEO_CaptureVifModeMax = 0x7FFFFFFF
} OMX_VIDEO_CAPTURE_HWPORT_VIF_MODE;

/**
 *  @brief OMX_VIDEO_CAPTURE_SCANTYPE : Video Scan Mode
 *  @ param OMX_VIDEO_CaptureScanTypeUnused: Unspecified Scan Mode
 *  @ param OMX_VIDEO_CaptureScanTypeProgressive: Progressive scan
 *  @ param OMX_VIDEO_CaptureScanTypeInterlaced: Interlaced scan
 *  @ param OMX_VIDEO_CaptureScanTypeTIExtensions : Reserved region for 
 *                                                introducing 
 *                                                TI Standard Extensions
 *  @ param OMX_VIDEO_CaptureScanTypeVendorStartUnused : Reserved region for 
 *                                                    introducing Vendor 
 *                                                    Extensions
 *  @ param OMX_VIDEO_CaptureScanTypeMax: Indicates the max. value available.
 *
 */

typedef enum OMX_VIDEO_CAPTURE_SCANTYPE
{
  OMX_VIDEO_CaptureScanTypeUnused = 0x00000000,
  OMX_VIDEO_CaptureScanTypeProgressive,
  OMX_VIDEO_CaptureScanTypeInterlaced,
  OMX_VIDEO_CaptureScanTypeTIExtensions = 0x6F000000,
  OMX_VIDEO_CaptureScanTypeVendorStartUnused  = 0x7F000000,
  OMX_VIDEO_CaptureScanTypeMax = 0x7FFFFFFF
} OMX_VIDEO_CAPTURE_SCANTYPE;

/*******************************************************************************
 *                              Structures
 ******************************************************************************/

/** 
 *   @ struct : OMX_PARAM_VFCC_HWPORT_PROPERTIES   
 *   @ brief  : Provides the H/W Port properties
 *
 *   @ param   nSize              :  Size of the structure in bytes
 *   @ param   nVersion           :  OMX specification version info 
 *   @ param   nPortIndex         :  Port Index, Ignored.This element is 
 *                                   compulsory as per the omx std.
 *   @ param   eCaptMode          :  Capture Mode
 *   @ param   eVifMode           :  Video Interface mode
 *   @ param   eInColorFormat     :  VIP input color format, Only 
 *                                   OMX_COLOR_Format24bitRGB888 and 
 *                                   OMX_COLOR_FormatYCbYCr are valid.
 *   @ param   eScanType          :  Frame scan type
 *   @ param   nMaxWidth          :  Maximum width in pels
 *   @ param   nMaxHeight         :  Maximum height in pels
 *   @ param   nMaxChnlsPerHwPort :  maximum channels per h/w port
 * 
 */
typedef struct OMX_PARAM_VFCC_HWPORT_PROPERTIES
{
  OMX_U32 nSize;
  OMX_VERSIONTYPE nVersion;
  OMX_U32 nPortIndex;
  OMX_VIDEO_CAPTURE_HWPORT_CAPT_MODE eCaptMode;
  OMX_VIDEO_CAPTURE_HWPORT_VIF_MODE  eVifMode;   
  OMX_COLOR_FORMATTYPE eInColorFormat;
  OMX_VIDEO_CAPTURE_SCANTYPE eScanType;
  OMX_U32 nMaxWidth;
  OMX_U32 nMaxHeight;
  OMX_U32 nMaxChnlsPerHwPort;
  OMX_BOOL bFieldMerged;
} OMX_PARAM_VFCC_HWPORT_PROPERTIES;

/** 
 *   @ struct : OMX_PARAM_VFCC_HWPORT_ID
 *   @ brief  : Provides the H/W Port ID 
 *
 *   @ param   nSize      :  Size of the structure in bytes
 *   @ param   nVersion   :  OMX specification version info 
 *   @ param   nPortIndex :  Port Index, Ignored.This element is compusory as 
 *                           per the omx std.
 *   @ param   eHwPortId  :  hardware port ID that the VFCC is configured to use
 * 
 */
typedef struct OMX_PARAM_VFCC_HWPORT_ID
{
  OMX_U32 nSize;
  OMX_VERSIONTYPE nVersion;
  OMX_U32 nPortIndex;
  OMX_VIDEO_CAPTURE_HWPORT_ID eHwPortId;
} OMX_PARAM_VFCC_HWPORT_ID;

/** 
 *   @ struct : OMX_PARAM_VIDEO_CAPTURE_STATS
 *   @ brief  : Gets the statistics on a specific omx port
 *
 *   @ param   nSize      :  Size of the structure in bytes
 *   @ param   nVersion   :  OMX specification version info 
 *   @ param   nPortIndex :  Port Index
 *   @ param   uBufsRxdFromHWPort : No. of buffers received from the h/w port 
 *                                  for port specified above
 *   @ param   uHeightErrCnt      : No. of buffers recvd. from driver having 
 *                                  height other than specified.
 *   @ param   uWidthErrCnt       : No. of buffers recvd. from driver having 
 *                                  width other than specified.
 *   @ param   uTotalBufsAvail    : No. of buffers available summed across all
 *                                  streams and channels.
 *   @ param   uLowBufsLevel      : Minimum number of available buffers of all
 *                                  streams and channels.
 *   @ param   uDroppedFrameCnt   ; No. of frames dropped during capture.
 *
 *    Note: This is a place holder for getting the capture statistics. 
 *    The current release (4.0.0.8) does not use this configuration.
 */
typedef struct OMX_PARAM_VIDEO_CAPTURE_STATS
{
  OMX_U32 nSize;
  OMX_VERSIONTYPE nVersion;
  OMX_U32 nPortIndex;
  OMX_U32 uBufsRxdFromHWPort;
  OMX_U32 uHeightErrCnt;
  OMX_U32 uWidthErrCnt;
  OMX_U32 uTotalBufsAvail;
  OMX_U32 uLowBufsLevel;
  OMX_U32 uDroppedFrameCnt;
} OMX_PARAM_VIDEO_CAPTURE_STATS;

/** 
 *   @ struct : OMX_CONFIG_VIDEO_CAPTURE_RESET_STATS
 *   @ brief  : Resets the statistics on a specific omx port
 *
 *   @ param   nSize       :  Size of the structure in bytes
 *   @ param   nVersion    :  OMX specification version info 
 *   @ param   nPortIndex  :  Port Index
 *
 *    Note: This is a place holder for resetting the capture statistics. 
 *    The current release (4.0.0.8) does not use this configuration.
 *
 */
typedef struct OMX_CONFIG_VIDEO_CAPTURE_RESET_STATS
{
  OMX_U32 nSize;
  OMX_VERSIONTYPE nVersion;
  OMX_U32 nPortIndex;
} OMX_CONFIG_VIDEO_CAPTURE_RESET_STATS;

/** 
 *   @ struct : OMX_CONFIG_VFCC_FRAMESKIP_INFO
 *   @ brief  : Skip frames on a specific omx port
 *
 *   @ param   nSize       :  Size of the structure in bytes
 *   @ param   nVersion    :  OMX specification version info 
 *   @ param   nPortIndex  :  Port Index
 *   @ param   frameSkipMask: Frame skip masx
 */
typedef struct OMX_CONFIG_VFCC_FRAMESKIP_INFO
{
  OMX_U32 nSize;
  OMX_VERSIONTYPE nVersion;
  OMX_U32 nPortIndex;
  OMX_U32 frameSkipMask;
} OMX_CONFIG_VFCC_FRAMESKIP_INFO;

/*---------------------- - function prototypes -------------------------------*/
/** OMX VFCC Component Init */

  OMX_ERRORTYPE OMX_TI_VFCC_ComponentInit ( OMX_HANDLETYPE hComponent );

#ifdef _cplusplus
}
#endif /* __cplusplus */

#endif /* _OMX_VFCC_H */

/* omx_vfcc.h - EOF */
