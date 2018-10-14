//
//  GameScene.h
//  ShiftPong
//

//  Copyright (c) 2014 Christian Patrick Helvin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property (strong, nonatomic) SKAction *hitSoundAction;

@end
