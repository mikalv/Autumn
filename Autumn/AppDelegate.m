//
//  AppDelegate.m
//  Autumn
//
//  Created by Steven Degutis on 11/14/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "AppDelegate.h"
#import "Window.h"
#import "App.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    NSStatusItem* item;
    JSContext* ctx;
}

- (IBAction) rerunScript:(id)sender {
    NSString* script = [NSString stringWithContentsOfFile:[@"~/.autumn.js" stringByStandardizingPath] encoding:NSUTF8StringEncoding error:NULL];
    [ctx evaluateScript: script];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    item = [bar statusItemWithLength: NSSquareStatusItemLength];
    item.image = [NSImage imageNamed:@"StatusIcon"];
    item.button.target = self;
    item.button.action = @selector(rerunScript:);
    
    JSVirtualMachine* vm = [[JSVirtualMachine alloc] init];
    ctx = [[JSContext alloc] initWithVirtualMachine: vm];
    
    ctx[@"Window"] = [Window class];
    ctx[@"App"] = [App class];
    
    ctx[@"console"] = @{@"log": ^(id x) {
        NSLog(@"CONSOLE.LOG: %@", x);
    }};
    
//    NSLog(@"%@", [ctx evaluateScript: @"Window.prototype.title"]);
//    NSLog(@"%@", [ctx evaluateScript: @"Window"]);
    
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL trusted = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    NSLog(@"trusted = %d", trusted);
    
//    [self rerunScript: nil];
    
//    NSLog(@"%@", [ctx evaluateScript: @"App.prototype.title"]);
//    NSLog(@"%@", [ctx evaluateScript: @"App"]);
//    NSLog(@"%@", [ctx evaluateScript: @"apps = App.runningApps(); null"]);
//    NSLog(@"%@", [ctx evaluateScript: @"apps.length"]);
//    NSLog(@"%@", [ctx evaluateScript: @"apps.map(app => app.title())"]);
//    NSLog(@"%@", [ctx evaluateScript: @"app = apps[apps.length - 1]"]);
//    NSLog(@"%@", [ctx evaluateScript: @"app.title()"]);
//    NSLog(@"%@", [ctx evaluateScript: @"App.prototype.title.bind(app)()"]);

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"%@", [ctx evaluateScript: @"app.visibleWindows"]);
//        NSLog(@"%@", [ctx evaluateScript: @"app.visibleWindows()"]);
//
//        MJAccessibilityOpenPanel();
//
//        NSLog(@"%@", [ctx evaluateScript: @"win = app.mainWindow()"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.title()"]);
//        NSLog(@"%@", [ctx evaluateScript: @"Window.prototype.title.bind(win)()"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.size()"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.size().x"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.size().y"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.size().width"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.size().height"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.topLeft()"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.topLeft().x"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.topLeft().y"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.topLeft().width"]);
//        NSLog(@"%@", [ctx evaluateScript: @"win.topLeft().height"]);
//    });
    

//    Window* win = [[Window alloc] init];
//    ctx[@"win"] = win;
//
//    NSLog(@"%@", [ctx evaluateScript: @"win"]);
//    NSLog(@"%@", [ctx evaluateScript: @"win.foo"]);
//    NSLog(@"%@", [ctx evaluateScript: @"win.foo = 243 * 2"]);
////    NSLog(@"%@", win.foo);
//    NSLog(@"%@", [ctx evaluateScript: @"win.bar"]);
//    NSLog(@"%@", [ctx evaluateScript: @"win.bar()"]);
//    NSLog(@"%@", [ctx evaluateScript: @"win.quux"]);
//    NSLog(@"%@", [ctx evaluateScript: @"win.quux(3)"]);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
