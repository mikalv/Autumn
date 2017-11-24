//
//  JavaScriptBridge.h
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JavaScriptBridge : NSObject

+ (void) reset;
+ (void) runConfig;
+ (NSString*) runString:(NSString*)str;

@end
