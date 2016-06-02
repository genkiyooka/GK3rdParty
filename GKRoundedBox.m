// Refactored for ARC and ObjC 2.1 by GK
//
//  RoundedBox
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

#import "GKRoundedBox.h"
#import "NSDictionary+NSAttributedString.h"
#if __GKROUNDEDBOX_CONFIG_USE_GRADIENTS
#import "CTGradient.h"
#endif

@interface GKRoundedBox()
@property (assign,nonatomic) BOOL drawsTitle;
@property (assign,nonatomic) NSRect titlePathRect;
@end

@implementation GKRoundedBox

ARC_SYNTHESIZEAUTO(selected);
ARC_SYNTHESIZEAUTO(borderWidth);
ARC_SYNTHESIZEAUTO(cornerRadius);
ARC_SYNTHESIZEAUTO(drawsTitle);
ARC_SYNTHESIZEAUTO(allowsTitleEditingWithMouseClick);
ARC_SYNTHESIZEAUTO(drawsFullTitleBar);
ARC_SYNTHESIZEAUTO(titleColor);
ARC_SYNTHESIZEAUTO(titlePathRect);
ARC_SYNTHESIZEAUTO(borderColor);
ARC_SYNTHESIZEAUTO(backgroundColor);

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])!=nil) {
        [self setDefaults];
		}
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder {
	/* better way to handle nib case */
    if ((self = [super initWithCoder:coder])!=nil) {
        [self setDefaults];
		}
    return self;
}

- (void)dealloc
{
	ARC_DEALLOC_NIL(self.borderColor);
	ARC_DEALLOC_NIL(self.titleColor);
	ARC_DEALLOC_NIL(self.backgroundColor);
	ARC_SUPERDEALLOC(self);
}


- (void)setDefaults
{
	_allowsTitleEditingWithMouseClick = NO;
    _drawsTitle = YES;
    [self.titleCell setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.titleCell setEditable:YES];
    
	_titleInset = 3.0;
    _borderWidth = 0.5;
	_cornerRadius = 5.0;
	_titleWidthMultiplier = 1.25;
	_titleExpansionThreshold = 20.0;
    [self setBorderColor:[NSColor colorWithCalibratedWhite:0.70 alpha:0.75]];
    [self setTitleColor:[NSColor whiteColor]];
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.85 alpha:0.75]];
    [self setTitleFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
    
    self.drawsFullTitleBar=NO;
	self.selected = NO;
}


- (BOOL)preservesContentDuringLiveResize
{
    // NSBox returns YES for this, but doing so would screw up the gradients.
    return NO;
}

- (void)mouseDown:(NSEvent *)event {
	if (self.allowsTitleEditingWithMouseClick) {
	NSPoint mouseDown = [self convertPoint:event.locationInWindow fromView:nil];
		if (NSPointInRect(mouseDown,_titlePathRect)) {
			self.drawsTitle = NO;
			[self setNeedsDisplay:YES];
		NSRect editingRect = NSInsetRect([self.titleCell drawingRectForBounds:_titlePathRect],
										 _titleInset + self.borderWidth,
										 _titleInset);
			editingRect.size.width = [self frame].size.width - (2.0 * editingRect.origin.x);
			[self.titleCell editWithFrame:[self convertRect:editingRect toView:nil] 
									 inView:self.window.contentView 
									 editor:[self.window fieldEditor:YES forObject:self.titleCell] 
								   delegate:self 
									  event:event];
			}
		}
}

- (BOOL)textShouldBeginEditing:(NSText *)fieldEditor {
	return self.allowsTitleEditingWithMouseClick;
}

- (BOOL)textShouldEndEditing:(NSText *)fieldEditor {
	if (self.allowsTitleEditingWithMouseClick) {
		self.drawsTitle = YES;
		if (REQUIRED_DEBUG(fieldEditor.string.length>0))
			self.title = fieldEditor.string;
		}
    return YES;
}


- (void)textDidEndEditing:(NSNotification *)aNotification
{
	if (self.allowsTitleEditingWithMouseClick) {
		[self.titleCell endEditing:[self.window fieldEditor:YES forObject:self.titleCell]];
		}
}


- (void)resetCursorRects {
	if (self.allowsTitleEditingWithMouseClick) {
		[self addCursorRect:_titlePathRect cursor:[NSCursor IBeamCursor]];
		}
}


- (void)drawBorderPathAroundBox:(NSBezierPath*)borderPath {
    // Draw rounded rect around entire box
    if (_borderWidth > 0.0) {
        [borderPath setLineWidth:_borderWidth];
        [borderPath stroke];
    }
}

- (NSBezierPath*)borderPathWithinRect:(NSRect)borderRect {
NSInteger minX = NSMinX(borderRect);
NSInteger midX = NSMidX(borderRect);
NSInteger maxX = NSMaxX(borderRect);
NSInteger minY = NSMinY(borderRect);
NSInteger midY = NSMidY(borderRect);
NSInteger maxY = NSMaxY(borderRect);
NSBezierPath* borderPath = [NSBezierPath bezierPath];
    
    // Bottom edge and bottom-right curve
    [borderPath moveToPoint:NSMakePoint(midX, minY)];
    [borderPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:_cornerRadius];
    
    // Right edge and top-right curve
    [borderPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:_cornerRadius];
    
    // Top edge and top-left curve
    [borderPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:_cornerRadius];
    
    // Left edge and bottom-left curve
    [borderPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:_cornerRadius];
    [borderPath closePath];
	return borderPath;
}

- (NSBezierPath*)titlePathWithinRect:(NSRect)rect cornerRadius:(CGFloat)cornerRadius titleRect:(NSRect)titleRect
{
    // Construct rounded rect path    
NSRect bgRect = rect;
NSInteger minX = NSMinX(bgRect);
NSInteger maxX = minX + titleRect.size.width + ((titleRect.origin.x - rect.origin.x) * 2.0);
NSInteger maxY = NSMaxY(bgRect);
NSInteger minY = NSMinY(titleRect) - (maxY - (titleRect.origin.y + titleRect.size.height));
    // i.e. if there's less than 20px space to the right of the short titlebar, just draw the full one.
NSBezierPath* titlePath = [NSBezierPath bezierPath];
    
    [titlePath moveToPoint:NSMakePoint(minX, minY)];
    
    if (bgRect.size.width - titleRect.size.width >= _titleExpansionThreshold && !self.drawsFullTitleBar && self.drawsTitle) {
        // Draw a short titlebar
        [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                       toPoint:NSMakePoint(maxX, maxY) 
                                        radius:cornerRadius];
        [titlePath lineToPoint:NSMakePoint(maxX, maxY)];
    } else {
        // Draw full titlebar, since we're either set to always do so, or we don't have room for a short one.
        [titlePath lineToPoint:NSMakePoint(NSMaxX(bgRect), minY)];
        [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bgRect), maxY) 
                                       toPoint:NSMakePoint(NSMaxX(bgRect) - (bgRect.size.width / 2.0), maxY) 
                                        radius:cornerRadius];
    }
    
    [titlePath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                   toPoint:NSMakePoint(minX, minY) 
                                    radius:cornerRadius];
    
    [titlePath closePath];
    
    return titlePath;
}

- (void)drawBackgroundWithBorderPath:(NSBezierPath*)borderPath boxRect:(NSRect)boxRect borderRect:(NSRect)borderRect {
	// Draw solid color background
	[self.backgroundColor set];
	[borderPath fill];
}

- (void)drawTitleWithBorderPath:(NSBezierPath*)borderPath boxRect:(NSRect)boxRect borderRect:(NSRect)borderRect {
    // Create drawing rectangle for title
    
CGFloat titleHInset = _borderWidth + _titleInset + 1.0;
CGFloat titleVInset = _borderWidth;
NSDictionary* titleAttrs = [[self.titleCell attributedStringValue] attributesAtIndex:0 effectiveRange:NULL];
NSSize titleSize = [self.title sizeWithAttributes:titleAttrs];
	titleSize.width *= _titleWidthMultiplier;
NSRect titleRect = NSMakeRect(boxRect.origin.x + titleHInset, 
							  boxRect.origin.y + boxRect.size.height - titleSize.height - (titleVInset * 2.0), 
							  titleSize.width + (_borderWidth * 2.0),
							  titleSize.height);
    titleRect.size.width = MIN(titleRect.size.width, boxRect.size.width - (2.0 * titleHInset));
    
    if (self.selected) {
        [[NSColor alternateSelectedControlColor] set];
        // We use the alternate (darker) selectedControlColor since the regular one is too light.
        // The alternate one is the highlight color for NSTableView, NSOutlineView, etc.
        // This mimics how Automator highlights the selected action in a workflow.
    } else {
        [self.borderColor set];
    }
    
    // Draw title background
NSBezierPath* titlePath = [self titlePathWithinRect:borderRect cornerRadius:_cornerRadius titleRect:titleRect];
    [titlePath fill];
    self.titlePathRect = titlePath.bounds;

	[self drawBorderPathAroundBox:borderPath];
    
    // Draw title text using the titleCell
    if (_drawsTitle) {
		[self.titleCell setTextColor:self.titleColor];
        [self.titleCell drawInteriorWithFrame:titleRect inView:self];
    }
}

- (void)drawRect:(NSRect)rect {
NSRect bounds = self.bounds;

	/* make the boxRect consistent with the boxRect used by NSBox so you can easily switch back and forth */
NSRect boxRect = NSInsetRect(bounds,4.0,4.0);
	boxRect.origin.x += 1.0;
	boxRect.origin.y += 2.0;
	
    // Construct rounded rect path
NSRect borderRect = boxRect;
    borderRect = NSIntegralRect(NSInsetRect(boxRect, _borderWidth / 2.0, _borderWidth / 2.0));
    borderRect.origin.x += 0.5;
    borderRect.origin.y += 0.5;

NSBezierPath* borderPath = [self borderPathWithinRect:borderRect];
	[self drawBackgroundWithBorderPath:borderPath boxRect:boxRect borderRect:borderRect];
	[self drawTitleWithBorderPath:borderPath boxRect:boxRect borderRect:borderRect];
}


- (void)setTitle:(NSString*)newTitle
{
    [super setTitle:newTitle];
    [self.window invalidateCursorRectsForView:self];
    [self setNeedsDisplay:YES];
}

- (void)setDrawsFullTitleBar:(BOOL)drawsFullTitleBar
{
    _drawsFullTitleBar = drawsFullTitleBar;
    [self.window invalidateCursorRectsForView:self];
    [self setNeedsDisplay:YES];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay:YES];
}

@end

#endif /* !TARGET_OS_IPHONE */