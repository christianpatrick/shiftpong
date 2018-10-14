//
//  GameScene.m
//  ShiftPong
//
//  Created by Christian Patrick Helvin on 12/30/14.
//  Copyright (c) 2014 Christian Patrick Helvin. All rights reserved.
//

#import "GameState.h"
#import "GameScene.h"

BOOL tapped;
BOOL hit;
static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
SKSpriteNode* toppaddle;
SKSpriteNode* botpaddle;
SKSpriteNode* ball;
SKSpriteNode* beforeGame;
SKSpriteNode* hud;
static const uint32_t ballCategory  = 0x1 << 0;         // 00000000000000000000000000000001
static const uint32_t topCategory = 0x1 << 1;           // 00000000000000000000000000000010
static const uint32_t botCategory = 0x1 << 2;           // 00000000000000000000000000000100
static const uint32_t topPaddleCategory = 0x1 << 3;     // 00000000000000000000000000001000
static const uint32_t botPaddleCategory = 0x1 << 4;     // 00000000000000000000000000010000

@interface GameScene()

@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic, retain) SKLabelNode* ScoreNode;
@property (nonatomic, retain) SKLabelNode* versionNum;
@property (nonatomic, retain) SKLabelNode* GameOverTextNode;
@property (nonatomic, retain) SKLabelNode* highScoreNode;
@property (nonatomic, retain) SKLabelNode* bottomText;

@end

@implementation GameScene

- (id) initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.306 green:0.765 blue:0.859 alpha:1.0];
        
    }
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    //border for bounce

    CGRect bodyRect = CGRectMake(CGRectGetMidX(self.frame) - (self.frame.size.width)/2, CGRectGetMidY(self.frame) - (self.frame.size.width + 40)/2, self.frame.size.width, self.frame.size.width + 80);
    
    CGRect colorRect = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - (self.frame.size.width - 50)/2, self.frame.size.width, self.frame.size.width - 25);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyRect];
    self.physicsBody.friction = 0.0f;
    
    SKShapeNode *bgRect = [[SKShapeNode alloc] init];
    bgRect.path = [UIBezierPath bezierPathWithRect:colorRect].CGPath;
    bgRect.fillColor = SKColor.whiteColor;
    [self addChild:bgRect];
    
    [self createHUD];
    
    //ball
    ball = [SKSpriteNode spriteNodeWithImageNamed: @"ball"];
    ball.name = ballCategoryName;
    ball.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMidY(colorRect));
    [self addChild:ball];
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    ball.physicsBody.friction = 0.0f;
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0.0f;
    ball.physicsBody.allowsRotation = YES;
    ball.physicsBody.dynamic = NO;
    
    //top paddle
    toppaddle = [[SKSpriteNode alloc] initWithImageNamed: @"paddle"];
    toppaddle.name = paddleCategoryName;
    toppaddle.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMaxY(colorRect) + 3);
    [self addChild:toppaddle];
    toppaddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(toppaddle.frame.size.width, toppaddle.frame.size.height)];
    toppaddle.physicsBody.restitution = 0.0f;
    toppaddle.physicsBody.friction = 0.0f;
    toppaddle.physicsBody.allowsRotation = NO;
    toppaddle.physicsBody.dynamic = NO;
    botpaddle.physicsBody.usesPreciseCollisionDetection = YES;
    
    //bottom paddle
    botpaddle = [[SKSpriteNode alloc] initWithImageNamed: @"paddle"];
    botpaddle.name = paddleCategoryName;
    botpaddle.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMinY(colorRect) - 3);
    [self addChild:botpaddle];
    botpaddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(botpaddle.frame.size.width, toppaddle.frame.size.height)];
    botpaddle.physicsBody.restitution = 0.0f;
    botpaddle.physicsBody.friction = 0.0f;
    botpaddle.physicsBody.allowsRotation = NO;
    botpaddle.physicsBody.dynamic = NO;
    botpaddle.physicsBody.usesPreciseCollisionDetection = YES;
    
    //top outofbounds
    CGRect topRect = CGRectMake(bodyRect.origin.x, CGRectGetMaxY(bodyRect), bodyRect.size.width, 1);
    SKNode* top = [SKNode node];
    top.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:topRect];
    [self addChild:top];
    
    //bottom outofbounds
    CGRect bottomRect = CGRectMake(bodyRect.origin.x, bodyRect.origin.y, bodyRect.size.width, 1);
    SKNode* bottom = [SKNode node];
    bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
    [self addChild:bottom];
    
    top.physicsBody.categoryBitMask = topCategory;
    bottom.physicsBody.categoryBitMask = botCategory;
    ball.physicsBody.categoryBitMask = ballCategory;
    toppaddle.physicsBody.categoryBitMask = topPaddleCategory;
    botpaddle.physicsBody.categoryBitMask = botPaddleCategory;
    
    ball.physicsBody.contactTestBitMask = topCategory|botCategory|topPaddleCategory|botPaddleCategory;
    
    beforeGame = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(CGRectGetMaxX(colorRect), CGRectGetMaxY(colorRect))];
    beforeGame.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMinY(colorRect));
    [self addChild:beforeGame];
    
    self.bottomText = [[SKLabelNode alloc] init];
    self.bottomText = [SKLabelNode labelNodeWithFontNamed:@"Avenir Heavy"];
    self.bottomText.position = CGPointMake(0, -50);
    self.bottomText.text = @"Tap to Start";
    self.bottomText.name = @"start";
    self.bottomText.fontSize = colorRect.size.height/9;
    self.bottomText.fontColor = [UIColor whiteColor];
    [beforeGame addChild:self.bottomText];
    
    tapped = false;
    
    return self;
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == topPaddleCategory)) {
        
        if (ball.physicsBody.velocity.dy <= 0 && hit == true) {
            [GameState sharedInstance].Score+=1;
            self.ScoreNode.text=[NSString stringWithFormat:@"%d",[GameState sharedInstance].Score];
            ball.physicsBody.velocity=CGVectorMake(ball.physicsBody.velocity.dx+0.4, 0);
            [ball.physicsBody applyImpulse:CGVectorMake(0, -20.1f)];
            [self runAction:[SKAction playSoundFileNamed:@"hit.caf" waitForCompletion:NO]];
            hit = false;
            
            if ([GameState sharedInstance].Score%3 == 0) {
                CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
                CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.1; // 0.5 to 1.0, away from white
                CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.7; // 0.5 to 1.0, away from black
                self.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
            }
        }
    }

    if ((firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == botPaddleCategory) ) {
        
        if (ball.physicsBody.velocity.dy >= 0 && hit == false) {
            [GameState sharedInstance].Score+=1;
            self.ScoreNode.text=[NSString stringWithFormat:@"%d",[GameState sharedInstance].Score];
            ball.physicsBody.velocity=CGVectorMake(ball.physicsBody.velocity.dx+0.4, 0);
            [ball.physicsBody applyImpulse:CGVectorMake(0, 20.1f)];
            [self runAction:[SKAction playSoundFileNamed:@"hit.caf" waitForCompletion:NO]];
            hit = true;
            
            if ([GameState sharedInstance].Score%3 == 0) {
                CGFloat hue = ( arc4random() % 256 / 256.0 ); // 0.0 to 1.0
                CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.1; // 0.5 to 1.0, away from white
                CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.7; // 0.5 to 1.0, away from black
                self.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
            }
        }
    }

    if ((firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == botCategory) || (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == topCategory)) {
        
        //Game Over Screen

        [[GameState sharedInstance] saveState];
        
        [toppaddle runAction:[SKAction sequence:@[[SKAction speedTo:0.0f duration:0.1],[SKAction removeFromParent]]]];
        [botpaddle runAction:[SKAction sequence:@[[SKAction speedTo:0.0f duration:0.1],[SKAction removeFromParent]]]];
        [ball runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:0.05],[SKAction removeFromParent]]]];
        
        CGRect colorRect = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - (self.frame.size.width - 50)/2, self.frame.size.width, self.frame.size.width - 25);
        
        SKSpriteNode* afterGame = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(CGRectGetMaxX(colorRect), CGRectGetMaxY(colorRect))];
        afterGame.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMinY(colorRect));
        [self addChild:afterGame];

        self.GameOverTextNode = [[SKLabelNode alloc] init];
        self.GameOverTextNode = [SKLabelNode labelNodeWithFontNamed:@"Avenir Roman"];
        self.GameOverTextNode.position = CGPointMake(0, CGRectGetMidY(colorRect) + 20);
        self.GameOverTextNode.text = @"Game Over";
        self.GameOverTextNode.fontSize = colorRect.size.height/6;
        self.GameOverTextNode.fontColor = [UIColor whiteColor];
        [afterGame addChild:self.GameOverTextNode];
        
        self.bottomText = [[SKLabelNode alloc] init];
        self.bottomText = [SKLabelNode labelNodeWithFontNamed:@"Avenir Heavy"];
        self.bottomText.position = CGPointMake(0, -50);
        self.bottomText.text = @"Retry Game";
        self.bottomText.name = @"retry";
        self.bottomText.fontSize = colorRect.size.height/9;
        self.bottomText.fontColor = [UIColor whiteColor];
        [afterGame addChild:self.bottomText];
        
        self.highScoreNode = [[SKLabelNode alloc] init];
        self.highScoreNode = [SKLabelNode labelNodeWithFontNamed:@"Avenir Heavy"];
        self.highScoreNode.position = CGPointMake(0, CGRectGetMinY(colorRect) - 70);
        self.highScoreNode.text = [NSString stringWithFormat:@"High Score: %d", [GameState sharedInstance].highScore];
        self.highScoreNode.fontSize = colorRect.size.height/14;
        self.highScoreNode.fontColor = [UIColor blackColor];
        [afterGame addChild:self.highScoreNode];
        
    }

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGRect colorRect = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - (self.frame.size.width - 50)/2, self.frame.size.width, self.frame.size.width - 25);
    
    CGPoint topdiff = CGPointMake(toppaddle.position.x, toppaddle.position.y);
    CGPoint botdiff = CGPointMake(botpaddle.position.x, botpaddle.position.y);
    
    if (ball.physicsBody.dynamic) {} else {
        ball.physicsBody.dynamic = YES;
        hit = false;
        [ball.physicsBody applyImpulse:CGVectorMake(.7f, -10.7f)];
        [beforeGame runAction:[SKAction removeFromParent]];
    }
    
    CGMutablePathRef toppath = CGPathCreateMutable();
    CGMutablePathRef toppathstart = CGPathCreateMutable();
    CGMutablePathRef botpath = CGPathCreateMutable();
    CGMutablePathRef botpathstart = CGPathCreateMutable();
    
    if (tapped == true) {
        
        tapped = false;
        
        //TOP
        CGPathMoveToPoint(toppathstart, NULL, topdiff.x, CGRectGetMaxY(colorRect) + 3);
        CGPathAddLineToPoint(toppathstart, NULL, CGRectGetMaxX(colorRect), CGRectGetMaxY(colorRect) + 3);
        SKAction *toplinestart = [SKAction followPath:toppathstart asOffset:NO orientToPath:NO speed:250.0f];
        
        CGPathMoveToPoint(toppath, NULL, CGRectGetMinX(colorRect), CGRectGetMaxY(colorRect) + 3);
        CGPathAddLineToPoint(toppath, NULL, CGRectGetMaxX(colorRect), CGRectGetMaxY(colorRect) + 3);
        SKAction *topline = [SKAction followPath:toppath asOffset:NO orientToPath:NO speed:250.0f];
        SKAction *tlrepeat = [SKAction repeatActionForever:topline];
        
        SKAction *tlseq = [SKAction sequence:@[toplinestart, tlrepeat]];
        
        //BOTTOM
        CGPathMoveToPoint(botpathstart, NULL, botdiff.x, CGRectGetMinY(colorRect) - 3);
        CGPathAddLineToPoint(botpathstart, NULL, CGRectGetMinX(colorRect), CGRectGetMinY(colorRect) - 3);
        SKAction *botlinestart = [SKAction followPath:botpathstart asOffset:NO orientToPath:NO speed:250.0f];
        
        CGPathMoveToPoint(botpath, NULL, CGRectGetMaxX(colorRect), CGRectGetMinY(colorRect) - 3);
        CGPathAddLineToPoint(botpath, NULL, CGRectGetMinX(colorRect), CGRectGetMinY(colorRect) - 3);
        SKAction *botline = [SKAction followPath:botpath asOffset:NO orientToPath:NO speed:250.0f];
        SKAction *blrepeat = [SKAction repeatActionForever:botline];
        
        SKAction *blseq = [SKAction sequence:@[botlinestart, blrepeat]];
        
        //RUN
        [toppaddle runAction: tlseq];
        [botpaddle runAction: blseq];
        
    } else {
        
        tapped = true;
        
        //TOP
        CGPathMoveToPoint(toppathstart, NULL, topdiff.x, CGRectGetMaxY(colorRect) + 3);
        CGPathAddLineToPoint(toppathstart, NULL, CGRectGetMinX(colorRect), CGRectGetMaxY(colorRect) + 3);
        SKAction *toplinestart = [SKAction followPath:toppathstart asOffset:NO orientToPath:NO speed:250.0f];
        
        CGPathMoveToPoint(toppath, NULL, CGRectGetMaxX(colorRect), CGRectGetMaxY(colorRect) + 3);
        CGPathAddLineToPoint(toppath, NULL, CGRectGetMinX(colorRect), CGRectGetMaxY(colorRect) + 3);
        SKAction *topline = [SKAction followPath:toppath asOffset:NO orientToPath:NO speed:250.0f];
        SKAction *tlrepeat = [SKAction repeatActionForever:topline];
        
        SKAction *tlseq = [SKAction sequence:@[toplinestart, tlrepeat]];
        
        //BOTTOM
        CGPathMoveToPoint(botpathstart, NULL, botdiff.x, CGRectGetMinY(colorRect) - 3);
        CGPathAddLineToPoint(botpathstart, NULL, CGRectGetMaxX(colorRect), CGRectGetMinY(colorRect) - 3);
        SKAction *botlinestart = [SKAction followPath:botpathstart asOffset:NO orientToPath:NO speed:250.0f];
        
        CGPathMoveToPoint(botpath, NULL, CGRectGetMinX(colorRect), CGRectGetMinY(colorRect) - 3);
        CGPathAddLineToPoint(botpath, NULL, CGRectGetMaxX(colorRect), CGRectGetMinY(colorRect) - 3);
        SKAction *botline = [SKAction followPath:botpath asOffset:NO orientToPath:NO speed:250.0f];
        SKAction *blrepeat = [SKAction repeatActionForever:botline];
        
        SKAction *blseq = [SKAction sequence:@[botlinestart, blrepeat]];
        
        //RUN
        [toppaddle runAction: tlseq];
        [botpaddle runAction: blseq];
    }
    
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start"]) {
        tapped = true;
    }
    
    if ([node.name isEqualToString:@"retry"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
        
        GameScene * scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }
}

// Adds the HUD to the scene
-(void)createHUD {
    
    CGRect colorRect = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMidY(self.frame) - (self.frame.size.width - 50)/2, self.frame.size.width, self.frame.size.width - 25);
    
    hud = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(CGRectGetMaxX(colorRect), CGRectGetMaxX(colorRect))];
    hud.position = CGPointMake(CGRectGetMidX(colorRect), CGRectGetMidY(colorRect));
    [self addChild:hud];
    
    // score
    [GameState sharedInstance].Score=0;
    self.ScoreNode = [[SKLabelNode alloc] init];
    self.ScoreNode = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    self.ScoreNode.position = CGPointMake(0, (CGRectGetMinY(colorRect) - CGRectGetMaxY(colorRect))/9);
    self.ScoreNode.fontSize=hud.size.height/4;
    self.ScoreNode.text=@"0";
    self.ScoreNode.fontColor = [UIColor colorWithRed:0.51 green:0.51 blue:0.51 alpha:1];
    [hud addChild:self.ScoreNode];
    
    /*
    self.versionNum = [[SKLabelNode alloc] init];
    self.versionNum = [SKLabelNode labelNodeWithFontNamed:@"Avenir Bold"];
    self.versionNum.position = CGPointMake((CGRectGetMaxX(colorRect) - self.size.width)/2, colorRect.origin.y + 50);
    self.versionNum.fontSize=hud.size.height/20;
    self.versionNum.text=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionNum.fontColor = [UIColor blackColor];
    [hud addChild:self.versionNum];
    */
    
}

@end