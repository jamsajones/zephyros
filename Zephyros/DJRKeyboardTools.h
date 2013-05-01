#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface DJRKeyboardTools : NSObject
{
	TISInputSourceRef	    layout;
	const UCKeyboardLayout* layoutData;
    id                      keyCodeCache;
}

+ (id)sharedInstance;
- (TISInputSourceRef)keyboardLayout;
- (NSString *)translateKeyCode:(short)keyCode;
- (CGKeyCode)keyCodeForChar:(unichar)aChar;

@end
