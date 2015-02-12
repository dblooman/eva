EVA
=========
Docker web control


## Running

Start redis

```sh
redis-server
```

Start worker

```sh
sidekiq -r./lib/worker.rb
```

Start server

```sh
bundle exec thin start
```

Visit [http://localhost:3000](http://localhost:3000)

Sidekiq server [http://localhost:3000/sidekiq](http://localhost:3000/sidekiq)
