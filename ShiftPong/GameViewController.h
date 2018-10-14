//
//  GameViewController.h
//  ShiftPong
//

//  Copyright (c) 2014 Christian Patrick Helvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameCenterManager.h"

@interface GameViewController : UIViewController <UIActionSheetDelegate, GameCenterManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *statusDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionBarLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *playerPicture;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *playerStatus;

@end