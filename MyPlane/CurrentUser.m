//
//  CurrentUser.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

@synthesize currentUser;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static CurrentUser *sharedCurrentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCurrentUser = [[self alloc] init];
    });
    return sharedCurrentUser;
}

- (id)init {
    if (self = [super init]) {
        currentUser = nil;
    }
    return self;
}

//How to use
//CurrentUser *sharedManager = [CurrentUser sharedManager];
//sharedManager.currentUser = nil;

@end
