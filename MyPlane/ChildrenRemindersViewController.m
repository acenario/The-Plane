//
//  ChildrenRemindersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/27/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ChildrenRemindersViewController.h"
#import "ReminderCell.h"

static NSString *const ReminderCellIdentifier = @"ReminderTemplateCell";

@interface ChildrenRemindersViewController ()

@end

@implementation ChildrenRemindersViewController {
    NSDateFormatter *mainFormatter;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"ReminderCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:ReminderCellIdentifier];
    
    self.navigationController.title = [NSString stringWithFormat:@"%d Reminders", self.parent.children.count];
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.parent.children.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReminderCell *cell = (ReminderCell *)[tableView dequeueReusableCellWithIdentifier:ReminderCellIdentifier];
    
    Reminders *reminder = [self.parent.children objectAtIndex:indexPath.row];
    
    cell.taskLabel.text = reminder.title;
    cell.dateLabel.text = [mainFormatter stringFromDate:reminder.date];
    cell.usernameLabel.text = reminder.user;
    
    cell.userImage.file = reminder.recipient.profilePicture;
    [cell.userImage loadInBackground];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showErrorWithStatus:@"Set up disclosure"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}



@end
