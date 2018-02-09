# Postman

## Generating and reusing auth tokens

if (responseCode.code === 200){
    var jsonData = JSON.parse(responseBody);
    postman.setGlobalVariable("token", jsonData.authenticationToken);
} else {
    postman.clearGlobalVariable("token", null);
}
