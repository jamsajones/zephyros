//
//  SDAppStalker.h
//  Zephyros
//
//  Created by Steven on 4/21/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDListenEventAppOpened @"SD_EVENT_APP_LAUNCHED"
#define SDListenEventAppClosed @"SD_EVENT_APP_DIED"
#define SDListenEventWindowCreated @"SD_EVENT_WINDOW_CREATED"
#define SDListenEventWindowMoved @"SD_EVENT_WINDOW_MOVED"
#define SDListenEventWindowResized @"SD_EVENT_WINDOW_RESIZED"
#define SDListenEventWindowMinimized @"SD_EVENT_WINDOW_MINIMIZED"
#define SDListenEventWindowUnminimized @"SD_EVENT_WINDOW_UNMINIMIZED"
#define SDListenEventAppHidden @"SD_EVENT_APP_HIDDEN"
#define SDListenEventAppShown @"SD_EVENT_APP_SHOWN"
#define SDListenEventFocusChanged @"SD_EVENT_FOCUS_CHANGED"

@interface SDAppStalker : NSObject

+ (SDAppStalker*) sharedAppStalker;

- (void) beginStalking;

@end
