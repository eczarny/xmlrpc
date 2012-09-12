#import <Foundation/Foundation.h>
#import "XMLRPCEncoder.h"

@interface XMLRPCDefaultEncoder : NSObject <XMLRPCEncoder> {
    NSString *myMethod;
    NSArray *myParameters;
    NSFileHandle *myEncodingCacheFile;
    NSString *myEncodingCacheFilePath;
}

- (void)encodeAndCache;

@end
