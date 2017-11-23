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

- (BOOL) isEqual:(App*)object;

- (Window*) mainWindow;
- (NSArray<Window*>*) allWindows;
- (NSArray<Window*>*) visibleWindows;

- (NSString*) title;
- (NSString*) bundleID;
- (pid_t) pid;
- (NSString*) kind;

- (BOOL) launchOrFocus:(NSString*)name;
- (BOOL) activate:(BOOL)allWindows;

- (BOOL) unhide;
- (BOOL) hide;

- (void) kill;
- (void) forceKill;

- (BOOL) isHidden;
- (BOOL) isUnresponsive;

@end

@interface App : NSObject <JSExport_App>
@end
