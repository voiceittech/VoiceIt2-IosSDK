//
//  VoiceItViewController.m
//  VoiceItApi2IosSDK
//
//  Created by armaanbindra on 03/23/2017.
//  Copyright (c) 2017 armaanbindra. All rights reserved.
//

#import "VoiceItViewController.h"
#import "VoiceItAPITwo.h"
@interface VoiceItViewController ()
@property VoiceItAPITwo * myVoiceIt;
@end

@implementation VoiceItViewController

- (IBAction)startClicked:(id)sender {

    NSMutableDictionary * styles = [[NSMutableDictionary alloc] init];
    [styles setObject:@"#FE0000" forKey:@"kThemeColor"];
    [styles setObject:@"monochrome" forKey:@"kIconStyle"];
    
    _myVoiceIt = [[VoiceItAPITwo alloc] init:self apiKey:@"key_4306d632525748ac987cc0385ceff339" apiToken:@"tok_c910f4047d1d425980c856bb3ca8fa5b" styles: styles];
    [_myVoiceIt encapsulatedVideoEnrollUser:@"usr_8c69320d0bdd42549f69d3d0d53ae824" contentLanguage:@"en-US" voicePrintPhrase:@"never forget tomorrow is a new day" userEnrollmentsCancelled:^{

    } userEnrollmentsPassed:^{

    }];
//    [_myVoiceIt encapsulatedVideoVerification:@"usr_8c69320d0bdd42549f69d3d0d53ae824" contentLanguage:@"en-US" voicePrintPhrase:@"never forget tomorrow is a new day" userVerificationCancelled:^{
//    } userVerificationSuccessful:^(float a, float b, NSString * result){
//
//    } userVerificationFailed:^(float a, float b, NSString * result){
//
//    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
