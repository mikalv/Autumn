//
//  ReplWindowController.h
//  Autumn
//
//  Created by Steven Degutis on 11/20/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ReplWindowController : NSWindowController <NSTextFieldDelegate>

+ (instancetype) sharedInstance;

- (void) logError:(NSString*)errorMessage
         location:(NSString*)errorLocation;

- (void) logString:(NSString*)str;

@end
