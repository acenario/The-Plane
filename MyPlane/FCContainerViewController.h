//
//  FCContainerViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCContainerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *FCContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *circContainer;
- (IBAction)changePage:(id)sender;

@end
