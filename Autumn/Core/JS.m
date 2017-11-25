//
//  JavaScriptBridge.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "JS.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Window.h"
#import "App.h"
#import "Hotkey.h"
#import "Keycodes.h"
#import "Alert.h"
#import "Autumn.h"
#import "Env.h"
#import "NotificationManager.h"
#import "ReplWindowController.h"

static JSContext* ctx;
static NSMutableArray<NSString*>* requireStack;

@implementation JS

static JSValue* loadFile(NSString* path) {
    if (![path hasSuffix: @".js"]) path = [path stringByAppendingPathExtension: @"js"];
    if (![path hasPrefix: @"/"])   path = [requireStack.lastObject.stringByDeletingLastPathComponent stringByAppendingPathComponent: path];
    path = path.stringByStandardizingPath;
    
    __autoreleasing NSError* error;
    NSString* script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!script) {
        [JS showError: [NSString stringWithFormat:@"Error loading config file: %@", path]
             location: error.localizedDescription];
        
        NSLog(@"error loading file at [%@]: %@", path, error);
        return nil;
    }
    
    [requireStack addObject: path];
    JSValue* result = [ctx evaluateScript: script];
    [requireStack removeLastObject];
    
    return result;
}

+ (void) runConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Env reset];
        loadFile(@"~/.autumnjs/init.js".stringByStandardizingPath);
    });
}

+ (NSString*) runString:(NSString*)str {
    return [ctx evaluateScript: str].toString;
}

+ (void) showError:(NSString*)errorMessage location:(NSString*)errorLocation {
    [[ReplWindowController sharedInstance] logError: errorMessage
                                           location: errorLocation];
    
    NSUserNotification* note = [[NSUserNotification alloc] init];
    note.title = @"Autumn script error";
    note.subtitle = errorMessage;
    note.informativeText = errorLocation;
    
    [NotificationManager deliverNotification:note
                                     clicked:^{
                                         [[ReplWindowController sharedInstance] showWindow: nil];
                                     }
                                   forceShow:^BOOL{
                                       return !(NSApp.isActive
                                                && [ReplWindowController sharedInstance].windowLoaded
                                                && [ReplWindowController sharedInstance].window.isKeyWindow);
                                   }
                                  resettable:NO];
}

+ (void) reset {
    requireStack = [NSMutableArray array];
    
    JSVirtualMachine* vm = [[JSVirtualMachine alloc] init];
    ctx = [[JSContext alloc] initWithVirtualMachine: vm];
    
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSString* errorMessage = exception.toString;
        NSString* errorLocation = [NSString stringWithFormat:@"%@ %@:%@", [requireStack.lastObject lastPathComponent], exception[@"line"], exception[@"column"]];
        [self showError:errorMessage location:errorLocation];
    };
    
    ctx[@"Autumn"] = [Autumn class];
    ctx[@"Window"] = [Window class];
    ctx[@"App"] = [App class];
    ctx[@"Hotkey"] = [Hotkey class];
    ctx[@"Alert"] = [Alert class];
    
    ctx[@"loadFile"] = ^(JSValue* relativePath) {
        return loadFile(relativePath.toString);
    };
    
    ctx[@"console"][@"log"] = ^{
        NSMutableString* s = [NSMutableString string];
        BOOL skippedTab = NO;
        for (JSValue* arg in [JSContext currentArguments]) {
            if (!skippedTab) skippedTab = YES; else [s appendString: @"\t"];
            [s appendString: arg.toString];
        }
        [[ReplWindowController sharedInstance] logString: s];
    };
}

@end
