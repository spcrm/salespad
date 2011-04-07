//
//  LoginController.h
//  SalesPad
//
//  Created by SP on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSforce.h"

@protocol LoginDelegate;

@interface LoginController : UIViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITextField* username;
	IBOutlet UITextField* password;
	IBOutlet UIActivityIndicatorView* busyView;
	IBOutlet UITableView  *logintable;
	BOOL	 isloggedin;	
	id <LoginDelegate> delegate;
	UITableViewCell *usernamecell;
	UITableViewCell *passwordcell;
}


@property (nonatomic,retain) IBOutlet UITextField* username;
@property (nonatomic,retain) IBOutlet UITextField* password;
@property (nonatomic, retain) IBOutlet UITableViewCell *usernamecell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordcell;
@property (nonatomic, retain) IBOutlet UITableView *logintable;


@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busyView;

@property (nonatomic, assign) id <LoginDelegate> delegate;

@property (nonatomic) BOOL isloggedin;
- (IBAction)doLogin:(id)sender;
- (IBAction)doOffline:(id)sender;

@end
@protocol LoginDelegate <NSObject>
- (void) loginSuccess:(LoginController*) loginController user:(ZKUserInfo*)user;
- (void) loginCancel:(LoginController*) LoginController;
@end