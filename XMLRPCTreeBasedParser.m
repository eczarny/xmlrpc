// 
// Copyright (c) 2008 Eric Czarny <eczarny@gmail.com>
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
// XMLRPCTreeBasedParser.m
// 
// Created by Eric Czarny on Wednesday, January 14, 2004.
// Copyright (c) 2008 Divisible by Zero.
// 

#import "XMLRPCTreeBasedParser.h"
#import "NSDataAdditions.h"

@interface XMLRPCTreeBasedParser (XMLRPCTreeBasedParserPrivate)

- (NSXMLElement *)getChildFromElement: (NSXMLElement *)element withName: (NSString *)name;

#pragma mark -

- (id)parseObject: (NSXMLElement *)element;

- (id)trueParseObject: (NSXMLElement *)element;

#pragma mark -

- (NSArray *)parseArray: (NSXMLElement *)element;

#pragma mark -

- (NSDictionary *)parseDictionary: (NSXMLElement *)element;

#pragma mark -

- (NSNumber *)parseNumber: (NSXMLElement *)element isDouble: (BOOL)flag;

- (CFBooleanRef)parseBoolean: (NSXMLElement *)element;

- (NSString *)parseString: (NSXMLElement *)element;

- (NSDate *)parseDate: (NSXMLElement *)element;

- (NSData *)parseData: (NSXMLElement *)element;

@end

#pragma mark -

@implementation XMLRPCTreeBasedParser

- (id)initWithData: (NSData *)data {
    if (!data) {
        return nil;
    }
    
    if (self = [super init]) {
        NSError *error = nil;
        myXML = [[NSXMLDocument alloc] initWithData: data options: NSXMLDocumentTidyXML error: &error];
        myDateFormatter = [[NSDateFormatter alloc] init];
        
        [myDateFormatter setDateFormat: @"yyyyMMdd'T'HH:mm:ss"];
        
        if (!myXML) {
            if (error) {
                NSLog(@"Encountered an XML parsing error: %@", error);
            }
            
            [self release];
            
            return nil;
        }
        
        if (error) {
            NSLog(@"Encountered an XML parsing error: %@", error);
            
            [self release];
            
            return nil;
        }
    }
    
    return self;
}

#pragma mark -

- (id)parse {
    NSXMLElement *child, *root = [myXML rootElement];
    
    if (!root) {
        return nil;
    }
    
    child = [self getChildFromElement: root withName: @"params"];
    
    if (child) {
        child = [self getChildFromElement: child withName: @"param"];
        
        if (!child) {
            return nil;
        }
        
        child = [self getChildFromElement: child withName: @"value"];
        
        if (!child) {
            return nil;
        }
    } else {
        child = [self getChildFromElement: root withName: @"fault"];
        
        if (!child) {
            return nil;
        }
        
        child = [self getChildFromElement: child withName: @"value"];
        
        if (!child) {
            return nil;
        }
        
        isFault = YES;
    }
    
    return [self parseObject: child];
}

#pragma mark -

- (BOOL)isFault {
    return isFault;
}

#pragma mark -

- (void)dealloc {
    [myXML release];
    [myDateFormatter release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation XMLRPCTreeBasedParser (XMLRPCTreeBasedParserPrivate)

- (NSXMLElement *)getChildFromElement: (NSXMLElement *)element withName: (NSString *)name {
    NSArray *children = [element elementsForName: name];
    
    if ([children count] > 0) {
        return [children objectAtIndex: 0];
    }
    
    return nil;
}

#pragma mark -

- (id)parseObject: (NSXMLElement *)element {
    NSXMLElement *child = (NSXMLElement *)[element childAtIndex: 0];
    
    if (child) {
        return [self trueParseObject: child];
    }
    
    return nil;
}

- (id)trueParseObject: (NSXMLElement *)element {
    NSString *name = [element name];
    
    if ([name isEqualToString: @"array"]) {
        return [self parseArray: element];
    } else if ([name isEqualToString: @"struct"]) {
        return [self parseDictionary: element];
    } else if ([name isEqualToString: @"int"] || [name isEqualToString: @"i4"]) {
        return [self parseNumber: element isDouble: NO];
    } else if ([name isEqualToString: @"double"]) {
        return [self parseNumber: element isDouble: YES];
    } else if ([name isEqualToString: @"boolean"]) {
        return (id)[self parseBoolean: element];
    } else if ([name isEqualToString: @"string"]) {
        return [self parseString: element];
    } else if ([name isEqualToString: @"dateTime.iso8601"]) {
        return [self parseDate: element];
    } else if ([name isEqualToString: @"base64"]) {
        return [self parseData: element];
    } else {
        return [self parseString: element];
    }
    
    return nil;
}

#pragma mark -

- (NSArray *)parseArray: (NSXMLElement *)element {
    NSXMLElement *parent = [self getChildFromElement: element withName: @"data"];
    NSMutableArray *array = [NSMutableArray array];
    int index;
    
    if (!parent) {
        return nil;
    }
    
    for (index = 0; index < [parent childCount]; index++) {
        NSXMLElement *child = (NSXMLElement *)[parent childAtIndex: index];
        
        if (![[child name] isEqualToString: @"value"]) {
            continue;
        }
        
        id value = [self parseObject: child];
        
        if (value) {
            [array addObject: value];
        }
    }
    
    return (NSArray *)array;
}

#pragma mark -

- (NSDictionary *)parseDictionary: (NSXMLElement *)element {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    int index;
    
    for (index = 0; index < [element childCount]; index++) {
        NSXMLElement *child, *parent = (NSXMLElement *)[element childAtIndex: index];
        
        if (![[parent name] isEqualToString: @"member"]) {
            continue;
        }
        
        child = [self getChildFromElement: parent withName: @"name"];
        
        if (!child) {
            continue;
        }
        
        NSString *key = [child stringValue];
        
        child = [self getChildFromElement: parent withName: @"value"];
        
        if (!child) {
            continue;
        }
        
        id object = [self parseObject: child];
        
        if (object && key && ![key isEqualToString: @""]) {
            [dictionary setObject: object forKey: key];
        }
    }
    
    return (NSDictionary *)dictionary;
}

#pragma mark -

- (NSNumber *)parseNumber: (NSXMLElement *)element isDouble: (BOOL)flag {
    if (flag) {
        return [NSNumber numberWithDouble: [[element stringValue] doubleValue]];
    }
    
    return [NSNumber numberWithInt: [[element stringValue] intValue]];
}

- (CFBooleanRef)parseBoolean: (NSXMLElement *)element {
    if ([[element stringValue] isEqualToString: @"1"]) {
        return kCFBooleanTrue;
    }
    
    return kCFBooleanFalse;
}

- (NSString *)parseString: (NSXMLElement *)element {
    return [element stringValue];
}

- (NSDate *)parseDate: (NSXMLElement *)element {
    return [myDateFormatter dateFromString: [element stringValue]];
}

- (NSData *)parseData: (NSXMLElement *)element {
    return [NSData base64DataFromString: [element stringValue]];
}

@end
