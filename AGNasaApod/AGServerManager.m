//
//  AGServerManager.m
//  AGNasaApod
//
//  Created by User on 21.03.16.
//  Copyright © 2016 User. All rights reserved.
//

#import "AGServerManager.h"
#import "AFNetworking.h"
#import "AFURLConnectionOperation.h"

@interface AGServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation AGServerManager

+ (AGServerManager*) sharedManager {
    
    static AGServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AGServerManager alloc] init];
    });
    
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.nasa.gov/planetary/apod?"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        [self.requestOperationManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        self.formatter = [[NSDateFormatter alloc]init];
        self.formatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Chicago"];        //  Because they load new photo to server for their timezone
        [self.formatter setDateFormat:@"yyyy-MM-dd"];

        NSDate* now = [NSDate date];
        self.stringDateForRequest = [self.formatter stringFromDate:now];
    }
    return self;
}
- (void)getPhotoForDate:(NSString*)stringDate
               onSuccess:(void(^)(NSDictionary* responceObj))success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[self getFullURL] parameters:nil success:^(AFHTTPRequestOperation * operation, NSDictionary* responseObject) {
        NSLog(@"JSON: %@",responseObject);
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation* operation, NSError*  error) {
      
            NSLog(@"Error: %@",[error localizedDescription]);
    }];
}

- (NSString*)getFullURL{
    
    self.finalURLString  = [NSString stringWithFormat:@"%@%@%@",BaseURLString,self.stringDateForRequest ,ApiKeyString];
    return self.finalURLString;
}

@end
