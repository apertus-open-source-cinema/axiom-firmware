## Download Nightly Firmware
If you want to experiment with the latest changes and dont mind, when the camera isnt working, you try use the untested nightly firmware images.
```diff
- Warning! The nightly images are not veryfied by a human and might damage your camera permanently. 
- Only continue, if you know, what you are doing!
```

To try this anyway, you
1. Have to [download etcher](https://etcher.io/) & install it
2. [Go to circleci](https://circleci.com/gh/apertus-open-source-cinema/beta-software) & log in
    1. click on the last successful build job of type `assemble_test_image`
    2. select the `artifacts` tab and download the `axiom-nightly.img.gz`
3. Select the `axiom-nightly.img.gz` file of the image in etcher and flash it on a microsd card with at least 8GB.
