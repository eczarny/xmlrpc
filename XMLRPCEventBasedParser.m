// 
// Copyright (c) 2009 Eric Czarny <eczarny@gmail.com>
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
// Copyright (c) 2009 Divisible by Zero.
// 

#import "XMLRPCEventBasedParser.h"
#import "NSDataAdditions.h"

@interface XMLRPCEventBasedParser (NSXMLParserDelegate)

- (void)parser: (NSXMLParser *)parser didStartElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes:(NSDictionary *)attributes;

- (void)parser: (NSXMLParser *)parser didEndElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName;

- (void)parser: (NSXMLParser *)parser foundCharacters: (NSString *)string;

- (void)parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)parseError;

@end

#pragma mark -

@interface XMLRPCEventBasedParser (XMLRPCEventBasedParserPrivate)

- (void)setParser: (NSXMLParser *)parser;

- (NSXMLParser *)parser;

#pragma mark -

- (void)setParent: (XMLRPCEventBasedParser *)parent;

- (XMLRPCEventBasedParser *)parent;

#pragma mark -

- (void)setElementType: (XMLRPCEventBasedParserElementType)elementType;

- (XMLRPCEventBasedParserElementType)elementType;

#pragma mark -

- (void)setElementKey: (NSString *)elementKey;

- (NSString *)elementKey;

#pragma mark -

- (id)elementValue;

#pragma mark -

- (void)setValue: (id)value;

- (id)value;

#pragma mark -

- (void)addValueToParent;

#pragma mark -

- (void)parseChildren;

#pragma mark -

- (NSNumber *)parseInteger: (NSString *)value;

- (NSNumber *)parseDouble: (NSString *)value;

- (CFBooleanRef)parseBoolean: (NSString *)value;

- (NSString *)parseString: (NSString *)value;

- (NSDate *)parseDate: (NSString *)value;

- (NSData *)parseData: (NSString *)value;

@end

#pragma mark -

@implementation XMLRPCEventBasedParser

- (id)init {
    if (self = [super init]) {
        myParser = nil;
        
        myDateFormatter = [[NSDateFormatter alloc] init];
        
        [myDateFormatter setDateFormat: @"yyyyMMdd'T'HH:mm:ss"];
        
        myParent = nil;
        myElementType = XMLRPCEventBasedParserElementTypeError;
        myElementKey = nil;
        myElementValue = nil;
        myValue = nil;
        
        isFault = NO;
    }
    
    return self;
}

#pragma mark -

- (id)initWithData: (NSData *)data {
    if (!data) {
        return nil;
    }
    
    if (self = [self init]) {
        myParser = [[NSXMLParser alloc] initWithData: data];
    }
    
    return self;
}

#pragma mark -

- (id)parse {
    NSError *parserError = nil;
    
    [myParser setDelegate: self];
    
    [myParser parse];
    
    parserError = [myParser parserError];
    
    if (parserError) {
        return parserError;
    }
    
    return myValue;
}

- (void)abortParsing {
    [myParser abortParsing];
}

#pragma mark -

- (BOOL)isFault {
    return isFault;
}

#pragma mark -

- (void)dealloc {
    [myParser release];
    [myDateFormatter release];
    [myParent release];
    [myElementKey release];
    [myElementValue release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation XMLRPCEventBasedParser (NSXMLParserDelegate)

- (void)parser: (NSXMLParser *)parser didStartElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName attributes:(NSDictionary *)attributes {
    if ([elementName isEqualToString: @"fault"]) {
        isFault = YES;
        
        return;
    }
    
    if ([elementName isEqualToString: @"array"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeArray];
        
        [myElementValue release];
        
        myElementValue = [[NSMutableArray alloc] init];
        
        [self parseChildren];
    } else if ([elementName isEqualToString: @"struct"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeDictionary];
        
        [myElementValue release];
        
        myElementValue = [[NSMutableDictionary alloc] init];
        
        [self parseChildren];
    } else if ([elementName isEqualToString: @"int"] || [elementName isEqualToString: @"i4"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeInteger];
    } else if ([elementName isEqualToString: @"double"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeDouble];
    } else if ([elementName isEqualToString: @"boolean"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeBoolean];
    } else if ([elementName isEqualToString: @"string"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeString];
    } else if ([elementName isEqualToString: @"dateTime.iso8601"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeDate];
    } else if ([elementName isEqualToString: @"base64"]) {
        [self setElementType: XMLRPCEventBasedParserElementTypeData];
    } else {
        [self setElementType: XMLRPCEventBasedParserElementTypeString];
    }
}

- (void)parser: (NSXMLParser *)parser didEndElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName: (NSString *)qualifiedName {
    if ([elementName isEqualToString: @"name"]) {
        [self setElementKey: [myElementValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    } else if ([elementName isEqualToString: @"value"]) {
        id previousElementValue = myElementValue;
        
        switch (myElementType) {
            case XMLRPCEventBasedParserElementTypeError:
                break;
            case XMLRPCEventBasedParserElementTypeArray:
                break;
            case XMLRPCEventBasedParserElementTypeDictionary:
                break;
            case XMLRPCEventBasedParserElementTypeInteger:
                myElementValue = [self parseInteger: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            case XMLRPCEventBasedParserElementTypeDouble:
                myElementValue = [self parseDouble: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            case XMLRPCEventBasedParserElementTypeBoolean:
                myElementValue = (id)[self parseBoolean: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            case XMLRPCEventBasedParserElementTypeString:
                myElementValue = [self parseString: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            case XMLRPCEventBasedParserElementTypeDate:
                myElementValue = [self parseDate: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            case XMLRPCEventBasedParserElementTypeData:
                myElementValue = [self parseData: (NSString *)previousElementValue];
                
                [previousElementValue release];
                
                break;
            default:
                break;
        }
        
        [self addValueToParent];
        
        [self setValue: myElementValue];
    } else if ([elementName isEqualToString: @"array"] || [elementName isEqualToString: @"struct"]) {
        [myParser setDelegate: myParent];
    }
    
    if ([elementName isEqualToString: @"name"] || [elementName isEqualToString: @"value"]) {
        [myElementValue release];
        
        myElementValue = nil;
    }
}

- (void)parser: (NSXMLParser *)parser foundCharacters: (NSString *)string {
    if ((myElementType == XMLRPCEventBasedParserElementTypeArray) || (myElementType == XMLRPCEventBasedParserElementTypeDictionary)) {
        return;
    }
    
    if (!myElementValue) {
        myElementValue = [[NSMutableString alloc] initWithString: string];
    } else {
        [myElementValue appendString: string];
    }
}

- (void)parser: (NSXMLParser *)parser parseErrorOccurred: (NSError *)parseError {
    NSLog(@"The XML parser encountered an error parsing the response: %@", parseError);
    
    [parser abortParsing];
}

@end

#pragma mark -

@implementation XMLRPCEventBasedParser (XMLRPCEventBasedParserPrivate)

- (void)setParser: (NSXMLParser *)parser {
    [parser retain];
    
    [myParser release];
    
    myParser = parser;
}

- (NSXMLParser *)parser {
    return myParser;
}

#pragma mark -

- (void)setParent: (XMLRPCEventBasedParser *)parent {
    [parent retain];
    
    [myParent release];
    
    myParent = parent;
}

- (XMLRPCEventBasedParser *)parent {
    return myParent;
}

#pragma mark -

- (void)setElementType: (XMLRPCEventBasedParserElementType)elementType {
    myElementType = elementType;
}

- (XMLRPCEventBasedParserElementType)elementType {
    return myElementType;
}

#pragma mark -

- (void)setElementKey: (NSString *)elementKey {
    [elementKey retain];
    
    [myElementKey release];
    
    myElementKey = elementKey;
}

- (NSString *)elementKey {
    return myElementKey;
}

#pragma mark -

- (id)elementValue {
    return myElementValue;
}

#pragma mark -

- (void)setValue: (id)value {
    [value retain];
    
    [myValue release];
    
    myValue = value;
}

- (id)value {
    return myValue;
}

#pragma mark -

- (void)addValueToParent {
    if (!myParent) {
        return;
    }
    
    if ([myParent elementType] == XMLRPCEventBasedParserElementTypeArray) {
        [[myParent elementValue] addObject: myElementValue];
    } else if ([myParent elementType] == XMLRPCEventBasedParserElementTypeDictionary) {
        [[myParent elementValue] setValue: myElementValue forKey: myElementKey];
    }
}

#pragma mark -

- (void)parseChildren {
    XMLRPCEventBasedParser *childrenParser = [[[XMLRPCEventBasedParser alloc] init] autorelease];
    
    [childrenParser setParser: myParser];
    [childrenParser setParent: self];
    
    [myParser setDelegate: childrenParser];
}

#pragma mark -

- (NSNumber *)parseInteger: (NSString *)value {
    return [NSNumber numberWithInt: [value intValue]];
}

- (NSNumber *)parseDouble: (NSString *)value {
    return [NSNumber numberWithDouble: [value doubleValue]];
}

- (CFBooleanRef)parseBoolean: (NSString *)value {
    if ([value isEqualToString: @"1"]) {
        return kCFBooleanTrue;
    }
    
    return kCFBooleanFalse;
}

- (NSString *)parseString: (NSString *)value {
    return [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDate *)parseDate: (NSString *)value {
    return [myDateFormatter dateFromString: value];
}

- (NSData *)parseData: (NSString *)value {
    return [NSData base64DataFromString: value];
}

@end
