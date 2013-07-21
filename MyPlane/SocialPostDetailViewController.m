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
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUserObject = (UserInfo *)object;
    }];
    
    NSLog(@"%@", self.socialPost);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *comments = self.socialPost.comments;
    
    return comments.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *comments = self.socialPost.comments;
    if (indexPath.row == 0) {
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
    } else if ((((comments.count >= 3) && (indexPath.row == comments.count + 1)) || ((comments.count < 3) && (indexPath.row == comments.count + 1)))) {
        static NSString *identifier = @"CommentPostCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        UITextField *commentTextfield = (UITextField *)[cell viewWithTag:5241];
        UIButton *addCommentButton = (UIButton *)[cell viewWithTag:5231];
        
        self.commentTextField = commentTextfield;
        self.addCommentButton = addCommentButton;
        
        commentTextfield.delegate = self;
        [commentTextfield addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    } else {
        static NSString *identifier = @"CommentCell";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        Comments *comment = [comments objectAtIndex:indexPath.row - 1];
        UserInfo *commentUser = (UserInfo *)comment.user;
        
        UILabel *commentText = (UILabel *)[cell viewWithTag:5204];
        PFImageView *commentUserImage = (PFImageView *)[cell viewWithTag:5212];
        
        commentUserImage.file = commentUser.profilePicture;
        commentText.text = [comment objectForKey:@"text"];
        
        [commentUserImage loadInBackground];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *comments = self.socialPost.comments;
    
    if (indexPath.row == 0) {
        return 90;
    } else if ((((comments.count >= 3) && (indexPath.row == comments.count + 1)) || ((comments.count < 3) && (indexPath.row == comments.count + 1)))) {
        return 44;
    } else {
        return 60;
    }
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
    Comments *comment = [Comments object];
    
    [comment setObject:currentUserObject forKey:@"user"];
    [comment setObject:self.commentTextField.text forKey:@"text"];
    NSLog(@"%@", comment);
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.commentTextField.text = @"";
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        [self.socialPost addObject:comment forKey:@"comments"];
        [self.socialPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            NSLog(@"%@", self.socialPost);
            [self.delegate socialPostDetailRefreshData:self];
        }];
    }];
}

@end
