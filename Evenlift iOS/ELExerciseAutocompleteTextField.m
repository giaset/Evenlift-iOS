//
//  ELExerciseAutocompleteTextField.m
//
//  Created by Gianni Settino on 4/10/14.
//

#import "ELExerciseAutocompleteTextField.h"
#import <Firebase/Firebase.h>

@implementation ELExerciseAutocompleteTextField

- (void)setupAutocompleteTextField
{
    [super setupAutocompleteTextField];
    
    // Set up the Firebase for this user's exercises
    NSString* uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    Firebase* exercisesRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/users/%@/exercises", uid]];
    
    // Init the empty Exercises array
    self.exercises = [[NSMutableArray alloc] init];
    
    // Get exercises to suggest
    [exercisesRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString* exercise = snapshot.name;
        [self.exercises addObject:exercise];
    }];
    
    self.autocompleteDataSource = self;
}

#pragma mark - HTAutocompleteDataSource

- (NSString *)textField:(HTAutocompleteTextField *)textField completionForPrefix:(NSString *)prefix ignoreCase:(BOOL)ignoreCase
{
    NSString* stringToLookFor = (ignoreCase) ? [prefix lowercaseString] : prefix;
    
    for (NSString* stringFromReference in self.exercises)
    {
        NSString* stringToCompare = (ignoreCase) ? [stringFromReference lowercaseString] : stringFromReference;
        
        if ([stringToCompare hasPrefix:stringToLookFor])
        {
            return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
        }
        
    }

    return @"";
}

- (void)setExercises:(NSMutableArray *)newExercises
{
    if (_exercises != newExercises) {
        _exercises = [newExercises mutableCopy];
    }
}


@end
