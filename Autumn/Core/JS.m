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
#import "Core.h"
#import "Screen.h"
#import "Env.h"
#import "Notification.h"
#import "ReplWindowController.h"

@implementation JS {
    JSContext* ctx;
    JSValue* ns;
    NSMutableArray<NSString*>* requireStack;
}

- (JSValue*) loadFile:(NSString*)path {
    if (![path hasSuffix: @".js"]) path = [path stringByAppendingPathExtension: @"js"];
    if (![path hasPrefix: @"/"])   path = [requireStack.lastObject.stringByDeletingLastPathComponent stringByAppendingPathComponent: path];
    path = path.stringByStandardizingPath;
    
    __autoreleasing NSError* error;
    NSString* script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!script) {
        [self showError: [NSString stringWithFormat:@"Error loading config file: %@", path]
               location: error.localizedDescription];
        
        NSLog(@"error loading file at [%@]: %@", path, error);
        return nil;
    }
    
    [requireStack addObject: path];
    JSValue* result = [ctx evaluateScript: script];
    [requireStack removeLastObject];
    
    return result;
}

- (NSString*) runString:(NSString*)str {
    return [ctx evaluateScript: str].toString;
}

- (void) showError:(NSString*)errorMessage location:(NSString*)errorLocation {
    [[ReplWindowController sharedInstance] logError: errorMessage
                                           location: errorLocation];
    
    NSUserNotification* note = [[NSUserNotification alloc] init];
    note.title = @"Autumn script error";
    note.subtitle = errorMessage;
    note.informativeText = errorLocation;
    
    [Notification deliverNotification:note
                              clicked:^{
                                  [[ReplWindowController sharedInstance] showWindow: nil];
                              }
                            forceShow:!(NSApp.isActive
                                        && [ReplWindowController sharedInstance].windowLoaded
                                        && [ReplWindowController sharedInstance].window.isKeyWindow)];
}

- (void) showErrorFromException:(JSValue*)exception {
    NSString* errorMessage = exception.toString;
    NSString* errorLocation = [NSString stringWithFormat:@"%@ %@:%@", [requireStack.lastObject lastPathComponent], exception[@"line"], exception[@"column"]];
    [self showError:errorMessage location:errorLocation];
}

- (instancetype) init {
    if (self = [super init]) {
        requireStack = [NSMutableArray array];
        
        JSVirtualMachine* vm = [[JSVirtualMachine alloc] init];
        ctx = [[JSContext alloc] initWithVirtualMachine: vm];
        
        __weak JS* weakSelf = self;
        ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            [weakSelf showErrorFromException: exception];
        };
        
        ns = [JSValue valueWithNewObjectInContext: ctx];
        ctx[@"Autumn"] = ns;
        
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
    return self;
}

- (JSValue*) addModule:(id)module {
    NSString* name = [module className];
    ns[name] = module;
    return ns[name];
}

- (void) loadUserConfig {
    [self loadFile: @"~/.autumnjs/init.js".stringByStandardizingPath];
}

@end
