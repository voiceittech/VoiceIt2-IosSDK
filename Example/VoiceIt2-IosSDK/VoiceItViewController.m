//
//  VoiceItViewController.m
//  VoiceIt2-IosSDK
//
//  Created by VoiceIt Technologies, LLC
//  Copyright (c) 2020 VoiceIt Technologies, LLC. All rights reserved.
//

#import "VoiceItViewController.h"
#import "VoiceItAPITwo.h"
@interface VoiceItViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *userPickerView;
@end

@implementation VoiceItViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.API_KEY = @"key_204413831ca34dc7a692338260eb41ea";
    self.API_TOKEN = @"tok_b855f16643e74b88b2dc50d8b681d4e2";
    self.TEST_USER_ID_ONE = @"usr_9cbc25ed62404792b5d496fe2a1b01d6";
    self.TEST_USER_ID_TWO = @"USER_ID_HERE";
    self.TEST_USER_ID = self.TEST_USER_ID_ONE;
    self.TEST_GROUP_ID = @"GROUP_ID_HERE";
    self.TEST_PHRASE = @"never forget tomorrow is a new day";
    self.TEST_CONTENT_LANGUAGE = @"es-MX";

    NSMutableDictionary * styles = [[NSMutableDictionary alloc] init];
    [styles setObject:@"#FBC132" forKey:@"kThemeColor"];
    [styles setObject:@"default" forKey:@"kIconStyle"];
    self.myVoiceIt  = [[VoiceItAPITwo alloc] init:self apiKey: self.API_KEY apiToken: self.API_TOKEN styles:styles];
    self.userPickerView.delegate = self;
    self.userPickerView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)voiceEnrollmentClicked:(id)sender {
    [self.myVoiceIt encapsulatedVoiceEnrollUser: self.TEST_USER_ID contentLanguage:self.TEST_CONTENT_LANGUAGE voicePrintPhrase:self.TEST_PHRASE userEnrollmentsCancelled:^{
        NSLog(@"User Voice Enrollments Cancelled");
    } userEnrollmentsPassed:^(NSString * response){
        NSLog(@"User Voice Enrollments Completed with response: %@",response);
    }];
}

- (IBAction) faceEnrollmentClicked:(id)sender {
    [self.myVoiceIt encapsulatedFaceEnrollUser: self.TEST_USER_ID
                    contentLanguage:self.TEST_CONTENT_LANGUAGE
                      userEnrollmentsCancelled:^{
        NSLog(@"User Face Enrollments Cancelled");
    } userEnrollmentsPassed:^(NSString * response){
        NSLog(@"User Face Enrollments Completed with response: %@",response);
    }];
}

- (IBAction)videoEnrollmentClicked:(id)sender {
    [self.myVoiceIt encapsulatedVideoEnrollUser: self.TEST_USER_ID contentLanguage:self.TEST_CONTENT_LANGUAGE voicePrintPhrase:self.TEST_PHRASE userEnrollmentsCancelled:^{
        NSLog(@"User Video Enrollments Cancelled");
    } userEnrollmentsPassed:^(NSString * response){
        NSLog(@"User Video Enrollments Completed with response: %@",response);
    }];
}

- (IBAction)voiceVerificationClicked:(id)sender {
    [self.myVoiceIt encapsulatedVoiceVerification:self.TEST_USER_ID
                                  contentLanguage:self.TEST_CONTENT_LANGUAGE
                                 voicePrintPhrase:self.TEST_PHRASE
    userVerificationCancelled:^{
        NSLog(@"User Voice Verication Cancelled");
    } userVerificationSuccessful:^(float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Voice Verication Successful voiceConfidence : %g ",voiceConfidence);
    } userVerificationFailed:^(float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Voice Verication Failed voiceConfidence : %g",voiceConfidence);
    }];
}

- (IBAction)voiceIdentificationClicked:(id)sender {
    NSLog(@"VOICE IDENTIFICATION CLICKED");
    [self.myVoiceIt encapsulatedVoiceIdentification:self.TEST_GROUP_ID
                                    contentLanguage:self.TEST_CONTENT_LANGUAGE
                                   voicePrintPhrase:self.TEST_PHRASE
    userIdentificationCancelled:^{
        NSLog(@"User Voice Identification Cancelled");
    } userIdentificationSuccessful:^(float voiceConfidence , NSString * foundUserId, NSString * jsonResponse){
        NSLog(@"User Voice Identification Successful voiceConfidence : %g and RESPONSE : %@", voiceConfidence, jsonResponse);
        [self showAlert:[[NSString alloc] initWithFormat:@"Succesfully identified user : %@ with voiceConfidence %g", foundUserId, voiceConfidence]];
        NSLog(@"Found user %@", foundUserId);
    } userIdentificationFailed:^(float voiceConfidence , NSString * jsonResponse){
        NSLog(@"User Voice Identification Failed voiceConfidence : %g and RESPONSE : %@", voiceConfidence, jsonResponse);
    }];
}

- (IBAction)faceVerificationClicked:(id)sender {
    [self.myVoiceIt encapsulatedFaceVerification:self.TEST_USER_ID
                             doLivenessDetection:self.livenessToggle.isOn
                                  doAudioPrompts:self.audioPromptsToggle.isOn
                                 contentLanguage:self.TEST_CONTENT_LANGUAGE
    userVerificationCancelled:^{
        NSLog(@"User Face Verification Cancelled");
    } userVerificationSuccessful:^(float faceConfidence , NSString * jsonResponse){
        NSLog(@"User Face Verication Successful faceConfidence : %g and RESPONSE : %@", faceConfidence, jsonResponse);
    } userVerificationFailed:^(float faceConfidence , NSString * jsonResponse){
        NSLog(@"User Face Verication Failed faceConfidence : %g and RESPONSE : %@", faceConfidence, jsonResponse);
    }];
}

- (IBAction)videoVerificationClicked:(id)sender {
    [self.myVoiceIt encapsulatedVideoVerification:self.TEST_USER_ID
                                  contentLanguage:self.TEST_CONTENT_LANGUAGE
                                 voicePrintPhrase:self.TEST_PHRASE
                              doLivenessDetection:self.livenessToggle.isOn
                                   doAudioPrompts:self.audioPromptsToggle.isOn
    userVerificationCancelled:^{
         NSLog(@"User Verication Cancelled");
    } userVerificationSuccessful:^(float faceConfidence ,float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Verication Successful voiceConfidence : %g , faceConfidence : %g",voiceConfidence, faceConfidence);
    } userVerificationFailed:^(float faceConfidence ,float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Verication Failed voiceConfidence : %g , faceConfidence : %g",voiceConfidence, faceConfidence);
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row == 0){
        return self.TEST_USER_ID_ONE;
    }
    if(row == 1){
        return self.TEST_USER_ID_TWO;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(row == 0){
        self.TEST_USER_ID = self.TEST_USER_ID_ONE;
    }
    if(row == 1){
        self.TEST_USER_ID = self.TEST_USER_ID_TWO;
    }
}

-(void)showAlert:(NSString *) alertMessage {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                   message:alertMessage
   preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    if([self.TEST_USER_ID isEqualToString:@"USER_ID_HERE"]){
        [self showAlert:@"Please replace variables under VoiceItViewController.m with your credentials, groupId and userIds"];
    }
}
@end
