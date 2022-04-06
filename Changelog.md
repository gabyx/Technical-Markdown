# Changelog

List items with ❗ should get special attention: The changes are provided either
in the diff view in the pull request or in a more direct link.

<!--UPDATE-TAG min-version:1.0.5 max-version:9.9.9-->

## Version `v2.0.0` (2022-04-6)

❗ This major update includes docker images (see [`Readme.md`](Readme.md)) and some
major clean up on the directory structure of the repository. The major changes
include

- Pandoc `2.17` is used in all docker images.
- The `convert` folder has been moved to `tools/convert` to **decouple** the build
  from the markdown source. The upgrade makes it possible to use docker images
  `technical-markdown:<version>` to build your own sources without the need to
  have the `tools` folder also in your own repository. Also a different source
  layout is possible by adapting the `build.gradle.kts`. If you want to
  experiment in your fork or own repository with different layouts/styling and
  `pandoc` conversions you can use the `technical-markdown:<version>-minimal`
  image which does not include the tools folder. Any feature improvement which
  could be of general interest is highly welcome.

## Version < `v1.7.0`

No changelog has been maintained so far. Read the Git history.
