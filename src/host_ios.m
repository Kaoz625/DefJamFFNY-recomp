/* iOS host glue (blz/ios, Kaoz625 fork).
 *
 * Runs before main(): the game looks for game/default.xbe in the working folder and keeps
 * its settings, saves and logs beside it, so the working folder is the app's Documents
 * folder (visible in Files and Finder through UIFileSharingEnabled). Copy the extracted
 * dump there as Documents/game. DEFJAM_DATA names the same folder, as the setup's data
 * folder does on the Mac.
 */
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/stat.h>

__attribute__((constructor)) static void defjam_ios_folders(void)
{
    @autoreleasepool {
        NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        if (!docs) return;
        const char *path = docs.fileSystemRepresentation;
        if (chdir(path) != 0) return;
        if (!getenv("DEFJAM_DATA")) setenv("DEFJAM_DATA", path, 1);
        /* Logs: Documents/logs/ios-<time>.log, readable with devicectl copy from. */
        mkdir("logs", 0755);
        if (!getenv("DEFJAM_IOS_CONSOLE")) {
            char name[128];
            time_t now = time(NULL);
            strftime(name, sizeof name, "logs/ios-%Y%m%d-%H%M%S.log", localtime(&now));
            freopen(name, "w", stderr);
            dup2(fileno(stderr), fileno(stdout));
        }
    }
}

/* The display shape for widescreen "auto": the whole screen (landscape). */
int host_macos_display_size(int *w, int *h) { (void)w; (void)h; return 0; }
