#import <Foundation/Foundation.h>

@protocol XMLRPCEncoder <NSObject>
- (NSString *)encode;

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

- (void)setParameters: (NSArray*)parameters;
#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

@end
