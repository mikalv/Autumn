//
//  JavaScriptBridge.h
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JS : NSObject

+ (void) runConfig;
+ (NSString*) runString:(NSString*)str;
+ (void) reset;

@end
