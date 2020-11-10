CREATE TABLE test
    (
        id integer UNIQUE,
        name varchar(10)
    );
INSERT INTO test
    VALUES
        (
            1001,
            'alice'
        ),
        (
            1002,
            'bob'
        )
;