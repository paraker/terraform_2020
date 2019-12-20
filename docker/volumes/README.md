# Docker volumes

We can mount volumes to docker containers.
we can specify a chosen mount points.

## Creating a volume
Very simple code. We can probably specify a whole lot more parameters here if we want?

    resource "docker_volume" "mysql_data_volume" {
      name = "mysql_data"
    }
    
## Mount a volume to a container
Provide a reference to the volume's name.
And provide a mount point as per the "container_path" variable

    resource "docker_container" "mysql_container" {
      image = "${docker_image.mysql_image.name}"
      name = "ghost_database"
    
      volumes {
        volume_name = "${docker_volume.mysql_data_volume.name}"
        container_path = "/var/lib/mysql"  # path we are mounting this volume to
      }
    
## How do we know that the container stores data on the volume?
Well first we can inspect our volume with docker volume inspect "name".
This is really helpful as it prints out what the local mountpoint is on our host system, in the Mountpoint variable.

    docker volume inspect mysql_data       
    [
        {
            "CreatedAt": "2019-12-06T04:40:04Z",
            "Driver": "local",
            "Labels": null,
            "Mountpoint": "/var/lib/docker/volumes/mysql_data/_data",
            "Name": "mysql_data",
            "Options": null,
            "Scope": "local"
        }
    ]
 
 So now, we can do a sudo ls on /var/lib/docker/volumes/mysql_data/_data to see what files that exist on the volume.
 Well I can't at the moment because I'm not connected to internet so I can't download the docker images to do this.
 But you should see files from mysql in that directory.