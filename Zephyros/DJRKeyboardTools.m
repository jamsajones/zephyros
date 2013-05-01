#import "DJRKeyboardTools.h"

#define MAX_LEN	4

@implementation DJRKeyboardTools

- (id)initWithKeyboardLayout:(TISInputSourceRef)aLayout
{
	if ((self = [super init])) {
		layout = aLayout;
        keyCodeCache = [[NSMutableDictionary alloc] init];
		CFDataRef data = TISGetInputSourceProperty(layout , kTISPropertyUnicodeKeyLayoutData);
		layoutData = (const UCKeyboardLayout*)CFDataGetBytePtr(data);
	}
	return self;
}

- (void)dealloc
{
    if (keyCodeCache) {
        [keyCodeCache release];
        keyCodeCache = nil;
    }
    if (layout) CFRelease(layout);
    [super dealloc];
}

+ (id)sharedInstance
{
	static DJRKeyboardTools* instance = nil;
	TISInputSourceRef currentLayout = TISCopyCurrentKeyboardLayoutInputSource();
    
	if (!instance) {
		instance = [[DJRKeyboardTools alloc] initWithKeyboardLayout:currentLayout];
	}
	else if ([instance keyboardLayout] != currentLayout) {
		[instance release];
		instance = [[DJRKeyboardTools alloc] initWithKeyboardLayout:currentLayout];
	}
	return instance;
}

- (TISInputSourceRef)keyboardLayout
{
	return layout;
}

- (NSString *)translateKeyCode:(short)keyCode
{
	UniCharCount len;
	UniChar str[MAX_LEN];
	UInt32 deadKeyState;
    
	UCKeyTranslate(layoutData, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, MAX_LEN, &len, str);
	return [NSString stringWithCharacters:str length:1];
}


- (CGKeyCode)keyCodeForChar:(unichar)aChar
{
    NSNumber *cached;
    CGKeyCode code = 0;
    id cacheKey = [NSNumber numberWithUnsignedShort:aChar];
    /* check cache first */
    cached = [keyCodeCache objectForKey:cacheKey];
    if (cached) {
        return (CGKeyCode)[cached unsignedShortValue];
    }
    for(short kc=0; kc<128; kc++) {
        NSString *charCode = [self translateKeyCode:kc];
        if ([charCode characterAtIndex:0] == aChar) {
            code = kc;
            /* cache it */
            [keyCodeCache setObject:[NSNumber numberWithUnsignedShort:(unsigned short)code] forKey:cacheKey];
            break;
        }
    }
    return code;
}


@end