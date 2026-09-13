[back to overview](overview.md)
---

# Restoring individual files

Daily ZIPs contain the original file names and bytes at the ZIP root.
Any ZIP tool supporting Deflate and ZIP64 can extract them. There is no
manifest to interpret and no storepack-specific restore command.

1. Stop storepack and avoid concurrent changes to the affected store files.
2. Extract the required ZIP into a separate empty directory.
3. Verify extraction succeeded and review any names already present in the
   store. Do not overwrite different content.
4. Move the extracted files directly into the store.
5. Remove the ZIP only if you want the entire day to remain unpacked and all
   its entries have been restored successfully.

Names and bytes are restored exactly. Original filesystem metadata is not
restored. The precise timestamp remains in the filename. Basic ZIP dates
have limited range and precision and do not record a timezone.

If storepack runs again while the restored files are eligible, it packs them
again. Adjust the filter or minimum age, or keep storepack stopped while
working with an unpacked day. If the ZIP still exists, identical duplicates
are recognized and removed on the next run.
