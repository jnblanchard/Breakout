//
//  ViewController.m
//  Breakout
//
//  Created by John Blanchard on 7/31/14.
//  Copyright (c) 2014 John Blanchard. All rights reserved.
//

#import "ViewController.h"
#import "PaddleView.h"
#import "BallView.h"
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet PaddleView *paddleView;
@property (weak, nonatomic) IBOutlet BallView *ballView;
@property UIDynamicAnimator* dyAnimator;
@property UIPushBehavior* pushBehavior;
@property UICollisionBehavior* collisionBehavior;
@property UIDynamicItemBehavior* ballBehavior;
@property UIDynamicItemBehavior* paddleBehavior;
@property (weak, nonatomic) IBOutlet UIImageView *lifeImageView;
@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property int numLives;
@property BOOL gameStarted;
@property NSMutableArray* blockArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.blockArray = [[NSMutableArray alloc]init];

    self.lifeImageView.image = [UIImage imageNamed:@"threelives"];
    self.numLives = 3;
    self.gameStarted = YES;


    [self pushBehaviorSetterDynamicAnimatorInstantiationAndCollisonBehaviorInstantiation];

    [self createBlockViewAddToCollisionBehaviorAndSetBehavior];

    [self.dyAnimator addBehavior:self.collisionBehavior];

    [self ballBehaviorSetter];
    [self paddleBehaviorSetter];
}

- (void) pushBehaviorSetterDynamicAnimatorInstantiationAndCollisonBehaviorInstantiation
{
    self.dyAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.ballView]  mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.pushDirection = CGVectorMake(0.1, 0.1);
    self.pushBehavior.active = NO;
    self.pushBehavior.magnitude = 0.5;
    [self.dyAnimator addBehavior:self.pushBehavior];
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballView, self.paddleView]];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
}



- (void) createBlockViewAddToCollisionBehaviorAndSetBehavior {
    for (int i = 1; i <= 15; i++) {
        int x = 0;
        int y = 0;
        if ( i == 1 || i == 2 || i == 3) {
            y = 37;
        }
        if ( i == 2 || i == 5 || i == 8 || i == 11 || i == 14) {
            x = 110;
        }
        if ( i == 3 || i == 6 || i == 9 || i == 12 || i == 15 ) {
            x = 220;
        }
        if ( i == 4 || i == 5 || i == 6) {
            y = 62;
        }
        if ( i == 7 || i == 8 || i == 9) {
            y = 87;
        }
        if ( i == 10 || i == 11 || i == 12) {
            y = 112;
        }
        if ( i == 13 || i == 14 || i == 15) {
            y = 137;
        }
        BlockView * block = [[BlockView alloc]initWithFrame:CGRectMake(x, y, 100, 17)];
        block.backgroundColor = [UIColor colorWithRed:(float)rand()/RAND_MAX green:(float)rand()/RAND_MAX blue:(float)rand()/RAND_MAX alpha:1.0f];
        //block.backgroundColor = [UIColor clearColor];
        [self.blockArray addObject:block];
        [self.collisionBehavior addItem:block];
        [self.view addSubview:block];
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 100, 17)];
//        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i" ,(rand()% (3 - 1 + 1) + 1)]]];
//        [self.view addSubview:imageView];
        block.behavior = [[UIDynamicItemBehavior alloc] initWithItems:@[block]];
        block.behavior.density = 1000000;
        block.behavior.allowsRotation = NO;
        [self.dyAnimator addBehavior:block.behavior];
    }
}

- (void) createBlocksMidGame
{
    for (BlockView* block in self.blockArray) {
        [self.collisionBehavior addItem:block];
        [self.view addSubview:block];
        [self.dyAnimator addBehavior:block.behavior];
    }
}

- (void) removeBlocksAndRestartLevel
{
    for (BlockView* block in self.blockArray) {
        [self.dyAnimator updateItemUsingCurrentState:block];
        [self.collisionBehavior removeItem:block];
        [self.dyAnimator removeBehavior:block.behavior];
        [block removeFromSuperview];
    }
    [self.blockArray removeAllObjects];
    [self createBlockViewAddToCollisionBehaviorAndSetBehavior];
}

- (void) ballBehaviorSetter
{
    self.ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.ballBehavior.allowsRotation = NO;
    self.ballBehavior.elasticity = 1.0;
    self.ballBehavior.friction = 0;
    self.ballBehavior.resistance = 0;
    [self.dyAnimator addBehavior:self.ballBehavior];
}

- (void) paddleBehaviorSetter
{
    self.paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView]];
    self.paddleBehavior.allowsRotation = NO;
    self.paddleBehavior.density = 1000000;
    [self.dyAnimator addBehavior:self.paddleBehavior];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    if ([item1 isKindOfClass:[BlockView class]] || [item2 isKindOfClass:[BlockView class]]) {
        BlockView * block;
        if ([item1 isKindOfClass:[BlockView class]] && [item2 isKindOfClass:[BallView class]]) {
            block = item1;
        }
        if ([item2 isKindOfClass:[BlockView class]] && [item1 isKindOfClass:[BallView class]]) {
            block = item2;
        }
        [self.dyAnimator updateItemUsingCurrentState:block];
        [self.collisionBehavior removeItem:block];
        [self.dyAnimator removeBehavior:block.behavior];
        [block removeFromSuperview];
        [self.blockArray removeObject:block];
    }
    if ( self.blockArray.count < 1 ) {
        self.ballView.center = CGPointMake(151, 223);
        self.paddleView.center = CGPointMake(115, 477);
        [self pushBehaviorSetterDynamicAnimatorInstantiationAndCollisonBehaviorInstantiation];
        [self.gameOverLabel setText:@"You Win! - Tap to Restart"];
        self.gameOverLabel.hidden = NO;
        self.gameStarted = YES;

        [self createBlockViewAddToCollisionBehaviorAndSetBehavior];

        [self.dyAnimator addBehavior:self.collisionBehavior];

        [self ballBehaviorSetter];
        [self paddleBehaviorSetter];

        [self.dyAnimator updateItemUsingCurrentState:self.paddleView];
        [self.dyAnimator updateItemUsingCurrentState:self.ballView];
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (p.y > 566 ) {
        self.numLives--;
        self.ballView.center = CGPointMake(151, 223);
        self.paddleView.center = CGPointMake(115, 477);
        [self pushBehaviorSetterDynamicAnimatorInstantiationAndCollisonBehaviorInstantiation];

        [self createBlocksMidGame];

        [self.dyAnimator addBehavior:self.collisionBehavior];

        [self ballBehaviorSetter];
        [self paddleBehaviorSetter];

        [self.dyAnimator updateItemUsingCurrentState:self.paddleView];
        [self.dyAnimator updateItemUsingCurrentState:self.ballView];
        for (BlockView* block in self.blockArray) {
            [self.dyAnimator updateItemUsingCurrentState:block];
        }
    }
    if (self.numLives == 2) {
        self.lifeImageView.image = [UIImage imageNamed:@"twolives"];
        self.gameStarted = YES;
    }
    if (self.numLives == 1) {
        self.lifeImageView.image = [UIImage imageNamed:@"onelife"];
        self.gameStarted = YES;
    }
    if (self.numLives < 1) {
        self.gameOverLabel.hidden = NO;
        [self.gameOverLabel setText:@"Game Over - Tap to Restart"];
        self.lifeImageView.image = [UIImage imageNamed:@"threelives"];
        self.numLives = 3;
        self.gameStarted = YES;

        self.ballView.center = CGPointMake(151, 223);
        self.paddleView.center = CGPointMake(115, 477);
        [self pushBehaviorSetterDynamicAnimatorInstantiationAndCollisonBehaviorInstantiation];

        [self removeBlocksAndRestartLevel];

        [self.dyAnimator addBehavior:self.collisionBehavior];

        [self ballBehaviorSetter];
        [self paddleBehaviorSetter];

        [self.dyAnimator updateItemUsingCurrentState:self.paddleView];
        [self.dyAnimator updateItemUsingCurrentState:self.ballView];
    }

}

- (IBAction)onTap:(UITapGestureRecognizer*)tapGestureRecognizer
{
    if (self.gameStarted == YES) {
        self.pushBehavior.active = YES;
        self.gameOverLabel.hidden = YES;
        self.gameStarted = NO;
    }
}


- (IBAction)dragPaddle:(UIPanGestureRecognizer*)panGestureRecognizer
{

    self.paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x, self.paddleView.center.y);
    [self.dyAnimator updateItemUsingCurrentState:self.paddleView];
}



@end
