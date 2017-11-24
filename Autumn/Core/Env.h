//
//  Env.h
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Env : NSObject

+ (void) setupOnce;
+ (void) reset;

@end
