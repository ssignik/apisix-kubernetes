package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, Version 2!")
}

func main() {
	http.HandleFunc("/version", handler)
	fmt.Println("Server listening on port 8080...")
	http.ListenAndServe(":8080", nil)
}