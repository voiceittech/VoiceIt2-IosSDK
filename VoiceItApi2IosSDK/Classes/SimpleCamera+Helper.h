//
//  SimpleCamera+Helper.h
//  SimpleCameraExample
//
//  Created by Ömer Faruk Gül on 20/02/16.
//  Copyright © 2016 Ömer Faruk Gül. All rights reserved.
//

#import "SimpleCamera.h"

@interface SimpleCamera (Helper)

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;

- (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end
