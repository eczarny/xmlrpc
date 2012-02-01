#import <Foundation/Foundation.h>

@interface XMLRPCEncoder : NSObject {
    NSString *myMethod;
    NSArray *myParameters;
}

- (NSString *)encode;

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

- (void)setParameters: (NSArray*)parameters;

#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

@end
