//
//  Autumn.h
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Module.h"

@protocol JSExport_Core <JSExport>

+ (void) quit;
+ (void) reloadConfigs;
+ (void) showDocs;
+ (void) showRepl;

+ (JSValue*) loadFile:(NSString*)path;

@end

@interface Core : NSObject <JSExport_Core, Module>

@end
