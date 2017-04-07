package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"

	"github.com/lastlantean/PiWall/wifi"
)

func handleScan(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")

	r.ParseForm()
	inter := r.FormValue("interface")
	nets, err := wifi.GetNetworks(inter)
	if err != nil {
		io.WriteString(w, "[]")
		log.Println(err)
	}

	data, _ := json.Marshal(&nets)

	io.WriteString(w, string(data))
}

func handleConnect(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")

	r.ParseForm()
	ssid := r.FormValue("ssid")
	key := r.FormValue("key")

	fmt.Println(ssid)
	fmt.Println(key)

	wifi.SetWifi(ssid, key)

	io.WriteString(w, "OK")
}

func handleCurrentWifi(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")

	info, err := wifi.GetCurrentWifi("wlan1")
	if err != nil {
		log.Println(err)
	}

	data, _ := json.Marshal(&info)

	io.WriteString(w, string(data))
}

func handleShutdown(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")

	_, err := exec.Command("poweroff").Output()
	if err != nil {
		log.Println(err)
	}

	io.WriteString(w, string("ok"))
}

func main() {
	args := os.Args

	webPath := "public"

	if len(args) > 1 {
		webPath = args[1]
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/scan", handleScan)
	mux.HandleFunc("/connect", handleConnect)
	mux.HandleFunc("/currentWifi", handleCurrentWifi)
	mux.HandleFunc("/shutdown", handleShutdown)

	fs := http.FileServer(http.Dir(webPath))
	mux.Handle("/", fs)

	log.Println("Listening...")
	http.ListenAndServe(":8080", mux)
}
