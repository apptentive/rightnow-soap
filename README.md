# RightNow

Partial Ruby wrapper for Oracle RightNow's SOAP API.

This library currently only supports:

- Contact
  - Create
- Incident
  - Create
  - Update

## Issues, Questions & ToDos

1. Extract objects into classes
  - Email, Name, etc
1. How does Oracle respond if we send a blank/nil Thread message?
  - Or other fields for that matter
1. How are we handling an anonymous user?
  - Normally we create a no-reply@apptentive.com user
  - We will need to store this user account on the Integration
    - but what if they change the credentials?
    - do we clear out the user? then we'd need to find it again
      - maybe we need a QUERY interface as well for contacts?
1. Should we raise an error if we get a duplication message back?
  - Creating contacts could result in collisions, which will cause us not to have an ID for that App/Email pair.

## Contributing to RightNow

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Michael Saffitz. See LICENSE.txt for
further details.

