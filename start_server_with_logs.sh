cd /home/ubuntu/IntegrarPlus
source ~/.rvm/scripts/rvm
export RAILS_ENV=production
source bin/setup-db
bundle exec rails server -e production -p 3001 2>&1 | tee -a log/production.log
