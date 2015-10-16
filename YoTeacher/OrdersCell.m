/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */


#import "OrdersCell.h"
#import "UIImageView+HeadImage.h"

@interface OrdersCell (){
    UILabel *_timeLabel;
    UILabel *_detailLabel;
    UIView *_lineView;
}

@end

@implementation OrdersCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 7, 80, 16)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_timeLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 175, 20)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:15];
        _detailLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_detailLabel];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
        _lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    
    //    [self.imageView sd_setImageWithURL:_imageURL placeholderImage:_placeholderImage];
    [self.imageView imageWithUsername:_name placeholderImage:_placeholderImage];
    self.imageView.frame = CGRectMake(10, 7, 45, 45);
    
    //    self.textLabel.text = _name;
    [self.textLabel setTextWithUsername:_name];
    self.textLabel.frame = CGRectMake(65, 7, 175, 20);
    
    _detailLabel.text = _detailMsg;
    _timeLabel.text = _time;
    
    frame = _lineView.frame;
    frame.origin.y = self.contentView.frame.size.height - 1;
    _lineView.frame = frame;
}

-(void)setName:(NSString *)name{
    _name = name;
}

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
@end
