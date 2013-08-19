//
//  CircleDetailViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "CircleMembersViewController.h"
#import "CirclePostsViewController.h"
#import "IndependentInviteMenuViewController.h"
#import "CircleRemindersViewController.h"

@class CircleDetailViewController;

@protocol CircleDetailViewControllerDelegate <NSObject>

@end

@interface CircleDetailViewController : UITableViewController <CircleMembersViewControllerDelegate, CirclePostsViewControllerDelegate, IndependentInviteMenuViewControllerDelegate, CircleRemindersViewControllerDelegate>

@property (nonatomic, weak) id <CircleDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) NSArray *circles;
@property (strong, nonatomic) IBOutlet UILabel *ownerName;
@property (strong, nonatomic) IBOutlet UILabel *membersCount;
@property (strong, nonatomic) IBOutlet UILabel *postsCount;
@property (strong, nonatomic) IBOutlet UILabel *remindersCount;
- (IBAction)leaveCircle:(id)sender;

@end
 