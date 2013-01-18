#!/bin/bash
source /usr/local/rvm/environments/ruby-1.8.7-p371
# or source /home/dashd/.rvm/environments/ruby-1.8.7-p371
GEMFILE=~/.designshelld-wrapper.gemfile
cat << 'EOF' > $GEMFILE
source :rubygems
gem 'designshell'
EOF
BUNDLE_GEMFILE=$GEMFILE bundle exec designshelld
rm $GEMFILE
rm $GEMFILE.'lock'
