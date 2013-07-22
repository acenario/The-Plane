//
//  CirclesViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/20/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserInfo.h"
#import "Comments.h"
#import "SocialPosts.h"
#import "Circles.h"

@class CirclesViewController;

@protocol CirclesDelegate <NSObject>

@end

@interface CirclesViewController : PFQueryTableViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) id <CirclesDelegate> delegate;
//@property NSInteger count;
//- (IBAction)segmentedSwitch:(id)sender;

@end
