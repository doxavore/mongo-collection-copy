Mongo Collection Copier
=======================

Copy collection items from one database/collection to another. This project
makes a slew of assumptions:

* You use a BSON ObjectID as the document \_id
* Your source documents are NOT updated once inserted
* You will insert source IDs in order

This makes it useful for things like GridFS, but useless for many other cases.

An inventory of what must be copied is taken at start, so it will need to be
re-run to pick up any new source documents that have been created since starting.

Usage
-----

    bundle install
    ./bin/mongo-collection-copy -s mongodb://user:pass@127.0.0.1/my_db -d mongodb://user:pass@10.1.2.3/other_db -c my_coll

If you wish to use a different collection name, you may do so after the migration:

    db.my_coll.renameCollection("new_coll_name")

To get a full list of options:

    ./bin/mongo-collection-copy --help

When specifying a finder (`-f`) your options are:
* max_id: The fastest option, it looks at the max \_id present in the destination collection and starts from there.
* enumerate: For each record in the source collection, insert into the destination collection if it isn't already present.

If you need to delete any records in the destination collection that have since been removed from the source collection:

    ./bin/mongo-collection-delete-missing -s mongodb://user:pass@127.0.0.1/my_db -D mongodb://user:pass@10.1.2.3/other_db -c my_coll
