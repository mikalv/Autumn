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

static JSContext* ctx;
static NSMutableArray<NSString*>* requireStack;

static JSValue* loadFile(NSString* path) {
    if (![path hasSuffix: @".js"]) path = [path stringByAppendingPathExtension: @"js"];
    if (![path hasPrefix: @"/"])   path = [requireStack.lastObject.stringByDeletingLastPathComponent stringByAppendingPathComponent: path];
    path = path.stringByStandardizingPath;
    
    __autoreleasing NSError* error;
    NSString* script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!script) {
        NSLog(@"error loading file at [%@]: %@", path, error);
        return nil;
    }
    
    [requireStack addObject: path];
    JSValue* result = [ctx evaluateScript: script];
    [requireStack removeLastObject];
    
    return result;
}

@implementation JS

+ (void) runConfig {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Env reset];
        loadFile(@"~/.autumnjs/init.js".stringByStandardizingPath);
    });
}

+ (NSString*) runString:(NSString*)str {
    return [ctx evaluateScript: str].toString;
}

+ (void) reset {
    requireStack = [NSMutableArray array];
    
    JSVirtualMachine* vm = [[JSVirtualMachine alloc] init];
    ctx = [[JSContext alloc] initWithVirtualMachine: vm];
    
    ctx.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JS exception: %@\n%@:%@\n%@", exception, exception[@"line"], exception[@"column"], exception[@"stack"]);
        [Alert show:[NSString stringWithFormat:@"Config error\n%@\n%@ %@:%@", exception.toString, requireStack.lastObject, exception[@"line"], exception[@"column"]] duration:@5];
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
        NSLog(@"CONSOLE.LOG: %@", s);
    };
}

@end