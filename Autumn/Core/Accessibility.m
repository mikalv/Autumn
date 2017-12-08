//
//  Accessibility.m
//  Autumn
//
//  Created by Steven Degutis on 12/8/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "Accessibility.h"

@interface Accessibility ()

@property (readwrite) BOOL enabled;

@end

@implementation Accessibility

+ (Accessibility*) sharedAccessibility {
    static Accessibility* accessibility;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        accessibility = [[Accessibility alloc] init];
    });
    return accessibility;
}

- (instancetype) init {
    if (self = [super init]) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(accessibilityChanged:)
                                                                name:@"com.apple.accessibility.api"
                                                              object:nil];
        [self recache];
    }
    return self;
}

- (void) accessibilityChanged:(NSNotification*)note {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self recache];
    });
}

- (void) recache {
    self.enabled = AXIsProcessTrustedWithOptions(NULL);
}

+ (void) openPanel {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
}

@end

