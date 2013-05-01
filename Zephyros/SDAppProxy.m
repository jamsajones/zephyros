//
//  SDAppProxy.m
//  Zephyros
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAppProxy.h"

#import "SDWindowProxy.h"
#import "SDUniversalAccessHelper.h"

#import "SDWindowProxy.h"

#import "SDAppStalker.h"

@interface SDAppProxy ()

@property AXUIElementRef app;
@property (readwrite) pid_t pid;
@property AXObserverRef observer;

- (id) initWithElement:(AXUIElementRef)element;

@end

void sendNotificationButNotTooOften(NSString* name, id thing) {
    NSNotification* note = [NSNotification notificationWithName:name object:nil userInfo:@{@"thing": thing}];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostNow];
}

void obsessiveWindowCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon) {
    if (CFEqual(notification, kAXWindowCreatedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventWindowCreated, window);
    }
    else if (CFEqual(notification, kAXWindowMovedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventWindowMoved, window);
    }
    else if (CFEqual(notification, kAXWindowResizedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventWindowResized, window);
    }
    else if (CFEqual(notification, kAXWindowMiniaturizedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventWindowMinimized, window);
    }
    else if (CFEqual(notification, kAXWindowDeminiaturizedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventWindowUnminimized, window);
    }
    else if (CFEqual(notification, kAXApplicationHiddenNotification)) {
        SDAppProxy* app = [[SDAppProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventAppHidden, app);
    }
    else if (CFEqual(notification, kAXApplicationShownNotification)) {
        SDAppProxy* app = [[SDAppProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventAppShown, app);
    }
    else if (CFEqual(notification, kAXFocusedWindowChangedNotification)) {
        SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:element];
        sendNotificationButNotTooOften(SDListenEventFocusChanged, window);
    }
}

@implementation SDAppProxy

+ (NSArray*) runningApps {
    if ([SDUniversalAccessHelper complainIfNeeded])
        return nil;
    
    NSMutableArray* apps = [NSMutableArray array];
    
    for (NSRunningApplication* runningApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        SDAppProxy* app = [[SDAppProxy alloc] initWithPID:[runningApp processIdentifier]];
        [apps addObject:app];
    }
    
    return apps;
}

- (id) initWithElement:(AXUIElementRef)element {
    pid_t pid;
    AXUIElementGetPid(element, &pid);
    return [self initWithPID:pid];
}

- (id) initWithRunningApp:(NSRunningApplication*)app {
    return [self initWithPID:[app processIdentifier]];
}

- (id) initWithPID:(pid_t)pid {
    if (self = [super init]) {
        self.pid = pid;
        self.app = AXUIElementCreateApplication(pid);
    }
    return self;
}

- (void) dealloc {
    if (self.app)
        CFRelease(self.app);
}

- (NSArray*) visibleWindows {
    if ([SDUniversalAccessHelper complainIfNeeded])
        return nil;
    
    return [[self allWindows] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SDWindowProxy* win, NSDictionary *bindings) {
        return ![[win app] isHidden]
        && ![win isWindowMinimized]
        && [win isNormalWindow];
    }]];
}

- (NSArray*) allWindows {
    NSMutableArray* windows = [NSMutableArray array];
    
    CFArrayRef _windows;
    AXError result = AXUIElementCopyAttributeValues(self.app, kAXWindowsAttribute, 0, 100, &_windows);
    if (result == kAXErrorSuccess) {
        for (NSInteger i = 0; i < CFArrayGetCount(_windows); i++) {
            AXUIElementRef win = CFArrayGetValueAtIndex(_windows, i);
            
            SDWindowProxy* window = [[SDWindowProxy alloc] initWithElement:win];
            [windows addObject:window];
        }
        CFRelease(_windows);
    }
    
    return windows;
}

- (BOOL) isHidden {
    CFTypeRef _isHidden;
    BOOL isHidden = NO;
    if (AXUIElementCopyAttributeValue(self.app, (CFStringRef)NSAccessibilityHiddenAttribute, (CFTypeRef *)&_isHidden) == kAXErrorSuccess) {
        NSNumber *isHiddenNum = CFBridgingRelease(_isHidden);
        isHidden = [isHiddenNum boolValue];
    }
    return isHidden;
}

- (void) show {
    [self setAppProperty:NSAccessibilityHiddenAttribute withValue:[NSNumber numberWithLong:NO]];
}

- (void) hide {
    [self setAppProperty:NSAccessibilityHiddenAttribute withValue:[NSNumber numberWithLong:YES]];
}

- (NSString*) title {
    return [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] localizedName];
}

- (void) kill {
    [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] terminate];
}

- (void) kill9 {
    [[NSRunningApplication runningApplicationWithProcessIdentifier:self.pid] forceTerminate];
}

- (void) startObservingStuff {
    AXObserverRef observer;
    AXError err = AXObserverCreate(self.pid, obsessiveWindowCallback, &observer);
    if (err != kAXErrorSuccess) {
//        NSLog(@"start observing stuff failed at point #1 with: %d", err);
        return;
    }
    
    self.observer = observer;
    AXObserverAddNotification(self.observer, self.app, kAXWindowCreatedNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXWindowMovedNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXWindowResizedNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXWindowMiniaturizedNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXWindowDeminiaturizedNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXApplicationHiddenNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXApplicationShownNotification, NULL);
    AXObserverAddNotification(self.observer, self.app, kAXFocusedWindowChangedNotification, NULL);
    
    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop],
                       AXObserverGetRunLoopSource(self.observer),
                       kCFRunLoopDefaultMode);
}

- (void) stopObservingStuff {
    CFRunLoopRemoveSource([[NSRunLoop currentRunLoop] getCFRunLoop],
                          AXObserverGetRunLoopSource(self.observer),
                          kCFRunLoopDefaultMode);
    
    AXObserverRemoveNotification(self.observer, self.app, kAXWindowCreatedNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXWindowMovedNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXWindowResizedNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXWindowMiniaturizedNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXWindowDeminiaturizedNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXApplicationHiddenNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXApplicationShownNotification);
    AXObserverRemoveNotification(self.observer, self.app, kAXFocusedWindowChangedNotification);
    
    CFRelease(self.observer);
    self.observer = nil;
}

- (id) getAppProperty:(NSString*)propType withDefaultValue:(id)defaultValue {
    CFTypeRef _someProperty;
    if (AXUIElementCopyAttributeValue(self.app, (__bridge CFStringRef)propType, &_someProperty) == kAXErrorSuccess)
        return CFBridgingRelease(_someProperty);
    
    return defaultValue;
}

- (BOOL) setAppProperty:(NSString*)propType withValue:(id)value {
    AXError result = AXUIElementSetAttributeValue(self.app, (__bridge CFStringRef)(propType), (__bridge CFTypeRef)(value));
    return result == kAXErrorSuccess;
}

@end
