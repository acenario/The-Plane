//
//  SocialViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SocialViewController.h"

@interface SocialViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;
@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;

@end

@implementation SocialViewController {
    UserInfo *currentUserObject;
    Circles *currentCircleObject;
    SocialPosts *currentSocialObject;
    PFQuery *userQuery;
    NSDateFormatter *dateFormatter;
//    PFQuery *postQuery;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"spCenterTabbarItemTapped"
                                               object:nil];
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Circles" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@", item);
        [self performSegueWithIdentifier:@"showSocialCircles" sender:nil];
    }];
    item0.tag = 0;
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0]];
    [self.view addSubview:self.uzysSMenu];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
    }];
    
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
        [self performSegueWithIdentifier:@"AddSocialPost" sender:nil];
    }
}

-(IBAction)socialMenu:(id)sender {
    [self.uzysSMenu toggleMenu];
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
    
//    NSLog(@"%@", currentUserObject);
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:userQuery];
    [query includeKey:@"members"];
    
    PFQuery *postsQuery = [SocialPosts query];
    [postsQuery whereKey:@"circle" matchesQuery:query];
    [postsQuery includeKey:@"circle"];
    [postsQuery includeKey:@"user"];
    [postsQuery includeKey:@"comments"];
    [postsQuery includeKey:@"comments.user"];
    [postsQuery orderByDescending:@"createdAt"];
    
//    postQuery = postsQuery;
    
    if (self.objects.count == 0) {
        postsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    NSLog(@"CHECK");
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
        
        name.text = [NSString stringWithFormat:@"%@ %@", userObject.firstName, userObject.lastName];
        text.text = object.text;
        circle.text = [object.circle objectForKey:@"displayName"];
        ownerImage.file = userObject.profilePicture;
        date.text = [dateFormatter stringFromDate:object.createdAt];
        [ownerImage loadInBackground];
        
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
    
    if (indexPath.row == 0) {
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5101];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:5102];
        UILabel *circleLabel = (UILabel *)[cell viewWithTag:302];
        UILabel *circleNameLabel = (UILabel *)[cell viewWithTag:5104];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:1];
        UIFont *socialFont = [UIFont flatFontOfSize:14];
        
        nameLabel.font = socialFont;
        nameLabel.textColor = [UIColor asbestosColor];
        postLabel.font = [UIFont flatFontOfSize:16];
        postLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
        circleLabel.font = socialFont;
        circleNameLabel.font = socialFont;
        dateLabel.font = socialFont;
        
        
        [cell.contentView addSubview:imgView];
        
    } else {
        UIFont *commentFont = [UIFont flatFontOfSize:18];
        UIColor *fontColor = [UIColor lightGrayColor];
        UILabel *commentLabel = (UILabel *)[cell viewWithTag:9];
        commentLabel.font = commentFont;
        commentLabel.textColor = fontColor;
        
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        nil;
    } else {
       
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        controller.userQuery = userQuery;
    }
}

- (void)addSocialDidFinishAdding:(AddSocialPostViewController *)controller
{
    [self loadObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.objects.count == 0) {
        return @"Join a circle...";
    } else {
        return nil;
    }
}

//- (void)socialPostDetailRefreshData:(SocialPostDetailViewController *)controller
//{
//    [self loadObjects];
//    controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
//    NSLog(@"%@")
//}

@end
