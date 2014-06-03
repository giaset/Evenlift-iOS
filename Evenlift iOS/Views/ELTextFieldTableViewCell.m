//
//  ELTextFieldTableViewCell.m
//  Evenlift
//
//  Created by Gianni Settino on 2014-05-30.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELTextFieldTableViewCell.h"

@implementation ELTextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 320, 54)];
        [self addSubview:self.textField];
    }
    return self;
}

@end
