/*
 ***BINARY***
 For Private/non-commercial use: free
 
 commercial use: request + payment
 
 
 ***SOURCE***
 Source may not be used for commercial use
 
 may be used for non-commercial use/private use
 *source only allowed for other open source programs*
 
 If redistributed, this licence must remain
 */

#import "TBPreferencesWindowController.h"



@implementation TBPreferencesWindowController

#pragma mark Singleton
TBPreferencesWindowController *sharedPreferencesWindowInstance = nil;

@synthesize availableSounds;

+ (TBPreferencesWindowController *) preferencesWindowController
{
    if (!sharedPreferencesWindowInstance)
        sharedPreferencesWindowInstance = [[self alloc] initWithWindowNibName:@"PreferencesWindow"];
    return sharedPreferencesWindowInstance;
}

#pragma mark Overrides
- (id) initWithWindowNibName:(NSString *)windowNibName
{
    if (!(self = [super initWithWindowNibName:windowNibName]))
        NSLog(@"initWithWindowNibName \"%@\" failed", windowNibName);
    else {
		NSLog(@"initWithWindowNibName \"%@\" succeeded", windowNibName);
        defaults = [NSUserDefaults standardUserDefaults];
		pluginVerifier = [TBPluginVerifier new];
		fm = [NSFileManager defaultManager];
		nc = [NSNotificationCenter defaultCenter];
		if ([defaults arrayForKey:@"plugins"] == nil)  //create "plugins" entry in the defaults
			[defaults setObject:[NSMutableArray new] forKey:@"plugins"];
		
		//check if Application support directory for kryptomator exists, if no then create
		BOOL isDir;
		NSString *appSupportPath = [[[NSHomeDirectory()
									  stringByAppendingPathComponent:@"Library"]
									 stringByAppendingPathComponent:@"Application Support"]
									stringByAppendingPathComponent:@"Kryptomator"];
		if( !([fm fileExistsAtPath:appSupportPath isDirectory:&isDir] && isDir))
			[fm createDirectoryAtPath:appSupportPath attributes:nil];
		
		
		// set play sound
        NSDirectoryEnumerator *soundEnumerator;
		NSArray *soundDirectories = [NSArray arrayWithObjects: @"/System/Library/Sounds",
									 [NSHomeDirectory() stringByAppendingPathComponent: @"Library/Sounds"], nil];
        NSString *soundPath, *soundDirectory, *sound;
		NSMutableArray * sounds = [NSMutableArray array];
		for (soundDirectory in soundDirectories){
			// get list of all sounds and sort alphabetically
			soundEnumerator = [fm enumeratorAtPath:soundDirectory];
			while ((soundPath = [soundEnumerator nextObject])){
				sound = [soundPath stringByDeletingPathExtension];
				if ([NSSound soundNamed: sound])
					[sounds addObject: sound];
				availableSounds = [[sounds sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] retain];
				
				
			}
		}
		
		
	}
	return self;
}



- (void) windowDidLoad
{
	[self setMainView:pluginView];
}

#pragma mark IBActions

- (IBAction)addPlugin:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:YES];
	[openPanel beginSheetForDirectory:nil
								 file:nil
								types:nil
					   modalForWindow:[self window]
						modalDelegate:self
					   didEndSelector:@selector(addPluginsPanelDidEnd:returnCode:contextInfo:)
						  contextInfo:NULL];
	
}

-(void)addPluginsPanelDidEnd:(NSOpenPanel*)openPanel
				  returnCode:(int)returnCode
				 contextInfo:(void*)context
{
	
	if(returnCode == NSOKButton){
		NSString *path;
		NSMutableDictionary *pluginInfo;
		for(path in [openPanel filenames]){
			pluginInfo = [pluginVerifier dictionaryForPluginAtPath:path];
			if(pluginInfo != nil){
				NSMutableArray *defaultPluginsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"plugins"]];
				
				//generate new path for plugin file
				NSString *destination = [[[[NSHomeDirectory()
											stringByAppendingPathComponent:@"Library"]
										   stringByAppendingPathComponent:@"Application Support"]
										  stringByAppendingPathComponent:@"Kryptomator"]
										 stringByAppendingPathComponent:[path lastPathComponent]];
				
				//add the path as a property for the plugins pluginInfo
				[pluginInfo setObject:destination forKey:@"path"];
				
				if([[defaults objectForKey:@"plugins"] containsObject:pluginInfo] == NO){ //if plug-in not already there
					
					//move plugin file to generated path
					[fm copyPath:path toPath:destination handler:nil];
					//add pluginInfo dictionary to the defaults
					[defaultPluginsArray addObject:pluginInfo];
					[defaults setObject:defaultPluginsArray forKey:@"plugins"];
				}
			}
		}
		[nc postNotificationName:@"TBPluginPreferencesChanged" object:self userInfo:nil];
	}
}

- (IBAction) removePlugin:(id)sender
{
	[fm removeItemAtPath:[[[pluginArrayController selectedObjects] objectAtIndex:0] objectForKey:@"path"] error:NULL];
	[pluginArrayController remove:self];
	[nc postNotificationName:@"TBPluginPreferencesChanged" object:self userInfo:nil];
}

- (void) setMainView:(NSView *) newView
{
	NSView *view = generalView; /* default */
	NSWindow *window = [self window];
	if (newView)
		view = newView;
	
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


-(IBAction) changeToPluginView: (id)sender
{
	[self setMainView:pluginView];
}

-(IBAction) changeToGeneralView: (id)sender
{	
	[self setMainView:generalView];
}

-(IBAction) changeToEffectsView: (id)sender
{
	[self setMainView:effectsView];
}



@end
