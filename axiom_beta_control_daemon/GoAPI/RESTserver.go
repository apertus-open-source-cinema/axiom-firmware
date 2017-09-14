package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

type RESTserver struct {
}

func (server *RESTserver) Init() {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/", Index)
	router.HandleFunc("/todos", TodoIndex)
	router.HandleFunc("/todos/{todoId}", TodoShow)
	router.HandleFunc("/settings", SettingsShowGET).Methods("GET")
	router.HandleFunc("/settings", SettingsShowPUT).Methods("PUT")
	router.HandleFunc("/settings", SettingsShowOPTIONS).Methods("OPTIONS")

	headersOk := handlers.AllowedHeaders([]string{"X-Requested-With"})
	originsOk := handlers.AllowedOrigins([]string{os.Getenv("ORIGIN_ALLOWED")})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

	log.Fatal(http.ListenAndServe(":7070", handlers.CORS(originsOk, headersOk, methodsOk)(router)))
}

// // Reference: https://thenewstack.io/make-a-restful-json-api-go/
// func main() {

// }

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Welcome!")
}

func TodoIndex(w http.ResponseWriter, r *http.Request) {
	// todos := Todos{
	// 	Todo{Name: "Write presentation"},
	// 	Todo{Name: "Host meetup"},
	// }

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	// json.NewEncoder(w).Encode(todos)
}

func TodoShow(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	todoId := vars["todoId"]
	fmt.Fprintln(w, "Todo show:", todoId)
}

func SettingsShowGET(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	todoId := vars["Test123"]

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	fmt.Fprintln(w, "Available settings:", todoId)
}

func SettingsShowPUT(w http.ResponseWriter, r *http.Request) {
	//vars := mux.Vars(r)
	//newValue := vars["gain"]
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading body: %v", err)
		http.Error(w, "can't read body", http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	//dec := json.NewDecoder(r.Body)
	fmt.Fprintln(w, "Set new value:", bytes.NewBuffer(body))
}

// Handler for pre-flight, browser checks for available methods before sending real request
func SettingsShowOPTIONS(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET,POST, PUT")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
	fmt.Fprintln(w, r)
}
