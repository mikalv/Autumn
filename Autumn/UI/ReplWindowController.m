//
//  ReplWindowController.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "ReplWindowController.h"
#import "JS.h"

static NSDictionary<NSAttributedStringKey, id>* inputAttrs;
static NSDictionary<NSAttributedStringKey, id>* outputAttrs;
static NSDictionary<NSAttributedStringKey, id>* errorAttrs;
static NSDictionary<NSAttributedStringKey, id>* textAttrs;
static NSDateFormatter* nowFormatter;

@implementation ReplWindowController {
    __weak IBOutlet NSTextView* outputView;
    NSMutableAttributedString* preLogged;
}

+ (void) initialize {
    if (self == [ReplWindowController class]) {
        NSFont* font = [NSFont fontWithName:@"Menlo" size:12.0];
        
        nowFormatter = [[NSDateFormatter alloc] init];
        nowFormatter.dateFormat = @"[HH:mm:ss.SSS] ";
        
        inputAttrs  = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemBlueColor]};
        outputAttrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemGreenColor]};
        errorAttrs  = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemRedColor]};
        textAttrs   = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemPurpleColor]};
    }
}

+ (instancetype) sharedInstance {
    static ReplWindowController* singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[ReplWindowController alloc] initWithWindow: nil];
    });
    return singleton;
}

- (NSNibName) windowNibName {
    return @"ReplWindowController";
}

- (void) windowDidLoad {
    [super windowDidLoad];
    
    if (preLogged) {
        [outputView.textStorage appendAttributedString: preLogged];
        preLogged = nil;
        
        [outputView scrollRangeToVisible:NSMakeRange(outputView.textStorage.length, 0)];
    }
}

- (void) logString:(NSString*)str {
    [self add: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n%@\n", str]
                                               attributes: textAttrs]];
}

- (void) logError:(NSString*)errorMessage location:(NSString*)errorLocation {
    [self add: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n%@\n%@\n", errorMessage, errorLocation]
                                               attributes: errorAttrs]];
}

- (IBAction) runString:(NSTextField*)sender {
    NSString* input = sender.stringValue;
    sender.stringValue = @"";
    
    [self add: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n$ %@\n", input]  attributes:inputAttrs]];
    
    NSString* output = [JS runString: input];
    
    [self add: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n> %@\n", output] attributes:outputAttrs]];
}

- (void) add:(NSAttributedString*)attrString {
    NSMutableAttributedString* stamped = [attrString mutableCopy];
    NSDictionary* attrs = [stamped attributesAtIndex:1 effectiveRange:nil];
    NSDate* now = [NSDate date];
    NSAttributedString* timestamp = [[NSAttributedString alloc] initWithString:[nowFormatter stringFromDate: now] attributes:attrs];
    [stamped insertAttributedString:timestamp atIndex:1];
    
    if (self.windowLoaded) {
        [outputView.textStorage appendAttributedString: stamped];
        [outputView scrollRangeToVisible:NSMakeRange(outputView.textStorage.length, 0)];
    }
    else {
        if (!preLogged) {
            preLogged = [[NSMutableAttributedString alloc] init];
        }
        
        [preLogged appendAttributedString: stamped];
    }
}

@end
