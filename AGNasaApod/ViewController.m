//
//  ViewController.m
//  AGNasaApod
//
//  Created by User on 21.03.16.
//  Copyright © 2016 User. All rights reserved.
//

#define INDICATOR_LENGHT 50
#import "ViewController.h"

static NSString* const firstDateString = @"1995-06-22";//http://apod.nasa.gov/apod/archivepix.html

@interface ViewController ()<UIWebViewDelegate>
@property (strong,nonatomic) UIImageView* astro;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.serverManager = [AGServerManager sharedManager];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-INDICATOR_LENGHT/2,CGRectGetMidY(self.view.frame)-INDICATOR_LENGHT, INDICATOR_LENGHT, INDICATOR_LENGHT)];
    self.indicator.color = [UIColor redColor];
    [self.webView setScalesPageToFit:YES];
    self.isTextAnimationFinished = YES;

    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:rightSwipeGesture];
    [self.view addGestureRecognizer:leftSwipeGesture];
    
    [_webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:rightSwipeGesture];
    [_webView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:leftSwipeGesture];
   
    [self performSelectorInBackground:@selector(getPhotoFromServer) withObject:nil];
    [self.view  addSubview:self.indicator];
}
#pragma mark - Text Animation

- (void)animateLabelShowText:(NSString*)newText characterDelay:(NSTimeInterval)delay {
    self.isTextAnimationFinished = NO;
   
    [self.titleLabel setText:@""];
    
    for (int i=0; i<newText.length; i++)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self.titleLabel setText:[NSString stringWithFormat:@"%@%C", self.titleLabel.text, [newText characterAtIndex:i]]];
                       });
        
        [NSThread sleepForTimeInterval:delay];
    }
    self.isTextAnimationFinished = YES;
}

#pragma mark - Work with date

- (void)oneDayRemove{
    
    NSDate* startDate = [self.serverManager.formatter dateFromString:self.serverManager.stringDateForRequest];
    NSDate* finalDate = [[NSDate alloc]init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = -1;
    finalDate = [calendar dateByAddingComponents:components toDate:startDate options: 0];
    self.serverManager.stringDateForRequest = [self.serverManager.formatter stringFromDate:finalDate];
}
- (void)oneDayAdd{
    
    NSDate* startDate = [self.serverManager.formatter dateFromString:self.serverManager.stringDateForRequest];
    NSDate* finalDate = [[NSDate alloc]init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    finalDate = [calendar dateByAddingComponents:components toDate:startDate options: 0];
    self.serverManager.stringDateForRequest = [self.serverManager.formatter stringFromDate:finalDate];

}

#pragma mark - API/Server Data

- (void) getPhotoFromServer {
  
    if ([self isAvailableDate:self.serverManager.stringDateForRequest]) {
       
        AGServerManager* serverManager = [AGServerManager sharedManager];

        [serverManager getPhotoForDate:serverManager.stringDateForRequest onSuccess:^(NSDictionary *responceObj) {
            
            NSLog(@"%@",[responceObj objectForKey:@"media_type"]);
            
            if ([[responceObj objectForKey:@"media_type"]isEqualToString:@"video"]){
                self.serverManager.isIMGformat = NO;
            } else {
                self.serverManager.isIMGformat = YES;
            }
            self.serverManager.photoURLString = [responceObj objectForKey:@"url"];
            NSURL* url = [NSURL URLWithString:self.serverManager.photoURLString];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:request];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setParameters:responceObj];
                
            });
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            [self serverError:error];
            
        }];
    }
}

- (void)setParameters:(NSDictionary*)responceObj {
    
    self.textView.text = [responceObj objectForKey:@"explanation"];
    
    if ([responceObj objectForKey:@"copyright"] != nil) {
        
        [self.textView setContentOffset:CGPointZero];
         NSString* totalString = [NSString stringWithFormat:@"Author:%@ Date:%@",[responceObj objectForKey:@"copyright"],[responceObj objectForKey:@"date"]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           [self animateLabelShowText:totalString characterDelay:0.02];
                       });
    } else {
        
        [self.textView setContentOffset:CGPointZero];
        NSString* totalString = [NSString stringWithFormat:@"Date:%@",[responceObj objectForKey:@"date"]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           [self animateLabelShowText:totalString characterDelay:0.02];
                       });
    }
}

//check if the date is correct. APOD started work at
- (BOOL)isAvailableDate:(NSString*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *firstDate = [[NSDate alloc] init];
    firstDate = [dateFormatter dateFromString:firstDateString];
    NSDate *lastDate = [[NSDate alloc] init];
    lastDate = [dateFormatter dateFromString:date];
    
    if([firstDate compare:lastDate] == NSOrderedAscending) {
        return YES;
    } else if (([firstDate compare:[dateFormatter dateFromString:date]] == NSOrderedDescending)) {
        //request date < 22-06-1995 when project started
        return YES;
    }
    NSLog(@"NSOrderedSame");
    return NO;
}

#pragma mark - Gestures

- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipe {
    
    if (self.isTextAnimationFinished == YES) {
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"UISwipeGestureRecognizerDirectionRight");
            [self oneDayRemove];
            [self performSelectorInBackground:@selector(getPhotoFromServer) withObject:nil];
        } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft){
            NSLog(@"UISwipeGestureRecognizerDirectionLeft");
            [self oneDayAdd];
            [self performSelectorInBackground:@selector(getPhotoFromServer) withObject:nil];
        }
    }
}

#pragma mark - PhotoSave

- (IBAction)actionSaveToLibrary:(id)sender {
    
    if (self.serverManager.isIMGformat == NO) {
        //alert can't save video
        [self cantSaveVideo];
    } else {
        __block NSData *storeImageData;
       
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_sync(queue, ^{
            //load url image into NSData
            storeImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.serverManager.photoURLString]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //convert data into image after completion
                UIImage *storeImage = [UIImage imageWithData:storeImageData];
                UIImageWriteToSavedPhotosAlbum(storeImage,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
                
            });
        });
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
   
    // Unable to save the image
    if (error) {
        UIAlertController * alert =   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"No photo for this date"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self oneDayRemove];
                                        [self getPhotoFromServer];
                           
        [alert addAction:yesButton];}];

        [self presentViewController:alert animated:YES completion:nil];
        } else {
        // All is well
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Photo saving"
                                      message:@"Success! Image Saved"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
    
                                    }];
            
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];

        }
}

#pragma mark Alerts

- (void)cantSaveVideo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                             message:@"Video from Youtube.com can't be saved"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)notAvailablePhotoForThisDayYet {
 
    UIAlertController* alertController =   [UIAlertController
                                 alertControllerWithTitle:@"Alert"
                                 message:@"Not available photo for this day yet. Download photo for day before"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

    }];
    [alertController addAction:okAction];
   
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)serverError:(NSError*)error {
    
    UIAlertController* alertController =   [UIAlertController
                                            alertControllerWithTitle:@"Server Error"
                                            message:[error localizedDescription]
                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIWebViewDelegate 

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
}

@end
