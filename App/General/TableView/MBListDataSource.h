/*!
    MBListDataSource
    v 1.0

    Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
    https://github.com/Chinamobo/iOS-Project-Template

    Apache License, Version 2.0
    http://www.apache.org/licenses/LICENSE-2.0
 */
#import "RFDelegateChain.h"

/**
 单 section 的列表 dataSource
 */
@interface MBListDataSource : RFDelegateChain

/**
 清空数据、重置状态，以便作为另一个列表的 dataSource 使用
 
 不会重设配置量
*/
- (void)prepareForReuse;

#pragma mark - Items

@property (strong, nonatomic) NSMutableArray *items;

/// 列表为空
@property (assign, nonatomic) BOOL empty;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(id)item;

/**
 使用这个方法会自动处理条目
 */
//- (void)insertObjects:(NSArray *)objects atBegin:(BOOL)atBegin;

/**
 使用这个方法会自动处理条目
 */
//- (void)replaceItems:(NSArray *)items;

#pragma mark - 分页

typedef NS_ENUM(short, MBDataSourcePageStyle) {
    /// 默认，把当前页数作为游标，从 1 开始计算
    MBDataSourceDefaultPageStyle = 0,

    /// 把上一页最后的 item 的 ID 作为分页游标
    MBDataSourceMAXIDPageStyle,
};

/**
 使用的分页模式，默认 MBDataSourceDefaultPageStyle
 */
@property (assign, nonatomic) MBDataSourcePageStyle pageStyle;

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSUInteger pageSize;

@property (strong, nonatomic) id maxID;

/// maxID 的获取是通过在最后一个 item 上执行 valueForKeyPath: 获取的
@property (strong, nonatomic) NSString *maxIDKeypath;

/// 默认 page
@property (strong, nonatomic) NSString *pageParameterName;

/// 默认 page_size
@property (strong, nonatomic) NSString *pageSizeParameterName;

/// 默认 MAX_ID
@property (strong, nonatomic) NSString *maxIDParameterName;

/// 页面到底了
@property (assign, nonatomic) BOOL pageEnd;

/**
 判断页面到底的策略
 */
typedef NS_ENUM(short, MBDataSourcePageEndDetectPolicy) {
    /// 默认，只有返回为空时才算到底
    MBDataSourcePageEndDetectPolicyEmpty = 0,

    /// 获取数量少于 page_size 就算到底
    MBDataSourcePageEndDetectPolicyStrict
};
@property (assign, nonatomic) MBDataSourcePageEndDetectPolicy pageEndDetectPolicy;

#pragma mark - 条目获取
/// 是否正在获取数据
@property (readonly) BOOL fetching;
@property (assign, nonatomic) BOOL hasSuccessFetched;
@property (copy, nonatomic) IBInspectable NSString *fetchAPIName;

/// 当改属性是 NSMutableDictionary 或空时会附加分页参数
@property (strong, nonatomic) NSDictionary *fetchParameters;

/**
 加载数据
 
 @param nextPage
 @param success fetchedItems 是处理后的最终数据
 */
- (void)fetchItemsFromViewController:(id)viewController nextPage:(BOOL)nextPage success:(void (^)(MBListDataSource *dateSource, NSArray *fetchedItems))success completion:(void (^)(MBListDataSource *dateSource))completion;

#pragma mark - 条目处理

/**
 对网络请求返回的数据进行第一次处理，典型情形如手工去重、模型转换
 
 @param oldItems 数据源中目前存在对象的拷贝，如果是刷新获取会是 nil，获取下一页时一定是个数组
 @param newItems 请求返回的对象，有可能不是数组，这种情况有必要处理

 返回处理好的数组，之后会交由 data source 进行其他处理
 */
@property (copy, nonatomic) NSArray *(^processItems)(__unused NSArray *oldItems, NSArray *newItems);

/**
 当新获取对象在数组中已存在如何操作
 */
typedef NS_ENUM(short, MBDataSourceDistinctRule) {
    MBDataSourceDistinctRuleDefault = 0,

    /// 忽略掉新对象
    MBDataSourceDistinctRuleIgnore,

    /// 用新对象替换掉旧的，不改变已有对象顺序
    MBDataSourceDistinctRuleUpdate,

    /// 用新对象替换掉旧的，对象被移动到后面
    MBDataSourceDistinctRuleReplace,
};

/**
 重复条目处理方式
 */
@property (assign, nonatomic) MBDataSourceDistinctRule distinctRule;

/**
 最后的条目处理机会，典型情形显示前将数据 model 转换为显示 model
 */
//@property (copy, nonatomic) NSArray *(^finalizeItems)(__unused NSArray *oldItems, NSArray *newItems);
@end
