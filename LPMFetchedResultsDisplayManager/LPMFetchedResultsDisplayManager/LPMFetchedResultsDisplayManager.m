// LPMFetchedResultsDisplayManager.m
//
// Copyright (c) 2014 Lonely Planet Publications Pty. Ltd. (http://lonelyplanet.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPMFetchedResultsDisplayManager.h"
#import "LPMCellConfiguration.h"

static void * LPMFetchedResultsDisplayManagerContext = &LPMFetchedResultsDisplayManagerContext;

@interface LPMFetchedResultsDisplayManager()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *keyPaths;

@end

@implementation LPMFetchedResultsDisplayManager

#pragma mark -
#pragma mark - Life-Cycle Methods
#pragma mark -

- (instancetype)init
{
    if (self = [super init])
    {
        NSString *tableViewKeyPath = NSStringFromSelector(@selector(tableView));
        [self addObserver:self forKeyPath:tableViewKeyPath
                  options:(NSKeyValueObservingOptionNew)
                  context:LPMFetchedResultsDisplayManagerContext];
    }
    
    return self;
}

- (void)dealloc
{
    NSString *tableViewKeyPath = NSStringFromSelector(@selector(tableView));
    [self removeObserver:self forKeyPath:tableViewKeyPath];
}

#pragma mark -
#pragma mark KVO
#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    BOOL contextMatches = (context == LPMFetchedResultsDisplayManagerContext);
    BOOL objectMatches = [object isEqual:self];
    BOOL keyPathMatches = [keyPath isEqualToString:NSStringFromSelector(@selector(tableView))];
    if (contextMatches && objectMatches && keyPathMatches && self.tableView)
    {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark -
#pragma mark Public Methods
#pragma mark -

- (void)reloadData
{
    if (self.fetchRequest)
    {
        if (self.cellConfiguration.cellClass && self.cellConfiguration.cellIdentifier && self.cellConfiguration.cellConfigurationBlock)
        {
            // Register the specified cell
            [self.tableView registerClass:self.cellConfiguration.cellClass
                   forCellReuseIdentifier:self.cellConfiguration.cellIdentifier];
        }
        else
        {
            // Register the generic cell
            NSString *cellIdentifierString = [NSString stringWithFormat:@"%@Cell", self.fetchRequest.entityName];
            UINib *cellNib = [UINib nibWithNibName:cellIdentifierString bundle:nil];
            [self.tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifierString];
        }
        
        NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
                                                                            managedObjectContext:moc
                                                                              sectionNameKeyPath:self.sectionNameKeyPath
                                                                                       cacheName:nil];
        [self.fetchedResultsController performFetch:nil];
    }
    else
    {
        self.fetchedResultsController = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table View Data Source Methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.fetchedResultsController)
    {
        NSInteger sections = self.fetchedResultsController.sections.count;
        return sections;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        NSInteger numberOfObjects = [sectionInfo numberOfObjects];
        return numberOfObjects;
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        return [sectionInfo name];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.fetchedResultsController)
    {
        return [self.fetchedResultsController sectionIndexTitles];
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (self.fetchedResultsController)
    {
        return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController)
    {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UITableViewCell *cell = nil;
        
        if (self.cellConfiguration.cellIdentifier && self.cellConfiguration.cellConfigurationBlock)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellConfiguration.cellIdentifier forIndex  Path:indexPath];
            self.cellConfiguration.cellConfigurationBlock(cell, managedObject);
        }
        else
        {
            // NOTE: Code below assumes that, for the NSManagedObject subclass being fetched,
            // there exists a UITableViewCell subclass with an identifier of the form 'ClassCell',
            // where 'Class' is the name of the NSManagedObject subclass being fetched. The code
            // also assumes that this UITableViewCell subclass implements a method of the form
            // 'configureWithClass:', where 'Class' is the name of the NSManagedObject subclass
            // being fetched. For instance, if there exists an NSManagedObject subclass Hamburger,
            // then this code assumes that there exists a UITableViewCell subclass HamburgerCell
            // with identifier 'HamburgerCell' and a method 'configureWithHamburger:(Hamburger*)hamburger'.
            // If your project cannot allow these assumptions, then provide an LPMCellConfiguration
            // instance with the relevant configuration data.
            NSString *managedObjectClassString = NSStringFromClass([managedObject class]);
            
            NSString *cellIdentifierString = [NSString stringWithFormat:@"%@Cell", managedObjectClassString];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierString forIndexPath:indexPath];
            
            NSString *cellSelectorString = [NSString stringWithFormat:@"configureWith%@:", managedObjectClassString];
            SEL selector = NSSelectorFromString(cellSelectorString);
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [cell performSelector:selector withObject:managedObject];
#pragma clang diagnostic pop
        }
        
        return cell;
    }
    else
    {
        return nil;
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellSelectionCallback)
    {
        NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.cellSelectionCallback(selectedObject);
    }
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods
#pragma mark -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self tableView:tableView
              configureCell:[tableView cellForRowAtIndexPath:indexPath]
          withManagedObject:anObject
                atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Private Methods
#pragma mark -

- (void)tableView:(UITableView*)tableView
    configureCell:(UITableViewCell*)cell
withManagedObject:(NSManagedObject*)managedObject
      atIndexPath:(NSIndexPath*)indexPath
{
    if (self.cellConfiguration.cellIdentifier && self.cellConfiguration.cellConfigurationBlock)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:self.cellConfiguration.cellIdentifier forIndexPath:indexPath];
        self.cellConfiguration.cellConfigurationBlock(cell, managedObject);
    }
    else
    {
        // NOTE: Code below assumes that, for the NSManagedObject subclass being fetched,
        // there exists a UITableViewCell subclass with an identifier of the form 'ClassCell',
        // where 'Class' is the name of the NSManagedObject subclass being fetched. The code
        // also assumes that this UITableViewCell subclass implements a method of the form
        // 'configureWithClass:', where 'Class' is the name of the NSManagedObject subclass
        // being fetched. For instance, if there exists an NSManagedObject subclass Hamburger,
        // then this code assumes that there exists a UITableViewCell subclass with identifier
        // 'HamburgerCell' and a method 'configureWithHamburger:(Hamburger*)hamburger'.
        // If your project cannot allow these assumptions, then provide a cellIdentifier
        // and cellConfigurationBlock via the relevant parameters.
        NSString *managedObjectClassString = NSStringFromClass([managedObject class]);
        
        NSString *cellIdentifierString = [NSString stringWithFormat:@"%@Cell", managedObjectClassString];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierString forIndexPath:indexPath];
        
        NSString *cellSelectorString = [NSString stringWithFormat:@"configureWith%@:", managedObjectClassString];
        SEL selector = NSSelectorFromString(cellSelectorString);
        [cell performSelector:selector withObject:managedObject afterDelay:0];
    }
}

@end
