CREATE TABLE Repo (
    id INT NOT NULL,
    provider varchar(255) NOT NULL,
    user varchar(255) NOT NULL,
    repo varchar(255) NOT NULL,
    active boolean DEFAULT true,
    PRIMARY KEY (id),
    UNIQUE (provider, user, repo)
);

CREATE TABLE Build (
    num int NOT NULL,
    repo int NOT NULL,
    status int NOT NULL,
    logs TEXT,
    PRIMARY KEY (num, repo),
    FOREIGN KEY (repo) REFERENCES Repo(id)
);


