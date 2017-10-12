//
//  SpinningView.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "SpinningView.h"
#import "Utilities.h"
#import "Styles.h"

@implementation SpinningView
- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSLog(@"Setup Started");
    _circleLayer = [[CAShapeLayer alloc] init];
    _circleLayer.lineWidth = 8;
    _circleLayer.fillColor = nil;
    _circleLayer.strokeColor = [Styles getMainCGColor];
    [[self layer] addSublayer:_circleLayer];
    NSLog(@"Setup Finished");
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if(flag){
        [self startAnimation];
    }
}

-(void)startAnimation{
    CABasicAnimation * inAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [inAnimation setFromValue: [NSNumber numberWithFloat:0.0]];
    [inAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    [inAnimation setDuration:2.0];
    [inAnimation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn]];
    
    CABasicAnimation * outAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    [outAnimation setBeginTime:1.0];
    [outAnimation setFromValue: [NSNumber numberWithFloat:0.0]];
    [outAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    [outAnimation setDuration:2.0];
    [outAnimation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut]];
    
    [_circleLayer removeAnimationForKey:@"strokeAnimation"];
    CAAnimationGroup * strokeAnimationGroup = [CAAnimationGroup animation];
    [strokeAnimationGroup setDuration:2.0 + [outAnimation beginTime] ];
    [strokeAnimationGroup setRepeatCount:MAXFLOAT];
    [strokeAnimationGroup setAnimations: [[NSArray alloc] initWithObjects:inAnimation, outAnimation, nil]];
    [_circleLayer addAnimation:strokeAnimationGroup forKey:@"strokeAnimation"];
    [strokeAnimationGroup setDelegate:self];
    NSLog(@"startAnimationCalled");
}

-(void)endAnimation{
    [_circleLayer removeAllAnimations];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    // Code to Build Basic Circle
    CGFloat yPoint = [self frame].size.height * 0.75;
    CGPoint bottomPoint = CGPointMake([self center].x, yPoint );
    CGFloat radius = 75.0 / 2 - _circleLayer.lineWidth /2;
    CGFloat startAngle = M_PI_2;
    CGFloat endAngle = startAngle + (M_PI * 2);
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [_circleLayer setPosition:bottomPoint];
    [_circleLayer setPath:[path CGPath]];
    [self startAnimation];
    CABasicAnimation * rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setFromValue: [NSNumber numberWithFloat: 0]];
    [rotationAnimation setToValue:[NSNumber numberWithFloat: 2 * M_PI]];
    [rotationAnimation setDuration:4.0];
    [rotationAnimation setRepeatCount:MAXFLOAT];
    [_circleLayer addAnimation: rotationAnimation forKey:@"rotateAnimation"];
    NSLog(@"Sub View Layed Out and animation should have started");
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}
@end
