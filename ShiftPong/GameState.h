//
//  GameState.h
//  ShiftPong
//
//  Created by Christian Patrick Helvin on 1/3/15.
//  Copyright (c) 2015 Blue Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (nonatomic, assign) int Score;
@property (nonatomic, assign) int highScore;

+ (instancetype)sharedInstance;

- (void) saveState;

@end
