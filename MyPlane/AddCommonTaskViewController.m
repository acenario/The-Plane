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
	// Do any additional setup after loading the view.
    
    if (!(self.task)) {
        editing = NO;
        self.doneButton.enabled = NO;
    } else {
        editing = YES;
        self.textField.text = self.task.text;
        self.navigationController.title = @"Edit Task";
        self.doneButton.enabled = YES;
    }
    
    self.textField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.textField.text length] > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = YES;
    }
    
    return YES;
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
