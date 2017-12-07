//
//  Env.h
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JS.h"

@interface Env : NSObject

+ (void) reset;

@property (class, readonly) Env* current;

@property (readonly) JS* js;

@end
