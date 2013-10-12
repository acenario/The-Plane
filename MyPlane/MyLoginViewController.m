//
//  MyLoginViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "MyLoginViewController.h"
#import "KGStatusBar.h"
#import <QuartzCore/QuartzCore.h>

const double scale = 0.74f;

@interface MyLoginViewController ()
@property (nonatomic, strong) UIImageView *unUnderline;
@property (nonatomic, strong) UIImageView *pwUnderline;
@property (nonatomic, strong) UIImageView *fpUnderline;

@end

@implementation MyLoginViewController

@synthesize unUnderline,pwUnderline,fpUnderline;

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
    [KGStatusBar dismiss];
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrMockup"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo2"]]];
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    
    
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
        
    //Add Underlines
    unUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    pwUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    fpUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    
    [self.logInView addSubview:self.unUnderline];
    [self.logInView sendSubviewToBack:self.unUnderline];
    
    [self.logInView addSubview:self.pwUnderline];
    [self.logInView sendSubviewToBack:self.pwUnderline];
    
    [self.logInView addSubview:self.fpUnderline];
    [self.logInView sendSubviewToBack:self.fpUnderline];
    
    
    //Set Placeholder
    [self.logInView.usernameField setPlaceholder:@"USERNAME"];
    [self.logInView.passwordField setPlaceholder:@"PASSWORD"];
    
    //Customize Textfields
    self.logInView.usernameField.font = [UIFont flatFontOfSize:20];
    self.logInView.passwordField.font = [UIFont flatFontOfSize:20];
    
    self.logInView.usernameField.textAlignment = NSTextAlignmentLeft;
    self.logInView.passwordField.textAlignment = NSTextAlignmentLeft;
    
    [self.logInView.usernameField setTextColor:[UIColor whiteColor]];
    [self.logInView.passwordField setTextColor:[UIColor whiteColor]];
    
    //Customize Place Holder
    [self.logInView.usernameField setValue:[UIColor colorWithWhite:1.0f alpha:0.44f] forKeyPath:@"_placeholderLabel.textColor"];
    [self.logInView.passwordField setValue:[UIColor colorWithWhite:1.0f alpha:0.44f] forKeyPath:@"_placeholderLabel.textColor"];

    
	// Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Set frame for elements
    if (IS_IPHONE5) {
    [self.logInView.logo setFrame:CGRectMake(45.0f, 20.0f, 235.0f, 145.0f)];
    
    [self.logInView.usernameField setFrame:CGRectMake(29.5f, 195.0f, 260.0f, 20.0f)];
    [self.unUnderline setFrame:CGRectMake(27.5f, 217.0f, 226.0f, 5.0f)];
    
    [self.logInView.passwordField setFrame:CGRectMake(29.5f, 244.0f, 260.0f, 20.0f)];
    [self.pwUnderline setFrame:CGRectMake(27.5f, 265.0f, 226.0f, 5.0f)];
    
    
    [self.logInView.logInButton setFrame:CGRectMake(53.0f, 285.0f, 108.375f, 44.625f)];
    [self.logInView.signUpButton setFrame:CGRectMake(161.375f, 286.0f, 108.375f, 44.625f)];
        
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(83.0f, 339.0f, 160.0f, 20.0f)];
    [self.fpUnderline setFrame:CGRectMake(83.0f, 358.0f, 132.0f, 5.0f)];
        
    } else {
        
        
        [self.logInView.logo setFrame:CGRectMake(75.0, 20.0*scale, 235.0*scale, 145.0*scale)];
        
//        [self.logInView.usernameField setFrame:CGRectMake(29.5, 195.0*scale, 260.0*scale, 20.0*scale)];
//        [self.unUnderline setFrame:CGRectMake(27.5, 217.0*scale, 226.0*scale, 5.0*scale)];
//        
//        [self.logInView.passwordField setFrame:CGRectMake(29.5, 244.0*scale, 260.0*scale, 20.0*scale)];
//        [self.pwUnderline setFrame:CGRectMake(27.5, 265.0*scale, 226.0*scale, 5.0*scale)];
        [self.logInView.usernameField setFrame:CGRectMake(29.5, 187.0*scale, 227.0f, 30.0*scale)];
        [self.unUnderline setFrame:CGRectMake(27.5, 217.0*scale, 226.0, 5.0)];
        
        [self.logInView.passwordField setFrame:CGRectMake(29.5, 236.0*scale, 227.0f, 30.0*scale)];
        [self.pwUnderline setFrame:CGRectMake(27.5, 265.0*scale, 226.0, 5.0)];

        
        [self.logInView.logInButton setFrame:CGRectMake(75.0, 285.0*scale, 108.375*scale, 44.625*scale)];
        [self.logInView.signUpButton setFrame:CGRectMake(161.375, 286.0*scale, 108.375*scale, 44.625*scale)];
        
        [self.logInView.passwordForgottenButton setFrame:CGRectMake(79.0, 339.0*scale, 160.0, 20.0)];
        [self.fpUnderline setFrame:CGRectMake(79.0, 362.0*scale, 132.0, 5.0)];
        
    }
    
    [self.logInView.signUpLabel setText:@""];
    
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignupBtn"] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"loginSelected"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signupSelected"] forState:UIControlStateHighlighted];
    
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgotPassword"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgotPasswordSelected"] forState:UIControlStateHighlighted];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.logInView.usernameField) { 
        textField.text = [textField.text lowercaseString];
    }
    
    return YES;
}

@end
