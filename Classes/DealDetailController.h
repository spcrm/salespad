//
//  DealDetail.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deal.h"
@protocol DealDetailDelegate <NSObject>
-(void) reviewedDeal;
@end

@interface DealDetailController : UIViewController <UIWebViewDelegate>{
	UINavigationItem *titlebar;
	UIWebView		*browser;
	Deal			*deal;
	id <DealDetailDelegate> delegate;
}

@property (nonatomic,retain) IBOutlet UIWebView       *browser;
@property (nonatomic,retain) IBOutlet Deal            *deal;
@property (nonatomic,retain) IBOutlet UINavigationItem *titlebar;
@property (nonatomic,retain) id <DealDetailDelegate> delegate;

-(void) showDeal;
-(IBAction) closeDeal;

@end
