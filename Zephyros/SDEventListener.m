//
//  SDEventListener.m
//  Zephyros
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDEventListener.h"

#import "SDJSBlockWrapper.h"
#import <JSCocoa/JSCocoa.h>

@interface SDEventObserver : NSObject
@property NSString* eventName;
@property SDJSBlockWrapper* fn;
@property id realObserver;
@end

@implementation SDEventObserver

- (void) beginObserving {
    self.realObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"SD_EVENT_%@", [self.eventName uppercaseString]]
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      id thing = [[note userInfo] objectForKey:@"thing"];
                                                      NSArray* args = (thing ? @[thing] : nil);
                                                      [self.fn call:args];
                                                  }];
}

- (void) stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self.realObserver];
}

@end

@interface SDEventListener ()

@property NSArray* upcomingListeners;
@property NSArray* listeners;

@end

@implementation SDEventListener

+ (SDEventListener*) sharedEventListener {
    static SDEventListener* sharedEventListener;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventListener = [[SDEventListener alloc] init];
    });
    return sharedEventListener;
}

- (void) removeListeners {
    for (SDEventObserver* observer in self.listeners) {
        [observer stopObserving];
    }
}

- (void) finalizeNewListeners {
    self.listeners = self.upcomingListeners;
    self.upcomingListeners = nil;
    
    for (SDEventObserver* observer in self.listeners) {
        [observer beginObserving];
    }
}

- (void) listenForEvent:(NSString*)name fn:(JSValueRefAndContextRef)fn {
    SDEventObserver* observer = [[SDEventObserver alloc] init];
    observer.eventName = name;
    observer.fn = [[SDJSBlockWrapper alloc] initWithJavaScriptFn:fn];
    
    self.upcomingListeners = [[NSArray arrayWithArray:self.upcomingListeners] arrayByAddingObject:observer];
}

@end
