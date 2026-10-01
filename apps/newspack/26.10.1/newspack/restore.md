[back to overview](overview.md)
---

# Restoring individual files

Daily ZIPs contain the original file names and bytes at the ZIP root. Any ZIP
tool supporting Deflate and ZIP64 can extract them. There is no manifest to
interpret and no newspack-specific restore command.

1. Stop newspack, Newsindex, and other tools that read or change the affected
   store while performing this offline procedure.
2. Extract the required ZIP into a separate empty directory.
3. Verify extraction succeeded and review any names already present in the
   store. Do not overwrite different content.
4. Move the extracted files directly into the store.
5. Remove the ZIP only if you want the entire day to remain unpacked and all
   its entries have been restored successfully.

Names and bytes are restored exactly. Original filesystem metadata is not
restored. The precise timestamp remains in the filename. Basic ZIP dates have
limited range and precision and do not record a timezone.

If newspack runs again while the restored files are eligible, it packs them
again except for the retained loose anchor. Adjust the filter or minimum age, or
keep newspack stopped while working with an unpacked day. If the ZIP still
exists, identical duplicates are recognized and removed on the next run except
for the retained anchor.

## Regular-operation readiness

Before restarting regular operation, follow the shared
[anchor and delivery prerequisites](https://github.com/leni-lab/store-contracts/blob/main/docs/news-store.md#operating-prerequisites-and-recovery).
