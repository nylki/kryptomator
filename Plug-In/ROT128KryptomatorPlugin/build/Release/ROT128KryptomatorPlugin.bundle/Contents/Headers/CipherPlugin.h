//protocol for kryptomator cipher plug-ins

@protocol KryptomatorCipherProtocol

//class-methods ->

+ (BOOL) needsPassword;
+ (NSString*) pluginName;
+ (NSString*) pluginInfo;

//instance methods ->

@property(readwrite) BOOL isEncryptionOperation;
@property(readwrite) BOOL isDecryptionOperation;
@property(readwrite,copy) NSString *key;
@property(readwrite,copy) NSString *destinationPath;
@property(readwrite,copy) NSString *sourcePath;


- (id)initCryptoOperationOfKind: (NSString*)cryptoKind
				 withSourcePath:(NSString*)source
				destinationPath:(NSString*)destination
					   password:(NSString*)password;

-(void)main;

@end