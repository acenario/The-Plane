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


@end

@implementation SocialViewController {
    UserInfo *currentUserObject;
    Circles *currentCircleObject;
    SocialPosts *currentSocialObject;
    PFQuery *userQuery;
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
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
    }];
    
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
        UILabel *circle = (UILabel *)[cell viewWithTag:5104];
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:5111];
        
        name.text = userObject.firstName;
        text.text = object.text;
        circle.text = [object.circle objectForKey:@"name"];
        ownerImage.file = userObject.profilePicture;
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

//- (void)socialPostDetailRefreshData:(SocialPostDetailViewController *)controller
//{
//    [self loadObjects];
//    controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
//    NSLog(@"%@", controller.socialPost);
////    [controller.tableView reloadData];
//}

@end
