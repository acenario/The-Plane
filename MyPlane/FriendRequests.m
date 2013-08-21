//
//  FriendRequests.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/21/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendRequests.h"
#import <Parse/PFObject+Subclass.h>

@implementation FriendRequests
+ (NSString *)parseClassName {
    return @"FriendRequests";
}

@dynamic sender;
@dynamic receiver;
@dynamic senderUsername;
@dynamic receiverUsername;

@end
