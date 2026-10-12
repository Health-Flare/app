<!-- kind: fix -->
- When an update to your data failed partway and was tried again, the
  copy saved before the update could be replaced by a copy of the
  half-updated data. The copy from before the update is now kept.
- A new profile can no longer be given the number of a deleted profile
  whose entries are still stored, even if an update didn't finish.
