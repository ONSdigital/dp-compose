# Data API Stack

This stack deploys the necessary services and dependencies to work with the data api stack.

- The stack uses a local [stub](https://github.com/ONSdigital/dis-authentication-stub) for user authentication

## Gotchas

In the `Makefile` of the stack there is a `DEFAULT_KEYS_FOLDER` variable that is set to point to the `static/keys` folder in the `dis-authentication-stub` repo.
Running the `make up` command will run also the `init` target in the `Makefile` and try to decrypt the files that are inside that folder.
If you run the `make up` command and you get an error saying that there are *no such files* in the folder, please change the value of the `ONS_DP_SRC_ROOT` variable (also located in the `Makefile`) to the root of where all your ONSdigital repos are.