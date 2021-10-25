## Validating docker working well ##

In order to run the `start-import.sh` or `start-analysis.sh` scripts which kick off one import job, you need to have the docker files for Cantabular running.

Sometimes a verion of docker / docker-compose may not prove reliable, so the `test-compose.sh` script can be used to gain confidence in docker and docker-compose.

The script `test-compose.sh` runs multiple iterations of these steps:

    start containers
    get florence token
    run import process
    stop containers.

Its primary purpose is to determine that the version of Docker and Docker-compose are working well (it also demonstrates that the whole import process is functioning, as are all the contaiers / services)

Usage: (on mac books)
* Have a version of Docker running that you wish to test.

    Using Docker 3.3.3 works well (the one before having docker-compose v2.0.0-beta.6 ... which does not work well)

* Edit the `helpers/florence-token` script to use your florence username/password. Alternatively set the
`FLORENCE_PASSWORD` environment variable to your florence login's password.

* Adjust the constant `maxRuns` in `test-compose.go` for the number of times you want the process to run. Each loop of the process may take about 3 minutes. You may also need to adjust `maxContainersInJob` to match the number of containers that are run for the cantabular import process (which may change).

* First run `make start` and then when all containers running, run `./start-import.sh` in its directory to test that at least one import process completes OK

* Then to run multiple tests: `./test-compose.sh`

* follow any instructions the above produces.

When test is run, the job id is placed in / appended to file ../analysis/tmp/id.txt that allows quick access if you have the whole of the dp-compose directory open in say vscode or goland ide's. You should clear this file before running the test and then check that the expected amount of id's are in the file after the test.

If the test fails, after its finished, you may need to do: `docker-compose down` and try again.