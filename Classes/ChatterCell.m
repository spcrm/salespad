//
//  ChatterCell.m
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatterCell.h"


@implementation ChatterCell

@synthesize photo, body, link, author, date, commentMarker, respond;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    return;
    //[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void) setfeed:(ChatterFeed*)f {
	[body setText:[f body]];
	[author setText:[f author]];
	[date setText:[f date]];
	if ([f fid] == nil) {
		[commentMarker setHidden:([f fid] == nil)];
	}
	//NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[f photourl]]];
	//[photo setImage:[UIImage imageWithData:imageData]];
	//[imageData release];
}

- (void)dealloc {
	[photo release];
	[body release];
	[link release];
	[author release];
	[date release];
    [super dealloc];
}


@end
