# Quick config that allows a "Run To Here" functionality from inside Neovim in RADDBG.

### Setup
Install the RADDBG debugger to a desired directory from here: https://github.com/EpicGamesExt/raddebugger
Inside the root folder of the raddebugger, create a launch_raddbg.bat script and add it to your PATH.
Also add the raddebugger executable to PATH, which should be in the build\ directory after building. 
I've uploaded mine which does some simple caching, so we don't reinitialize MVSC variables every time.

Place the raddbg.lua file in your nvim config and require it. 

From your nvim buffer, you should be able to set the target

```
:RadDbgSetTarget bin\Debug\main.exe
```

And from then on, just place your cursor on the line you want to break on and run

```
:RadDbgRunHere
```

I've personally mapped it to `<leader>dh` (for Debug Here)

#### NOTE

I've dabbled with setting breakpoints and running with an already open instance of RADDBG, but
honestly, the debugger starts up so fast that it's almost like a window switch anyway. So personally,
I just close the debugger after I've done the debugging for the given breakpoint and then just
run the command again to re-open it.
