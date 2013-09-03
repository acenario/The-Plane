//
//  ReminderDisclosureViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderDisclosureViewController.h"
#import "Reachability.h"

@interface ReminderDisclosureViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation ReminderDisclosureViewController {
    UserInfo *currentUserObject;
    CGPoint originalCenter;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatter2;
    Reachability *reachability;
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.loadingViewEnabled = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    
    reachability = [Reachability reachabilityForInternetConnection];
	// Do any additional setup after loading the view.
    //    self.tableView.rowHeight = 60;
    
    self.commentTextField.delegate = self;
    
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    currentUserObject = sharedManager.currentUser;
    
    originalCenter = CGPointMake(self.view.center.x, self.view.center.y);
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter2 setTimeStyle:NSDateFormatterShortStyle];
    
    self.editButton.enabled = ([[self.reminderObject objectForKey:@"fromUser"] isEqualToString:[PFUser currentUser].username]);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    
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

#pragma mark - PFQueries

- (PFQuery *)queryForTable
{
    PFQuery *query = [Comments query];
    [query whereKey:@"reminder" equalTo:self.reminderObject];
    [query includeKey:@"user"];
    [query includeKey:@"recipient"];
    
    [query orderByDescending:@"createdAt"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

-(void)objectsWillLoad {
    [super objectsWillLoad];
    [SVProgressHUD showWithStatus:@"Loading Comments..."];
    
}

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [SVProgressHUD dismiss];
    
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
        return 1;
    } else {
        return ([self.objects count]);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"UserCell";
            PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
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
            
            NSString *description = [self.reminderObject objectForKey:@"description"];
            
            if (description.length > 0) {
                cell.detailTextLabel.text = description;
            } else {
                cell.detailTextLabel.text = @"No description available";
            }
            
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
        
        
        UIButton *reRemind = (UIButton *)[cell viewWithTag:1];
        UIButton *sendUpdate = (UIButton *)[cell viewWithTag:2];
        UIButton *sendUpdate2 = (UIButton *)[cell viewWithTag:4];
        UIImageView *line = (UIImageView *)[cell viewWithTag:3];
        
        //        UserInfo *recipient = (UserInfo *)[self.reminderObject objectForKey:@"user"];
        
        if ([[PFUser currentUser].username isEqualToString:[self.reminderObject objectForKey:@"user"]]) {
            reRemind.hidden = YES;
            sendUpdate.hidden = YES;
            line.hidden = YES;
            [sendUpdate2 addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            sendUpdate2.hidden = YES;
            [reRemind addTarget:self action:@selector(remindAgain:) forControlEvents:UIControlEventTouchUpInside];
            [sendUpdate addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        // This is the comment text input cell
        static NSString *CellIdentifier = @"CommentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UITextField *commentTextField = (UITextField *)[cell viewWithTag:1341];
        UIButton *addCommentButton = (UIButton *)[cell viewWithTag:1331];
        
        self.commentTextField = commentTextField;
        self.addCommentButton = addCommentButton;
        self.limitLabel = (UILabel *)[cell viewWithTag:1337];
        self.limitLabel.hidden = YES;
        
        commentTextField.delegate = self;
        [commentTextField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1301];
        UILabel *commentLabel = (UILabel *)[cell viewWithTag:1302];
        UILabel *date = (UILabel *)[cell viewWithTag:1];
        PFImageView *userImage = (PFImageView *)[cell viewWithTag:1311];
        
        Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
        
        UserInfo *userObject = (UserInfo *)comment.user;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", userObject.firstName, userObject.lastName];
        date.text = [dateFormatter2 stringFromDate:comment.createdAt];
        commentLabel.text = comment.text;
        userImage.file = userObject.profilePicture;
        
        [userImage loadInBackground];
        
        
        return cell;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:13101];
            UILabel *username = (UILabel *)[cell viewWithTag:13102];
            
            nameLabel.font = [UIFont flatFontOfSize:16];
            username.font = [UIFont flatFontOfSize:14];
            
            [cell.contentView addSubview:imgView];
            [cell.contentView addSubview:bottomView];
            
        } else if (indexPath.row != 3) {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont boldFlatFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
            
            [cell.contentView addSubview:imgView];
            [cell.contentView addSubview:bottomView];
        } else {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont boldFlatFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        }
        
    } else if (indexPath.section == 1) {
        cell.textLabel.font = [UIFont boldFlatFontOfSize:16];
        cell.textLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.section == 2) {
        UITextField *commentText = (UITextField *)[cell viewWithTag:1341];
        UILabel *limit = (UILabel *)[cell viewWithTag:1337];
        commentText.font = [UIFont flatFontOfSize:14];
        limit.font = [UIFont flatFontOfSize:14];
        limit.adjustsFontSizeToFitWidth = YES;
    } else {
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1301];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:1302];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:1];
        UIFont *postFont = [UIFont flatFontOfSize:16];
        
        nameLabel.font = [UIFont flatFontOfSize:14];
        timeLabel.font = [UIFont flatFontOfSize:14];
        
        [cell.contentView addSubview:imgView];
        [cell.contentView addSubview:bottomView];
        
        int i;
        
        for(i = 16; i > 10; i=i-2)
        {
            // Set the new font size.
            postFont = [UIFont flatFontOfSize:i];
            // You can log the size you're trying: NSLog(@"Trying size: %u", i);
            
            /* This step is important: We make a constraint box
             using only the fixed WIDTH of the UILabel. The height will
             be checked later. */
            CGSize constraintSize = CGSizeMake(222.0f, MAXFLOAT);
            
            // This step checks how tall the label would be with the desired font.
            CGSize labelSize = [postLabel.text sizeWithFont:postFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            /* Here is where you use the height requirement!
             Set the value in the if statement to the height of your UILabel
             If the label fits into your required height, it will break the loop
             and use that font size. */
            if(labelSize.height <= 36.0f)
                break;
        }
        
        postLabel.font = postFont;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        return UITableViewCellEditingStyleNone;
    } else {
        
        if (indexPath.section == 3)
        {
            
            Comments *post = (Comments *)[self.objects objectAtIndex:indexPath.row];
            UserInfo *selectedUser = (UserInfo *)post.user;
            
            if ([selectedUser.user isEqualToString:[PFUser currentUser].username]) {
                return UITableViewCellEditingStyleDelete;
            } else {
                return UITableViewCellEditingStyleNone;
            }
            
        }
        
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
    UserInfo *userObject = (UserInfo *)comment.user;
    Reminders *reminder = (Reminders *)self.reminderObject;
    
    if ([userObject.user isEqualToString:[PFUser currentUser].username]) {
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [reminder removeObject:[Comments objectWithoutDataWithObjectId:comment.objectId] forKey:@"comments"];
                [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                    [self loadObjects];
                    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                    
                    [SVProgressHUD showSuccessWithStatus:@"Deleted comment!"];
                    
                }];
                
            } else {
                NSLog(@"error: %@", error);
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Can't delete try blocking instead!"];
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            return 90;
        } else if (indexPath.row == 3) {
            return 44;
        } else {
            return 70;
        }
    } if (indexPath.section == 1) {
        return 44;
    } else if (indexPath.section == 2) {
        return 44;
    } else {
        return 60;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //    if ((self.objects.count > 0) && (section == 2)) {
    //        return @"Comments";
    //    }
    return nil;
}


#pragma mark - Text Field Methods

- (IBAction)checkTextField:(id)sender
{
    self.limitLabel.hidden = NO;
    UITextField *textField = (UITextField *)sender;
    //NSLog(@"%@", textField.text);
    NSString *removedSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 70 - textField.text.length;
    self.limitLabel.text = [NSString stringWithFormat:@"%d", limit];
    if ((removedSpaces.length > 0) && (limit >= 0)) {
        self.addCommentButton.enabled = YES;
    } else {
        self.addCommentButton.enabled = NO;
        self.limitLabel.textColor = [UIColor redColor];
    }
    
    if (limit >= 0) {
        self.limitLabel.textColor = [UIColor lightGrayColor];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
        return YES;
    } else {
        [self addComment:nil];
        [textField resignFirstResponder];
        return YES;
    }
}


#pragma mark - Other Methods

- (IBAction)addComment:(id)sender {
    Comments *comment = [Comments object];
    
    [comment setObject:self.reminderObject forKey:@"reminder"];
    [comment setObject:currentUserObject forKey:@"user"];
    [comment setObject:self.commentTextField.text forKey:@"text"];
    self.commentTextField.text = @"";
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        [self.reminderObject addObject:[Comments objectWithoutDataWithObjectId:comment.objectId] forKey:@"comments"];
        [self.reminderObject saveInBackground];
        [self loadObjects];
    }];
}

- (void)remindAgain:(id)sender {
    Reminders *reminder = (Reminders *)self.reminderObject;
    if ([reminder.fromUser isEqualToString:[PFUser currentUser].username]) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult result;
        result = [currentDate compare:[reminder.reRemindTime dateByAddingTimeInterval:60]];
        if ((result == NSOrderedDescending) || !(reminder.reRemindTime)) {            
            if (reachability.currentReachabilityStatus == NotReachable) {
                [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
            } else {
                UserInfo *recipient = (UserInfo *)[self.reminderObject objectForKey:@"recipient"];
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:recipient.user];
                reminder.reRemindTime = [NSDate date];
                
                if ([[PFUser currentUser].username isEqualToString:recipient.user]) {
                    [self showAlert:@"You can't re-remind yourself!" title:@"Error!"];
                } else {
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    [push setMessage:[self.reminderObject objectForKey:@"title"]];
                    [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [push sendPushInBackground];
                    }];
                }
            }
        } else {
            [self showAlert:@"You have to wait some time before reminder again" title:@"Try again later"];
        }
    }
}

- (void)update:(id)sender
{
    Reminders *reminder = (Reminders *)self.reminderObject;
    if ([reminder.user isEqualToString:[PFUser currentUser].username]) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult result;
        result = [currentDate compare:[reminder.recipientUpdateTime dateByAddingTimeInterval:60]];
        if ((result == NSOrderedDescending) || !(reminder.recipientUpdateTime)) {
            if (reachability.currentReachabilityStatus == NotReachable) {
                [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
            } else {
                
                UserInfo *recipient = (UserInfo *)[self.reminderObject objectForKey:@"recipient"];
                NSString *sender = [self.reminderObject objectForKey:@"fromUser"];
                PFQuery *pushQuery = [PFInstallation query];
                NSString *message = [NSString stringWithFormat:@"Update for: %@", [self.reminderObject objectForKey:@"title"]];
                reminder.recipientUpdateTime = [NSDate date];
                if ([[PFUser currentUser].username isEqualToString:recipient.user]) {
                    [pushQuery whereKey:@"user" equalTo:sender];
                    
                } else {
                    [pushQuery whereKey:@"user" equalTo:recipient.user];
                    
                }
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setMessage:message];
                [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [push sendPushInBackground];
                }];
            }
        } else {
            [self showAlert:@"You have to wait some time before updating again" title:@"Try again later"];
        }
    } else if ([reminder.fromUser isEqualToString:[PFUser currentUser].username]) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult result;
        result = [currentDate compare:[reminder.senderUpdateTime dateByAddingTimeInterval:60]];
        if ((result == NSOrderedDescending) || !(reminder.senderUpdateTime)) {
            if (reachability.currentReachabilityStatus == NotReachable) {
                [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
            } else {
                
                UserInfo *recipient = (UserInfo *)[self.reminderObject objectForKey:@"recipient"];
                NSString *sender = [self.reminderObject objectForKey:@"fromUser"];
                PFQuery *pushQuery = [PFInstallation query];
                NSString *message = [NSString stringWithFormat:@"Update for: %@", [self.reminderObject objectForKey:@"title"]];
                reminder.senderUpdateTime = [NSDate date];
                if ([[PFUser currentUser].username isEqualToString:recipient.user]) {
                    [pushQuery whereKey:@"user" equalTo:sender];
                    
                } else {
                    [pushQuery whereKey:@"user" equalTo:recipient.user];
                    
                }
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setMessage:message];
                [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [push sendPushInBackground];
                }];            }
        } else {
            [self showAlert:@"You have to wait some time before updating again" title:@"Try again later"];
        }
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

- (void)hideKeyboard
{
    [self.commentTextField resignFirstResponder];
}

- (void)editReminderViewController:(EditReminderViewController *)controller didFinishWithReminder:(Reminders *)reminders
{
    self.reminderObject = reminders;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        EditReminderViewController *controller = (EditReminderViewController *)nav.topViewController;
        controller.reminder = (Reminders *)self.reminderObject;
        controller.delegate = self;
    }
}

@end
