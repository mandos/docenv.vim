# Introduction

Problem I tried to resolve is to use custom environment with specific toolset
per project. I like tools like rbenv or pyenv/virtualenv/pipx but in other
hand I would like to have as clean developer's host OS as posible and I don't
want to configure toolset for every language/framework I'm working. One of
solutions is to use developers host to run vim with some common tools and rest
tools put in docker container. 

This plugin helps in managing this way of working, Based on `.docenv.json`
creates set of shims for every command to run inside containers. It manages
cycle of life for this containers. Shims are saved in folder `.docenv` in root
project.


# Requirements                                          

 * Docker (working with 18.09)
 * system application: md5sum

Note: I'm using `pwd` to locate configuration file and shims' folder, so vim should
be run from root project directory.

# Configuration                                            

To configure shims use `.docenv.json` file in root project folder. Every
container you want to use, should have separate section in configuration file. >
```javascript
  {
      "--unique name--": {
      "image": "--base image--",
          "apps": [
              "--list of command run in this container--"
          ],
          "args": [ 
              "--list of arguments added to docker run--"
          ]
      }
  }
```
  
Note: Configuration is simply translation json to VimL dictionary.

Example 
```javascript
  {
      "vim": {
          "image": "mandos22/python:3.7.3",
          "apps": ["vint"]
      },
      "terraform": {
          "image": "mandos22/terraform:0.11.13",
          "apps": ["terraform"],
          "args": [
              "--mount='type=bind,src=/tmp,dst=/tmp'"
          ]
      }
  }
```

# Commands                                                  

:DocenvRefresh      Stops all running container and recreate all shims.

