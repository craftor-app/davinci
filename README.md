# Davinchi

### Simple use case of the Click method.

<p>NOTE: only use this if widget is present in the widget tree

Returns the `Uint8List` of the widget</p>

```

image = await DavinciCapture.click(
context: context, imageKey, pixelRatio: 3);

```

### Offstage method

<p>Creates new widget pipeline and captures screenshot of the widget.

NOTE: IN this method widget doesn't require to be present in the widget tree.

</p>

```
  image = await DavinciCapture.offStage(
                    context: context, const PreviewWidget());
```
