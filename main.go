package main

import (
	"fmt"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/karalabe/hid"
	"github.com/shirou/gopsutil/v4/sensors"
)

const (
	VendorID  = 0x5131
	ProductID = 0x2007
)

func getCPUTemp() float64 {
	temps, err := sensors.SensorsTemperatures()
	if err != nil {
		return 0
	}
	for _, t := range temps {
		if strings.Contains(t.SensorKey, "k10temp") || strings.Contains(t.SensorKey, "coretemp") {
			return t.Temperature
		}
	}
	return 0
}

func main() {
	fmt.Printf("Iniciando controlador do CPU Cooler (PID: %d)\n", os.Getpid())

	// Handle interrupt signal for clean shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	done := make(chan bool, 1)
	go func() {
		lastHeartbeat := time.Time{}
		var device *hid.Device

		defer func() {
			if device != nil {
				device.Close()
			}
			done <- true
		}()

		for {
			if device == nil {
				// Search for device
				infos := hid.Enumerate(VendorID, ProductID)
				if len(infos) > 0 {
					var err error
					device, err = infos[0].Open()
					if err != nil {
						fmt.Printf("Erro ao abrir dispositivo: %v. Tentando novamente...\n", err)
						device = nil
					} else {
						fmt.Printf("\nConectado ao dispositivo %04x:%04x\n", VendorID, ProductID)
					}
				} else {
					fmt.Print("Aguardando dispositivo...\r")
				}

				if device == nil {
					time.Sleep(2 * time.Second)
					continue
				}
			}

			temp := getCPUTemp()

			// Heartbeat log every 60 seconds
			if time.Since(lastHeartbeat) > 60*time.Second {
				fmt.Printf("\n[Heartbeat] CPU Temp: %.1f°C - Dispositivo OK\n", temp)
				lastHeartbeat = time.Now()
			} else {
				fmt.Printf("CPU Temp: %.1f°C\r", temp)
			}

			// [ReportID, Comando, Temperatura, Padding...]
			// Python's write([0x00, 0x01, temp...]) works. 
			// In many HID libs, the first byte of Write() is the Report ID.
			buf := []byte{0x00, 0x01, byte(temp), 0x00, 0x00, 0x00}
			
			_, err := device.Write(buf)
			if err != nil {
				fmt.Printf("\nConexão perdida ou erro na escrita: %v. Tentando reconectar...\n", err)
				device.Close()
				device = nil
				time.Sleep(2 * time.Second)
				continue
			}

			time.Sleep(1 * time.Second)
		}
	}()

	select {
	case <-sigChan:
		fmt.Println("\nEncerrando...")
	case <-done:
	}
}
