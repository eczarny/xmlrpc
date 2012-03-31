#import "NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

+ (NSString *)stringByGeneratingUUID {
    CFUUIDRef UUIDReference = CFUUIDCreate(nil);
    CFStringRef temporaryUUIDString = CFUUIDCreateString(nil, UUIDReference);
    
    CFRelease(UUIDReference);
    
    return [NSMakeCollectable(temporaryUUIDString) autorelease];
}

#pragma mark -

- (NSString *)unescapedString {
    NSMutableString *string = [NSMutableString stringWithString: self];
    
    [string replaceOccurrencesOfString: @"&amp;"  withString: @"&" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&quot;" withString: @"\"" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&#x27;" withString: @"'" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&#x39;" withString: @"'" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&#x92;" withString: @"'" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&#x96;" withString: @"'" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&gt;" withString: @">" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"&lt;" withString: @"<" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    
    return [NSString stringWithString: string];
}

- (NSString *)escapedString {
    NSMutableString *string = [NSMutableString stringWithString: self];
    
    [string replaceOccurrencesOfString: @"&"  withString: @"&amp;" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"\"" withString: @"&quot;" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"'"  withString: @"&#x27;" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @">"  withString: @"&gt;" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString: @"<"  withString: @"&lt;" options: NSLiteralSearch range: NSMakeRange(0, [string length])];
    
    return [NSString stringWithString: string];
}

@end
