//
//  ChatterCell.h
//  SalesPad
//
//  Created by SP on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatterFeed.h"

/*
 SELECT Id, Type, CreatedById, CreatedBy.FirstName, CreatedBy.LastName,
 ParentId, Parent.Name,
 FeedPost.Body, FeedPost.Title, FeedPost.LinkUrl,
 (SELECT Id, FieldName, OldValue, NewValue
 FROM FeedTrackedChanges ORDER BY Id DESC),
 (SELECT Id, CommentBody, CreatedDate,
 CreatedBy.FirstName, CreatedBy.LastName
 FROM FeedComments ORDER BY CreatedDate)
 FROM OpportunityFeed
 WHERE ParentID = '0063000000aELYd'
 
 
 Owner.FullPhotoUrl
*/ 
@interface ChatterCell : UITableViewCell {
	IBOutlet UIImageView *photo;
	IBOutlet UILabel     *body;
	IBOutlet UILabel     *author;
	IBOutlet UILabel     *date;
	IBOutlet UILabel	 *link;
	IBOutlet UIView		 *commentMarker;
	IBOutlet UIButton	 *respond;
}

@property (nonatomic,retain) IBOutlet UIImageView *photo;
@property (nonatomic,retain) IBOutlet UILabel     *body;
@property (nonatomic,retain) IBOutlet UILabel     *author;
@property (nonatomic,retain) IBOutlet UILabel     *date;
@property (nonatomic,retain) IBOutlet UILabel	  *link;
@property (nonatomic,retain) IBOutlet UIView	  *commentMarker;
@property (nonatomic,retain) IBOutlet UIButton    *respond;



-(void) setfeed:(ChatterFeed*)f;
@end
