# Quick config that allows a "Run To Here" functionality from inside Neovim in RADDBG.

### Setup
Install the RADDBG debugger to a desired directory from here: https://github.com/EpicGamesExt/raddebugger.
After it's built, go into the build directory and create a launch_raddbg.bat file. I've uploaded mine here.
Add the raddebugger build\ directory to PATH.

Place the raddbg.lua file in your nvim config and require it. 

From your nvim buffer, you should be able to set the target *relative* to your neovim buffer!
This is important, as I'm resolving the absolute path from it.

```
:RadDbgSetTarget ..\bin\Debug\main.exe
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
