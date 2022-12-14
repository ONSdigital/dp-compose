var databases = [
	{
		name: "interactives",
		collections: [
			{
				"name": "metadata",
				"index": [
					{
						"condition": '{"metadata.resource_id": 1}',
						"options": '{"background":true, "unique": true}'
					}
				]
		    }
		]
	},
	{
		name: "datasets",
		collections: [
			{"name": "datasets"}, {"name":"contacts"}, {"name":"editions"}, {"name":"instances"}, {"name":"dimension.options"}, {"name":"instances_locks"}]
	},
	{
		name: "recipes",
		collections: [{"name":"recipes"}]
	},
	{
		name: "filters",
		collections: [{"name":"filters"}, {"name":"filterOutputs"}]
	},
	{
		name: "imports",
		collections: [{"name":"imports"}]
	},
	{
		name: "topics",
		collections: [{"name":"topics"}, {"name":"content"}]
	},
	{
		name: "search",
		collections: [{"name":"jobs"}, {"name":"jobs_locks"}]
	},
	{
		name: "images",
		collections: [{"name":"images_locks"}]
	},
	{
		name: "files",
		collections: [{"name":"metadata"}]
	},
    {
		name: "images",
		collections: [{"name":"images"}]
	},
	{
        name: "permissions",
        collections: [{"name":"roles"}, {"name":"policies"}]
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
