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
#import "TBDropView.h"
#import "TBPluginVerifier.h"

#import "TBPreferencesWindowController.h"
#import "TBAboutWindowController.h"
#import "TDScreenFlasher.h"

//import ciphers
#import "ROT128Cipher.h"
#import "ARC4Cipher.h"
#import "AES128Cipher.h"

@interface TBKryptomator : NSObject
{
	
	IBOutlet NSPopUpButton *cipherPopUpButton;
	IBOutlet NSTextField *inputNameTextField;
	IBOutlet NSTextField *outputNameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSArrayController *droppedFilesArrayController;
	IBOutlet NSArrayController *pluginArrayController;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *installPluginsSheet;
	IBOutlet NSWindow *passwordSheet;
	IBOutlet NSWindow *expandedPasswordSheet;
    IBOutlet TBDropView *dropView_drop;
    IBOutlet NSImageView *imageView_dropIcon;
    IBOutlet NSImageView *imageView_dropImage;
    IBOutlet NSProgressIndicator *droppingProgressIndicator;
    IBOutlet NSTextField *textField_result;
    IBOutlet NSTextField *textField_status;
    IBOutlet NSView *dropView;
    IBOutlet NSView *manageView;
	IBOutlet NSView *advancedManageView;
	IBOutlet NSView *statusView;
	IBOutlet NSImageView *imageViewDropImage;
    IBOutlet NSImageView *imageViewDropBackground;
	IBOutlet NSArrayController* itemArrayController;
	
	IBOutlet NSProgressIndicator *statusBar;
	IBOutlet NSTextField *statusTextField;
	
	IBOutlet NSArrayController *operationsController;
	
	NSMenuItem *selectedCipherMenuItem;
	NSOperationQueue *operationQueue;
	double operationCount;
	NSMenu *cipherMenu;
	NSImage *_fullTrashImage;
	NSImage *_appDraggedImage;
	NSImage *_trashImage;
	NSImage *_statusBorderImage;
	NSString *TBEncryptionOperationKey;
	NSString *TBDecryptionOperationKey;
	NSString *choosenOperationType;
	NSString *inputFile;
	NSString *outputFile;
	NSMutableArray *droppedFilesArray;
	NSDictionary *cipherDictionary;
	
	NSUserDefaults *defaults;
	NSNotificationCenter *nc;
	NSFileManager *fm;
	TBPluginVerifier *pluginVerifier;
	
	
}

@property NSOperationQueue *operationQueue;

- (NSMutableArray*) droppedFilesArray;

- (IBAction)clickedPasswordSheetOK:(id)sender;
- (IBAction)clickedPasswordSheetCancel:(id)sender;
- (IBAction)cancelOperations:(id)sender;
- (IBAction)proceedManageView:(id)sender;
- (IBAction)cancelManageView:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showAdvancedSettings:(id) sender;
- (IBAction)showPreferencesWindow:(id) sender;
- (IBAction)cancelInstallPluginsSheet:(id)sender;
- (IBAction)endInstallPluginsSheet:(id)sender;

-(NSString*)destinationPathForSourcePath:(NSString*)sourcePath;

- (void) setDroppedFilesArray:(NSMutableArray*)newObject;
- (void) acceptDroppedFiles:(NSArray*)files
			  operatonType:(NSString*)operationType;
- (void) doEffectsAfterOperationsFinished;
- (void) handleChangedPluginPreferences: (NSNotification*) note;
- (void)setMainView:(NSView *) newView;
- (void) prepareForCryptoOperation;


@end
