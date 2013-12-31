//
//  Requests.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "Circles.h"
#import "UserInfo.h"

@interface Requests : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) Circles *circle;
@property (retain) UserInfo *sender;
@property (retain) UserInfo *receiver;
@property (retain) NSString *senderUsername;
@property (retain) NSString *receiverUsername;


@end
