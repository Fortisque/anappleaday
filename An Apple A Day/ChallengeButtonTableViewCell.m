//
//  ChallengeButtonTableViewCell.m
//  An Apple A Day
//
//  Created by Gavin Chu on 12/29/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "ChallengeButtonTableViewCell.h"

@implementation ChallengeButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonPressed:(id)sender {
    [self.delegate challengeButtonWasPressed];
}
@end