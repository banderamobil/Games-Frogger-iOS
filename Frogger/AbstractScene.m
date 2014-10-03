//
//  Frogger
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "AbstractScene.h"
#import "Globals.h"

@implementation AbstractScene

- (void)makeBackground
{
    [self setBackgroundColor:[SKColor grayColor]];
    [self setScaleMode:SKSceneScaleModeAspectFill];

    UIImage *tileImage = [UIImage imageNamed:@"SceneTileBackground"];
    UIImage *logoImage = [UIImage imageNamed:@"SceneLogo"];

    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextDrawTiledImage(context,
                            (CGRect){ CGPointZero, tileImage.size },
                            [tileImage CGImage]);

    CGRect logoRect = CGRectMake(-(CGRectGetMidX(self.frame) - logoImage.size.width / 2),
                                 -(CGRectGetMidY(self.frame) - logoImage.size.height / 2),
                                 -logoImage.size.width,
                                 -logoImage.size.height);

    CGContextRotateCTM(context, degreesToRadians(180.0f));

    CGContextDrawImage(context,
                       logoRect,
                       [logoImage CGImage]);

    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    SKTexture *texture = [SKTexture textureWithImage:backgroundImage];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:texture];

    [self addChild:background];

    [background setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame))];

    NSString *labelText = @"G'Frogger";
    SKColor *labelColor = [SKColor colorWithRed:1.000f green:0.400f blue:0.400f alpha:0.8f];

    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];

    [labelNode setText:labelText];
    [labelNode setFontSize:48.0f];
    [labelNode setFontColor:labelColor];
    [labelNode setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetHeight(self.frame) * 0.82f)];

    [self addChild:labelNode];
}

- (void)makeLabel:(NSString *)text
{
    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Bradley Hand"];

    [labelNode setText:text];
    [labelNode setFontSize:28.0f];
    [labelNode setFontColor:[UIColor whiteColor]];
    [labelNode setPosition:CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetHeight(self.frame) * 0.2f)];

    [self addChild:labelNode];
}

@end
