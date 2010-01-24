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
// XMLRPCResponse.m
// 
// Created by Eric Czarny on Wednesday, January 14, 2004.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "XMLRPCResponse.h"
#import "XMLRPCEventBasedParser.h"

@implementation XMLRPCResponse

- (id)initWithData: (NSData *)data {
    if (!data) {
        return nil;
    }

    if (self = [super init]) {
        XMLRPCEventBasedParser *parser = [[XMLRPCEventBasedParser alloc] initWithData: data];
        
        if (!parser) {
            [self release];
            
            return nil;
        }
    
        myBody = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        myObject = [[parser parse] retain];
        
        isFault = [parser isFault];
        
        [parser release];
    }
    
    return self;
}

#pragma mark -

- (BOOL)isFault {
    return isFault;
}

- (NSNumber *)faultCode {
    if (isFault) {
        return [myObject objectForKey: @"faultCode"];
    }
    
    return nil;
}

- (NSString *)faultString {
    if (isFault) {
        return [myObject objectForKey: @"faultString"];
    }
    
    return nil;
}

#pragma mark -

- (id)object {
    return myObject;
}

#pragma mark -

- (NSString *)body {
    return myBody;
}

#pragma mark -

- (void)dealloc {
    [myBody release];
    [myObject release];
    
    [super dealloc];
}

@end
