var databases = [
	{
		name: "datasets",
		collections: [
			{
				name: "datasets",
				index: [
					{ condition: '{"current.is_based_on.id": 1}', options: '{}' },
					{ condition: '{"next.is_based_on.id": 1}', options: '{}' }
				]
			},
			{
				name: "editions",
				index: [
					{ condition: '{"current.links.dataset.id": 1, "current.edition": 1, "current.state": 1}', options: '{}' },
					{ condition: '{"next.links.dataset.id": 1, "next.edition": 1}', options: '{}' }
				]
			},
			{
				name: "instances",
				index: [
					{ condition: '{"links.dataset.id": 1, "edition": 1, "version": 1, "state": 1}', options: '{}' },
					{ condition: '{"state": 1}', options: '{}' },
					{ condition: '{"id": 1, "import.tasks.build_hierarchies.dimension_name": 1}', options: '{}' },
					{ condition: '{"id": 1, "import.tasks.build_search_indices.dimension_name": 1}', options: '{}' }
				]
			},
			{ name: "instances_locks" },
			{
				name: "versions",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			},
			{
				name: "dimension.options",
				index: [
					{ condition: '{"instance_id": 1, "name": 1, "option": 1}', options: '{}' }
				]
			},
			{ name: "contacts" }
		]
	},
	{
		name: "recipes",
		collections: [{ name: "recipes" }]
	},
	{
		name: "filters",
		collections: [
			{
				name: "filters",
				index: [
					{ condition: '{"filter_id": 1}', options: '{}' },
					{ condition: '{"id": 1}', options: '{}' }
				]
			},
			{
				name: "filterOutputs",
				index: [
					{ condition: '{"filter_id": 1}', options: '{}' },
					{ condition: '{"id": 1}', options: '{}' }
				]
			}
		]
	},
	{
		name: "imports",
		collections: [
			{
				name: "imports",
				index: [
					{ condition: '{"id": 1}', options: '{}' },
					{ condition: '{"state": 1, "id": 1}', options: '{}' }
				]
			},
			{
				name: "imports_locks",
				index: [
					{ condition: '{"resource": 1}', options: '{"unique": true}' },
					{ condition: '{"exclusive.LockId": 1}', options: '{}' },
					{ condition: '{"exclusive.ExpiresAt": 1}', options: '{}' },
					{ condition: '{"shared.locks.LockId": 1}', options: '{}' },
					{ condition: '{"shared.locks.ExpiresAt": 1}', options: '{}' }
				]
			}
		]
	},
	{
		name: "topics",
		collections: [
			{
				name: "topics",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			},
			{
				name: "content",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			}
		]
	},
	{
		name: "search",
		collections: [
			{
				name: "jobs",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			},
			{
				name: "jobs_locks",
				index: [
					{ condition: '{"id": 1}', options: '{}' },
					{ condition: '{"resource": 1}', options: '{}' },
					{ condition: '{"exclusive.LockId": 1}', options: '{}' },
					{ condition: '{"exclusive.ExpiresAt": 1}', options: '{}' },
					{ condition: '{"shared.locks.LockId": 1}', options: '{}' },
					{ condition: '{"shared.locks.ExpiresAt": 1}', options: '{}' }
				]
			},
			{
				name: "tasks",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			}
		]
	},
	{
		name: "images",
		collections: [
			{
				name: "images",
				index: [
					{ condition: '{"id": 1}', options: '{}' },
					{ condition: '{"collection_id": 1}', options: '{}' }
				]
			},
			{
				name: "images_locks",
				index: [
					{ condition: '{"resource": 1}', options: '{}' },
					{ condition: '{"exclusive.LockId": 1}', options: '{}' },
					{ condition: '{"exclusive.ExpiresAt": 1}', options: '{}' },
					{ condition: '{"shared.locks.LockId": 1}', options: '{}' },
					{ condition: '{"shared.locks.ExpiresAt": 1}', options: '{}' }
				]
			}
		]
	},
	{
		name: "files",
		collections: [
			{
				name: "metadata",
				index: [
					{ condition: '{"id": 1}', options: '{}' },
					{ condition: '{"collection_id": 1}', options: '{}' },
					{ condition: '{"path": 1}', options: '{"unique": true}' }
				]
			},
			{
				name: "collections",
				index: [
					{ condition: '{"id": 1}', options: '{"unique": true}' }
				]
			},
			{ 
				name: "bundles",
				index: [
					{ condition: '{"id": 1}', options: '{"unique": true}' }
				] 
			}
		]
	},
	{
		name: "permissions",
		collections: [
			{
				name: "roles",
				index: [
					{ condition: '{"id": 1}', options: '{}' }
				]
			},
			{ name: "policies" }
		]
	},
	{
		name: "bundles",
		collections: [
			{ 
				name: "bundles",
				index: [
					{ condition: '{"id": 1}', options: '{"unique": true}' }
				] 
			},
			{ 
				name: "bundle_events",
				index: [
					{ condition: '{"id": 1}', options: '{"unique": true}' }
				] 
			},
			{ 
				name: "bundle_contents",
				index: [
					{ condition: '{"id": 1}', options: '{"unique": true}' }
				] 
			}
		]
	}
];

for (database of databases) {
    db = db.getSiblingDB(database.name);

    for (collection of database.collections){
        db.createCollection(collection["name"]);
    
        if (collection["index"]) {
            for (index of collection["index"]){
				printjson(index)
                results = db[collection["name"]].createIndex(JSON.parse(index["condition"]), JSON.parse(index["options"]))
				printjson(results);
            }
        }
    }
}

db = db.getSiblingDB("bundles");
db.bundle_events.find({}).forEach(function(doc) {
    if (typeof doc.created_at === "string") {
        db.bundle_events.updateOne(
            {_id: doc._id},
            {$set: {"created_at": new ISODate(doc.created_at)}}
        );
    }
});
