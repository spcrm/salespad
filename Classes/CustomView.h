//
//  CustomView.h
//  SalesPad
//
//  Created by SP on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FiscalCalendar.h"

@protocol CustomViewDelegate
- (void) modifiedRange:(int) startTab endTab:(int)endTab;
@end

@interface CustomView : UIView {
	int startTab, endTab;
	int currentTab, activeTab;
	NSMutableArray* tabList;
	id <CustomViewDelegate> delegate;
}

@property (nonatomic) int startTab;
@property (nonatomic) int endTab;
@property (nonatomic) int currentTab;
@property (nonatomic) int activeTab;

@property (nonatomic,copy) NSMutableArray* tabList;
@property (assign) id <CustomViewDelegate> delegate;

- (void) setForCalendar:(FiscalCalendar*)calendar;
- (void) clearAllTabs;
- (void) addTab:(NSString*)title;
- (void) refresh;
@end
