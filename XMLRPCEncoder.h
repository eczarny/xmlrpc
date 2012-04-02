//
//  XMlRPCEncoder.h
//  XMLRPC
//
//  Created by Zack Powers on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
