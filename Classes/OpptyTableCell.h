//
//  OpptyTableCell.h
//  SalesPad
//
//  Created by SP on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OpptyTableCell : UITableViewCell {
	IBOutlet UILabel	*name;
	IBOutlet UILabel    *date;
	IBOutlet UILabel	*amount;
	IBOutlet UILabel	*owner;
	IBOutlet UILabel	*stage;
	IBOutlet UIImageView* thumb;
	IBOutlet UIButton	*detail;
}

@property (nonatomic, retain) IBOutlet UILabel	*name;
@property (nonatomic, retain) IBOutlet UILabel  *date;
@property (nonatomic, retain) IBOutlet UILabel	*amount;
@property (nonatomic, retain) IBOutlet UILabel	*owner;
@property (nonatomic, retain) IBOutlet UILabel	*stage;
@property (nonatomic, retain) IBOutlet UIImageView* thumb;
@property (nonatomic, retain) IBOutlet UIButton  *detail;

@end
