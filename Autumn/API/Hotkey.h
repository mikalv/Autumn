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

JSExportAs(bind,
           + (Hotkey*) bind:(NSNumber*)mods key:(NSString*)key callback:(JSValue*)callback
           );

- (NSNumber*) enable;
- (void) disable;

- (NSNumber*) equals:(Hotkey*)other;

@end

@interface Hotkey : NSObject <JSExport_Hotkey>

+ (void) setupWithJS;
+ (void) setupOnce;
+ (void) reset;

@end
