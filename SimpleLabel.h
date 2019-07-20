//
//  SimpleLabel.h
//  GP
//


#import <SpriteKit/SpriteKit.h>

#import "GlobalSettings.h"

@interface SimpleLabel : SKLabelNode

- (id)initWithText:(NSString *)text fontSize:(int)fontSize position:(CGPoint)position colorByHEX:(NSString *)color andZPosition:(int)zPosition;

@end
