//
//  CircleMembersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@class CircleMembersViewController;

@protocol CircleMembersViewControllerDelegate <NSObject>

@end

@interface CircleMembersViewController : PFQueryTableViewController

@property (nonatomic, weak) id <CircleMembersViewControllerDelegate> delegate;

@property (nonatomic, strong) Circles *circle;

@end
