//protocol for kryptomator cipher plug-ins

@protocol KryptomatorCipherProtocol

BOOL isEnabled;

+ (BOOL) needsPassword;
+ (BOOL)activate;
+ (void)deactivate;
+ (NSString*) pluginName;
+ (NSString*) pluginInfo;

-(BOOL)isEnabled;
-(void)setIsEnabled:(BOOL)newBool;

- (BOOL) encryptFile:(NSString*)path
			  toPath:(NSString*)newPath
		withPassword:(NSString*)password;

- (BOOL) decryptFile:(NSString*)path
			  toPath:(NSString*)newPath
		withPassword:(NSString*)password;

@end