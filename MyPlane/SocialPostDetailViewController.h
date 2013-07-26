//
//  SocialPostDetailViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserInfo.h"
#import "SocialPosts.h"
#import "Comments.h"

@class SocialPostDetailViewController;

@protocol SocialPostDetailViewControllerDelegate <NSObject>

//- (void)socialPostDetailRefreshData:(SocialPostDetailViewController *)controller;

@end

@interface SocialPostDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) SocialPosts *socialPost;
//@property (nonatomic, strong) PFQuery *postQuery;
@property (nonatomic, weak) id <SocialPostDetailViewControllerDelegate> delegate;
- (IBAction)addComment:(id)sender;


@end
