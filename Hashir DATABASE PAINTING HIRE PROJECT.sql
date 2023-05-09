--Hashir
--22816
CREATE TABLE customer (
    customer_no          INT NOT NULL,
    customer_name        VARCHAR(255) NOT NULL,
    customer_address     VARCHAR(255),
    customer_cat         CHAR CHECK ( customer_cat = 'S'
                              OR customer_cat = 'B'
                              OR customer_cat = 'G'
                              OR customer_cat = 'P' ),
    customer_description VARCHAR(255),
    customer_discount    INT,
    PRIMARY KEY ( customer_no )
);

CREATE TABLE painting (
    painting_no    INT NOT NULL,
    painting_title VARCHAR(255) NOT NULL,
    painting_theme VARCHAR(255),
    PRIMARY KEY ( painting_no )
);

CREATE TABLE rental_report (
    customer_no   INT NOT NULL,
    painting_no   INT NOT NULL,
    date_of_hire  DATE NOT NULL,
    date_due_back DATE NOT NULL,
    returned      CHAR CHECK ( returned = 'Y'
                          OR returned = 'N' ),
    FOREIGN KEY ( customer_no )
        REFERENCES customer ( customer_no ),
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no ),
    PRIMARY KEY ( customer_no,
                  painting_no )
);

CREATE TABLE artist (
    artist_no        INT NOT NULL,
    artist_name      VARCHAR(255) NOT NULL,
    country_of_birth VARCHAR(255),
    year_of_birth    INT,
    year_of_death    INT,
    age              INT,
    PRIMARY KEY ( artist_no )
);

CREATE TABLE owner (
    owner_no        INT NOT NULL,
    owner_name      VARCHAR(255) NOT NULL,
    owner_address   VARCHAR(555),
    onwer_telephone INT,
    PRIMARY KEY ( owner_no )
);

CREATE TABLE artist_report (
    painting_no INT NOT NULL,
    artist_no   INT NOT NULL,
    owner_no    INT NOT NULL,
    price       INT NOT NULL,
    FOREIGN KEY ( owner_no )
        REFERENCES owner ( owner_no ),
    FOREIGN KEY ( artist_no )
        REFERENCES artist ( artist_no ),
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no ),
    PRIMARY KEY ( artist_no,
                  painting_no )
);

CREATE TABLE return_owner (
    painting_no INT NOT NULL,
    owner_no    INT NOT NULL,
    return_date DATE NOT NULL,
    FOREIGN KEY ( owner_no )
        REFERENCES owner ( owner_no ),
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no ),
    PRIMARY KEY ( owner_no,
                  painting_no )
);

CREATE TABLE owner_report (
    painting_no INT NOT NULL,
    owner_no    INT NOT NULL,
    FOREIGN KEY ( owner_no )
        REFERENCES owner ( owner_no ),
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no ),
    PRIMARY KEY ( owner_no,
                  painting_no )
);

CREATE TABLE painting_price (
    painting_no INT NOT NULL,
    price       INT NOT NULL,
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no )
);

CREATE TABLE painting_rented (
    painting_no INT NOT NULL,
    available   CHAR NOT NULL,
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no )
);

CREATE TABLE last_rented (
    painting_no INT NOT NULL,
    rent_date   DATE NOT NULL,
    FOREIGN KEY ( painting_no )
        REFERENCES painting ( painting_no )
);

CREATE OR REPLACE PROCEDURE add_artist (
    no      INT,
    name    artist.artist_name%TYPE,
    country artist.country_of_birth%TYPE,
    yob     artist.year_of_birth%TYPE,
    yod     VARCHAR
) IS
BEGIN
    IF yod IS NULL THEN
        INSERT INTO artist VALUES (
            no,
            name,
            country,
            yob,
            CAST((yod) AS INT),
            CAST(((EXTRACT(YEAR FROM sysdate) - yob)) AS INT)
        );

    ELSE
        INSERT INTO artist VALUES (
            no,
            name,
            country,
            yob,
            yod,
            CAST(((yod - yob)) AS INT)
        );

    END IF;
END;

CREATE OR REPLACE PROCEDURE add_artist_report (
    n1 INT,
    n2 INT,
    n3 INT
) IS
    pp INT;
BEGIN
    SELECT
        price
    INTO pp
    FROM
        painting_price
    WHERE
        painting_no = n1;

    INSERT INTO artist_report VALUES (
        n1,
        n2,
        n3,
        pp
    );

END;

CREATE OR REPLACE PROCEDURE add_customer (
    no      INT,
    name    customer.customer_name%TYPE,
    address customer.customer_address%TYPE,
    cat     customer.customer_cat%TYPE
) IS
BEGIN
    IF cat = 'B' THEN
        INSERT INTO customer VALUES (
            no,
            name,
            address,
            cat,
            'BRONZE',
            0
        );

    ELSIF cat = 'S' THEN
        INSERT INTO customer VALUES (
            no,
            name,
            address,
            cat,
            'SILVER',
            5
        );

    ELSIF cat = 'G' THEN
        INSERT INTO customer VALUES (
            no,
            name,
            address,
            cat,
            'GOLD',
            25
        );

    ELSIF cat = 'P' THEN
        INSERT INTO customer VALUES (
            no,
            name,
            address,
            cat,
            'PLATINIUM',
            50
        );

    END IF;
END;

CREATE OR REPLACE PROCEDURE add_owner (
    no      INT,
    name    owner.owner_name%TYPE,
    address owner.owner_address%TYPE,
    age     owner.onwer_telephone%TYPE
) IS
BEGIN
    INSERT INTO owner VALUES (
        no,
        name,
        address,
        age
    );

END;

CREATE OR REPLACE PROCEDURE add_painting (
    n1    INT,
    no    INT,
    title painting.painting_title%TYPE,
    theme painting.painting_theme%TYPE,
    price painting_price.price%TYPE,
    own   INT
) IS
BEGIN
    INSERT INTO painting VALUES (
        no,
        title,
        theme
    );

    INSERT INTO painting_price VALUES (
        no,
        price
    );

    INSERT INTO owner_report VALUES (
        no,
        own
    );

    INSERT INTO painting_rented VALUES (
        no,
        'Y'
    );

    INSERT INTO artist_report VALUES (
        no,
        n1,
        own,
        price
    );

END;

CREATE OR REPLACE PROCEDURE del_return_to_owner (
    n1 INT,
    n2 INT
) IS
BEGIN
    DELETE FROM return_owner
    WHERE
        painting_no = n1
        AND owner_no = n2;

END;

CREATE OR REPLACE PROCEDURE return_painting (
    n1 INT,
    n2 INT
) IS
BEGIN
    UPDATE painting_rented
    SET
        available = 'Y'
    WHERE
        painting_no = n2;

    UPDATE rental_report
    SET
        returned = 'Y'
    WHERE
        painting_no = n2;

END;

CREATE OR REPLACE PROCEDURE return_to_owner (
    n1 INT,
    n2 INT
) IS
BEGIN
    INSERT INTO return_owner VALUES (
        n1,
        n2,
        sysdate
    );

END;

CREATE OR REPLACE FUNCTION artist_report_view (
    num INT
) RETURN VARCHAR IS

    output VARCHAR(32767);
    CURSOR simple_cursor IS
    SELECT
        *
    FROM
        artist_report
    WHERE
        artist_no = num;

    paint  painting%rowtype;
    own    owner%rowtype;
    temp   artist_report%rowtype;
BEGIN     
   -- dbms_output.put_line('Painting No '||'Painting Title '||'Theme '||'Rental Price '||'Owner no '||'Owner Name '||'Owner Tel' );  
    OPEN simple_cursor;
    LOOP
        FETCH simple_cursor INTO temp;
        EXIT WHEN simple_cursor%notfound;
        SELECT
            *
        INTO paint
        FROM
            painting
        WHERE
            painting_no = temp.painting_no;

        SELECT
            *
        INTO own
        FROM
            owner
        WHERE
            owner_no = temp.owner_no;

        output := output
                  || '_'
                  || paint.painting_no
                  || '.......'
                  || paint.painting_title
                  || '.......'
                  || paint.painting_theme
                  || '.......'
                  || temp.price
                  || '$...... '
                  || own.owner_no
                  || '......'
                  || own.owner_name
                  || '.....'
                  || own.onwer_telephone;

    END LOOP;

    CLOSE simple_cursor;
    RETURN output;
END;

CREATE OR REPLACE FUNCTION calculate_price (
    p_no     INT,
    c_no     INT,
    duration DATE
) RETURN FLOAT IS
    due FLOAT;
    pp  INT;
    cat customer.customer_discount%TYPE;
BEGIN
    SELECT
        price
    INTO pp
    FROM
        painting_price
    WHERE
        painting_no = p_no;

    SELECT
        customer_discount
    INTO cat
    FROM
        customer
    WHERE
        customer_no = c_no;

    due := ( ( duration - sysdate ) / 30 ) * pp * ( 1 - ( cat / 100 ) );

    RETURN due;
END;

CREATE OR REPLACE FUNCTION check_avail (
    p_no INT
) RETURN CHAR IS
    pp CHAR := 'Y';
    c  INT;
BEGIN
    SELECT
        COUNT(*)
    INTO c
    FROM
        painting_rented
    WHERE
        painting_no = p_no;

    IF c >= 1 THEN
        SELECT
            available
        INTO pp
        FROM
            painting_rented
        WHERE
            painting_no = p_no;

    ELSE
        INSERT INTO painting_rented VALUES (
            p_no,
            'N'
        );

    END IF;

    RETURN pp;
END;

CREATE OR REPLACE FUNCTION customer_report_view (
    num INT
) RETURN VARCHAR IS

    output STRING(32767);
    CURSOR simple_cursor_2 IS
    SELECT
        *
    FROM
        rental_report
    WHERE
        customer_no = num;

    paint  painting%rowtype;
    cust   customer%rowtype;
    temp   rental_report%rowtype;
BEGIN
    OPEN simple_cursor_2;
    LOOP
        FETCH simple_cursor_2 INTO temp;
        EXIT WHEN simple_cursor_2%notfound;
        SELECT
            *
        INTO paint
        FROM
            painting
        WHERE
            painting_no = temp.painting_no;

        output := output
                  || '_'
                  || + paint.painting_no
                  || '........'
                  || paint.painting_title
                  || '.....'
                  || paint.painting_theme
                  || '.....'
                  || temp.date_of_hire
                  || '.....'
                  || temp.date_due_back
                  || '.....'
                  || temp.returned;

    END LOOP;

    CLOSE simple_cursor_2;
    RETURN output;
END;

CREATE OR REPLACE FUNCTION display_artist_details (
    num INT
) RETURN VARCHAR IS
    output VARCHAR(32767);
    art    artist%rowtype;
BEGIN
    SELECT
        *
    INTO art
    FROM
        artist
    WHERE
        artist_no = num;

    output := 'Artist No: '
              || art.artist_no
              || '_Artist Name: '
              || art.artist_name
              || '_Country of Birth: '
              || art.country_of_birth
              || '_Year of Birth: '
              || art.year_of_birth
              || '_Year of Death: '
              || art.year_of_death
              || '_Artist Age: '
              || art.age;

    RETURN output;
END;

CREATE OR REPLACE FUNCTION display_customer_details (
    num INT
) RETURN VARCHAR IS
    cust   customer%rowtype;
    output VARCHAR(32767);
BEGIN
    SELECT
        *
    INTO cust
    FROM
        customer
    WHERE
        customer_no = num;

    output := 'Customer No: '
              || cust.customer_no
              || '_Customer Name: '
              || cust.customer_name
              || '_Customer Address: '
              || cust.customer_address
              || '_Customer Category: '
              || cust.customer_cat
              || '_Category Description: '
              || cust.customer_description
              || '_Category Discount: '
              || cust.customer_discount
              || '%';

    RETURN output;
END;

CREATE OR REPLACE FUNCTION display_owner_details (
    num INT
) RETURN VARCHAR IS
    own    owner%rowtype;
    output VARCHAR(32767);
BEGIN
    SELECT
        *
    INTO own
    FROM
        owner
    WHERE
        owner_no = num;

    output := '_Owner No: '
              || own.owner_no
              || '_Owner Name: '
              || own.owner_name
              || '_Owner Address: '
              || own.owner_address;
--'Painting No'||'Painting Title'||'Return Date';
    RETURN output;
END;

CREATE OR REPLACE FUNCTION eligble_to_rehire (
    p_no INT
) RETURN CHAR IS
    ppp  CHAR;
    pp   CHAR := 'K';
    temp return_owner%rowtype;
BEGIN
    ppp := isreturned(p_no);
    IF ppp = 'Y' THEN
        SELECT
            *
        INTO temp
        FROM
            return_owner
        WHERE
            painting_no = p_no;

        pp := sol2(temp.return_date);
    END IF;

    RETURN pp;
END;

CREATE OR REPLACE FUNCTION isreturned (
    p_no INT
) RETURN CHAR IS
    pp CHAR := 'N';
    c  INT := 0;
BEGIN
    SELECT
        COUNT(*)
    INTO c
    FROM
        return_owner
    WHERE
        painting_no = p_no;

    IF c >= 1 THEN
        pp := 'Y';
        RETURN pp;
    ELSE
        pp := 'N';
        RETURN pp;
    END IF;

END;

CREATE OR REPLACE FUNCTION not_rented RETURN STRING IS

    CURSOR curr IS
    SELECT
        painting_no
    FROM
        painting
    MINUS
    SELECT
        painting_no
    FROM
        last_rented
    WHERE
        sol(rent_date) = 'K';

    output VARCHAR(32767);
    temp   INT;
    temp2  painting%rowtype;
BEGIN
    OPEN curr;
    LOOP
        EXIT WHEN curr%notfound;
        FETCH curr INTO temp;
        SELECT
            *
        INTO temp2
        FROM
            painting
        WHERE
            painting_no = temp;

        output := output
                  || '_'
                  || '-->'
                  || temp2.painting_no
                  || ' '
                  || temp2.painting_title;

    END LOOP;

    CLOSE curr;
    RETURN output;
END;

CREATE OR REPLACE FUNCTION owner_return_view (
    num INT
) RETURN VARCHAR IS

    output VARCHAR(32767);
    CURSOR cursor_3 IS
    SELECT
        *
    FROM
        return_owner
    WHERE
        owner_no = num;

    temp   return_owner%rowtype;
    paint  painting%rowtype;
BEGIN
    OPEN cursor_3;
    LOOP
        FETCH cursor_3 INTO temp;
        EXIT WHEN cursor_3%notfound;
        SELECT
            *
        INTO paint
        FROM
            painting
        WHERE
            painting_no = temp.painting_no;

        output := output
                  || '_'
                  || paint.painting_no
                  || '.......'
                  || paint.painting_title
                  || '........'
                  || temp.return_date;

    END LOOP;

    CLOSE cursor_3;
    RETURN output;
END;

CREATE OR REPLACE FUNCTION sol (
    d DATE
) RETURN CHAR IS
    i INT;
BEGIN
    i := ( ( sysdate - d ) / 30 );
    IF i > 6 THEN
        RETURN 'D';
    ELSE
        RETURN 'K';
    END IF;
END;

CREATE OR REPLACE FUNCTION sol2 (
    d DATE
) RETURN CHAR IS
    i INT;
BEGIN
    i := ( ( sysdate - d ) / 30 );
    IF i > 3 THEN
        RETURN 'K';
    ELSE
        RETURN 'R';
    END IF;
END;

CREATE OR REPLACE TRIGGER adding_painting AFTER
    INSERT ON painting
    FOR EACH ROW
BEGIN
    dbms_output.put_line('new painting added');
END;

CREATE OR REPLACE TRIGGER adding_owner AFTER
    INSERT ON owner
    FOR EACH ROW
BEGIN
    dbms_output.put_line('new owner added');
END;

CREATE OR REPLACE TRIGGER adding_artist AFTER
    INSERT ON artist
    FOR EACH ROW
BEGIN
    dbms_output.put_line('new artist added');
END;

CREATE OR REPLACE TRIGGER adding_customer AFTER
    INSERT ON customer
    FOR EACH ROW
BEGIN
    dbms_output.put_line('new customer added');
END;

CREATE OR REPLACE TRIGGER painting_rented AFTER
    INSERT ON painting_rented
    FOR EACH ROW
BEGIN
    dbms_output.put_line('new painting rented');
END;

CREATE OR REPLACE TRIGGER painting_rented AFTER
    UPDATE ON painting_rented
    FOR EACH ROW
BEGIN
    dbms_output.put_line('painting returned');
END;

CREATE OR REPLACE TRIGGER owner_return AFTER
    INSERT ON owner_report
    FOR EACH ROW
BEGIN
    dbms_output.put_line('painting returned to owner');
END;