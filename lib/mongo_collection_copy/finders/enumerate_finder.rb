module MongoCollectionCopy
  module Finders
    class EnumerateFinder < Base
      END_OF_COLLECTION = -1

      def next_source_doc_to_copy
        nid = nil

        # Find the first ID that doesn't exist in the destination collection
        while nid.nil?
          nid = next_id
          break if nid == END_OF_COLLECTION

          if dest_coll.find({'_id' => nid}, {:fields => ['_id']}).limit(1).first
            self.current_id = nid
            nid = nil
          end
        end

        if nid != END_OF_COLLECTION
          if first_doc
            # On the first query, re-update the last record imported
            doc = source_coll.find({'_id' => current_id}).limit(1).first
            # Don't set current_id and let the next query do that
            self.first_doc = false
          else
            doc = source_coll.find({'_id' => nid}).limit(1).first
            # Store our current position
            self.current_id = nid
          end
        else
          nil
        end
      end

      private

      attr_accessor :current_id

      def next_id
        if current_id
          query = {'_id' => {'$gt' => current_id}}
        else
          # Find the first document, if any
          query = {}
        end

        next_doc = source_coll.find(query, {:fields => ['_id']}).sort({'_id' => 1}).limit(1).first
        next_doc ? next_doc['_id'] : END_OF_COLLECTION
      end

    end
  end
end
