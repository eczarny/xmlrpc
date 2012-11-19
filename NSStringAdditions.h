#import <Foundation/Foundation.h>

@interface NSString (NSStringAdditions)

+ (NSString *)stringByGeneratingUUID;

#pragma mark -

- (NSString *)gtm_stringByUnescapingFromHTML;

- (NSString *)escapedString;

@end
