
#import "ExpandedPathToLargeIconTransformer.h"

@implementation ExpandedPathToLargeIconTransformer

+ (Class) transformedValueClass
{
    return [NSImage class];
}

+ (BOOL) allowsReverseTransformation
{
    return NO;
}

- (id) transformedValue: (id) value
{
    if (!value)
        return nil;
    
    NSImage * icon = [[[NSWorkspace sharedWorkspace] iconForFile: [value stringByExpandingTildeInPath]] retain];
    [icon setScalesWhenResized: YES];
    [icon setSize: NSMakeSize(32.0, 32.0)];
    
    return icon;
}


@end