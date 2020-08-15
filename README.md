# phoenixcms

Phoenix CMS

## Setup

Copy firebaseConfig-template.js as firebaseConfig.js and fill in your Firebase project information

## Update Firestore Rules

### Add Rules Function at top
`    function getPhoenixUser() {
    	return get(/databases/$(database)/documents/phoenixcms_users/$(request.auth.uid));
    }`

### Add Rules Needed for Phoenix CMS to function properly

`
    match /phoenixcms_users/{userId} {
      allow read: if getPhoenixUser() != null;
    }
  	match /phoenixcms_schema/{document=**} {
      allow read: if getPhoenixUser() != null;
      allow write: if getPhoenixUser() != null && getPhoenixUser().data.permissionLevel in ["owner", "admin"];
    }
`

### Add Rules for any collections you want to add data for (change 'new_collection' to your collection id):

`
    match /new_collection/{documentId} {
      allow read: if request.auth.uid != null;
      allow write: if getPhoenixUser() != null && getPhoenixUser().data.permissionLevel in ["owner", "admin", "editor", "creator"];
    }
`

# run 
`flutter run --debug -d chrome`

# build
`flutter build -v web`
