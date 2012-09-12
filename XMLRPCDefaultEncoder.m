#import "XMLRPCDefaultEncoder.h"
#import "NSStringAdditions.h"
#import "NSData+Base64.h"

// If you change this, be sure it's a multiple of 90. The Base64 encoding adds a new line every 90 characters.
#define kChunkSize 18000

#pragma mark -

@interface XMLRPCDefaultEncoder (XMLRPCEncoderPrivate)

- (void)valueTag: (NSString *)tag value: (NSString *)value;

#pragma mark -

- (void)encodeObject: (id)object;

#pragma mark -

- (void)encodeArray: (NSArray *)array;

- (void)encodeDictionary: (NSDictionary *)dictionary;

#pragma mark -

- (void)encodeBoolean: (CFBooleanRef)boolean;

- (void)encodeNumber: (NSNumber *)number;

- (void)encodeString: (NSString *)string;

- (void)encodeDate: (NSDate *)date;

- (void)encodeData: (NSData *)data;

#pragma mark -

- (void)appendString: (NSString *)string;

- (void)appendStringWithFormat: (NSString *)format, ...;

#pragma mark -

- (void)openEncodingCache;

@end

#pragma mark -

@implementation XMLRPCDefaultEncoder

- (id)init {
    if (self = [super init]) {
        myMethod = [[NSString alloc] init];
        myParameters = [[NSArray alloc] init];
    }
    
    return self;
}

#pragma mark -

- (id)encode {
    [self encodeAndCache];
    
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath: myEncodingCacheFilePath];
    NSMutableData *encodingCacheData = [NSMutableData data];
    
    [stream open];
    
    while ([stream hasBytesAvailable]) {
        uint8_t buffer[1024];
        unsigned int length = [stream read: buffer maxLength: 1024];
        
        if (length) {
            [encodingCacheData appendBytes: buffer length: length];
        }
    }
    
    [stream close];
    
#if ! __has_feature(objc_arc)
    return [[[NSString alloc] initWithData: encodingCacheData encoding: NSUTF8StringEncoding] autorelease];
#else
    return [[NSString alloc] initWithData: encodingCacheData encoding: NSUTF8StringEncoding];
#endif
}

#pragma mark -

- (void)encodeAndCache {
    if (myEncodingCacheFilePath) {
        return;
    }
    
    [self openEncodingCache];
    
    [self appendString: @"<?xml version=\"1.0\"?><methodCall><methodName>"];
    
    [self appendString: [myMethod escapedString]];
    
    [self appendString: @"</methodName><params>"];
    
    if (myParameters) {
        for (id parameter in myParameters) {
            [self appendString: @"<param>"];
            [self encodeObject: parameter];
            [self appendString: @"</param>"];
        }
    }
    
    [self appendString: @"</params>"];
    
    [self appendString: @"</methodCall>"];
    
    [myEncodingCacheFile synchronizeFile];
}

#pragma mark -

- (NSNumber *)encodedLength {
    if (!myEncodingCacheFilePath) {
        [self encodeAndCache];
    }
    
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: myEncodingCacheFilePath error: &error];
    
    if (error) {
        return nil;
    }
    
    return [attributes objectForKey: NSFileSize];
}

#pragma mark -

- (void)setMethod: (NSString *)method withParameters: (NSArray *)parameters {
#if ! __has_feature(objc_arc)
    if (myMethod)    {
        [myMethod release];
    }
    
    if (!method) {
        myMethod = nil;
    } else {
        myMethod = [method retain];
    }
    
    if (myParameters) {
        [myParameters release];
    }
    
    if (!parameters) {
        myParameters = nil;
    } else {
        myParameters = [parameters retain];
    }
#else
	myMethod = method;
	myParameters = parameters;
#endif
}

#pragma mark -

- (NSString *)method {
    return myMethod;
}

- (NSArray *)parameters {
    return myParameters;
}

#pragma mark -

- (void)dealloc {
    if (myEncodingCacheFile) {
        [myEncodingCacheFile closeFile];
        
        [[NSFileManager defaultManager] removeItemAtPath: myEncodingCacheFilePath error: nil];
    }
    
#if ! __has_feature(objc_arc)
    [myMethod release];
    [myParameters release];
    [myEncodingCacheFile release];
    [myEncodingCacheFilePath release];
    
    [super dealloc];
#endif
}

@end

#pragma mark -

@implementation XMLRPCDefaultEncoder (XMLRPCEncoderPrivate)

- (void)valueTag: (NSString *)tag value: (NSString *)value {
    [self appendStringWithFormat: @"<value><%@>%@</%@></value>", tag, value, tag];
}

#pragma mark -

- (void)encodeObject: (id)object {
    if (!object) {
        return;
    }
    
    if ([object isKindOfClass: [NSArray class]]) {
        [self encodeArray: object];
    } else if ([object isKindOfClass: [NSDictionary class]]) {
        [self encodeDictionary: object];
#if ! __has_feature(objc_arc)
    } else if (((CFBooleanRef)object == kCFBooleanTrue) || ((CFBooleanRef)object == kCFBooleanFalse)) {
#else
    } else if (((__bridge_retained CFBooleanRef)object == kCFBooleanTrue) || ((__bridge_retained CFBooleanRef)object == kCFBooleanFalse)) {
#endif
        [self encodeBoolean: (CFBooleanRef)object];
    } else if ([object isKindOfClass: [NSNumber class]]) {
        [self encodeNumber: object];
    } else if ([object isKindOfClass: [NSString class]]) {
        [self encodeString: object];
    } else if ([object isKindOfClass: [NSDate class]]) {
        [self encodeDate: object];
    } else if ([object isKindOfClass: [NSData class]]) {
        [self encodeData: object];
    } else if ([object isKindOfClass: [NSInputStream class]]) {
        [self encodeInputStream: object];
    } else if ([object isKindOfClass: [NSFileHandle class]]) {
        [self encodeFileHandle: object];
    } else {
        [self encodeString: object];
    }
}

#pragma mark -

- (void)encodeArray: (NSArray *)array {
    [self appendString: @"<value><array><data>"];
    
    for (id object in array) {
        [self encodeObject: object];
    }
    
    [self appendString: @"</data></array></value>"];
}

- (void)encodeDictionary: (NSDictionary *)dictionary {
    [self appendString: @"<value><struct>"];
    
    for (id key in [dictionary allKeys]) {
        [self appendString: @"<member>"];
        
        [self appendString: @"<name>"];
        [self encodeString: key];
        [self appendString: @"</name>"];
        
        id value = [dictionary objectForKey: key];
        
        if (value != [NSNull null]) {
            [self encodeObject: value];
        } else {
            [self appendString: @"<value><nil/></value>"];
        }

        [self appendString: @"</member>"];
    }
    
    [self appendString: @"</struct></value>"];
}

#pragma mark -

- (void)encodeBoolean: (CFBooleanRef)boolean {
    if (boolean == kCFBooleanTrue) {
        [self valueTag: @"boolean" value: @"1"];
    } else {
        [self valueTag: @"boolean" value: @"0"];
    }
}

- (void)encodeNumber: (NSNumber *)number {
    NSString *numberType = [NSString stringWithCString: [number objCType] encoding: NSUTF8StringEncoding];
    
    if ([numberType isEqualToString: @"d"]) {
        [self valueTag: @"double" value: [number stringValue]];
    } else {
        [self valueTag: @"i4" value: [number stringValue]];
    }
}

- (void)encodeString: (NSString *)string {
    [self valueTag: @"string" value: [string escapedString]];
}

- (void)encodeDate: (NSDate *)date {
    unsigned components = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: components fromDate: date];
    NSString *buffer = [NSString stringWithFormat: @"%.4d%.2d%.2dT%.2d:%.2d:%.2d", [dateComponents year], [dateComponents month], [dateComponents day], [dateComponents hour], [dateComponents minute], [dateComponents second], nil];
    
    [self valueTag: @"dateTime.iso8601" value: buffer];
}

- (void)encodeData: (NSData *)data {
    [self valueTag: @"base64" value: [data base64EncodedString]];
}

#pragma mark -

- (void)encodeInputStream: (NSInputStream *)stream {
    [self appendString: @"<value><base64>"];
    
    [stream open];
    
    while ([stream hasBytesAvailable]) {
        uint8_t buffer[kChunkSize];
        unsigned int length = [stream read: buffer maxLength: kChunkSize];
        
        if (length) {
            @autoreleasepool {
                NSData *chunk = [NSData dataWithBytes: buffer length: length];
                
                [self appendString: [chunk base64EncodedString]];
            }
        }
    }
    
    [stream close];
    
    [self appendString: @"</base64></value>"];
}

- (void)encodeFileHandle: (NSFileHandle *)handle {
    NSData *chunk = [handle readDataOfLength: kChunkSize];
    
    [self appendString: @"<value><base64>"];
    
    while ([chunk length] > 0) {
        @autoreleasepool {
            [self appendString: [chunk base64EncodedString]];
            
            chunk = [handle readDataOfLength: kChunkSize];
        }
    }
    
    [self appendString: @"</base64></value>"];
}

#pragma mark -

- (void)appendString: (NSString *)string {
    [myEncodingCacheFile writeData: [string dataUsingEncoding: NSUTF8StringEncoding]];
}

- (void)appendStringWithFormat: (NSString *)format, ... {
    va_list arguments;
	va_start(arguments, format);
    NSString *string = nil;
    
#if ! __has_feature(objc_arc)
	string = [[[NSString alloc] initWithFormat: format arguments: arguments] autorelease];
#else
    string = [[NSString alloc] initWithFormat: format arguments: arguments];
#endif
    
    [self appendString: string];
}

#pragma mark -

- (void)openEncodingCache {
    if (myEncodingCacheFile) {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *availablePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [availablePaths objectAtIndex: 0];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    
    myEncodingCacheFilePath = [[cacheDirectory stringByAppendingPathComponent: guid] retain];
    
    [fileManager createFileAtPath: myEncodingCacheFilePath contents: nil attributes: nil];
    
    myEncodingCacheFile = [[NSFileHandle fileHandleForWritingAtPath: myEncodingCacheFilePath] retain];
}

@end
