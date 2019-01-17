//
//  TGHttpHandler.mm
//  TangramMap
//
//  Created by Karim Naaji on 11/23/16.
//  Copyright (c) 2017 Mapzen. All rights reserved.
//

#import "TGHttpHandler.h"

#include <string>
#include <sstream>
#include <iostream>

@interface TGHttpHandler()

@property (strong, nonatomic) NSURLSession* session;
@property (strong, nonatomic) NSURLSessionConfiguration* configuration;
@property (nonatomic) BOOL offlineMode;

+ (NSURLSessionConfiguration*)defaultConfiguration;

@end

@implementation TGHttpHandler

@synthesize HTTPAdditionalHeaders = _HTTPAdditionalHeaders;

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];

    if (self) {
        [self initialSetupWithConfiguration:[TGHttpHandler defaultSessionConfiguration]];
    }

    return self;
}


- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];

    if (self) {
        [self initialSetupWithConfiguration:configuration];
    }

    return self;
}

- (instancetype)initWithCachePath:(NSString*)cachePath cacheMemoryCapacity:(NSUInteger)memoryCapacity cacheDiskCapacity:(NSUInteger)diskCapacity
{
    self = [super init];

    if (self) {
        [self initialSetupWithConfiguration:[TGHttpHandler defaultSessionConfiguration]];
        [self setCachePath:cachePath cacheMemoryCapacity:memoryCapacity cacheDiskCapacity:diskCapacity];
    }

    return self;
}

- (void)initialSetupWithConfiguration:(NSURLSessionConfiguration *)configuration {
    self.configuration = configuration;
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    self.HTTPAdditionalHeaders = [[NSMutableDictionary alloc] init];

}

#pragma mark - Class Methods

+ (NSURLSessionConfiguration*)defaultSessionConfiguration
{
    NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    sessionConfiguration.timeoutIntervalForRequest = 30;
    sessionConfiguration.timeoutIntervalForResource = 60;

    return sessionConfiguration;
}

#pragma mark - Custom Getter/Setters

- (NSMutableDictionary *)HTTPAdditionalHeaders {
    return _HTTPAdditionalHeaders;
}

- (void)setAdditionalHTTPHeaders:(NSMutableDictionary *)HTTPAdditionalHeaders {
    _HTTPAdditionalHeaders = HTTPAdditionalHeaders;
    self.configuration.HTTPAdditionalHeaders = HTTPAdditionalHeaders;
    self.session = [NSURLSession sessionWithConfiguration:self.configuration];
}

- (void)setCachePath:(NSString*)cachePath cacheMemoryCapacity:(NSUInteger)memoryCapacity cacheDiskCapacity:(NSUInteger)diskCapacity
{
    NSURLCache* tileCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity
                                                          diskCapacity:diskCapacity
                                                              diskPath:cachePath];

    self.configuration.URLCache = tileCache;
    self.configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    self.session = [NSURLSession sessionWithConfiguration:self.configuration];
}

#pragma mark - Instance Methods



- (NSUInteger)downloadRequestAsync:(NSString*)url completionHandler:(TGDownloadCompletionHandler)completionHandler
{
    
   
    
    NSString * urlz;
    NSString * urlx;
    NSString * urly;
    NSData * data1;
    NSString* urlNsstring = [NSURL URLWithString:url].absoluteString;
    std::string urlString = [urlNsstring UTF8String];
    auto loc = urlString.find("v3");
    
    if (loc > 100){
        
        NSURLSessionDataTask* dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:url]
                                                     completionHandler:completionHandler];
        
        [dataTask resume];
        return [dataTask taskIdentifier];
    }else{
        NSString *sep = @"/.";
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
        NSArray<NSString *> * saperated = [urlNsstring componentsSeparatedByCharactersInSet: set];
        
        for(int i = 0 ; i < [saperated count] ; i++ ){
            if([saperated[i]  isEqual: @"v3"]){
                urlz = saperated[i + 1];
                urlx = saperated[i + 2];
                urly = saperated[i + 3];
                break;
            }
        }
        NSString * fileName = urlz;
        fileName = [fileName stringByAppendingString:@"a"];
        fileName = [fileName stringByAppendingString:urlx];
        fileName = [fileName stringByAppendingString:@"a"];
        fileName = [fileName stringByAppendingString:urly];
        fileName = [fileName stringByAppendingString:@".tile"];
        
        data1 = readFile_getNSData([fileName UTF8String]);
    }
    
    if(_offlineMode || data1 != nullptr){
        
         dispatch_async(dispatch_get_main_queue(), ^{
             completionHandler(data1 , nullptr ,nullptr );
        });
        return  2;
    }else{
        NSURLSessionDataTask* dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:url]
                                                     completionHandler:completionHandler];
        
        [dataTask resume];
        
        return  [dataTask taskIdentifier];
    }
    
}

- (void)cancelDownloadRequestAsync:(NSUInteger)taskIdentifier
{
    [self.session getTasksWithCompletionHandler:^(NSArray* dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        for (NSURLSessionTask* task in dataTasks) {
            if ([task taskIdentifier] == taskIdentifier) {
                [task cancel];
                break;
            }
        }
    }];
}
static NSString * getDocFilePath(const char* fileName)
{
    // 파일 경로
    
    NSFileManager *fileManager;
    fileManager = [NSFileManager defaultManager];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    docsDir = [docsDir stringByAppendingPathComponent:@"offLineMap"];
    
    [fileManager createDirectoryAtPath:docsDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString * fName = [[NSString alloc] initWithBytesNoCopy: (void*) fileName
                                                      length:strlen(fileName)encoding: NSUTF8StringEncoding freeWhenDone: NO];
    
    
    return [docsDir stringByAppendingPathComponent:fName];
}
static const char* fNamePtr_append;
static NSFileHandle* _fHandle_append;

bool System_openFileToReWrite(const char *fileName)
{
    NSString * fileAtPath = getDocFilePath(fileName);
    
    _fHandle_append = [NSFileHandle fileHandleForWritingAtPath: fileAtPath];
    
    if(!_fHandle_append) {
        if(![[NSFileManager defaultManager] createFileAtPath: fileAtPath contents: nil attributes: nil]) {
            return false;
        }
        _fHandle_append = [NSFileHandle fileHandleForWritingAtPath: fileAtPath];
    }else{
        
        if(![[NSFileManager defaultManager] removeItemAtPath: fileAtPath error: nil]) {
            return false;
        }
        
        if(![[NSFileManager defaultManager] createFileAtPath: fileAtPath contents: nil attributes: nil]) {
            return false;
        }
        
        _fHandle_append = [NSFileHandle fileHandleForWritingAtPath: fileAtPath];
        
    }
    if(_fHandle_append != nil) {
        fNamePtr_append = fileName;
        return true;
    }
    return false;
}
NSData * readFile_getNSData(const char* fileName)
{
    NSData* data = [NSData dataWithContentsOfFile: getDocFilePath(fileName)];
    if(data){
        return data;
    }else{
        return nullptr;
    }
}
char * System_readFile_getString(const char* fileName)
{
    NSData* data = [NSData dataWithContentsOfFile: getDocFilePath(fileName)];
    
    if(data) {
        const void *_Nullable rawData = [data bytes];
        char *src = (char *)rawData;
        return src;
    } else {
        return nullptr;
    }
}

void System_appendToFile(const char *fileName, NSData * data){
    NSString * fileAtPath = getDocFilePath(fileName);
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath: fileAtPath];
    
    if(!fileHandle) { // file이 존재할 경우 append
        if(![[NSFileManager defaultManager] createFileAtPath: fileAtPath contents: nil attributes: nil]) {
        }
        fileHandle = [NSFileHandle fileHandleForWritingAtPath: fileAtPath];
    }
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
    
    return;
}

-(NSUInteger)offlineMapDownloadWithURL:(NSString*)url successfunc:(offlineDownloadCompletionHandler)successFunc
{
    
    
    
    NSURLSessionDataTask* dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:url]
                                                 completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
                                                     
                                                     NSString * urlz;
                                                     NSString * urlx;
                                                     NSString * urly;
                                                     
                                                     NSString* urlNsstring = [NSURL URLWithString:url].absoluteString;
                                                     std::string urlString = [urlNsstring UTF8String];
                                                     std::stringstream urlStream;
                                                     auto loc = urlString.find("v3");
                                                     if (loc < 100 && error == nil){
                                                         NSString *sep = @"/.";
                                                         NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
                                                         NSArray<NSString *> * saperated = [urlNsstring componentsSeparatedByCharactersInSet: set];
                                                         
                                                         for(int i = 0 ; i < [saperated count] ; i++ ){
                                                             if([saperated[i]  isEqual: @"v3"]){
                                                                 urlz = saperated[i + 1];
                                                                 urlx = saperated[i + 2];
                                                                 urly = saperated[i + 3];
                                                                 break;
                                                             }
                                                         }
                                                         NSString * fileName = urlz;
                                                         fileName = [fileName stringByAppendingString:@"a"];
                                                         fileName = [fileName stringByAppendingString:urlx];
                                                         fileName = [fileName stringByAppendingString:@"a"];
                                                         fileName = [fileName stringByAppendingString:urly];
                                                         fileName = [fileName stringByAppendingString:@".tile"];
                                                         
                                                         
                                                         System_openFileToReWrite(  [fileName UTF8String] );
                                                         System_appendToFile([fileName UTF8String], data);
                                                         
                                                     }
                                                     successFunc(url , error);
                                                     // System_openFileToAppend( [nStr UTF8String] );
                                                     // System_appendToFile([nStr UTF8String], data);
                                                     
                                                     
                                                 }];
    
    [dataTask resume];
    
    return [dataTask taskIdentifier];
    
}
@end
