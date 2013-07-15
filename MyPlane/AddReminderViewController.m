//
//  AddReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddReminderViewController.h"


@interface AddReminderViewController ()

@end

@implementation AddReminderViewController {
    NSString *nameOfUser;
    NSString *descriptionPlaceholderText;
    PFObject *receivedObjectID;
    NSDateFormatter *mainFormatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.dateDetail.text = [mainFormatter stringFromDate:[NSDate date]];
    
    descriptionPlaceholderText = @"Enter a longer description if the space provided in Task does not fit your needs.";
    self.descriptionTextView.text = descriptionPlaceholderText;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender
{
    PFObject *reminder = [PFObject objectWithClassName:@"Reminders"];
    [reminder setObject:[mainFormatter dateFromString:self.dateDetail.text] forKey:@"date"];
    [reminder setObject:self.taskTextField.text forKey:@"title"];
    [reminder setObject:self.username.text forKey:@"user"];
    [reminder setObject:receivedObjectID forKey:@"fromFriend"];
    [reminder setObject:[PFUser currentUser].username forKey:@"fromUser"];
    if (self.descriptionTextView.text != descriptionPlaceholderText) {
        [reminder setObject:self.descriptionTextView.text forKey:@"description"];
    } else {
        [reminder setObject:@"No description available." forKey:@"description"];
    }
    [reminder saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)senderf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingContactWithUsername:(NSString *)username withName:(NSString *)name withProfilePicture:(UIImage *)image withObjectId:(PFObject *)objectID
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.name.text = name;
    self.username.text = username;
    self.userImage.image = image;
    receivedObjectID = objectID;
    self.doneBarItem.enabled = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsForReminders"]) {
        FriendsForRemindersViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ReminderDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        NSLog(@"$$$$ %@", self.dateDetail.text);
        controller.displayDate = self.dateDetail.text;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ((indexPath.section == 0) && (indexPath.row == 1)) {
        if ([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descriptionTextView.text = @"";
            self.descriptionTextView.textColor = [UIColor blackColor];
        }
        
        self.descriptionTextView.userInteractionEnabled = YES;
        [self.descriptionTextView becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    //self.mainFormatter = dateFormatter;
    self.dateDetail.text = [mainFormatter stringFromDate:date];
    NSLog(@"%@", self.dateDetail.text);
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
