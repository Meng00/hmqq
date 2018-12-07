//
//  LCGlobalSelector.m
//  lifeassistant
//
//  Created by wangyong on 13-6-16.
//
//

#import "LCGlobalSelector.h"
#import "HMGlobal.h"

#define kSelectorDictionary 1
#define kSelectorDelimiterString 2
#define kSelectorArray 3

@interface LCGlobalSelector ()

@end

@implementation LCGlobalSelector

@synthesize selectedIndex;
//@synthesize showField;
@synthesize showTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"请选择";
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil viewTitle:(NSString *)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _resultTable.frame;
    if (IOS7) {
        _resultTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 73;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 93;
    }
    _resultTable.frame = rect;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setResultTable:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma tableview data source method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataSource) {
        return [_dataSource numberOfRows] + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"globalSelectorCell";
    if (indexPath.row == 0) {
        cellId = @"globalSelectorCellTitle";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.backgroundColor = [UIColor redColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        if (showTitle) {
            cell.textLabel.text = showTitle;
        }else
            cell.textLabel.text = @"请选择";
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
         
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        if (_dataSource) {
            NSString *str = [_dataSource titleForRow:(indexPath.row - 1)];
            cell.textLabel.text = str;
        }
        UIImageView *detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
       if (indexPath.row == (selectedIndex + 1)) {
            [detailImage setImage:[UIImage imageNamed:@"global_selector_checked.png"]];
        }else{
            [detailImage setImage:[UIImage imageNamed:@"global_selector_uncheck.png"]];
        }
        
        cell.accessoryView = detailImage;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        NSInteger selectRow = indexPath.row - 1;
        if (_delegate) {
            [self.navigationController popViewControllerAnimated:YES];
            [_delegate selectorDidSelect:selectRow];
        }
    }
    
}
@end
