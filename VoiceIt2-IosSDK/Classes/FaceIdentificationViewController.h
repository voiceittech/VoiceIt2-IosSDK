//
//  FaceIdentificationViewController.h
//  VoiceIt2-IosSDK
//
//  Created by VoiceIt Technologies, LLC
//  Copyright (c) 2020 VoiceIt Technologies, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SpinningView.h"
#import "Utilities.h"
#import "ResponseManager.h"
#import "VoiceItAPITwo.h"

@interface FaceIdentificationViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

#pragma mark -  Graphics/UI/Constraints/Animations
@property CGFloat originalMessageLeftConstraintContstant;
@property (weak, nonatomic) IBOutlet UIView *identificationBox;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet SpinningView *progressView;
@property CGPoint cameraCenterPoint;
@property CAShapeLayer * progressCircle;
@property CALayer * cameraBorderLayer;
@property CALayer * faceRectangleLayer;
@property CALayer *rootLayer;

#pragma mark -  Camera Related Stuff
@property AVCaptureSession * captureSession;
@property AVCaptureDevice * videoDevice;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSData *finalCapturedPhotoData;
@property (nonatomic,strong) AVAudioPlayer *player;
@property AVCaptureMovieFileOutput *movieFileOutput;

#pragma mark -  Boolean Switches
@property BOOL lookingIntoCam;
@property BOOL isRecording;
@property BOOL continueRunning;
@property BOOL enoughRecordingTimePassed;
@property BOOL doLivenessDetection;
@property BOOL doAudioPrompts;
@property BOOL verificationStarted;
@property BOOL isReadyToWrite;

#pragma mark -  Counters to keep track of stuff
@property int lookingIntoCamCounter;
@property int failCounter;
@property int failsAllowed;
@property int numberOfLivenessFailsAllowed;

#pragma mark -  Developer Passed Options
@property (strong, nonatomic)  NSString * groupToIdentifyGroupId;
@property (strong, nonatomic)  NSObject * voiceItMaster;
@property (strong, nonatomic)  NSString * contentLanguage;


#pragma mark - callbacks
@property (nonatomic, copy) void (^userIdentificationCancelled)(void);
@property (nonatomic, copy) void (^userIdentificationSuccessful)(float, NSString *, NSString *);
@property (nonatomic, copy) void (^userIdentificationFailed)(float, NSString *);
@end
