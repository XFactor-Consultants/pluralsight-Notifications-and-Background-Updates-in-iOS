# Notifications and Background Updates in iOS
### Companion repo for the Pluralsight course — TaskFlow sample app

This repo holds **TaskFlow**, the same sample app used across the Authentication and Secure Storage course, now extended with local notifications, remote push, notification actions, Live Activity awareness, and background task scheduling. Every module builds directly on the previous one's completed code.

This README covers everything you need before you start: required versions, one-time setup, how to actually fire the JSON payload files used throughout the course, and — importantly — a list of known Simulator limitations discovered while building this course, so you don't lose time rediscovering them yourself.

---

## 1. What You Need Before Starting

### Hardware and OS
- **A Mac**, running **macOS Tahoe (26.x) or later**.
- **Xcode 26.x**, with the newest iOS Simulator runtime installed (Xcode → Settings → Platforms).

### Apple Developer Program
- A **paid Apple Developer Program membership** is required for this course — Push Notifications, Background Modes, and remote notification registration all require entitlements that a free/personal team cannot add.
- Enroll as an **Individual** unless you have a registered business with a D-U-N-S number.
- Kick off enrollment on day one if you haven't already — approval can take hours to a couple of business days.

### Your own bundle identifier
Every identifier string used throughout this course — `com.xfactorconsulting.TaskFlow`, `com.xfactorconsulting.TaskFlow.refresh`, `com.xfactorconsulting.TaskFlow.archive`, `com.xfactorconsulting.TaskFlow.historySync` — is built from **this specific project's** bundle identifier. None of those strings are magic values, and none of them are meant to be copied verbatim into a different project.

If you're building this course under your own Apple Developer account, your project will have its **own** bundle identifier (set in Xcode's target **General** tab, under **Bundle Identifier** — something like `com.yourcompany.TaskFlow`). Every one of the identifier strings in this course needs to be swapped to match yours, consistently, everywhere that string appears:

- The `identifier` constant in `BackgroundRefreshScheduler.swift` and `BackgroundArchiveScheduler.swift`
- `HistorySyncManager.sessionIdentifier`
- Both entries in the `Permitted background task scheduler identifiers` array in Info.plist
- The bundle identifier in every `xcrun simctl push booted <bundle-id> ...` command you run from Terminal
- The `identifier` you swap into the LLDB `_simulateLaunchForTaskWithIdentifier:` command

**The only hard requirement is internal consistency, not any specific string.** Nothing about `com.xfactorconsulting` is special — it's simply the reverse-domain identifier this particular project happens to use. What actually matters is that wherever a background task's identifier is referenced — the Swift constant, the Info.plist entry, and any LLDB command targeting it — all of them contain the exact same string, character for character. A single typo or an unswapped leftover from this repo's identifier is one of the most common ways background task registration silently fails: everything compiles cleanly, no error appears anywhere, and the task simply never runs, because the system is checking for a string that doesn't match what your code is actually using.

### A physical iOS device (strongly recommended, not strictly required)
Several mechanisms in this course — silent push delivery, `BGTaskScheduler.submit`, genuine cold-launch timing — are documented to behave unreliably on the Simulator (see **Section 6**). You can complete every module using only the Simulator and the debug-only workarounds this course builds, but if you have access to a real device, testing there will show you real, correct behavior the Simulator sometimes can't.

### Terminal comfort
This course uses `xcrun simctl push` extensively to fire test push notifications, and occasionally drops into LLDB (Xcode's debugger console) to simulate background task launches. Both are covered step by step below.

---

## 2. One-Time Project Setup

1. **Clone this repo.**
   ```bash
   git clone <repo-url> TaskFlow
   cd TaskFlow
   ```

2. **Open the project via the `.xcodeproj` file directly.**
   ```bash
   open TaskFlow/TaskFlow.xcodeproj
   ```

3. **Confirm the deployment target** is iOS 18.0 or higher: blue **TaskFlow** project icon → **TaskFlow** target → **General** → **Minimum Deployments**.

4. **Build the canonical base once** to confirm your environment is healthy — pick any iPhone simulator, press **⌘R**, and confirm you land on TaskFlow's task list.

5. **Add the required capabilities**, if you're building this course from the canonical base yourself rather than checking out a module's completed tag:
   - **Push Notifications** (Signing & Capabilities → + Capability)
   - **Background Modes**, with **Background fetch**, **Background processing**, and **Remote notifications** all checked

6. **Add the required Info.plist entries** (Info tab → Custom iOS Target Properties):
   - `Permitted background task scheduler identifiers` (raw key `BGTaskSchedulerPermittedIdentifiers`), an Array containing two Strings:
     - `com.xfactorconsulting.TaskFlow.refresh`
     - `com.xfactorconsulting.TaskFlow.archive`
   - `Required background modes` should show three entries once the capability above is added: `fetch`, `processing`, and `remote-notification`.

   **This last one — `remote-notification` — is the single easiest thing to miss in this entire course.** Without it, silent push notifications will be accepted by the system and registration will succeed, but `didReceiveRemoteNotification` will never fire, with no error anywhere telling you why.

---

## 3. Branch and Tag Structure

Same convention as the Authentication course: a `canonical-base` tag marks the app before any of this course's code exists, and each module ends in a tagged, fully-built commit.

```bash
git checkout canonical-base           # the true starting point
git checkout m2                       # TaskFlow after Module 2
```

Check out `canonical-base` if you want to build the whole course yourself, module by module. Jump straight to any `module-N-completed` tag if you'd rather study finished, working code.

---

## 4. Firing Test Push Notifications with `simctl push`

Every remote-push demo in this course uses Xcode's `simctl push` command instead of a real backend, a real certificate, or a real network round trip. It hands a JSON payload directly to the Simulator's notification system, exactly as if it had arrived from Apple's push servers.

### The payload files this course uses

Create these as plain `.json` files **anywhere outside this repo** — your Desktop, or a separate scratch folder. They are not part of the Xcode project and should never be added to the repo itself.

**`payload.json`** — a silent, content-available push (no banner, no sound):
```json
{
  "aps": { "content-available": 1 },
  "taskID": "8B4A1F2C-3D4E-4A5B-9C1D-2E3F4A5B6C7D",
  "title": "Review teammate's edits",
  "assigneeName": "Marcus Webb"
}
```

**`malformed.json`** — deliberately broken data, used to prove the app fails silently and safely rather than crashing:
```json
{
  "aps": { "content-available": 1 },
  "title": "Missing the task ID"
}
```

**`assignment.json`** — a visible alert push, tagged with the notification category so Complete and Snooze actions appear:
```json
{
  "aps": {
    "alert": { "title": "New assignment", "body": "Prepare sprint demo" },
    "category": "TASK_ASSIGNMENT"
  },
  "taskID": "8B4A1F2C-3D4E-4A5B-9C1D-2E3F4A5B6C7D",
  "title": "Prepare sprint demo",
  "assigneeName": "Dana Ortiz"
}
```

**Note on `taskID`:** TaskFlow's sample data normally generates a random UUID for every task at launch, which means it will never match a hardcoded ID in one of these files. If you want a payload's `taskID` to resolve against a real task in `TasksStore`, give that one task an explicit `id:` argument in `TasksStore.swift`'s `init()`, matching the UUID string used in your payload file.

### Running a push

1. Build and run TaskFlow (**⌘R**), and let it fully launch.
2. Background the app — **⇧⌘H**, or Simulator menu bar → **Device → Home**. (Do not force-quit unless a specific demo asks you to — backgrounding keeps the process alive, which is what most of these tests need.)
3. From Terminal, in the folder holding your `.json` file:
   ```bash
   xcrun simctl push booted com.xfactorconsulting.TaskFlow payload.json
   ```
   Confirm your bundle identifier matches exactly — check Xcode's target **General** tab if you're unsure.
4. Check Xcode's console for the expected output. A silent, content-available push produces no visible UI change at all — the proof is entirely in the console.

---

## 5. Simulating Background Tasks with LLDB

Waiting for iOS's real background scheduler isn't practical for testing — it can take anywhere from minutes to hours, or may not run at all in a given session. Apple provides a debugger command specifically to force a background task to run on demand.

1. Run the app (**⌘R**).
2. Pause execution — click the **pause** button (⏸) in Xcode's debug bar, or set a breakpoint anywhere in your code. **Do not click Stop** — that terminates the process and detaches the debugger entirely, which will not let this command work.
3. Once you see the `(lldb)` prompt at the bottom of the console, type:
   ```
   e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.xfactorconsulting.TaskFlow.refresh"]
   ```
   (Swap the identifier string for `com.xfactorconsulting.TaskFlow.archive` to simulate the archive task instead.)
4. Resume execution — click **Continue** (▶) in the debug bar, or type `continue` at the `(lldb)` prompt.
5. Watch the console for the handler's output.

**Important:** this command only works if `BGTaskScheduler.shared.submit(request)` succeeded earlier in the same run. See Section 6 below — on the Simulator, `submit` frequently does not succeed, which means this command will report *"No task request with identifier ... has been scheduled"* even when every other piece of your setup is correct.

---

## 6. Known Simulator Limitations

These were discovered directly while building this course. None of them indicate a problem with your code — they're documented gaps in what the Simulator can emulate, confirmed against Apple's own developer forums.

### `BGTaskScheduler.submit()` frequently fails on Simulator
You may see `Error Domain=BGTaskSchedulerErrorDomain Code=1 "(null)"` when calling `submit`, even with a correctly registered identifier, a correct `Info.plist` entry, and the right capability checked. This is a known Simulator rough edge. On a real device, `submit` succeeds cleanly under the same code.

### Silent (`content-available`) push notifications are unreliable on Simulator
Apple's own developer forums confirm this directly: silent push delivery to `didReceiveRemoteNotification` does not fire consistently on the Simulator, "by design" as simulated behavior, separate from ordinary alert-based pushes (which do deliver reliably). If a silent push demo doesn't produce console output, this is very likely why — not a bug in your delegate code.

### The workaround this course builds: debug-only direct invocation
Rather than keep fighting unreliable delivery, this course adds `#if DEBUG`-only methods that call the real production delegate methods **directly**, bypassing the unreliable Simulator delivery layer entirely. For example, `AppDelegate.debugSimulateSilentPush()` builds the same `userInfo` dictionary a real silent push would carry and hands it straight to `didReceiveRemoteNotification` — exercising the actual production code path deterministically, wired to a debug-only button in Settings. These methods are wrapped in `#if DEBUG` and will never exist in a release build.

If you hit either of the two limitations above while working through this course yourself, look for the equivalent debug affordance already built into that module rather than assuming your own code is wrong.

---

## 7. Course-Wide Conventions

- **Every background trigger funnels into one shared function**, never duplicated logic per trigger. `RefreshCoordinator.refresh()` is called identically from a scheduled `BGAppRefreshTask` and from a silent push arriving through `didReceiveRemoteNotification` — two different triggers, one definition of what "check for updates" means.
- **A background task's own job is to start long work and step aside**, not to babysit it. `HistorySyncManager.startSync()` kicks off a background `URLSession` transfer and returns immediately; a separate `AppDelegate` callback, `handleEventsForBackgroundURLSession`, is responsible for picking up the result whenever it actually arrives — potentially well after the code that started it has already finished running.
- **Expiration handlers exist to leave data in a valid state, not to finish faster.** `BackgroundArchiveScheduler`'s handler checks a cancellation flag between units of work, never mid-unit, so a reclaimed background window never leaves anything half-written.
- **Payloads are data you don't trust yet.** Every remote notification payload is parsed through a failable initializer (`TaskAssignmentPayload`) that returns `nil` rather than crashing on anything malformed or incomplete.
- **Debug-only affordances are named clearly and always wrapped in `#if DEBUG`** — `debugForceExpire`, `debugCorruptFirstEntry`, `debugSimulateSilentPush`, and others. None of them exist in a release build.

---

## 8. Getting Help

If a demo in this course doesn't behave the way the video shows, check — in order:
1. Is your `Info.plist` genuinely correct? Expand every array entry and check its actual value character by character; a stray character (this happened once during development, when an entire XML document got pasted into a single field by accident) is easy to miss at a glance.
2. Is this one of the two known Simulator limitations in Section 6? If so, use the debug-only workaround the relevant module already built, rather than continuing to chase the unreliable path.
3. Run `git status` / `git diff` and confirm the files you expect to be modified for that module actually show real changes — a discussed fix that never got saved is the single most common cause of "this doesn't match the video" issues in a long build session like this one.
