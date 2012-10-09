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

#import "TBDropView.h"
#import "TDObject.h"


@implementation TBDropView

- (id) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	
	if (self) 
	{
		TBEncryptionOperationKey = @"encryptionOperation";
		TBDecryptionOperationKey = @"decryptionOperation";
		defaults = [NSUserDefaults standardUserDefaults];
		draggingActive = NO;
	}
	
	return self;
}

- (void) dealloc
{
	/*
	 [_fullTrashImage release];
	 [_appDraggedImage release];
	 [_trashImage release];
	 [_statusBorderImage release];
	 */
	
	[super dealloc];
}

- (void) drawDraggingRect:(NSRect)rect
			   isSelected:(BOOL)isSelected
			   withString:(NSString*)string
{

	NSMutableAttributedString *drawString = [[NSMutableAttributedString alloc] initWithString:string];
	[drawString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Lucida Grande" size:18.0] range:NSMakeRange(0, [string length])];
	[drawString addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [string length])];

	NSPoint stringOrigin;
	NSSize stringSize = [drawString size];

	//getting center of rect for drawing the string
	stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width )/2;
	stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height )/2;
	[drawString drawAtPoint:stringOrigin];

	//array for the dotted lines around the rectangles
	CGFloat pattern[1];
	pattern[0] = 14.0; //the colored dot
	pattern[1] = 7.0;   //the gap

	//drawing rectangle
	NSBezierPath *roundedRectangle = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:15.0 yRadius:15.0];
	roundedRectangle.lineWidth = 3.0;
	if( isSelected == YES){
		[[[NSColor blackColor] colorWithAlphaComponent:0.6] set];
		[roundedRectangle fill];
		[[NSColor keyboardFocusIndicatorColor] set];
		[roundedRectangle stroke];
		
	} else {
		[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
		[roundedRectangle fill];
		
		[[NSColor whiteColor] set];
		[roundedRectangle setLineDash:(const CGFloat *)pattern count:2.0 phase:0];
		[roundedRectangle stroke];
	}
}

- (void) drawRect:(NSRect)rect
{
	
	NSRect bounds = [self bounds];

	if( draggingActive){
		lowerRect = bounds;
		upperRect = bounds;
		
		//split the rect of the whole view into two rects, with borders
		lowerRect.size.height = (bounds.size.height / 2) - 20;
		upperRect.size.height = (bounds.size.height / 2) - 20;
		lowerRect.size.width -= 20;
		upperRect.size.width -= 20;
		
		lowerRect.origin.x = 10;
		upperRect.origin.x = 10;
		lowerRect.origin.y = 15;
		upperRect.origin.y = (bounds.size.height / 2) + 5;

		if(onlyEncryptedFiles == YES){
			NSRect roundedBounds = bounds;
			roundedBounds.origin.x = 10;
			roundedBounds.origin.y = 10;
			roundedBounds.size.height -= 20;
			roundedBounds.size.width -= 20;
			[self drawDraggingRect:roundedBounds
						isSelected:YES
						withString:@"decrypting"];
		} else {

			[self drawDraggingRect:lowerRect
						isSelected:([selectedOperationType isEqualToString:TBDecryptionOperationKey])
						withString:@"decrypting"];

			[self drawDraggingRect:upperRect
						isSelected:([selectedOperationType isEqualToString:TBEncryptionOperationKey])
						withString:@"encrypting"];

		}

		[super drawRect: rect];
		[self setNeedsDisplay:YES];
		
	} else { //write "drag files here"
		NSMutableAttributedString *drawString = [[NSMutableAttributedString alloc] initWithString:@"Drag files here!"];
		[drawString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Lucida Grande" size:18.0] range:NSMakeRange(0,16)];
		[drawString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] range:NSMakeRange(0, 16)];

		NSPoint stringOrigin;
		NSSize stringSize = [drawString size];
		
		//getting center of rect for drawing the string
		stringOrigin.x = rect.origin.x + (rect.size.width - stringSize.width )/2;
		stringOrigin.y = rect.origin.y + (rect.size.height - stringSize.height )/2;
		[drawString drawAtPoint:stringOrigin];

	}
}

-(void)setImage: (NSImage *)newImage
{
	[newImage retain];
	[image release];
	image = newImage;
	[[self animator] setNeedsDisplay:YES];
}

#pragma mark Drag and drop
- (NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender 
{
	NSLog(@"files entered into the dropview");
	[self setNeedsDisplay:YES];
	
	
	NSPasteboard *pboard;
    NSDragOperation sourceDragMask;	
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	//looking if _all_ files are previously encrypted files
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *droppedItems = [pboard propertyListForType:NSFilenamesPboardType];
		NSString *path;
		onlyEncryptedFiles = YES;
		for( path in droppedItems){
			if ( !([[path pathExtension] isEqualToString:[defaults objectForKey:@"encryptedFilesExtension"]])){
				onlyEncryptedFiles = NO;
				break;
			}
		}
		
	}
	draggingActive = YES;

	[self setNeedsDisplay:YES];

	return NSDragOperationGeneric;

}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
	NSPoint cursorPosition = [sender draggingLocation];
	/*
	NSSize dropViewSize = [self bounds].size;
	int dropViewHeightMiddle = (int) round(dropViewSize.height / 2);
	int mouseHeight = (int) round(cursorPosition.y);*/
	
	if (onlyEncryptedFiles == YES) {
			selectedOperationType = TBDecryptionOperationKey;
	}
	else if (NSPointInRect(cursorPosition, upperRect) && ![selectedOperationType isEqualToString:TBEncryptionOperationKey]){
		//mouse _was_ in lower field, now is in upper part of the view
		NSLog(@"mouse in upper part");
		mouseInUpperField = YES;
		selectedOperationType = TBEncryptionOperationKey;
		[self setNeedsDisplay:YES];
	}
	else if (NSPointInRect(cursorPosition, lowerRect) && ![selectedOperationType isEqualToString:TBDecryptionOperationKey] ){
		//mouse _was_ in upper field, now is in lower part of the view
		NSLog(@"mouse in lower part");
		mouseInUpperField = NO;
		selectedOperationType = TBDecryptionOperationKey;
		[self setNeedsDisplay:YES];
	}
	
	
	return NSDragOperationGeneric;
}

- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender 
{
	draggingActive = NO;
	
	NSLog(@"perform drag operation...");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	NSPoint cursorPosition = [sender draggingLocation];
	
	if ( !( NSPointInRect(cursorPosition, lowerRect)) && !(NSPointInRect(cursorPosition, upperRect)) )
		return NO;
	
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
		NSArray *droppedItems = [pboard propertyListForType:NSFilenamesPboardType];
		NSMutableArray *filesArray = [NSMutableArray new];
		NSString *path;
		
		for( path in droppedItems){
			NSMutableDictionary *fileDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												   [path lastPathComponent], @"name", 
												   path, @"path",
												   nil];
			[filesArray addObject:fileDictionary];
		}
		[[TDObject sharedKryptomatorInstance] acceptDroppedFiles:[filesArray copy]
													operatonType:selectedOperationType];
		[pool release];
		[self setNeedsDisplay:YES];
		return YES;
	}
	[self setNeedsDisplay:YES];
	return NO;
	[pool release];
	
	
}

- (void) draggingExited:(id <NSDraggingInfo>)sender
{
	draggingActive = NO;
	[self setNeedsDisplay:YES];
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
	draggingActive = NO;
	[self setNeedsDisplay:YES];
}


@end
