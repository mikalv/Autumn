//
//  Hotkey.h
//  Autumn
//
//  Created by Steven Degutis on 11/21/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class Hotkey;

@protocol JSExport_Hotkey <JSExport>

- (instancetype) initWithMap:(JSValue*)spec;
- (BOOL) enable;
- (void) disable;

@end

@interface Hotkey : NSObject <JSExport_Hotkey>

+ (void) setup;
+ (void) resetHandlers;

@end
