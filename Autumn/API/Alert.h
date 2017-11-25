//
//  Alert.h
//  Autumn
//
//  Created by Steven Degutis on 11/23/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSExport_Alert <JSExport>

JSExportAs(show, + (void) show:(NSString*)oneLineMsg options:(JSValue*)options);

@end

@interface Alert : NSWindowController <NSWindowDelegate, JSExport_Alert>

+ (void) show:(NSString*)oneLineMsg
     duration:(NSNumber*)duration;

@end