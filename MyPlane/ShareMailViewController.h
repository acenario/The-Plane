//
//  ShareMailViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/3/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>


@interface ShareMailViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *dictionary;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property BOOL isForMessages;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
