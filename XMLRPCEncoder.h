#import <Foundation/Foundation.h>

@protocol XMLRPCEncoder <NSObject>

- (id)encode;

#pragma mark -

- (NSNumber *)encodedLength;

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

@end
