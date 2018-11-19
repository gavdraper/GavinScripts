CREATE TABLE online_identity_code_access
(
	id int NOT NULL IDENTITY (1, 1),
	user_requesting_access int NOT NULL,
	person_id int NOT NULL,
	[date] datetime NOT NULL CONSTRAINT df_online_identity_code_access_date DEFAULT GETDATE(),
	CONSTRAINT pk_online_identity_code_access PRIMARY KEY CLUSTERED(Id),
	CONSTRAINT fk_online_identity_code_access_person FOREIGN KEY (person_id) REFERENCES person(id),
	CONSTRAINT fk_online_identity_code_access_user FOREIGN KEY (user_requesting_access) REFERENCES [user](id),
)

