//
//  ReplWindowController.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "ReplWindowController.h"
#import "JS.h"

static NSDictionary<NSAttributedStringKey, id>* outputAttrs;
static NSDictionary<NSAttributedStringKey, id>* inputAttrs;

@implementation ReplWindowController {
    __weak IBOutlet NSTextView* outputView;
}

+ (void) load {
    if (self == [ReplWindowController class]) {
        NSFont* font = [NSFont fontWithName:@"Menlo" size:16.0];
        
        inputAttrs = @{NSFontAttributeName: font,
                       NSForegroundColorAttributeName: [NSColor blueColor]};
        
        outputAttrs = @{NSFontAttributeName: font,
                        NSForegroundColorAttributeName: [NSColor redColor]};
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

- (IBAction) runString:(NSTextField*)sender {
    NSString* input = sender.stringValue;
    sender.stringValue = @"";
    
    NSString* output = [JS runString: input];
    
    [outputView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n$ %@\n", input]  attributes:inputAttrs]];
    [outputView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"> %@\n", output] attributes:outputAttrs]];
    
    [outputView scrollRangeToVisible:NSMakeRange(outputView.textStorage.length, 0)];
}

@end
