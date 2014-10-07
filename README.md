FOAssetPicker
=============

Lightweight library for iOS multi-selection asset picking (photo+video)

### Usage
Create an instance of the asset picker, configure it and assign it the delegate.

```
FOAssetPicker* assetPicker = [[FOAssetPicker alloc] initWithPickerType: FOAssetPickerTypePhotos];
assetPicker.maxSelectionCount = 10;
assetPicker.pickerDelegate = self;
```

Then present it (e.g on a navigation controller):

```
[self.navigationController pushViewController:assetPicker animated:YES];
```

React to the user selection in your delegate:

```
 - (void) assetPicker: (FOAssetPicker*) assetPicker didFinishPickingWithAssets: (NSArray*) assets {
  ALAsset* firstAsset = [assets objectAtIndex:0];
  // e.g. get a thumbnail
  CGImageRef thumbRef = [firstAsset aspectRatioThumbnail];
  // e.g. get the full resolution image
  ALAssetRepresentation* representation = [firstAsset defaultRepresentation];
  CGImageRef fullRef = [representation fullResolutionImage];
  // or access the asset by addressing it with its URL
  NSURL* url = [firstAsset valueForProperty: ALAssetPropertyAssetURL];
  ...
}
```