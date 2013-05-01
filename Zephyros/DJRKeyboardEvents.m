#import "DJRKeyboardTools.h"
#import "DJRKeyboardEvents.h"

@implementation DJRKeyboardEvents

+ (void)sendCommandC
{
    CGKeyCode _C = [[DJRKeyboardTools sharedInstance] keyCodeForChar:'c'];
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    CGEventRef pasteCommandDown = CGEventCreateKeyboardEvent(source, _C, YES);
    CGEventSetFlags(pasteCommandDown, kCGEventFlagMaskCommand);
    CGEventRef pasteCommandUp = CGEventCreateKeyboardEvent(source, _C, NO);
    
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandDown);
    CGEventPost(kCGAnnotatedSessionEventTap, pasteCommandUp);
    
    CFRelease(pasteCommandUp);
    CFRelease(pasteCommandDown);
    CFRelease(source);    
}

@end
