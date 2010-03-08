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
// XMLRPCEventBasedParserDelegate.h
// 
// Created by Eric Czarny on Tuesday, July 14, 2009.
// Copyright (c) 2010 Divisible by Zero.
// 

#import <Foundation/Foundation.h>

typedef enum {
    XMLRPCElementTypeArray,
    XMLRPCElementTypeDictionary,
    XMLRPCElementTypeMember,
    XMLRPCElementTypeName,
    XMLRPCElementTypeInteger,
    XMLRPCElementTypeDouble,
    XMLRPCElementTypeBoolean,
    XMLRPCElementTypeString,
    XMLRPCElementTypeDate,
    XMLRPCElementTypeData
} XMLRPCElementType;

#pragma mark -

@interface XMLRPCEventBasedParserDelegate : NSObject {
    XMLRPCEventBasedParserDelegate *myParent;
    NSMutableArray *myChildren;
    XMLRPCElementType myElementType;
    NSString *myElementKey;
    id myElementValue;
}

- (id)initWithParent: (XMLRPCEventBasedParserDelegate *)parent;

#pragma mark -

- (void)setParent: (XMLRPCEventBasedParserDelegate *)parent;

- (XMLRPCEventBasedParserDelegate *)parent;

#pragma mark -

- (void)setElementType: (XMLRPCElementType)elementType;

- (XMLRPCElementType)elementType;

#pragma mark -

- (void)setElementKey: (NSString *)elementKey;

- (NSString *)elementKey;

#pragma mark -

- (void)setElementValue: (id)elementValue;

- (id)elementValue;

@end
