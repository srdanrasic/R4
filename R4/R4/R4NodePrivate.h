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
  BOOL _dirty;
  BOOL _visited;
  
@public
  CGFloat _distanceToCamera;
}

@property (nonatomic, readwrite) R4Scene *scene;
@property (nonatomic, readwrite) R4Node *parent;
@property (nonatomic, readwrite) NSArray *children;
@property (nonatomic, readwrite) NSArray *actions;

@property (nonatomic) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign, readonly) GLKVector3 wsPosition;

- (void)willTraverse;
- (void)didTraverse;

- (void)updateActionsAtTime:(NSTimeInterval)time;

- (R4Node *)hitTest:(R4Ray)ray event:(UIEvent *)event;

@end
