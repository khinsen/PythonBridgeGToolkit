# PythonBridge extensions for GToolkit

Work in progress. Goal: useful inspector views on Python objects.

## Installation on top of GToolkit

Get GToolkit from [this site](https://gtoolkit.com/install/), and execute the following lines in a playground:

```
Metacello new
    baseline: 'PythonBridgeGToolkit';
    repository: 'github://khinsen/PythonBridgeGToolkit/src';
    onConflictUseLoaded;
    load.
```

