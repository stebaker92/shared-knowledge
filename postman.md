# Postman

## Generating and reusing auth tokens

- Create a "GetAuthToken" request
- Add the following code into the 'Tests' section of the request

```
if (responseCode.code === 200) {
    var jsonData = JSON.parse(responseBody);
    postman.setGlobalVariable("token", jsonData.authenticationToken);
} else {
    postman.clearGlobalVariable("token", null);
}
```

- In all of your requests, you can now add the Authorization header and enter `{{token}}` as the value. This will read the global variable `token` and inject it into the request
