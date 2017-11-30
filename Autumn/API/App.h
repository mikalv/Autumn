//
//  App.h
//  Autumn
//
//  Created by Steven Degutis on 11/15/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class Window;
@class App;

@protocol JSExport_App <JSExport>

+ (App*) appForPid:(pid_t)pid;
+ (NSArray<App*>*) appsForBundleID:(NSString*)bundleIdentifier;
+ (NSArray<App*>*) runningApps;

- (NSNumber*) equals:(App*)other;

- (Window*) mainWindow;
- (NSArray<Window*>*) allWindows;
- (NSArray<Window*>*) visibleWindows;

- (NSString*) title;
- (NSString*) bundleID;
- (pid_t) pid;
- (NSString*) kind;

+ (void) open:(NSString*)name;
- (void) activate:(BOOL)allWindows;

- (void) unhide;
- (void) hide;

- (void) kill;
- (void) forceKill;

- (NSNumber*) isHidden;
- (NSNumber*) isUnresponsive;

@end

@interface App : NSObject <JSExport_App>

- (BOOL) internal_bringToFront:(BOOL)allWindows;

@end
