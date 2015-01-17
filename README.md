ShareASale
==========

ShareASale conference app

An app that allows people at the same industry events/conferences (by location) to find each other based on common preferences, filter results, view details, chat, meetup, and record the results.

Users login via Facebook using Parse's PFFacebookUtils class, and then are stored as a _User object on Parse.com's cloud backend, which keeps location, preferences, profile, and other attributes. Their invitations to users that match their preferences are stored as Invite objects, messages between each other stored as Message, notes about meeting results stored as Note, and corresponding personal photos grabbed from Facebook (or changed via UIIMagePickerController) stored as UserPhoto. User profile images are also stored locally using CoreData. I can provide Parse login if you need it. 

In-app chat is implemented via JSQMessagesViewController: https://github.com/jessesquires/JSQMessagesViewController

Desired Improvements: 

1. Change from Facebook to LinkedIn login. Facebook probably isn't what professionals want to expose to a meetup app. NOTE: Added third party PFLinkedInUtils library to help (https://github.com/alexruperez/PFLinkedInUtils)

2. Overhaul UI using Sketch? (me) Seems pretty basic now. 

3. Add teaser information *before* login so users are greeted with something else before being prompted to join/login using LinkedIn. Possibly teaser information might include a running list of latest users, attendees, users meeting up, etc. 

4. Brainstorm new features, e.g. would be AWESOME for users to be able to pinpoint each other on a map with an availability indicator, make it as modular as possible since the app is intended to be licensed to different conferences and even industries.

5. Eventually Android (maybe even Windows Phone) support? 

6. Profit!



