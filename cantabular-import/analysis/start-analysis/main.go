package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"
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

	client = &http.Client{}
)

const (
	idDir      = "../tmp"
	idFileName = "../tmp/id.txt"
)

func main() {
	ensureDirectoryExists(idDir)

	//	token, err := readInput()
	token, err := getToken()
	if err != nil {
		fmt.Println("error reading input: ", err)
		os.Exit(1)
	}

	// grab time before postJob to ensure we have 'time' before anything relevant to this
	// operation is put in log file for Docker container(s)
	t := time.Now()

	res, err := postJob(token)
	if err != nil {
		fmt.Println("error posting job to importAPI: ", err)
		os.Exit(1)
	}

	fmt.Printf("\nTrace ID (?): %s\n\n", res.ID)
	idTextFile, err := os.OpenFile(idFileName, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
	check(err)

	if err := putJob(token, res); err != nil {
		fmt.Println("error putting job to importAPI: ", err)
		cerr := idTextFile.Close()
		if cerr != nil {
			fmt.Printf("problem closing: %s : %v\n", idFileName, cerr)
		}
		os.Exit(1)
	}

	// prefix time stamp of initiating the integration test
	// (the specific format chosen is to be compatible with the ones in the docker logs, and thus makes
	//  comparison of time's easily possible)
	_, err = fmt.Fprintf(idTextFile, "%s %s\n", t.Format("2006-01-02T15:04:05.000000000Z"), res.ID)
	check(err)
	cerr := idTextFile.Close()
	if cerr != nil {
		fmt.Printf("problem closing: %s : %v\n", idFileName, cerr)
	}
	os.Exit(0)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func ensureDirectoryExists(dirName string) {
	if _, err := os.Stat(dirName); os.IsNotExist(err) {
		check(os.Mkdir(dirName, 0700))
	}
}

/*func readInput() (string, error) {
	rdr := bufio.NewReader(os.Stdin)

	s, err := rdr.ReadString('\n')
	if err != nil && err != io.EOF {
		return "", fmt.Errorf("failed to read from stdin: %s", err)
	}

	fmt.Println("florence-token:", s)

	return s, nil
}*/

func getToken() (string, error) {
	fmt.Printf("Running get-florence-token\n")

	cmd := exec.Command("./florence-token")        // where to get the command from
	cmd.Dir = "../../helpers"                      // where to execute the command*/

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

	if s == "Authentication failed." {
		return s, fmt.Errorf("Failed getting token: Authentication failed")
	}

	fmt.Println("florence-token:", s)

	return s, nil
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

	res, err := client.Do(r)
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

	res, err := client.Do(r)
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
