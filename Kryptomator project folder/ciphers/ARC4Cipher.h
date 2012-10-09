//
//  ROT128KryptomatorOperation.h
//  ROT128KryptomatorPlugin
//
//  Created by Tom on 18.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KryptomatorCipherProtocol.h"

#include "arc4.h"
#include "openssl/sha.h"


@interface ARC4Cipher : NSOperation <KryptomatorCipherProtocol>
{
	BOOL isEnabled;
	BOOL isEncryptionOperation;
	BOOL isDecryptionOperation;
	
	NSString *TBEncryptionOperationKey;
	NSString *TBDecryptionOperationKey;
	
	NSString *pluginInfo;
	NSString *pluginName;
	NSString *key;
	NSString *destinationPath;
	NSString *sourcePath;
	
	unsigned char rawKey[20];
	arc4_state s;
}

+ (BOOL) needsPassword;
+ (NSString*) pluginName;
+ (NSString*) pluginInfo;
+ (NSString*) categorie;

- (id)initCryptoOperationOfType: (NSString*)cryptoKind
				 withSourcePath:(NSString*)source
				destinationPath:(NSString*)destination
					   password:(NSString*)password;


@property(readwrite) BOOL isEncryptionOperation;
@property(readwrite) BOOL isDecryptionOperation;
@property(readwrite,copy) NSString *key;
@property(readwrite,copy) NSString *destinationPath;
@property(readwrite,copy) NSString *sourcePath;

@end
