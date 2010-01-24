// 
// Copyright (c) 2010 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

// 
// Cocoa XML-RPC Framework
// XMLRPCConnectionManager.h
// 
// Created by Eric Czarny on Thursday, July 31, 2008.
// Copyright (c) 2010 Divisible by Zero.
// 

#import <Foundation/Foundation.h>
#import "XMLRPCConnectionDelegate.h"

@class XMLRPCConnection, XMLRPCRequest;

@interface XMLRPCConnectionManager : NSObject {
    NSMutableDictionary *myConnections;
}

+ (XMLRPCConnectionManager *)sharedManager;

#pragma mark -

- (NSString *)spawnConnectionWithXMLRPCRequest: (XMLRPCRequest *)request delegate: (id<XMLRPCConnectionDelegate>)delegate;

#pragma mark -

- (NSArray *)activeConnectionIdentifiers;

- (int)numberOfActiveConnections;

#pragma mark -

- (XMLRPCConnection *)connectionForIdentifier: (NSString *)identifier;

#pragma mark -

- (void)closeConnectionForIdentifier: (NSString *)identifier;

- (void)closeConnections;

@end
