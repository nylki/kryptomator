//encryption and decryption is the same here
/*#import <Foundation/Foundation.h>
#import "CipherPlugin.h"


@interface ROT128KryptomatorPlugin : NSOperation <KryptomatorCipherProtocol>
{
}
@end

@implementation ROT128KryptomatorPlugin

-(BOOL)isEnabled
{
	return isEnabled;
}

-(void)setIsEnabled:(BOOL)newBool
{
	isEnabled = newBool;
}

+ (BOOL)activate
{
    NSLog (@"SimpleMessage plug-in activated");
    return (YES);
	
} // activate

+ (void)deactivate
{
    NSLog (@"SimpleMessage plug-in deactivated");
} // deactivate

+ (BOOL) needsPassword
{
	return NO;
}

+ (NSString*) pluginName
{
	return @"binary ROT128";
}

+ (NSString*) pluginInfo
{
	return @"Performs a ROT128 cipher operation on the binary, so all decimal values of all characters are shifted by 128, not only the alphabetics. Encrypt and Decrypt will have same result...";
}


- (BOOL) encryptFile:(NSString*)path
			  toPath:(NSString*)newPath
		withPassword:(NSString*)password //we don't use a password for a rot13
{
	
	unsigned char *currentChar, *stop;
	unsigned char buffer[2048];
	FILE *oldFile, *newFile;
	int result = 0;
	ssize_t readBytes;
	
	oldFile = fopen([path UTF8String],"r");
	if( oldFile == NULL){
		perror("could not open input file");
		return NO;
	}
	newFile = fopen([newPath UTF8String], "a+");
	if( newFile == NULL){
		perror("could not open output file");
		return NO;
	}
	while ( !feof(oldFile) ){
		readBytes = fread(buffer,sizeof(buffer[0]),sizeof(buffer),oldFile);
		if (result < 0){
			perror("error reading data");
			return NO;
		}
		currentChar = buffer;
		stop = buffer + readBytes;
		while (currentChar < stop) {
			*currentChar += 128;
			currentChar++;
			
		}
		fwrite(buffer,sizeof(buffer[0]),readBytes,newFile);
		strcpy(buffer,"");
	}
	fclose(newFile);
	return YES;
	
}
- (BOOL) decryptFile:(NSString*)path
			  toPath:(NSString*)newPath
		withPassword:(NSString*)password //we don't use a password for a rot13
{
	
	unsigned char *currentChar, *stop;
	unsigned char buffer[2048];
	FILE *oldFile, *newFile;
	int result = 0;
	ssize_t readBytes;
	
	oldFile = fopen([path UTF8String],"r");
	if( oldFile == NULL){
		perror("could not open input file");
		return NO;
	}
	newFile = fopen([newPath UTF8String], "a+");
	if( newFile == NULL){
		perror("could not open output file");
		return NO;
	}
	while ( !feof(oldFile) ){
		readBytes = fread(buffer,sizeof(buffer[0]),sizeof(buffer),oldFile);
		if (result < 0){
			perror("error reading data");
			return NO;
		}
		currentChar = buffer;
		stop = buffer + readBytes;
		while (currentChar < stop) {
			*currentChar += 128;
			currentChar++;
			
		}
		fwrite(buffer,sizeof(buffer[0]),readBytes,newFile);
		strcpy(buffer,"");
	}
	fclose(newFile);
	return YES;
}

@end*/
