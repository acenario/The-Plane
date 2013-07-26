//
//  SocialPosts.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SocialPosts.h"
#import <Parse/PFObject+Subclass.h>

@implementation SocialPosts
+ (NSString *)parseClassName {
    return @"SocialPosts";
}

//@dynamic objectId;
@dynamic text;
@dynamic circle;
@dynamic user;
@dynamic comments;

@end