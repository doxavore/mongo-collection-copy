module MongoCollectionCopy
  module Finders
    class Base
      def initialize(source_coll, dest_coll)
        @source_coll = source_coll
        @dest_coll = dest_coll
        @first_doc = true
      end

      def next_source_doc_to_copy
        raise NotImplementedError
      end

      private

      attr_accessor :first_doc
      attr_reader :dest_coll, :source_coll

    end
  end
end
