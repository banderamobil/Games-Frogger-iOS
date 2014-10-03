//
//  Frogger
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Globals.h"
#import "LaneNode.h"
#import "Playground.h"
#import "RoadNode.h"
#import "VehicleNode.h"

#define LaneWidth 50.0f

@interface LaneNode ()

@property (nonatomic, assign, readwrite) TrafficDirection  trafficDirection;
@property (nonatomic, assign, readwrite) CGFloat           speedFrom;
@property (nonatomic, assign, readwrite) CGFloat           speedTo;
@property (nonatomic, assign, readwrite) CGFloat           intervalFrom;
@property (nonatomic, assign, readwrite) CGFloat           intervalTo;

@property (nonatomic, strong)            NSTimer           *trafficTimer;

@end

@implementation LaneNode

@synthesize trafficDirection  = _trafficDirection;

- (id)initWithAttributes:(NSDictionary *)attributes
              playground:(SKSpriteNode *)playground
{
    CGFloat playgroundWidth = CGRectGetWidth(playground.frame);

    self = [super init];
    if (self == nil)
        return nil;

    self.trafficTimer = nil;

    [self parseAttributes:attributes];

    [self setName:@"laneNode"];
    [self setZPosition:NodeZLane];

    CGSize size = CGSizeMake(playgroundWidth, LaneWidth);

    [self setSize:size];

    [self setPhysicsBody:[self preparePhysicsBody:size]];

    return self;
}

- (void)parseAttributes:(NSDictionary *)attributes
{
    NSString *attrTrafficDirection = [attributes objectForKey:@"TrafficDirection"];
    NSString *attrSpeed = [attributes objectForKey:@"Speed"];
    NSString *attrInterval = [attributes objectForKey:@"Interval"];
    NSScanner *scanner;
    NSArray *parts;

    if ([attrTrafficDirection isEqualToString:@"LeftToRight"]) {
        self.trafficDirection = TrafficDirectionLeftToRight;
    } else if ([attrTrafficDirection isEqualToString:@"RightToLeft"]) {
        self.trafficDirection = TrafficDirectionRightToLeft;
    } else {
        // Error
    }

    parts = [attrSpeed componentsSeparatedByString:@"-"];
    if ([parts count] != 2) {
        // Error
    }

    float speedFrom;
    float speedTo;

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
    [scanner scanFloat:&speedFrom];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
    [scanner scanFloat:&speedTo];

    self.speedFrom = speedFrom;
    self.speedTo = speedTo;

    parts = [attrInterval componentsSeparatedByString:@"-"];
    if ([parts count] != 2) {
        // Error
    }

    float intervalFrom;
    float intervalTo;

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:0]];
    [scanner scanFloat:&intervalFrom];

    scanner = [NSScanner scannerWithString:[parts objectAtIndex:1]];
    [scanner scanFloat:&intervalTo];

    self.intervalFrom = intervalFrom;
    self.intervalTo = intervalTo;
}

- (SKPhysicsBody *)preparePhysicsBody:(CGSize)laneSize
{
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:laneSize];
    
    [physicsBody setUsesPreciseCollisionDetection:YES];

    [physicsBody setCategoryBitMask:NodeCategoryLane];
    [physicsBody setCollisionBitMask:0];
    [physicsBody setContactTestBitMask:0];

    [physicsBody setDynamic:YES];
    [physicsBody setFriction:0.0f];
    [physicsBody setRestitution:0.0f];
    [physicsBody setLinearDamping:0.0f];
    [physicsBody setAllowsRotation:NO];

    return physicsBody;
}

- (void)startTraffic
{
    self.trafficTimer =
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(scheduleVehicle)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)stopTraffic
{
    if (self.trafficTimer != nil) {
        [self.trafficTimer invalidate];
        self.trafficTimer = nil;
    }

    for (SKSpriteNode *node in [self children])
    {
        if ([node.name isEqualToString:@"vehicleNode"] == YES) {
            VehicleNode *vehicle = (VehicleNode *)node;
            [vehicle stopVehicle];
        }

        [node removeFromParent];
    }
}

- (void)scheduleVehicle
{
    CGFloat interval = randomBetween(self.intervalFrom, self.intervalTo);

    [self startVehicle];

    self.trafficTimer =
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(scheduleVehicle)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)startVehicle
{
    CGFloat         startPosition;
    CGFloat         lanePosition;
    VehicleType     vehicleType;
    DriveDirection  direction;
    CGFloat         speed;

    switch (self.trafficDirection)
    {
        case TrafficDirectionLeftToRight:
            direction = DriveDirectionLeftToRight;
            break;

        case TrafficDirectionRightToLeft:
            direction = DriveDirectionRightToLeft;
            break;
    }

    RoadNode *road = (RoadNode *)self.parent;
    switch ([road roadType ])
    {
        case RoadTypeCityStreet:
        {
            int randomNumber = (int)round(randomBetween(1, 10));
            if (randomNumber < 4)
                vehicleType = VehicleTypePKW;
            else
                vehicleType = VehicleTypeLKW;

            break;
        }

        case RoadTypeHighway:
        {
            int randomNumber = (int)round(randomBetween(1, 10));
            if (randomNumber < 7)
                vehicleType = VehicleTypePKW;
            else
                vehicleType = VehicleTypeLKW;

            break;
        }
    }

    speed = randomBetween(self.speedFrom, self.speedTo);

    VehicleNode *vehicle = [[VehicleNode alloc] initWithType:vehicleType
                                              driveDirection:direction
                                                drivingSpeed:speed];

    if (direction == DriveDirectionLeftToRight)
        startPosition = -CGRectGetWidth(self.frame) / 2 - vehicle.size.height / 2 + 1;
    else
        startPosition = CGRectGetWidth(self.frame) / 2 + vehicle.size.height / 2 - 1;

    CGFloat laneOffsetRange = (CGRectGetHeight(self.frame) - CGRectGetWidth(vehicle.frame)) / 2;
    lanePosition = randomBetween(-laneOffsetRange,
                                 laneOffsetRange);
    lanePosition = floor(lanePosition);

    [vehicle setPosition:CGPointMake(startPosition, lanePosition)];

    for (VehicleNode *otherVehicle in [self children])
        if (CGRectIntersectsRect(vehicle.frame, otherVehicle.frame) == YES)
            return;

    [self addChild:vehicle];

    [vehicle startVehicle];
}

@end
