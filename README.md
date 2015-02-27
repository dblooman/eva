EVA
=========
Docker web control


## Running

On Boot2Docker

```
docker run --name=eva \
           -v /var/run:/var/run:rw \
           -p 8080:3000 \
           -d davey/eva
```

Visit [http://192.168.59.103:8080/](http://192.168.59.103:8080/)

### Login using
```sh
username: admin  
password: admin
```

### Screenshots
![screenshot 2015-02-14 21 25 17](https://cloud.githubusercontent.com/assets/1492067/6201130/300f4212-b490-11e4-8d2e-e6604c540fc0.png)
![screenshot 2015-02-14 21 25 20](https://cloud.githubusercontent.com/assets/1492067/6201131/3024aed6-b490-11e4-951f-12a68e577ab4.png)
