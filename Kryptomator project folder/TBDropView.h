/* TDDropView */
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

#import <Cocoa/Cocoa.h>


@interface TBDropView : NSView
{
    IBOutlet NSImageView *imageView_dropImage;
    IBOutlet NSImageView *imageView_dropBackground;
	IBOutlet NSImageView *testImageView;
	
	NSImage *_fullTrashImage;
	NSImage *_appDraggedImage;
	NSImage *_trashImage;
	NSImage *_statusBorderImage;
	NSImage *image;
	BOOL mouseInUpperField;
	BOOL draggingActive;
	BOOL onlyEncryptedFiles;
	NSString *TBDecryptionOperationKey;
	NSString *TBEncryptionOperationKey;
	NSString *selectedOperationType;
	NSRect upperRect;
	NSRect lowerRect;
	NSRect *selectedRect;
	
	NSUserDefaults *defaults;
}

- (void) drawDraggingRect:(NSRect)rect
			   isSelected:(BOOL)isSelected
			   withString:(NSString*)string;

@end
