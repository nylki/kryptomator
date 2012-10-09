//
//  ROT128KryptomatorOperation.h
//  ROT128KryptomatorPlugin
//
//  Created by Tom on 18.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KryptomatorCipherProtocol.h"


@interface ROT128Cipher : NSOperation <KryptomatorCipherProtocol>
{
	BOOL isEncryptionOperation;
	BOOL isDecryptionOperation;
	
	NSString *TBEncryptionOperationKey;
	NSString *TBDecryptionOperationKey;
	
	NSString *pluginInfo;
	NSString *pluginName;
	NSString *key;
	NSString *destinationPath;
	NSString *sourcePath;
}

+ (BOOL) needsPassword;
+ (NSString*) pluginName;
+ (NSString*) pluginInfo;
+ (NSString*) categorie;

- (id)initCryptoOperationOfType: (NSString*)cryptoKind
				 withSourcePath:(NSString*)source
				destinationPath:(NSString*)destination
					   password:(NSString*)password;

-(void)decryptBuffer  : (unsigned char*)buffer
		   toPosition : (unsigned char*)stop;

-(void)encryptBuffer  : (unsigned char*)buffer
		   toPosition : (unsigned char*)stop;

@property(readwrite) BOOL isEncryptionOperation;
@property(readwrite) BOOL isDecryptionOperation;
@property(readwrite,copy) NSString *key;
@property(readwrite,copy) NSString *destinationPath;
@property(readwrite,copy) NSString *sourcePath;

@end
