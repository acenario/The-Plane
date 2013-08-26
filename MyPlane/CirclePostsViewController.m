//
//  CirclePostsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CirclePostsViewController.h"
#import "AddSocialPostViewController.h"

@interface CirclePostsViewController ()

@end

@implementation CirclePostsViewController {
    //PFQuery *userQuery;
    NSDateFormatter *dateFormatter;
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
    [self loadObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.tableView.rowHeight = 90;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
//    userQuery = [UserInfo query];
//    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
//    
//    //    NSLog(@"%@", currentUserObject);
//    PFQuery *query = [Circles query];
//    [query whereKey:@"members" matchesQuery:userQuery];
//    [query includeKey:@"members"];
    PFQuery *postsQuery = [SocialPosts query];
    [postsQuery whereKey:@"circle" equalTo:[Circles objectWithoutDataWithObjectId:self.circle.objectId]];
    [postsQuery includeKey:@"circle"];
    [postsQuery includeKey:@"user"];
    [postsQuery includeKey:@"comments"];
    [postsQuery includeKey:@"comments.user"];
    [postsQuery orderByDescending:@"createdAt"];
    
    if (self.objects.count == 0) {
        postsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    return postsQuery;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
        static NSString *identifier = @"Posts";
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        UserInfo *userObject = (UserInfo *)object.user;
        Circles *circle = (Circles *)object.circle;
        UILabel *name = (UILabel *)[cell viewWithTag:6403];
        UILabel *text = (UILabel *)[cell viewWithTag:6404];
        
        UILabel *circleNameLabel = (UILabel *)[cell viewWithTag:641];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:642];
        
        
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:6412];
        
        name.text = [NSString stringWithFormat:@"%@ %@", userObject.firstName, userObject.lastName];
        text.text = object.text;
        circleNameLabel.text = circle.displayName;
        dateLabel.text = [dateFormatter stringFromDate:object.createdAt];
        ownerImage.file = userObject.profilePicture;
        [ownerImage loadInBackground];
        
        return cell;
    } else {
        static NSString *identifier = @"Comments";
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
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:6403];
        UILabel *postLabel = (UILabel *)[cell viewWithTag:6404];
        UILabel *circleLabel = (UILabel *)[cell viewWithTag:640];
        UILabel *circleNameLabel = (UILabel *)[cell viewWithTag:641];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:642];
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
        UILabel *commentLabel = (UILabel *)[cell viewWithTag:643];
        commentLabel.font = commentFont;
        commentLabel.textColor = fontColor;
        commentLabel.backgroundColor = [UIColor whiteColor];
        
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *socialPost = [self.objects objectAtIndex:indexPath.section];
    UserInfo *userObject = (UserInfo *)[socialPost objectForKey:@"user"];
    
    [SVProgressHUD showWithStatus:@"Deleting post"];
    if ([userObject.user isEqualToString:[PFUser currentUser].username]) {
        [socialPost deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                [self loadObjects];
                [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                
                [SVProgressHUD showSuccessWithStatus:@"Deleted Post!"];
                
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Detail"]) {
    SocialPostDetailViewController *controller = [segue destinationViewController];
//    controller.delegate = self;
    controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
    } else if ([segue.identifier isEqualToString:@"AddPost"]) {
        AddSocialPostViewController *controller = [segue destinationViewController];
        controller.circle = self.circle;
        controller.currentUser = self.currentUser;
    }
}

@end
