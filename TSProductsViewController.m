//
//  TSProductsViewController.m
//  Sell product
//
//  Created by Mac on 03.06.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue: b/255.0 alpha:1.0]
#define VIOLET_COLOR RGB(79, 49, 108)
#define LIGHTGRAY_COLOR RGB(221, 221, 221)
#define WHITE_COLOR RGB(255, 255, 255)
#define GRAY_COLOR RGB(115, 115, 115)

#import "TSProductsViewController.h"
#import "TSDetailsTableViewController.h"
#import "TSTableViewCell.h"
#import "TSDataManager.h"
#import "TSProduct+CoreDataProperties.h"
#import "TSDescriptionViewController.h"
#import "TSCustomButton.h"
#import <CoreData/CoreData.h>

@interface TSProductsViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TSProduct *product;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation TSProductsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(4, 0, 48, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [self configureSearchBar];
    [self configureTabBar];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - UISearchBar

- (void)configureSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 35, 40)];
    searchBar.backgroundImage = [[UIImage alloc] init];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
}

#pragma mark - the bottom panel buttons

- (void)configureTabBar
{
    CGRect frameDiscover = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width / 2, 44);
    CGRect frameSell = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height - 44, self.view.frame.size.width / 2, 44);
    
    TSCustomButton *discoverButton  = [TSCustomButton customButton:frameDiscover  color:VIOLET_COLOR image:[UIImage imageNamed:@"discover"] title:@"Discover" correctOffset:20 titleColor:WHITE_COLOR];
    
    TSCustomButton *sellButton = [TSCustomButton customButton:frameSell color:LIGHTGRAY_COLOR image:[UIImage imageNamed:@"sell"] title:@"Sell" correctOffset:0 titleColor:GRAY_COLOR];
    
    [discoverButton addTarget:self action:@selector(actionDiscover:) forControlEvents:UIControlEventTouchUpInside];
    [sellButton addTarget:self action:@selector(actionSell:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:discoverButton];
    [self.view addSubview:sellButton];
}

#pragma mark - NSManagedObjectContext

-(NSManagedObjectContext *) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[TSDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (TSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Configure cell

- (void)configureCell:(TSTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TSProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = product.name;
    cell.priceLabel.text = product.price;
    NSArray *images = [NSKeyedUnarchiver unarchiveObjectWithData:product.images];
    cell.imageProduct.image = [images objectAtIndex:0];
}

#pragma mark - UITableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSDescriptionViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSDescriptionViewController"];
    self.product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    controller.name = self.product.name;
    controller.price = self.product.price;
    controller.specification = self.product.specification;
    controller.images = [NSKeyedUnarchiver unarchiveObjectWithData:self.product.images];
    [controller receiveCell:self.product];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Acrions

- (void)actionDiscover:(UIBarButtonItem *)item
{
    
}

- (void)actionSell:(UIBarButtonItem *)item
{
    TSDetailsTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSDetailsTableViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar becomeFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        _fetchedResultsController = nil;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
        [[_fetchedResultsController fetchRequest] setPredicate:predicate];
    }
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TSProduct" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptorImage = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptorImage]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
