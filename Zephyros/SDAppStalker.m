//
//  SDAppStalker.m
//  Zephyros
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAppStalker.h"

#import "SDAppProxy.h"

@interface SDAppStalker ()

@property NSMutableArray* apps;

@end

@implementation SDAppStalker

+ (SDAppStalker*) sharedAppStalker {
    static SDAppStalker* sharedAppStalker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppStalker = [[SDAppStalker alloc] init];
    });
    return sharedAppStalker;
}

- (void) beginStalking {
    self.apps = [NSMutableArray array];
    
    for (NSRunningApplication* app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        [self stalkApp:app];
    }
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(appLaunched:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(appDied:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
}

- (void) appLaunched:(NSNotification*)note {
    NSRunningApplication *launchedApp = [[note userInfo] objectForKey:NSWorkspaceApplicationKey];
    [self stalkApp:launchedApp];
}

- (void) appDied:(NSNotification*)note {
    NSRunningApplication *launchedApp = [[note userInfo] objectForKey:NSWorkspaceApplicationKey];
    [self unstalkApp:launchedApp];
}

- (void) stalkApp:(NSRunningApplication*)runningApp {
    SDAppProxy* app = [[SDAppProxy alloc] initWithRunningApp:runningApp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDListenEventAppOpened
                                                        object:nil
                                                      userInfo:@{@"thing": app}];
    
    [self.apps addObject:app];
    [app startObservingStuff];
}

- (void) unstalkApp:(NSRunningApplication*)deadApp {
    SDAppProxy* app;
    for (SDAppProxy* couldBeThisApp in self.apps) {
        if ([deadApp processIdentifier] == couldBeThisApp.pid) {
            app = couldBeThisApp;
            break;
        }
    }
    
    if (!app) {
        NSLog(@"uhh... ok?");
        return;
    }
    
    [app stopObservingStuff];
    [self.apps removeObject:app];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDListenEventAppClosed
                                                        object:nil
                                                      userInfo:@{@"thing": app}];
}

@end
