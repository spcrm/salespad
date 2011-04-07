//
//  CustomView.m
//  SalesPad
//
//  Created by SP on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomView.h"
#import "Reachability.h"

@implementation CustomView

@synthesize startTab, endTab, tabList, delegate, currentTab, activeTab;

- (void) baseInit {
	tabList = [[NSMutableArray array]retain];
	startTab = 0;
	endTab = -1;
	currentTab = -1;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self baseInit]; 
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super initWithCoder:aDecoder])) {
		[self baseInit];
	}
	return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	if ([tabList count] == 0) {
		return;
	}
	
	float desiredTabWidth = (self.frame.size.width)/[tabList count]-1;
	
	for (int i=0; i < [tabList count]; i++) {
		UIButton* button = [tabList objectAtIndex:i];
		CGRect buttonFrame = CGRectMake(desiredTabWidth * i+i, 0, desiredTabWidth, self.frame.size.height);
		button.frame = buttonFrame;
	}
}

- (UIColor*) getColor:(int)r g:(int)g b:(int)b
{
	return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1.0f];
}

- (void) addTab:(NSString *)title 
{
	UILabel *button = [[[UILabel alloc] init] retain];
	button.contentMode = UIViewContentModeCenter;
	[button setText:[[[NSString alloc]initWithString:title]retain]];
	[button setTextColor:[UIColor whiteColor]];
	[button setFont:[UIFont systemFontOfSize:10]];
	[button setTextAlignment:UITextAlignmentCenter];
	[button setBackgroundColor:[self getColor:0x8e g:0x8e b:0x8e]];
	[[self tabList] addObject:button];
	[self addSubview:button];
	[self setEndTab:[self endTab]+1];
	[self refresh];
	[self setNeedsLayout];
}
	 
-(void) refresh
{
	for (int i=0; i<[[self tabList]count]; i++) {
		UILabel *button = [[self tabList] objectAtIndex:i];
		[button setFont:[UIFont systemFontOfSize:10]];
		[button setBackgroundColor:[self getColor:0x8e g:0x8e b:0x8e]];
		[button setHighlighted:NO];
	}
	
	UILabel *button = [[self tabList]objectAtIndex:startTab];
	[button setHighlighted:YES];
	[button setFont:[UIFont systemFontOfSize:14]];
	[button setBackgroundColor:[self getColor:0x6a g:0xb8 b:0xc5]];

	button = [[self tabList]objectAtIndex:endTab];
	[button setHighlighted:YES];
	[button setFont:[UIFont systemFontOfSize:14]];
	[button setBackgroundColor:[self getColor:0x6a g:0xb8 b:0xc5]];
}


-(void)handleTouchAtLocation:(int) whichTab {
	//called if this is the first time this tab is touched.
	//remove highlight on the previous tab
	//NSLog(@"New Tab: %d, Old Tab: %d - Start %d to %d", whichTab, currentTab, startTab, endTab);
	if (whichTab > [[self tabList] count] || whichTab < 0) {
		return;
	}
	
	if (currentTab == startTab) {
		startTab = whichTab;
	} else if (currentTab == endTab) {
		endTab = whichTab;
	}
	
	currentTab = whichTab;
	[self refresh];
}

- (int)whereTouched:(CGPoint) touchLocation {
	int touchedTab = 0;
	
	for(int i = [tabList count] - 1; i>=0; i--) {
		UIButton* button = [[self tabList]objectAtIndex:i];
		if(touchLocation.x > button.frame.origin.x) {
			touchedTab = i;
			break;
		}
	}
	
	return touchedTab;
}
	

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//which is the nearest tab - do nothing unless we are touching the selected tab.
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	int where = [self whereTouched:touchLocation];
	if (where == [self startTab] || where == [self endTab]) {
		//NSLog(@"Set Current Tab: %d", where);
		[self setCurrentTab:where];
		[self handleTouchAtLocation:[self currentTab]];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self];
	int where = [self whereTouched:touchLocation];

	//if we touching a different tab then engage.
	if (where != [self currentTab]) {
		
		//if we were not engaged then should we?
		if ([self currentTab] == -1) {
			if (where == [self startTab] || where == [self endTab]) {
				[self setCurrentTab:where];
			}
		} 

		[self handleTouchAtLocation:where];
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setCurrentTab:-1];
	//switch start and end tab if needed.
	if (startTab > endTab) {
		int tmp = startTab;
		startTab = endTab;
		endTab = tmp;
	}
	[delegate modifiedRange:startTab endTab:endTab];
}

- (void) clearAllTabs 
{
	startTab = 0;
	endTab = -1;
	currentTab = -1;
	[[self tabList] removeAllObjects];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void) setForCalendar:(FiscalCalendar*)calendar
{
	[self clearAllTabs];
	NSDateFormatter *month_name_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[month_name_formatter setDateFormat:@"MMM"];
	NSDate* start = [calendar firstDayOfYear];
	for(int i=0;i<12;i++){
		NSDate* date = [calendar dateByAddingMonths:i toDate:start];
		[self addTab:[month_name_formatter stringFromDate:date]];
	}
}

- (void)dealloc {
	[tabList release];
	tabList = nil;
    [super dealloc];
}


@end
