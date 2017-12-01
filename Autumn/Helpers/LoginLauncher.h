//
//  LoginLauncher.h
//  Autumn
//
//  Created by Steven Degutis on 11/30/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginLauncher : NSObject

+ (BOOL) isEnabled;
+ (void) setEnabled:(BOOL)opensAtLogin;

@end
