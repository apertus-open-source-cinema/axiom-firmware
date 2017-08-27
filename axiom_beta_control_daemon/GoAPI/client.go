// Copyright (C) 2017 apertus° Association & contributors
//
// This file is part of Axiom Beta Rest Interface.
//
// Axiom Beta Rest Interface is free software:
// you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

package main

import (
	schema "Schema/AxiomDaemon"
	"fmt"
	"io"
	"log"
	"net"

	flatbuffers "github.com/google/flatbuffers/go"
)

// Client for REST API
type Client struct {
	SocketPath string
	Builder    *flatbuffers.Builder
	Settings   []flatbuffers.UOffsetT
	Socket     net.Conn
}

// Init setups client
func (c *Client) Init() {
	c.SocketPath = "/tmp/axiom_daemon"
	c.SetupSocket()

	c.Builder = flatbuffers.NewBuilder(1024)
	c.Settings = make([]flatbuffers.UOffsetT, 0)
}

// reader processes the packages to send
func reader(r io.Reader) {
	buf := make([]byte, 1024)
	for {
		n, err := r.Read(buf[:])
		if err != nil {
			return
		}
		println("Client got:", string(buf[0:n]))
	}
}

// SetupSocket opens the socket connectiont to the daemon
func (c *Client) SetupSocket() {
	fmt.Printf("Socket path: %s\n", c.SocketPath)
	var err error
	c.Socket, err = net.Dial("unixgram", c.SocketPath)

	if err != nil {
		panic(err)
	}
}

// TransferData sends added settings to daemon
func (c *Client) TransferData() {
	//byteVector := c.Builder.CreateByteVector(c.Settings)

	schema.PacketStartSettingsVector(c.Builder, 1)
	c.Builder.PrependUOffsetT(c.Settings[0])
	settings := c.Builder.EndVector(1)

	schema.PacketStart(c.Builder)
	schema.PacketAddSettings(c.Builder, settings)
	p := schema.PacketEnd(c.Builder)
	c.Builder.Finish(p)

	bytes := c.Builder.FinishedBytes()

	_, err := c.Socket.Write(bytes)
	if err != nil {
		log.Fatal("write error:", err)
	}

}

// AddSettingIS provides method to add image sensor settings
// Write/read setting of image sensor
// Fixed to 2 bytes for now, as CMV used 128 x 2 bytes registers and it should be sufficient for first tests
func (c *Client) AddSettingIS(mode schema.Mode, imageSensorSetting schema.ImageSensorSettings, parameter uint16) {
	schema.ImageSensorSettingStart(c.Builder)
	schema.ImageSensorSettingAddMode(c.Builder, mode)
	schema.ImageSensorSettingAddSetting(c.Builder, imageSensorSetting)
	schema.ImageSensorSettingAddParameter(c.Builder, parameter)
	is := schema.ImageSensorSettingEnd(c.Builder)

	schema.PayloadStart(c.Builder)
	schema.PayloadAddPayloadType(c.Builder, schema.SettingImageSensorSetting)
	schema.PayloadAddPayload(c.Builder, is)
	payload := schema.PayloadEnd(c.Builder)

	c.Settings = append(c.Settings, payload)
}

func main() {
	c := new(Client)
	c.Init()

	//c.AddSettingSPI(Mode::Write, )
	c.AddSettingIS(schema.ModeWrite, schema.ImageSensorSettingsGain, 2)

	c.TransferData()

	server := new(RESTserver)
	server.Init()

	// TODO: Add c.Execute() to process sent settings as bulk
}
