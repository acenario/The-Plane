//
//  Comment.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "Comments.h"
#import <Parse/PFObject+Subclass.h>

@implementation Comments
+ (NSString *)parseClassName {
    return @"Comments";
}

@dynamic text;
@dynamic reminder;
@dynamic user;

@end
