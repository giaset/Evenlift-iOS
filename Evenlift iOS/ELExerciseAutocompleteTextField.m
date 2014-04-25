//
//  ELExerciseAutocompleteTextField.m
//
//  Created by Gianni Settino on 4/10/14.
//

#import "ELExerciseAutocompleteTextField.h"
#import <Firebase/Firebase.h>
#import "ELSettingsUtil.h"

@implementation ELExerciseAutocompleteTextField

- (void)setupAutocompleteTextField
{
    [super setupAutocompleteTextField];
    
    // Set up the Firebase for this user's exercises
    Firebase* exercisesRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://evenlift.firebaseio.com/users/%@/exercises", [ELSettingsUtil getUid]]];
    
    // Init the empty Exercises array
    self.exercises = [[NSMutableArray alloc] initWithObjects:@"Bench Press", @"Squat", @"Deadlift", @"Military Press", nil];
    
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
