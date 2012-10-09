

#import "TDObject.h"

@implementation TDObject
static TBKryptomator *sharedKryptomatorInstance = nil;

+ (void)setSharedKryptomatorInstance:(TBKryptomator *)newInstance
{
    @synchronized(self) {
        if (newInstance != sharedKryptomatorInstance) {
            if (sharedKryptomatorInstance)
                [sharedKryptomatorInstance release];
            sharedKryptomatorInstance = [newInstance retain];
        }
    }
}

+ (TBKryptomator *)sharedKryptomatorInstance
{
    NSParameterAssert(sharedKryptomatorInstance != nil);
    return sharedKryptomatorInstance;
}
@end
