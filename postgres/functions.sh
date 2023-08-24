postgres_database_delete() {
    echo -n "Enter the PostgreSQL password: "
    read -s pg_password
    echo

    export PGPASSWORD="$pg_password"

    echo -n "Enter the name of the database to delete: "
    read db_name

    if psql -U postgres -h localhost -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
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
