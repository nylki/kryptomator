/*
 Copyright (c) 2007 AppScrapper authors and contributors
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TDScreenFlasher.h"

@implementation TDScreenFlasher

- (void) flashScreen {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSWindow *flashWindow = [[NSWindow alloc] initWithContentRect:[[[NSScreen screens] objectAtIndex:0] frame]
                                                        styleMask:NSBorderlessWindowMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:YES];
	[flashWindow setBackgroundColor:[NSColor whiteColor]];
	[flashWindow setOpaque:YES];
	[flashWindow setIgnoresMouseEvents:YES];
	[flashWindow setLevel:NSFloatingWindowLevel];
    [flashWindow setAlphaValue:0.6];
        
	[flashWindow makeKeyAndOrderFront:self];
    
    float i;
    for (i = 0.6; i >= 0; i-=0.1) {
        [flashWindow setAlphaValue:(float)i];
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval)0.06]];
    }
    
    [flashWindow orderOut:self];
    
    [pool release];
}

@end
