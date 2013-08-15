//
//  Requests.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "Requests.h"
#import <Parse/PFObject+Subclass.h>

@implementation Requests
+ (NSString *)parseClassName {
    return @"Requests";
}

@dynamic circle;
@dynamic invitedBy;
@dynamic invited;
@dynamic requester;
@dynamic requesterUsername;
@dynamic inviterUsername;
@dynamic invitedUsername;

@end
