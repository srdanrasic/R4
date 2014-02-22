//
//  R4Node_.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4Node () {
  NSMutableArray *_children;
  NSMutableArray *_actions;
  
  R4Box _accumulatedBoundingBox;
  
@public
  CGFloat _distanceToCamera;
  GLKMatrix4 _modelMatrix;
  GLKMatrix4 _invModelMatrix;
  GLKVector3 _positionWorldSpace;
  
  BOOL _transformsDirty;
}

@property (nonatomic, readwrite) R4Scene *scene;
@property (nonatomic, readwrite) R4Node *parent;
@property (nonatomic, readwrite) NSArray *children;
@property (nonatomic, readwrite) NSArray *actions;

@property (nonatomic, readonly) GLKMatrix4 modelMatrix;
@property (nonatomic, readonly) GLKMatrix4 invModelMatrix;

@property (nonatomic, readonly) GLKVector3 positionWorldSpace;

- (void)updateNodeAtTime:(NSTimeInterval)time;

- (R4Node *)hitTest:(R4Ray)ray event:(UIEvent *)event;

@end
