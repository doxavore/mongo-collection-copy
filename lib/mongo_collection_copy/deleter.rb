require 'mongo'

module MongoCollectionCopy
  class Deleter
    END_OF_COLLECTION = -1

    def initialize(source, delete_from, coll_name)
      @source = Mongo::Connection.from_uri(source)
      @source_db = @source[source.split('/').last]
      @source_coll = @source_db[coll_name]

      # Always use safe writes on the delete_from db
      @delete_from = Mongo::Connection.from_uri(delete_from + "?safe=true")
      @delete_from_db = @delete_from[delete_from.split('/').last]
      @delete_from_coll = @delete_from_db[coll_name]
    end

    def next_doc_id_to_delete
      next_id = nil

      while next_id.nil?
        next_id = next_delete_from_id
        break nil if next_id == END_OF_COLLECTION

        self.current_id = next_id

        in_source_coll = source_coll.find({'_id' => next_id},
                                          {:fields => ['_id']}
                                         ).sort({'_id' => 1}).limit(1).first

        next_id = in_source_coll ? nil : next_id
      end

      next_id == END_OF_COLLECTION ? nil : next_id
    end

    def run
      while next_id = next_doc_id_to_delete
        delete_from_coll.remove({'_id' => next_id})
      end
    end

    def total_delete_from_documents
      delete_from_coll.count
    end

    def total_source_documents
      source_coll.count
    end

    private

    attr_accessor :current_id
    attr_reader :delete_from_coll, :source_coll

    # Start with the most recent and work your way back
    def next_delete_from_id
      if current_id
        query = {'_id' => {'$lt' => current_id}}
      else
        # Find the first document, if any
        query = {}
      end

      next_doc = delete_from_coll.find(query, {:fields => ['_id']}).sort({'_id' => -1}).limit(1).first
      next_doc ? next_doc['_id'] : END_OF_COLLECTION
    end

  end
end
