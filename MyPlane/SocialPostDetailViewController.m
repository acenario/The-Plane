//
//  SocialPostDetailViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#define TAG_ONE 1
#define TAG_TWO 2

#import "SocialPostDetailViewController.h"
#import "CurrentUser.h"
#import "Reachability.h"

@interface SocialPostDetailViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;
@property (nonatomic, strong) UILabel *limitLabel;
@property (nonatomic, strong) UIButton *claimButton;

@end

@implementation SocialPostDetailViewController {
    UserInfo *currentUserObject;
    SocialPosts *currentSocialObject;
    PFQuery *userQuery;
    NSDateFormatter *dateFormatter;
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
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    currentUserObject = sharedManager.currentUser;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if ([self.socialPost.username isEqualToString:currentUserObject.user]) {
        self.editButton.enabled = YES;
    } else {
        self.editButton.enabled = NO;
    }
    
    
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

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:YES];
//    
//    NSLog(@"HEU");
//    
//    if ([self.socialPost.claimerUsernames containsObject:currentUserObject.user]) {
//        [self setButtonTitle:self.claimButton withTitle:@"Unclaim"];
//        [self.claimButton removeTarget:self action:@selector(claim:) forControlEvents:UIControlEventTouchUpInside];
//        [self.claimButton addTarget:self action:@selector(unclaim:) forControlEvents:UIControlEventTouchUpInside];
//    } else {
//        [self setButtonTitle:self.claimButton withTitle:@"Claim"];
//        [self.claimButton removeTarget:self action:@selector(unclaim:) forControlEvents:UIControlEventTouchUpInside];
//        [self.claimButton addTarget:self action:@selector(claim:) forControlEvents:UIControlEventTouchUpInside];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"post" equalTo:self.socialPost];
    [query includeKey:@"user"];
    
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.socialPost.reminderTask.length > 0) {
        return 4;
    } else {
        return 3;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 1;
            break;
        case 2:
            if (self.socialPost.reminderTask.length > 0) {
                return 1;
            } else {
                return self.objects.count;
            }
            break;
            
        default:
            return self.objects.count;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *identifier = @"PostCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        UserInfo *userObject = (UserInfo *)self.socialPost.user;
        
        UILabel *name = (UILabel *)[cell viewWithTag:5201];
        UILabel *text = (UILabel *)[cell viewWithTag:5202];
        UILabel *circle = (UILabel *)[cell viewWithTag:5203];
        UILabel *date = (UILabel *)[cell viewWithTag:521];
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:5211];
        NSDateFormatter *displayDateFormat = [[NSDateFormatter alloc] init];
        [displayDateFormat setDateStyle:NSDateFormatterShortStyle];
        [displayDateFormat setTimeStyle:NSDateFormatterShortStyle];
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", userObject.firstName, userObject.lastName];
        
        name.text = fullName;
        text.text = self.socialPost.text;
        circle.text = [self.socialPost.circle objectForKey:@"displayName"];
        date.text = [displayDateFormat stringFromDate:self.socialPost.createdAt];
        ownerImage.file = userObject.profilePicture;
        [ownerImage loadInBackground];
        
        return cell;
    } else if (indexPath.section == 1) {
        if (self.socialPost.reminderTask.length > 0) {
            static NSString *identifier = @"ReminderCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            UILabel *task = (UILabel *)[cell viewWithTag:1];
            UILabel *date = (UILabel *)[cell viewWithTag:2];
            UIButton *claim = (UIButton *)[cell viewWithTag:11];
            NSDateFormatter *displayDateFormat = [[NSDateFormatter alloc] init];
            [displayDateFormat setDateStyle:NSDateFormatterShortStyle];
            [displayDateFormat setTimeStyle:NSDateFormatterShortStyle];
            
            task.text = self.socialPost.reminderTask;
            date.text = [displayDateFormat stringFromDate:self.socialPost.reminderDate];
            claim.hidden = ([self.socialPost.username isEqualToString:currentUserObject.user]);
            
            if ([self.socialPost.claimerUsernames containsObject:currentUserObject.user]) {
                [self setButtonTitle:claim withTitle:@"Unclaim"];
                [claim removeTarget:self action:@selector(claim:) forControlEvents:UIControlEventTouchUpInside];
                [claim addTarget:self action:@selector(unclaim:) forControlEvents:UIControlEventTouchUpInside];
                self.claimButton = claim;
            } else {
                [self setButtonTitle:claim withTitle:@"Claim"];
                [claim removeTarget:self action:@selector(unclaim:) forControlEvents:UIControlEventTouchUpInside];
                [claim addTarget:self action:@selector(claim:) forControlEvents:UIControlEventTouchUpInside];
                self.claimButton = claim;
            }
            return cell;
        } else {
            static NSString *identifier = @"CommentPostCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            UITextField *commentTextfield = (UITextField *)[cell viewWithTag:5241];
            UIButton *addCommentButton = (UIButton *)[cell viewWithTag:5231];
            
            self.commentTextField = commentTextfield;
            self.addCommentButton = addCommentButton;
            self.limitLabel = (UILabel *)[cell viewWithTag:1337];
            self.limitLabel.hidden = YES;
            
            commentTextfield.delegate = self;
            //        [commentTextfield addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
            
            return cell;
            
        }
    } else if (indexPath.section == 2) {
        if (self.socialPost.reminderTask.length > 0) {
            static NSString *identifier = @"CommentPostCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            UITextField *commentTextfield = (UITextField *)[cell viewWithTag:5241];
            UIButton *addCommentButton = (UIButton *)[cell viewWithTag:5231];
            
            self.commentTextField = commentTextfield;
            self.addCommentButton = addCommentButton;
            self.limitLabel = (UILabel *)[cell viewWithTag:1337];
            self.limitLabel.hidden = YES;

            commentTextfield.delegate = self;
            //        [commentTextfield addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
            
            return cell;
        } else {
            static NSString *identifier = @"CommentCell";
            PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            
            Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
            
            
            UILabel *commentText = (UILabel *)[cell viewWithTag:5204];
            UILabel *date = (UILabel *)[cell viewWithTag:1];
            UILabel *usernameLabel = (UILabel *)[cell viewWithTag:110];
            PFImageView *commentUserImage = (PFImageView *)[cell viewWithTag:5212];
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",[comment.user objectForKey:@"firstName"], [comment.user objectForKey:@"lastName"]];
            
            commentUserImage.file = [comment.user objectForKey:@"profilePicture"];
            commentText.text = comment.text;
            usernameLabel.text = fullName;
            date.text = [dateFormatter stringFromDate:comment.createdAt];
            
            [commentUserImage loadInBackground];
            
            return cell;
            //        __block UserInfo *commentUser;
            //        __block NSString *commentTextReceived;
            //        __block NSString *dateCreated;
            //
            //
            //        [comment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            //            commentUser = (UserInfo *)[object objectForKey:@"user"];
            //            commentTextReceived = [object objectForKey:@"text"];
            //            dateCreated = [dateFormatter stringFromDate:[object createdAt]];
            //        }];
            //        //UserInfo *commentUser = (UserInfo *)comment.user;
            //
            //        __block PFFile *profilePic;
            //        [commentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            //            profilePic = [object objectForKey:@"profilePicture"];
            //        }];
        }
    } else {
        static NSString *identifier = @"CommentCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        
        Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
        
        
        UILabel *commentText = (UILabel *)[cell viewWithTag:5204];
        UILabel *date = (UILabel *)[cell viewWithTag:1];
        UILabel *usernameLabel = (UILabel *)[cell viewWithTag:110];
        PFImageView *commentUserImage = (PFImageView *)[cell viewWithTag:5212];
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",[comment.user objectForKey:@"firstName"], [comment.user objectForKey:@"lastName"]];
        
        commentUserImage.file = [comment.user objectForKey:@"profilePicture"];
        commentText.text = comment.text;
        usernameLabel.text = fullName;
        date.text = [dateFormatter stringFromDate:comment.createdAt];
        
        [commentUserImage loadInBackground];
        
        return cell;
        //        __block UserInfo *commentUser;
        //        __block NSString *commentTextReceived;
        //        __block NSString *dateCreated;
        //
        //
        //        [comment fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //            commentUser = (UserInfo *)[object objectForKey:@"user"];
        //            commentTextReceived = [object objectForKey:@"text"];
        //            dateCreated = [dateFormatter stringFromDate:[object createdAt]];
        //        }];
        //        //UserInfo *commentUser = (UserInfo *)comment.user;
        //
        //        __block PFFile *profilePic;
        //        [commentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //            profilePic = [object objectForKey:@"profilePicture"];
        //        }];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5201];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:5202];
        UILabel *circleTitle = (UILabel *)[cell viewWithTag:520];
        UILabel *circleLabel = (UILabel *)[cell viewWithTag:5203];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:521];
        UIFont *postFont = [UIFont flatFontOfSize:16];
        
        nameLabel.font = [UIFont flatFontOfSize:14];
        circleTitle.font = [UIFont flatFontOfSize:14];
        circleLabel.font = [UIFont flatFontOfSize:14];
        dateLabel.font = [UIFont flatFontOfSize:14];
        
        nameLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.adjustsFontSizeToFitWidth = YES;
        circleLabel.adjustsFontSizeToFitWidth = YES;
        
        int i;
        
        for(i = 16; i > 10; i=i-2)
        {
            // Set the new font size.
            postFont = [UIFont flatFontOfSize:i];
            // You can log the size you're trying: NSLog(@"Trying size: %u", i);
            
            /* This step is important: We make a constraint box
             using only the fixed WIDTH of the UILabel. The height will
             be checked later. */
            CGSize constraintSize = CGSizeMake(214.0f, MAXFLOAT);
            
            // This step checks how tall the label would be with the desired font.
            CGSize labelSize = [self.socialPost.text sizeWithFont:postFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            /* Here is where you use the height requirement!
             Set the value in the if statement to the height of your UILabel
             If the label fits into your required height, it will break the loop
             and use that font size. */
            if(labelSize.height <= 49.0f)
                break;
        }
        postLabel.font = postFont;
        
        
        
    } else if (indexPath.section == 1) {
        if (self.socialPost.reminderTask.length > 0) {
            UILabel *task = (UILabel *)[cell viewWithTag:1];
            UILabel *dateTask = (UILabel *)[cell viewWithTag:2];
            FUIButton *claimBtn = (FUIButton *)[cell viewWithTag:11];
            UIFont *taskFont = [UIFont flatFontOfSize:16];
            
            claimBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
            claimBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
            claimBtn.shadowHeight = 2.0f;
            claimBtn.cornerRadius = 3.0f;
            claimBtn.titleLabel.font = [UIFont boldFlatFontOfSize:15];
            
            [claimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [claimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            dateTask.font = [UIFont flatFontOfSize:14];
            
            int i;
            
            for(i = 16; i > 10; i=i-2)
            {
                // Set the new font size.
                taskFont = [UIFont flatFontOfSize:i];
                // You can log the size you're trying: NSLog(@"Trying size: %u", i);
                
                /* This step is important: We make a constraint box
                 using only the fixed WIDTH of the UILabel. The height will
                 be checked later. */
                CGSize constraintSize = CGSizeMake(199.0f, MAXFLOAT);
                
                // This step checks how tall the label would be with the desired font.
                CGSize labelSize = [self.socialPost.reminderTask sizeWithFont:taskFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                
                /* Here is where you use the height requirement!
                 Set the value in the if statement to the height of your UILabel
                 If the label fits into your required height, it will break the loop
                 and use that font size. */
                if(labelSize.height <= 43.0f)
                    break;
            }
            task.font = taskFont;
            
            //// ARJUN IMPLEMENT REMINDER STYLE HERE
        } else {
            UITextField *postComment = (UITextField *)[cell viewWithTag:5241];
            UILabel *limit = (UILabel *)[cell viewWithTag:1337];
            postComment.font = [UIFont flatFontOfSize:14];
            
            limit.font = [UIFont flatFontOfSize:14];
            limit.adjustsFontSizeToFitWidth = YES;
        }
    } else if (indexPath.section == 2) {
        
        if (self.socialPost.reminderTask.length > 0) {
            UITextField *postComment = (UITextField *)[cell viewWithTag:5241];
            postComment.font = [UIFont flatFontOfSize:14];
        } else {
            UILabel *commentDate = (UILabel *)[cell viewWithTag:1];
            UILabel *userNameLabel = (UILabel *)[cell viewWithTag:110];
            UILabel *commentText = (UILabel *)[cell viewWithTag:5204];
            UIFont *commentFont = [UIFont flatFontOfSize:16];
            
            commentDate.font = [UIFont flatFontOfSize:14];
            userNameLabel.font = [UIFont flatFontOfSize:14];
            
            [cell.contentView addSubview:imgView];
            
            int i;
            
            for(i = 16; i > 10; i=i-2)
            {
                // Set the new font size.
                commentFont = [UIFont flatFontOfSize:i];
                // You can log the size you're trying: NSLog(@"Trying size: %u", i);
                
                /* This step is important: We make a constraint box
                 using only the fixed WIDTH of the UILabel. The height will
                 be checked later. */
                CGSize constraintSize = CGSizeMake(222.0f, MAXFLOAT);
                
                // This step checks how tall the label would be with the desired font.
                CGSize labelSize = [commentText.text sizeWithFont:commentFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                
                /* Here is where you use the height requirement!
                 Set the value in the if statement to the height of your UILabel
                 If the label fits into your required height, it will break the loop
                 and use that font size. */
                if(labelSize.height <= 36.0f)
                    break;
            }
            
            commentText.font = commentFont;

            
            if (indexPath.row != 0) {
                [cell.contentView addSubview:bottomView];
            }
        }
        
    } else {
        
        UILabel *commentDate = (UILabel *)[cell viewWithTag:1];
        UILabel *userNameLabel = (UILabel *)[cell viewWithTag:110];
        UILabel *commentText = (UILabel *)[cell viewWithTag:5204];
        UIFont *commentFont = [UIFont flatFontOfSize:16];
        
        commentDate.font = [UIFont flatFontOfSize:14];
        userNameLabel.font = [UIFont flatFontOfSize:14];
        
        [cell.contentView addSubview:imgView];
        
        int i;
        
        for(i = 16; i > 10; i=i-2)
        {
            // Set the new font size.
            commentFont = [UIFont flatFontOfSize:i];
            // You can log the size you're trying: NSLog(@"Trying size: %u", i);
            
            /* This step is important: We make a constraint box
             using only the fixed WIDTH of the UILabel. The height will
             be checked later. */
            CGSize constraintSize = CGSizeMake(222.0f, MAXFLOAT);
            
            // This step checks how tall the label would be with the desired font.
            CGSize labelSize = [commentText.text sizeWithFont:commentFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            /* Here is where you use the height requirement!
             Set the value in the if statement to the height of your UILabel
             If the label fits into your required height, it will break the loop
             and use that font size. */
            if(labelSize.height <= 36.0f)
                break;
        }
        
        commentText.font = commentFont;
        
        if (indexPath.row != 0) {
            [cell.contentView addSubview:bottomView];
        }
        
        
        
        
        
    }
    

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 115;
            break;
            
        case 1:
            if (self.socialPost.reminderTask.length > 0) {
                return 70;
            } else {
                return 44;
            }
            break;
            
        case 2:
            if (self.socialPost.reminderTask.length > 0) {
                return 44;
            } else {
                return 60;
            }
            break;
            
        default:
            return 60;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        return UITableViewCellEditingStyleNone;
    } else {
        int section;
        
        if (self.socialPost.reminderTask.length > 0) {
            section = 3;
        } else {
            section = 2;
        }
        
        if (indexPath.section == section)
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
    SocialPosts *post = self.socialPost;
    
    if ([userObject.user isEqualToString:[PFUser currentUser].username]) {
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [post removeObject:[Comments objectWithoutDataWithObjectId:comment.objectId] forKey:@"comments"];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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


- (IBAction)checkTextField:(id)sender
{
    self.limitLabel.hidden = NO;
    UITextField *textField = (UITextField *)sender;
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


- (IBAction)addComment:(id)sender {
    Comments *comment = [Comments object];
    
    [comment setUser:currentUserObject];
    [comment setText:self.commentTextField.text];
    [comment setPost:[SocialPosts objectWithoutDataWithObjectId:self.socialPost.objectId]];
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.commentTextField.text = @"";
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        
        [self loadObjects];
        
        [self.socialPost addObject:comment forKey:@"comments"];
        [self.socialPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
    }];
}

- (void)hideKeyboard
{
    [self.commentTextField resignFirstResponder];
}

- (IBAction)claim:(id)sender {
    UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
    
    NSString *title;
    NSString *message;
    if (self.socialPost.claimers.count > 0) {
        title = @"This post has already been claimed";
        message = @"Are you sure you still want to claim this?";
    } else {
        title = @"Are you sure you want to claim this?";
        message = nil;
    }
    
    FUIAlertView *alertView = [[FUIAlertView alloc]
                               initWithTitle:title
                               message:message
                               delegate:self
                               cancelButtonTitle:@"No"
                               otherButtonTitles:@"Yes", nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    alertView.messageLabel.textColor = [UIColor whiteColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor clearColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.tag = TAG_ONE;
    
    [alertView show];
}

- (IBAction)unclaim:(id)sender {
    UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
    
    NSString *title;
    NSString *message;
    title = @"Are you sure you want to unclaim this?";
    message = nil;
    
    FUIAlertView *alertView = [[FUIAlertView alloc]
                               initWithTitle:title
                               message:message
                               delegate:self
                               cancelButtonTitle:@"No"
                               otherButtonTitles:@"Yes", nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor clearColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.tag = TAG_ONE;
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ONE) {
        if (buttonIndex == 1) {
            if (![self.socialPost.claimerUsernames containsObject:currentUserObject.user]) {
                [self claimMethod];
            } else {
                [self unclaimMethod];
            }
        }
    } else {
        if (buttonIndex == 1) {
            
            Reminders *reminder = [Reminders object];
            
            [reminder setRecipient:currentUserObject];
            [reminder setUser:currentUserObject.user];
            
            [reminder setFromFriend:self.socialPost.user];
            [reminder setFromUser:self.socialPost.username];
            
            [reminder setDate:self.socialPost.reminderDate];
            [reminder setDescription:self.socialPost.reminderDescription];
            [reminder setSocialPost:self.socialPost];
            [reminder setTitle:self.socialPost.reminderTask];
            
            [self.socialPost setIsClaimed:YES];
            [self.socialPost addObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId] forKey:@"claimers"];
            [self.socialPost addObject:currentUserObject.user forKey:@"claimerUsernames"];
            
            [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                [self.socialPost addObject:[Reminders objectWithoutDataWithObjectId:reminder.objectId] forKey:@"reminder"];
                [self.socialPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self.tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                }];
                } else {
                    NSLog(@"%@", error);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                }
            }];
            
        }
    }
}

- (void)claimMethod
{
    [SVProgressHUD showWithStatus:@"Claiming..."];
    
    if (self.socialPost.claimers.count > 0) {
        Reminders *reminder = [Reminders object];
        
        [reminder setRecipient:currentUserObject];
        [reminder setUser:currentUserObject.user];
        
        [reminder setFromFriend:self.socialPost.user];
        [reminder setFromUser:self.socialPost.username];
        [reminder setDate:self.socialPost.reminderDate];
        [reminder setDescription:self.socialPost.reminderDescription];
        
        [reminder setTitle:self.socialPost.reminderTask];
        [reminder setSocialPost:self.socialPost];
        
        [self.socialPost setIsClaimed:YES];
        [self.socialPost addObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId] forKey:@"claimers"];
        [self.socialPost addObject:currentUserObject.user forKey:@"claimerUsernames"];
        
        [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.socialPost addObject:[Reminders objectWithoutDataWithObjectId:reminder.objectId] forKey:@"reminder"];
            [self.socialPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.tableView reloadData];
                [SVProgressHUD showSuccessWithStatus:@"Done"];
            }];
        }];
    } else {
        PFQuery *query = [SocialPosts query];
        [query includeKey:@"circle"];
        [query includeKey:@"user"];
        [query includeKey:@"claimers"];
        [query includeKey:@"reminder"];
        [query includeKey:@"comments"];
        [query includeKey:@"comments.user"];
        [query getObjectInBackgroundWithId:self.socialPost.objectId block:^(PFObject *object, NSError *error) {
            SocialPosts *post = (SocialPosts *)object;
            self.socialPost = post;
            
            if (post.claimers.count > 0) {
                UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
                
                FUIAlertView *alertView = [[FUIAlertView alloc]
                                           initWithTitle:@"Someone else has recently claimed this reminder"
                                           message:@"Do you still want to claim this"
                                           delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
                
                alertView.titleLabel.textColor = [UIColor cloudsColor];
                alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                alertView.messageLabel.textColor = [UIColor cloudsColor];
                alertView.messageLabel.font = [UIFont flatFontOfSize:14];
                alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
                alertView.alertContainer.backgroundColor = barColor;
                alertView.defaultButtonColor = [UIColor cloudsColor];
                alertView.defaultButtonShadowColor = [UIColor clearColor];
                alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
                alertView.defaultButtonTitleColor = [UIColor asbestosColor];
                alertView.tag = TAG_TWO;
                
                [alertView show];
            } else {
                Reminders *reminder = [Reminders object];
                
                [reminder setRecipient:currentUserObject];
                [reminder setUser:currentUserObject.user];
                
                [reminder setFromFriend:self.socialPost.user];
                [reminder setFromUser:self.socialPost.username];
                
                [reminder setDate:self.socialPost.reminderDate];
                [reminder setDescription:self.socialPost.reminderDescription];
                [reminder setSocialPost:self.socialPost];
                [reminder setTitle:self.socialPost.reminderTask];
                
                [post setIsClaimed:YES];
                [post addObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId] forKey:@"claimers"];
                [post addObject:currentUserObject.user forKey:@"claimerUsernames"];
                
                [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [post addObject:[Reminders objectWithoutDataWithObjectId:reminder.objectId] forKey:@"reminder"];
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.tableView reloadData];
                        [SVProgressHUD showSuccessWithStatus:@"Done"];
                    }];
                }];
                
            }
        }];
    }
}

- (void)unclaimMethod
{
    [SVProgressHUD showWithStatus:@"Unclaiming..."];
    PFQuery *query = [SocialPosts query];
    [query includeKey:@"circle"];
    [query includeKey:@"user"];
    [query includeKey:@"claimers"];
    [query includeKey:@"reminder"];
    [query includeKey:@"comments"];
    [query includeKey:@"comments.user"];
    [query getObjectInBackgroundWithId:self.socialPost.objectId block:^(PFObject *object, NSError *error) {
        SocialPosts *post = (SocialPosts *)object;
        self.socialPost = post;
        if ([self.socialPost.claimerUsernames containsObject:currentUserObject.user]) {
            if (post.claimers.count > 1) {
                int indexPath = [post.claimers indexOfObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId]];
                [post removeObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId] forKey:@"claimers"];
                [post removeObject:currentUserObject.user forKey:@"claimerUsernames"];
                
                Reminders *reminder = [post.reminder objectAtIndex:indexPath];
                [post removeObject:[Reminders objectWithoutDataWithObjectId:reminder.objectId] forKey:@"reminder"];
                
                [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.tableView reloadData];
                        [SVProgressHUD showSuccessWithStatus:@"Done"];
                    }];
                }];
                
            } else {
                [post setIsClaimed:NO];
                int indexPath = [post.claimerUsernames indexOfObject:currentUserObject.user];
                [post removeObject:[UserInfo objectWithoutDataWithObjectId:currentUserObject.objectId] forKey:@"claimers"];
                [post removeObject:currentUserObject.user forKey:@"claimerUsernames"];
                Reminders *reminder = [post.reminder objectAtIndex:indexPath];
                [post removeObject:[Reminders objectWithoutDataWithObjectId:reminder.objectId] forKey:@"reminder"];
                
                [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.tableView reloadData];
                        [SVProgressHUD showSuccessWithStatus:@"Done"];
                    }];
                }];
            }
        } else {
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"Done"];
        }
    }];
}

- (void)setButtonTitle:(UIButton *)button withTitle:(NSString *)title
{
    [button setTitle:title forState: UIControlStateNormal];
    [button setTitle:title forState: UIControlStateApplication];
    [button setTitle:title forState: UIControlStateHighlighted];
    [button setTitle:title forState: UIControlStateReserved];
    [button setTitle:title forState: UIControlStateSelected];
    [button setTitle:title forState: UIControlStateDisabled];
}

- (void)editSocialPostViewController:(EditSocialPostViewController *)controller didFinishWithPost:(SocialPosts *)post
{
    self.socialPost = post;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditPost"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        EditSocialPostViewController *controller = (EditSocialPostViewController *)nav.topViewController;
        controller.post = self.socialPost;
        controller.delegate = self;
    }
}

@end