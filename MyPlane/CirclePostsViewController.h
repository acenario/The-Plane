//
//  CirclePostsViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import "SocialPostDetailViewController.h"

@class CirclePostsViewController;

@protocol CirclePostsViewControllerDelegate <NSObject>

@end

@interface CirclePostsViewController : PFQueryTableViewController

@property (nonatomic, weak) id <CirclePostsViewControllerDelegate> delegate;

@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) UserInfo *currentUser;

@end
 