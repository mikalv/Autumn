//
//  LoginLauncher.m
//  Autumn
//
//  Created by Steven Degutis on 11/30/17.
//  Copyright © 2017 Pen & Paper Software. All rights reserved.
//

#import "LoginLauncher.h"

@implementation LoginLauncher

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static LSSharedFileListRef shared_file_list() {
    static LSSharedFileListRef list;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    });
    return list;
}

+ (BOOL) isEnabled {
    NSURL *appURL = [[[NSBundle mainBundle] bundleURL] fileReferenceURL];
    
    UInt32 seed;
    NSArray *sharedFileListArray = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(shared_file_list(), &seed);
    for (id item in sharedFileListArray) {
        LSSharedFileListItemRef sharedFileItem = (__bridge LSSharedFileListItemRef)item;
        CFURLRef url = NULL;
        
        OSStatus result = LSSharedFileListItemResolve(sharedFileItem, 0, &url, NULL);
        if (result == noErr && url != NULL) {
            BOOL foundIt = [appURL isEqual: [(__bridge NSURL*)url fileReferenceURL]];
            
            CFRelease(url);
            
            if (foundIt) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void) setEnabled:(BOOL)opensAtLogin {
    NSURL *appURL = [[[NSBundle mainBundle] bundleURL] fileReferenceURL];
    
    if (opensAtLogin) {
        LSSharedFileListItemRef result = LSSharedFileListInsertItemURL(shared_file_list(),
                                                                       kLSSharedFileListItemLast,
                                                                       NULL,
                                                                       NULL,
                                                                       (__bridge CFURLRef)appURL,
                                                                       NULL,
                                                                       NULL);
        CFRelease(result);
    }
    else {
        UInt32 seed;
        NSArray *sharedFileListArray = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(shared_file_list(), &seed);
        for (id item in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileItem = (__bridge LSSharedFileListItemRef)item;
            CFURLRef url = NULL;
            
            OSStatus result = LSSharedFileListItemResolve(sharedFileItem, 0, &url, NULL);
            if (result == noErr && url != nil) {
                if ([appURL isEqual: [(__bridge NSURL*)url fileReferenceURL]])
                    LSSharedFileListItemRemove(shared_file_list(), sharedFileItem);
                
                CFRelease(url);
            }
        }
    }
}

#pragma clang diagnostic pop

@end
