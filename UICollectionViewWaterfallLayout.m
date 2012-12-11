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
}

#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];

    // This is ugly and hacky and urgh
    
    if ([self collectionView] && _delegate) {
        NSInteger itemCount = [[self collectionView] numberOfItemsInSection:0];
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemCount];

        for (int i = 0; i < itemCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            CGFloat height = [self.delegate collectionView:self.collectionView
                                   layout:self
                                  heightForItemAtIndexPath:indexPath];
            [items addObject:@(height)];
        }
        CGFloat width = self.collectionView.frame.size.width - _contentInset.left - _contentInset.right;

        [self setupLayoutWithCount:itemCount width:width andItems:items];
    }
}

- (void)setupLayoutWithCount:(CGFloat)itemCount width:(CGFloat)width andItems:(NSArray *)array {
    NSAssert(_columnCount > 1, @"columnCount for UICollectionViewWaterfallLayout should be greater than 1.");

    CGFloat maximumMargin = floorf((width - _columnCount * _itemWidth) / (_columnCount - 1));
    _itemCount = itemCount;
    
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

    _itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    _columnHeights = [NSMutableArray arrayWithCapacity:_columnCount];

    // Start all the columns with the content inset
    for (NSInteger idx = 0; idx < _columnCount; idx++) {
        [_columnHeights addObject:@(_contentInset.top)];
    }

    // Item will be put into shortest column.
    for (NSInteger idx = 0; idx < itemCount; idx++) {

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
    return contentSize;
}

- ( UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return _itemAttributes[path.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
//    // Currently, PSTCollectionView has issue with this.
//    // It can't display items correctly.
//    // But UICollectionView works perfectly.
    return [self.itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
//    return _itemAttributes;
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

- (CGFloat)longestColumnHeightForHeights:(NSArray *)heights withWidth:(CGFloat)width {
    [self setupLayoutWithCount:heights.count width:width andItems:heights];
    return [_columnHeights[[self longestColumnIndex]] floatValue];
}

@end
