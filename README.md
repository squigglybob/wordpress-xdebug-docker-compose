# README

This setup is a hash of several other things I've found to get a docker multisite setup that worked for running, devving and debugging wordpress.

Including https://github.com/wpdiaries/wordpress-xdebug for the wordpress and xdebug container

It is currently setup for a multisite wp, so environment variables `WORDPRESS_CONFIG_*` would need to be changed to match your environment.

## Wordpress setup with Xdebug enabled

To quickly setup wordpress from another wp clone.

1. Download a mysql dump into a tables folder
2. Create a folder called `wordpress` in the root.
3. Add the .htaccess file into the `wordpress` folder
4. Create folders `wordpress/wp-content/plugins` and `wordpress/wp-content/themes`
5. Make sure that the WP and PHP match the versions of the clone in `xdebug/Dockerfile`
6. Edit `loadDB.sh` to point correctly to your mysql dump
7. Edit `loadDB.sh` to change any urls in the db to match the url of `yoursite.url` that you want to use on your local dev environment
8. Edit `loadDB.sh` to change the container names to your container names
9. Run `./loadDB.sh` to load the database into the db using the wp-cli and do a search and replace for the urls

## Start the containers

Run `docker compose build` to pull down the containers and build the xdebug container locally

Run `docker compose up -d` to start the containers in detached mode

Run without `-d` so that you can check the logs if there are any errors in the setup

Current addresses for the containers are

|container| address|
|wordpress| 5000|
|mailhog|5025|
|phpmyadmin|5081|

Wordpress will be installed in a folder called `wordpress`

## Devving in the container

In order to be able to edit files within wp-content you will need to set the permissions correctly.

This could probably be done in several ways, but I've found works is this.

* All folders within wordpress with permissions 775 and be owned by www-data <yourusername>
* All files within wp-content to have permissions 664 and also be owned by www-data <yourusername>

Then make sure that the user <yourusername> is in the www-data group

This way wordpress can still edit the files within the folders which enables WP to be able to update from within wp-admin and also for wordpress to be able to install plugins from within wp-admin.

It also means that you are able to work on plugins and themes too.

## Using Xdebug with vscode.

The launch.json file in .vscode at the root uses the same port number as the xdebug setup.

I changed the port number from the default 9003 so that it wouldn't clash with my host debugger.

1. Launch the debugger in vscode.
2. Trigger the debugger when loading a page in WP

The setup is currently set to only start debugging if a trigger is present in the PHP request from the browser.

I use Xdebug helper plugin in chrome/brave to trigger the debug when desired (otherwise pages can run really slowly or trigger debug points when you don't need/want it to). The plugin adds a cookie `XDEBUG_SESSION=XDEBUG_ECLIPSE` which triggers debug mode.

## Wordpress Multisite

In order to use multisite locally with a named domain I have setup a reverse proxy on my host apache setup

```apacheconf
<VirtualHost *:80>

        ProxyRequests Off
        ProxyPreserveHost On

        RewriteEngine On

        RewriteRule ^/(.*) http://localhost:5000/$1 [proxy,last]
        ProxyPassReverse / http://localhost:5000/

        ServerName yoursite.url

        <Proxy http://localhost:5000>

                Require all granted

                Options None

                ProxySet enablereuse=on

        </Proxy>

</VirtualHost>
```

and a line in the `/etc/hosts` file

```
127.0.0.1       yoursite.url
```
