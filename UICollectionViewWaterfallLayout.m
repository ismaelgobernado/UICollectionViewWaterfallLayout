//
//  UICollectionViewWaterfallLayout.m
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//

#import "UICollectionViewWaterfallLayout.h"

@interface UICollectionViewWaterfallLayout()
@property (nonatomic, assign) NSInteger itemCount;

@property (nonatomic, assign) CGFloat interItemHorizontalSpacing;
@property (nonatomic, assign) CGFloat interItemVerticalSpacing;

@property (nonatomic, strong) NSMutableArray *columnHeights; // height for each column
@property (nonatomic, strong) NSMutableArray *itemAttributes; // attributes for each item
@property (nonatomic, strong) UICollectionViewLayoutAttributes *footerAttributes;
@end

@implementation UICollectionViewWaterfallLayout

#pragma mark - Accessors

- (void)setColumnCount:(NSUInteger)columnCount
{
    if (_columnCount != columnCount) {
        _columnCount = columnCount;
        [self invalidateLayout];
    }
}

- (void)setItemWidth:(CGFloat)itemWidth
{
    if (_itemWidth != itemWidth) {
        _itemWidth = itemWidth;
        [self invalidateLayout];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        [self invalidateLayout];
    }
}

- (void)setItemMargins:(UIOffset)itemMargins
{
    if (!UIOffsetEqualToOffset(_itemMargins, itemMargins)) {
        _itemMargins = itemMargins;
        [self invalidateLayout];
    }
}

#pragma mark - Init

- (void)commonInit
{
    _columnCount = 2;
    _itemWidth = 140.0f;
    _contentInset = UIEdgeInsetsZero;
    _itemMargins = UIOffsetZero;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Life cycle

- (void)dealloc
{
    [_columnHeights removeAllObjects];
    _columnHeights = nil;

    [_itemAttributes removeAllObjects];
    _itemAttributes = nil;

    _footerAttributes = nil;
}

#pragma mark - Methods to Override

- (void)prepareLayout
{
    [super prepareLayout];
    
    if ([self collectionView] && _delegate) {

        // We need to pre-load the heights and the widths from the collectionview
        // and our delegate in order to pass these through to setupLayoutWithWidth

        NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
        NSMutableArray *heights = [NSMutableArray arrayWithCapacity:itemCount];
        CGFloat width = self.collectionView.frame.size.width - _contentInset.left - _contentInset.right;

        // Ask delegates for all the heights
        for (int i = 0; i < itemCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            CGFloat height = [self.delegate collectionView:self.collectionView
                                   layout:self
                                  heightForItemAtIndexPath:indexPath];
            [heights addObject:@(height)];
        }

        [self setupLayoutWithWidth:width andHeights:heights];
    }
}

- (CGFloat)longestColumnHeightForHeights:(NSArray *)heights withWidth:(CGFloat)width {
    [self setupLayoutWithWidth:width andHeights:heights];
    return [_columnHeights[[self longestColumnIndex]] floatValue];
}

- (void)setupLayoutWithWidth:(CGFloat)width andHeights:(NSArray *)array {
    NSAssert(_columnCount > 1, @"columnCount for UICollectionViewWaterfallLayout should be greater than 1.");

    CGFloat maximumMargin = floorf((width - _columnCount * _itemWidth) / (_columnCount - 1));
    _itemCount = array.count;
    
    if (UIOffsetEqualToOffset(_itemMargins, UIOffsetZero)) {

        // Generate the margins by using up all available space
        _interItemHorizontalSpacing = maximumMargin;
        _interItemVerticalSpacing = maximumMargin;
    } else {

        // Base margins off the itemMargins iVar and then center
        _interItemHorizontalSpacing = MIN(_itemMargins.horizontal, maximumMargin);
        _interItemVerticalSpacing = MIN(_itemMargins.vertical, maximumMargin);
    }

    // If the interItem horizontal spacing is less than the max, center the items
    CGFloat centeringOffset = ((maximumMargin - _interItemHorizontalSpacing) / 2) * _columnCount;

    _itemAttributes = [NSMutableArray arrayWithCapacity:_itemCount];
    _columnHeights = [NSMutableArray arrayWithCapacity:_columnCount];

    // Start all the columns with the content inset
    for (NSInteger idx = 0; idx < _columnCount; idx++) {
        [_columnHeights addObject:@(_contentInset.top)];
    }

    // Item will be put into shortest column.
    for (NSInteger idx = 0; idx < _itemCount; idx++) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        CGFloat itemHeight = [array[idx] floatValue];

        NSUInteger columnIndex = [self shortestColumnIndex];
        CGFloat xOffset = _contentInset.left + centeringOffset + (_itemWidth + _interItemHorizontalSpacing) * columnIndex;
        CGFloat yOffset = [(_columnHeights[columnIndex]) floatValue];
        CGPoint itemCenter = CGPointMake(floorf(xOffset + _itemWidth/2), floorf((yOffset + itemHeight/2)));

        UICollectionViewLayoutAttributes *attributes =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = CGSizeMake(self.itemWidth, itemHeight);
        attributes.center = itemCenter;
        [_itemAttributes addObject:attributes];

        _columnHeights[columnIndex] = @(yOffset + itemHeight + _interItemVerticalSpacing);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:heightForFooterWithLayout:)]) {
        NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);
        
        NSIndexPath *zeroIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        CGFloat yOffset = [_columnHeights[[self longestColumnIndex]] floatValue];
        CGFloat height = [_delegate collectionView:self.collectionView heightForFooterWithLayout:self];
        if (height > 0) {
            _footerAttributes =  [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:UICollectionElementKindSectionFooter withIndexPath:zeroIndexPath];
            _footerAttributes.frame = CGRectMake(0, yOffset + _interItemHorizontalSpacing, width, height);
        }
    }
}

- (CGSize)collectionViewContentSize
{
    if (self.itemCount == 0) {
        return CGSizeZero;
    }

    CGSize contentSize = self.collectionView.frame.size;
    NSUInteger columnIndex = [self longestColumnIndex];
    CGFloat height = [_columnHeights[columnIndex] floatValue];
    contentSize.height = height - _interItemHorizontalSpacing + _contentInset.bottom;
    if (_footerAttributes) {
        contentSize.height += CGRectGetHeight(_footerAttributes.frame) + _interItemHorizontalSpacing;
    }
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([decorationViewKind isEqualToString:UICollectionElementKindSectionFooter]) {
        // ignore indexPath
        return _footerAttributes;
    }
    return nil;
}


- ( UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return _itemAttributes[path.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *allAttributes = [self.itemAttributes arrayByAddingObject:self.footerAttributes];
    return [allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

#pragma mark - Private Methods
// Find out shortest column.
- (NSUInteger)shortestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;

    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];

    return index;
}

// Find out longest column.
- (NSUInteger)longestColumnIndex
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;

    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];

    return index;
}

@end
