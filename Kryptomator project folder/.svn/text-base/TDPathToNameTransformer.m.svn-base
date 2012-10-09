/*
***BINARY***
For Private/non-commercial use: free

commercial use: request + payment


***SOURCE***
Source may not be used for commercial use

may be used for non-commercial use/private use
source only allowed for other open source programs

 If redistributed, this licence must remain
 */

#import "TDPathToNameTransformer.h"


@implementation TDPathToNameTransformer

+ (Class) transformedValueClass
{
    return [NSString class];
}

+ (BOOL) allowsReverseTransformation
{
    return NO;
}

- (id) transformedValue: (id) value
{
    if (!value)
        return nil;
    
    return [[value lastPathComponent] stringByDeletingPathExtension];
}

@end