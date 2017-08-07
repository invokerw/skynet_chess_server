
all: proto/login.pb proto/room.pb proto/table.pb

proto/login.pb: proto/login.proto
	protoc --descriptor_set_out proto/login.pb proto/login.proto

proto/room.pb: proto/room.proto
	protoc --descriptor_set_out proto/room.pb proto/room.proto

proto/table.pb: proto/table.proto
	protoc --descriptor_set_out proto/table.pb proto/table.proto
