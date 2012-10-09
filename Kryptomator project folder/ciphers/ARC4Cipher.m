//
//  ROT128KryptomatorOperation.m
//  ROT128KryptomatorPlugin
//
//  Created by Tom on 18.12.07.
//  Copyright 2007 Scratchdrive. All rights reserved.
//

//You are welcome to make suggestion for other layout of the operationPlugins

//this is a a subclass of a NSOperation to be used in a NSOperationQueue, there the main() function

#import "ARC4Cipher.h"



@implementation ARC4Cipher

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
	arc4_init(&s, rawKey, 20);
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
		
		if (self.isDecryptionOperation)
		{
			arc4_crypt(&s, buffer, buffer, readBytes);
		} 
		else if (self.isEncryptionOperation) 
		{
			arc4_crypt(&s, buffer, buffer, readBytes);		
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
	return @"ARC4";   //the name of your plugin
}

+ (NSString*) pluginInfo
{  
	//short description of the plugin
	return @"ARC4 cipher plugin that uses a SHA-1 based key derivation function.";
}

+ (NSString*) categorie
{
	return nil;   //a categorie
}



@end
