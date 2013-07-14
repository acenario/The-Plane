//
//  ReminderDateViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ReminderObjectViewController;

@protocol ReminderObjectViewController <NSObject>

@end



@interface ReminderObjectViewController : UITableViewController

@property (nonatomic, weak) id <ReminderObjectViewController> delegate;

@end
