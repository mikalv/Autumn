//
//  Keycodes.h
//  Autumn
//
//  Created by Steven Degutis on 11/22/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSExport_Keycodes <JSExport>

+ (void) setInputSourceChangedHandler:(JSValue*)fn;

@end

@interface Keycodes : NSObject <JSExport_Keycodes>

+ (void) setupOnce;
+ (void) reset;
+ (NSDictionary<NSString*, NSNumber*>*) map;

@end
