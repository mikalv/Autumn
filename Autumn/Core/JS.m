//
//  JavaScriptBridge.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "JS.h"
#import "Window.h"
#import "App.h"
#import "Hotkey.h"
#import "Keyboard.h"
#import "Alert.h"
#import "Autumn.h"
#import "Screen.h"
#import "Env.h"
#import "NotificationManager.h"
#import "ReplWindowController.h"

static JSContext* ctx;
static NSMutableArray<NSString*>* requireStack;

@implementation JS

+ (JSValue*) loadFile:(NSString*)path {
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
        [self loadFile: @"~/.autumnjs/init.js".stringByStandardizingPath];
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
    
    NSArray<Class>* classes = @[[Window class],
                                [App class],
                                [Hotkey class],
                                [Keyboard class],
                                [Alert class],
                                [Screen class],
                                ];
    
    ctx[@"Autumn"] = [Autumn class];
    
    for (Class cls in classes) {
        ctx[@"Autumn"][[cls className]] = cls;
    }
    
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

+ (JSContext*) context {
    return ctx;
}

@end
