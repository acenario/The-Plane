//
//  AddSocialPostViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddSocialPostViewController.h"

@interface AddSocialPostViewController ()

@end

@implementation AddSocialPostViewController {
    BOOL textCheck;
    BOOL circleCheck;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *placeholderText = @"Write a post here...";
    
    self.postTextField.text = placeholderText;
    self.postTextField.textColor = [UIColor grayColor];
    self.postTextField.delegate = self;
    
    if ((self.circle)) {
        self.circleLabel.text = self.circle.displayName;
        circleCheck = YES;
        self.pickCircleCell.userInteractionEnabled = NO;
        self.pickCircleCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self configureDoneButton];
    [self configureViewController];
    
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.postTextField.textColor = [UIColor blackColor];
        self.postTextField.text = @"";
        self.postTextField.userInteractionEnabled = YES;
        [self.postTextField becomeFirstResponder];
    } else {
        nil;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        
        self.postTextField.font = [UIFont flatFontOfSize:14];
        
        [cell.contentView addSubview:imgView];
        
    } else {
        
        self.circleName.font = [UIFont flatFontOfSize:16];
        self.circleLabel.font = [UIFont flatFontOfSize:16];
        self.circleLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
        self.circleLabel.backgroundColor = [UIColor whiteColor];
        self.circleName.backgroundColor = [UIColor whiteColor];
    }
    
    
    return cell;
    
}


- (IBAction)done:(id)sender {
    
    SocialPosts *post = [SocialPosts object];
    [post setObject:self.postTextField.text forKey:@"text"];
    [post setObject:self.circle forKey:@"circle"];
    [post setObject:self.currentUser forKey:@"user"];
        
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.circle addObject:post forKey:@"posts"];
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.delegate addSocialDidFinishAdding:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        
        }];
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCircle"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        PickCircleViewController *controller = (PickCircleViewController *)navController.topViewController;
        controller.delegate = self;
        controller.userQuery = self.userQuery;
    }
}

- (void)pickCircleViewController:(PickCircleViewController *)controller didSelectCircle:(Circles *)circle
{
    self.circleLabel.text = circle.displayName;
    self.circle = circle;
    circleCheck = YES;
    [self configureDoneButton];
}

- (void)hideKeyboard
{
    [self.postTextField resignFirstResponder];
}

- (void)configureDoneButton {
    if ((circleCheck) && (textCheck)) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.postTextField.text.length > 0) {
        textCheck = YES;
    } else {
        textCheck = NO;
    }
    
    [self configureDoneButton];
}

@end
