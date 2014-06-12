//
//  ItemDownloader.m
//  NSProgressDemo
//

#import "ItemDownloader.h"

@interface ItemDownloader () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *dataDownloaded;
@property (nonatomic, strong) NSProgress *progress;

@property (nonatomic, copy) void (^handler)(NSData *downloadedData);

@end

@implementation ItemDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)downloadItemAtURL:(NSURL *)url completionHandler:(void (^)(NSData *downloadedData))handler;
{
    NSParameterAssert(url);
    
    if (self.dataTask) {
        // Only allow one download at a time.
        return;
    }
    
    self.handler = handler;
    
    self.dataDownloaded = [[NSMutableData alloc] init];
    self.dataTask = [self.session dataTaskWithURL:url];
    
    self.progress = [NSProgress progressWithTotalUnitCount:self.dataTask.countOfBytesExpectedToReceive];
    self.progress.cancellable = NO;
    self.progress.pausable = NO;
    
    [self.dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    // Update Progress
    int64_t totalExpected = dataTask.countOfBytesExpectedToReceive;
    NSLog(@"totalExpected: %lld", totalExpected);
    
    int64_t totalRecieved = dataTask.countOfBytesReceived;
    NSLog(@"totalRecieved: %lld", totalRecieved);
    
    
    self.progress.totalUnitCount = totalExpected;
    self.progress.completedUnitCount = totalRecieved;

    // Update Data
    [self.dataDownloaded appendData:data];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
{
    if (self.handler) {
        NSData *data = [NSData dataWithData:self.dataDownloaded];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.handler(data);
        }];
        self.dataDownloaded = nil;
        self.dataTask = nil;
        self.progress = nil;
    }
}



@end
