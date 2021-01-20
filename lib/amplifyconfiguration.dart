const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
      "plugins": {
          "awsCognitoAuthPlugin": {
              "IdentityManager": {
                  "Default": {}
              },
              "CredentialsProvider": {
                  "CognitoIdentity": {
                      "Default": {
                          "PoolId": "us-west-2:02f9afae-83ad-419e-8490-9f65d64b4e77",
                          "Region": "us-west-2"
                      }
                  }
              },
              "CognitoUserPool": {
                  "Default": {
                      "PoolId": "us-west-2_4ozwPjKeL",
                      "AppClientId": "1orl83hdnv52nembmf0fdemaab",
                      "Region": "us-west-2"
                  }
              },
              "Auth": {
                  "Default": {
                      "authenticationFlowType": "USER_SRP_AUTH"
                  }
              }
          }
      }
  }
}''';
