import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type User record {|
    readonly int id;
    string name;

    @sql:Column {name: "birth_date"}
    time:Date birthDate;

    @sql:Column {name: "mobile_number"}
    string mobileNumber;
|};

type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

table<User> key(id) users = table [
    {id: 1, name: "Joe", birthDate: {year: 1990, month: 2, day: 13}, mobileNumber: "0776587987"}
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type DatabaseConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DatabaseConfig databaseConfig = ?;

mysql:Client socialMediaDb = check new (...databaseConfig);

service /social\-media on new http:Listener(9090) {

    # Get all the users
    #
    # + return - The list of users or error message
    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = socialMediaDb->query(`SELECT * FROM users`);
        return from var user in userStream
            select user;
    }

    # Get a specific user
    #
    # + id - The user ID of the user to be retrived
    # + return - A specific user or error message
    resource function get users/[int id]() returns User|UserNotFound|error {
        User|sql:Error user = socialMediaDb->queryRow(`SELECT * FROM users WHERE id = ${id}`);
        if user is sql:NoRowsError {
            UserNotFound userNotFound = {body: {message: string `id: ${id}`, details: string `user/${id}`, timeStamp: time:utcNow()}};
            return userNotFound;
        }
        return user;
    }

    # Create a new user
    #
    # + newUser - The user details of the new user
    # + return - The created message or error message
    resource function post users(NewUser newUser) returns http:Created|error {
        _ = check socialMediaDb->execute(`
            INSERT INTO users(birth_date, name, mobile_number)
            VALUES (${newUser.birthDate}, ${newUser.name}, ${newUser.mobileNumber});`);
        return http:CREATED;
    }
}
