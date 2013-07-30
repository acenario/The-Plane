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

@class CircleDetailViewController;

@protocol CircleDetailViewControllerDelegate <NSObject>

@end

@interface CircleDetailViewController : UITableViewController <CircleMembersViewControllerDelegate, CirclePostsViewControllerDelegate>

@property (nonatomic, weak) id <CircleDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (strong, nonatomic) IBOutlet UILabel *ownerName;
@property (strong, nonatomic) IBOutlet UILabel *membersCount;
@property (strong, nonatomic) IBOutlet UILabel *postsCount;
@property (strong, nonatomic) IBOutlet UILabel *remindersCount;

@end
 