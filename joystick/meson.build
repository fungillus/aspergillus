#project('libjoystick', 'c')

#cc = meson.get_compiler('c')

libjoystick = static_library('libjoystick', ['epoll.c', 'joystick.c'])

libjoystickPath = include_directories('.')

executable('joystick_test', ['main.c'], link_with: [libjoystick])
