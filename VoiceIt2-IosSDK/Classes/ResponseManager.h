//
//  ResponseManager.h
//  VoiceIt2-IosSDK
//
//  Created by VoiceIt Technologies, LLC
//  Copyright (c) 2020 VoiceIt Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseManager : NSObject
+(NSString *)getMessage:(NSString*) name contentLanguage:(NSString*)contentLanguage;

+(NSString *)getMessage:(NSString*) name
    contentLanguage:(NSString*)contentLanguage
    variable:(NSString*)variable;
@end
