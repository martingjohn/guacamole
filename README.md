# guacamole

This is a stand alone Guacamole (https://guacamole.incubator.apache.org/) build with the config saved in a configuration xml file rather than a database and UK keymap included

Put your config XML in "config" directory and mount empty "data" directory for file transfers, in user-mapping.xml use the following

    <param name="enable-drive">true</param>
    <param name="drive-path">/file-transfer</param>

To use UK keyboard

    <param name="server-layout">en-gb-qwerty</param>

Start with

    docker run \
       -it \
       --name guac \
       --rm \
       -p 8080:8080 \
       -v ${PWD}/config:/etc/guacamole \
       -v ${PWD}/data:/file-transfer \
       martinjohn/guacamole:latest

Then connect to docker server http://docker:8080/remote
