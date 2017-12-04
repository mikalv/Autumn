//
//  Keycodes.h
//  Autumn
//
//  Created by Steven Degutis on 11/22/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSExport_Keyboard <JSExport>

+ (void) setLayoutChangedCallback:(JSValue*)fn;

@end

@interface Keyboard : NSObject <JSExport_Keyboard>

+ (void) setupOnce;
+ (void) reset;
+ (NSDictionary<NSString*, NSNumber*>*) keyCodes;

@end
