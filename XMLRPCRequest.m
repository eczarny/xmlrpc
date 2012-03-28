#import "XMLRPCRequest.h"
#import "XMLRPCEncoderImpl.h"

@implementation XMLRPCRequest

- (id)initWithURL: (NSURL *)URL {
    self = [super init];
    if (self) {
        if (URL) {
            myRequest = [[NSMutableURLRequest alloc] initWithURL: URL];
        } else {
            myRequest = [[NSMutableURLRequest alloc] init];
        }
        
        myXMLEncoder = [[XMLRPCEncoderImpl alloc] init];
    }
    
    return self;
}

#pragma mark -

- (void)setURL: (NSURL *)URL {
    [myRequest setURL: URL];
}

- (NSURL *)URL {
    return [myRequest URL];
}

#pragma mark -

- (void)setUserAgent: (NSString *)userAgent {
    if (![self userAgent]) {
        [myRequest addValue: userAgent forHTTPHeaderField: @"User-Agent"];
    } else {
        [myRequest setValue: userAgent forHTTPHeaderField: @"User-Agent"];
    }
}

- (NSString *)userAgent {
    return [myRequest valueForHTTPHeaderField: @"User-Agent"];
}

#pragma mark -

- (void)setMethod: (NSString *)method {
    [myXMLEncoder setMethod: method withParameters: nil];
}

- (void)setMethod: (NSString *)method withParameter: (id)parameter {
    NSArray *parameters = nil;
    
    if (parameter) {
        parameters = [NSArray arrayWithObject: parameter];
    }
    
    [myXMLEncoder setMethod: method withParameters: parameters];
}

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters {
    [myXMLEncoder setMethod: method withParameters: parameters];
}

- (void) setParameter:(id)parameter {
    NSArray *parameters = nil;
    
    if (parameter) {
        parameters = [NSArray arrayWithObject: parameter];
    }
    
    [myXMLEncoder setParameters:parameters];
}

- (void) setParameters:(NSArray *)parameters {
    [myXMLEncoder setParameters:parameters];
}

#pragma mark -

- (NSString *)method {
    return [myXMLEncoder method];
}

- (NSArray *)parameters {
    return [myXMLEncoder parameters];
}

#pragma mark -

- (NSString *)body {
    return [myXMLEncoder encode];
}

#pragma mark -

- (NSURLRequest *)request {
    NSData *content = [[self body] dataUsingEncoding: NSUTF8StringEncoding];
    NSNumber *contentLength = [NSNumber numberWithInt: [content length]];
    
    if (!myRequest) {
        return nil;
    }
    
    [myRequest setHTTPMethod: @"POST"];
    
    if (![myRequest valueForHTTPHeaderField: @"Content-Type"]) {
        [myRequest addValue: @"text/xml" forHTTPHeaderField: @"Content-Type"];
    } else {
        [myRequest setValue: @"text/xml" forHTTPHeaderField: @"Content-Type"];
    }
    
    if (![myRequest valueForHTTPHeaderField: @"Content-Length"]) {
        [myRequest addValue: [contentLength stringValue] forHTTPHeaderField: @"Content-Length"];
    } else {
        [myRequest setValue: [contentLength stringValue] forHTTPHeaderField: @"Content-Length"];
    }
    
    if (![myRequest valueForHTTPHeaderField: @"Accept"]) {
        [myRequest addValue: @"text/xml" forHTTPHeaderField: @"Accept"];
    } else {
        [myRequest setValue: @"text/xml" forHTTPHeaderField: @"Accept"];
    }
    
    if (![self userAgent]) {
      NSString *userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
      if (userAgent) {
        [self setUserAgent:userAgent];
      }
    }
    
    [myRequest setHTTPBody: content];
    
    return (NSURLRequest *)myRequest;
}

#pragma mark -

- (void)setValue: (NSString *)value forHTTPHeaderField: (NSString *)header {
    [myRequest setValue: value forHTTPHeaderField: header];
}

#pragma mark -

- (void)dealloc {
    [myRequest release];
    [myXMLEncoder release];
    
    [super dealloc];
}

@end
