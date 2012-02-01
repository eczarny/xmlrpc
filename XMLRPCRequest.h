#import <Foundation/Foundation.h>

@class XMLRPCEncoder;

@interface XMLRPCRequest : NSObject {
    NSMutableURLRequest *myRequest;
    XMLRPCEncoder *myXMLEncoder;
}

- (id)initWithURL: (NSURL *)URL;

#pragma mark -

- (void)setURL: (NSURL *)URL;

- (NSURL *)URL;

#pragma mark -

- (void)setUserAgent: (NSString *)userAgent;

- (NSString *)userAgent;

#pragma mark -

- (void)setMethod: (NSString *)method;

- (void)setMethod: (NSString *)method withParameter: (id)parameter;

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters;

- (void)setParameter: (id)parameter;
- (void)setParameters: (NSArray*)parameters;

#pragma mark -

- (NSString *)method;

- (NSArray *)parameters;

#pragma mark -

- (NSString *)body;

#pragma mark -

- (NSURLRequest *)request;

#pragma mark -

- (void)setValue: (NSString *)value forHTTPHeaderField: (NSString *)header;

@end
