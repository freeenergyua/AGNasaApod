//
//  ViewController.h
//  AGNasaApod
//
//  Created by User on 21.03.16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGServerManager.h"
#import "AFNetworking.h"

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView* webView;
@property (weak, nonatomic) IBOutlet UIToolbar* toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* saveToLibraryButton;
@property (weak, nonatomic) IBOutlet UITextView* textView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong, nonatomic) UIActivityIndicatorView* indicator;
@property (strong,nonatomic) AGServerManager* serverManager;
@property (assign,nonatomic) BOOL isTextAnimationFinished;

- (IBAction)actionSaveToLibrary:(id)sender;
- (void) getPhotoFromServer;

@end

