//
//  Circles.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface Circles : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *user;
@property (retain) NSString *name;
@property (retain) PFObject *owner;
@property (retain) NSArray *members;
@property (readonly) NSArray *posts;

@end