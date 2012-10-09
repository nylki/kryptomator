//
//  TBPluginController.m
//  Kryptomator
//
//  Created by tom on 07.09.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


//#import <Foundation/Foundation.h>
#import "TBPluginVerifier.h"
#import "KryptomatorCipherProtocol.h"

@implementation TBPluginVerifier

- (id) init
{
	self = [super init];
	if (self != nil) {
		TBEncryptionOperationKey = @"encryptionOperation";
		TBDecryptionOperationKey = @"decryptionOperation";
	}
	return self;
}


- (NSMutableDictionary*) dictionaryForPluginAtPath: (NSString*) path
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSBundle *plugin;
	Class principalClass;

		if(! ([[path pathExtension] isEqualToString:@"bundle"])){
			NSLog(@"no bundle at path: %@", path);
			return nil;
		}
		
		plugin = [NSBundle bundleWithPath:path];
		if (!plugin) {
			NSLog (@"could not load plug-in at path %@", path);
			return nil;
		}
		
		principalClass = [plugin principalClass];
		if(!principalClass){
			NSLog(@"Could not load principal class for plug-in at path %@!\nMake sure the principalClass target setting is correct",path);
			return nil;
		}
		
		if(![principalClass conformsToProtocol:@protocol(KryptomatorCipherProtocol)]){
			NSLog(@"Plug-in does not conform the KryptomatorCipher-Protocol! ( %@ )",path);
			return nil;
		}
		
		NSMutableDictionary *pluginFileDictionary = [[NSMutableDictionary alloc]initWithCapacity:4];
		[pluginFileDictionary addEntriesFromDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[principalClass pluginName], @"pluginName", 
			path, @"path",
			[principalClass pluginInfo], @"pluginInfo",
			nil]];
		NSLog(@"succesfully verified plugin: %@",[principalClass pluginName]);
		[plugin release];
		return pluginFileDictionary;
}

- (id) pluginClassAtPath: (NSString*) path
{
	
	if(! ([[path pathExtension] isEqualToString:@"bundle"]))
		return nil;
	
	NSBundle *plugin;
    Class principalClass;
	
    NSLog (@"processing plug-in: %@", path);
	
    plugin = [NSBundle bundleWithPath:path];
	
    if (plugin == nil) {
        NSLog (@"could not load plug-in at path %@", path);
        return nil;
    }
	
    principalClass = [plugin principalClass];
	
	if(principalClass == nil){
		NSLog(@"Could not load principal class for plug-in at path %@!\nMake sure the principalClass target setting is correct",path);
		return nil;
	}
	
	if(![principalClass conformsToProtocol:@protocol(KryptomatorCipherProtocol)]){
		NSLog(@"Plug-in does not conform the KryptomatorCipher-Protocol! ( %@ )",path);
		return nil;
	}

	NSLog(@"%@ succesfully loaded...",[principalClass pluginName]);
	NSLog(@"plugin-info: %@",[principalClass pluginInfo]);
	return principalClass;
}	

			
@end
