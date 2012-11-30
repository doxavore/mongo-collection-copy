module MongoCollectionCopy
  module Finders
    class Base
      def initialize(source_coll, dest_coll)
        @source_coll = source_coll
        @dest_coll = dest_coll
      end

      def last_dest_document
        dest_coll.find().sort({'_id' => -1}).limit(1).first
      end

      def next_source_doc_to_copy
        raise NotImplementedError
      end

      private

      attr_reader :dest_coll, :source_coll

    end
  end
end
