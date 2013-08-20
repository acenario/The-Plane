//
//  ACRPickCircleViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickMembersViewController.h"
#import "SubclassHeader.h"

@class ACRPickCircleViewController;

@protocol ACRPickCircleViewControllerDelegate <NSObject>

@end

@interface ACRPickCircleViewController : UITableViewController <PickMembersViewControllerDelegate>

@property (nonatomic, weak) id <ACRPickCircleViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *circles;
@property (nonatomic, strong) UserInfo *currentUser;

@end
