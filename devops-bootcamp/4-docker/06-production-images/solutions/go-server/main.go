// A tiny HTTP server with no dependencies — perfect for showing multi-stage builds.
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	host, _ := os.Hostname()
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "{\"message\": \"hello from Go\", \"hostname\": %q}\n", host)
	})
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, `{"status": "ok"}`)
	})
	log.Println("listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
