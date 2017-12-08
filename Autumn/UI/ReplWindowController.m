//
//  ReplWindowController.m
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "ReplWindowController.h"
#import "JS.h"
#import "Env.h"

static NSDictionary<NSAttributedStringKey, id>* inputAttrs;
static NSDictionary<NSAttributedStringKey, id>* outputAttrs;
static NSDictionary<NSAttributedStringKey, id>* errorAttrs;
static NSDictionary<NSAttributedStringKey, id>* textAttrs;
static NSDateFormatter* nowFormatter;

@implementation ReplWindowController {
    __weak IBOutlet NSTextView* outputView;
    __weak IBOutlet NSTextField* inputField;
    NSMutableAttributedString* preLogged;
    
    NSMutableArray* history;
    NSInteger historyIndex;
}

+ (void) initialize {
    if (self == [ReplWindowController class]) {
        NSFont* font = [NSFont fontWithName:@"Menlo" size:12.0];
        
        nowFormatter = [[NSDateFormatter alloc] init];
        nowFormatter.dateFormat = @"[HH:mm:ss.SSS] ";
        
        inputAttrs  = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemBlueColor]};
        outputAttrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemGreenColor]};
        errorAttrs  = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemOrangeColor]};
        textAttrs   = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [NSColor systemGrayColor]};
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
    return [self className];
}

- (void) windowDidLoad {
    [super windowDidLoad];
    
    history = [NSMutableArray array];
    
    if (preLogged) {
        [outputView.textStorage appendAttributedString: preLogged];
        preLogged = nil;
        
        [outputView scrollRangeToVisible:NSMakeRange(outputView.textStorage.length, 0)];
    }
    
    inputField.textColor = inputAttrs[NSForegroundColorAttributeName];
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
    
    [self addToHistory: input];
    
    [self add: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"\n$ %@\n", input]  attributes:inputAttrs]];
    
    NSString* output = [Env.current.js runString: input];
    
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

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(moveUp:)) {
        [self goPreviousInHistory];
        return YES;
    }
    else if (commandSelector == @selector(moveDown:)) {
        [self goNextInHistory];
        return YES;
    }
    return NO;
}

- (void) addToHistory:(NSString*)str {
    [history addObject: str];
    historyIndex = history.count;
}

- (void) goNextInHistory {
    [self tryHistoryIndex: historyIndex + 1];
}

- (void) goPreviousInHistory {
    [self tryHistoryIndex: historyIndex - 1];
}

- (void) tryHistoryIndex:(NSInteger)maybeHistoryIndex {
    if (maybeHistoryIndex < 0 || maybeHistoryIndex > history.count)
        return;
    
    historyIndex = maybeHistoryIndex;
    NSString* str = (maybeHistoryIndex == history.count) ? @"" : history[maybeHistoryIndex];
    
    NSRange range = NSMakeRange(str.length, 0);
    inputField.stringValue = str;
    inputField.currentEditor.selectedRange = range;
}

@end
