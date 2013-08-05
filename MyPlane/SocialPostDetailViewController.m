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
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:5211];
        
        name.text = userObject.firstName;
        text.text = self.socialPost.text;
        circle.text = [self.socialPost.circle objectForKey:@"name"];
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
        PFImageView *commentUserImage = (PFImageView *)[cell viewWithTag:5212];
        
        //commentUserImage.file = commentUser.profilePicture;
        
        commentUserImage.file = [comment.user objectForKey:@"profilePicture"];
        commentText.text = comment.text;
        date.text = [dateFormatter stringFromDate:comment.createdAt];
        
        [commentUserImage loadInBackground];
        
        return cell;
    }
    
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

@end