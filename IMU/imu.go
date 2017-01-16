package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"github.com/tarm/serial"
	"gopkg.in/redis.v5"
	"log"
)

type Nav struct {
	Navigation Imu `json:"navigation"`
}

func NewNav() *Nav {
	n := Nav{}
	return &n
}

type Imu struct {
	Heading float32 `json:"heading,omitempty"bson:"heading,omitempty"`
	Roll    float32 `json:"roll,omitempty"bson:"roll,omitempty"`
	Pitch   float32 `json:"pitch,omitempty"bson:"pitch,omitempty"`
}

func NewImu() *Imu {
	i := Imu{}
	return &i
}

func (i *Imu) Marshal() *[]byte {
	encoded, _ := json.Marshal(i)
	return &encoded
}

func main() {
	client := redis.NewClient(&redis.Options{
		//Network:  "unix",
		//Addr:     "/tmp/redis.sock",
		Addr:     "192.168.2.1:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	config := &serial.Config{
		Name: "/dev/ttyACM0",
		Baud: 115200,
	}
	arduino, err := serial.OpenPort(config)
	if err != nil {
		log.Panic(err.Error())
	}

	defer arduino.Close()

	reader := bufio.NewReader(arduino)
	var token []byte

	for {
		token, _, err = reader.ReadLine()
		if err != nil {
			log.Panic(err.Error())
		}
		currentNav := NewNav()
		err = json.Unmarshal(token, currentNav)
		if err != nil {

		}
		if err == nil {
			client.Publish("dynaHeading", fmt.Sprint(currentNav.Navigation.Heading))
			fmt.Println(currentNav.Navigation.Heading)
		}
	}
}
