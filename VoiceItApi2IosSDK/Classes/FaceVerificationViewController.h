//
//  FaceVerificationViewController.h
//  Pods-VoiceItApi2IosSDK_Example
//
//  Created by Armaan Bindra on 3/17/18.
//

#import <AVFoundation/AVFoundation.h>
#import "SpinningView.h"
#import "Utilities.h"
#import "ResponseManager.h"
#import "VoiceItAPITwo.h"
@import GoogleMobileVision;

@interface FaceVerificationViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
// Detector.
@property(nonatomic, strong) GMVDetector *faceDetector;

#pragma mark -  Graphics/UI/Constraints/Animations
@property CGFloat originalMessageLeftConstraintContstant;
@property (weak, nonatomic) IBOutlet UIView *verificationBox;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet SpinningView *progressView;
@property  CGPoint cameraCenterPoint;
@property CAShapeLayer * leftCircle;
@property CAShapeLayer * rightCircle;
@property CAShapeLayer * downCircle;
@property CAShapeLayer * upCircle;
@property CALayer * cameraBorderLayer;
@property CALayer * faceRectangleLayer;

#pragma mark -  Camera Related Stuff
@property  AVCaptureSession * captureSession;
@property AVCaptureDevice * videoDevice;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSData *finalCapturedPhotoData;

#pragma mark -  Boolean Switches
@property BOOL lookingIntoCam;
@property BOOL livenessDetectionIsHappening;
@property BOOL isRecording;
@property BOOL continueRunning;
@property BOOL enoughRecordingTimePassed;
//@property BOOL takePhoto;

#pragma mark -  Counters to keep track of stuff
@property int successfulChallengesCounter;
@property int lookingIntoCamCounter;
@property int smileCounter;
@property int failCounter;
@property int blinkCounter;
@property BOOL smileFound;
@property int faceDirection;
@property int blinkState;

#pragma mark -  Developer Passed Options
@property (strong, nonatomic)  NSString * userToVerifyUserId;
@property (strong, nonatomic)  NSObject * voiceItMaster;
#pragma mark - Miscellaneous
@property (strong, nonatomic) NSMutableArray* okResponseCodes;

#pragma mark - callbacks
@property (nonatomic, copy) void (^userVerificationCancelled)(void);
@property (nonatomic, copy) void (^userVerificationSuccessful)( float, NSString *);
@property (nonatomic, copy) void (^userVerificationFailed)( float, NSString *);
@end
