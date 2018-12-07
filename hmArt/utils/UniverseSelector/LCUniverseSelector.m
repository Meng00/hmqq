//
//  LCUniverseSelector.m
//  lifeassistant
//
//  Created by wangyong on 13-7-29.
//
//

#import "LCUniverseSelector.h"
@interface LCUniverseSelector ()

@end

@implementation LCUniverseSelector

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _tableHeight =  [[UIScreen mainScreen] applicationFrame].size.height - 93;
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
    

    CGRect rect = self.view.frame;
    rect.size.height = _tableHeight;
    self.view.frame = rect;
    CGRect rectTable = _leftTable.frame;
    rectTable.size.height = _tableHeight;
    _leftTable.frame = rectTable;
    
    rectTable = _rightTable.frame;
    rectTable.size.height = _tableHeight;
    _rightTable.frame = rectTable;
    if (_viewTitle) {
        self.title = _viewTitle;
    }
}

- (void)setHeight:(CGFloat)heigth
{
    _tableHeight = heigth;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLeftTable:nil];
    [self setRightTable:nil];
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
        return [_dataSource numberOfRowsInTableView:tableView.tag];
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(heightForRow:)]) {
        return [_dataSource heightForRow:tableView.tag];
    }
    return 44.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {   //left table
        NSString *kitemID = [NSString stringWithFormat:@"lefCell_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kitemID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kitemID];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        if (_dataSource) {
            NSDictionary *item = [_dataSource dictionaryForRow:indexPath.row withTag:tableView.tag];
            if ([[item objectForKey:@"hasNext"] isEqualToString:@"1"]) {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            if ([[item objectForKey:@"checked"] isEqualToString:@"1"]) {
                //NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            cell.textLabel.text = [item objectForKey:@"name"];
        }
        
        return cell;
        
    }else{ //right table
        static NSString *kRightItemID = @"rightCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRightItemID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRightItemID];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.contentView.backgroundColor = tableView.backgroundColor;
        }
        if (_dataSource) {
            NSDictionary *item = [_dataSource dictionaryForRow:indexPath.row withTag:tableView.tag];
            cell.textLabel.text = [item objectForKey:@"name"];
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate) {
        //[_delegate didSelectAtRow:indexPath.row withTableTag:tableView.tag];
        if (tableView.tag == 1) {
            [_delegate tableView:_leftTable didSelectAtRow:indexPath.row otherTable:_rightTable];
        }else{
            [_delegate tableView:_rightTable didSelectAtRow:indexPath.row otherTable:_leftTable];
        }
    
    }
}

- (void)reloadTable:(NSInteger)tableTag
{
    if (tableTag == 1) {
        [_leftTable reloadData];
    }else if(tableTag == 2){
        [_rightTable reloadData];
    }else
    {
        [_leftTable reloadData];
        [_rightTable reloadData];
    }
}

@end
