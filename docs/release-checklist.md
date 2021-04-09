Release Checklist
===

- [ ] Make sure the right endpoints are configured in `Network.swift`

- For every outlet
 - [ ] Ensure succes dismissed the view controller
 - [ ] Ensure cancel does not dismiss the view controller
 - [ ] (If possible) ensure it displays an error message
 - [ ] Make sure the analytics events fire for tapped & succeeded
 - [ ] Ensure outlet only shows up if available


 - Photo Prompt
 - [ ] Ensure the Photo pre-prompts before making the native ask
 - [ ] Ensure "deny" tells the user to visit settings
 - [ ] Ensure allow, allows the outlets to work



 - Snapchat
 - [ ] Install `ShareThatToSnapchat` & ensure outlet shows up

 - Facebook
 - [ ] Install `ShareThatToFacebook` & ensure outlet shows up
