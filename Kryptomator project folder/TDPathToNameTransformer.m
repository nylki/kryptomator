

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