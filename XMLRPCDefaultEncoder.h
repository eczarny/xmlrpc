#import <Foundation/Foundation.h>
#import "XMLRPCEncoder.h"

@interface XMLRPCDefaultEncoder : NSObject <XMLRPCEncoder> {
    NSString *myMethod;
    NSArray *myParameters;
}

- (NSString *)encode;

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

@end
