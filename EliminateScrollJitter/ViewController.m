//
//  ViewController.m
//  TableViewDemo
//
//  Created by sunjinglin on 2020/5/17.
//  Copyright © 2020 sunjinglin. All rights reserved.
//

#import "ViewController.h"
#import "EliminateJitter.h"

@interface ViewController () <NSTableViewDelegate, NSTableViewDataSource>
@property (strong) NSMutableArray *fileList;
@property (strong) EliminateJitter *trigger;
@property (weak) IBOutlet NSTableView *fileListTableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.fileList = [NSMutableArray arrayWithCapacity:1];
    self.trigger = [[EliminateJitter alloc] initWithTriggerInterval:0.5];
    
    self.fileListTableview.delegate = self;
    self.fileListTableview.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidScroll:) name:NSViewBoundsDidChangeNotification object:self.fileListTableview.enclosingScrollView.contentView];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark- File Action
- (IBAction)clickLoadFileBtn:(NSButton *)sender {
    [self.fileList removeAllObjects];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = YES;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            for( NSURL* url in panel.URLs ){
                __block  NSString * filePath = url.path;
                if (filePath == nil ) {
                    return;
                }
                
                if (!self.fileList) {
                    self.fileList = [NSMutableArray array];
                }
                [self.fileList addObject:filePath.lastPathComponent];
            }
            
            [self.fileListTableview reloadData];
            [self.fileListTableview selectRowIndexes:[[NSIndexSet alloc] initWithIndex:0] byExtendingSelection:NO];
        }
    }];
}

#pragma mark - table data souutce delegate
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fileList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (self.fileList.count > row) {
        NSTableCellView *cellView = [self.fileListTableview makeViewWithIdentifier:@"fileCell" owner:self];
        cellView.textField.stringValue = [self.fileList objectAtIndex:row];
        return cellView;
    }
    
    return nil;
}

#pragma mark- Scroll Event
- (void)scrollViewDidScroll:(NSNotification *)notify {
    NSScrollView *scrollView = self.fileListTableview.enclosingScrollView;
    NSLog(@"documentVisibleRect=%@, \r\n docBounds=%@, \r\n contenSize=%@", NSStringFromRect(scrollView.documentVisibleRect), NSStringFromRect(scrollView.documentView.bounds),  NSStringFromSize(scrollView.contentSize));
    
    __weak typeof(self) weakSelf = self;
    [self.trigger triggerWithCallback:^{
        __strong typeof(self) self = weakSelf;
        NSArray *subs =  self.fileListTableview.accessibilityVisibleRows;
        
        NSMutableArray *arr1 = [NSMutableArray arrayWithCapacity:1];
        [subs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger currentRow = [[obj valueForKey:@"row"] integerValue];
            [arr1 addObject:[self.fileList objectAtIndex:currentRow]];
        }];
            
        NSLog(@"subs=%@", arr1);
    }];
}

- (BOOL)isScrollToBottom {
    NSScrollView *scrollView = self.fileListTableview.enclosingScrollView;
    NSRect contentOffSet = scrollView.documentVisibleRect;
    
    NSInteger docHeight = scrollView.documentView.bounds.size.height; //NSTableView 的高度（>= scrollView.contentView.height）
    NSInteger contentHeight = scrollView.contentSize.height; //clipView 的高度（也就是可视区域）
    NSInteger delt = docHeight - contentHeight; //滚动条的正常（非触底或触顶后继续拉伸）滚动区域（0-delt）。
    NSInteger offsetY = contentOffSet.origin.y; //滚动条的的滚动位置
    
    if (offsetY > delt ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isScrollToTop {
    NSScrollView *scrollView = self.fileListTableview.enclosingScrollView;
    NSRect contentOffSet = scrollView.documentVisibleRect;
    NSInteger offsetY = contentOffSet.origin.y; //滚动条的的滚动位置
    
    if (offsetY < 0) {
        return YES;
    }
    
    return NO;
}

@end
