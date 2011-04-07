//
//  NewChatViewController.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewChatterPostDelegate <NSObject>
- (void) post:(NSString*)pid body:(NSString*) body;
@end

@interface NewChatViewController : UIViewController {
	id <NewChatterPostDelegate> delegate;
	NSString    *entity;
	UITextView  *body;
}

@property (nonatomic,retain) id <NewChatterPostDelegate> delegate;
@property (nonatomic,retain) IBOutlet UITextView *body;
@property (nonatomic,copy)   NSString            *entity;
- (IBAction) submit:(id) sender;

@end
