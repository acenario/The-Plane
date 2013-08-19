//
//  PickMembersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"

@class PickMembersViewController;

@protocol PickMembersViewControllerDelegate <NSObject>

@end

@interface PickMembersViewController : UITableViewController

@property (nonatomic, weak) id <PickMembersViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;

@end
