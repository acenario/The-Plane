//
//  PickCircleViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserInfo.h"
#import "Comments.h"
#import "Circles.h"

@class PickCircleViewController;

@protocol PickCircleViewControllerDelegate <NSObject>

- (void)pickCircleViewController:(PickCircleViewController *)controller didSelectCircle:(Circles *)circle;

@end

@interface PickCircleViewController : PFQueryTableViewController
- (IBAction)cancel:(id)sender;
@property (nonatomic, weak) id <PickCircleViewControllerDelegate> delegate;
@property (nonatomic, strong) PFQuery *userQuery;

@end
