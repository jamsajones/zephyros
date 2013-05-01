//
//  SDAlertWindow.m
//  Zephyros
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAlertWindow.h"

@implementation SDAlertWindow

- (id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag]) {
		[self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
		[self setLevel:NSFloatingWindowLevel];
//        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary];
	}
	return self;
}

@end
