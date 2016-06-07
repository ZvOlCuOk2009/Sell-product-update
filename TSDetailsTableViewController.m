//
//  TSDetailsTableViewController.m
//  Sell product
//
//  Created by Mac on 25.05.16.
//  Copyright © 2016 Tsvigun Alexandr. All rights reserved.
//

#import "TSDetailsTableViewController.h"
#import "TSDataManager.h"
#import "NSString+TSFormattedStingPrice.h"
#import <CoreData/CoreData.h>

static NSString * messageCreation = @"Fill out all the required fields \nto create a product \nimage, name\nand price...";

@interface TSDetailsTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIImage *imageOne;
@property (strong, nonatomic) UIImage *imageTwo;
@property (strong, nonatomic) UIImage *imageThree;

@property (strong, nonatomic) NSMutableArray *arrayImages;
@property (strong, nonatomic) NSMutableArray *updateArrayImages;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *collectionButton;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) TSProduct *currentProduct;
@property (strong, nonatomic) UIButton *buttonEditing;
@property (strong, nonatomic) UIButton *oneButton;
@property (assign, nonatomic) NSInteger currentTag;
@property (assign, nonatomic) NSInteger counter;


@end

@implementation TSDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Post your item";
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    self.arrayImages = [NSMutableArray array];
    self.updateArrayImages = [NSMutableArray array];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.nameTextField.text = self.name;
    self.priceTextField.text = self.price;
    self.descriptionTextField.text = self.specification;
    
    _counter = 0;
    
    for (int i = 0; i < [self.images count]; i++) {
        self.buttonEditing = [self.collectionButton objectAtIndex:i];
        [self.buttonEditing setImage:[self.images objectAtIndex:_counter] forState:UIControlStateNormal];
        _counter++;
    }
    
    self.images = self.arrayImages;
    
    /*
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
     */
    
    self.nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 10, 0);
    self.priceTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 10, 0);
    self.descriptionTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 10, 0);
}

/*
- (void)actionBack:(UIBarButtonItem *)item
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
 */

- (void)currentProduct:(TSProduct *)product
{
    self.currentProduct = product;
}

#pragma mark - NSManagedObjectContext

-(NSManagedObjectContext *) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[TSDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

#pragma mark - Actions

- (IBAction)photoAction:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select image"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionCamera = [UIAlertAction actionWithTitle:@"Use the camera"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                              if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                  picker.delegate = self;
                                                  [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                                                  picker.allowsEditing = false;
                                                  [self presentViewController:picker animated:true completion:nil];
                                                              }
                                                          }];
    
    UIAlertAction *alertActionLibrary = [UIAlertAction actionWithTitle:@"From the library"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                              if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                  picker.delegate = self;
                                                  [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                  picker.allowsEditing = true;
                                                  [self presentViewController:picker animated:YES completion:nil];
                                                              }
                                                          }];
    [alertController addAction:alertActionCamera];
    [alertController addAction:alertActionLibrary];
    [self presentViewController:alertController animated:YES completion:nil];
    
    self.currentTag = sender.tag;
}

- (IBAction)postItAction:(id)sender
{
    if (self.currentProduct) {
        self.oneButton = [self.collectionButton objectAtIndex:0];
        if (![self.oneButton.imageView.image isEqual:[UIImage imageNamed:@"photo"]] && ![self.nameTextField.text isEqualToString:@""] && ![self.priceTextField.text isEqualToString:@""]) {
        [self editingCurrentProduct];
        } else {
            [self warningAlertController];
        }
    } else {
        
        if (![self.oneButton.imageView.image isEqual:[UIImage imageNamed:@"photo"]] && ![self.nameTextField.text isEqualToString:@""] && ![self.priceTextField.text isEqualToString:@""]) {
            [self createdNewProduct];
        } else {
            [self warningAlertController];
        }
    }
}

- (void)warningAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please!"
                                                                             message:messageCreation
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"Ok"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                        }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Save product

- (void)createdNewProduct
{
    TSProduct *product = [NSEntityDescription insertNewObjectForEntityForName:@"TSProduct"
                                                       inManagedObjectContext:self.managedObjectContext];
    product.name = self.nameTextField.text;
    product.price = [NSString formattedStringPrice:self.priceTextField.text];
    product.specification = self.descriptionTextField.text;
    product.images = [NSKeyedArchiver archivedDataWithRootObject:self.arrayImages];
    [self.managedObjectContext save:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Save editing product

- (void)editingCurrentProduct
{
    self.currentProduct.name = self.nameTextField.text;
    self.currentProduct.price = [NSString formattedStringPrice:self.priceTextField.text];
    self.currentProduct.specification = self.descriptionTextField.text;
    
    for (UIButton *button in self.collectionButton) {
        if (![button.imageView.image isEqual:[UIImage imageNamed:@"photo"]]) {
            UIImage *image = button.imageView.image;
            [self.updateArrayImages addObject:image];
        }
    }
    
    NSData *imageArchive = [NSKeyedArchiver archivedDataWithRootObject:self.updateArrayImages];
    self.currentProduct.images = imageArchive;
    [self.managedObjectContext save:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.currentTag == 0) {
        self.imageOne = image;
        [self.arrayImages addObject:self.imageOne];
    } else if (self.currentTag == 1) {
        self.imageTwo = image;
        [self.arrayImages addObject:self.imageTwo];
    } else if (self.currentTag == 2) {
        self.imageThree = image;
        [self.arrayImages addObject:self.imageThree];
    }
    
    [self setButtonImageBackgruond:self.currentTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setButtonImageBackgruond:(NSInteger)tagButton
{
    UIButton *currentButton = [self.collectionButton objectAtIndex:tagButton];
    self.buttonEditing = currentButton;
    
    if (currentButton.tag == 0) {
        [currentButton setImage:self.imageOne forState:UIControlStateNormal];
    } else if (currentButton.tag == 1) {
        [currentButton setImage:self.imageTwo forState:UIControlStateNormal];
    } else if (currentButton.tag == 2) {
        [currentButton setImage:self.imageThree forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField && textField == self.descriptionTextField) {
        [self.descriptionTextField becomeFirstResponder];
    } else if (textField == self.priceTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
