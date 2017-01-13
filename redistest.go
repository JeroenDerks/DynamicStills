package main

import (
	"fmt"
	"gopkg.in/redis.v5"
)

func main() {
	client := redis.NewClient(&redis.Options{
		//Network:  "unix",
		//Addr:     "/tmp/redis.sock",
		Addr:     "127.0.0.1:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})
	pubsub, err := client.Subscribe("x-value")
	pubsub2, err2 := client.Subscribe("y-value")
	if err != nil {
		panic(err)
	}
	defer pubsub.Close()

	if err2 != nil {
		panic(err2)
	}
	defer pubsub2.Close()

	for {
		msg2, err2 := pubsub2.ReceiveMessage()
		msg, err := pubsub.ReceiveMessage()
		if err != nil {
			panic(err)
		}
		if err2 != nil {
			panic(err2)
		}
		fmt.Println(msg2.Channel, msg2.Payload)
		fmt.Println(msg.Channel, msg.Payload)
	}
}
