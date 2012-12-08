module MongoCollectionCopy
  module Finders
    class MaxIDFinder < Base

      def next_source_doc_to_copy
        if mdid = max_dest_id
          if first_doc
            # On the first query, re-update the last record imported
            query = {'_id' => mdid}
            self.first_doc = false
          else
            query = {'_id' => {'$gt' => mdid}}
          end
        else
          query = {}
        end

        source_coll.find(query).sort({'_id' => 1}).limit(1).first
      end

      private

      def find_max_id(collection)
        cursor = collection.find({}, {:fields => ['_id']}).sort({'_id' => -1}).limit(1)
        extract_first_value(cursor, '_id')
      end

      def extract_first_value(cursor, field = '_id')
        result = cursor.first
        result ? result[field] : nil
      end

      def max_dest_id
        find_max_id(dest_coll)
      end

    end
  end
end
