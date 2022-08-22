C game engine with lua


Cloning
=======

clone this repository recursively to get all the submodules.
Like so :

```
git clone --recurse https://github.com/fungillus/libaspergillus
```

To compile
==========

```
meson build
```

where build is a directory of your choice

Then change directory to "build" and do :

```
ninja
```

Using the "runGame" executable
============================

inside the build directory, the executable "runGame" will be available.

You have two choices at this point, either you "cd" inside a project and execute "runGame"
or you can execute :

```
runGame <path to project directory>
```
