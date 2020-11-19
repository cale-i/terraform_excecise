-- CREATE USER testuser WITH PASSWORD 'password';
ALTER ROLE testuser SET client_encoding TO 'utf8';
ALTER ROLE testuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE testuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;

-- for test
ALTER USER testuser CREATEDB;

CREATE TABLE test(
        id integer UNIQUE,
        name varchar(10)
);

INSERT INTO test VALUES
    (
        1001,
        'alice'
    ),
    (
        1002,
        'bob'
    );

-- INSERT INTO book VALUES(
--     '2596a762-7c07-4974-85cf-4293af4c0312',
--     'title1',
--      1000,
--     '2020-10-22'
-- );