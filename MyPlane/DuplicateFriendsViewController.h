//
//  DuplicateFriendsViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 10/27/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@interface DuplicateFriendsViewController : PFQueryTableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fixButton;

- (IBAction)FixAll:(id)sender;
@end
