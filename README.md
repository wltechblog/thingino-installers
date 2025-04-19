# thingino-installers

Files and tools for building Thingino firmware on various supported camera models.

> [!NOTE]
> Follow the README in the subdirectory named for your camera, THIS OVERRIDES WHAT I SHOW IN A VIDEO

## A note about UPDATES

The images in the installers are updated once a week, you probably want to do a full upgrade after installing!

## More Info

I have install videos for each model listed at https://www.youtube.com/@wltechblog
For support, jump over to the Hacker's Homestead discord channel! https://discord.gg/s6yJzhS4hD

## Want to build your own?

The included script `make_installers.sh` will create all the install images. Note that firmware images are cached between runs for speed and to
allow for version pinning.

> Note that the script is intended to run on a Linux host.

### Building with Docker

If you're not on Linux (say macOS), utilities such as `sfdisk` may not be available. You can build the dev container using Docker:

```bash
./docker-run.sh up
```

This will build a container using the docker files in this repository and drop you in a bash shell.
Next, simply run the `make_installers.sh` script as you would on a Linux host. `./docker-run.sh cleanup` will stop and remove the container.
Run `./docker-run.sh` to see a list of available commands.

## DISCLAIMER

The instructions and tools provided are best effort and were tested on the specific devices I purchased. Future hardware
and software revisions may cause problems, and maybe even break your camera (unlikely!). If your device doesn't flash as expected,
please file a bug with details or better yet, join our Discord and we can help diagnose it together. This is a hobbyist project
and no warranty is implied! Generally speaking you can only break these cameras if you hit them with something, but some devices
are easier for tinkering than others.
