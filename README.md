SIMBL - SIMBL is the SIMple Bundle Loader
=========================================

Official homepage: <http://code.google.com/p/simbl/>

This is another fork of SIMBL with a few additions / changes:

* It fixes the "Please update this scripting addition to supply a value for ThreadSafe for each event handler" warning which occurs in console ([bug report](http://code.google.com/p/simbl/issues/detail?id=7)). This makes it incompatible with 10.5 and older (that is why upstream didn't want to patch it).

* It searches for SIMBL plugins in all directories, i.e. also `/System/...` where it hasn't searched earlier. Technically, earlier, it searched only in `NSUserDomainMask | NSLocalDomainMask | NSNetworkDomainMask` whereby now, it searches in `NSAllDomainsMask`.

* It looks for plugins in MyPlugins instead of Plugins, to work around Chrome 14's blacklist. So your plugins should be installed in `/System/Library/Application\ Support/SIMBL/MyPlugins`.

* It must be installed now into `/System/Library/Services/`. Run `sudo "/System/Library/Services/SIMBL.bundle/Contents/Resources/SIMBL Agent.app/Contents/MacOS/SIMBL Agent" -psn` for setup.

* It uses `mach_inject_bundle_pid` from [mach_star](https://github.com/rentzsch/mach_star) ([my fork of mach_star](https://github.com/albertz/mach_star)).

The changes regarding `/System/` are needed to make it working again with recent Chrome versions. See [here](http://stackoverflow.com/questions/7269704/google-chrome-openscripting-framework-cant-find-entry-point-injecteventhandle/) for details.

Blacklist an application:

    defaults write net.culater.SIMBL_Agent SIMBLApplicationIdentifierBlacklist -array com.apple.Safari

