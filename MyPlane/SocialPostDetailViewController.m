//
//  SocialPostDetailViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SocialPostDetailViewController.h"

@interface SocialPostDetailViewController ()

@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *addCommentButton;

@end

@implementation SocialPostDetailViewController {
    UserInfo *currentUserObject;
    SocialPosts *currentSocialObject;
    PFQuery *userQuery;
    NSDateFormatter *dateFormatter;
    
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
    [self configureViewController];
	// Do any additional setup after loading the view.
    userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
    }];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
        circle.text = [self.socialPost.circle objectForKey:@"name"];
        date.text = [displayDateFormat stringFromDate:self.socialPost.createdAt];
        ownerImage.file = userObject.profilePicture;
        [ownerImage loadInBackground];
        
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *identifier = @"CommentPostCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        UITextField *commentTextfield = (UITextField *)[cell viewWithTag:5241];
        UIButton *addCommentButton = (UIButton *)[cell viewWithTag:5231];
        
        self.commentTextField = commentTextfield;
        self.addCommentButton = addCommentButton;
        
        commentTextfield.delegate = self;
        //        [commentTextfield addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    } else {
        static NSString *identifier = @"CommentCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        
        Comments *comment = (Comments *)[self.objects objectAtIndex:indexPath.row];
        
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
    }
    
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
    
    if (indexPath.section == 0) {
            
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5201];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:5202];
        UILabel *circleTitle = (UILabel *)[cell viewWithTag:520];
        UILabel *circleLabel = (UILabel *)[cell viewWithTag:5203];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:521];

        nameLabel.font = [UIFont flatFontOfSize:14];
        postLabel.font = [UIFont flatFontOfSize:16];
        circleTitle.font = [UIFont flatFontOfSize:14];
        circleLabel.font = [UIFont flatFontOfSize:14];
        dateLabel.font = [UIFont flatFontOfSize:14];
                        
    } else if (indexPath.section == 1) {
        UITextField *postComment = (UITextField *)[cell viewWithTag:5241];
        postComment.font = [UIFont flatFontOfSize:14];
        
        
        
    } else {
        
        UILabel *commentDate = (UILabel *)[cell viewWithTag:1];
        UILabel *userNameLabel = (UILabel *)[cell viewWithTag:110];
        UILabel *commentText = (UILabel *)[cell viewWithTag:5204];

        commentText.font = [UIFont flatFontOfSize:15];
        commentDate.font = [UIFont flatFontOfSize:14];
        userNameLabel.font = [UIFont flatFontOfSize:14];
        
        [cell.contentView addSubview:imgView];
        
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 90;
            break;
            
        case 1:
            return 44;
            break;
            
        default:
            return 60;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    nil;
}

- (IBAction)checkTextField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if (textField.text.length > 0) {
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

@end