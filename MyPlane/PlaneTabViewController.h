//
//  PlaneTabViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "UserInfo.h"


@interface PlaneTabViewController : UITabBarController

@property (nonatomic, strong) PFObject *userInfoObject;
@property (nonatomic, strong) PFObject *userInfoFriends;


@end
