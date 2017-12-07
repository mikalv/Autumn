//
//  Module.h
//  Autumn
//
//  Created by Steven Degutis on 12/7/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#ifndef Module_h
#define Module_h

#import <JavaScriptCore/JavaScriptCore.h>

@protocol Module <NSObject>

+ (void) startModule:(JSValue*)ctor;
+ (void) stopModule;

@end

#endif /* Module_h */
