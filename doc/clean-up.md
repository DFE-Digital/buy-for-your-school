# Clean-up

## Kill running containers and volumes

The following command can be run to stop any running Docker containers and remove all volumes used by the databases.

- From within project root `$ docker-compose down -v --remove-orphans`

## Clear Sidekiq queues

The following task clears all Sidekiq queues, scheduled jobs, retries, and dead jobs in development.

- From within project root `$ bundle exec rails sidekiq:clear`
