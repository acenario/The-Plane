//
//  Circles.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "Circles.h"
#import <Parse/PFObject+Subclass.h>

@implementation Circles
+ (NSString *)parseClassName {
    return @"Circles";
}

@dynamic user;
@dynamic name;
@dynamic members;
@dynamic posts;
@dynamic owner;

@end