//
//  FixNullValuesViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/28/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@interface FixNullValuesViewController : PFQueryTableViewController <UIAlertViewDelegate>

- (IBAction)fix:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fixButton;

@end
