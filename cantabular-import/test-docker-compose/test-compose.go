package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"
)

type PutJobRequest struct {
	Links Links  `json:"links"`
	State string `json:"state"`
}

type PostJobResponse struct {
	ID    string `json:"id"`
	Links Links  `json:"links"`
}

type Links struct {
	Instances []Link `json:"instances"`
	Self      Link   `json:"self"`
}

type Link struct {
	ID   string `json:"id"`
	HRef string `json:"href"`
}

var (
	importAPIHost = "http://localhost:21800"
	recipeID      = "38542eb6-d3a6-4cc4-ba3f-32b25f23223a"

	httpClient = &http.Client{}
)

const (
	idDir              = "../analysis/tmp"
	idFileName         = "../analysis/tmp/id.txt"
	maxContainersInJob = 14 // adjust this to suite the number of continers docker-compose runs up
	maxRuns            = 2  // number of times to run up containers, perform integration test and stop containers
)

func main() {
	ensureDirectoryExists(idDir)

	showedReminder := false

	for testCount := 1; testCount <= maxRuns; testCount++ {
		fmt.Printf("Runnning test: %d\n\n", testCount)

		startContainers()

		lastCount := 0

		// give enough time for containers to be built (if needed)...
		// initial 180 seconds is from observing time taken to build all containers if they don't exist
		for i := 0; i < 180; i++ {
			count, err := getCantabularContainerCount()
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			fmt.Printf("Seconds: %03d   Cantabular Containers Running count: %d\n", i, count)
			time.Sleep(1 * time.Second)
			if count == maxContainersInJob {
				break
			}
			if count > lastCount {
				// looks like containers exist and are starting up, so reduce remainng timeout
				lastCount = count
				i = 120
			}
			if count == 0 && i == 40 {
				showImportReminder()
				showedReminder = true
			}
		}

		// we should now check health of apps, but it seemd OK to just do a delay for these tests
		fmt.Println("Pasuing 15 seconds")
		if showedReminder {
			showImportReminder()
		}
		time.Sleep(15 * time.Second)

		fmt.Printf("Doing Import ...\n")
		for attempts := 0; attempts <= 5; attempts++ {
			err := doImport()
			if err != nil {
				fmt.Println(err)
				if attempts < 5 {
					fmt.Println("Pasuing 5 seconds, and trying import again")
					if showedReminder {
						showImportReminder()
					}
					time.Sleep(5 * time.Second)
				} else {
					fmt.Printf("Import failing ...\n")
					fmt.Println("Pasuing 5 seconds")
					time.Sleep(5 * time.Second)

					_ = stopAllCantabularDockerContainers()
					fmt.Println("Pasuing 5 seconds")
					time.Sleep(5 * time.Second)
					fmt.Println("Do you need to run './import-recipes.sh mongodb://localhost:27017' in dp-recipe-api/import-recipies (when all containers are running) ?")
					fmt.Printf("Stopping early during test number: %d\n", testCount)
					os.Exit(2)
				}
			} else {
				break
			}
		}

		fmt.Println("Pasuing 5 seconds")
		time.Sleep(5 * time.Second)

		err := stopAllCantabularDockerContainers()
		if err != nil {
			fmt.Printf("problem closing containers, stopping: %v\n", err)
			break
		}

		fmt.Println("Pasuing 5 seconds")
		time.Sleep(5 * time.Second)
	}
}

func ensureDirectoryExists(dirName string) {
	if _, err := os.Stat(dirName); os.IsNotExist(err) {
		check(os.Mkdir(dirName, 0700))
	}
}

func showImportReminder() {
	fmt.Println("\nprobably building containers and when you see: 'Running get-florence-token'")
	fmt.Println("you will most likely need to, in another terminal:")
	fmt.Println("in:")
	fmt.Println("    dp-recipe-api/import-recipies")
	fmt.Println("do:")
	fmt.Printf("    ./import-recipes.sh mongodb://localhost:27017\n\n")
}

func startContainers() {
	cmd := exec.Command("./run-cantabular-without-sudo.sh") // where to get the command from
	cmd.Dir = ".."                                          // where to execute the command
	err := cmd.Start()
	if err != nil {
		log.Fatal(err)
	}
}

func doImport() error {

	token, err := getToken()
	if err != nil {
		fmt.Println("error reading input: ", err)
		return err
	}

	// grab time before postJob to ensure we have 'time' before anything relevant to this
	// operation is put in log file for Docker container(s)
	t := time.Now()

	res, err := postJob(token)
	if err != nil {
		fmt.Println("error posting job to importAPI: ", err)
		return err
	}

	fmt.Printf("\nTrace ID (?): %s\n\n", res.ID)
	idTextFile, err := os.OpenFile(idFileName, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
	check(err)
	defer func() {
		cerr := idTextFile.Close()
		if cerr != nil {
			fmt.Printf("problem closing: %s : %v\n", idFileName, cerr)
		}
	}()

	if err := putJob(token, res); err != nil {
		fmt.Println("error putting job to importAPI: ", err)
		return err
	}

	// prefix time stamp of initiating the integration test
	// (the specific format chosen is to be compatible with the ones in the docker logs, and thus makes
	//  comparison of time's easily possible)
	_, err = fmt.Fprintf(idTextFile, "%s %s\n", t.Format("2006-01-02T15:04:05.000000000Z"), res.ID)
	check(err)

	return nil
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func postJob(token string) (*PostJobResponse, error) {
	fmt.Printf("Making request to POST import-api/jobs:")

	b := []byte(fmt.Sprintf(`{"recipe":"%s"}`, recipeID))

	fmt.Println(string(b))

	r, err := http.NewRequest("POST", importAPIHost+"/jobs", bytes.NewReader(b))
	if err != nil {
		return nil, fmt.Errorf("error creating request: %s", err)
	}

	r.Header.Set("X-Florence-Token", token)

	res, err := httpClient.Do(r)
	if err != nil {
		return nil, fmt.Errorf("error performing request: %s", err)
	}
	defer func() {
		cerr := res.Body.Close()
		if cerr != nil {
			fmt.Printf("problem closing: response body : %v\n", cerr)
		}
	}()

	var resp PostJobResponse

	b, err = ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, fmt.Errorf("error reading response body: %s", err)
	}

	if err := json.Unmarshal(b, &resp); err != nil {
		r := fmt.Sprintf("%d %s", res.StatusCode, string(b))
		return nil, fmt.Errorf("error unmarshalling response: '%s' response: %s\n", err, r)
	}

	fmt.Printf("Got response from POST import-api/jobs: %s\n", prettyPrint(resp))
	return &resp, nil
}

func putJob(token string, resp *PostJobResponse) error {
	fmt.Println("Making request to PUT import-api/jobs:")

	req := PutJobRequest{
		State: "submitted",
		Links: resp.Links,
	}

	b, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("error marshalling request: %s request:\n%+v", err, req)
	}

	fmt.Println(prettyPrint(req))

	r, err := http.NewRequest("PUT", importAPIHost+"/jobs/"+resp.ID, bytes.NewReader(b))
	if err != nil {
		return fmt.Errorf("error creating request: %s", err)
	}

	r.Header.Set("X-Florence-Token", token)

	res, err := httpClient.Do(r)
	if err != nil {
		return fmt.Errorf("error making request: %s", err)
	}
	defer func() {
		cerr := res.Body.Close()
		if cerr != nil {
			fmt.Printf("problem closing: response body : %v\n", cerr)
		}
	}()

	b, err = ioutil.ReadAll(res.Body)
	if err != nil {
		return fmt.Errorf("error reading response body: %s", err)
	}

	fmt.Printf("Got response from PUT import-api/jobs/%s: %d\n", resp.ID, res.StatusCode)
	fmt.Println(prettyPrint(string(b)))

	return nil
}

func prettyPrint(s interface{}) string {
	b, err := json.MarshalIndent(s, "", "  ")
	if err == nil {
		return fmt.Sprintf("%s", string(b))
	} else {
		return fmt.Sprintf("%+v", s)
	}
}

func getToken() (string, error) {
	fmt.Printf("Running get-florence-token\n")

	cmd := exec.Command("./florence-token")        // where to get the command from
	cmd.Dir = "../helpers"                         // where to execute the command*/

	var out bytes.Buffer
	cmd.Stdout = &out
	var stdErr bytes.Buffer
	cmd.Stderr = &stdErr
	err := cmd.Run()
	if err != nil {
		fmt.Printf("in all caps: %q\n", out.String())
		fmt.Printf("stderr in all caps: %q\n", stdErr.String())
		return "", err
	}

	s := out.String()
	s = strings.ReplaceAll(s, "\"", "")

	fmt.Println("florence-token:", s)

	return s, nil
}

func stopAllCantabularDockerContainers() error {
	fmt.Printf("Stopping all Containers\n")
	ctx := context.Background()

	cli, err := client.NewClientWithOpts(client.FromEnv)
	if err != nil {
		return err
	}

	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		return err
	}

	containersStoppedCount := 0

	for _, container := range containers {

		if strings.Contains(container.Names[0], "/cantabular-import-journey") {
			fmt.Print("Stopping cantabular container ", container.ID[:10], " ", container.Names[0], " ... \n")
			if err := cli.ContainerStop(ctx, container.ID, nil); err != nil {
				return err
			}
			containersStoppedCount++
		}
	}

	if containersStoppedCount > 0 {
		fmt.Printf("%d of %d : Containers stopped\n", containersStoppedCount, maxContainersInJob)
	} else {
		return errors.New("no containers found to stop")
	}
	return nil
}

func getCantabularContainerCount() (int, error) {
	ctx := context.Background()

	cli, err := client.NewClientWithOpts(client.FromEnv)
	if err != nil {
		return 0, err
	}

	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		return 0, err
	}

	cantabularContainersCount := 0

	for _, container := range containers {

		if strings.Contains(container.Names[0], "/cantabular-import-journey") {
			cantabularContainersCount++
		}
	}

	return cantabularContainersCount, nil
}
