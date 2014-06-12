//
//  ItemDownloader.h
//  NSProgressDemo
//

#import <Foundation/Foundation.h>

@interface ItemDownloader : NSObject

- (void)downloadItemAtURL:(NSURL *)url completionHandler:(void (^)(NSData *downloadedData))handler;

@end
