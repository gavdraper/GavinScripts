CREATE TABLE named_constraints
(
	id int NOT NULL IDENTITY (1, 1),
	added_by int NOT NULL,
	person_id int NOT NULL,
	[date] datetime NOT NULL CONSTRAINT df_table_default DEFAULT GETDATE(),
	CONSTRAINT pk_table_id PRIMARY KEY CLUSTERED(Id),
	CONSTRAINT fk_table_added_by FOREIGN KEY (added_by) REFERENCES [user](id),
)

