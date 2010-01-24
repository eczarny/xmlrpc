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
// XMLRPCEventBasedParser.m
// 
// Created by Eric Czarny on Friday, September 5, 2008.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "XMLRPCEventBasedParser.h"
#import "XMLRPCEventBasedParserDelegate.h"

@implementation XMLRPCEventBasedParser

- (id)initWithData: (NSData *)data {
    if (!data) {
        return nil;
    }
    
    if (self = [self init]) {
        myParser = [[NSXMLParser alloc] initWithData: data];
        myParserDelegate = nil;
        isFault = NO;
    }
    
    return self;
}

#pragma mark -

- (id)parse {
    [myParser setDelegate: self];
    
    [myParser parse];
    
    if ([myParser parserError]) {
        return nil;
    }
    
    return [myParserDelegate elementValue];
}

- (void)abortParsing {
    [myParser abortParsing];
}

#pragma mark -

- (NSError *)parserError {
    return [myParser parserError];
}

#pragma mark -

- (BOOL)isFault {
    return isFault;
}

#pragma mark -

- (void)dealloc {
    [myParser release];
    [myParserDelegate release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation XMLRPCEventBasedParser (NSXMLParserDelegate)

- (void)parser: (NSXMLParser *)parser didStartElement: (NSString *)element namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes: (NSDictionary *)attributes {
    if ([element isEqualToString: @"fault"]) {
        isFault = YES;
    } else if ([element isEqualToString: @"value"]) {
        myParserDelegate = [[XMLRPCEventBasedParserDelegate alloc] initWithParent: nil];
        
        [myParser setDelegate: myParserDelegate];
    }
}

- (void)parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)parseError {
    [self abortParsing];
}

@end
