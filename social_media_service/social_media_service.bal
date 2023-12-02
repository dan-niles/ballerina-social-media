import ballerina/http;
import ballerina/time;

type User record {|
    readonly int id;
    string name;
    time:Date birthDate;
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

service /social\-media on new http:Listener(9090) {
    // [GET] social-media/users
    resource function get users() returns User[]|error {
        return users.toArray();
    }

    // [GET] social-media/users/[id]
    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {body: {message: string `id: ${id}`, details: string `user/${id}`, timeStamp: time:utcNow()}};
            return userNotFound;
        }
        return user;
    }

    // [POST] social-media/users
    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.length() + 1, ...newUser});
        return http:CREATED;
    }
}
