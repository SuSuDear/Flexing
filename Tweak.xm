//
//  Tweak.m
//  FLEXing
//
//  Created by Tanner Bennett on 2016-07-11
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//


#import <roothide.h>
#import <notify.h>
#import "Interfaces.h"

BOOL initialized = NO;
id manager = nil;
SEL show = nil;

static int volumeFLEXNotifyToken = 0;

/// This isn't perfect, but works for most cases as intended
inline bool isLikelyUIProcess() {
    NSString *executablePath = NSProcessInfo.processInfo.arguments[0];

    return [executablePath hasPrefix:@"/var/containers/Bundle/Application"] ||
        [executablePath hasPrefix:@"/Applications"] ||
        [executablePath containsString:@"/procursus/Applications"] ||
        [executablePath hasSuffix:@"CoreServices/SpringBoard.app/SpringBoard"];
}

inline bool isSnapchatApp() {
    // See: near line 44 below
    return [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.toyopagroup.picaboo"];
}

inline BOOL flexAlreadyLoaded() {
    return NSClassFromString(@"FLEXExplorerToolbar") != nil;
}

%ctor {
    if (isLikelyUIProcess() && !isSnapchatApp()) {
        Class FLEXManagerClass = NSClassFromString(@"FLEXManager");

        if (FLEXManagerClass && [FLEXManagerClass respondsToSelector:@selector(sharedManager)]) {
            manager = [FLEXManagerClass performSelector:@selector(sharedManager)];
            show = @selector(showExplorer);
            initialized = manager != nil;

            NSString *bid = NSBundle.mainBundle.bundleIdentifier;
            if (bid.length > 0 && ![bid isEqualToString:@"com.apple.springboard"]) {
                NSString *notification = [@"com.susudear.flexing.volume/" stringByAppendingString:bid];
                notify_register_dispatch(notification.UTF8String, &volumeFLEXNotifyToken, dispatch_get_main_queue(), ^(int token) {
                    if (initialized && manager && show) {
                        [manager performSelector:show];
                    }
                });
            }
        }
    }
}

%hook UIWindow
- (BOOL)_shouldCreateContextAsSecure {
    Class FLEXWindowClass = NSClassFromString(@"FLEXWindow");
    return (initialized && FLEXWindowClass && [self isKindOfClass:FLEXWindowClass]) ? YES : %orig;
}

%end


%hook FLEXExplorerViewController
- (BOOL)_canShowWhileLocked {
    return YES;
}
%end

%hook _UISheetPresentationController
- (id)initWithPresentedViewController:(id)present presentingViewController:(id)presenter {
    self = %orig;
    if ([present isKindOfClass:%c(FLEXNavigationController)]) {
        // Enable half height sheet
        if ([self respondsToSelector:@selector(_presentsAtStandardHalfHeight)]) {
            self._presentsAtStandardHalfHeight = YES;
        } else {
            self._detents = @[[%c(_UISheetDetent) _mediumDetent], [%c(_UISheetDetent) _largeDetent]];
        }
        // Start fullscreen, 0 for half height
        self._indexOfCurrentDetent = 1;
        // Don't expand unless dragged up
        self._prefersScrollingExpandsToLargerDetentWhenScrolledToEdge = NO;
        // Don't dim first detent
        self._indexOfLastUndimmedDetent = 1;
    }

    return self;
}
%end

%hook FLEXManager
%new
+ (NSString *)dlopen:(NSString *)path {
    if (!dlopen(path.UTF8String, RTLD_NOW)) {
        return @(dlerror());
    }

    return @"OK";
}
%end
