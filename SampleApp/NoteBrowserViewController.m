//
//  NoteBrowserViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/6/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "NoteBrowserViewController.h"
#import "EvernoteSDK.h"
#import "ENMLUtility.h"

@interface NoteBrowserViewController ()

@property (nonatomic,assign) NSInteger currentNote;

@end

@implementation NoteBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.btnPrev setEnabled:NO];
    [self loadCurrentNote];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBtnPrev:nil];
    [super viewDidUnload];
}

- (IBAction)nextNote:(id)sender {
    self.currentNote++;
    if(self.currentNote > 0) {
        [self.btnPrev setEnabled:YES];
    }
    else {
        [self.btnPrev setEnabled:NO];
    }
    [self loadCurrentNote];
}

- (IBAction)previousNote:(id)sender {
    self.currentNote--;
    [self loadCurrentNote];
    if(self.currentNote==0) {
        [self.btnPrev setEnabled:NO];
    }
}

- (void) loadCurrentNote {
    EDAMNoteFilter* filter = [[EDAMNoteFilter alloc] initWithOrder:0 ascending:NO words:nil notebookGuid:nil tagGuids:nil timeZone:nil inactive:NO emphasized:nil];
    [[EvernoteNoteStore noteStore] findNotesWithFilter:filter offset:self.currentNote maxNotes:1 success:^(EDAMNoteList *list) {
        EDAMNote* foundNote = list.notes[0];
        [[EvernoteNoteStore noteStore] getNoteWithGuid:foundNote.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
            ENMLUtility *utltility = [[ENMLUtility alloc] init];
            [utltility convertENMLToHTML:note.content withResources:note.resources completionBlock:^(NSString *html, NSError *error) {
                if(error == nil) {
                    [self.webView loadHTMLString:html baseURL:nil];
                }
            }];
        } failure:^(NSError *error) {
            NSLog(@"Failed to get note : %@",error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failed to find notes : %@",error);;
    }];
}
@end