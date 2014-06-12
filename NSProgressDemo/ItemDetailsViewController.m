//
//  ItemDetailsViewController.m
//  NSProgressDemo
//

#import "ItemDetailsViewController.h"

#import "ItemDownloader.h"

static void *DownloadProgressContext = &DownloadProgressContext;
static NSString * const FractionCompletedKeyPath = @"fractionCompleted";
static NSString * const DownloadURLString = @"http://www.fillmurray.com/1000/1000/";

@interface ItemDetailsViewController ()

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) ItemDownloader *downloader;
@property (nonatomic, strong) NSProgress *progress;

- (IBAction)downloadButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;

@end

@implementation ItemDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressView.progress = 0.0;
}


- (IBAction)downloadButtonTapped:(id)sender;
{
    if (!self.downloader) {
        self.downloader = [[ItemDownloader alloc] init];
    }
    
    self.progressView.progress = 0.0;
    
    self.progress = [NSProgress progressWithTotalUnitCount:1];
    [self.progress addObserver:self forKeyPath:FractionCompletedKeyPath options:NSKeyValueObservingOptionInitial context:DownloadProgressContext];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    
    [self.downloader downloadItemAtURL:[NSURL URLWithString:DownloadURLString] completionHandler:^(NSData *downloadedData) {
        NSLog(@"downloadedData.length: %d", [downloadedData length]);
        [self.progress removeObserver:self forKeyPath:FractionCompletedKeyPath context:DownloadProgressContext];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIImage *image = [UIImage imageWithData:downloadedData];
            self.imageView.image = image;
        }];
    }];
    
    [self.progress resignCurrent];
}

- (IBAction)resetButtonTapped:(id)sender;
{
    self.progressView.progress = 0.0;
    self.imageView.image = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((context == DownloadProgressContext) && ([keyPath isEqualToString:FractionCompletedKeyPath])) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"progress.fractionCompleted: %f", self.progress.fractionCompleted);
            self.progressView.progress = self.progress.fractionCompleted;
        }]; 
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
