/*
 * Empties all non-system collections in the current database without dropping them.
 * Usage (mongosh):
 *   mongosh <connection_string>/<database_name> --file ../../provisioning/mongo/reset.js
 */

const database = db;
const databaseName = database.getName();
const collections = database.getCollectionNames();

print("resetting collections in database:", databaseName);

collections.forEach((name) => {
	if (name.startsWith("system.")) {
		return;
	}

	const collection = database.getCollection(name);
	const result = collection.deleteMany({});
	print(`emptied ${databaseName}.${name}: ${result.deletedCount} documents deleted`);
});

print("reset complete");
