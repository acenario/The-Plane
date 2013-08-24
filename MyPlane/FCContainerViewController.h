//
//  FCContainerViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirclesViewController.h"
#import "FriendsQueryViewController.h"

@interface FCContainerViewController : UIViewController <FriendsQueryViewControllerDelegate, CirclesDelegate>

@property (strong, nonatomic) IBOutlet UIView *FCContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *circContainer;

- (IBAction)changePage:(id)sender;

@end
