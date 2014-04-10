//
//  ELExerciseAutocompleteTextField.h
//
//  Created by Gianni Settino on 4/10/14.
//

#import "HTAutocompleteTextField.h"

@interface ELExerciseAutocompleteTextField : HTAutocompleteTextField <HTAutocompleteDataSource>

/*
 * A list of exercises to suggest
 */
@property (nonatomic, copy) NSMutableArray* exercises;

@end
