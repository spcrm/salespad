//
//  OpptyTableCell.m
//  SalesPad
//
//  Created by SP on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpptyTableCell.h"
#import "Currency.h"



@implementation OpptyTableCell

@synthesize name, date, stage, amount, owner, thumb, detail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[name release];
	[date release];
	[stage release];
	[amount release];
	[owner release];
	[thumb release];
	[detail release];
    [super dealloc];
}


@end
