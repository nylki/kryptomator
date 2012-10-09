//
//  ROT128KryptomatorOperation.m
//  ROT128KryptomatorPlugin
//
//  Created by nylk on 18.12.07.
//  Copyright 2007 Scratchdrive. All rights reserved.
//

//You are welcome to make suggestion for other layout of the operationPlugins

//this is a a subclass of a NSOperation to be used in a NSOperationQueue, there the main() function

#import "AES128Cipher.h"



@implementation AES128Cipher

//'synthesize' automatically creates setter and getter methods for the property
@synthesize isEncryptionOperation;
@synthesize isDecryptionOperation;
@synthesize sourcePath;
@synthesize destinationPath;
@synthesize key;


- (id)initCryptoOperationOfType: (NSString*)cryptoKind
				 withSourcePath:(NSString*)source
				destinationPath:(NSString*)destination
					   password:(NSString*)password //password is a password the user inputs, you can do with it, whatever you want, create keys etc.


{
	self = [super init];
	TBEncryptionOperationKey = @"encryptionOperation";
	TBDecryptionOperationKey = @"decryptionOperation";
	
	self.isEncryptionOperation = ([cryptoKind isEqualToString:TBEncryptionOperationKey]) ? YES : NO;
	self.isDecryptionOperation = ([cryptoKind isEqualToString:TBDecryptionOperationKey]) ? YES : NO;
	unsigned char *keyData = (unsigned char *)[password UTF8String];
	NSLog(@"keyData: %s", keyData);
	NSLog(@"original password: %@", password); 
	
	SHA1(keyData, strlen(keyData), rawKey); // <--
	
	self.key = [[NSString alloc] initWithCString:rawKey encoding:NSUTF8StringEncoding];
	AES_set_encrypt_key(rawKey, 128,&aes_encrypt_key);
	self.sourcePath = source;
	self.destinationPath = destination;
	
    return self;
}

-(void)main
{
	
	/* the main function read in the data, and uses other function to encrypt/decrypt the buffer */
	unsigned char *stop;
	unsigned char buffer[16384];
	FILE *oldFile, *newFile;
	int result = 0;
	ssize_t readBytes;
	
	oldFile = fopen([self.sourcePath UTF8String],"r");
	if( oldFile == NULL){
		perror("could not open input file");
		return;
	}
	newFile = fopen([self.destinationPath UTF8String], "a+");
	if( newFile == NULL){
		perror("could not open output file");
		return;
	}
	while ( !feof(oldFile) ){
		if ([self isCancelled])
			break;	// user cancelled this operation
		
		readBytes = fread(buffer,sizeof(buffer[0]),sizeof(self.sourcePath),oldFile);
		if (result < 0){
			perror("error reading data");
			return;
		}

		stop = buffer + readBytes;
		NSLog(@"+");
		if (self.isDecryptionOperation)
		{
			AES_cbc_encrypt(buffer, buffer,
							AES_BLOCK_SIZE,
							&aes_encrypt_key,
							"0123456789123456", AES_DECRYPT);
		} 
		else if (self.isEncryptionOperation) 
		{
			AES_cbc_encrypt(buffer, buffer,
							AES_BLOCK_SIZE,
							&aes_encrypt_key,
							"0123456789123456", AES_ENCRYPT);	
		}
		
		fwrite(buffer,sizeof(buffer[0]),readBytes,newFile);
		strcpy(buffer,"");
	}
	fclose(newFile);
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"TBCryptoOperationDidFinish"
					  object:self
					userInfo:nil];
}

/* Class-Methods for activating/deactivating and properties like name and description
 Used to describe the plugin in the preferences etc.
 */

+ (BOOL) needsPassword
{
	return YES;  //set if your cipher needs a password as input
}

+ (NSString*) pluginName
{
	return @"AES-128";   //the name of your plugin
}

+ (NSString*) pluginInfo
{  
	//short description of the plugin
	return @"AES-128 cipher plugin that uses a SHA-1 based key derivation function.";
}

+ (NSString*) categorie
{
	return @"AES";   //a categorie
}



@end
