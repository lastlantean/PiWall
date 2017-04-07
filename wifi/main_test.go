package wifi

import (
	"testing"
)

func TestParseIWconfig(t *testing.T) {
	output := "wlan1     IEEE 802.11bg  ESSID:\"test123\"\n" +
		"          Mode:Managed  Frequency:2.462 GHz  Access Point: 00:00:00:00:00:00\n"

	info, _ := parseIWconfig(output)

	if info.ESSID != "test123" {
		t.Error("essid did not match")
	}

	output1 := "wlan1     IEEE 802.11bg  ESSID:off/any\n"
	_, err := parseIWconfig(output1)

	if err.Error() != "Wifi not set" {
		t.Error("Should return error")
	}

	output2 := "eth0      no wireless extensions.\n"
	_, err2 := parseIWconfig(output2)

	if err2.Error() != "no wireless extensions" {
		t.Error("Should return error")
	}
}

func TestParseNetworks(t *testing.T) {
	output := "wlan0  Scan completed :\n" +
		"          Cell 01 - Address: 00:00:00:00:00:00\n" +
		"                    Channel:1\n" +
		"                    Frequency:2.412 GHz (Channel 1)\n" +
		"                    Quality=53/70  Signal level=-57 dBm\n" +
		"                    Encryption key:on\n" +
		"                    ESSID:\"TestNet\"\n" +
		"          Cell 02 - Address: 00:00:00:00:00:00\n" +
		"                    Channel:7\n" +
		"                    Frequency:2.442 GHz (Channel 7)\n" +
		"                    Quality=47/70  Signal level=-63 dBm\n" +
		"                    Encryption key:on\n" +
		"                    ESSID:\"NETGEAR\"\n"

	info, _ := parseNetworks(output)

	if info[0].ESSID != "TestNet" {
		t.Error("essid did not match")
	}

	if !info[0].Encrypted {
		t.Error("the network should be encrypted")
	}

}
