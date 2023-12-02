import ballerina/http;
import ballerina/time;

type User record {|
    int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

service /social\-media on new http:Listener(9090) {
    // social-media/users
    resource function get users() returns User[]|error {
        User joe = {id: 1, name: "Joe", birthDate: {year: 1990, month: 2, day: 13}, mobileNumber: "0776587987"};
        return [joe];
    }
}
