package wifi

import (
	"errors"
	"io/ioutil"
	"log"
	"os/exec"
	"strings"
)

type wifiNetwork struct {
	ESSID     string
	Encrypted bool
}

func parseNetworks(inn string) ([]wifiNetwork, error) {
	var nets []wifiNetwork
	data := strings.Split(inn, "\n")
	if strings.Contains(data[0], "No scan results") {
		return nets, errors.New("No scan results")
	}

	currentline := 1
	for {
		currentNet := wifiNetwork{}

		currentline = currentline + 4
		if strings.Contains(data[currentline], "on") {
			currentNet.Encrypted = true
		} else {
			currentNet.Encrypted = false
		}

		currentline = currentline + 1
		currentNet.ESSID = data[currentline]
		currentNet.ESSID = currentNet.ESSID[27 : len(currentNet.ESSID)-1]

		nets = append(nets, currentNet)
		for {
			if (currentline == len(data)-1) || strings.Contains(data[currentline], " Cell ") {
				break
			}
			currentline = currentline + 1
		}

		if currentline == len(data)-1 {
			break
		}
	}

	return nets, nil
}

// GetNetworks scan for wifi networks
func GetNetworks(inter string) ([]wifiNetwork, error) {
	out, err := exec.Command("iwlist", inter, "scanning").Output()
	if err != nil {
		return nil, err
	}

	nets, err := parseNetworks(string(out))
	if err != nil {
		return nets, errors.New("No scan results")
	}

	return nets, nil
}

func SetWifi(ssid string, key string) {
	input, err := ioutil.ReadFile("/etc/wpa_supplicant/wpa_supplicant.conf")
	if err != nil {
		log.Fatalln(err)
	}

	lines := strings.Split(string(input), "\n")

	for i, line := range lines {
		if strings.Contains(line, "ssid=\"") {
			lines[i] = "	ssid=\"" + ssid + "\""
		}

		if strings.Contains(line, "psk=\"") {
			lines[i] = "	psk=\"" + key + "\""
		}
	}
	output := strings.Join(lines, "\n")
	err = ioutil.WriteFile("/etc/wpa_supplicant/wpa_supplicant.conf", []byte(output), 0644)
	if err != nil {
		log.Fatalln(err)
	}

	_, err = exec.Command("sudo", "ifdown", "wlan1").Output()
	if err != nil {
		log.Fatal(err)
	}

	_, err = exec.Command("sudo", "ifup", "wlan1").Output()
	if err != nil {
		log.Fatal(err)
	}
}

func parseIWconfig(inn string) (wifiNetwork, error) {
	line := strings.Split(inn, "\n")

	if strings.Contains(line[0], "no wireless extensions") {
		return wifiNetwork{}, errors.New("no wireless extensions")
	}

	if strings.Contains(line[0], "ESSID:off/any") {
		return wifiNetwork{}, errors.New("Wifi not set")
	}

	info := wifiNetwork{
		ESSID: line[0][strings.Index(line[0], "ESSID:")+7 : len(line[0])-1],
	}

	return info, nil
}

// GetCurrentWifi - Get the network currently connected to. TODO: Make this better
func GetCurrentWifi(inter string) (wifiNetwork, error) {
	out, err := exec.Command("iwconfig", inter).Output()
	if err != nil {
		log.Fatal(err)
	}

	return parseIWconfig(string(out))
}
