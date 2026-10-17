<!-- kind: fix -->
- Meal photos and profile pictures are kept in the app's own folder, so the
  phone can't clear them and they no longer go missing after an update.
  Photos saved earlier are moved there; ones the phone had already cleared
  are removed instead of showing as broken. New photos are saved at most
  1600 pixels across.
- Removing a photo, or deleting its meal or profile, now deletes the photo
  file too. Before, it stayed on the phone. The app says so first: removing
  a saved photo asks before it goes, and deleting a meal with a photo or a
  profile says its photos are deleted with it and are lost if they aren't
  saved anywhere else.
- A backup file can no longer make the app show another file on the phone
  as a profile picture or meal photo.
