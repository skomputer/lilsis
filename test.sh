#!/bin/bash

RAILS_ENV=test bundle exec spring rspec "$@"
