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

@interface XMLRPCEventBasedParserDelegate : NSObject<NSXMLParserDelegate> {
#if !__has_feature(objc_arc)
    XMLRPCEventBasedParserDelegate *myParent;
#else
    // Without ARC this reference is effectively unretained so don't use strong reference here.
    XMLRPCEventBasedParserDelegate * __unsafe_unretained myParent;
#endif
    NSMutableSet *myChildren;
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
