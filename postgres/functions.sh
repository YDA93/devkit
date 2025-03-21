function postgres_database_delete() {
    echo -n "Enter the PostgreSQL password: "
    read -s pg_password
    echo

    export PGPASSWORD="$pg_password"

    # Get a list of all databases
    databases=$(psql -U postgres -h localhost -lqt | cut -d \| -f 1 | sed -e 's/ //g' -e '/^$/d')
    echo "List of databases:"
    echo "------------------"
    echo "$databases"
    echo "------------------"

    echo -n "Enter the name of the database to delete from the above list: "
    read db_name

    if echo "$databases" | grep -qw "$db_name"; then
        while true; do
            echo -n "Database '$db_name' exists. Do you want to drop it? (yes/no): "
            read drop_confirm
            case $drop_confirm in
            [Yy][Ee][Ss])
                # Terminate active sessions
                psql -U postgres -h localhost -c "SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$db_name';"

                # Drop the database
                dropdb -U postgres -h localhost "$db_name"
                echo "Database '$db_name' dropped."
                break
                ;;
            [Nn][Oo])
                echo "Database '$db_name' not dropped."
                break
                ;;
            *)
                echo "Please answer yes or no."
                ;;
            esac
        done
    else
        echo "Database '$db_name' does not exist."
    fi

    unset PGPASSWORD
}

function postgres_database_list() {
    echo -n "Enter the PostgreSQL password: "
    read -s pg_password
    echo

    export PGPASSWORD="$pg_password"

    # Get a list of all databases
    databases=$(psql -U postgres -h localhost -lqt | cut -d \| -f 1 | sed -e 's/ //g' -e '/^$/d')

    echo "List of databases:"
    echo "------------------"
    echo "$databases"
    echo "------------------"
    echo "Total databases: $(echo "$databases" | wc -l)"

    unset PGPASSWORD
}

function postgres_database_create() {
    # Prompt for the PostgreSQL password and store in an environment variable
    echo -n "Enter the PostgreSQL password: "
    read -s pg_password
    echo
    export PGPASSWORD="$pg_password"

    # Prompt for the desired database name
    echo -n "Enter the name of the database you want to create: "
    read db_name

    # Create the database
    createdb -U postgres -h localhost "$db_name" && echo "Database '$db_name' created successfully!" || echo "Failed to create database."

    # Clean up and remove the PGPASSWORD environment variable for security
    unset PGPASSWORD
}

function postgres_check_password() {
    # Attempt to connect to PostgreSQL using the set PGPASSWORD
    if ! (psql -U postgres -h localhost -c "\q" 2>/dev/null || true); then
        echo "Error: Invalid PostgreSQL password!\n Please check the LOCAL_DB_PASSWORD value in .env file."
        unset PGPASSWORD
        return 1
    fi
}

function postgres_manage_database_creation() {
    # List available databases before deletion prompt
    databases=$(psql -U postgres -h localhost -lqt | cut -d \| -f 1 | sed -e 's/ //g' -e '/^$/d')
    echo "Available databases:"
    echo "------------------"
    echo "$databases"
    echo "------------------"

    # Prompt user to enter database name
    echo -n "Enter name of the database you wish to create: "
    read db_name
    sleep 2

    # Check if db_name exists
    if psql -U postgres -h localhost -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
        while true; do
            echo -n "Database '$db_name' already exists. Do you want to drop it? (yes/no): "
            read drop_confirm
            case $drop_confirm in
            [Yy][Ee][Ss])
                # Terminate active sessions
                if ! psql -U postgres -h localhost -c "SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$db_name';" 2>/dev/null; then
                    echo "Error: Failed to terminate active sessions."
                    return 1
                fi

                # Drop the database
                if ! dropdb -U postgres -h localhost "$db_name"; then
                    echo "Error: Failed to drop database."
                    return 1
                fi
                echo "Database dropped."
                sleep 2
                break
                ;;
            [Nn][Oo])
                echo "Operation canceled. Exiting..."
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
            esac
        done
    fi

    # Create new database
    echo "Creating new database..."
    if ! createdb -U postgres -h localhost "$db_name"; then
        echo "Error: Failed to create database."
        return 1
    fi
    echo "New database created."
    sleep 2
}
