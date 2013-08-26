//
//  AddCommonTaskViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddCommonTaskViewController.h"
#import "MZFormSheetController.h"

@interface AddCommonTaskViewController ()

@end

@implementation AddCommonTaskViewController {
    BOOL editing;
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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    if (!(self.task)) {
        editing = NO;
        self.doneButton.enabled = NO;
    } else {
        editing = YES;
        self.textField.text = self.task.text;
        [self.navigationItem setTitle:@"Edit Task"];
        self.doneButton.enabled = YES;
    }
    
    self.textField.delegate = self;
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
}

-(void)hideKeyboard {
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *removedSpaces = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (removedSpaces.length > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = YES;
    }
    
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
    
    self.taskLabel.font = [UIFont boldFlatFontOfSize:17];
    self.textField.font = [UIFont flatFontOfSize:16];

    
    return cell;
}

- (IBAction)done:(id)sender {
    if (editing) {
        
        self.task.text = self.textField.text;
        self.task.lastUsed = [NSDate date];
        
        [self.task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
                [self.delegate didFinish];
            }];
        }];
    } else {
        
        CommonTasks *task = [CommonTasks object];
        task.text = self.textField.text;
//        task.user = self.currentUser;
        task.username = [PFUser currentUser].username;
        task.lastUsed = [NSDate date];
        
        [task saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
                [self.delegate didFinish];
            }];
        }];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

@end
