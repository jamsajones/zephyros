//
//  DJRPasteboardProxy.m
//  Zephyros
//
//  Created by Julián Romero on 4/22/13.
//

#import "DJRPasteboardProxy.h"
#import "DJRKeyboardEvents.h"
#import "NSPasteboard+SaveRestore.h"

@implementation DJRPasteboardProxy

+ (DJRPasteboardProxy *) shared
{
    static dispatch_once_t onceToken;
    static DJRPasteboardProxy * shared_pasteboard_proxy;
    dispatch_once( &onceToken, ^ {
        shared_pasteboard_proxy = [[self alloc] init];
    });
    return shared_pasteboard_proxy;
}

- (id)init {
    self = [super init];
    if (self) {
        _pasteboard = [NSPasteboard generalPasteboard];
    }
    return self;
}

- (NSString *) _selectedText
{
    NSString * selection = nil;
    BOOL insist = YES;
    NSUInteger attempts = 10;
    NSAssert(self.pasteboard, @"Opps, lost the pasteboard.");
    NSInteger previous = [self.pasteboard changeCount];
    [self.pasteboard save];
    [DJRKeyboardEvents sendCommandC];
    while (insist) {
        attempts--;
        [NSThread sleepForTimeInterval:0.125];
        NSInteger current = [self.pasteboard changeCount];
        if (current > previous) {
            insist = NO;
            NSString * availableType = [self.pasteboard availableTypeFromArray:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
            if (availableType) {
                selection = [self.pasteboard stringForType:availableType];
//                NSLog(@"Selected text: %@", selection);
            }
        }
        insist = insist && attempts > 0;
    }
    [self.pasteboard restore];
    return selection ? selection : @"" ;
}

+ (NSString*) selectedText {
    return [[self shared] _selectedText];
}

@end
