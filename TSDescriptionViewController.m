//
//  TSDescriptionViewController.m
//  Sell product
//
//  Created by Mac on 03.06.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import "TSDescriptionViewController.h"
#import "TSProduct.h"
#import "TSDataManager.h"
#import "TSDetailsTableViewController.h"

@interface TSDescriptionViewController () <UIScrollViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) TSProduct *currentProduct;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation TSDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameTextView.text = self.name;
    self.priceTextView.text = self.price;
    self.descriptionTextView.text = self.specification;
    
    self.pageControl.numberOfPages = [self.images count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nameTextView.editable = NO;
    self.priceTextView.editable = NO;
    self.descriptionTextView.editable = NO;
}

/*
- (void)actionBack:(UIBarButtonItem *)item
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
 */

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupScroll];
}

#pragma mark - NSManagedObjectContext

-(NSManagedObjectContext *) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[TSDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - Transfer pressed cell

- (void)receiveCell:(TSProduct *)product
{
    self.currentProduct = product;
}

#pragma mark - Actions

- (IBAction)trashButton:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you"
                                                                             message:@"Sure you want to remove this product"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionNo = [UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                          }];
    
    UIAlertAction *alertActionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self.managedObjectContext deleteObject:self.currentProduct];
                                                              [self.managedObjectContext save:nil];
                                                              [self.navigationController popToRootViewControllerAnimated:YES];
                                                          }];
    [alertController addAction:alertActionNo];
    [alertController addAction:alertActionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)editButton:(id)sender
{
    TSDetailsTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TSDetailsTableViewController"];
    controller.name = self.name;
    controller.price = self.price;
    controller.specification = self.specification;
    controller.images = self.images;
    [controller currentProduct:self.currentProduct];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionDiscover:(UIBarButtonItem *)item
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIScrollView

- (void) setupScroll {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.images count], self.scrollView.bounds.size.height);
    
    for (int i = 0; i < [self.images count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.scrollView.bounds.size.width,
                                                                               0 * self.scrollView.bounds.size.height,
                                                                               self.scrollView.bounds.size.width,
                                                                               self.scrollView.bounds.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        imageView.image = [self.images objectAtIndex:i];
        
        [self.scrollView addSubview:imageView];
    }
}

#pragma mark -  UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width;
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = pageNumber;
}

@end
