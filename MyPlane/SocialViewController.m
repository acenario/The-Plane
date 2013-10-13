//
//  SocialViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SocialViewController.h"
#import "CurrentUser.h"
#import "Reachability.h"

@interface SocialViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;
@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation SocialViewController {
    UserInfo *currentUserObject;
//    Circles *currentCircleObject;
    SocialPosts *currentSocialObject;
    PFQuery *userQuery;
    NSDateFormatter *dateFormatter;
    Reachability *reachability;
//    PFQuery *postQuery;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.loadingViewEnabled = NO;
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.sharedManager = [CurrentUser sharedManager];
    currentUserObject = self.sharedManager.currentUser;
    [self loadObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"spCenterTabbarItemTapped"
                                               object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
//    
//    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        currentUserObject = (UserInfo *)object;
//    }];
//
    
    
    [self configureViewController];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
}

-(void)configureViewController {
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"spCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add Social Post command!");
        
        //[self performSegueWithIdentifier:@"AddSocialPost" sender:nil];
        [self performSegueWithIdentifier:@"addReminder" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    userQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:userQuery];
    [query includeKey:@"members"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    
    PFQuery *postsQuery = [SocialPosts query];
    [postsQuery whereKey:@"circle" matchesQuery:query];
    [postsQuery whereKey:@"username" notContainedIn:sharedManager.currentUser.blockedUsernames];
    [postsQuery includeKey:@"circle"];
    [postsQuery includeKey:@"user"];
    [postsQuery includeKey:@"claimers"];
    [postsQuery includeKey:@"reminder"];
    [postsQuery includeKey:@"comments"];
    [postsQuery includeKey:@"comments.user"];
    [postsQuery orderByDescending:@"createdAt"];
    
//    postQuery = postsQuery;
    
    if (self.objects.count == 0) {
        postsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return postsQuery;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"%d", [self.objects count]);
    return self.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    SocialPosts *postObject = [self.objects objectAtIndex:section];
//    NSArray *comments = postObject.comments;
    
//    if (comments.count >= 3) {
//        return 6;
//    } else {
//        return comments.count + 3;
//    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SocialPosts *object = [self.objects objectAtIndex:indexPath.section];
//    NSArray *comments = object.comments;

    if (indexPath.row == 0) {
        static NSString *identifier = @"PostCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        UserInfo *userObject = (UserInfo *)object.user;
        UILabel *name = (UILabel *)[cell viewWithTag:5101];
        UILabel *text = (UILabel *)[cell viewWithTag:5102];
        UILabel *date = (UILabel *)[cell viewWithTag:1];
        UILabel *circle = (UILabel *)[cell viewWithTag:5104];
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:5111];
        UIImageView *clippy = (UIImageView *)[cell viewWithTag:109];
        
        name.text = [NSString stringWithFormat:@"%@ %@", userObject.firstName, userObject.lastName];
        text.text = object.text;
        circle.text = [object.circle objectForKey:@"displayName"];
        ownerImage.file = userObject.profilePicture;
        date.text = [dateFormatter stringFromDate:object.createdAt];
        [ownerImage loadInBackground];
        
        if (object.reminderTask.length > 0) {
            clippy.hidden = NO;
        } else {
            clippy.hidden = YES;
        }
        
        return cell;
    } else {
        static NSString *identifier = @"ShowMoreCommentsCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        return cell;
    }
//    } else if (((comments.count >= 3) && (indexPath.row == 5)) || ((comments.count < 3) && (indexPath.row == comments.count + 2))) {
//        static NSString *identifier = @"CommentPostCell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        
//        UITextField *commentTextfield = (UITextField *)[cell viewWithTag:5141];
//        UIButton *addCommentButton = (UIButton *)[cell viewWithTag:5131];
//        
//        self.commentTextField = commentTextfield;
//        self.addCommentButton = addCommentButton;
//        
//        commentTextfield.delegate = self;
//        [commentTextfield addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
//        
//        return cell;
//    } else {
//        static NSString *identifier = @"CommentCell";
//        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        
//        Comments *comment = [comments objectAtIndex:indexPath.row - 2];
//        UserInfo *commentUser = (UserInfo *)comment.user;
//        
//        UILabel *commentText = (UILabel *)[cell viewWithTag:5103];
//        PFImageView *commentUserImage = (PFImageView *)[cell viewWithTag:5112];
//        
//        commentUserImage.file = commentUser.profilePicture;
//        commentText.text = [comment objectForKey:@"text"];
//        
//        [commentUserImage loadInBackground];
//        
//        return cell;
//    }
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
    
    if (indexPath.row == 0) {
        SocialPosts *object = [self.objects objectAtIndex:indexPath.section];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5101];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:5102];
        UILabel *circleLabel = (UILabel *)[cell viewWithTag:302];
        UILabel *circleNameLabel = (UILabel *)[cell viewWithTag:5104];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:1];
        UIFont *socialFont = [UIFont flatFontOfSize:14];
        UIFont *postFont = [UIFont flatFontOfSize:16];
        
        nameLabel.font = socialFont;
        nameLabel.textColor = [UIColor asbestosColor];
        postLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
        circleLabel.font = socialFont;
        circleNameLabel.font = socialFont;
        dateLabel.font = socialFont;
        
        nameLabel.adjustsFontSizeToFitWidth = YES;
        dateLabel.adjustsFontSizeToFitWidth = YES;
        circleNameLabel.adjustsFontSizeToFitWidth = YES;
        
        int i;
        
        for(i = 16; i > 12; i=i-2)
        {
            // Set the new font size.
            postFont = [UIFont flatFontOfSize:i];
            // You can log the size you're trying: NSLog(@"Trying size: %u", i);
            
            /* This step is important: We make a constraint box
             using only the fixed WIDTH of the UILabel. The height will
             be checked later. */
            CGSize constraintSize = CGSizeMake(214.0f, MAXFLOAT);
            
            // This step checks how tall the label would be with the desired font.
            CGSize labelSize = [object.text sizeWithFont:postFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            /* Here is where you use the height requirement!
             Set the value in the if statement to the height of your UILabel
             If the label fits into your required height, it will break the loop
             and use that font size. */
            if(labelSize.height <= 49.0f)
                break;
        }
        
        
        postLabel.font = postFont;
        
        [cell.contentView addSubview:imgView];
        
    } else {
        UIFont *commentFont = [UIFont flatFontOfSize:18];
        UIColor *fontColor = [UIColor lightGrayColor];
        UILabel *commentLabel = (UILabel *)[cell viewWithTag:9];
        commentLabel.font = commentFont;
        commentLabel.textColor = fontColor;
        
        [cell.contentView addSubview:bottomView];
        
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        nil;
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else {
       
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    [SVProgressHUD showWithStatus:@"Deleting post"];
    SocialPosts *socialPost = [self.objects objectAtIndex:indexPath.section];
    UserInfo *userObject = (UserInfo *)[socialPost objectForKey:@"user"];
    NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
    
    for (Comments *comment in socialPost.comments) {
        [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
    }
    
    if ([userObject.user isEqualToString:[PFUser currentUser].username]) {
        [socialPost.circle removeObject:[SocialPosts objectWithoutDataWithObjectId:socialPost.objectId] forKey:@"posts"];
        [socialPost.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [socialPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [Comments deleteAllInBackground:commentsToDelete];
                    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                    [self loadObjects];
                    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                    
                    [SVProgressHUD showSuccessWithStatus:@"Deleted Post!"];
                    
                } else {
                    NSLog(@"error: %@", error);
                }
            }];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Can't delete try blocking instead!"];
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    SocialPosts *object = [self.objects objectAtIndex:indexPath.section];
//    NSArray *comments = object.comments;
    
    if (indexPath.row == 0) {
        return 90;
    } else {
        return 33;
    }
//    } else if (((comments.count >= 3) && (indexPath.row == 5)) || ((comments.count < 3) && (indexPath.row == comments.count + 2))) {
//        return 44;
//    } else {
//        return 60;
//    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        return UITableViewCellEditingStyleNone;
    } else {
        if (indexPath.row == 0)
        {
            SocialPosts *post = (SocialPosts *)[self.objects objectAtIndex:indexPath.section];
            if ([post.username isEqualToString:[PFUser currentUser].username]) {
                return UITableViewCellEditingStyleDelete;
            } else {
        
            return UITableViewCellEditingStyleNone;
            }
        }
        
        return UITableViewCellEditingStyleNone;
    }
}

- (IBAction)checkTextField:(id)sender
{
    
    /// THIS IS FOR THE DEPRECATED 3 COMMENTS PREVIEW IN SOCIAL POSTS
    /// GO AWAY
    
    UITextField *textField = (UITextField *)sender;
    //NSLog(@"%@", textField.text);
    NSString *removedSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 70 - textField.text.length;
//    self.limitLabel.text = [NSString stringWithFormat:@"%d characters left", limit];
    if ((removedSpaces.length > 0) && (limit >= 0)) {
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


- (IBAction)addComment:(id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    SocialPosts *socialPost = [self.objects objectAtIndex:clickedButtonPath.section];
    NSString *userObjectID = currentUserObject.objectId;

    UserInfo *userToAdd = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:userObjectID];
    
    Comments *comment = [Comments object];
    
    [comment setObject:userToAdd forKey:@"user"];
    [comment setObject:self.commentTextField.text forKey:@"text"];
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.commentTextField.text = @"";
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        [socialPost addObject:comment forKey:@"comments"];
        [socialPost saveInBackground];
        [self loadObjects];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SocialPostDetail"]) {
        SocialPostDetailViewController *controller = [segue destinationViewController];
        controller.delegate = self;
//        controller.postQuery = postQuery;
        controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
    } else if ([segue.identifier isEqualToString:@"AddSocialPost"]) {
        AddSocialPostViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.currentUser = currentUserObject;
        controller.userQuery = userQuery;
    } else if ([segue.identifier isEqualToString:@"addReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.unwinder = 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.objects.count == 0) {
        return @"Join a circle...";
    } else {
        return nil;
    }
}

- (void)addSocialDidFinishAdding:(AddSocialPostViewController *)controller
{
    [self loadObjects];
}

//- (void)socialPostDetailRefreshData:(SocialPostDetailViewController *)controller
//{
//    [self loadObjects];
//    controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
//    NSLog(@"%@")
//}

- (IBAction)unwindToSocial:(UIStoryboardSegue *)unwindSegue {
    
}

@end
