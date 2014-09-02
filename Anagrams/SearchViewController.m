//
//  SearchViewController.m
//  Anagrams
//
//  Created by Jonathan on 9/2/14.
//  Copyright (c) 2014 Jonathan Underwood. All rights reserved.
//

#import "SearchViewController.h"
#import "ResultsTableViewController.h"

#import "DictionaryImporter.h"
#import "WordTree.h"
#import "TreeClimber.h"

@interface SearchViewController ()
@property (nonatomic, strong) WordTree *wordTree;
@property (nonatomic, strong) NSArray *results;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIProgressView *loadProgress;
@property (weak, nonatomic) IBOutlet UITextField *lettersTextField;
@property (weak, nonatomic) IBOutlet UITextField *boardTextField;
@end

@implementation SearchViewController

- (IBAction)loadButton:(id)sender {
    self.loadButton.enabled = NO;
    self.loadProgress.alpha = 1;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        DictionaryImporter *importer = [[DictionaryImporter alloc] init];
        self.wordTree = [importer buildWordTree:^ (long total, long imported){
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = (float)imported / (float)total;
                self.loadProgress.progress = progress;
            });
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadProgress.alpha = 0;
            self.searchButton.enabled = YES;
        });
    });
}

- (IBAction)searchButton:(id)sender {
    TreeClimber *treeClimber = [[TreeClimber alloc] initWithWordTree:self.wordTree andLetters:self.lettersTextField.text];
    [treeClimber startClimbing];

    self.results = treeClimber.results;
    [self performSegueWithIdentifier:@"showResults" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResults"]) {
        ResultsTableViewController *resultsVC = (ResultsTableViewController *)segue.destinationViewController;

        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        resultsVC.theResults = [self.results sortedArrayUsingDescriptors:sortDescriptors];
    }
}

@end