//
//  SearchAllMembersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/5/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "UzysSlideMenu.h"
#import "MZFormSheetController.h"

@interface SearchAllMembersViewController : PFQueryTableViewController <UISearchBarDelegate, FUIAlertViewDelegate, UIScrollViewDelegate>
- (IBAction)options:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@end
