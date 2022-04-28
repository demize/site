---
title: "Running Atom in Docker"
date: 2018-09-22T19:27:49-04:00
description: "Quick guide for running Atom in Docker"
---

## Introduction

I discussed on Twitter a while ago one of the difficulties I'm having running
the musl version of Void Linux: some applications just don't work on musl. Text
editors, specifically. I normally use Sublime, but it being a proprietary editor
means that it won't work on musl without the developers adding support (which is
something they've been asked to do a few times, with no response ever given).
So I tried to use Atom, which is open source! Except it completely obfuscates
the process of downloading dependencies to the point that it *deletes them* when
the build finishes, even if it finished by failing, and one dependency uses the
`basename` function in a way that doesn't work on musl. The fix for that would
actually be pretty easy... if I could actually edit the dependency. I eventually
decided to try Kate, which doesn't seem like a bad text editor, but just isn't
what I'm used to. I then didn't ever really use it, because I only run Void on
my laptop, and I haven't actually sat down to work on the project I'm working on
in a while.

But today I wanted to write a post here about an issue I ran into this week, and
I figured I could use this laptop for that instead of rebooting my desktop to
Ubuntu just to write a blog post. And then when I actually sat down to start
writing that, I didn't even open Kate; I spent most of today trying to a) make
a desktop environment other than xfce work (I'm on cinnamon now) and b) find and
build a text editor that might be closer to what I'm used to. When that didn't
work, I tried to set up a glibc chroot and run Sublime, or Atom, or any of the
other editors I tried in that; that also didn't work for any of them. But one
editor I tried had instructions to run it in Docker, and though that didn't
work, I decided to see if there was any way to do that with Atom. And there is!

## Running Atom in Docker

Turns out that James Netherton has already created a [public Docker container](https://hub.docker.com/r/jamesnetherton/docker-atom-editor/)
that lets you run Atom in Docker. The README, however, is somewhat lacking, and
didn't actually work for me, so here's what I found works:

1. Install Docker (on Void, with `sudo xbps-install -S docker`).
2. If you want things to be slightly easier, add yourself to the docker group.
   On Void, use `usermod -aG docker your_username`. This is obviously a security
   risk and, given how the Docker container is set up, should be wholly
   unnecessary. I, however, threw security to the wind and added myself anyway.
   Should you have any issues trying to do this while running Docker with sudo,
   I'd be glad to try and help solve them.
3. Add yourself to the xhost access list, so that the container can open a
   window on your physical machine: `xhost +SI:localuser:$USER`.
4. If you're on a system that doesn't have systemd, then add these lines to your
   /etc/rc.local (and either run them or reboot):

      ```
      mkdir /sys/fs/cgroup/systemd
      mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
      ```

      This is necessary for Docker to work at all; otherwise it will error out.
5. Pull the Docker container: `docker pull jamesnetherton/docker-atom-editor`.
6. Create and start the Docker container:
   ```
   docker run -d --name atom \
             --user=$(id -u) \
             --env="DISPLAY" \
             --workdir="$HOME" \
             --volume="$HOME:$HOME" \
             --volume="/etc/group:/etc/group:ro" \
             --volume="/etc/passwd:/etc/passwd:ro" \
             --volume="/etc/shadow:/etc/shadow:ro" \
             --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
             --volume="/dev/shm:/dev/shm" \
             jamesnetherton/docker-atom-editor
   ```
   This does a few things that the command in the README doesn't:

      1. Override the user specified in the Dockerfile to be yourself
      2. Mount your home directory in the container so that you can edit all your
      files (and keep the Atom config files persistent). You can change what you
      mount here, but keep if you do want to further limit what you mount, make
      sure you at least mount your .atom directory to `$HOME/.atom`, otherwise
      you'll lose configuration persistence. In my situation, I'm fine mapping my
      entire home directory since I have nothing sensitive on this laptop, but if
      you have your own concerns this is the most flexible part of the setup.
      3. Mount the group/passwd/shadow/X11 files from your system to the container,
      in order for a) permissions to make sense and b) allow step 3 to work (per
      [the Open Source Robotics Foundation](http://wiki.ros.org/docker/Tutorials/GUI)).

   The README works, but only if you turn off access control to your X server
   and do some other mapping to be able to open files and store your config
   (and the command in the README might require some fudging of permissions if
   you aren't user 1000).
7. That's it! Atom should open and you should be able to browse your home
   folder. When you close Atom, it will stop the Docker container. To relaunch
   Atom, you'll only need to run `docker start atom`.
8. (Added the day after I published this post) If you reboot, then your X server
   shuts down, and if your X server shuts down, the access control changes you
   made with `xhost` are lost. To solve that, either re-run
   `xhost +SI:localuser:$USER` every time you reboot, or make it happen when X
   starts: `echo "xhost +SI:localuser:$USER" >> ~/.xprofile`. This still isn't
   a big security concern; it only allows your user, with your credentials, to
   connect to the X server.

This is, as far as I can tell, probably the most secure way to run this Docker
container. You don't open your X11 server up to connections from anywhere, which
was a big issue with the only instructions I could find for running this, and
you still get a working installation of Atom where it otherwise wouldn't work.
If you run into any issues, feel free to reach out on Twitter and I can try to
help you with them.
