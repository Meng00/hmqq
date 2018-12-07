//
//  LCUniverseSelector.h
//  lifeassistant
//
//  Created by wangyong on 13-7-29.
//
//

#import <UIKit/UIKit.h>

@protocol LCUniverseSelectorDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInTableView:(NSInteger)tableTag;
- (NSDictionary *)dictionaryForRow:(NSInteger)row withTag:(NSInteger)tag;

@optional
- (CGFloat)heightForRow:(NSInteger)tableTag;
@end

@protocol LCUniverseSelectorDelegate <NSObject>

@optional
//- (void)didSelectAtRow:(NSInteger)row withTableTag:(NSInteger)tag;
- (void)tableView:(UITableView *)tableView didSelectAtRow:(NSInteger)row otherTable:(UITableView *)other;
@end
@interface LCUniverseSelector : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _tableHeight;
}

@property (strong, nonatomic) id<LCUniverseSelectorDataSource> dataSource;
@property (strong, nonatomic) id<LCUniverseSelectorDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *leftTable;
@property (strong, nonatomic) IBOutlet UITableView *rightTable;
@property (copy, nonatomic) NSString *viewTitle;
- (void)reloadTable:(NSInteger)tableTag;

- (void)setHeight:(CGFloat)heigth;

@end
