#import "XMLRPCStreamingEncoder.h"

@implementation XMLRPCStreamingEncoder

- (id)encode {
    [self encodeAndCache];
    
    return [NSInputStream inputStreamWithFileAtPath: myEncodingCacheFilePath];
}

@end
