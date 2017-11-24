//
//  Autumn.h
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSExport_Autumn <JSExport>

+ (void) quit;
+ (void) reloadConfigs;
+ (void) showDocs;
+ (void) showRepl;

@end

@interface Autumn : NSObject <JSExport_Autumn>

@end
