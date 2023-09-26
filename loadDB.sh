#!/usr/bin/bash

echo "Importing mysql database"
docker exec -i zume-training-db-1 mysql -psomewordpress -uroot wp_zume5 < ./tables/wp_zume5.sql
echo "replacing zume5.training with zume5.test in database"
docker exec -i zume-training-wp-cli-1 wp search-replace 'zume5.training' 'zume5.test' --precise --recurse-objects --all-tables
docker exec -i zume-training-wp-cli-1 wp search-replace 'zume5.wpengine.com' 'zume5.test' --precise --recurse-objects --all-tables
docker exec -i zume-training-wp-cli-1 wp search-replace 'https://' 'http://' --precise --recurse-objects --all-tables
