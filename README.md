# bundler-api-replay
This project is a web app that receives syslog drains via HTTP and then it replays the traffic to other web apps.

## Dependencies
* PostreSQL
* Foreman (development)

## Setup
First, you'll need to create a database to use and set the `DATABASE_URL` in your environment.

    bundle install --binstubs bin/
    bin/sequel -m db/migrations $DATABASE_URL

Next, we'll setup the environment for use with foreman. There's a sample env provided that you can just edit.

    cp .env.sample .env
    # edit .env

To start the web server we can just use foreman.

    foreman start

## Tests
The tests will require a separate test database. You'll need to create that and set `TEST_DATABASE_URL` in your environment and add it to your `.env` file. We'll need to run the migrations on the test database.

    bin/sequel -m db/migrations $TEST_DATABASE_URL

We can now run the tests

    foreman run bin/rake spec
