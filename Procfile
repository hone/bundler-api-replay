web: bundle exec puma -e $RACK_ENV -p $PORT
worker: bundle exec sidekiq -r ./lib/bundler_api_replay/job.rb -c $SIDEKIQ_THREAD_NUM
