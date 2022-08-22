C game engine with lua


Cloning
=======

```
clone this repository recursively to get all the submodules.
```

git clone --recurse https://github.com/fungillus/libaspergillus

To compile
==========

```
meson build
```

where build is a directory of your choice

Then change directory to build and do

```
ninja
```

Running the example codes
========================

inside the build directory, the executable "runGame" will be available.

You have two choices at this point, either you "cd" inside a project and execute "runGame"
or you execute

```
runGame <path to project directory>
```
