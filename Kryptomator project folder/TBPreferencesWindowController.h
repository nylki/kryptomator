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
//#import "TDObject.h"
#import "TBPluginVerifier.h"



@interface TBPreferencesWindowController : NSWindowController
{
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *removeButton;
    IBOutlet NSTableView *installedPluginsTableView;
	IBOutlet NSArrayController *pluginArrayController;
	IBOutlet NSView *pluginView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *effectsView;
	IBOutlet NSToolbar *toolbar;
	
	TBPluginVerifier *pluginVerifier;
    NSUserDefaults *defaults;    
	NSFileManager *fm;
	NSNotificationCenter *nc;
	
	NSArray *availableSounds;
	
}

@property NSArray *availableSounds;
+ (TBPreferencesWindowController *)preferencesWindowController;

- (IBAction)addPlugin:(id)sender;
- (IBAction)removePlugin:(id)sender;

- (void) setMainView:(NSView *) newView;

-(IBAction) changeToGeneralView: (id)sender;
-(IBAction) changeToPluginView: (id)sender;
-(IBAction) changeToEffectsView: (id)sender;
@end
