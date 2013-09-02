//
//  EditExpiryTimeViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditExpiryTimeViewController;

@protocol EditExpiryTimeViewControllerDelegate <NSObject>

- (void)editExpiryTimeViewController:(EditExpiryTimeViewController *)controller withGracePeriod:(int)gracePeriod;

@end

@interface EditExpiryTimeViewController : UITableViewController <UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)done:(id)sender;
@property (nonatomic, strong) id <EditExpiryTimeViewControllerDelegate> delegate;

@property int gracePeriod;

@end
