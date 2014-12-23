//
//  NSBundle+LoginItem.m
//
//  Created by Tom Li on 11/10/14.
//  Copyright (c) 2014 Inspirify Limited. All rights reserved.
//

#import "NSBundle+LoginItem.h"

@implementation NSBundle (LoginItem)

- (void)enableLoginItem
{
    if ([self isLoginItemEnabled]) {
        return;
    }
    
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (!sharedFileList) {
        NSLog(@"Unable to create shared file list!");
        return;
    }

    NSURL *appURL = [NSURL fileURLWithPath:self.bundlePath];
    
    LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)appURL, NULL, NULL);
    if (sharedFileListItem) {
        CFRelease(sharedFileListItem);
    }
    if (sharedFileList) {
        CFRelease(sharedFileList);
    }
}

- (void)disableLoginItem
{
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (!sharedFileList) {
        NSLog(@"Unable to create shared file list!");
        return;
    }

    UInt32 seedValue;
    CFArrayRef sharedFileListArray = LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
    if (sharedFileListArray) {
        for (id sharedFile in (__bridge NSArray *)sharedFileListArray) {
            if (!sharedFile) {
                continue;
            }
            LSSharedFileListItemRef sharedFileListItem = (__bridge LSSharedFileListItemRef)sharedFile;
            
            CFURLRef appURL;
            LSSharedFileListItemResolve(sharedFileListItem, 0, &appURL, NULL);
            
            if (appURL == NULL) {
                continue;
            }
            
            NSString *resolvedPath = [(__bridge NSURL *)appURL path];
            if ([resolvedPath compare:self.bundlePath] == NSOrderedSame) {
                LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
            }
            CFRelease(appURL);
        }
        CFRelease(sharedFileListArray);
        CFRelease(sharedFileList);
    }
}

- (BOOL)isLoginItemEnabled
{
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (!sharedFileList) {
        NSLog(@"Unable to create shared file list!");
        return NO;
    }
    
    BOOL bFound = NO;
    UInt32 seedValue;
    CFArrayRef sharedFileListArray = LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
    if (sharedFileListArray) {
        for (id sharedFile in (__bridge NSArray *)sharedFileListArray) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)sharedFile;
            
            CFURLRef appURL = NULL;
            LSSharedFileListItemResolve(item, 0, (CFURLRef *)&appURL, NULL);
            if (!appURL) {
                continue;
            }

            NSString *resolvedApplicationPath = [(__bridge NSURL *)appURL path];
            CFRelease(appURL);
            
            if ([resolvedApplicationPath compare:self.bundlePath] == NSOrderedSame) {
                bFound = YES;
                break;
            }
        }
        CFRelease(sharedFileListArray);
        CFRelease(sharedFileList);
    }
    return bFound;
}

@end
