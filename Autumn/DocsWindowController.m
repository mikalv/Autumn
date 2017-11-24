//
//  DocsWindowController.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "DocsWindowController.h"

@interface DocsWindowController ()

@end

@implementation DocsWindowController

+ (instancetype) sharedInstance {
    static DocsWindowController* singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[DocsWindowController alloc] initWithWindow: nil];
    });
    return singleton;
}

- (NSNibName) windowNibName {
    return @"DocsWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
