//
//  NoFriendsViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ShareMailViewController.h"


@interface NoFriendsViewController : PFQueryTableViewController <FUIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSArray *emails;
- (IBAction)done:(id)sender;

@end
