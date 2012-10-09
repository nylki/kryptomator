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

#import "TBKryptomator.h"
#import "TDObject.h"
#import "KryptomatorCipherProtocol.h"
#import "ExpandedPathToLargeIconTransformer.h"
#import "ExpandedPathToSmallIconTransformer.h"
#import "TDPathToNameTransformer.h"

//for the manage view. if choosed crypto algorithm, fade in encrypt + decrypt button, else only a cancel button.


@implementation TBKryptomator



#pragma mark -
#pragma mark initializers and notifications
#pragma mark -

+ (void) initialize
{
    /* Default prefs */
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile:
															  [[NSBundle mainBundle] pathForResource: @"Defaults" ofType: @"plist"]]];
	
	/* Set custom value transformers */
    ExpandedPathToLargeIconTransformer * largeIconTransformer =
	[[[ExpandedPathToLargeIconTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer: largeIconTransformer forName: @"ExpandedPathToLargeIconTransformer"];
    
    ExpandedPathToSmallIconTransformer * smallIconTransformer =
	[[[ExpandedPathToSmallIconTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer: smallIconTransformer forName: @"ExpandedPathToSmallIconTransformer"];
    
    TDPathToNameTransformer * nameTransformer =
	[[[TDPathToNameTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer: nameTransformer forName: @"TDPathToNameTransformer"];
}

@synthesize operationQueue;

- (id) init
{
	self = [super init];
    if (self != nil) {
        [TDObject setSharedKryptomatorInstance:self];
		defaults = [NSUserDefaults standardUserDefaults];
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(handleChangedPluginPreferences:)
				   name:@"TBPluginPreferencesChanged" object:nil];
		
		
		TBEncryptionOperationKey = @"encryptionOperation";
		TBDecryptionOperationKey = @"decryptionOperation";
		
		fm = [NSFileManager defaultManager];
		nc = [NSNotificationCenter defaultCenter];
		pluginVerifier = [TBPluginVerifier new];
		[nc addObserver:self
			   selector:@selector(handleFinishedOperation:)
				   name:@"TBCryptoOperationDidFinish"
				 object:nil];

		
		/*populating cipherDictionary with all ciphers (which are built-in, so only non-plugin ciphers)	*/	
		NSMutableDictionary *cipherDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												 [ROT128Cipher class], [ROT128Cipher pluginName],
												 [ARC4Cipher class],[ARC4Cipher pluginName],
												 [AES128Cipher class], [AES128Cipher pluginName],
												 nil];
		
		
		  //reload plugins from the defaults and add then to the cipherDictionary
		for(NSDictionary *pluginDict in [defaults objectForKey:@"plugins"]){
			id plugin = [pluginVerifier pluginClassAtPath:[pluginDict objectForKey:@"path"]];
			if(plugin != nil)
				[cipherDict setObject:plugin forKey:[plugin pluginName]];
		}
		cipherDictionary = [cipherDict copy];
		
		
		[NSApp setDelegate:self];
		droppedFilesArray = [[NSMutableArray alloc]init];
		
		[statusBar setUsesThreadedAnimation:YES];
	}
    return self;
}

-(void)menuItemAction:(NSMenuItem*)menuItem
		   returnCode:(int)returnCode
		  contextInfo:(void*)context
{
	[selectedCipherMenuItem setTitle:[menuItem title]];
	[cipherPopUpButton selectItem:selectedCipherMenuItem];
	
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification
{
    /* Load controllers */
    
    [dropView_drop registerForDraggedTypes: 
	 [NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	
	//setting up cipher menu
	NSMutableDictionary *subMenus = [NSMutableDictionary dictionary];
	cipherMenu = [cipherPopUpButton menu];
	
	selectedCipherMenuItem = [cipherMenu itemAtIndex:0]; //the very first one
	
	for (NSString *cipherKey in cipherDictionary){
		Class cipher = [cipherDictionary objectForKey:cipherKey];
		NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[cipher pluginName]
															 action:@selector(menuItemAction:returnCode:contextInfo:)
													  keyEquivalent:@"" ];
		if ([cipher categorie] != nil){
			if ([subMenus objectForKey:[cipher categorie]] == nil)
				[subMenus setObject:[[NSMenu alloc] initWithTitle:[cipher categorie]] forKey:[cipher categorie]];
			
			[[subMenus objectForKey:[cipher categorie]] addItem:newMenuItem];
			
		} else {
			[cipherMenu addItem:newMenuItem];
			
		}
	}
	
	//adding submenues to main cipherMenu
	for (NSString* key in subMenus){
		NSMenu *subMenu = [subMenus objectForKey:key];
		
		NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:[subMenu title]
															 action:NULL
													  keyEquivalent:@""];
		[cipherMenu addItem:subMenuItem];
		[cipherMenu setSubmenu:subMenu forItem:subMenuItem];
	}
	
	
	
    /* Prepare and show the main window */
    [self setMainView:nil];
    [mainWindow makeKeyAndOrderFront:nil];
	[self handleChangedPluginPreferences:nil];
	[cipherPopUpButton setMenu:cipherMenu];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{ 
    return YES;
}

- (void) setMainView:(NSView *) newView
{
    NSView *view = dropView; /* default */
    if (newView)
        view = newView;
    
    NSWindow *window = mainWindow;
    if ([window contentView] == view)
        return;
    
    NSRect windowRect = [window frame];
    int difference = [view frame].size.height - [[window contentView] frame].size.height;
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
    
    [view setHidden: YES];
    [window setContentView: view];
	[[window animator] setFrame: windowRect display: YES];
    [view setHidden: NO];
}



- (IBAction)showAdvancedSettings:(id) sender
{
	[self setMainView:advancedManageView];
}


-(void) passwordSheetDidEnd: (NSWindow *) sheet
				 returnCode: (int) returnCode
				contextInfo: (void*) contextInfo
{
	if (returnCode == 1)
		[self prepareForCryptoOperation];
}

-(void) didReceiveProgressUpdate : (id)userInfo
{
	
}

- (void) prepareForCryptoOperation
{
	if(nil != cipherDictionary) NSLog(@"ciph d: %i", [cipherDictionary count]);
	Class choosenCipher = [cipherDictionary objectForKey:[selectedCipherMenuItem title]];
	NSLog(@"index: %i",[cipherPopUpButton indexOfSelectedItem]);
	NSLog(@"selected item: %@", [cipherPopUpButton titleOfSelectedItem]);
	NSString *path;
	NSDictionary *fileDict;
	BOOL isDir;
	
	[statusBar setDoubleValue:0];
	operationCount = 0;
	operationQueue = [[NSOperationQueue alloc] init];
	operationQueue.maxConcurrentOperationCount = 6;
	
	for( fileDict in droppedFilesArray){  //iterate through all dropped *files*	
		path = [fileDict objectForKey:@"path"];
		
		if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) { // if item is directory, iterate through it
			NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:path];
			NSString *subPath;
			while(( subPath = [dirEnum nextObject]) != nil){
				subPath = [path stringByAppendingPathComponent:subPath];
				NSOperation *newCryptoOperation;
				
				if ([fm fileExistsAtPath:subPath isDirectory:&isDir] && (isDir == NO)){
					
					newCryptoOperation = [[choosenCipher alloc] initCryptoOperationOfType:choosenOperationType
																		   withSourcePath:subPath
																		  destinationPath:[self destinationPathForSourcePath:subPath]
																				 password:[passwordTextField stringValue]];
					[operationQueue addOperation:newCryptoOperation];
					operationCount++; [statusBar setMaxValue:(double)operationCount];
				}
			}		
		}else{ // if item is no directory
			NSOperation *newCryptoOperation;
			newCryptoOperation = [[choosenCipher alloc] initCryptoOperationOfType:choosenOperationType
																   withSourcePath:path
																  destinationPath:[self destinationPathForSourcePath:path]
																		 password:[passwordTextField stringValue]];
			
			[operationQueue addOperation:newCryptoOperation];
			operationCount++; [statusBar setMaxValue:(double)operationCount];
		}
		
	}
	[statusBar setMaxValue:(double)operationCount];
	[statusBar setIndeterminate:NO];
	[statusBar startAnimation:self];
	[self setMainView:statusView];
	
	[droppedFilesArrayController removeObjects:[droppedFilesArrayController content]];
	
}

-(NSString*)destinationPathForSourcePath:(NSString*)sourcePath
{
	NSString *destinationPath;
	if([choosenOperationType isEqualToString:TBEncryptionOperationKey]){
		destinationPath = [sourcePath stringByAppendingPathExtension:[defaults objectForKey:@"encryptedFilesExtension"]];
	}else{
		//if files has the .decrypted extension, the new name will be the original (without the additional extension)
		if ( [[sourcePath pathExtension] isEqualToString:[defaults objectForKey:@"encryptedFilesExtension"]]){
			destinationPath = [sourcePath stringByDeletingPathExtension];
		} else {
			destinationPath = [sourcePath stringByAppendingPathExtension:[defaults objectForKey:@"decryptedFilesExtension"]];
		}
	}
	return destinationPath;
}


-(void) doEffectsAfterOperationsFinished
{
	if( [defaults boolForKey:@"flashScreen"] )
		[[TDScreenFlasher new] flashScreen];
	
	if( [defaults boolForKey:@"playSound"]){
		NSSound *soundToPlay = [NSSound soundNamed: [defaults objectForKey:@"soundToPlay"]];
		[soundToPlay play];
	}
}

-(IBAction)clickedPasswordSheetOK:(id)sender
{
	[expandedPasswordSheet orderOut:sender];
	[NSApp endSheet:expandedPasswordSheet returnCode:1];	
}

-(IBAction)clickedPasswordSheetCancel:(id)sender
{
	[expandedPasswordSheet orderOut:sender];
	[NSApp endSheet:expandedPasswordSheet returnCode:0];
}

#pragma mark -
#pragma mark handle notifications and accessor methods
#pragma mark -

-(void) handleChangedPluginPreferences: (NSNotification*) note
{//reload arrayController with new plugins
	/*
	 //remove all plugins from current pluginArrayController
	 [pluginArrayController removeObjects:[pluginArrayController content]];
	 
	 //now add all default cipher classes
	 [pluginArrayController addObjects: [NSArray arrayWithObjects:
	 [ROT128Cipher class],
	 [ARC4Cipher class],nil]];
	 
	 //reload pluginArrayController with new plugins from the defaults
	 for(NSDictionary *pluginDict in [defaults objectForKey:@"plugins"]){
	 id plugin = [pluginVerifier pluginClassAtPath:[pluginDict objectForKey:@"path"]];
	 if(plugin != nil)
	 [pluginArrayController addObject:plugin];
	 }*/
}

-(void) handleFinishedOperation:(NSNotification*)note
{
	[statusBar incrementBy:1.0];
	[statusTextField setStringValue:[NSString stringWithFormat:@"%i/%i files", (int)[statusBar doubleValue],(int)operationCount]];
	
	if([defaults boolForKey:@"deleteOriginalFiles"] == YES)
		[fm removeItemAtPath:[[note object] sourcePath] error:NULL];
	
	//If all operations done:
	if ( [statusBar doubleValue] >= operationCount){
		[statusBar setIndeterminate:YES];
		[self doEffectsAfterOperationsFinished];
		
		[operationQueue cancelAllOperations];
		[operationQueue release];
		
		[textField_status setStringValue:@"drop files here"];
		[self setMainView:dropView];
	}
	
	
	NSLog(@"operation finished!");
}


- (NSMutableArray*) droppedFilesArray
{
	return droppedFilesArray;
}

-(IBAction)cancelOperations:(id)sender
{
	[operationQueue cancelAllOperations];
	[operationQueue release];
	[self setMainView:dropView];
}

- (void) setDroppedFilesArray:(NSMutableArray*)newObject
{
	[droppedFilesArray release];
	[newObject retain];
	droppedFilesArray = newObject;
}

-(void) acceptDroppedFiles:(NSArray*)files
			  operatonType:(NSString*)operationType
{
	NSLog(@"accept dropped files: %@",files);
	
	if(nil != cipherDictionary) NSLog(@"ciph d: %i", [cipherDictionary count]);
	[droppingProgressIndicator setHidden:NO];
	[droppingProgressIndicator startAnimation:self];
	[droppedFilesArrayController addObjects:files];
	choosenOperationType = operationType;
	[mainWindow setTitle: ([choosenOperationType isEqualToString:TBEncryptionOperationKey] ? @"Encrypt" : @"Decrypt")];
	if([defaults boolForKey:@"showDetailedView"] == YES){
		[self setMainView:manageView];
	} else {
		[[NSApplication sharedApplication] beginSheet: expandedPasswordSheet
									   modalForWindow: mainWindow
										modalDelegate: self
									   didEndSelector: @selector(passwordSheetDidEnd:returnCode:contextInfo:)
										  contextInfo: choosenOperationType ];
	}
	
	[droppingProgressIndicator stopAnimation:self];
	[droppingProgressIndicator setHidden:YES];
}

-(IBAction)proceedManageView:(id)sender
{
	[[NSApplication sharedApplication] beginSheet: expandedPasswordSheet
								   modalForWindow: mainWindow
									modalDelegate: self
								   didEndSelector: @selector(passwordSheetDidEnd:returnCode:contextInfo:)
									  contextInfo: choosenOperationType ];
}

- (IBAction)cancelManageView:(id)sender
{
	[textField_status setStringValue:@"drop files here"];
	[itemArrayController removeObjects:[itemArrayController content]];
	[self setMainView:dropView];
}
- (IBAction)showPreferencesWindow:(id)sender
{
	[[TBPreferencesWindowController preferencesWindowController] showWindow:nil];
}

- (IBAction)showAboutWindow:(id)sender
{
	[[TBAboutWindowController aboutWindowController] showWindow:nil];
}

@end
