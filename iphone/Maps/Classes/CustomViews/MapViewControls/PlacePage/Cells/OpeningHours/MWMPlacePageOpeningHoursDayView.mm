#import "MWMPlacePageOpeningHoursDayView.h"
#import "UIColor+MapsMeColor.h"
#import "UIFont+MapsMeFonts.h"

@interface MWMPlacePageOpeningHoursDayView ()

@property (weak, nonatomic) IBOutlet UILabel * label;
@property (weak, nonatomic) IBOutlet UILabel * openTime;
@property (weak, nonatomic) IBOutlet UILabel * compatibilityLabel;

@property (weak, nonatomic) IBOutlet UILabel * breakLabel;
@property (weak, nonatomic) IBOutlet UIView * breaksHolder;

@property (weak, nonatomic) IBOutlet UILabel * closedLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * labelTopSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * labelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * breakLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * breaksHolderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * openTimeLabelLeadingOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * labelOpenTimeLabelSpacing;

@end

@implementation MWMPlacePageOpeningHoursDayView

- (void)setLabelText:(NSString *)text isRed:(BOOL)isRed
{
  UILabel * label = self.label;
  label.text = text;
  if (isRed)
    label.textColor = [UIColor red];
  else if (self.currentDay)
    label.textColor = [UIColor blackPrimaryText];
  else
    label.textColor = [UIColor blackSecondaryText];
}

- (void)setOpenTimeText:(NSString *)text
{
  self.openTime.hidden = (text.length == 0);
  self.openTime.text = text;
}

- (void)setBreaks:(NSArray<NSString *> *)breaks
{
  NSUInteger const breaksCount = breaks.count;
  BOOL const haveBreaks = breaksCount != 0;
  [self.breaksHolder.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  if (haveBreaks)
  {
    CGFloat const breakSpacerHeight = 4.0;
    self.breakLabel.hidden = NO;
    self.breaksHolder.hidden = NO;
    CGFloat labelY = 0.0;
    for (NSString * br in breaks)
    {
      UILabel * label = [[UILabel alloc] initWithFrame:{{0, labelY},{}}];
      label.text = br;
      label.font = self.currentDay ? [UIFont regular14] : [UIFont light12];
      label.textColor = [UIColor blackSecondaryText];
      [label sizeToIntegralFit];
      [self.breaksHolder addSubview:label];
      labelY += label.height + breakSpacerHeight;
    }
    self.breaksHolderHeight.constant = ceil(labelY - breakSpacerHeight);
  }
  else
  {
    self.breakLabel.hidden = YES;
    self.breaksHolder.hidden = YES;
    self.breaksHolderHeight.constant = 0.0;
  }
}

- (void)setClosed:(BOOL)closed
{
  self.closedLabel.hidden = !closed;
}

- (void)setCompatibilityText:(NSString *)text isPlaceholder:(BOOL)isPlaceholder
{
  self.compatibilityLabel.text = text;
  self.compatibilityLabel.textColor = isPlaceholder ? [UIColor blackSecondaryText] : [UIColor blackPrimaryText];
}

- (void)invalidate
{
  CGFloat viewHeight;
  if (self.isCompatibility)
  {
    [self.compatibilityLabel sizeToIntegralFit];
    CGFloat const compatibilityLabelVerticalOffsets = 24.0;
    viewHeight = self.compatibilityLabel.height + compatibilityLabelVerticalOffsets;
  }
  else
  {
    UILabel * label = self.label;
    UILabel * openTime = self.openTime;
    CGFloat const labelOpenTimeLabelSpacing = self.labelOpenTimeLabelSpacing.constant;
    [label sizeToIntegralFit];
    self.labelWidth.constant = MIN(label.width, openTime.minX - label.minX - labelOpenTimeLabelSpacing);

    [self.breakLabel sizeToIntegralFit];
    self.breakLabelWidth.constant = self.breakLabel.width;

    CGFloat const verticalSuperviewSpacing = self.labelTopSpacing.constant;
    CGFloat const minHeight = label.height + 2 * verticalSuperviewSpacing;
    CGFloat const breaksHolderHeight = self.breaksHolderHeight.constant;
    CGFloat const additionalHeight = (breaksHolderHeight > 0 ? 4.0 : 0.0);
    viewHeight = minHeight + breaksHolderHeight + additionalHeight;

    if (self.closedLabel && !self.closedLabel.hidden)
    {
      CGFloat const heightForClosedLabel = 20.0;
      viewHeight += heightForClosedLabel;
    }
  }

  self.viewHeight = ceil(viewHeight);

  [self setNeedsLayout];
  [self layoutIfNeeded];
}

#pragma mark - Properties

- (void)setViewHeight:(CGFloat)viewHeight
{
  _viewHeight = viewHeight;
  if (self.currentDay)
  {
    self.height.constant = viewHeight;
  }
  else
  {
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
  }
}

- (void)setIsCompatibility:(BOOL)isCompatibility
{
  _isCompatibility = isCompatibility;
  self.compatibilityLabel.hidden = !isCompatibility;
  self.label.hidden = isCompatibility;
  self.openTime.hidden = isCompatibility;
  self.breakLabel.hidden = isCompatibility;
  self.breaksHolder.hidden = isCompatibility;
  self.closedLabel.hidden = isCompatibility;
}

- (CGFloat)openTimeLeadingOffset
{
  return self.openTime.minX;
}

- (void)setOpenTimeLeadingOffset:(CGFloat)openTimeLeadingOffset
{
  self.openTimeLabelLeadingOffset.constant = openTimeLeadingOffset;
}

@end
