//
//  VideoVerificationViewController.m
//  Pods-VoiceItApi2IosSDK_Example
//
//  Created by Armaan Bindra on 3/23/18.
//

#import "VideoVerificationViewController.h"
#import "Styles.h"

@interface VideoVerificationViewController ()
@property(nonatomic, strong)  VoiceItAPITwo * myVoiceIt;
@property(nonatomic, strong)  NSString *videoPath;
@property CGFloat circleWidth;
@property CGFloat backgroundWidthHeight;
@property NSTimer * timer;
@property int currentChallenge;
@property UIColor * greenColor;
@end

@implementation VideoVerificationViewController
int VIDEO_VERIFICATION_TIME_TO_WAIT_TILL_FACE_FOUND = 15;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue",
                                                          DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(int)pickChallenge{
    int rndValue = arc4random_uniform(4);
    while (rndValue == self.currentChallenge){
        rndValue = arc4random_uniform(4);
    }
    return rndValue;
}

-(void)startVerificationProcess {
    [self startDelayedRecording:0.4];
}

-(void)startDelayedRecording:(NSTimeInterval)delayTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(self.continueRunning){
            [self setMessage:[ResponseManager getMessage:@"VERIFY" variable:self.thePhrase]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(self.continueRunning){
                    [self startRecording];
                }
            });
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.greenColor = [UIColor colorWithRed:39.0f/255.0f
                                  green:174.0f/255.0f
                                   blue:96.0f/255.0f
                                  alpha:1.0f];
    self.successfulChallengesCounter = 0;
    self.currentChallenge = -1;
    self.okResponseCodes = [[NSMutableArray alloc] initWithObjects:@"FNFD",  nil];
    self.myVoiceIt = (VoiceItAPITwo *) [self voiceItMaster];
    // Initialize Boolean and All
    self.lookingIntoCam = NO;
    self.livenessDetectionIsHappening  = NO;
    self.continueRunning = YES;
    self.smileFound = NO;
    self.lookingIntoCamCounter = 0;
    self.smileCounter = 0;
    self.blinkCounter = 0;
    self.faceDirection = -2;
    self.blinkState = -1;
    self.failCounter = 0;
    
    // Do any additional setup after loading the view.
    [self.progressView setHidden:YES];
    
    // Set up the AVCapture Session
    [self setupCaptureSession];
    [self setupVideoProcessing];
    
    // Initialize the face detector.
    NSDictionary *options = @{
                              GMVDetectorFaceMinSize : @(0.3),
                              GMVDetectorFaceTrackingEnabled : @(YES),
                              GMVDetectorFaceClassificationType : @(GMVDetectorFaceClassificationAll),
                              GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll),
                              GMVDetectorFaceMode : @(GMVDetectorFaceAccurateMode)
                              };
    self.faceDetector = [GMVDetector detectorOfType:GMVDetectorTypeFace options:options];
    [self setupScreen];
}

-(void)startTimer:(float)seconds {
    self.timer = [NSTimer scheduledTimerWithTimeInterval: seconds
                                              target:self
                                            selector:@selector(timerDone)
                                            userInfo:nil
                                             repeats:NO];
}

-(void)stopTimer{
    [self.timer invalidate];
}

-(void)livenessFailedAction{
    [self stopTimer];
    self.continueRunning = NO;
    self.lookingIntoCam = NO;
    [self setMessage:@"Sorry! Face Verification Failed"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated: YES completion:^{
            NSError *error;
            NSMutableDictionary * jsonResponse = [[NSMutableDictionary alloc] init];
            [jsonResponse setObject:@"LDFA" forKey:@"responseCode"];
            [jsonResponse setObject:@"Liveness detection failed" forKey:@"message"];
            [jsonResponse setObject:@0.0 forKey:@"voiceConfidence"];
            [jsonResponse setObject:@0.0 forKey:@"faceConfidence"];
            [jsonResponse setObject:@"Liveness detection failed" forKey:@"message"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject: jsonResponse options:0 error:&error];
            if (! jsonData) {
                NSLog(@"Got an error: %@", error);
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self userVerificationFailed]( 0.0, 0.0, jsonString);
            }
        }];
    });
}

-(void)timerDone{
    [self livenessFailedAction];
}

-(void)setupScreen {
    // Setup Awesome Transparent Background and radius for Verification Box
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:0];
    } else {
        [[self view] setBackgroundColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:0.6]];
    }
    [[self.verificationBox layer] setCornerRadius:10.0];
    [self setBottomCornersForCancelButton];
    [self setupCameraCircle];
}

- (void)cleanupCaptureSession {
    [self.captureSession stopRunning];
    [self cleanupVideoProcessing];
    self.captureSession = nil;
    [self.previewLayer removeFromSuperlayer];
}

- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.captureSession removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
}

- (void)setupVideoProcessing {
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *rgbOutputSettings = @{
                                        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
                                        };
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    
    if (![self.captureSession canAddOutput:self.videoDataOutput]) {
        [self cleanupVideoProcessing];
        NSLog(@"Failed to setup video output");
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.captureSession addOutput:self.videoDataOutput];
}

- (IBAction)cancelClicked:(id)sender {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.continueRunning = NO;
    [self setAudioSessionInactive];
    [self cleanupCaptureSession];
    [self dismissViewControllerAnimated:YES completion:^{
        [self userVerificationCancelled]();
    }];
}

-(void)setMessage:(NSString *) newMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageLabel setText: newMessage];
        [self.messageLabel setAdjustsFontSizeToFitWidth:YES];
    });
}

-(void)setBottomCornersForCancelButton{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.cancelButton.bounds byRoundingCorners:( UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.cancelButton.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.cancelButton.layer.mask = maskLayer;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.progressView startAnimation];
    [self.messageLabel setText: [ResponseManager getMessage:@"LOOK_INTO_CAM"]];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
    [self cleanupCaptureSession];
    [super viewDidDisappear:animated];
}


-(void)setupCaptureSession{
    // Setup Video Input Devices
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    [self.captureSession setSessionPreset: AVCaptureSessionPresetMedium];
    self.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSError * videoError;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: self.videoDevice error:&videoError];
    [self.captureSession addInput:videoInput];
}

-(void)setupCameraCircle{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //    [self.captureSession addOutput:self.movieFileOutput];
    // Setup code to capture face meta data
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [self.captureSession addOutput: metadataOutput];
    // We're only interested in faces
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    // This VC is the delegate. Please call us on the main queue
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Setup Little Camera Circle and Positions
    CALayer *rootLayer = [[self verificationBox] layer];
    self.backgroundWidthHeight = (CGFloat) [self verificationBox].frame.size.height  * 0.50;
    CGFloat cameraViewWidthHeight = (CGFloat) [self verificationBox].frame.size.height  * 0.48;
    self.circleWidth = (self.backgroundWidthHeight - cameraViewWidthHeight) / 2;
    CGFloat backgroundViewX = ([self verificationBox].frame.size.width - self.backgroundWidthHeight)/2;
    CGFloat cameraViewX = ([self verificationBox].frame.size.width - cameraViewWidthHeight)/2;
    CGFloat backgroundViewY = 30.0; // TODO: Make this number a constant
    CGFloat cameraViewY = backgroundViewY + self.circleWidth;
    
    self.cameraBorderLayer = [[CALayer alloc] init];
    self.leftCircle = [CAShapeLayer layer];
    self.rightCircle = [CAShapeLayer layer];
    self.downCircle = [CAShapeLayer layer];
    self.upCircle = [CAShapeLayer layer];
    self.progressCircle = [CAShapeLayer layer];
    
    [self.cameraBorderLayer setFrame:CGRectMake(backgroundViewX, backgroundViewY, self.backgroundWidthHeight, self.backgroundWidthHeight)];
    [self.previewLayer setFrame:CGRectMake(cameraViewX, cameraViewY, cameraViewWidthHeight, cameraViewWidthHeight)];
    [self.previewLayer setCornerRadius: cameraViewWidthHeight / 2];
    self.cameraCenterPoint = CGPointMake(self.cameraBorderLayer.frame.origin.x + (self.backgroundWidthHeight/2), self.cameraBorderLayer.frame.origin.y + (self.backgroundWidthHeight/2) );
    
    if ([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        CGPoint autofocusPoint = self.cameraCenterPoint;
        [self.videoDevice setFocusPointOfInterest:autofocusPoint];
        [self.videoDevice setFocusMode:AVCaptureFocusModeLocked];
    }
    
    self.leftCircle.path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(self.backgroundWidthHeight / 2) startAngle: 0.75 * M_PI endAngle: 1.25 * M_PI clockwise:YES].CGPath;
    self.leftCircle.fillColor =  [UIColor clearColor].CGColor;
    self.leftCircle.strokeColor = [UIColor clearColor].CGColor;
    self.leftCircle.lineWidth = self.circleWidth + 8.0;
    
    self.rightCircle.path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(self.backgroundWidthHeight / 2) startAngle: 1.75 * M_PI endAngle: 0.25 * M_PI clockwise:YES].CGPath;
    self.rightCircle.fillColor =  [UIColor clearColor].CGColor;
    self.rightCircle.strokeColor = [UIColor clearColor].CGColor;
    self.rightCircle.lineWidth = self.circleWidth + 8.0;
    
    self.downCircle.path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(self.backgroundWidthHeight / 2) startAngle: 0.75 * M_PI endAngle: 0.25 * M_PI clockwise:NO].CGPath;
    self.downCircle.fillColor =  [UIColor clearColor].CGColor;
    self.downCircle.strokeColor = [UIColor clearColor].CGColor;
    self.downCircle.lineWidth = self.circleWidth + 8.0;
    
    self.upCircle.path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(self.backgroundWidthHeight / 2) startAngle: 1.25 * M_PI endAngle: 1.75 * M_PI clockwise:YES].CGPath;
    self.upCircle.fillColor =  [UIColor clearColor].CGColor;
    self.upCircle.strokeColor = [UIColor clearColor].CGColor;
    self.upCircle.lineWidth = self.circleWidth + 8.0;
    
    // Setup Progress Circle
    self.progressCircle .path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(self.backgroundWidthHeight / 2) startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
    self.progressCircle.fillColor = [UIColor clearColor].CGColor;
    self.progressCircle.strokeColor = [UIColor clearColor].CGColor;
    self.progressCircle.lineWidth = self.circleWidth + 8.0;
    
    [self.cameraBorderLayer setBackgroundColor: [UIColor clearColor].CGColor];
    self.cameraBorderLayer.cornerRadius = self.backgroundWidthHeight / 2;
    
    // Setup Rectangle Around Face
    self.faceRectangleLayer = [[CALayer alloc] init];
    self.faceRectangleLayer.zPosition = 1;
    self.faceRectangleLayer.borderColor = [Styles getMainCGColor];
    self.faceRectangleLayer.borderWidth  = 4.0;
    self.faceRectangleLayer.opacity = 0.7;
    [self.faceRectangleLayer setHidden:YES];
    
    [rootLayer addSublayer:self.cameraBorderLayer];
    [rootLayer addSublayer:self.leftCircle];
    [rootLayer addSublayer:self.rightCircle];
    [rootLayer addSublayer:self.downCircle];
    [rootLayer addSublayer:self.upCircle];
    [rootLayer addSublayer:self.progressCircle];
    [rootLayer addSublayer:self.previewLayer];
    [self.previewLayer addSublayer:self.faceRectangleLayer];
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}

-(void)animateProgressCircle {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressCircle.strokeColor = [Styles getMainCGColor];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 5;
        animation.removedOnCompletion = YES;//NO;
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.progressCircle addAnimation:animation forKey:@"drawCircleAnimation"];
    });
}

-(void)showGreenCircleLeftUnfilled{
    self.leftCircle.strokeColor =  self.greenColor.CGColor;
    self.leftCircle.opacity = 0.3;
}

-(void)showGreenCircleRightUnfilled{
    self.rightCircle.strokeColor =  self.greenColor.CGColor;
    self.rightCircle.opacity = 0.3;
}

-(void)showGreenCircleLeft:(BOOL) showCircle{
    self.leftCircle.opacity = 1.0;
    if(showCircle){
        self.leftCircle.strokeColor = self.greenColor.CGColor;
    } else {
        self.leftCircle.strokeColor = [UIColor clearColor].CGColor;
    }
}

-(void)showGreenCircleRight:(BOOL) showCircle{
    self.rightCircle.opacity = 1.0;
    if(showCircle){
        self.rightCircle.strokeColor = self.greenColor.CGColor;
    } else {
        self.rightCircle.strokeColor = [UIColor clearColor].CGColor;
    }
}

-(void)startRecording {
    NSLog(@"Starting RECORDING");
    self.isRecording = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    if (err)
    {
        NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    err = nil;
    if (err)
    {
        NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    
    // Unique recording URL
    NSString *fileName = @"OriginalFile"; // Changed it So It Keeps Replacing File
    self.audioPath = [NSTemporaryDirectory()
                  stringByAppendingPathComponent:[NSString
                                                  stringWithFormat:@"%@.wav", fileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.audioPath
                                                   error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:self.audioPath];
    err = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[Utilities getRecordingSettings] error:&err];
    if(!self.audioRecorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [self.audioRecorder setDelegate:self];
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder recordForDuration:4.8];
    
    // Start Progress Circle Around Face Animation
    [self animateProgressCircle];
}

-(void)stopRecording{
    self.isRecording = NO;
    self.progressCircle.strokeColor = [UIColor clearColor].CGColor;
}

// Code to Capture Face Rectangle and other cool metadata stuff
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    BOOL faceFound = NO;
    for(AVMetadataObject *metadataObject in metadataObjects) {
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeFace]) {
            [self.faceRectangleLayer setHidden:NO];
            faceFound = YES;
            AVMetadataObject * face = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            self.faceRectangleLayer.frame = face.bounds;
            self.faceRectangleLayer.cornerRadius = 10.0;
        }
    }
    
    if(faceFound) {
        if (self.lookingIntoCamCounter > VIDEO_VERIFICATION_TIME_TO_WAIT_TILL_FACE_FOUND && !self.lookingIntoCam && !self.livenessDetectionIsHappening) {
            self.lookingIntoCam = YES;
            self.livenessDetectionIsHappening = YES;
            [self startLivenessDetection];
        }
        self.lookingIntoCamCounter += 1;
    } else if (!self.livenessDetectionIsHappening){
        [self setMessage: [ResponseManager getMessage:@"LOOK_INTO_CAM"]];
        self.lookingIntoCam = NO;
        self.lookingIntoCamCounter = 0;
        [self.faceRectangleLayer setHidden:YES];
    } else {
        self.lookingIntoCam = NO;
        self.lookingIntoCamCounter = 0;
        [self.faceRectangleLayer setHidden:YES];
    }
}

-(void)setupLivenessDetection{
    // TODO: Put all liveness detection setup into one method
    self.lookingIntoCam = YES;
    [self showGreenCircleLeft:NO];
    [self showGreenCircleRight:NO];
    self.blinkCounter = 0;
    self.smileFound = NO;
    self.smileCounter = 0;
    self.faceDirection = -2;
    self.blinkState = -1;
}

-(void)startLivenessDetection {
    if(self.successfulChallengesCounter >= 2){
        self.lookingIntoCam = NO;
        [self showGreenCircleLeft:NO];
        [self showGreenCircleRight:NO];
        [self startVerificationProcess];
        return;
    }
    
    self.currentChallenge = [self pickChallenge];
    //    self.currentChallenge = 5;
    NSLog(@"Current Challenge %d", self.currentChallenge);
    [self setupLivenessDetection];
    
    // TODO: Continue putting more logic here.
    switch (self.currentChallenge) {
        case 0:
            //SMILE
            [self setMessage:@"Please smile into the camera"];
            [self startTimer:2.5];
            break;
        case 1:
            //Blink
            [self setMessage:@"Please blink three times into the camera"];
            [self startTimer:3.0];
            break;
        case 2:
            //Move head left
            [self setMessage:@"Please Turn your face to the left"];
            [self startTimer:2.5];
            [self showGreenCircleLeftUnfilled];
            break;
        case 3:
            //Move head right
            [self setMessage:@"Please Turn your face to the right"];
            [self startTimer:2.5];
            [self showGreenCircleRightUnfilled];
            break;
        default:
            break;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)livenessChallengePassed {
    self.successfulChallengesCounter++;
    self.lookingIntoCam = NO;
    [self.messageLabel setText:@"Perfect! You got it"];
    [self stopTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(self.continueRunning){
            [self startLivenessDetection];
        }
        
    });
}

-(void)doSmileDetection:(GMVFaceFeature *)face image:(UIImage *) image {
    if(face.hasSmilingProbability){
        if(face.smilingProbability > 0.85){
            NSLog(@"\nSMILING\n");
            self.smileCounter++;
        } else {
            NSLog(@"NOT SMILING\n");
            self.smileCounter = -1;
        }
    }
    
    if(self.smileCounter > 5){
        if(!self.smileFound){
            self.smileFound = YES;
            [self saveImageData:image];
            [self livenessChallengePassed];
        }
    }
    
    if(self.smileCounter == -1){
        if(self.smileFound){
            //            [self.messageLabel setText:@"I don't see you smiling"];
            self.smileFound = NO;
        }
    }
}

-(void)doBlinkDetection:(GMVFaceFeature *)face image:(UIImage *) image {
    if(face.hasLeftEyeOpenProbability && face.hasRightEyeOpenProbability){
        if(face.leftEyeOpenProbability > 0.8 && face.rightEyeOpenProbability > 0.8){
            if(self.blinkState == -1) { self.blinkState = 0; }
            if(self.blinkState == 1) {
                self.blinkState = -1;
                self.blinkCounter++;
                if(self.blinkCounter == 3){
                    [self saveImageData:image];
                    [self livenessChallengePassed];
                } else {
                    [self.messageLabel setText: [NSString stringWithFormat:@"Blink %d", self.blinkCounter]];
                }
            }
        }
        if(face.leftEyeOpenProbability < 0.4 && face.rightEyeOpenProbability < 0.4){
            if(self.blinkState == 0) { self.blinkState = 1; }
        }
    }
    
}

-(void)moveHeadLeftDetection:(GMVFaceFeature *)face image:(UIImage *) image {
    if(face.hasHeadEulerAngleY && face.hasHeadEulerAngleZ){
        NSLog(@"Face angle y %f", face.headEulerAngleY);
        NSLog(@"Face angle z %f", face.headEulerAngleZ);
        if( (face.headEulerAngleY > 18.0)){
            self.faceDirection = 1;
            [self showGreenCircleLeftUnfilled];
            [self livenessFailedAction];
        }
        else if(face.headEulerAngleY < - 18.0){
            NSLog(@"Head Facing Left Side : %f", face.headEulerAngleY);
            if(self.faceDirection != -1){
                [self showGreenCircleLeft:YES];
                [self livenessChallengePassed];
                self.faceDirection = -1;
            }
        } else {
            NSLog(@"Head Facing Straight On : %f", face.headEulerAngleY);
            if(self.faceDirection != 0){
                self.faceDirection = 0;
                [self saveImageData:image];
                [self showGreenCircleLeftUnfilled];
            }
        }
    }
}

-(void)moveHeadRightDetection:(GMVFaceFeature *)face image:(UIImage *) image {
    NSLog(@"Face angle y %f", face.headEulerAngleY);
    if(face.hasHeadEulerAngleY && face.hasHeadEulerAngleZ){
        if( (face.headEulerAngleY > 18.0)){
            [self showGreenCircleRight:YES];
            [self livenessChallengePassed];
            self.faceDirection = 1;
        }  else if(face.headEulerAngleY < - 18.0){
            NSLog(@"Head Facing Left Side : %f", face.headEulerAngleY);
            if(self.faceDirection != -1){
                self.faceDirection = -1;
                [self showGreenCircleRightUnfilled];
                [self livenessFailedAction];
            }
        } else {
            NSLog(@"Head Facing Straight On : %f", face.headEulerAngleY);
            if(self.faceDirection != 0){
                self.faceDirection = 0;
                [self saveImageData:image];
                [self showGreenCircleRightUnfilled];
            }
        }
    }
    
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    // Don't do any analysis when not looking into the camera
    if(!self.lookingIntoCam){
        return;
    }
    
    UIImage *image = [GMVUtility sampleBufferTo32RGBA:sampleBuffer];

    // Establish the image orientation.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:AVCaptureDevicePositionFront
                                       defaultDeviceOrientation:deviceOrientation];
    NSDictionary *options = @{GMVDetectorImageOrientation : @(orientation)};
    // Detect features using GMVDetector.
    NSArray<GMVFaceFeature *> *faces = [self.faceDetector featuresInImage:image options:options];
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // Display detected features in overlay.
        for (GMVFaceFeature *face in faces) {
            
            switch (self.currentChallenge) {
                case 0:
                    // SMILE
                    [self doSmileDetection:face image:image];
                    break;
                case 1:
                    // Do Blink Detection
                    [self doBlinkDetection:face image:image];
                    break;
                case 2:
                    //Move head left
                    [self moveHeadLeftDetection:face image:image];
                    break;
                case 3:
                    //Move head right
                    [self moveHeadRightDetection:face image:image];
                    break;
                default:
                    break;
            }
        }
    });
}

-(void)saveImageData:(UIImage *)image{
    if ( image != nil){
        self.finalCapturedPhotoData  = UIImageJPEGRepresentation(image, 0.8);
    }
}

-(void)showLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setHidden:NO];
        [self setMessage:@""];
    });
}

-(void)removeLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setHidden:YES];
    });
}


-(void)setAudioSessionInactive{
    [self.audioRecorder stop];
    NSError * err;
    [self.audioSession setActive:NO error:&err];
}

#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"AUDIO RECORDED FINISHED SUCCESS = %d", flag);
    [self setAudioSessionInactive];
    [self stopRecording];
    [self showLoading];
    [self.myVoiceIt videoVerification:self.userToVerifyUserId contentLanguage: self.contentLanguage imageData:self.finalCapturedPhotoData audioPath:self.audioPath callback:^(NSString * jsonResponse){
            [self removeLoading];
            NSLog(@"Video Verification JSON Response : %@", jsonResponse);
            NSDictionary *jsonObj = [Utilities getJSONObject:jsonResponse];
            NSLog(@"Response Code is %@ and message is : %@", [jsonObj objectForKey:@"responseCode"], [jsonObj objectForKey:@"message"]);
            NSString * responseCode = [jsonObj objectForKey:@"responseCode"];
            
            if([responseCode isEqualToString:@"SUCC"]){
                [self setMessage:[ResponseManager getMessage:@"SUCCESS"]];
                float faceConfidence = [[jsonObj objectForKey:@"faceConfidence"] floatValue];
                float voiceConfidence = [[jsonObj objectForKey:@"voiceConfidence"] floatValue];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated: YES completion:^{
                        [self userVerificationSuccessful](faceConfidence, voiceConfidence, jsonResponse);
                    }];
                });
            } else {
                if(![self.okResponseCodes containsObject:responseCode]){
                    self.failCounter += 1;
                }
                
                if(self.failCounter < 3){
                    if([responseCode isEqualToString:@"STTF"]){
                        [self setMessage:[ResponseManager getMessage: responseCode variable:self.thePhrase]];
                        [self startDelayedRecording:3.0];
                    }
                    else if ([responseCode isEqualToString:@"TVER"]){
                        [self setMessage:[ResponseManager getMessage: responseCode]];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated: YES completion:^{
                                [self userVerificationFailed](0.0, 0.0, jsonResponse);
                            }];
                        });
                    }else{
                        [self setMessage:[ResponseManager getMessage: responseCode]];
                        [self startDelayedRecording:3.0];
                    }
                } else {
                    [self setMessage:[ResponseManager getMessage: @"TOO_MANY_ATTEMPTS"]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        float faceConfidence = [[jsonObj objectForKey:@"faceConfidence"] floatValue];
                        float voiceConfidence = [[jsonObj objectForKey:@"voiceConfidence"] floatValue];
                        [self dismissViewControllerAnimated: YES completion:^{
                            [self userVerificationFailed](faceConfidence, voiceConfidence, jsonResponse);
                        }];
                    });
                }
            }
        }];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"fail because %@", error.localizedDescription);
}

@end

