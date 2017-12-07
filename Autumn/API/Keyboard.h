//
//  Keycodes.h
//  Autumn
//
//  Created by Steven Degutis on 11/22/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"

@protocol JSExport_Keyboard <JSExport>

+ (void) setLayoutChangedCallback:(JSValue*)fn;

@end

@interface Keyboard : NSObject <JSExport_Keyboard, Module>

+ (NSDictionary<NSString*, NSNumber*>*) keyCodes;

@end
