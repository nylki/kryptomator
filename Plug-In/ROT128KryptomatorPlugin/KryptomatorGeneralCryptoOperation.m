//
//  ROT128KryptomatorOperation.m
//  ROT128KryptomatorPlugin
//
//  Created by Tom on 18.12.07.
//  Copyright 2007 Scratchdrive. All rights reserved.
//

//You are welcome to make suggestion for other layout of the operationPlugins

//this is a a subclass of a NSOperation to be used in a NSOperationQueue, there the main() function

#import "KryptomatorGeneralCryptoOperation.h"

NSString *TBEncryptionOperationKey = @"encryptionOperation";
NSString *TBDecryptionOperationKey = @"decryptionOperation";

@implementation KryptomatorGeneralCryptoOperation

//'synthesize' automatically creates setter and getter methods for the property
@synthesize isEncryptionOperation;
@synthesize isDecryptionOperation;
@synthesize sourcePath;
@synthesize destinationPath;
@synthesize key;


- (id)initCryptoOperationOfType:(NSString*)cryptoKind //encryption or decryption
				 withSourcePath:(NSString*)source
				destinationPath:(NSString*)destination
					   password:(NSString*)password  //password is a password the user inputs, you can do with it, whatever you want, create keys etc.
													//in a different function
{
	self = [super init];
	
	self.isEncryptionOperation = ([cryptoKind isEqualToString:TBEncryptionOperationKey]) ? YES : NO;
	self.isDecryptionOperation = ([cryptoKind isEqualToString:TBDecryptionOperationKey]) ? YES : NO;
	self.key = password; //key creation functions can be applied here
	self.sourcePath = source;
	self.destinationPath = destination;
	
    return self;
}

-(void)decryptBuffer  : (unsigned char*)buffer
		   toPosition : (unsigned char*)stop
{
	while (buffer < stop) {
		*buffer += 128;
		buffer++;
	}
}

-(void)encryptBuffer  : (unsigned char*)buffer
		   toPosition : (unsigned char*)stop
{
	while (buffer < stop) {
		*buffer += 128;
		buffer++;
	}
}

-(void)main
{
	
	/* the main function read in the data, and uses other function to encrypt/decrypt the buffer */
	unsigned char *stop;
	unsigned char buffer[262144]; //256 kilobyte
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
			[self decryptBuffer:buffer
					 toPosition:stop];
		} 
		else if (self.isEncryptionOperation) 
		{
			[self encryptBuffer:buffer
					 toPosition:stop];		
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
	return NO;  //set if your cipher needs a password as input
}

+ (NSString*) pluginName
{
	return @"binary ROT128";   //the name of your plugin
}

+ (NSString*) pluginInfo
{  
	//short description of the plugin
	return @"Performs a ROT128 cipher operation on the binary, so all decimal values of all characters are shifted by 128, not only the alphabetics. Encrypt and Decrypt will have same result...";
}



@end
