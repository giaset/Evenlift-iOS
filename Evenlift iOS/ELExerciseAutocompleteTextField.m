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
    // Check that text field contains an @
    NSRange atSignRange = [prefix rangeOfString:@"@"];
    if (atSignRange.location == NSNotFound)
    {
        return @"";
    }

    // Stop autocomplete if user types dot after domain
    NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
    NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
    if (rangeOfDot.location != NSNotFound)
    {
        return @"";
    }

    // Check that there aren't two @-signs
    NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
    if ([textComponents count] > 2)
    {
        return @"";
    }

    if ([textComponents count] > 1)
    {
        // If no domain is entered, use the first domain in the list
        if ([(NSString *)textComponents[1] length] == 0)
        {
            return [self.exercises objectAtIndex:0];
        }

        NSString *textAfterAtSign = textComponents[1];

        NSString *stringToLookFor;
        if (ignoreCase)
        {
            stringToLookFor = [textAfterAtSign lowercaseString];
        }
        else
        {
            stringToLookFor = textAfterAtSign;
        }

        for (NSString *stringFromReference in self.exercises)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }

            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }

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
