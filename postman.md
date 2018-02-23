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


## Environments

- Go to the Cog icon (top right)
- click on `Manage Environments`
- Add a new environment(s) (i.e. Replica, Production) 
- Add a key to each (i.e. MyApiUrl)
- You can now use that variable anywhere in a request, such as the URL: `http://{{MyApiUrl}}/customer/1` and easily toggle between environments!
