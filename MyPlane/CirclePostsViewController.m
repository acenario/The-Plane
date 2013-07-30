//
//  CirclePostsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CirclePostsViewController.h"

@interface CirclePostsViewController ()

@end

@implementation CirclePostsViewController {
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
        UILabel *name = (UILabel *)[cell viewWithTag:6403];
        UILabel *text = (UILabel *)[cell viewWithTag:6404];
//        UILabel *circle = (UILabel *)[cell viewWithTag:5104];
        PFImageView *ownerImage = (PFImageView *)[cell viewWithTag:6412];
        
        name.text = userObject.firstName;
        text.text = object.text;
//        circle.text = [object.circle objectForKey:@"name"];
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
    SocialPostDetailViewController *controller = [segue destinationViewController];
//    controller.delegate = self;
    controller.socialPost = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
}

@end
