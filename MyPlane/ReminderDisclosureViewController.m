//
//  ReminderDisclosureViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderDisclosureViewController.h"

@interface ReminderDisclosureViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;

@end

@implementation ReminderDisclosureViewController {
    UserInfo *currentUserObject;
    CGPoint originalCenter;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatter2;

}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //    self.tableView.rowHeight = 60;
    
    self.commentTextField.delegate = self;
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
    }];
    
    originalCenter = CGPointMake(self.view.center.x, self.view.center.y);
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter2 setTimeStyle:NSDateFormatterShortStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueries

- (PFQuery *)queryForTable
{
    PFQuery *query = [Comments query];
    [query whereKey:@"reminder" equalTo:self.reminderObject];
    [query includeKey:@"user"];
    [query includeKey:@"recipient"];
    
    [query orderByAscending:@"createdDate"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.objects.count == 0) {
        return 3;
    } else{
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 1;
    }else if (section == 2) {
        if (self.objects.count > 0) {
            return ([self.objects count]);
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"UserCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            PFImageView *userImage = (PFImageView *)[cell viewWithTag:1312];
            UILabel *name = (UILabel *)[cell viewWithTag:13101];
            UILabel *username = (UILabel *)[cell viewWithTag:13102];
            
            UserInfo *object = [self.reminderObject objectForKey:@"fromFriend"];
            
            name.text = [NSString stringWithFormat:@"%@ %@", object.firstName, object.lastName ];
            username.text = object.user;
            userImage.file = object.profilePicture;
            [userImage loadInBackground];
            
            return cell;
            
        } else if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"TaskCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            cell.detailTextLabel.text = [self.reminderObject objectForKey:@"title"];
            return cell;
            
        } else if (indexPath.row == 2) {
            static NSString *CellIdentifier = @"DescriptionCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            cell.detailTextLabel.text = [self.reminderObject objectForKey:@"description"];
            return cell;
            
        } else {
            static NSString *CellIdentifier = @"DateCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            cell.detailTextLabel.text = [dateFormatter stringFromDate:[self.reminderObject objectForKey:@"date"]];
            return cell;
        }
        
    } else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"RemindAgainCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        return cell;
    } else if (indexPath.section == 2) {
        if (self.objects.count > 0) {    // This is the Comment Cell
            static NSString *CellIdentifier = @"Cell";
            PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:1301];
            UILabel *commentLabel = (UILabel *)[cell viewWithTag:1302];
            UILabel *date = (UILabel *)[cell viewWithTag:1];
            PFImageView *userImage = (PFImageView *)[cell viewWithTag:1311];
            
            Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
             
            UserInfo *userObject = (UserInfo *)comment.user;
            nameLabel.text = userObject.firstName;
            date.text = [dateFormatter2 stringFromDate:[self.reminderObject objectForKey:@"date"]];
            commentLabel.text = comment.text;
            userImage.file = userObject.profilePicture;
            
            [userImage loadInBackground];
            
            
            return cell;
        } else { // This is the comment text input cell
            static NSString *CellIdentifier = @"CommentCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            UITextField *commentTextField = (UITextField *)[cell viewWithTag:1341];
            UIButton *addCommentButton = (UIButton *)[cell viewWithTag:1331];
            
            self.commentTextField = commentTextField;
            self.addCommentButton = addCommentButton;
            
            commentTextField.delegate = self;
            [commentTextField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
            
            return cell;
        }
    } else { // Same as above
        static NSString *CellIdentifier = @"CommentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UITextField *commentTextField = (UITextField *)[cell viewWithTag:1341];
        UIButton *addCommentButton = (UIButton *)[cell viewWithTag:1331];
        
        self.commentTextField = commentTextField;
        self.addCommentButton = addCommentButton;
        
        commentTextField.delegate = self;
        [commentTextField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self remindAgain:nil];
       
    } else {
        nil;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            return 90;
        } else if (indexPath.row == 3) {
            return 44;
        } else {
            return 60;
        }
    } if (indexPath.section == 1) {
        return 44;
    } else if (indexPath.section == 2) {
        if (self.objects.count > 0) {
            return 60;
        } else {
            return 44;
        }
    } else {
        return 44;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((self.objects.count > 0) && (section == 2)) {
        return @"Comments";
    } else {
        return nil;
    }
}


#pragma mark - Text Field Methods

- (IBAction)checkTextField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    //NSLog(@"%@", textField.text);
    NSString *textFieldText = [NSString stringWithFormat:@"%@", textField.text];
    if (textFieldText.length > 0) {
        self.addCommentButton.enabled = YES;
    } else {
        self.addCommentButton.enabled = NO;
    }
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Other Methods

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addComment:(id)sender {
    Comments *comment = [Comments object];
    
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"Reminders" objectId:self.reminderObject.objectId];
    
    [comment setObject:self.reminderObject forKey:@"reminder"];
    [comment setObject:currentUserObject forKey:@"user"];
    [comment setObject:self.commentTextField.text forKey:@"text"];
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.commentTextField.text = @"";
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        [self.reminderObject addObject:object forKey:@"comments"];
        [self.reminderObject saveInBackground];
        [self loadObjects];
    }];
}

- (void)remindAgain:(id)sender {
    
    if (![[PFUser currentUser].username isEqualToString:currentUserObject.user]) {
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:currentUserObject.user];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setMessage:[self.reminderObject objectForKey:@"title"]];
    [push sendPushInBackground];
    
    
    NSLog(@"Arjun implement a notification here in \"remindAgain\"");
    } else {
        UserInfo *recipient = (UserInfo *)[self.reminderObject objectForKey:@"recipient"];
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:recipient.user];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:[self.reminderObject objectForKey:@"title"]];
        [push sendPushInBackground];
        NSLog(@"Arjun implement a notification here in \"remindAgain\"");
    }
}

-(void)showAlert:(NSString *)message title:(NSString *)title {
    UIColor *barColor = [UIColor colorFromHexCode:@"FF9773"];
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:18];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:16];
    alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    
    [alertView show];


}

@end
