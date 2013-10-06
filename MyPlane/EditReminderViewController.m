//
//  EditReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "EditReminderViewController.h"

@interface EditReminderViewController ()

@end

@implementation EditReminderViewController {
    BOOL textCheck;
    BOOL descCheck;
    NSDate *reminderDate;
    NSString *descriptionPlaceholderText;
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
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    reminderDate = self.reminder.date;
    self.taskTextField.text = self.reminder.title;
    self.dateLabel.text = [mainFormatter stringFromDate:reminderDate];
    self.taskLimit.hidden = YES;
    self.taskLimit.text = [NSString stringWithFormat:@"%d", 35 - self.taskTextField.text.length];
    if ([[self.reminder objectForKey:@"description"] length] > 0) {
        //        NSLog(@"%@", self.reminder.description);
        self.descTextView.text = [self.reminder objectForKey:@"description"];
        self.descLimit.text = [NSString stringWithFormat:@"%d", 250 - self.descTextView.text.length ];
    } else {
        descriptionPlaceholderText = @"Enter more information about the reminder...";
        self.descTextView.text = descriptionPlaceholderText;
        self.descTextView.textColor = [UIColor lightGrayColor];
        self.descTextView.userInteractionEnabled = NO;
    }
    
    descCheck = YES;
    textCheck = YES;
    self.descTextView.delegate = self;
    self.taskTextField.delegate = self;
    

    
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)taskValidation:(id)sender
{
    self.taskLimit.hidden = NO;
    NSString *removedSpaces = [self.taskTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 35 - self.taskTextField.text.length;
    self.taskLimit.text = [NSString stringWithFormat:@"%d", limit];
    //textCheck = ((removedSpaces.length > 0) && (limit >= 0));
    if ((removedSpaces.length > 0) && (limit >= 0)) {
        textCheck = YES;
    } else {
        textCheck = NO;
        self.taskLimit.textColor = [UIColor redColor];
    }
    
    if (limit >= 0) {
        self.taskLimit.textColor = [UIColor lightGrayColor];
    }

    [self configureDoneButton];
}

- (IBAction)done:(id)sender
{
    [SVProgressHUD showWithStatus:@"Editing..."];
    if (![self.descTextView.text isEqualToString:descriptionPlaceholderText]) {
        [self.reminder setObject:self.descTextView.text forKey:@"description"];
    }
    self.reminder.date = reminderDate;
    self.reminder.title = self.taskTextField.text;
    
    [self.reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.delegate editReminderViewController:self didFinishWithReminder:self.reminder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    int limit = 250 - self.descTextView.text.length;
    self.descLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
    //descCheck = ((limit >= 0));
    if ((limit >= 0)) {
        descCheck = YES;
        self.descLimit.textColor = [UIColor lightGrayColor];
    } else {
        descCheck = NO;
        self.descLimit.textColor = [UIColor redColor];
    }
    
    [self configureDoneButton];
}

- (IBAction)commonTasks:(id)sender
{
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    CommonTasksViewController *cVC = (CommonTasksViewController *)[vc topViewController];
    cVC.delegate = self;
    cVC.isFromSettings = NO;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    formSheet.cornerRadius = 9.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
    
}

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task
{
    self.taskTextField.text = task;
    self.taskLimit.text = [NSString stringWithFormat:@"%d", 35 - self.taskTextField.text.length];
    textCheck = YES;
    [self configureDoneButton];
}

- (void)configureDoneButton
{
    self.doneButton.enabled = ((textCheck) && (descCheck));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
    } else if ((indexPath.section == 0) && (indexPath.row == 2)) {
        if ([self.descTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descTextView.text = @"";
            self.descTextView.textColor = [UIColor blackColor];
        }
        self.descTextView.userInteractionEnabled = YES;
        [self.descTextView becomeFirstResponder];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    imgView.frame = CGRectMake(-1, (cell.frame.size.height - 1), 302, 1);
    
    UIImageView *bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    bottomView.frame = CGRectMake(-1, -1, 302, 1);
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            self.taskDisplayLabel.font = [UIFont flatFontOfSize:16];
            self.taskTextField.font = [UIFont flatFontOfSize:14];
            self.taskLimit.font = [UIFont flatFontOfSize:14];
            
            self.taskLimit.adjustsFontSizeToFitWidth = YES;
            
            self.commonTasks.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
            self.commonTasks.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
            self.commonTasks.shadowHeight = 2.0f;
            self.commonTasks.cornerRadius = 3.0f;
            self.commonTasks.titleLabel.font = [UIFont boldFlatFontOfSize:15];
            
            [self.commonTasks setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.commonTasks setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            
            
            [cell.contentView addSubview:imgView];
            
        } else {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
            
            [cell.contentView addSubview:bottomView];
            [cell.contentView addSubview:imgView];
            
       }
        
    } else {
        self.DescDisplayLabel.font = [UIFont flatFontOfSize:16];
        self.descTextView.font = [UIFont flatFontOfSize:14];
        self.descLimit.font = [UIFont flatFontOfSize:14];
        self.descLimit.adjustsFontSizeToFitWidth = YES;
    }
    
    return cell;
    
}

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    reminderDate = date;
    self.dateLabel.text = [mainFormatter stringFromDate:date];
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.displayDate = self.dateLabel.text;
        controller.delegate = self;
    }
}

@end
