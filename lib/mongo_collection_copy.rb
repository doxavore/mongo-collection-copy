$:.unshift File.expand_path('../', __FILE__)

require 'mongo_collection_copy/finders/base'
require 'mongo_collection_copy/finders/enumerate_finder'
require 'mongo_collection_copy/finders/max_id_finder'
require 'mongo_collection_copy/copier'
require 'mongo_collection_copy/deleter'
