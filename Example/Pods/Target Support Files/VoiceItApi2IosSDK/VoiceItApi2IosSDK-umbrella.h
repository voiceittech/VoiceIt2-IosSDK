#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CameraViewController.h"
#import "SimpleCamera+Helper.h"
#import "SimpleCamera.h"
#import "UIImage+FixOrientation.h"
#import "ViewUtils.h"
#import "VoiceItApi2IosSDK.h"
#import "VoiceItAPITwo.h"

FOUNDATION_EXPORT double VoiceItApi2IosSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char VoiceItApi2IosSDKVersionString[];

