--	storeindex.sql
--
--	storeindex database schema
--
--	required fields and constraints are marked with (*), do not change
--	IF NOT EXISTS preserves existing objects when executed at each startup
--	existing databases require an explicit migration or storeindex rebuild

--------------------------------------------------------------------------------
--	sources of news items, identified by the source code in the filename

CREATE TABLE IF NOT EXISTS source (
	id			INTEGER		PRIMARY KEY,			-- internal source id (*)
	name		TEXT		NOT NULL UNIQUE			-- source code, e.g. leni (*)
);

--------------------------------------------------------------------------------
--	successfully indexed news items and their extracted fields

CREATE TABLE IF NOT EXISTS item (
	id				INTEGER		PRIMARY KEY,		-- internal item id, also FTS rowid (*)
	source			INTEGER		NOT NULL 			-- owning source (*)
								REFERENCES source(id),
	published_at	INTEGER		NOT NULL 			-- epoch time from filename (*)
								CHECK (published_at >= 0),
	suffix			INTEGER		NOT NULL 			-- suffix counter from filename (*)
								CHECK (suffix >= 0),

	-- 	user-defined fields for extracted content start here
	dispatch_at 	INTEGER		NOT NULL 			-- effective dispatch time, with update_at fallback
								CHECK (dispatch_at >= 0),
	src_id			INTEGER		NOT NULL,			-- source document id from JSON id
	src_rev			INTEGER		NOT NULL,			-- source document revision from JSON rev
	headline		TEXT,							-- unchanged source headline
	service			TEXT,							-- source service from data.svc_name

	UNIQUE (source, src_id, src_rev),				-- one entry per source document revision
	UNIQUE (source, published_at, suffix)			-- news item identity (*)
);

--------------------------------------------------------------------------------
--	application-specific indexes, extend as needed
--	publication times support chronological queries and rebuild cutoffs

CREATE INDEX IF NOT EXISTS item_published_at ON item(published_at);
CREATE INDEX IF NOT EXISTS item_dispatch_at ON item(dispatch_at);

--------------------------------------------------------------------------------
--	field keyword uses keyword(id,value) and item_keyword(item,keyword,position)
--	follow docs/schema-contract.md when extending the schema

CREATE TABLE IF NOT EXISTS keyword (
	id 				INTEGER 	PRIMARY KEY,
	value 			TEXT 		NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS item_keyword (
	item 			INTEGER 	NOT NULL
								REFERENCES item(id) ON DELETE CASCADE,
	keyword 		INTEGER 	NOT NULL
								REFERENCES keyword(id) ON DELETE RESTRICT,
	position 		INTEGER 	NOT NULL
								CHECK (position >= 0),

	PRIMARY KEY (item, position),
	UNIQUE (item, keyword)
);

CREATE INDEX IF NOT EXISTS item_keyword_keyword ON item_keyword(keyword);

--------------------------------------------------------------------------------
--	field channel uses channel(id,value) and item_channel(item,channel,position)

CREATE TABLE IF NOT EXISTS channel (
	id 				INTEGER 		PRIMARY KEY,
	value 			TEXT 			NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS item_channel (
	item 			INTEGER 	NOT NULL
								REFERENCES item(id) ON DELETE CASCADE,
	channel 		INTEGER 	NOT NULL
								REFERENCES channel(id) ON DELETE RESTRICT,
	position 		INTEGER 	NOT NULL
								CHECK (position >= 0),
	PRIMARY KEY (item, position),
	UNIQUE (item, channel)
);

CREATE INDEX IF NOT EXISTS item_channel_channel ON item_channel(channel);

--------------------------------------------------------------------------------
--	field location stores ordered source dateline places

CREATE TABLE IF NOT EXISTS location (
	id INTEGER PRIMARY KEY,
	value TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS item_location (
	item INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
	location INTEGER NOT NULL REFERENCES location(id) ON DELETE RESTRICT,
	position INTEGER NOT NULL CHECK (position >= 0),
	PRIMARY KEY (item, position),
	UNIQUE (item, location)
);

CREATE INDEX IF NOT EXISTS item_location_location ON item_location(location);

--------------------------------------------------------------------------------
--	full-text index with text stored in item, synchronized by the triggers below
--	index existing rows with INSERT INTO item_fts(item_fts) VALUES ('rebuild')

CREATE VIRTUAL TABLE IF NOT EXISTS item_fts
	USING fts5(
		headline,													 -- searchable headline from item.headline
		content='item',											 -- external content table
		content_rowid='id'												 -- FTS rowid equals item.id
	);

--------------------------------------------------------------------------------
--	add the new headline to the full-text index

CREATE TRIGGER IF NOT EXISTS item_insert AFTER INSERT ON item
BEGIN
	INSERT INTO item_fts(rowid, headline) VALUES (new.id, new.headline);
END;

--------------------------------------------------------------------------------
--	remove the old headline using the FTS delete command and its original text

CREATE TRIGGER IF NOT EXISTS item_delete AFTER DELETE ON item
BEGIN
	INSERT INTO item_fts(item_fts, rowid, headline)
		VALUES ('delete', old.id, old.headline);
END;

--------------------------------------------------------------------------------
--	replace the indexed headline when a news item's stored result changes

CREATE TRIGGER IF NOT EXISTS item_update AFTER UPDATE ON item
BEGIN
	INSERT INTO item_fts(item_fts, rowid, headline)
		VALUES ('delete', old.id, old.headline);
	INSERT INTO item_fts(rowid, headline) VALUES (new.id, new.headline);
END;
