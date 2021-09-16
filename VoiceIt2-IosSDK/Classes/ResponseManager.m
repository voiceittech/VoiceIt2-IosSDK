//
//  ResponseManager.m
//  VoiceIt2-IosSDK
//
//  Created by VoiceIt Technologies, LLC
//  Copyright (c) 2020 VoiceIt Technologies, LLC. All rights reserved.
//

#import "ResponseManager.h"

@implementation ResponseManager

+(NSString *)getMessage:(NSString*) name contentLanguage:(NSString*)contentLanguage {
    NSBundle * podBundle = [NSBundle bundleForClass: self.classForCoder];
    NSURL * bundleURL = [[podBundle resourceURL] URLByAppendingPathComponent:@"VoiceIt2-IosSDK.bundle"];
    NSBundle  * bundle = [[NSBundle alloc] initWithURL:bundleURL];
    //check for es-mx es-.......
    NSString * finalString = @"";
    if ([contentLanguage containsString:@"es-"]) {
        finalString = NSLocalizedStringFromTableInBundle(name, @"Prompts_es", bundle, nil);
    } else {
        finalString = NSLocalizedStringFromTableInBundle(name, @"Prompts_en", bundle, nil);
    }
    return finalString;
}

+(NSString *)getMessage:(NSString*) name                         contentLanguage:(NSString*)contentLanguage
    variable:(NSString*)variable{
    NSBundle * podBundle = [NSBundle bundleForClass: self.classForCoder];
    NSURL * bundleURL = [[podBundle resourceURL] URLByAppendingPathComponent:@"VoiceIt2-IosSDK.bundle"];
    NSBundle  * bundle = [[NSBundle alloc] initWithURL:bundleURL];
    //check for es-mx es-.......
    NSString * finalString = @"";
    if ([contentLanguage containsString:@"es-"]) {
        finalString = [[NSString alloc] initWithFormat: NSLocalizedStringFromTableInBundle(name, @"Prompts_es", bundle, nil) ,variable];
    } else {
        finalString = [[NSString alloc] initWithFormat: NSLocalizedStringFromTableInBundle(name, @"Prompts_en", bundle, nil) ,variable];
    }
    return finalString;
}
@end
