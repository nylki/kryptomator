
#import <Cocoa/Cocoa.h>
#import "TBKryptomator.h"

@interface TDObject : NSObject {
}

+ (void)setSharedKryptomatorInstance:(TBKryptomator *)newInstance;
+ (TBKryptomator *)sharedKryptomatorInstance;

@end
