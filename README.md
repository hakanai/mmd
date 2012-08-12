This is just a scratch area for MMD manipulation tools.

It isn't organised for reuse simply because I'm still trying to get it to work.

* mmd/vmd - code to read and write VMD files
* test.rb - run this with some .vmd files as parameters to see if the reading code works.
* glue.rb - utility to glue together two vmd files into a single file.

Glue
----

MMD seems to get exponentially slower as scenes get longer, and it's more convenient if you can work with separate files anyway.
Yet sometimes you might want to render a single output file (e.g. for a concert.)

So I tried making a tool which can glue together separate sequences.

If you didn't have a tool, this is what you would have to do:

    * Get Audacity or similar and use it to join the two wav files together.
    * In MMD, load that wav file.
    * From frame 0, load the first motion data. We'll assume it's in sync already.
    * Find the frame number of the second wav file, click on the header, load the second motion data.
    * Adjust the second motion data to match the music in the file (if you're good, maybe you can calculate the frame number before you add it, based on where you added it in the sound editor.)

Currently the glue code naively uses the frame of the animation, which is insufficient.

    * The glue code should take wav files in addition to vmd files.
    * It should be possible to specify the frame offset between the vmd and wav file if they don't line up.  (could possibly put this job on the animator though. Adjusting one file is not that hard.)
    * It should be possible to configure an unlimited number of animations to join together.
    * It should be possible to add animations which don't have sound.
    * It should be possible to add segments which have no sound nor animation.
    * If the motion data goes past the end of the wav, the motion data should determine the end of the animation.
    * If the motion data doesn't go past the end of the wav, the end of the animation should be determined based on the length of the wav (always at 30fps?)
    * If two wav files have different sample rates, the resulting wav should be the higher of the two (i.e. never downsample.)

When you hit the end of the first animation, strange interpolation occurs if the animation lacks explicit bone positions on the last frame.

    * Simple fix: have the code insert a bone at the last frame which matches the last position of that bone.
    * Proper fix: glue some more motion data between the two motion data files to bring the positions from one to the next in a sensible way.
    * Advanced fix: automatically generate some kind of sane animation for that intermediate file. :)

