require 'mongo'

module MongoCollectionCopy
  class Copier
    attr_accessor :delete_last_dest_before_run

    def initialize(source, dest, coll_name, finder = :max_id)
      @delete_last_dest_before_run = true

      @source = Mongo::Connection.from_uri(source)
      @source_db = @source[source.split('/').last]
      @source_coll = @source_db[coll_name]

      # Always use safe writes on the dest db
      @dest = Mongo::Connection.from_uri(dest + "?safe=true")
      @dest_db = @dest[dest.split('/').last]
      @dest_coll = @dest_db[coll_name]

      case finder
      when :enumerate
        @finder = Finders::EnumerateFinder.new(@source_coll, @dest_coll)
      when :max_id
        @finder = Finders::MaxIDFinder.new(@source_coll, @dest_coll)
      else
        raise ArgumentError, "Finder not...found: #{finder}"
      end
    end

    def run
      # To ensure a clean move, delete the last item copied, as it may be corrupt
      delete_last_dest_document if delete_last_dest_before_run

      while next_doc = finder.next_source_doc_to_copy
        next_doc_id = next_doc['_id']
        res = dest_coll.update({'_id' => next_doc_id},
                               next_doc,
                               {:upsert => true})

        raise "Error saving document #{next_doc_id}" unless res['err'].nil?
      end
    end

    def total_dest_documents
      dest_coll.count
    end

    def total_source_documents
      source_coll.count
    end

    private

    attr_reader :dest_coll, :source_coll, :finder

    def delete_last_dest_document
      if doc = finder.last_dest_document
        dest_coll.remove({'_id' => doc['_id']})
      end
    end
  end
end
