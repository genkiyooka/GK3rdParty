//
//  RoundedBox.m
//  RoundedBox
// Refactored for ARC and ObjC 2.1 by GK
//
//  Created by Matt Gemmell on 01/11/2005.
//  Copyright 2006 Matt Gemmell. http://mattgemmell.com/
//
//  Permission to use this code:
//
//  Feel free to use this code in your software, either as-is or 
//  in a modified form. Either way, please include a credit in 
//  your software's "About" box or similar, mentioning at least 
//  my name (Matt Gemmell). A link to my site would be nice too.
//
//  Permission to redistribute this code:
//
//  You can redistribute this code, as long as you keep these 
//  comments. You can also redistribute modified versions of the 
//  code, as long as you add comments to say that you've made 
//  modifications (keeping these original comments too).
//
//  If you do use or redistribute this code, an email would be 
//  appreciated, just to let me know that people are finding my 
//  code useful. You can reach me at matt.gemmell@gmail.com
//
#if !TARGET_OS_IPHONE

#import "RequiredAppKit.h"

@interface GKRoundedBox : NSBox

ARC_BEGIN_IVAR_DECL(GKRoundedBox)
ARC_IVAR_DECLAREAUTO(NSColor*,borderColor);
ARC_IVAR_DECLAREAUTO(NSColor*,titleColor);
ARC_IVAR_DECLAREAUTO(NSColor*,backgroundColor);
ARC_IVAR_DECLAREALWAYS(CGFloat,borderWidth);
ARC_IVAR_DECLAREALWAYS(CGFloat,cornerRadius);
ARC_IVAR_DECLAREALWAYS(CGFloat,titleInset);
ARC_IVAR_DECLAREALWAYS(CGFloat,titleWidthMultiplier);
ARC_IVAR_DECLAREALWAYS(CGFloat,titleExpansionThreshold);
ARC_IVAR_DECLAREALWAYS(BOOL,drawsFullTitleBar);
ARC_IVAR_DECLAREALWAYS(BOOL,selected);
ARC_IVAR_DECLAREALWAYS(BOOL,drawsTitle);
ARC_IVAR_DECLAREALWAYS(BOOL,allowsTitleEditingWithMouseClick);
ARC_IVAR_DECLAREALWAYS(NSRect,titlePathRect);
ARC_END_IVAR_DECL(GKRoundedBox)

- (void)setDefaults;
- (NSBezierPath *)titlePathWithinRect:(NSRect)rect cornerRadius:(float)radius titleRect:(NSRect)titleRect;

@property (assign,nonatomic) BOOL allowsTitleEditingWithMouseClick;
@property (assign,nonatomic) BOOL drawsFullTitleBar;
@property (assign,nonatomic) BOOL selected;
@property (assign,nonatomic) CGFloat borderWidth;
@property (assign,nonatomic) CGFloat cornerRadius;

@property (ARC_PROP_STRONG) NSColor* borderColor;
@property (ARC_PROP_STRONG) NSColor* titleColor;
@property (ARC_PROP_STRONG) NSColor* backgroundColor;

@end

#endif /* !TARGET_OS_IPHONE */