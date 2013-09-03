//
//  CirclesViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/20/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "UserInfo.h"
#import "Comments.h"
#import "SocialPosts.h"
#import "Circles.h"
#import "JoinCircleViewController.h"
#import "CircleRequestsViewController.h"
#import "CircleDetailViewController.h"
#import "JoinCircleViewController.h"
#import "CreateCircleViewController.h"
#import "UzysSlideMenu.h"

@class CirclesViewController;

@protocol CirclesDelegate <NSObject>

- (void)circlesSegmentDidChange:(UISegmentedControl *)segmentedController;

@end

@interface CirclesViewController : PFQueryTableViewController <JoinCircleViewController, CircleRequestsViewControllerDelegate, CircleDetailViewControllerDelegate, CreateCircleViewControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet FUISegmentedControl *segmentedController;
@property (strong, nonatomic) id <CirclesDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *requestButton;
- (IBAction)circleMenu:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)unwindToCircles:(UIStoryboardSegue *)unwindSegue;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;

//@property NSInteger count;
//- (IBAction)segmentedSwitch:(id)sender;

@end
 