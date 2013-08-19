//
//  AddCircleReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "ACRPickCircleViewController.h"
#import "PickMembersViewController.h"

@class AddCircleReminderViewController;

@protocol AddCircleReminderViewControllerDelegate <NSObject>

@end

@interface AddCircleReminderViewController : UITableViewController <ACRPickCircleViewControllerDelegate, PickMembersViewControllerDelegate>

@property (nonatomic, weak) id <AddCircleReminderViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) NSArray *circles;
@property (strong, nonatomic) IBOutlet UILabel *dateTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *circleLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *circleName;
@property (strong, nonatomic) IBOutlet UILabel *memberCountDisplay;

@end
