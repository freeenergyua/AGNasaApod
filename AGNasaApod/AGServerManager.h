//
//  AGServerManager.h
//  AGNasaApod
//
//  Created by User on 21.03.16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const BaseURLString = @"https://api.nasa.gov/planetary/apod?date=";
static NSString* const ApiKeyString = @"&hd=True&api_key=O3w4h3x75tCcqlzaHKAKPwD7o9KSfPxwJpPpLrBt";

static NSString* const FullString = @"https://api.nasa.gov/planetary/apod?date=2015-04-27&hd=True&api_key=O3w4h3x75tCcqlzaHKAKPwD7o9KSfPxwJpPpLrBt";

@interface AGServerManager : NSObject

//key O3w4h3x75tCcqlzaHKAKPwD7o9KSfPxwJpPpLrBt
//https://api.nasa.gov/planetary/apod?date=2015-04-27&hd=True&api_key=O3w4h3x75tCcqlzaHKAKPwD7o9KSfPxwJpPpLrBt

@property (strong, nonatomic) NSString* stringDateForRequest;
@property (strong, nonatomic) NSString* finalURLString;
@property (strong, nonatomic) NSString* photoURLString;
@property (assign, nonatomic) BOOL isIMGformat;
@property (strong, nonatomic) NSDateFormatter* formatter;

+ (AGServerManager*) sharedManager;

- (void)getPhotoForDate:(NSString*)stringDate
              onSuccess:(void(^)(NSDictionary* responceObj))success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;




@end
