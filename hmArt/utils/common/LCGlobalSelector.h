//
//  LCGlobalSelector.h
//  lifeassistant
//
//  Created by wangyong on 13-6-16.
//
//

#import <UIKit/UIKit.h>

@protocol globalSelectorDataSource <NSObject>

@required
- (NSInteger)numberOfRows;
- (NSString *)titleForRow:(NSInteger)row;

@end

@protocol globalSelectorDelegate <NSObject>

@required

- (void)selectorDidSelect:(NSInteger)row;

@end

@interface LCGlobalSelector : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *resultTable;

@property (copy, nonatomic) NSString *showTitle;

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, retain) id <globalSelectorDelegate>delegate;

@property (nonatomic, retain) id <globalSelectorDataSource>dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewTitle:(NSString *)title;
@end
