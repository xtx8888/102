//
//  SimpleLabel.m
//  GP
//


#import "SimpleLabel.h"

@implementation SimpleLabel

- (id)initWithText:(NSString *)text fontSize:(int)fontSize position:(CGPoint)position colorByHEX:(NSString *)color andZPosition:(int)zPosition {
    if (self = [super init]) {
        self = [SimpleLabel labelNodeWithFontNamed:FONT_NAME];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) self.fontSize = fontSize * 2;
        else self.fontSize = fontSize;
        self.position = position;
        self.fontColor = [self getColorFromHexString:color];
        self.text = text;
        self.zPosition = zPosition;
    }
    return self;
}

- (UIColor *)getColorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
