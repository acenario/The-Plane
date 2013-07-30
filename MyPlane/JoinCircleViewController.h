//
//  JoinCircle.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"

@class JoinCircleViewController;

@protocol JoinCircleViewController <NSObject>

- (void)joinCircleViewControllerDidFinishAddingFriends:(JoinCircleViewController *)controller;

@end

@interface JoinCircleViewController : PFQueryTableViewController <UISearchBarDelegate>

@property (nonatomic, strong) id <JoinCircleViewController> delegate;

- (IBAction)done:(id)sender;

@end
 